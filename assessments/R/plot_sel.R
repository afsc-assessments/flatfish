plot_sel <- function(mod, title=NULL,alpha=0.3,styr=1991,endyr=2020,bysex=TRUE,sexoverlay=TRUE){
#mod=M[[1]]; title="stuff";alpha=0.3;styr=1991;endyr=2020;bysex=TRUE;sexoverlay=TRUE
names(mod)
  mdf <- data.frame(Year=mod$Yr,sex="males",mod$sel_fsh_m)
  mdf <- rbind(mdf,data.frame(Year=mod$Yr,sex="females",mod$sel_fsh_f))
  names(mdf)[3:22] <- 1:20
  sdf <- (gather(mdf,age,selectivity,3:22) ) %>% filter(Year>=styr,Year<=endyr) %>% mutate(age=as.numeric(age)) #+ arrange(age,Year)
if (bysex)
{
if (sexoverlay){
  ggplot(sdf,aes(x=age,y=fct_rev(as.factor(Year)),height = selectivity,fill=sex,color=sex,alpha=alpha)) + ggtitle(title) +
            geom_density_ridges(stat = "identity",scale=1,alpha = alpha) + ylab("Year")+ .THEME #+ facet_grid(~seas) +
 } else {
  ggplot(sdf,aes(x=age,y=fct_rev(as.factor(Year)),height = selectivity,fill=sex,color=sex,alpha=alpha)) + ggtitle(title) +
            geom_density_ridges(stat = "identity",scale=1,alpha = alpha) + ylab("Year")+ .THEME #+ facet_grid(~seas) +
}
#else {
  #ggplot(sdf,aes(x=age,y=fct_rev(as.factor(Year)),height = selectivity,fill=sex,color=sex,alpha=alpha)) + ggtitle(title) +
            #geom_density_ridges(stat = "identity",scale=1,alpha = alpha) + ylab("Year")+ .THEME #+ facet_grid(~seas) +
#}
}
}

#mdf <- data.frame(Year=YFS2$Yr,Sex="males",YFS2$sel_fsh_m)
#mdf <- rbind(mdf,data.frame(Year=A$Yr,Sex="females",YFS2$sel_fsh_f))
#names(mdf)[3:22] <- 1:20
#sdf <- (gather(mdf,Age,selectivity,3:22) ) %>% filter(Year>=min(YFS2$Yr),Year<=max(YFS2$Yr)) %>% mutate(Age=as.numeric(Age)) #+ arrange(age,Year)

#ggplot(sdf,aes(x=Age,y=fct_rev(as.factor(Year)),height = selectivity,fill=Sex,color=Sex,alpha=0.3)) +
 #geom_density_ridges(stat = "identity",scale=1,alpha = 0.3) + ylab("Year")+ theme(axis.text.y = element_text(angle = 0, hjust = 1, size=5))
