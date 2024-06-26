% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/wlr.R
\name{wlr}
\alias{wlr}
\title{Weighted logrank test}
\usage{
wlr(data, weight, return_variance = FALSE)
}
\arguments{
\item{data}{Dataset that has been cut, generated by \code{\link[=sim_pw_surv]{sim_pw_surv()}}.}

\item{weight}{Weighting functions, such as \code{\link[=fh]{fh()}}, \code{\link[=mb]{mb()}}, and
\code{\link[=early_zero]{early_zero()}}.}

\item{return_variance}{A logical flag that, if \code{TRUE}, adds columns
estimated variance for weighted sum of observed minus expected;
see details; Default: \code{FALSE}.}
}
\value{
A list containing the test method (\code{method}),
parameters of this test method (\code{parameter}),
point estimate of the treatment effect (\code{estimate}),
standardized error of the treatment effect (\code{se}),
Z-score (\code{z}), p-values (\code{p_value}).
}
\description{
Weighted logrank test
}
\details{
\itemize{
\item \eqn{z} - Standardized normal Fleming-Harrington weighted logrank test.
\item \eqn{i} - Stratum index.
\item \eqn{d_i} - Number of distinct times at which events occurred in
stratum \eqn{i}.
\item \eqn{t_{ij}} - Ordered times at which events in stratum
\eqn{i}, \eqn{j = 1, 2, \ldots, d_i} were observed;
for each observation, \eqn{t_{ij}} represents the time post study entry.
\item \eqn{O_{ij.}} - Total number of events in stratum \eqn{i} that occurred
at time \eqn{t_{ij}}.
\item \eqn{O_{ije}} - Total number of events in stratum \eqn{i} in the
experimental treatment group that occurred at time \eqn{t_{ij}}.
\item \eqn{N_{ij.}} - Total number of study subjects in stratum \eqn{i}
who were followed for at least duration.
\item \eqn{E_{ije}} - Expected observations in experimental treatment group
given random selection of \eqn{O_{ij.}} from those in
stratum \eqn{i} at risk at time \eqn{t_{ij}}.
\item \eqn{V_{ije}} - Hypergeometric variance for \eqn{E_{ije}} as
produced in \code{Var} from \code{\link[=counting_process]{counting_process()}}.
\item \eqn{N_{ije}} - Total number of study subjects in
stratum \eqn{i} in the experimental treatment group
who were followed for at least duration \eqn{t_{ij}}.
\item \eqn{E_{ije}} - Expected observations in experimental group in
stratum \eqn{i} at time \eqn{t_{ij}} conditioning on the overall number
of events and at risk populations at that time and sampling at risk
observations without replacement:
\deqn{E_{ije} = O_{ij.} N_{ije}/N_{ij.}}
\item \eqn{S_{ij}} - Kaplan-Meier estimate of survival in combined
treatment groups immediately prior to time \eqn{t_{ij}}.
\item \eqn{\rho, \gamma} - Real parameters for Fleming-Harrington test.
\item \eqn{X_i} - Numerator for signed logrank test in stratum \eqn{i}
\deqn{X_i = \sum_{j=1}^{d_{i}} S_{ij}^\rho(1-S_{ij}^\gamma)(O_{ije}-E_{ije})}
\item \eqn{V_{ij}} - Variance used in denominator for Fleming-Harrington
weighted logrank tests
\deqn{V_i = \sum_{j=1}^{d_{i}} (S_{ij}^\rho(1-S_{ij}^\gamma))^2V_{ij})}
The stratified Fleming-Harrington weighted logrank test is then computed as:
\deqn{z = \sum_i X_i/\sqrt{\sum_i V_i}.}
}
}
\examples{
x <- sim_pw_surv(n = 200) |> cut_data_by_event(100)

# Example 1: WLR test with FH wights
x |> wlr(weight = fh(rho = 0, gamma = 1))
x |> wlr(weight = fh(rho = 0, gamma = 1), return_variance = TRUE)

# Example 2: WLR test with MB wights
x |> wlr(weight = mb(delay = 4, w_max = 2))

# Example 3: WLR test with early zero wights
x |> wlr(weight = early_zero(early_period = 4))
}
