################################################################################
# NLSY79 manuscript analysis script
# Project: Financial Preparedness, Reproductive Education, and Completed Fertility
# Purpose: Rebuild analytic files, estimate manuscript models, and export exact
#          CSV/LaTeX tables for manuscript audit and revision.
#
# Expected local input files, usually under "NLS79 DATA/":
#   - NLS79-FERTILITY.csv
#   - NLS79_Data_Raw.csv
#   - nls79_emergency_fe_result.csv  optional exact precomputed FE result
#
# The public CSVs retain original NLSY79 RNUM headers. This script maps only the
# variables used by the manuscript so the repository does not depend on the raw
# NLS Investigator loader files.
################################################################################

rm(list = ls())
options(stringsAsFactors = FALSE)

# -----------------------------
# 0. User paths
# -----------------------------
DATA_DIR <- Sys.getenv("NLS79_DATA_DIR", unset = "NLS79 DATA")
OUTPUT_DIR <- Sys.getenv("NLS79_OUTPUT_DIR", unset = "tables")

FERTILITY_FILE_CANDIDATES <- c("NLS79-FERTILITY.csv", "Capstone_data2.csv")
FINANCE_FILE_CANDIDATES   <- c("NLS79_Data_Raw.csv", "default324.csv")
FE_RESULT_FILE_CANDIDATES <- c("nls79_emergency_fe_result.csv")

SEARCH_DIRS <- unique(c(
  DATA_DIR,
  ".",
  "NLS79 DATA",
  "NLS79_DATA",
  "data",
  "Data",
  file.path("..", "NLS79 DATA"),
  file.path("..", "NLS79_DATA"),
  file.path("..", "data"),
  file.path("..", "Data")
))

if (!dir.exists(OUTPUT_DIR)) dir.create(OUTPUT_DIR, recursive = TRUE)

# -----------------------------
# 1. Packages
# -----------------------------
required_packages <- c("dplyr", "tidyr", "tibble", "purrr", "sandwich", "lmtest", "MASS", "survival", "knitr")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) install.packages(missing_packages)
invisible(lapply(required_packages, library, character.only = TRUE))
has_fixest <- requireNamespace("fixest", quietly = TRUE)

# -----------------------------
# 2. Helpers
# -----------------------------
locate_file <- function(candidates) {
  for (directory in SEARCH_DIRS) {
    for (candidate in candidates) {
      path <- file.path(directory, candidate)
      if (file.exists(path)) return(path)
    }
  }
  stop("Could not locate any of: ", paste(candidates, collapse = ", "), call. = FALSE)
}

as_num <- function(x) suppressWarnings(as.numeric(as.character(x)))

clean_missing <- function(data) {
  data[] <- lapply(data, function(x) {
    y <- as_num(x)
    y[y %in% c(-1, -2, -3, -4, -5)] <- NA_real_
    y
  })
  data
}

latest_nonmissing <- function(data, vars) {
  vars <- vars[vars %in% names(data)]
  if (length(vars) == 0) return(rep(NA_real_, nrow(data)))
  mat <- as.matrix(data[, vars, drop = FALSE])
  apply(mat, 1, function(row) {
    ok <- which(!is.na(row))
    if (length(ok) == 0) NA_real_ else row[max(ok)]
  })
}

row_any_yes <- function(data, vars) {
  vars <- vars[vars %in% names(data)]
  if (length(vars) == 0) return(rep(NA_real_, nrow(data)))
  mat <- as.matrix(data[, vars, drop = FALSE])
  apply(mat, 1, function(row) {
    if (all(is.na(row))) return(NA_real_)
    as.numeric(any(row == 1, na.rm = TRUE))
  })
}

format_num <- function(x, digits = 3) {
  ifelse(is.na(x), NA_character_, formatC(x, format = "f", digits = digits))
}

format_p <- function(p) {
  ifelse(is.na(p), NA_character_, ifelse(p < .001, "<.001", sub("^0", "", formatC(p, format = "f", digits = 3))))
}

model_n <- function(model) stats::nobs(model)

robust_row_lm_glm <- function(model, term, model_name, outcome, predictor, vcov_mat, exponentiate = FALSE) {
  beta <- stats::coef(model)[term]
  se <- sqrt(diag(vcov_mat))[term]
  stat <- beta / se
  p <- 2 * stats::pnorm(abs(stat), lower.tail = FALSE)
  est <- if (exponentiate) exp(beta) else beta
  ci_low <- if (exponentiate) exp(beta - 1.96 * se) else beta - 1.96 * se
  ci_high <- if (exponentiate) exp(beta + 1.96 * se) else beta + 1.96 * se
  tibble::tibble(
    Outcome = outcome,
    Predictor = predictor,
    Model = model_name,
    Metric = ifelse(exponentiate, "IRR", "Coefficient"),
    Estimate = format_num(est, 3),
    SE = format_num(se, 3),
    Statistic = paste0("z = ", format_num(stat, 2)),
    p = format_p(p),
    CI_95 = paste0("[", format_num(ci_low, 3), ", ", format_num(ci_high, 3), "]")
  )
}

robust_row_cox <- function(model, term, outcome, predictor) {
  s <- summary(model)
  ct <- as.data.frame(s$coefficients)
  beta <- ct[term, "coef"]
  se_col <- if ("robust se" %in% names(ct)) "robust se" else "se(coef)"
  se <- ct[term, se_col]
  z <- beta / se
  p <- 2 * stats::pnorm(abs(z), lower.tail = FALSE)
  ci_low <- exp(beta - 1.96 * se)
  ci_high <- exp(beta + 1.96 * se)
  tibble::tibble(
    Outcome = outcome,
    Predictor = predictor,
    Model = "Cox PH",
    Metric = "HR",
    Estimate = format_num(exp(beta), 3),
    SE = format_num(se, 3),
    Statistic = paste0("z = ", format_num(z, 2)),
    p = format_p(p),
    CI_95 = paste0("[", format_num(ci_low, 3), ", ", format_num(ci_high, 3), "]")
  )
}

write_latex <- function(x, path, caption) {
  out <- capture.output(knitr::kable(x, format = "latex", booktabs = TRUE, caption = caption))
  writeLines(out, path)
}

# -----------------------------
# 3. Read public CSV extracts
# -----------------------------
fertility_path <- locate_file(FERTILITY_FILE_CANDIDATES)
finance_path <- locate_file(FINANCE_FILE_CANDIDATES)
fe_result_path <- tryCatch(locate_file(FE_RESULT_FILE_CANDIDATES), error = function(e) NA_character_)
use_precomputed_fe <- !is.na(fe_result_path)

fert_raw <- read.csv(fertility_path, check.names = FALSE)
fin_raw  <- read.csv(finance_path, check.names = FALSE)
fert_raw <- clean_missing(fert_raw)
fin_raw  <- clean_missing(fin_raw)

# -----------------------------
# 4. Variable maps used in the manuscript
# -----------------------------
marital_vars <- c(
  "R0217501" = 1979, "R0405601" = 1980, "R0618601" = 1981, "R0898401" = 1982,
  "R1144901" = 1983, "R1520101" = 1984, "R1890801" = 1985, "R2257901" = 1986,
  "R2445301" = 1987, "R2871000" = 1988, "R3074700" = 1989, "R3401400" = 1990,
  "R3656800" = 1991, "R4007300" = 1992, "R4418400" = 1993, "R5081400" = 1994,
  "R5166700" = 1996, "R6479300" = 1998, "R7007000" = 2000, "R7704300" = 2002,
  "R8496700" = 2004, "T0988500" = 2006, "T2210500" = 2008, "T3108400" = 2010,
  "T4112900" = 2012, "T5023300" = 2014, "T5771200" = 2016, "T8219300" = 2018,
  "T8788500" = 2020, "T9300300" = 2022
)

emergency_vars <- c("T4100000" = 2012, "T5005400" = 2014, "T5739900" = 2016, "T8187000" = 2018, "T9260200" = 2022)

finlit_items <- list(
  `2012` = c(q4 = "T4100300", q5 = "T4100400", q6 = "T4100500", q7 = "T4100600", q8 = "T4100700"),
  `2014` = c(q4 = "T5005700", q5 = "T5005800", q6 = "T5005900", q7 = "T5006000", q8 = "T5006100"),
  `2016` = c(q4 = "T5740200", q5 = "T5740300", q6 = "T5740400", q7 = "T5740500", q8 = "T5740600"),
  `2018` = c(q4 = "T8187300", q5 = "T8187400", q6 = "T8187500", q7 = "T8187600", q8 = "T8187700")
)

numkid_vars <- c(
  "R0898837", "R1146829", "R1522036", "R1892736", "R2259836", "R2448036", "R2877500",
  "R3407600", "R3659046", "R4009446", "R4444600", "R5087400", "R5172700", "R6486300",
  "R7014100", "R7711700", "R8504200", "R9908000", "T0995900", "T2217700", "T3115700",
  "T4120200", "T5031400", "T5779600", "T8226700", "T8796000", "T9307800"
)

education_vars <- c(
  "R0216701", "R0406401", "R0618901", "R0898201", "R1145001", "R1520201", "R1890901",
  "R2258001", "R2445401", "R2871101", "R3074801", "R3401501", "R3656901", "R4007401",
  "R4418501", "R5103900", "R5166901", "R6479600", "R7007300", "R7704600", "R8497000",
  "T0988800", "T2210700", "T3108600", "T4113100", "T5023500", "T5771400", "T9900000"
)

male_bc_vars <- c("R1314200", "R1314400", "R1314500", "R1314600")
female_bc_vars <- c("R1381800", "R1382000", "R1382100", "R1382200")

# -----------------------------
# 5. Build respondent-wave marital/financial panel
# -----------------------------
make_long <- function(data, vars, value_name) {
  available <- intersect(names(vars), names(data))
  purrr::map_dfr(available, function(v) {
    tibble::tibble(
      id = as_num(data[["R0000100"]]),
      year = unname(vars[[v]]),
      value = as_num(data[[v]])
    )
  }) |>
    dplyr::rename(!!value_name := value)
}

marital_panel <- make_long(fin_raw, marital_vars, "marstat") |>
  dplyr::left_join(make_long(fin_raw, emergency_vars, "emergency_savings"), by = c("id", "year")) |>
  dplyr::mutate(
    married = ifelse(is.na(marstat), NA_real_, as.numeric(marstat %in% c(1, 5))),
    emergency_savings = ifelse(is.na(emergency_savings), NA_real_, as.numeric(emergency_savings == 1))
  ) |>
  dplyr::filter(!is.na(married), !is.na(emergency_savings))

objective_finlit_score <- function(data, year) {
  vars <- finlit_items[[as.character(year)]]
  correct <- tibble::tibble(
    q4 = if (vars["q4"] %in% names(data)) as.numeric(as_num(data[[vars["q4"]]]) == 0) else NA_real_,
    q5 = if (vars["q5"] %in% names(data)) as.numeric(as_num(data[[vars["q5"]]]) == 1) else NA_real_,
    q6 = if (vars["q6"] %in% names(data)) as.numeric(as_num(data[[vars["q6"]]]) == 3) else NA_real_,
    q7 = if (vars["q7"] %in% names(data)) as.numeric(as_num(data[[vars["q7"]]]) == 2) else NA_real_,
    q8 = if (vars["q8"] %in% names(data)) as.numeric(as_num(data[[vars["q8"]]]) == 1) else NA_real_
  )
  observed <- rowSums(!is.na(correct))
  score <- rowSums(correct, na.rm = TRUE)
  ifelse(observed == 0, NA_real_, score)
}

finlit_panel <- purrr::map_dfr(c(2012, 2014, 2016, 2018), function(yr) {
  tibble::tibble(
    id = as_num(fin_raw[["R0000100"]]),
    year = yr,
    fin_lit_score = objective_finlit_score(fin_raw, yr)
  )
}) |>
  dplyr::filter(!is.na(fin_lit_score))

finlit_person <- finlit_panel |>
  dplyr::group_by(id) |>
  dplyr::summarise(fin_lit_score_mean = mean(fin_lit_score, na.rm = TRUE), fin_lit_waves = dplyr::n(), .groups = "drop")

emergency_person <- marital_panel |>
  dplyr::group_by(id) |>
  dplyr::summarise(ever_emergency_savings = as.numeric(any(emergency_savings == 1, na.rm = TRUE)), emergency_savings_waves = dplyr::n(), .groups = "drop")

# -----------------------------
# 6. Build respondent-level fertility file
# -----------------------------
fert_person <- fert_raw |>
  dplyr::transmute(
    id = as_num(.data[["R0000100"]]),
    sex = as_num(.data[["R0214800"]]),
    race_ethnicity = as_num(.data[["R0214700"]]),
    education = latest_nonmissing(fert_raw, education_vars),
    completed_fertility = latest_nonmissing(fert_raw, numkid_vars),
    birth_control_education_male = row_any_yes(fert_raw, male_bc_vars),
    birth_control_education_female = row_any_yes(fert_raw, female_bc_vars),
    birth_control_education = dplyr::case_when(
      sex == 1 ~ birth_control_education_male,
      sex == 2 ~ birth_control_education_female,
      TRUE ~ dplyr::coalesce(birth_control_education_male, birth_control_education_female)
    ),
    first_birth_month = if ("R9900001" %in% names(fert_raw)) as_num(fert_raw[["R9900001"]]) else NA_real_,
    first_birth_year = if ("R9900002" %in% names(fert_raw)) as_num(fert_raw[["R9900002"]]) else NA_real_
  )

analysis_person <- fert_person |>
  dplyr::left_join(finlit_person, by = "id") |>
  dplyr::left_join(emergency_person, by = "id") |>
  dplyr::mutate(
    sex = factor(sex, levels = c(1, 2), labels = c("Male", "Female")),
    race_ethnicity = factor(race_ethnicity, levels = c(1, 2, 3), labels = c("Hispanic", "Black", "Non-Black, non-Hispanic")),
    birth_control_education = ifelse(is.na(birth_control_education), NA_real_, as.numeric(birth_control_education == 1)),
    completed_fertility = ifelse(completed_fertility < 0, NA_real_, completed_fertility),
    education = ifelse(education < 0 | education > 30, NA_real_, education)
  )

first_birth_data <- analysis_person |>
  dplyr::mutate(
    first_birth_year = ifelse(first_birth_year <= 0, NA_real_, first_birth_year),
    baseline_year = 1979,
    censor_year = 2022,
    prebaseline_parent = !is.na(first_birth_year) & first_birth_year < baseline_year,
    event_first_birth = as.numeric(!is.na(first_birth_year) & first_birth_year >= baseline_year),
    time_to_first_birth = ifelse(event_first_birth == 1, first_birth_year - baseline_year + 1, censor_year - baseline_year + 1)
  ) |>
  dplyr::filter(!prebaseline_parent, !is.na(time_to_first_birth), time_to_first_birth > 0)

# -----------------------------
# 7. Model estimation
# -----------------------------
if (use_precomputed_fe) {
  fe_result <- read.csv(fe_result_path)
  m1_result <- tibble::tibble(
    Outcome = "Marital stability",
    Predictor = "Emergency savings",
    Model = fe_result$model[[1]],
    Metric = "Coefficient",
    Estimate = format_num(fe_result$estimate[[1]], 3),
    SE = format_num(fe_result$se[[1]], 3),
    Statistic = paste0("t = ", format_num(fe_result$t_value[[1]], 2)),
    p = format_p(fe_result$p_value[[1]]),
    CI_95 = paste0("[", format_num(fe_result$ci_low[[1]], 3), ", ", format_num(fe_result$ci_high[[1]], 3), "]")
  )
  m1_n_obs <- fe_result$observations[[1]]
  m1_n_respondents <- fe_result$respondents[[1]]
} else if (has_fixest) {
  m1_fe <- fixest::feols(married ~ emergency_savings | id + year, cluster = ~ id, data = marital_panel)
  ct <- as.data.frame(summary(m1_fe)$coeftable)
  b <- ct["emergency_savings", "Estimate"]
  se <- ct["emergency_savings", "Std. Error"]
  stat <- b / se
  p <- 2 * stats::pnorm(abs(stat), lower.tail = FALSE)
  m1_result <- tibble::tibble(
    Outcome = "Marital stability",
    Predictor = "Emergency savings",
    Model = "Respondent FE LPM",
    Metric = "Coefficient",
    Estimate = format_num(b, 3),
    SE = format_num(se, 3),
    Statistic = paste0("z = ", format_num(stat, 2)),
    p = format_p(p),
    CI_95 = paste0("[", format_num(b - 1.96 * se, 3), ", ", format_num(b + 1.96 * se, 3), "]")
  )
  m1_n_obs <- nobs(m1_fe)
  m1_n_respondents <- dplyr::n_distinct(marital_panel$id)
} else {
  marital_panel <- marital_panel |>
    dplyr::group_by(id) |>
    dplyr::mutate(
      married_dm = married - mean(married, na.rm = TRUE),
      emergency_savings_dm = emergency_savings - mean(emergency_savings, na.rm = TRUE)
    ) |>
    dplyr::ungroup()
  m1_fe <- lm(married_dm ~ emergency_savings_dm + factor(year), data = marital_panel)
  m1_vcov <- sandwich::vcovCL(m1_fe, cluster = marital_panel$id, type = "HC1")
  m1_result <- robust_row_lm_glm(m1_fe, "emergency_savings_dm", "Respondent FE LPM", "Marital stability", "Emergency savings", m1_vcov, FALSE)
  m1_result$Statistic <- sub("z =", "t =", m1_result$Statistic)
  m1_n_obs <- model_n(m1_fe)
  m1_n_respondents <- dplyr::n_distinct(stats::model.frame(m1_fe)$id)
}

poisson_data <- analysis_person |>
  dplyr::filter(!is.na(completed_fertility), !is.na(fin_lit_score_mean), !is.na(birth_control_education), !is.na(education), !is.na(sex), !is.na(race_ethnicity))

m2_poisson <- glm(completed_fertility ~ fin_lit_score_mean + birth_control_education + education + sex + race_ethnicity, family = poisson(link = "log"), data = poisson_data)
m2_vcov <- sandwich::vcovHC(m2_poisson, type = "HC1")
m2_fin_result <- robust_row_lm_glm(m2_poisson, "fin_lit_score_mean", "Poisson", "Completed fertility", "Financial-literacy score", m2_vcov, FALSE)
m2_bc_result <- robust_row_lm_glm(m2_poisson, "birth_control_education", "Poisson", "Completed fertility", "Birth-control education", m2_vcov, FALSE)
m2_fin_irr <- robust_row_lm_glm(m2_poisson, "fin_lit_score_mean", "Poisson", "Completed fertility", "Financial-literacy score", m2_vcov, TRUE)
m2_bc_irr <- robust_row_lm_glm(m2_poisson, "birth_control_education", "Poisson", "Completed fertility", "Birth-control education", m2_vcov, TRUE)

m3_nb <- MASS::glm.nb(completed_fertility ~ fin_lit_score_mean + birth_control_education + education + sex + race_ethnicity, data = poisson_data)
m3_vcov <- sandwich::vcovHC(m3_nb, type = "HC1")
m3_bc_nb_irr <- robust_row_lm_glm(m3_nb, "birth_control_education", "Negative binomial", "Completed fertility", "Birth-control education", m3_vcov, TRUE)

cox_data <- first_birth_data |>
  dplyr::filter(!is.na(event_first_birth), !is.na(time_to_first_birth), !is.na(birth_control_education), !is.na(education), !is.na(sex), !is.na(race_ethnicity))

m4_cox <- survival::coxph(survival::Surv(time_to_first_birth, event_first_birth) ~ birth_control_education + education + sex + race_ethnicity + cluster(id), data = cox_data, robust = TRUE)
m4_result <- robust_row_cox(m4_cox, "birth_control_education", "Timing of first birth", "Birth-control education")
m4_n_obs <- nrow(cox_data)
m4_n_respondents <- dplyr::n_distinct(cox_data$id)
m4_n_events <- sum(cox_data$event_first_birth == 1, na.rm = TRUE)

# -----------------------------
# 8. Export exact audit tables
# -----------------------------
descriptive_summary <- tibble::tibble(
  Measure = c("Children ever born", "Emergency savings reported", "Financial-literacy score", "Birth-control education exposure"),
  `Exact value` = c(
    format_num(mean(analysis_person$completed_fertility, na.rm = TRUE), 3),
    paste0(format_num(100 * mean(marital_panel$emergency_savings, na.rm = TRUE), 1), "%"),
    format_num(mean(finlit_panel$fin_lit_score, na.rm = TRUE), 3),
    paste0(format_num(100 * mean(analysis_person$birth_control_education, na.rm = TRUE), 1), "%")
  ),
  Level = c("Respondent", "Respondent-wave", "Respondent-wave", "Respondent"),
  `Primary model use` = c("Completed-fertility models", "Marital-stability model", "Completed-fertility model", "Completed-fertility and first-birth timing models")
)

model_samples <- tibble::tibble(
  Model = c("Emergency savings and marital stability", "Completed fertility count model", "Negative binomial robustness", "Timing of first birth"),
  `Observation level` = c("Respondent-wave", "Respondent", "Respondent", "Respondent"),
  `Analytic observations` = c(m1_n_obs, model_n(m2_poisson), model_n(m3_nb), m4_n_obs),
  `Unique respondents` = c(m1_n_respondents, dplyr::n_distinct(poisson_data$id), dplyr::n_distinct(poisson_data$id), m4_n_respondents)
)

main_results <- dplyr::bind_rows(m1_result, m2_fin_result, m2_bc_result, m4_result)
effect_sizes <- dplyr::bind_rows(m2_fin_irr, m2_bc_irr, m3_bc_nb_irr, m4_result) |>
  dplyr::select(Outcome, Predictor, Model, Metric, Estimate, CI_95)

poisson_overdispersion <- sum(residuals(m2_poisson, type = "pearson")^2, na.rm = TRUE) / stats::df.residual(m2_poisson)
cox_zph <- tryCatch(survival::cox.zph(m4_cox), error = function(e) NULL)
cox_global_p <- if (!is.null(cox_zph) && "GLOBAL" %in% rownames(cox_zph$table)) cox_zph$table["GLOBAL", "p"] else NA_real_

robustness_diagnostics <- tibble::tibble(
  Check = c("Poisson overdispersion ratio", "Negative binomial theta", "Birth-control education IRR in negative binomial model", "Cox first-birth events", "Cox proportional hazards global test"),
  `Exact value` = c(format_num(poisson_overdispersion, 3), format_num(m3_nb$theta, 3), m3_bc_nb_irr$Estimate, as.character(m4_n_events), format_p(cox_global_p)),
  Interpretation = c(
    "Values above 1 indicate overdispersion relative to the Poisson variance assumption.",
    "Larger theta indicates less overdispersion in the negative binomial parameterization.",
    "Robustness estimate for the birth-control education association with completed fertility.",
    "Number of observed first-birth events in the Cox estimation sample; this is not the same as the respondent-level analytic sample size.",
    "Non-significant global test supports the proportional-hazards assumption."
  )
)

variable_crosswalk <- tibble::tibble(
  Construct = c("Respondent identifier", "Sex", "Race/ethnicity", "Marital status", "Emergency savings", "Financial-literacy objective items", "Completed fertility", "First child date of birth", "Birth-control education exposure", "Education"),
  Variables = c(
    "R0000100",
    "R0214800",
    "R0214700",
    paste(names(marital_vars), collapse = ", "),
    paste(names(emergency_vars), collapse = ", "),
    paste(unlist(finlit_items), collapse = ", "),
    paste(numkid_vars, collapse = ", "),
    "R9900001, R9900002",
    paste(c(male_bc_vars, female_bc_vars), collapse = ", "),
    paste(education_vars, collapse = ", ")
  ),
  `Model role` = c("Panel/person linkage", "Control", "Control", "Outcome for marital-stability model", "Primary predictor for marital-stability model", "Primary predictor for completed-fertility model", "Outcome for completed-fertility models", "Outcome construction for first-birth timing model", "Primary predictor for fertility and timing models", "Control")
)

write.csv(descriptive_summary, file.path(OUTPUT_DIR, "table1_descriptive_summary.csv"), row.names = FALSE)
write.csv(model_samples, file.path(OUTPUT_DIR, "table1b_model_specific_samples.csv"), row.names = FALSE)
write.csv(main_results, file.path(OUTPUT_DIR, "table2_main_results.csv"), row.names = FALSE)
write.csv(effect_sizes, file.path(OUTPUT_DIR, "table2b_effect_sizes.csv"), row.names = FALSE)
write.csv(robustness_diagnostics, file.path(OUTPUT_DIR, "table3_sensitivity_diagnostics.csv"), row.names = FALSE)
write.csv(variable_crosswalk, file.path(OUTPUT_DIR, "variable_crosswalk.csv"), row.names = FALSE)
write.csv(marital_panel, file.path(OUTPUT_DIR, "analytic_marital_panel.csv"), row.names = FALSE)
write.csv(analysis_person, file.path(OUTPUT_DIR, "analytic_person_file.csv"), row.names = FALSE)

write_latex(descriptive_summary, file.path(OUTPUT_DIR, "table1_descriptive_summary.tex"), "Descriptive Summary of Core Analytic Measures")
write_latex(model_samples, file.path(OUTPUT_DIR, "table1b_model_specific_samples.tex"), "Model-Specific Analytic Samples")
write_latex(main_results, file.path(OUTPUT_DIR, "table2_main_results.tex"), "Main Model Results")
write_latex(robustness_diagnostics, file.path(OUTPUT_DIR, "table3_sensitivity_diagnostics.tex"), "Sensitivity and Diagnostic Summary")
write_latex(variable_crosswalk, file.path(OUTPUT_DIR, "variable_crosswalk.tex"), "Variable Crosswalk")

cat("\nCompleted NLSY79 manuscript analysis.\n")
cat("Input fertility file: ", normalizePath(fertility_path), "\n", sep = "")
cat("Input financial/marital file: ", normalizePath(finance_path), "\n", sep = "")
if (use_precomputed_fe) cat("Input precomputed FE file: ", normalizePath(fe_result_path), "\n", sep = "")
cat("Tables and audit files written to: ", normalizePath(OUTPUT_DIR), "\n\n", sep = "")
print(main_results)
cat("\nModel-specific samples:\n")
print(model_samples)
cat("\nCox first-birth events:\n")
print(m4_n_events)
