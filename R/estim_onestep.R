utils::globalVariables(c("..eif_component_names"))

#' Estimating equation one-step (efficient) estimator
#'
#' @param data A \code{data.table} containing the observed data, with columns
#'  in the order specified by the NPSEM (Y, Z, A, W), with column names set
#'  appropriately based on the original input data. Such a structure is merely
#'  a convenience utility to passing data around to the various core estimation
#'  routines and is automatically generated as part of a call to the user-facing
#'  wrapper function \code{medshift}.
#' @param delta A \code{numeric} value indicating the degree of shift in the
#'  intervention to be used in defining the causal quantity of interest. In the
#'  case of binary interventions, this takes the form of an incremental
#'  propensity score shift, acting as a multiplier of the probability with which
#'  a given observational unit receives the intervention (EH Kennedy, 2018,
#'  JASA; <doi:10.1080/01621459.2017.1422737>).
#' @param g_lrnrs A \code{Stack} object, or other learner class (inheriting from
#'  \code{Lrnr_base}), containing a single or set of instantiated learners from
#'  the \code{sl3} package, to be used in fitting a model for the propensity
#'  score, i.e., g = P(A | W).
#' @param e_lrnrs A \code{Stack} object, or other learner class (inheriting
#'  from \code{Lrnr_base}), containing a single or set of instantiated learners
#'  from the \code{sl3} package, to be used in fitting a cleverly parameterized
#'  propensity score that includes the mediators, i.e., e = P(A | Z, W).
#' @param m_lrnrs A \code{Stack} object, or other learner class (inheriting
#'  from \code{Lrnr_base}), containing a single or set of instantiated learners
#'  from the \code{sl3} package, to be used in fitting the outcome regression,
#'  i.e., m(A, Z, W).
#' @param phi_lrnrs A \code{Stack} object, or other learner class
#'  (inheriting from \code{Lrnr_base}), containing a single or set of
#'  instantiated learners from the \code{sl3} package, to be used in fitting a
#'  reduced regression useful for computing the efficient one-step estimator,
#'  i.e., phi(W) = E[m(A = 1, Z, W) - m(A = 0, Z, W) | W).
#' @param w_names A \code{character} vector of the names of the columns that
#'  correspond to baseline covariates (W). The input for this argument is
#'  automatically generated by a call to the wrapper function \code{medshift}.
#' @param z_names A \code{character} vector of the names of the columns that
#'  correspond to mediators (Z). The input for this argument is automatically
#'  generated by a call to the wrapper function \code{medshift}.
#' @param cv_folds A \code{numeric} integer value specifying the number of folds
#'  to be created for cross-validation. Use of cross-validation / cross-fitting
#'  allows for entropy conditions on the AIPW estimator to be relaxed. Note: for
#'  compatibility with \code{origami::make_folds}, this value specified here
#'  must be greater than or equal to 2; the default is to create 10 folds.
#'
#' @importFrom stats var
#' @importFrom origami make_folds cross_validate folds_vfold
#
est_onestep <- function(data,
                        delta,
                        g_lrnrs,
                        e_lrnrs,
                        m_lrnrs,
                        phi_lrnrs,
                        w_names,
                        z_names,
                        cv_folds = 10) {
  # use origami to perform CV-SL, fitting/evaluating EIF components per fold
  eif_component_names <- c("Dy", "Da", "Dzw")

  # create folds for use with origami::cross_validate
  folds <- origami::make_folds(data,
    fold_fun = origami::folds_vfold,
    V = cv_folds
  )

  # perform the cv_eif procedure on a per-fold basis
  cv_eif_results <- origami::cross_validate(
    cv_fun = cv_eif,
    folds = folds,
    data = data,
    delta = delta,
    lrnr_stack_g = g_lrnrs,
    lrnr_stack_e = e_lrnrs,
    lrnr_stack_m = m_lrnrs,
    lrnr_stack_phi = phi_lrnrs,
    w_names = w_names,
    z_names = z_names,
    use_future = FALSE,
    .combine = FALSE
  )

  # combine results of EIF components for full EIF
  D_obs <- lapply(cv_eif_results[[1]], function(x) {
    D_obs_fold <- rowSums(x[, ..eif_component_names])
    return(D_obs_fold)
  })

  # get estimated observation-level values of EIF
  estim_eif <- do.call(c, D_obs)

  # compute one-step estimate of parameter and variance from EIF
  estim_onestep_param <- mean(estim_eif)
  estim_onestep_var <- stats::var(estim_eif) / length(estim_eif)

  # output
  estim_onestep_out <- list(
    theta = estim_onestep_param,
    var = estim_onestep_var,
    eif = (estim_eif - estim_onestep_param),
    type = "one-step efficient"
  )
  return(estim_onestep_out)
}
