#' Get messages from a channel.
#'
#' This function sets the channel links, API ID, and API hash, and then retrieves messages from the specified channel using the provided API credentials.
#'
#' @param x Character vector containing the channel links.
#' @param n Number of messages to be scraped
#' @param api_id The API ID required for authentication.
#' @param api_hash The API hash required for authentication.
#' @param env The name of the Python virtual environment to be used, when not "r-telescrapeR
#' @importFrom reticulate py py_run_file use_virtualenv py_to_r import
#' @importFrom glue glue
#' @return A data frame with the following columns: channel_name, channel_id, title, message_id, message_views, date, sender_id, message_text
#' @export
#'
get_messages <- function(x,
                         n,
                         api_id,
                         api_hash,
                         env = "r-telescraper") {
  reticulate::use_virtualenv(env)

  x_python <- glue::glue("[{paste(sprintf('\"%s\"', x), collapse = ', ')}]")

  py_vars <- glue("
channel_links = {x_python}
api_id = '{api_id}'
api_hash = '{api_hash}'
n_limit = {n}
")

  # create python variables
  reticulate::py_run_string(py_vars)



  # scrape messages with the python script
  reticulate::py_run_file("inst/scrape_messages.py")

  # transform python to r
  transform_py <- py_to_r(py$all_messages)
  # create dataframe with all messages
  df <- do.call(rbind.data.frame, transform_py)

  return(df)
}


