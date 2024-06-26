% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/randomize_by_fixed_block.R
\name{randomize_by_fixed_block}
\alias{randomize_by_fixed_block}
\title{Permuted fixed block randomization}
\usage{
randomize_by_fixed_block(n = 10, block = c(0, 0, 1, 1))
}
\arguments{
\item{n}{Sample size to be randomized.}

\item{block}{Vector of treatments to be included in each block.}
}
\value{
A treatment group sequence (vector) of length \code{n} with
treatments from \code{block} permuted within each block having
block size equal to the length of \code{block}.
}
\description{
Fixed block randomization. The \code{block} input should repeat each
treatment code the number of times it is to be included within each block.
The final block will be a partial block if \code{n} is not an exact multiple
of the block length.
}
\examples{
\dontshow{if (requireNamespace("dplyr", quietly = TRUE)) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
library(dplyr)

# Example 1
# 2:1 randomization with block size 3, treatments "A" and "B"
data.frame(x = 1:10) |> mutate(Treatment = randomize_by_fixed_block(block = c("A", "B", "B")))

# Example 2
# Stratified randomization
data.frame(stratum = c(rep("A", 10), rep("B", 10))) |>
  group_by(stratum) |>
  mutate(Treatment = randomize_by_fixed_block())
\dontshow{\}) # examplesIf}
}
