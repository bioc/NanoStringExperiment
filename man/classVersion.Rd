% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/NanoStringExperiment-accessors.R
\name{classVersion,NanoStringExperiment-method}
\alias{classVersion,NanoStringExperiment-method}
\title{Object class version accessor}
\usage{
\S4method{classVersion}{NanoStringExperiment}(object)
}
\arguments{
\item{object}{NanoStringExperiment object}
}
\value{
version of class used to generate object
}
\description{
Access version of NanoStringExperiment package used to generate object
}
\examples{
data(exampleNSEData)
classVersion(testExp)

}
