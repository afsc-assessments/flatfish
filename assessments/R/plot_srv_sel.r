plot_srv_sel <- function(theM,themod, title="Survey selectivity",bysex=TRUE,maxage = 20){

  M <- theM[[themod]]; names(M[]) #to see the names of what's in an object
  df <- rbind(data.frame(Age=1:maxage,sel=M$sel_srv_m,sex="Male"),data.frame(Age=1:maxage,sel=M$sel_srv_f,sex="Female"))
  ggplot(df,aes(x=Age,y=sel,color=sex)) + geom_line(size=2) + theme_few() + ylab("Selectivity") + ggtitle(paste0("Survey selectivity; (Model ",names(theM[themod]),")"))
  
#  n <- length(M)
#    mdf <- NULL
#    for (i in 1:n)
#    {
#        A   <- M[[i]]
#        #length(A$sel_srv_f)
#        #length(A$sel_srv_m)
#        mdf <- rbind(mdf, data.frame(Model= names(M)[i],sex="males",  selectivity=A$sel_srv_m,age=1:length(A$sel_srv_m)))
#        mdf <- rbind(mdf, data.frame(Model= names(M)[i],sex="females",selectivity=A$sel_srv_f,age=1:length(A$sel_srv_f)))
#    }
#    names(mdf) <- c("Model","sex","selectivity","age")

#if (bysex) {
##  ggplot(mdf,aes(x=age,y=Model,height = selectivity,fill=sex,color=sex,alpha=alpha)) + ggtitle(title) +
#  ggplot(mdf,aes(x=age,y=selectivity,height = selectivity,fill=sex,color=sex,alpha=alpha)) + ggtitle(title) +
#
#            geom_density_ridges(stat = "identity",scale=scale,alpha = alpha) + ylab("Year")+ .THEME #+ facet_wrap(~sex) 
#} else{
#  ggplot(mdf,aes(x=age,y=Model,height = selectivity,fill=Model,color=Model,alpha=.3)) + ggtitle(title) +
##  ggplot(mdf,aes(x=age,y=selectivity,height = selectivity,fill=Model,color=Model,alpha=.3)) + ggtitle(title) +
#            geom_density_ridges(stat = "identity",scale=scale,alpha = alpha) + ylab("Year")+ .THEME #+ facet_wrap(~sex) 
#}
}

