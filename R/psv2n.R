#' calculate score by PS-V2N methods
#'
#' @description 1) ready for one dataframe(such as vertex_sample, first
#' column is gene name, and the second colname is the type
#' identification code 0, 1, and 2 (0 means groupA, 1 maens groupB, 2 means share genes);
#' 2) Get your edge dataframe ready(such as edge_sample)
#' @param vertex the vertex data of your network,such as vertex_sample,
#' see also \code{\link{vertex_input}}
#' @param edge the edge data of your network,such as edge_sample
#'
#' @return the PS-V2N score of your group A
#' @importFrom igraph make_graph vertices V E degree shortest.paths diameter neighbors
#' @importFrom crayon blue
#' @export psv2n
#' @author Ji Yang
#' @examples
#' psv2n(vertex_sample, edge_sample)
psv2n <- function(vertex, edge) {
  #check vertex file before calculating
  if(!class(vetex) == "data.frame")
  {
    stop("param vetex input error!
         please input right file" )
  }
  #check edge file before calculating
  if(!class(edge) == "data.frame")
  {
    stop("param edge input error!
         please input right file" )
  }
  #devide groups to facilitate calculation
  groupA <- as.vector(subset(vertex, aorb == 0 | aorb == 2)[, 1])
  groupB <- as.vector(subset(vertex, aorb == 1 | aorb == 2)[, 1])
  group_share <- as.vector(subset(vertex, aorb == 2)[, 1])
  groupA_noshare <- as.vector(subset(vertex, aorb == 0)[, 1])
  # build up graph by your edge informations of network
  net_all <- make_graph(t(edge), directed = FALSE)
  cat(blue("Network load successfully!","\n",
  "network scale:",length(V(net_all)),"vertexes",length(E(net_all)),"edges","\n"))

  # calulate share gene's self value, namely use ave_closenessB to measure
  net_groupB <- net_all - vertices(groupA_noshare)
  net_groupB <- net_groupB - V(net_groupB)[degree(net_groupB) == 0]
  SPgroupB <- as.data.frame(shortest.paths(net_groupB))
  closenessB <- data.frame(symbol = c(NA), closeness = c(NA))
  i <- 0
  for (a in rownames(SPgroupB)) {
    i <- i + 1
    closenessB[i, 1] <- a
    CBi <- SPgroupB[a, ]
    for (m in colnames(CBi)) {
      CBi[2, m] <- CBi[1, m]
    }
    closenessB[i, 2] <- 1 / sum(CBi[2, ][CBi[2, ] != Inf])
  }
  ave_closenessB <- mean(closenessB$closeness)

  # calculate by PS-V2N methods
  groupA_avesp <- data.frame(symbol = c(NA), num_V_newnet = c(NA), sum_SPL = c(NA), sum_Inf = c(NA), num_neighbor_in_B = c(NA), PSV2N = c(NA))
  i <- 0
  for (node in groupA) {
    i <- i + 1
    groupA_avesp[i, 1] <- node
    if (node %in% group_share) {
      # rebuild net_minus
      net_minus <- net_all - vertices(groupA_noshare)
    } else {
      net_minus <- net_all - vertices(setdiff(groupA_noshare, node))
    }
    # remove outliers of net_minus
    net_final <- net_minus - V(net_minus)[degree(net_minus) == 0]

    #生成net_minus网络
    # assign(paste("MS",node,sep = "_"),net_minus)
    # we get net_minus's dataframes of shortestpaths
    SPMS <- assign(paste("SPMS", node, sep = "_"), as.data.frame(shortest.paths(net_minus)))
    if (node %in% rownames(SPMS)) {
      spfinal <- SPMS[node, ]
      # calculate net_minus's average degree
      ave_degree <- sum(degree(net_minus)) / length(spfinal)
      if (node %in% group_share) {
        for (m in colnames(spfinal)) {
          if (m == node) {
            spfinal[2, node] <- (1 / ave_closenessB)
          } else {
            spfinal[2, m] <- (1 / spfinal[1, m])
          }
        }
      } else {
        for (m in colnames(spfinal)) {
          spfinal[2, m] <- (1 / spfinal[1, m])
        }
      }
      spsum <- sum(spfinal[2, ][spfinal[2, ] != Inf])
      #build groupA_avesp dataframe
      groupA_avesp[i, 2] <- length(spfinal)
      groupA_avesp[i, 3] <- spsum
      groupA_avesp[i, 4] <- sum(spfinal[1, ] == Inf)
      groupA_avesp[i, 5] <- length(intersect(neighbors(net_minus, node)$name, groupB))
      if (node %in% group_share) {
        # nonshare genes
        groupA_avesp[i, 6] <- spsum / (nrow(SPMS)) + (1 / (sum(spfinal[1, ] == Inf) + 1)) * (1 / diameter(net_minus)) / nrow(SPMS)
      } else {
        # share genes
        groupA_avesp[i, 6] <- spsum / (nrow(SPMS) - 1) + (1 / (sum(spfinal[1, ] == Inf) + 1)) * (1 / diameter(net_minus)) / (nrow(SPMS) - 1)
      }
      rm(spsum, SPMS)
    } else {
      groupA_avesp[i, 6] <- Inf
    }
  }
  cat(underline("Calculate completed!!!","\n"))

  # the results is ordered by PS-V2N
  groupA_avesp <- groupA_avesp[order(-groupA_avesp$PSV2N), ]
  order_by_PSV2N <- c(1:i)
  groupA_avesp <- cbind(order_by_PSV2N, groupA_avesp)
  return(groupA_avesp)
}
