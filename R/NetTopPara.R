#' calculate network topological parameters
#'
#' @param edge  the edge data of your network,such as edge_sample
#'
#' @return a dataframe with network topological parameters such as
#' degree,betweenness,closeness,eccentricity and eigenvector
#'
#' @importFrom igraph make_graph V E degree betweenness closeness
#' eccentricity eigen_centrality
#' @importFrom crayon blue
#' @export NetTopPara
#'
#' @examples
#' NetTopPara(edge_sample)
NetTopPara <- function(edge){
  #check edge file before calculating
  if(!class(edge) == "data.frame")
  {
    stop("param edge input error!
         please input right file" )
  }
  # build up netwoek g
  g <- make_graph(t(edge), directed = FALSE)
  # show information of your input network
  cat(blue("Network load successfully!","\n",
           "network scale:",length(V(g)),"vertexes",length(E(g)),"edges","\n"))
  # calculate degree
  g.degree <- degree(g)
  g.degree <- as.data.frame(g.degree)
  # calculate betweenness
  g.betweenness <- betweenness(g,normalized = T)
  g.betweenness <- as.data.frame(g.betweenness)
  # calculate closeness
  g.closeness <- closeness(g,normalized = T)
  g.closeness <- as.data.frame(g.closeness)
  # calculate eccentricity
  g.eccentricity <- eccentricity(g)
  g.eccentricity <- as.data.frame(g.eccentricity)
  # calculate eigenvector
  g.eigenvector <- (eigen_centrality(g, directed = FALSE))$vector
  g.eigenvector <- as.data.frame(g.eigenvector)
  #combine parameters
  combine_inf <- cbind(g.degree,g.betweenness,g.closeness,g.eccentricity,g.eigenvector)
  return(combine_inf)
}
