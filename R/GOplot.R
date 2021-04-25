#' plot GO plot with your interisting genelist
#'
#' @description
#'
#' @param genelist a vector of gene SYMBOL
#' @param display.number number of display terms,respectively
#' @param enrich.pvalue default value 0.05
#' @param CPCOLS default c("#8DA1CB", "#FD8D62", "#66C3A5")
#' @param labelsize default value 10
#' @param label.title default "The Most Enriched GO Terms"
#' @param xlab.title default "GO Term"
#'
#' @return get the GO plot
#' @importFrom clusterProfiler bitr enrichGO
#' @import ggplot2
#' @export GOplot
#' @author Ji Yang
#' @examples
#' GOplot(vertex_sample[,1])
GOplot <- function(genelist,
                   display.number = 10,
                   enrich.pvalue = 0.05,
                   CPCOLS = c("#8DA1CB", "#FD8D62", "#66C3A5"),
                   labelsize = 8,
                   label.title = "The Most Enriched GO Terms",
                   xlab.title = "GO Term") {
  #check display.number before ploting
  if(trunc(display.number)-display.number != 0 || display.number <= 0)
  {
    stop("param display.number input error!
         please input integers greater than 0")
  }
  #check enrich.pvalue before ploting
  if(!class(enrich.pvalue) == "numeric" || enrich.pvalue <= 0)
  {
    stop("param enrich.pvalue input error!
         please input right file" )
  }
  if(trunc(labelsize)-labelsize != 0 || labelsize <= 0)
  {
    stop("param labelsize input error!
         please input integers greater than 0")
  }
  #install "org.Hs.eg.db" packages
  if (!requireNamespace("org.Hs.eg.db")) {
    BiocManager::install("org.Hs.eg.db")
  }
  #translate SYMBOL to ENTREZID
  gene <- bitr(t(genelist),
               fromType = "SYMBOL",
               toType = "ENTREZID",
               OrgDb = "org.Hs.eg.db")
  #get GO information
  ego_MF <- enrichGO(OrgDb = "org.Hs.eg.db",
                     gene = gene$ENTREZID,
                     keyType = "ENTREZID",
                     pvalueCutoff = enrich.pvalue,
                     ont = "MF")
  ego_CC <- enrichGO(OrgDb = "org.Hs.eg.db",
                     gene = gene$ENTREZID,
                     keyType = "ENTREZID",
                     pvalueCutoff = enrich.pvalue,
                     ont = "CC")
  ego_BP <- enrichGO(OrgDb = "org.Hs.eg.db",
                     gene = gene$ENTREZID,
                     keyType = "ENTREZID",
                     pvalueCutoff = enrich.pvalue,
                     ont = "BP")
  print("GO Analysis Finished")

  ego_BP <- as.data.frame(ego_BP@result)
  ego_MF <- as.data.frame(ego_MF@result)
  ego_CC <- as.data.frame(ego_CC@result)
  #get BP information
  go_BP <- as.data.frame(ego_BP)[1:display.number, ]
  go_BP[, display.number] <- -log10(go_BP$pvalue)
  colnames(go_BP)[display.number] <- "-log(pvalue)"
  #get MF information
  go_MF <- as.data.frame(ego_MF)[1:display.number, ]
  go_MF[, display.number] <- -log10(go_MF$pvalue)
  colnames(go_MF)[display.number] <- "-log(pvalue)"
  #get CC information
  go_CC <- as.data.frame(ego_CC)[1:display.number, ]
  go_CC[, display.number] <- -log10(go_CC$pvalue)
  colnames(go_CC)[display.number] <- "-log(pvalue)"
  #general message
  go_enrich_df <- data.frame(ID = c(go_BP$ID, go_CC$ID, go_MF$ID),
                             Description = c(go_BP$Description, go_CC$Description, go_MF$Description),
                             "-log(pvalue)" = c(go_BP$`-log(pvalue)`, go_CC$`-log(pvalue)`, go_MF$`-log(pvalue)`),
                             GeneNumber = c(go_BP$Count, go_CC$Count, go_MF$Count),
                             type = factor(c(rep("biological process", display.number), rep("cellular component",
                                           display.number),rep("molecular function", display.number)),
                             levels = c("molecular function", "cellular component", "biological process")))

  go_enrich_df$number <- factor(rev(1:nrow(go_enrich_df)))
  print("go_enrich_df finished")

#' shorten the character GO_term
  shorten_names <- function(x, n_word = 4, n_char = 40) {
    if (length(strsplit(x, " ")[[1]]) > n_word || (nchar(x) > 40)) {
      if (nchar(x) > 40) x <- substr(x, 1, 40)
      x <- paste(paste(strsplit(x, " ")[[1]][1:min(length(strsplit(x, " ")[[1]]),
                 n_word)],collapse = " "),
                 "...",
                 sep = "")
      return(x)
    }
    else {
      return(x)
    }
  }

  labelSet <- as.character(go_enrich_df$Description)
  newlabelSet <- NULL
  for (i in seq(1, length(labelSet))) {
    newlabelSet <- c(newlabelSet, shorten_names(labelSet[i], n_word = 10, n_char = 190))
  }
  go_enrich_df$Description <- as.character(newlabelSet)
  names(newlabelSet) <- rev(1:nrow(go_enrich_df))
  #start plot
  p <- ggplot(data = go_enrich_df, aes(x = number, y = X.log.pvalue., fill = type)) +
             geom_bar(stat = "identity", width = 0.8) +
             coord_flip() +
             scale_fill_manual(values = CPCOLS) +
             theme_bw() +
             scale_x_discrete(labels = newlabelSet) +
             xlab(xlab.title) +
             theme(axis.text = element_text(face = "bold", color = "gray50")) +
             labs(title = label.title, y = expression(-log[10](pvalue))) +
             geom_text(aes(label = GeneNumber), label.size = labelsize, hjust = 0.5) +
             theme(plot.title = element_text(hjust = 0.5))
  return(p)
}
