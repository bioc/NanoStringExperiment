% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/NanoStringExperiment-subset.R
\name{endogenousSubset}
\alias{endogenousSubset}
\title{Subset to endogenous features}
\usage{
endogenousSubset(object)
}
\arguments{
\item{object}{NanoStringExperiment object}
}
\value{
NanoStringExperiment object
}
\description{
Method to subset to features with CodeClass Endogenous
}
\examples{
data(exampleNSEData)
endogenousSubset(testExp)

}
