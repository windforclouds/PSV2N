#' crawling NCBI gene annotation data in batches
#'
#' @description
#' @param genelist a vector of gene SYMBOL
#'
#' @return get NCBI gene annotation data
#' @importFrom clusterProfiler bitr
#' @importFrom httr GET
#' @importFrom stringr str_split str_replace_all
#' @importFrom XML htmlParse getNodeSet xmlValue
#' @importFrom crayon green
#' @export annotation_gene
#' @author Ji Yang
#' @examples
#' sample<-head(annotation_gene(vertex_sample[,1]))
annotation_gene<-function(genelist){
  if (!requireNamespace("org.Hs.eg.db")) {
    BiocManager::install("org.Hs.eg.db")
  }
  #translate SYMBOL to ENTREZID
  genes<- bitr(genelist,
               fromType = "SYMBOL",
               toType   = "ENTREZID",
               OrgDb    = "org.Hs.eg.db")
  genes$NCBI_url <- paste("https://www.ncbi.nlm.nih.gov/gene/",genes$ENTREZ)
  genes$NCBI_url <- gsub(" ","",genes$NCBI_url)

  # Get the node content based on XPath：
  getNodesTxt <- function(html_txt1,xpath_p){
    els1 = getNodeSet(html_txt1, xpath_p)
    # Get the contents of Node and remove null characters:
    els1_txt <- sapply(els1,xmlValue)[!(sapply(els1,xmlValue)=="")]
    # remove \n：
    str_replace_all(els1_txt,"(\\n )+","")
  }

  # Processes the node format with character and length 0 assigned to NA:
  dealNodeTxt <- function(NodeTxt){
    ifelse(is.character(NodeTxt)==T && length(NodeTxt)!=0 , NodeTxt , NA)
  }

  # XPath precisely locates:
  for(i in 1:nrow(genes)){
    # Get the URL:
    doc <- GET(genes[i,"NCBI_url"])
    cat("Got the page successfully!\t")
    # Getting Web Content
    html_txt1 = htmlParse(doc, asText = TRUE)

    # Getting Full Name:
    genes[i,"FullName"] <- str_split(dealNodeTxt(getNodesTxt(html_txt1,'//*[@id="summaryDl"]/dd[preceding-sibling::dt[contains(text(),"Symbol") and position()=1 ] ]')),"provided")[[1]][1]
    cat("Written to the gene\t")
    # Getting HGNC ID:
    genes[i,"HGNC_ID"] <- str_replace_all(getNodesTxt(html_txt1,'//*[@id="summaryDl"]/dd[preceding-sibling::dt[text()="Primary source" and position()=1 ] ]')," |HGNC|:","")
    cat("Written to the HGNC_ID\t")
    # Getting Gene type:
    genes[i,"GeneType"] <- dealNodeTxt(getNodesTxt(html_txt1,'//*[@id="summaryDl"]/dd[preceding-sibling::dt[text()="Gene type" and position()=1 ] ]'))
    cat("Written to the GeneType\t")
    # Getting summary：
    genes[i,"Summary"] <- dealNodeTxt(getNodesTxt(html_txt1,'//*[@id="summaryDl"]/dd[preceding-sibling::dt[text()="Summary" and position()=1 ] ]'))
    cat("Written to the Summary\t")

    cat(green("finished NO ",i,"\n"))
  }
  return(genes)
}
