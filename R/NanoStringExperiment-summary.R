setAs("NanoStringExperiment", "list", 
    function(from) {
        c(as.list(assays(from)), as.list(rowData(from)), 
            as.list(colData(from)), 
        list(signatures = signatures(from), design = design(from)))
    })

#' Coerce NanoStringExperiment object to list
#' 
#' Coercion method for NanoStringExperiment in list format
#' 
#' @param x NanoStringExperiment object
#' @param ... additional parameters for \code{list}
#' 
#' @return list version of NanoStringExperiment object
#' 
#' @examples
#' data(exampleNSEData)
#' as.list(testExp)
#' 
#' @export
setMethod("as.list", "NanoStringExperiment", 
    function(x, ...) as(x, "list"))

#' Evaluate expression on NanoStringExperiment list
#' 
#' Performs expression within NanoStringExperiment list
#' 
#' @param data NanoStringExperiment object
#' @param expr expression to evaluate with on
#' @param ... additional parameters for \code{with}
#' 
#' @return results of evaluation
#' 
#' @examples
#' data(exampleNSEData)
#' with(testExp, table(CodeClass))
#' 
#' @export
setMethod("with", "NanoStringExperiment", 
    function(data, expr, ...) eval(substitute(expr), 
    as(data, "list"), parent.frame()))

#' Summarize assay data
#' 
#' Get chosen summary statistics for a selected assay
#' 
#' @importFrom NanoStringNCTools signatureScoresApply
#' 
#' @param object NanoStringExperiment object
#' @param MARGIN integer to apply across row or column
#' @param GROUP colData header to group by
#' @param log2scale boolean indicating to use log2 values
#' @param elt assay data matrix name
#' @param signatureScores boolean to use signature scores
#' @param ... parameters to pass to summary
#' 
#' @return summary table of aggregated results
#' 
#' @examples
#' data(exampleNSEData)
#' summary(testExp)
#' 
#' @export
setMethod("summary", "NanoStringExperiment", 
    function(object, MARGIN = 2L, GROUP = NULL, log2scale = TRUE, 
        elt = "exprs", signatureScores = FALSE, ...) {
        stopifnot(MARGIN %in% c(1L, 2L))
        FUN <- function(x) {
            if (signatureScores) {
                applyFUN <- signatureScoresApply
            } else {
                applyFUN <- assayDataApply
            }
            stats <- t(applyFUN(x, MARGIN = MARGIN, FUN = .marginalSummary,
                log2scale = log2scale, elt = elt))
            if (log2scale) {
                stats[, "SizeFactor"] <- 
                    2^(stats[, "MeanLog2"] - mean(stats[, "MeanLog2"]))
            }
            stats
        }
        if (is.null(GROUP)) {
            FUN(object)
        }
        else {
            esBy(object, GROUP = GROUP, FUN = FUN, simplify = FALSE)
        }
    })

#' Summary statistics list
#' 
#' Lists of useful summary statistics
#' 
#' @noRd
.summaryMetadata <- list(
    log2 = data.frame(labelDescription = c("Geometric Mean", 
        "Geometric Mean Size Factor", "Mean Log2", "SD Log2"), 
        row.names = c("GeomMean", "SizeFactor", "MeanLog2", "SDLog2"), 
        stringsAsFactors = FALSE), 
    moments = data.frame(labelDescription = c("Mean", "Standard Deviation", 
        "Skewness", "Excess Kurtosis"), row.names = c("Mean", "SD", 
        "Skewness", "Kurtosis"), stringsAsFactors = FALSE), 
    quantiles = data.frame(labelDescription = c("Minimum", "First Quartile", 
        "Median", "Third Quartile", "Maximum"), row.names = c("Min", "Q1", 
        "Median", "Q3", "Max"), stringsAsFactors = FALSE))

#' Summary statistics list calculation
#' 
#' Create summary statistics from list
#' 
#' @importFrom BiocGenerics sd
#' @importFrom stats quantile
#' 
#' @noRd
.marginalSummary <- function(x, log2scale = TRUE) {
    if (anyNA(x)) 
        x <- x[!is.na(x)]
    quartiles <- quantile(x, probs = c(0, 0.25, 0.5, 0.75, 1))
    names(quartiles) <- rownames(.summaryMetadata[["quantiles"]])
    if (log2scale) {
        log2X <- log2t(x, thresh = 0.5)
        stats <- structure(c(geomMean(x), NA_real_, mean(log2X), 
            sd(log2X)), names = rownames(.summaryMetadata[["log2"]]))
    }
    else {
        stats <- structure(c(mean(x), sd(x), skewness(x), kurtosis(x)), 
            names = rownames(.summaryMetadata[["moments"]]))
    }
    c(stats, quartiles)
}

#' Calculate skewness
#' @noRd
skewness <- function(x, na.rm = FALSE) {
    if (anyNA(x)) {
        if (na.rm) 
            x <- x[!is.na(x)]
        else return(NA_real_)
    }
    n <- length(x)
    if (n < 3L) 
        return(NA_real_)
    x <- x - mean(x)
    ((sqrt(n * (n - 1L))/(n - 2L)) * (sum(x^3)/n))/((sum(x^2)/n)^1.5)
}

#' Calculate kurtosis
#' @noRd
kurtosis <- function(x, na.rm = FALSE) {
    if (anyNA(x)) {
        if (na.rm) 
            x <- x[!is.na(x)]
        else return(NA_real_)
    }
    n <- length(x)
    if (n < 4L) 
        return(NA_real_)
    x <- x - mean(x)
    ((n + 1L) * (n - 1L) * ((sum(x^4) / n) / (sum(x^2) / n)^2 - (3 * 
        (n - 1L)) / (n + 1L)))/((n - 2L) * (n - 3L))
}

#' Calculate geometric mean
#' @noRd
geomMean <- function(x, na.rm = FALSE) {
    if (anyNA(x)) {
        if (na.rm) 
            x <- x[!is.na(x)]
        else return(NA_real_)
    }
    if (min(x) < 0) {
        return(NA_real_)
    }
    exp(mean(logt(x, thresh = 0.5)))
}

#' Calculate log base 2
#' @noRd
log2t <- function(x, thresh = 0.5) {
    if (min(x, na.rm = TRUE) < thresh) {
        x[!is.na(x) & x >= 0 & x < thresh] <- thresh
    }
    log2(x)
}

#' Calculate log with chosen base
#' @noRd
logt <- function(x, thresh = 0.5) {
    if (min(x, na.rm = TRUE) < thresh) {
        x[!is.na(x) & x >= 0 & x < thresh] <- thresh
    }
    log(x)
}
