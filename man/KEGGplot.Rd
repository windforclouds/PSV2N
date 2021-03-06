% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/KEGGplot.R
\name{KEGGplot}
\alias{KEGGplot}
\title{plot KEGG plot with your interisting genelist}
\usage{
KEGGplot(
  genelist,
  enrich.pvalue = 0.05,
  low.color = "green",
  high.color = "red",
  labs.x = "Pvalue",
  labs.y = "Pathway Name",
  titlesize.y = 8,
  labs.title = "Pathway Enrichment"
)
}
\arguments{
\item{genelist}{a vector of gene SYMBOL}

\item{enrich.pvalue}{default value 0.05}

\item{low.color}{default parameter "green".must be one of colors:
"black","red","green","blue","cyan","magenta","yellow","gray"}

\item{high.color}{default parameter "red".must be one of colors:
"black","red","green","blue","cyan","magenta","yellow","gray"}

\item{labs.x}{default "Pvalue"}

\item{labs.y}{default "Pathway Name"}

\item{titlesize.y}{default 8}

\item{labs.title}{default "Pathway Enrichment"}
}
\description{
plot KEGG plot with your interisting genelist
}
\examples{
KEGGplot(vertex_sample[,1])
}
