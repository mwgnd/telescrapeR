#' Install the Telethon package in a specified Python virtual environment.
#'
#' This function installs the Telethon package, a Python library for Telegram API, in the specified Python virtual environment. If a new environment is requested and an environment with the same name already exists, it will be removed before installation.
#'

#' @param envname The name of the Python virtual environment where Telethon will be installed. Default is "r-telescrapeR".
#' @param new_env Logical indicating whether a new virtual environment should be created. Default is `TRUE` if `envname` is "r-telescrapeR".
#' @details The function installs the Telethon package in the specified Python virtual environment. If `new_env` is `TRUE` and the specified environment already exists, it will be removed before installation to ensure a clean setup.
#' @importFrom reticulate virtualenv_exists virtualenv_remove py_install
#' @export
#'
#' @examples
#' \dontrun{
#' # Install Telethon package in the default environment
#' install_telethon()
#'
#' # Install Telethon package in a new environment named "myenv"
#' install_telethon(envname = "myenv", new_env = TRUE)
#'
#' # Install Telethon package in an existing environment named "r-telescrapeR"
#' install_telethon(envname = "r-telescrapeR", new_env = FALSE)
#' }
install_telethon <- function(...,
                             envname = "r-telescrapeR",
                             new_env = identical(envname, "r-telescrapeR")) {
  if (new_env && reticulate::virtualenv_exists(envname)) {
    reticulate::virtualenv_remove(envname)
  }
  reticulate::py_install(packages = "telethon", envname = envname, ...)
}
