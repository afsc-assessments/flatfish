#' Extract spawning stock biomass (ssb) from gmacs run
#'
#' Spawning biomass may be defined as all males or some combination of males and
#' females
#'
#' @param M list object created by read_admb function
#' @return dataframe of spawning biomass
#' @export
#' 
.get_srr_df <- function(M)
{
    n <- length(M)
    mdf <- NULL
    for (i in 1:n) {
        A <- M[[i]]
        df <- data.frame(
        ssb     = A$SRR_SSB,
        Model   = names(M)[i],
        rhat    = A$rechat,
        rhat.sd = A$rechat.sd,
        lb      = A$rechat/exp(2*sqrt(log(1+A$rechat.sd^2/A$rechat^2))),
        ub      = A$rechat*exp(2*sqrt(log(1+A$rechat.sd^2/A$rechat^2)))
        )
        mdf     <- rbind(mdf, df)
    }
    return(mdf)
}
.get_sr_est_df <- function(M)
{
    # Return SSB and Recruits 
    n <- length(M)
    mdf2 <- NULL
    for (i in 1:n)
    {
        A <- M[[i]]
        ts_len   <- 2:(length(A$SSB[,2]))
        df    = data.frame(
        Model = names(M)[i],
        ssb   = A$SSB[ts_len-1,2],
        Year  = A$SSB[ts_len,1],
        rhat  = A$R[ts_len,2],
        lb    = A$R[ts_len,4],
        ub    = A$R[ts_len,5])
        mdf2    <- rbind(mdf2, df)
    }
    return(mdf2)
}



#' Plot predicted spawning stock biomass (ssb)
#'
#' Spawning biomass may be defined as all males or some combination of males and
#' females
#'
#' @param M List object(s) created by read_admb function
#' @param xlab the x-label of the figure
#' @param ylab the y-label of the figure
#' @param ylim is the upper limit of the figure
#' @param alpha the opacity of the ribbon
#' @return Plot of model estimates of spawning stock biomass 
#' @export
#' 
plot_srr <- function(M, ylab = "Recruits (age 1, billions)", xlab = "Female spawning biomass (kt)", 
                     ylim = NULL, xlim=NULL, alpha = 0.05,ebar="FALSE",leglabs=NULL,styr=1978,endyr=2012)
{
    xlab <- paste0("\n", xlab)
    ylab <- paste0(ylab, "\n")
    
    mdf <- .get_srr_df(M)
    
    p <- ggplot(mdf) + labs(x = xlab, y = ylab) 

    if (!is.null(xlim))
        p <- p + xlim(xlim[1], xlim[2])        

    if (is.null(ylim))
    {
        p <- p + expand_limits(y = 0)
    } else {
        p <- p + ylim(c(ylim[1], ylim[2])        )
    }
    
    if (length(M) == 1)
    {
        p <- p + geom_line(aes(x = ssb, y = rhat)) +
            geom_ribbon(aes(x = ssb, ymax = ub, ymin = lb), alpha = alpha)
    } else {
        p <- p + geom_line(aes(x = ssb, y = rhat, col = Model),size=1.2) +
            geom_ribbon(aes(x = ssb, ymax = ub, ymin = lb, fill = Model), alpha = alpha)
    }
    mdf2<- .get_sr_est_df(M)
	mdf3<- filter(mdf2,Year<=endyr&Year>=styr)
    mdf2<- filter(mdf2,Year>endyr|Year<styr)
    if (length(M) == 1)
    {
        p <- p + geom_text(data=mdf2, aes(x = ssb, y = rhat, label=Year),size=3) 
        p <- p + geom_text(data=mdf3, aes(x = ssb, y = rhat, label=Year),size=5)#,fontface="bold") 
        if (ebar) p <- p + geom_errorbar(data=mdf2, aes(x = ssb, ymax = ub, ymin = lb))
    } else {
        p <- p + geom_text(data=mdf2, aes(x = ssb, y = rhat, label=Year , col = Model),size=3) 
        p <- p + geom_text(data=mdf3, aes(x = ssb, y = rhat, label=Year , col = Model),size=5)#,fontface="bold") 
        if (ebar) p <- p +  geom_errorbar(data=mdf2, aes(x = ssb, ymax = ub, ymin = lb ,colour=Model))
    }
    
    if (!is.null(leglabs)) p = p + scale_color_discrete(labels=leglabs)
    #p <- p + scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0))

    if(!.OVERLAY) p <- p + facet_wrap(~Model)
    print(p + .THEME + guides(fill=FALSE))
}
