% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/NanoStringExperiment-subset.R
\name{controlSubset,NanoStringExperiment-method}
\alias{controlSubset,NanoStringExperiment-method}
\title{Subset to IsControl features}
\usage{
\S4method{controlSubset}{NanoStringExperiment}(object)
}
\arguments{
\item{object}{NanoStringExperiment object}
}
\value{
NanoStringExperiment object
}
\description{
Method to subset to features with CodeClass IsControl
}
\examples{
data(exampleNSEData)
controlSubset(testExp)

}
