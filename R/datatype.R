#' @importfrom methods  setClass setGeneric setMethod setValidity
#'
setClass("vertex_input",
         slots = list(
           groupA = "character",
           groupB = "character")
        )
setClass("annotation_gene",
         slots = list(
           genelist = "data.frame")
         )
setClass("psv2n",
         slots = list(
           vertex = "data.frame",
           edge   = "data.frame")
        )
setClass("R/annotation_gene",
         slots = list(
           genelist = "data.frame")
        )
setClass("GOplot",
         slots = list(
           genelist       = "data.frame",
           display.number = "numeric",
           enrich.pvalue  = "numeric",
           CPCOLS         = "character",
           labelsize      = "numeric",
           label.title    = "character",
           xlab.title     = "character")
         )
setClass("KEGGplot",
         slots = list(
           genelist      = "data.frame",
           enrich.pvalue = "numeric",
           low.color     = "character",
           high.color    = "character",
           labs.x        = "character",
           labs.y        = "character",
           labs.title    = "character")
         )
