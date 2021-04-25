#'  plot KEGG plot with your interisting genelist
#'
#' @param genelist a vector of gene SYMBOL
#' @param enrich.pvalue default value 0.05
#' @param low.color default parameter "green".must be one of colors:
#' "black","red","green","blue","cyan","magenta","yellow","gray"
#' @param high.color default parameter "red".must be one of colors:
#' "black","red","green","blue","cyan","magenta","yellow","gray"
#' @param labs.x default "Pvalue"
#' @param labs.y default "Pathway Name"
#' @param labs.title default "Pathway Enrichment"
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
  #check genelist before ploting
  if(!class(genelist) == "data.frame")
  {
    stop("param genelist input error!
         please input right file" )
  }
  #check enrich.pvalue before ploting
  if(!class(enrich.pvalue) == "numeric" || enrich.pvalue <= 0)
  {
    stop("param enrich.pvalue input error!
         please input right file" )
  }
  #check low.color and  high.color before ploting
  colors <- c("black","red","green","blue","cyan","magenta","yellow","gray")
  if(!low.color %in% colors && !high.color %in% colors)
  {
    stop("param low.color or high.color input error!
         they must be one of colors")
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
  #get KEGG information
  MSKEGG <- enrichKEGG(gene = gene$ENTREZID,
                       organism = "hsa",
                       pvalueCutoff = enrich.pvalue)
  SUMKEGG <- MSKEGG@result
  symbolKEGG <- setReadable(MSKEGG, OrgDb = org.Hs.eg.db, keyType="ENTREZID")  #translate gene ID to symbol
  symbolKEGG <- symbolKEGG@result
  symbolKEGG <- as.data.frame(symbolKEGG[symbolKEGG$pvalue <= enrich.pvalue,])
  #start plot
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
