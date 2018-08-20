#' Extract spawning stock biomass (q_srv) from gmacs run
#'
#' Spawning biomass may be defined as all males or some combination of males and
#' females
#'
#' @param M list object created by read_admb function
#' @return dataframe of spawning biomass
#' @export
#' 
.get_m_df <- function(M)
{
    n <- length(M)
    mdf <- NULL
    for (i in 1:n)
    {
        print(i)
        A <- M[[i]]
        df <- data.frame( nLogPost  = A$nLogPosterior[c(6,7,8,9,10,11,12,13,15,16,17,19)] )
                    df$Component <- c("sexratio" , 'Survey Index',    'catch',  'Fishery age comp',    'Survey age comp',    'Recruitment-1',    'Recruitment-2',    'Recruitment-3',    'Fishery selectivity',    'Survey selectivity',    'q prior',  'fpen')
        df$Model <- names(M)[i]
        df$M_female  <- A$natmort_f 
        df$M_male  <- A$natmort_m 
        mdf        <- rbind(mdf, df)
    }
    mdf <- mdf %>% group_by(Component) %>% mutate(min = min(nLogPost),range=max(nLogPost)-min ) %>% ungroup() %>%filter(range>4)%>%mutate(nLogPost=nLogPost-min)
    return(mdf)
}
#m.df <- .get_m_df(M)

#' Plot predicted q_srv
#'
#' @param M List object(s) created by read_admb function
#' @param xlab the x-label of the figure
#' @param ylab the y-label of the figure
#' @param ylim is the upper limit of the figure
#' @param alpha the opacity of the ribbon
#' @return Plot of model estimates of spawning stock biomass 
#' @export
#' 
plot_m <- function(M, xlab = "Natural mortality", ylab = "-log density", ylim = NULL, xlim=NULL, alpha = 0.1)
{
    xlab <- paste0("\n", xlab)
    ylab <- paste0(ylab, "\n")
    
    mdf <- .get_m_df(M)
    
    p <- ggplot(mdf) + labs(x = xlab, y = ylab)
    
    if (!is.null(xlim))
        p <- p + xlim(xlim[1], xlim[2])        

    if (is.null(ylim))
    {
        p <- p + expand_limits(y = 0)
    } else {
        p <- p + ylim(ylim[1], ylim[2])        
    }
    
    if (length(M) == 1)
    {
        p <- p + geom_line(aes(x = M_female, y = nLogPost)) 
    } else {
        p <- p + geom_line(aes(x = M_female, y = nLogPost, col=Component),size=1.2) + geom_point(aes(x = M_female, y = nLogPost, col=Component,shape=Component),size=3) 
    }
    
    #if(!.OVERLAY) p <- p + facet_wrap(~Model)
    print(p + .THEME)
}
plot_m(M)