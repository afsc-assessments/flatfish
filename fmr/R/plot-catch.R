#' Get observed and predicted catch values
#'
#' @param M List object(s) created by read_admb function
#' @return dataframe of catch history (observed) and predicted values
#' @author SJD Martell, D'Arcy N. Webber
#' @export
#' 
.get_catch_df <- function(M)
{
    n  <- length(M)
    mdf <- NULL
    for( i in 1:n )
    {
        A <- M[[i]]
        df <- data.frame(Model = names(M)[i], A$dCatchData)
        colnames(df) <- c("model","year","seas","fleet","sex","obs","cv","type","units","mult","effort","discard.mortality")
        df$observed  <- na.omit(as.vector(t(A$obs_catch)))
        df$predicted <- na.omit(as.vector(t(A$pre_catch)))
        df$residuals <- na.omit(as.vector(t(A$res_catch)))
        df$sex       <- .SEX[df$sex+1]
        df$fleet     <- .FLEET[df$fleet]
        df$type      <- .TYPE[df$type+1]
        sd    <- sqrt(log(1+df$cv^2))
        df$lb <- exp(log(df$obs)-1.96*sd)
        df$ub <- exp(log(df$obs)+1.96*sd)
        mdf <- rbind(mdf, df)
    }
    mdf$year <- as.integer(mdf$year)
    return(mdf)
}


#' Plot observed and predicted catch values
#'
#' @param M list object created by read_admb function
#' @param plot_res plot residuals only (default = FALSE)
#' @param xlab the x-axis label for the plot
#' @param ylab the y-axis label for the plot
#' @param mlab the model label for the plot that appears above the key
#' @return plot of catch history (observed) and predicted values
#' @author SJD Martell, D'Arcy N. Webber
#' @export
#' 
plot_catch <- function(M , plot_res = FALSE,
                       xlab = "Year", ylab = "Catch", mlab = "Model")
{
    xlab <- paste0("\n", xlab)
    ylab <- paste0(ylab, "\n")

    mdf <- .get_catch_df(M)
    
    #if (plot_res)
    #{
      ## Residuals
      #p <- ggplot(df,aes(x=factor(year),y=residuals,fill=factor(sex)))
      #p <- p + geom_bar(stat = "identity", position="dodge")
      #p <- p + scale_x_discrete(breaks=pretty(df$year))
      #p <- p + labs(x="Year",y="Residuals ln(kt)",fill="Sex")
      #p <- p + facet_wrap(~fleet~type,scales="free")
    #}
    #else
    #p <- ggplot(mdf, aes(x = as.integer(year), y = observed, fill = sex))
    p <- ggplot(mdf, aes(x = year, y = observed)) +
        geom_bar(stat = "identity", position = "dodge", alpha = 0.15) +
        geom_linerange(aes(year, observed, ymax = ub, ymin = lb, position = "dodge"), size = 0.2, alpha = 0.5, col = "black") +
        labs(x = xlab, y = ylab)
    if(.OVERLAY)
    {
        if (length(M) == 1)
        {
            p <- p + facet_wrap(~sex + fleet + type, scales = "free_y")	+
                geom_line(aes(x = as.integer(year), y = predicted), alpha = 0.8)
        } else {
            p <- p + facet_wrap(~sex + fleet + type, scales = "free_y")	+
                geom_line(aes(x = as.integer(year), y = predicted, col = model), alpha = 0.8) +
                labs(col = mlab)
        }
    } else {
        p <- p + facet_wrap(~model + sex + fleet + type, scales = "free_y") +
            geom_line(aes(x = as.integer(year), y = predicted, col = model), alpha = 0.8)
    }
    print(p + .THEME)
}
