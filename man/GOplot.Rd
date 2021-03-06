% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/GOplot.R
\name{GOplot}
\alias{GOplot}
\title{plot GO plot with your interisting genelist}
\usage{
GOplot(
  genelist,
  display.number = 10,
  enrich.pvalue = 0.05,
  CPCOLS = c("#8DA1CB", "#FD8D62", "#66C3A5"),
  labelsize = 8,
  label.title = "The Most Enriched GO Terms",
  xlab.title = "GO Term"
)
}
\arguments{
\item{genelist}{a vector of gene SYMBOL}

\item{display.number}{number of display terms,respectively}

\item{enrich.pvalue}{default value 0.05}

\item{CPCOLS}{default c("#8DA1CB", "#FD8D62", "#66C3A5")}

\item{labelsize}{default value 10}

\item{label.title}{default "The Most Enriched GO Terms"}

\item{xlab.title}{default "GO Term"}
}
\value{
get the GO plot
}
\description{

}
\examples{
GOplot(vertex_sample[,1])
shorten the character GO_term
}
\author{
Ji Yang
}
