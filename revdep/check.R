library("devtools")

res <- revdep_check()
revdep_check_save_summary()
revdep_check_print_problems()
# revdep_email(date = "September 18", version = "v0.6.0", only_problems = FALSE, draft = TRUE)
