#' @title MatchTable
#'
#' @description This function finds the lines in a table that matches strings
#'
#' @param Table Name of the table
#' @param Char1 First character string to matrix
#' @param Char2 Second character string to matrix
#' @param Char3 Third character string to matrix
#' @param Char4 Fourth character string to matrix
#' @param Char5 Fifth character string to matrix
#' @param Char6 Fifth character string to matrix
#'
#' @return vector of matching line indices
#' @export
#'
#' @examples
#' \dontrun{
#' }
#' 
MatchTable<-function(Table,Char1=NULL,Char2=NULL,Char3=NULL,Char4=NULL,Char5=NULL,Char6=NULL)
{
  ii <- rep(T,length(Table[,1]))
  if (!is.null(Char1)) ii <- ii & (Table[,1]==Char1)
  if (!is.null(Char2)) ii <- ii & (Table[,2]==Char2)
  if (!is.null(Char3)) ii <- ii & (Table[,3]==Char3)
  if (!is.null(Char4)) ii <- ii & (Table[,4]==Char4)
  if (!is.null(Char5)) ii <- ii & (Table[,5]==Char5)
  if (!is.null(Char6)) ii <- ii & (Table[,6]==Char6)
  ii <- seq(1:length(Table[,1]))[ii]
  if (length(ii) == 0) { cat("failed",Char1,Char2,Char3,Char4,Char5,Char6,"\n"); AAA }
  return(ii)
}

