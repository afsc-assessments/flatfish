plot_srv_sel <- function(M, title="Survey selectivity",bysex=TRUE,alpha = 0.3,scale = 0.8){
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

if (bysex) {
#  ggplot(mdf,aes(x=age,y=Model,height = selectivity,fill=sex,color=sex,alpha=alpha)) + ggtitle(title) +
  ggplot(mdf,aes(x=age,y=selectivity,height = selectivity,fill=sex,color=sex,alpha=alpha)) + ggtitle(title) +

            geom_density_ridges(stat = "identity",scale=scale,alpha = alpha) + ylab("Year")+ .THEME #+ facet_wrap(~sex) 
} else{
  ggplot(mdf,aes(x=age,y=Model,height = selectivity,fill=Model,color=Model,alpha=.3)) + ggtitle(title) +
#  ggplot(mdf,aes(x=age,y=selectivity,height = selectivity,fill=Model,color=Model,alpha=.3)) + ggtitle(title) +
            geom_density_ridges(stat = "identity",scale=scale,alpha = alpha) + ylab("Year")+ .THEME #+ facet_wrap(~sex) 
}
}

