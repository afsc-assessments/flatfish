plot_sel <- function(mod, title=NULL,alpha=0.3){
  mdf <- data.frame(Year=1975:2017,sex="males",mod$sel_fsh_m)
  mdf <- rbind(mdf,data.frame(Year=1975:2017,sex="females",mod$sel_fsh_f))
  names(mdf)[3:22] <- 1:20
  sdf <- (gather(mdf,age,selectivity,3:22) ) %>% filter(Year>1990) %>% mutate(age=as.numeric(age)) #+ arrange(age,Year)
  ggplot(sdf,aes(x=age,y=fct_rev(as.factor(Year)),height = selectivity,fill=sex,color=sex,alpha=alpha)) + ggtitle(title) +
            geom_density_ridges(stat = "identity",scale=1,alpha = alpha) + ylab("Year")+ .THEME #+ facet_grid(~seas) +
}
plot_srv_sel <- function(M, title="Survey selectivity",bysex=TRUE){
  n <- length(M)
    mdf <- NULL
    for (i in 1:n)
    {
        A   <- M[[i]]
        #length(A$sel_srv_f)
        #length(A$sel_srv_m)
        mdf <- rbind(mdf, data.frame(Model= names(M)[i],sex="males",  selectivity=A$sel_srv_m,age=1:length(A$sel_srv_m)))
        mdf <- rbind(mdf, data.frame(Model= names(M)[i],sex="females",selectivity=A$sel_srv_f,age=1:length(A$sel_srv_f)))
    }
    names(mdf) <- c("Model","sex","selectivity","age")

if (bysex)
{
  ggplot(mdf,aes(x=age,y=Model,height = selectivity,fill=sex,color=sex,alpha=.3)) + ggtitle(title) +
            geom_density_ridges(stat = "identity",scale=0.8,alpha = .3) + ylab("Year")+ .THEME #+ facet_wrap(~sex) 
}
else
  ggplot(mdf,aes(x=age,y=sex,height = selectivity,fill=Model,color=Model,alpha=.3)) + ggtitle(title) +
            geom_density_ridges(stat = "identity",scale=0.8,alpha = .3) + ylab("Year")+ .THEME #+ facet_wrap(~sex) 
}