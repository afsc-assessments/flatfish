compareTime <- function(lstOuts,Slot,SD=F,Sum=NULL,startYear=NULL,legendPos="topright",...){

  lst     <- list(...)
  dat     <- lapply(lstOuts,function(x){return(x[[Slot]])})
  nms     <- names(dat); if(!is.null(Sum)){nms <- c(nms,paste(Sum[1],"+",Sum[2],sep=""))}

  nD      <- length(dat)
  if(is.null(startYear)){xrange <- range(unlist(lapply(dat,function(x){x[,1]})),na.rm=T)
  } else { xrange <- c(startYear,range(unlist(lapply(dat,function(x){x[,1]})),na.rm=T)[2])}
  yrange  <- range(pretty(range(unlist(lapply(dat,function(x){x[,4:5]})),na.rm=T)))
  
  dat     <- lapply(dat,function(x){idx <- which(x[,1] %in% xrange[1]:xrange[2]); return(x[idx,])})

  if(is.null(lst$ylim)==F) yrange <- lst$ylim
  if(is.null(lst$xlim)==F) xrange <- lst$xlim
  plot(x=dat[[1]][,1],y=dat[[1]][,2],type="l",lwd=2,xlab="Years",ylab=Slot,
       xlim=xrange,ylim=yrange)
  grid(); box()
  for(i in 1:nD)
    lines(x=dat[[i]][,1],y=dat[[i]][,2],col=i,lwd=2)
  if(!is.null(Sum)){
    idx1  <- which(nms==Sum[1])
    idx2  <- which(nms==Sum[2])
    datsum<- colSums(rbind(dat[[idx1]][,2],dat[[idx2]][,2]))
    lines(x=dat[[idx1]][,1],y=datsum,col=nD+1,lwd=2)
  }
  if(SD){
    for(i in 1:nD){
      iCol  <- col2rgb(i)
      iCol  <- rgb(iCol[1]/255,iCol[2]/255,iCol[3]/255,0.25)
      polygon(x=c(dat[[i]][,1],rev(dat[[i]][,1])),
              y=c(dat[[i]][,4],rev(dat[[i]][,5])),col=iCol,border=0)
    }
  }
  legend(legendPos,legend=c(nms),col=1:length(nms),lwd=2,lty=1,box.lty=0)
  box()

}

compareTimes <- function(lstOuts,Slots,SD=F,Sum=NULL,YrInd=NULL,Apply=mean,startYear=NULL,legendPos="topright",...){

  lst         <- list(...)
  nD          <- length(lstOuts)
  idxD        <- as.list(rep(numeric(1),nD))
  names(idxD) <- names(lstOuts)
  for(i in 1:nD)
    idxD[[i]] <- grep(Slots,names(lstOuts[[i]]))
  dat         <- as.list(rep(numeric(1),nD))
  names(dat)  <- names(lstOuts)
  for(i in 1:nD){
    for(j in idxD[[i]]){
      dat[[i]] <- cbind(dat[[i]],lstOuts[[i]][[j]])
    }
    dat[[i]] <- dat[[i]][,-1]
    if(length(idxD[[i]])>1) dat[[i]] <- apply(dat[[i]],1,Apply)
  }
  nms     <- names(dat); if(!is.null(Sum)){nms <- c(nms,paste(Sum[1],"+",Sum[2],sep=""))}

  if(is.null(YrInd)){
    xrange  <- range(unlist(lapply(dat,function(x){x[,1]})),na.rm=T)
    yrange  <- range(pretty(range(dat),na.rm=T))
  } else {
    xrange  <- range(YrInd,na.rm=T)
    yrange  <- range(pretty(range(dat),na.rm=T))
    for(i in 1:nD){
      if(length(YrInd) != length(dat[[i]])){
        dat[[i]] <- cbind(rev(rev(YrInd)[-1]),dat[[i]])
      } else {
          dat[[i]] <- cbind(YrInd,dat[[i]])
        }
    }
  }
  
  if(is.null(startYear)){xrange <- range(unlist(lapply(dat,function(x){x[,1]})),na.rm=T)
  } else { xrange <- c(startYear,range(unlist(lapply(dat,function(x){x[,1]})),na.rm=T)[2])}

  dat     <- lapply(dat,function(x){idx <- which(x[,1] %in% xrange[1]:xrange[2]); return(x[idx,])})

  if(is.null(lst$ylim)==F) yrange <- lst$ylim
  if(is.null(lst$xlim)==F) xrange <- lst$xlim

  plot(x=dat[[1]][,1],y=dat[[1]][,2],type="l",lwd=2,xlab="Years",ylab=Slots,
       xlim=xrange,ylim=yrange)
  grid(); box()
  for(i in 1:nD)
    lines(x=dat[[i]][,1],y=dat[[i]][,2],col=i,lwd=2)
  if(!is.null(Sum)){
    idx1  <- which(nms==Sum[1])
    idx2  <- which(nms==Sum[2])
    datsum<- colSums(rbind(dat[[idx1]][,2],dat[[idx2]][,2]))
    lines(x=dat[[idx1]][,1],y=datsum,col=nD+1,lwd=2)
  }
  if(SD){
    for(i in 1:nD){
      iCol  <- col2rgb(i)
      iCol  <- rgb(iCol[1]/255,iCol[2]/255,iCol[3]/255,0.25)
      polygon(x=c(dat[[i]][,1],rev(dat[[i]][,1])),
              y=c(dat[[i]][,4],rev(dat[[i]][,5])),col=iCol,border=0)
    }
  }
  legend(legendPos,legend=c(nms),col=1:length(nms),lwd=2,lty=1,box.lty=0)
  box()

}

compareMatrix <- function(lstOuts,Slot,SD=F,Sum=NULL,YrInd=NULL,Apply=mean,startYear=NULL,legendPos="topright",...){

  lst     <- list(...)

  dat     <- lapply(lstOuts,function(x){return(x[[Slot]])})
  nms     <- names(dat); if(!is.null(Sum)){nms <- c(nms,paste(Sum[1],"+",Sum[2],sep=""))}

  nD      <- length(dat)
  if(is.null(YrInd)){
    xrange  <- range(unlist(lapply(dat,function(x){x[,1]})),na.rm=T)
    yrange  <- range(pretty(range(unlist(lapply(dat,function(x){apply(x[,-1],1,Apply)})),na.rm=T)))
  } else {
    xrange  <- range(YrInd,na.rm=T)
    yrange  <- range(pretty(range(unlist(lapply(dat,function(x){apply(x,1,Apply)})),na.rm=T)))
    for(i in 1:nD){
      if(length(YrInd) != nrow(dat[[i]])){
        dat[[i]] <- cbind(rev(rev(YrInd)[-1]),dat[[i]])
      } else {
          dat[[i]] <- cbind(YrInd,dat[[i]])
        }
    }
  }
  for(i in 1:nD) dat[[i]] <- cbind(dat[[i]][,1],apply(dat[[i]][,-1],1,Apply))
  
  if(is.null(startYear)){xrange <- range(unlist(lapply(dat,function(x){x[,1]})),na.rm=T)
  } else { xrange <- c(startYear,range(unlist(lapply(dat,function(x){x[,1]})),na.rm=T)[2])}

  dat     <- lapply(dat,function(x){idx <- which(x[,1] %in% xrange[1]:xrange[2]); return(x[idx,])})

  if(is.null(lst$ylim)==F) yrange <- lst$ylim
  if(is.null(lst$xlim)==F) xrange <- lst$xlim
  plot(x=dat[[1]][,1],y=dat[[1]][,2],type="l",lwd=2,xlab="Years",ylab=Slot,
       xlim=xrange,ylim=yrange)
  grid(); box()
  for(i in 1:nD)
    lines(x=dat[[i]][,1],y=dat[[i]][,2],col=i,lwd=2)
  if(!is.null(Sum)){
    idx1  <- which(nms==Sum[1])
    idx2  <- which(nms==Sum[2])
    datsum<- colSums(rbind(dat[[idx1]][,2],dat[[idx2]][,2]))
    lines(x=dat[[idx1]][,1],y=datsum,col=nD+1,lwd=2)
  }
  if(SD){
    for(i in 1:nD){
      iCol  <- col2rgb(i)
      iCol  <- rgb(iCol[1]/255,iCol[2]/255,iCol[3]/255,0.25)
      polygon(x=c(dat[[i]][,1],rev(dat[[i]][,1])),
              y=c(dat[[i]][,4],rev(dat[[i]][,5])),col=iCol,border=0)
    }
  }
  legend(legendPos,legend=c(nms),col=1:length(nms),lwd=2,lty=1,box.lty=0)
  box()
}