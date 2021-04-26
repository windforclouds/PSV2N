#' @importfrom methods  setClass setGeneric setMethod setValidity
#'
setClass("vertex_input",
         slots = list(
           groupA = "character",
           groupB = "character")
        )
setClass("annotation_gene",
         slots = list(
           genelist = "character")
         )
setClass("psv2n",
         slots = list(
           vertex = "character",
           edge   = "data.frame")
        )
setClass("R/annotation_gene",
         slots = list(
           genelist = "character")
        )
setClass("GOplot",
         slots = list(
           genelist       = "character",
           display.number = "numeric",
           enrich.pvalue  = "numeric",
           CPCOLS         = "character",
           labelsize      = "numeric",
           label.title    = "character",
           xlab.title     = "character")
         )
setClass("KEGGplot",
         slots = list(
           genelist      = "character",
           enrich.pvalue = "numeric",
           low.color     = "character",
           high.color    = "character",
           labs.x        = "character",
           labs.y        = "character",
           titlesize.y   = "numeric",
           labs.title    = "character")
         )
setClass("NetTopPara",
         slots = list(
           edge = "data.frame")
         )
setClass("PDBinfGet",
         slots = list(
           id.fromType = "character",
           id.dataset  = "character",
           id.toType   = "character")
         )
