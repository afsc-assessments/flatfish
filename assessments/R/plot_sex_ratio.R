#' Extract Sex ratio
#'
#' @param M list object created by read_admb function
#' @return dataframe of spawning biomass
#' @export
#' 
.get_sr_df <- function(M)
{
    n <- length(M)
    mdf <- NULL
    for (i in 1:n)
    {
        A        <- M[[i]]
        df <- data.frame(A$Sex_ratio_population,type="Population")
        df <- rbind(df,data.frame(A$Sex_ratio_mature,type="Mature"))
        df <- rbind(df,data.frame(A$Sex_ratio_age_7_plus,type="Age_7_plus"))
        df <- rbind(df,data.frame(A$Sex_ratio_survey[,1:2],type="Survey_obs"))
        df <- rbind(df,data.frame(V1=A$Sex_ratio_survey[,1], V2=A$Sex_ratio_survey[,3], type="Survey_pred"))
        df <- rbind(df,data.frame(A$Sex_ratio_fishery[,1:2],type="Fishery_obs"))
        df <- rbind(df,data.frame(V1=A$Sex_ratio_fishery[,1], V2=A$Sex_ratio_fishery[,3], type="Fishery_pred"))
        df$Model <- names(M)[i]
        mdf      <- rbind(mdf, df)
    }
    names(mdf) <- c("Year","Ratio","Type")
    mdf$Year   <- as.numeric(mdf$Year)
    return(mdf)
}


#' Plot predicted sex ratios
#'
#' @param M List object(s) created by read_admb function
#' @param xlab the x-label of the figure
#' @param ylab the y-label of the figure
#' @param ylim is the upper limit of the figure
#' @param alpha the opacity of the ribbon
#' @return Plot of model estimates of spawning stock biomass 
#' @export
#' 
plot_sex_ratio_panel <- function(mdf, xlab = "Year", ylab = "Proportion female ", ylim = NULL, xlim=NULL, alpha = 0.1,type="Fishery")
{
    xlab <- paste0("\n", xlab)
    ylab <- paste0(ylab, "\n")
    
    mdf <- .get_sr_df(M)

  if (type=="Fishery")
    A   <- mdf %>% filter(source=="Fishery_obs"|source=="Fishery_est" )
  if (type=="Survey")
    A   <- mdf %>% filter(source=="Survey_obs"|source=="Survey_est" )
  if (type=="Population")
    A   <- mdf %>% filter(source=="Population")
  A <- A %>% arrange(Model,source,Year)
  
    p <- ggplot(A) + labs(x = xlab, y = ylab)
    
    if (!is.null(xlim))
      p <- p + xlim(xlim[1], xlim[2])        

    if (is.null(ylim))
    {
        p <- p + expand_limits(y = 0)
    } else {
        p <- p + ylim(ylim[1], ylim[2])        
    }
    
  if (type=="Survey") 
  {
    tmp <- A %>% filter(source=="Survey_obs") 
    p   <- p + geom_point(data=tmp, aes(x = Year, y = Females),size=3)  

    tmp <- A %>% filter(source=="Survey_est") 
    p   <- p + geom_path(data=tmp, aes(x = Year, y = Females,color=Model),size=1.2) 
  }
  if (type==c("Fishery"))
  {
    tmp <- A %>% filter(source=="Fishery_obs") 
    p   <- p + geom_point(data=tmp, aes(x = Year, y = Females),size=3) 

    tmp <- A %>% filter(source=="Fishery_est") 
    p   <- p + geom_path(data=tmp, aes(x = Year, y = Females,color=Model),size=1.2,position="identity") 
  } 
  if (type=="Population")
  {
    p <- p + geom_path(aes(x = Year, y = Females,color=Model), size=1.2,position="identity" ) 
  }

  print(p + .THEME + ggtitle(type))
}

#plot_sex_ratio(M,ylim=c(.25,.75))
#plot_sex_ratio(M,ylim=c(.25,.75),type="Population")
#plot_sex_ratio(M,ylim=c(.25,.75),type="Survey")



#' Plot predicted sex ratios
#'
#' @param M List object(s) created by read_admb function
#' @param xlab the x-label of the figure
#' @param ylab the y-label of the figure
#' @param ylim is the upper limit of the figure
#' @param alpha the opacity of the ribbon
#' @return Plot of model estimates of spawning stock biomass 
#' @export
#' 
plot_sex_ratio <- function(M, xlab = "Year", ylab = "Proportion female ", ylim = NULL, xlim=NULL, alpha = 0.1,type="Fishery")
{
    xlab <- paste0("\n", xlab)
    ylab <- paste0(ylab, "\n")
    
    mdf <- .get_sr_df(M)

  if (type=="Fishery")
    A   <- mdf %>% filter(source=="Fishery_obs"|source=="Fishery_est" )
  if (type=="Survey")
    A   <- mdf %>% filter(source=="Survey_obs"|source=="Survey_est" )
  if (type=="Population")
    A   <- mdf %>% filter(source=="Population")
  A <- A %>% arrange(Model,source,Year)
  
    p <- ggplot(A) + labs(x = xlab, y = ylab)
    
    if (!is.null(xlim))
      p <- p + xlim(xlim[1], xlim[2])        

    if (is.null(ylim))
    {
        p <- p + expand_limits(y = 0)
    } else {
        p <- p + ylim(ylim[1], ylim[2])        
    }
    
  if (type=="Survey") 
  {
  	tmp <- A %>% filter(source=="Survey_obs") 
    p   <- p + geom_point(data=tmp, aes(x = Year, y = Females),size=3)  

  	tmp <- A %>% filter(source=="Survey_est") 
    p   <- p + geom_path(data=tmp, aes(x = Year, y = Females,color=Model),size=1.2) 
  }
  if (type==c("Fishery"))
  {
  	tmp <- A %>% filter(source=="Fishery_obs") 
    p   <- p + geom_point(data=tmp, aes(x = Year, y = Females),size=3) 

    tmp <- A %>% filter(source=="Fishery_est") 
    p   <- p + geom_path(data=tmp, aes(x = Year, y = Females,color=Model),size=1.2,position="identity") 
  } 
  if (type=="Population")
  {
    p <- p + geom_path(aes(x = Year, y = Females,color=Model), size=1.2,position="identity" ) 
  }

  print(p + .THEME + ggtitle(type))
}

#plot_sex_ratio(M,ylim=c(.25,.75))
#plot_sex_ratio(M,ylim=c(.25,.75),type="Population")
#plot_sex_ratio(M,ylim=c(.25,.75),type="Survey")


