#'  plot KEGG plot with your interisting genelist
#'
#' @param genelist a vector of gene SYMBOL
#' @param enrich.pvalue
#' @param high.color
#' @param labs.x
#' @param labs.y
#' @param labs.title
#'
#' @importFrom clusterProfiler bitr enrichKEGG setReadable
#' @import ggplot2
#' @export KEGGplot
#'
#' @examples
#' KEGGplot(vertex_sample[,1])
KEGGplot<-function(genelist,
                   enrich.pvalue = 0.05,
                   low.color     = "green",
                   high.color    = "red",
                   labs.x        = "Pvalue",
                   labs.y        = "Pathway Name",
                   labs.title    = "Pathway Enrichment"){

  if (!requireNamespace("org.Hs.eg.db")) {
    BiocManager::install("org.Hs.eg.db")
  }
  gene <- bitr(t(genelist),
               fromType = "SYMBOL",
               toType = "ENTREZID",
               OrgDb = "org.Hs.eg.db")

  MSKEGG <- enrichKEGG(gene = gene$ENTREZID,
                       organism = "hsa",
                       pvalueCutoff = enrich.pvalue)
  SUMKEGG <- MSKEGG@result
  symbolKEGG <- setReadable(MSKEGG, OrgDb = org.Hs.eg.db, keyType="ENTREZID")  #translate gene ID to symbol
  symbolKEGG <- symbolKEGG@result
  symbolKEGG <- as.data.frame(symbolKEGG[symbolKEGG$pvalue <= enrich.pvalue,])

  p <-ggplot(symbolKEGG,aes(x=pvalue,y=reorder(Description,rev(pvalue))))+
    geom_point(aes(size=Count,color=-1*log10(pvalue)))+
    scale_color_gradient(low=low.color,high =high.color)+
    labs(color=expression(-log[10](pvalue)),size="Count",
         x=labs.x,
         y=labs.y,title=labs.title)+
    theme_bw()+
    theme(plot.title = element_text(hjust = 0.5))

  return(p)
}
