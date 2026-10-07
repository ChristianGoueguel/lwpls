## R CMD check results

0 errors | 0 warnings | 2 notes

* This is a new submission.

* On Linux, the installed size is about 7.7 Mb (sub-directories of 1Mb or
  more: libs 4.5Mb, doc 2.3Mb). The libs directory holds the compiled
  'RcppArmadillo' prediction kernel, and the doc directory holds four vignettes
  with figures.

## Test environments

* local macOS (aarch64), R 4.6.1
* GitHub Actions: macOS (release), Windows (release), Ubuntu (devel, release,
  oldrel-1)

## Notes for the reviewer

* The tests compare the package against an R transcription of Hiromasa
  Kaneko's MIT-licensed reference implementation of LW-PLS
  (tests/testthat/helper-reference.R). He is listed as a copyright holder
  in Authors@R.
