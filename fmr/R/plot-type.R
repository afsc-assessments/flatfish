#' Specify the type of plot you would like to create
#'
#' @param filename the directory and name of the file to save
#' @param fmr_options a list of options for plotting
#' @param width the width of the plot in mm
#' @param height the height of the plot in mm
#' @return a plot device
#' @author DN Webber
#' @export
#' 
plot_type <- function(filename, width, height, fmr_options = .fmr_options)
{
    if (fmr_options$plot_type %in% c("png","PNG",".png",".PNG","Png",".Png"))
    {
        png(paste(filename, ".png", sep = ""), width = width, height = height,
            unit = "mm", res = fmr_options$plot_resolution)
    }
}
