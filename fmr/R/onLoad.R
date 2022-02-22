#' On load hook
#'
#' This is a load hook that is called by R when the package is loaded. This
#' should not be exported
#' 
#' @author J Ianelli
#' 
.onLoad <- function(libname, pkgname)
{
  cat("\n")
  cat("==============================================================\n")
  cat("Flatfish stock assessment plotting library\n")
  cat(fmr.version())
  cat("For help see https://github.com/afsc-assessments/flatfish/fmr\n")
  cat("==============================================================\n")
  cat("\n")
}


