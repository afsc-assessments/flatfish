
#' Get observed and predicted size composition values
#'
#' @param M a list of lists created by the read_admb function
#' @return a list of observed and predicted age composition values
#' @author Jim Ianelli
#' @export
#'
.get_ageComps_df <- function(M,nages=20,type="fishery",sex="split")
{
    n <- length(M)
    ldf <- list()
    mdf <- mpf <- mrf <- NULL
    for(i in 1:n)
    {
        A <- M[[i]]
        if (type=="fishery"){
          if (sex=="split"){
            df <- data.frame(Model=names(M)[i], sex="Females",cbind(A$yrs_fsh_age_s,A$oac_fsh_s[,1:nages]) )
            pf <- data.frame(Model=names(M)[i], sex="Females",cbind(A$yrs_fsh_age_s,A$eac_fsh_s[,1:nages]) )
            df <- rbind(df,data.frame(Model=names(M)[i], sex="Males",cbind(A$yrs_fsh_age_s,A$oac_fsh_s[,(nages+1):(2*nages)])))
            pf <- rbind(pf,data.frame(Model=names(M)[i], sex="Males",cbind(A$yrs_fsh_age_s,A$eac_fsh_s[,(nages+1):(2*nages)])))
          }
          else
          {
          }
        }
        else # survey
        {
          if (sex=="split"){
            df <- data.frame(Model=names(M)[i], sex="Females",cbind(A$yrs_srv_age_s,A$oac_srv_s[,1:nages]) )
            pf <- data.frame(Model=names(M)[i], sex="Females",cbind(A$yrs_srv_age_s,A$eac_srv_s[,1:nages]) )
            df <- rbind(df,data.frame(Model=names(M)[i], sex="Males",cbind(A$yrs_srv_age_s,A$oac_srv_s[,(nages+1):(2*nages)])))
            pf <- rbind(pf,data.frame(Model=names(M)[i], sex="Males",cbind(A$yrs_srv_age_s,A$eac_srv_s[,(nages+1):(2*nages)])))
          }
          else
          {
            
          }
          
        }
        colnames(df) <- tolower(c("Model", "Sex", "Year",as.character(1:nages) ))
        colnames(pf) <- colnames(df)
		
        mdf <- rbind(mdf,df)
        mpf <- rbind(mpf,pf)
    }
    mdf <- melt(mdf,id.var=1:3)
    mpf <- melt(mpf,id.var=1:3)
    
    for(i in 1:n)
    {
      mdf <-cbind(mdf,pred=mpf$value)
    }   
    return(mdf)
}


#' Plot fits to size composition data
#' 
#' Get observed and predicted size composition values
#'
#' @param M List object(s) created by read_admb function
#' @param which_plots the size composition fits that you want to plot
#' @param xlab the x-axis label for the plot
#' @param ylab the y-axis label for the plot
#' @param slab the sex label for the plot that appears above the key
#' @param mlab the model label for the plot that appears above the key
#' @param tlab the fleet label for the plot that appears above the key
#' @return Plots of observed and predicted size composition values
#' @author SJD Martell, D'Arcy N. Webber
#' @export
#'
plot_age_comps <- function(M, xlab = "Age (yrs)", ylab = "Proportion", 
                           nages=20,type="fishery",sex="split",title="Fishery age compositions")
{
    xlab <- paste0("\n", xlab)
    ylab <- paste0(ylab, "\n")

    mdf <- .get_ageComps_df(M,nages,type,sex)
    
    ix <- pretty(1:nages)
    tdf <- mdf %>% mutate(pred=if_else(sex=="Males",-pred,pred),value=if_else(sex=="Males",-value,value))
    p <- ggplot(tdf,aes(variable,value,fill=sex)) +
         geom_bar(stat="identity",alpha=0.5)
    p <- p + geom_line(aes(as.numeric(variable),pred,col=sex),alpha=0.85)
    p <- p + scale_x_discrete(breaks=ix) 
    p <- p + labs(x = xlab, y = ylab)
    p <- p + ggtitle(title)
    p <- p + facet_wrap(~year) + .THEME
    #p <- p + facet_grid(irow~icol,labeller=label_both) + .THEME
    p <- p + theme(axis.text.x = element_text(angle = 45, vjust = 0.5))
    print(p)
}


#' plot_sizeCompRes
#' 
#' Get observed and predicted size composition values
#'
#' @param M List object(s) created by read_admb function
#' @return Plots of observed and predicted size composition values
#' @author SJD Martell, D'Arcy N. Webber
#' @export
#'
plot_ageCompRes <- function(M, which_plot = "all")
{
    mdf <- .get_ageComps_df(M)
    
    p <- ggplot(data=mdf[[1]])
    p <- p + geom_point(aes(factor(year),variable,col=factor(sign(resd)),size=abs(resd)),alpha=0.6)
    p <- p + scale_size_area(max_size=10)
    p <- p + labs(x="Year",y="Length",col="Sign",size="Residual")
    p <- p + scale_x_discrete(breaks=pretty(mdf[[1]]$mod_yrs))
    p <- p + scale_y_discrete(breaks=pretty(mdf[[1]]$mid_points))
    p <- p + facet_wrap(~model)+ .THEME
    fun <- function(x,p)
    {
        p %+% x
    }
    plist <- lapply(mdf,fun,p=p)
    if (which_plot == "all")
    {
        print(plist)
    } else {
        print(plist[[which.plot]])
    }
}
