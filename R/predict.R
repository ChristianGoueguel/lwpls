# Post-processor for when only the largest value of ncomp is being used. This
# works for regression predictions
single_numeric_preds <- function(results, object) {
  tmp_pred <- results$predict
  n <- dim(tmp_pred)[1]
  p <- dim(tmp_pred)[2]
  ncomp <- dim(tmp_pred)[3]
  tmp_pred <- tmp_pred[,,ncomp]
  if (p == 1) {
    res <- tibble::tibble(.pred = unname(tmp_pred))
  } else {
    res <- tibble::as_tibble(tmp_pred)
    names(res) <- paste0(".pred_", names(res))
  }
  res
}

single_class_preds <- function(results, object) {
  tmp_pred <- results$class$mahalanobis
  n <- dim(tmp_pred)[1]
  ncomp <- dim(tmp_pred)[2]
  tmp_pred <- tmp_pred[,ncomp]
  res <- tibble::tibble(.pred_class = unname(tmp_pred))
  res$.pred_class <- factor(res$.pred_class, levels = object$lvl)
  res
}

smax <- function(x) exp(x)/sum(exp(x))

single_prob_preds <- function(results, object) {
  tmp_pred <- results$predict
  n <- dim(tmp_pred)[1]
  p <- dim(tmp_pred)[2]
  ncomp <- dim(tmp_pred)[3]
  tmp_pred <- tmp_pred[,,ncomp]
  tmp_pred <- apply(tmp_pred, 1, smax)
  tmp_pred <- tibble::as_tibble(t(tmp_pred))
  names(tmp_pred) <- paste0(".pred_", names(tmp_pred))
  tmp_pred
}
