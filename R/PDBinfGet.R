#' Get all available PDB_ID information of the genelist you input
#'
#' @description we acquire information of PDB_ID in virtue of the api of
#' EMBL protein(https://www.ebi.ac.uk/proteins/api/proteins/),you just need
#' to input a vector of genelist in your hand.
#' @param genelist a vector of gene(s)
#' @param id.fromType input id type(must be same as type of input genelist),we set 4 frequently-used types here,
#' which are "hgnc_symbol","entrezgene_id","ensembl_gene_id","uniprot_gn_id"
#' @param id.biomart biomart types when id needs to be translated,
#' see also \code{\link{getBM}}
#' @param id.dataset biomart dataset choose,
#' see also \code{\link{getBM}}
#' @param id.toType output id type
#'
#' @return properties of PDB_ID,such as method of Protein crystal analysis,
#' resolution,chains,structure length
#' @import stringr httr jsonlite tidyverse
#' biomaRt progress tidyr
#' @importFrom crayon blue underline
#' @export PDBinfGet
#' @usage
#' PDBinfGet(genelist,
#'           id.fromType = "hgnc_symbol",
#'           id.biomart  = ENSEMBL_MART_ENSEMBL,
#'           id.dataset  = "hsapiens_gene_ensembl",
#'           id.toType   = "uniprot_gn_id"
#' @author Ji Yang
#'
#' @examples
#' #input type is "hgnc_symbol":
#' PDBinfGet(genelist    = vertex_sample[1:5,1],
#'           id.fromType = "hgnc_symbol",
#'           id.biomart  = ENSEMBL_MART_ENSEMBL,
#'           id.dataset  = "hsapiens_gene_ensembl",
#'           id.toType   = "uniprot_gn_id")
#' #input type is "uniprot_gn_id":
#' PDBinfGet(genelist    = "P21580",
#'           id.fromType = "uniprot_gn_id",
#'           id.biomart  = ENSEMBL_MART_ENSEMBL,
#'           id.dataset  = "hsapiens_gene_ensembl",
#'           id.toType   = "uniprot_gn_id")
#'
PDBinfGet<-function(genelist,
                    id.fromType = "hgnc_symbol",
                    id.biomart  = ENSEMBL_MART_ENSEMBL,
                    id.dataset  = "hsapiens_gene_ensembl",
                    id.toType   = "uniprot_gn_id"){
  #genelist<-t(genelist)
  pdb_all<-data.frame()
  pdb_null<-character()
  num_null = 0
  num_pdb = 0
  i=0
  #choose which ways to continue,"uniprot_gn_id" or other idtypes
  if (id.fromType == "uniprot_gn_id"){
    cat("input type:uniprot_gn_id, doesn't have to be converted","\n")
    pb <- progress_bar$new(
          format = "completed percent[:bar] :percent time remaining: :eta",
          total  = length(genelist), clear = FALSE, width= 100)
    for (queryid in genelist) {
         i=i+1
         pb$tick()
         pdb_inf<-uniprot2pdb(queryid)
         if (length(pdb_inf) == 0){
            num_null<-num_null+1
            pdb_null[num_null]<-queryid
            next;
         } else{
            pdb_all<-rbind(pdb_all,pdb_inf)
            pdb_all<-cbind(queryid,pdb_all)
           }
    }
  } else{
       #set progress bar
       pb <- progress_bar$new(
             format = "completed percent[:bar] :percent time remaining: :eta",
             total = length(genelist), clear = FALSE, width= 100)
          for (queryid in genelist) {
              i=i+1
              pb$tick()
              unipid <- idTranslater(genelist = queryid,
                                     biomart  = id.biomart,
                                     dataset  = id.dataset,
                                     fromType = id.fromType,
                                     toType   = id.toType)
            for (id in unipid) {
              pdb_inf<-uniprot2pdb(id)
              if (length(pdb_inf) == 0){
                next;
              } else{
                pdb_inf<-cbind(queryid,pdb_inf)
                pdb_all<-rbind(pdb_all,pdb_inf)
                num_pdb<-num_pdb+1
                }
            }
          }
        if (length(pdb_all)==0 && length(pdb)==0) {
          num_null<-num_null+1
          pdb_null[num_null]<-queryid
        }
      }
    cat(blue(paste("you submitted",length(genelist),"queryid(s),",
             num_null,"queryid(s) have no PDB_ID now.","\n")))
    if (!num_null == 0){
      cat(paste("queryid(s) with no PDB_ID are:",underline(paste(pdb_null,collapse = ", "))))
    }
  return(pdb_all)
}

#this function is setted for translating Uniprot_ID to PDB_ID,
#and search for properties of PDB_ID
uniprot2pdb<-function(Uniprot_ID){
  url<-paste0("https://www.ebi.ac.uk/proteins/api/proteins/",Uniprot_ID)
  html<-GET(url)
  pdb_content<-httr::content(html,type = 'text',
                       encoding = "UTF-8")%>%
    fromJSON()
  #build colnames
  pdb_content<-pdb_content$dbReferences
  pdb_properties<-pdb_content[pdb_content$type=="PDB","properties"]
  if (length(rownames(pdb_properties)) == 0) {
    num_pdb <- data.frame()
    return(num_pdb)
  } else{
     pdb_inf<-cbind(pdb_content[pdb_content$type=="PDB","id"],
                    pdb_properties[,c("method","chains","resolution")])
    names(pdb_inf)<-c("PDB_ID","method","chains","resolution")
    pdb_inf<-separate(data = pdb_inf,
                      col  = chains,
                      into = c("chains", "positions"),
                      sep  = "=")
    #calculated length of structures
    pdb_inf<-separate(data = pdb_inf,
                      col  = positions,
                      into = c("from", "to"),
                      sep  = "-",
                      remove = FALSE)
    #combine pdb_inf with pdb_all
    pdb_length<-as.data.frame(lapply(pdb_inf[,c("from","to")],as.numeric))
    pdb_inf$length<-pdb_length$to-pdb_length$from+1
    pdb_inf<-cbind(Uniprot_ID,pdb_inf)
    return(pdb_inf)
  }
}

#this function is setted for translating id types
idTranslater<-function(genelist,
                       biomart  = id.biomart,
                       dataset  = id.dataset,
                       fromType = id.fromType,
                       toType   = id.toType){
#listMarts()
#list all biomart types
#         biomart                version
# 1 ENSEMBL_MART_ENSEMBL      Ensembl Genes 103
# 2   ENSEMBL_MART_MOUSE      Mouse strains 103
# 3     ENSEMBL_MART_SNP  Ensembl Variation 103
# 4 ENSEMBL_MART_FUNCGEN Ensembl Regulation 103

#mart = useMart('ensembl')
#istDatasets(mart)
#list all dataset types
ensembl = useMart("ENSEMBL_MART_ENSEMBL",dataset="hsapiens_gene_ensembl")
ensembl = useDataset("hsapiens_gene_ensembl",mart=ensembl)
listGeneSymol<- getBM(attributes = c("hgnc_symbol","entrezgene_id","ensembl_gene_id","uniprot_gn_id"),
                      filters    = "hgnc_symbol",
                      values     = genelist,
                      mart       = ensembl)
unipid<-unique(listGeneSymol[listGeneSymol$hgnc_symbol%in%genelist,toType])
return(unipid)
}
