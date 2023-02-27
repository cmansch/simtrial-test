#  Copyright (c) 2022 Merck & Co., Inc., Rahway, NJ, USA and its affiliates. All rights reserved.
#
#  This file is part of the simtrial program.
#
#  simtrial is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#' @importFrom dplyr select mutate filter %>% arrange group_by
#' @importFrom tibble tibble
NULL

#' Process Survival Data into Counting Process Format
#'
#' Produces a tibble that is sorted by stratum and time.
#' Included in this is only the times at which one or more event occurs.
#' The output dataset contains Stratum, tte (time-to-event), at risk count and count of events at the specified tte
#' sorted by Stratum and tte.
#'
#' The function only considered two group situation.
#'
#' The tie is handled by the Breslow's Method.
#'
#' @param x a tibble with no missing values and contain variables
#' - `Stratum`: Stratum
#' - `Treatment`: Treatment group
#' - `tte`: Observed time
#' - `event`: Binary event indicator, `1` represents event, `0` represents censoring
#' @param txval value in the input `Treatment` column that indicates treatment group value.
#'
#' @return A `tibble` grouped by `Stratum` and sorted within strata by `tte`.
#' Remain rows with at least one event in the population, at least one subject
#' is at risk in both treatment group and control group.
#' Other variables in this represent the following within each stratum at
#' each time at which one or more events are observed:
#' - `events`: Total number of events
#' - `n_event_tol`: Total number of events at treatment group
#' - `n_risk_tol`: Number of subjects at risk
#' - `n_risk_trt`: Number of subjects at risk in treatment group
#' - `S`: Left-continuous Kaplan-Meier survival estimate
#' - `o_minus_e`: In treatment group, observed number of events minus expected
#' number of events. The expected number of events is estimated by assuming
#' no treatment effect with hypergeometric distribution with parameters total
#' number of events, total number of events at treatment group and number of
#' events at a time. (Same assumption of log-rank test under the null hypothesis)
#' - `var_o_minus_e`: variance of `o_minus_e` under the same assumption.
#'
#' @examples
#' library(dplyr)
#' library(tibble)
#'
#' # example 1
#' x <- tibble(Stratum = c(rep(1, 10),rep(2, 6)),
#'             Treatment = rep(c(1, 1, 0, 0), 4),
#'             tte = 1:16,
#'             event= rep(c(0, 1), 8))
#' counting_process(x, txval = 1)
#'
#' # example 2
#' x <- simPWSurv(n = 400)
#' y <- cutDataAtCount(x, 150) %>% counting_process(txval = "Experimental")
#' # weighted logrank test (Z-value and 1-sided p-value)
#' z <- sum(y$o_minus_e) / sqrt(sum(y$var_o_minus_e))
#' c(z, pnorm(z))
#'
#' @export
counting_process <- function(x, txval){

    unique_treatment <- unique(x$Treatment)

    if(length(unique_treatment) > 2){
      stop("counting_process: expected two groups!")
    }

    if(! txval %in% unique_treatment){
      stop("counting_process: txval is not a valid treatment group value!")
    }

    if(! all(unique(x$event) %in% c(0, 1) ) ){
      stop("counting_process: event indicator must be 0 (censoring) or 1 (event)!")
    }

    ans <- x %>%
      group_by(Stratum) %>%
      arrange(desc(tte)) %>%
      mutate(one = 1,
             n_risk_tol = cumsum(one),
             n_risk_trt = cumsum(Treatment == txval)) %>%
      # Handling ties using Breslow's method
      group_by(Stratum, mtte = desc(tte)) %>%
      dplyr::summarise(events = sum(event),
                       n_event_tol = sum((Treatment == txval) * event),
                       tte = first(tte),
                       n_risk_tol = max(n_risk_tol),
                       n_risk_trt = max(n_risk_trt)) %>%
      # Keep calculation for observed time with at least one event, at least one subject is
      # at risk in both treatment group and control group.
      filter(events > 0, n_risk_tol - n_risk_trt > 0, n_risk_trt > 0) %>%
      select(-mtte) %>%
      mutate(s = 1 - events / n_risk_tol) %>%
      arrange(Stratum, tte) %>%
      group_by(Stratum) %>%
      mutate( # left continuous Kaplan-Meier Estimator
             S = lag(cumprod(s), default = 1),
             # observed events minus Expected events in treatment group
             o_minus_e = n_event_tol - n_risk_trt / n_risk_tol * events,
             # variance of o_minus_e
             var_o_minus_e = (n_risk_tol - n_risk_trt) * n_risk_trt * events * (n_risk_tol - events) / n_risk_tol^2 / (n_risk_tol - 1)) %>%
      select(-s)

    return(ans)
}