plot_catch <- function(M,themod,obspred = FALSE){
  M <- modlst[[themod]]; names(M[]) #to see the names of what's in an object
  
  if (obspred == TRUE) {
  df <- rbind(data.frame(Year = M$Yr,Catches=M$Obs_catch,type = "Observed"),data.frame(Year=M$Yr,Catches=M$Pred_catch,type = "Predicted"))
  ggplot(df,aes(x=Year,y=Catches,color=type)) + geom_line(size=2) + theme_few() + ylab("Catches (t)")
  } else {
    df <- data.frame(Year = M$Yr,Catches=M$Obs_catch,type = "Observed")
    ggplot(df,aes(x=Year,y=Catches)) + geom_line(size=2) + theme_few() + ylab("Catches (t)")
    
  }
} 
