#' Generate the input file of vertex for next psv2n computation
#'
#' @description We have two kinds of gene list named groupA and groupB,
#' we need integrate these files into one.
#' @param groupA a list of genes
#' @param groupB a list of target genes that you want to acquire \code{\link{psv2n}} score
#'
#' @return the result of two kinds of gene list named groupA and groupB
#' @export vertex_input
#'
#' @examples
#' vertex_sample
vertex_input <- function(groupA,groupB){
  #Take the intersection of groupA and groupB
  sharelist <- intersect(groupA,groupB)
  #generate share dataframe
  if (length(sharelist) == 0){
    cat("there are no intersection in groupA and groupB!","\n")
  }else{
  share <- as.data.frame(sharelist)
  share$aorb <- "2"
  names(share)<-c("symbol","aorb")
  }
  #generate groupa dataframe
  groupa <-as.data.frame(setdiff(groupA,sharelist))
  groupa$aorb <- "0"
  names(groupa) <- c("symbol","aorb")
  #generate groupb dataframe
  groupb <-as.data.frame(setdiff(groupB,sharelist))
  groupb$aorb <- "1"
  names(groupb) <- c("symbol","aorb")
  #combine dataframes
  if (length(sharelist) == 0){
    vertex_input<-rbind(groupa,groupb)
  }else{
  vertex_input<-rbind(groupa,groupb,share)
  }
  return(vertex_input)
}
