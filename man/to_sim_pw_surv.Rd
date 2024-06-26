% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/to_sim_pw_surv.R
\name{to_sim_pw_surv}
\alias{to_sim_pw_surv}
\title{Convert enrollment and failure rates from \code{sim_fixed_n()} to
\code{sim_pw_surv()} format}
\usage{
to_sim_pw_surv(
  fail_rate = data.frame(stratum = "All", duration = c(3, 100), fail_rate = log(2)/c(9,
    18), hr = c(0.9, 0.6), dropout_rate = rep(0.001, 2))
)
}
\arguments{
\item{fail_rate}{Piecewise constant control group failure rates,
hazard ratio for experimental vs. control,
and dropout rates by stratum and time period.}
}
\value{
A list of two data frame components formatted for
\code{\link[=sim_pw_surv]{sim_pw_surv()}}: \code{fail_rate} and \code{dropout_rate}.
}
\description{
\code{to_sim_pw_surv()} converts failure rates and dropout rates entered in
the simpler format for \code{\link[=sim_fixed_n]{sim_fixed_n()}} to that used for \code{\link[=sim_pw_surv]{sim_pw_surv()}}.
The \code{fail_rate} argument for \code{\link[=sim_fixed_n]{sim_fixed_n()}} requires enrollment rates,
failure rates hazard ratios and dropout rates by stratum for a 2-arm trial,
\code{\link[=sim_pw_surv]{sim_pw_surv()}} is in a more flexible but less obvious but more flexible
format. Since \code{\link[=sim_fixed_n]{sim_fixed_n()}} automatically analyzes data and \code{\link[=sim_pw_surv]{sim_pw_surv()}}
just produces a simulation dataset, the latter provides additional options
to analyze or otherwise evaluate individual simulations in ways that
\code{\link[=sim_fixed_n]{sim_fixed_n()}} does not.
}
\examples{
# Example 1
# Convert standard input
to_sim_pw_surv()

# Stratified example
fail_rate <- data.frame(
  stratum = c(rep("Low", 3), rep("High", 3)),
  duration = rep(c(4, 10, 100), 2),
  fail_rate = c(
    .04, .1, .06,
    .08, .16, .12
  ),
  hr = c(
    1.5, .5, 2 / 3,
    2, 10 / 16, 10 / 12
  ),
  dropout_rate = .01
)

x <- to_sim_pw_surv(fail_rate)

# Do a single simulation with the above rates
# Enroll 300 patients in ~12 months at constant rate
sim <- sim_pw_surv(
  n = 300,
  stratum = data.frame(stratum = c("Low", "High"), p = c(.6, .4)),
  enroll_rate = data.frame(duration = 12, rate = 300 / 12),
  fail_rate = x$fail_rate,
  dropout_rate = x$dropout_rate
)

# Cut after 200 events and do a stratified logrank test
sim |>
  cut_data_by_event(200) |> # Cut data
  wlr(weight = fh(rho = 0, gamma = 0)) # Stratified logrank
}
