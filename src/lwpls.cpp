// Locally-weighted partial least squares (LW-PLS): prediction kernel.
//
// For every query sample x_q, each training sample i receives the similarity
// weight (Kim et al. 2011; Kaneko)
//
//     w_i = exp(-d_i / (sd(d) * localization)),   d_i = ||x_i - x_q||,
//
// and a weighted PLS model is fitted around the query. The weighted PLS uses
// the kernel formulation of Dayal & MacGregor (1997): only the p x q
// cross-product matrix X'WY is deflated and the scores are computed through
// the R = W(P'W)^-1 weights, so the n x p training matrix is never copied or
// deflated. Queries are processed in blocks so that the expensive steps
// (distances, local means, scores and loadings) are matrix-matrix products
// that run through level-3 BLAS.

// [[Rcpp::depends(RcppArmadillo)]]
#include <RcppArmadillo.h>

#include <algorithm>
#include <cmath>
#include <limits>
#include <numeric>
#include <vector>

namespace {

// Weights smaller than this (relative to the nearest sample, whose weight is
// one) are set to zero. They have no measurable influence on the local model
// but would otherwise let numerical noise dominate when the model is very
// local.
const double weight_floor = std::numeric_limits<double>::epsilon();

// Similarity weights of the training samples for one query. `w` (length n) is
// overwritten; samples outside the `k` nearest neighbours get a zero weight.
// Returns the number of non-zero weights.
arma::uword similarity_weights(const double* dist, const arma::uword n,
                               const arma::uword k, const double localization,
                               double* w, std::vector<arma::uword>& idx) {
  std::fill(w, w + n, 0.0);
  std::iota(idx.begin(), idx.end(), arma::uword(0));
  if (k < n) {
    std::nth_element(idx.begin(), idx.begin() + k, idx.end(),
                     [dist](arma::uword a, arma::uword b) {
                       return dist[a] < dist[b];
                     });
  }

  double d_min = std::numeric_limits<double>::infinity();
  double d_mean = 0.0;
  for (arma::uword s = 0; s < k; ++s) {
    const double d = dist[idx[s]];
    d_mean += d;
    d_min = std::min(d_min, d);
  }
  d_mean /= static_cast<double>(k);

  double ss = 0.0;
  for (arma::uword s = 0; s < k; ++s) {
    const double dev = dist[idx[s]] - d_mean;
    ss += dev * dev;
  }
  const double d_sd = k > 1 ? std::sqrt(ss / static_cast<double>(k - 1)) : 0.0;

  // All distances equal: every sample is equally similar.
  if (!(d_sd > 0.0) || !std::isfinite(d_sd)) {
    for (arma::uword s = 0; s < k; ++s) w[idx[s]] = 1.0;
    return k;
  }

  // Shifting by the smallest distance rescales all weights by a constant,
  // which leaves the weighted PLS model unchanged but avoids underflow.
  const double bandwidth = d_sd * localization;
  arma::uword n_nonzero = 0;
  for (arma::uword s = 0; s < k; ++s) {
    const arma::uword i = idx[s];
    const double value = std::exp(-(dist[i] - d_min) / bandwidth);
    if (value >= weight_floor) {
      w[i] = value;
      ++n_nonzero;
    }
  }
  return n_nonzero;
}

}  // namespace

// Predictions of LW-PLS models with 1, ..., num_comp components.
//
// x, y   : training predictors (n x p) and outcomes (n x q), already centred
//          (and possibly scaled).
// new_x  : query predictors (m x p), transformed like x.
// Returns an m x q x num_comp array of predictions on the scale of y.
// [[Rcpp::export(rng = false)]]
arma::cube lwpls_predict_cpp(const arma::mat& x, const arma::mat& y,
                             const arma::mat& new_x, const int num_comp,
                             const double localization, const int neighbors,
                             const double tol) {
  const arma::uword n = x.n_rows;
  const arma::uword p = x.n_cols;
  const arma::uword q = y.n_cols;
  const arma::uword m = new_x.n_rows;
  const arma::uword n_comp = static_cast<arma::uword>(std::max(num_comp, 1));
  const arma::uword k =
      std::min(n, static_cast<arma::uword>(std::max(neighbors, 1)));

  arma::cube out(m, q, n_comp, arma::fill::zeros);
  if (m == 0 || n == 0) return out;

  // Block size: keep the per-block working memory around 128 MB.
  const double per_query = 3.0 * n + 2.0 * p * n_comp + 1.0 * p * q + 4.0 * p;
  const arma::uword block = static_cast<arma::uword>(
      std::max(1.0, std::min(256.0, 16777216.0 / per_query)));

  // Products are written with the explicitly transposed training data: the
  // reference BLAS shipped with R is much slower for transposed products.
  const arma::mat xt = x.t();  // p x n
  const arma::mat yt = y.t();  // q x n
  const arma::vec x_sq = arma::sum(arma::square(x), 1);
  std::vector<arma::uword> idx(n);
  arma::vec dist(n);

  for (arma::uword start = 0; start < m; start += block) {
    Rcpp::checkUserInterrupt();
    const arma::uword end = std::min(start + block, m);
    const arma::uword b = end - start;
    const arma::mat query = new_x.rows(start, end - 1).t();  // p x b

    // Distances and similarity weights -------------------------------------
    arma::mat w = x * query;  // n x b; cross-products, then overwritten
    const arma::rowvec query_sq = arma::sum(arma::square(query), 0);
    std::vector<arma::uword> max_comp(b);
    for (arma::uword j = 0; j < b; ++j) {
      double* col = w.colptr(j);
      for (arma::uword i = 0; i < n; ++i) {
        const double d2 = x_sq[i] + query_sq[j] - 2.0 * col[i];
        dist[i] = d2 > 0.0 ? std::sqrt(d2) : 0.0;
      }
      const arma::uword n_nonzero =
          similarity_weights(dist.memptr(), n, k, localization, col, idx);
      // A weighted-centred matrix with n_nonzero rows has rank < n_nonzero.
      max_comp[j] = std::min({n_comp, p, n_nonzero - 1});
    }
    const arma::rowvec w_sum = arma::sum(w, 0);

    // Local (weighted) means and centred queries ----------------------------
    arma::mat x_mean = xt * w;  // p x b
    x_mean.each_row() /= w_sum;
    arma::mat y_mean = yt * w;  // q x b
    y_mean.each_row() /= w_sum;
    const arma::mat query_c = query - x_mean;

    // Cross-products X_c' W Y_c, one p x q slice per query ------------------
    // Outcomes are centred explicitly, predictors through the identity
    // X_c' W Y_c = X' W Y_c - x_mean (1' W Y_c).
    arma::cube xy(p, q, b);
    arma::mat z(n, b);
    for (arma::uword c = 0; c < q; ++c) {
      for (arma::uword j = 0; j < b; ++j) {
        z.col(j) = w.col(j) % (y.col(c) - y_mean(c, j));
      }
      const arma::mat xz = xt * z;
      const arma::rowvec z_sum = arma::sum(z, 0);
      for (arma::uword j = 0; j < b; ++j) {
        xy.slice(j).col(c) = xz.col(j) - x_mean.col(j) * z_sum[j];
      }
    }

    // Total weighted sum of squares of the centred predictors (tolerances).
    arma::rowvec ss_x =
        (w.t() * x_sq).t() - w_sum % arma::sum(arma::square(x_mean), 0);
    ss_x.transform([](double v) { return v > 0.0 ? v : 0.0; });

    // Latent variables -------------------------------------------------------
    arma::mat pred = y_mean;  // q x b
    arma::cube r_hist(p, n_comp, b);
    arma::cube p_hist(p, n_comp, b);
    arma::vec xy_norm0(b);
    std::vector<char> active(b);
    for (arma::uword j = 0; j < b; ++j) {
      xy_norm0[j] = arma::norm(xy.slice(j), "fro");
      active[j] = max_comp[j] > 0 && xy_norm0[j] > 0.0 &&
                  std::isfinite(xy_norm0[j]);
    }

    arma::mat r_cur(p, b);
    arma::rowvec tt(b);
    for (arma::uword a = 0; a < n_comp; ++a) {
      // Weights w_a (dominant left singular vector of the deflated X'WY) and
      // the corresponding R weights r_a = w_a - R (P' w_a).
      r_cur.zeros();
      arma::uword n_active = 0;
      for (arma::uword j = 0; j < b; ++j) {
        if (!active[j]) continue;
        const arma::mat& xy_j = xy.slice(j);
        const double xy_norm = arma::norm(xy_j, "fro");
        if (a >= max_comp[j] || !(xy_norm > tol * xy_norm0[j])) {
          active[j] = 0;
          continue;
        }
        arma::vec w_a;
        if (q == 1) {
          w_a = xy_j.col(0) / xy_norm;
        } else {
          arma::vec eig_val;
          arma::mat eig_vec;
          if (!arma::eig_sym(eig_val, eig_vec, xy_j.t() * xy_j)) {
            active[j] = 0;
            continue;
          }
          w_a = xy_j * eig_vec.col(q - 1);
          w_a /= arma::norm(w_a);
        }
        if (a > 0) {
          const arma::vec proj = p_hist.slice(j).head_cols(a).t() * w_a;
          r_cur.col(j) = w_a - r_hist.slice(j).head_cols(a) * proj;
        } else {
          r_cur.col(j) = w_a;
        }
        ++n_active;
      }

      if (n_active > 0) {
        // Scores of the training samples: t = X_c r = X r - (x_mean' r) 1.
        arma::mat t = x * r_cur;  // n x b
        for (arma::uword j = 0; j < b; ++j) {
          if (active[j]) {
            t.col(j) -= arma::dot(x_mean.col(j), r_cur.col(j));
            z.col(j) = w.col(j) % t.col(j);
            tt[j] = arma::dot(z.col(j), t.col(j));
            if (!(tt[j] > tol * ss_x[j]) || !std::isfinite(tt[j])) {
              active[j] = 0;
            }
          }
          if (!active[j]) z.col(j).zeros();
        }

        // Loadings p_a = X_c' W t / (t' W t).
        const arma::mat xwt = xt * z;  // p x b
        for (arma::uword j = 0; j < b; ++j) {
          if (!active[j]) continue;
          const arma::vec& r_j = r_cur.col(j);
          const arma::vec x_load =
              (xwt.col(j) - x_mean.col(j) * arma::accu(z.col(j))) / tt[j];
          const arma::vec y_load = xy.slice(j).t() * r_j / tt[j];
          const double t_query = arma::dot(query_c.col(j), r_j);

          pred.col(j) += t_query * y_load;
          xy.slice(j) -= x_load * (tt[j] * y_load.t());
          r_hist.slice(j).col(a) = r_j;
          p_hist.slice(j).col(a) = x_load;
        }
      }

      // Queries whose local model is exhausted keep their last prediction.
      for (arma::uword j = 0; j < b; ++j) {
        for (arma::uword c = 0; c < q; ++c) {
          out(start + j, c, a) = pred(c, j);
        }
      }
    }
  }

  return out;
}
