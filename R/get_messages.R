#' Get messages from a channel.
#'
#' This function sets the channel links, API ID, and API hash, and then retrieves messages from the specified channel using the provided API credentials.
#'
#' @param x Character vector containing the channel links.
#' @param n Number of messages to be scraped
#' @param api_id The API ID required for authentication.
#' @param api_hash The API hash required for authentication.
#' @param env The name of the Python virtual environment to be used, when not "r-telescrapeR
#' @importFrom reticulate py py_run_file use_virtualenv py_to_r import r_to_py
#' @importFrom glue glue
#' @return A data frame with the following columns: channel_name, channel_id, title, message_id, message_views, date, sender_id, message_text
#' @export
#'
get_messages <- function(x,
                         n,
                         api_id,
                         api_hash,
                         env = "r-telescraper") {
  # use specified virtual environment
  reticulate::use_virtualenv(env)
  reticulate::py_run_string(glue("print('Using', '{env}', 'virtual enviroment')"))

  # assign python variables
  py$channel_links <- x
  py$api_id <- api_id
  py$api_hash <- api_hash
  py$n_limit <- as.integer(n)

  # scrape messages with the python script
  reticulate::py_run_file("inst/scrape_messages.py")

  # transform python to r
  transform_py <- py_to_r(py$all_messages)
  # create dataframe with all messages
  df <- do.call(rbind.data.frame, transform_py)

  return(df)
}


