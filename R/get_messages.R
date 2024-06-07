#' Setup the Telegram client
#'
#' This function loads the Python environment, the Python functions and defines the telegram client.
#'
#' @param api_id The API ID provided by Telegram.
#' @param api_hash The API hash provided by Telegram.
#' @param env The name of the virtual environment to use. Default is "r-telescrapeR".
#' @return NULL
#' @importFrom reticulate py py_run_file use_virtualenv py_run_string
#' @importFrom glue glue
#' @examples
#' \dontrun{
#' # Start TelescrapeR in default environment
#' start_ts(api_id, api_hash)
#' }
#' @export

start_ts <- function(api_id,
                     api_hash,
                     env = "r-telescrapeR") {

  # use specified virtual environment
  reticulate::use_virtualenv(env)
  reticulate::py_run_string(glue("print('Using', '{env}', 'virtual enviroment')"))

  # load the python functions
  py_script <- system.file("py_func.py", package = "telescrapeR")
  reticulate::py_run_file(py_script)

  # setup the telegram client
  py$client(api_id, api_hash)


}


#' Get messages from channels.
#'
#' @description
#' `get_messages()` retrieves messages from the specified channels.
#'
#' @param x Character vector containing the `Telegram`` entities. Could be in the format of "t.me/xxx", https://t.me/xxx" or "xxx".
#' @param n Number of messages to be scraped. Defauls is 0, which means all.
#' @param reverse The default order (FALSE) is from newest to oldest, but this behaviour can be changed with the reverse parameter (TRUE).
#' @param min_id All the messages with a lower (older) messege_id or equal to this will be excluded .
#' @param max_id All the messages with a higher (newer) message_id or equal to this will be excluded.
#' @param offset_date  Offset date (messages previous to this date will be retrieved). Use reverse for messages newer to this date.
#' @param verbose If TRUE, the function will print the channels and the number of messages being scraped.
#' @importFrom reticulate py
#' @return A data frame.
#' @seealso [start_ts()], [update_messages()]
#' @examples
#' \dontrun{
#' # Start TelescrapeR
#' start_ts(api_id, api_hash)
#'
#' # Scrape all messages from channels
#' df <- get_messages(x)
#'
#' # Scrape 100 messages from channels (newest to oldest)
#' df <- get_messages(x, n = 100)
#'
#' # Scrape 100 messages from channels (oldest to newest)
#' df <- get_messages(x, n = 100, reverse = TRUE)
#'
#' # Scrape messages sent before a certain date
#' df <- get_messages(x, offset_date = "2024-05-24")
#'
#' # Scrape messages sent after a certain date
#' df <- get_messages(x, offset_date = "2024-05-24", reverse = TRUE)
#' }
#' @export
#'
get_messages <- function(x,
                         n = 0,
                         reverse = FALSE,
                         min_id = 0,
                         max_id = 0,
                         offset_date = NULL,
                         verbose = TRUE) {

  #scrape messages
  list_of_messages <- list()

  for (channel in x) {
    if (verbose) { cat(paste("Scraping messages from", channel, "...\n"))}

    py_list <- py$scrape_messages(channel, n, reverse,
                                  as.integer(min_id),
                                  as.integer(max_id),
                                  as.Date(offset_date),
                                  verbose)
    list_of_messages <- append(list_of_messages, py_list)
  }
  # turn list into a data frame
  df <- do.call(rbind.data.frame, list_of_messages)

  if (verbose) {cat("Scraped", nrow(df), "messages.\n")}

  return(df)
}

#' Update message dataframe with new messages
#'
#' @description
#' `update_messages()` updates a data frame of previously fetched messages with newer messages. Use after [get_messages()] to fetch new messages.
#'
#' @param x A data frame previously fetched by `telescrapeR`
#' @param verbose If TRUE, the function will print the channels and the number of messages being scraped.
#' @return A data frame with old and new scraped messages.
#' @seealso [start_ts()], [get_messages()]
#' @examples
#' \dontrun{
#' #Start TelescrapeR (if not already started)
#' start_ts(api_id, api_hash)
#'
#' # Scrape all messages from channels
#' df <- get_messages(x)
#'
#' # Update message dataframe with new messages
#' df_update <- update_messages(df)
#' }
#' @export
#'


update_messages <- function(x,
                            verbose = TRUE) {
  # get the last message_id for each channel
  min_ids <- tapply(x$message_id, x$chat_name, max)

  min_id_df <- data.frame(
    chat_name = names(min_ids),
    max_message_id = as.vector(min_ids)
  )
  # scrape new messages
  templist <- list()

  for (i in 1:nrow(min_id_df)) {
    z <- get_messages(x = min_id_df$chat_name[i],
                      min_id = min_id_df$max_message_id[i],
                      verbose = verbose)

    templist[[i]] <- z
  }
  # turn list into a data frame
  df <- do.call(rbind, templist)

  # merge old and new messages
  if (identical(colnames(x), colnames(df))) {
    if (verbose) {cat("Adding new scraped messages to old ones...")}
    new <- rbind(x, df)
    ordered_new <- new[order(new$chat_name, new$message_id), ]

    return(ordered_new)
  } else {
    cat("Dataframes have different columns. Return new messages without merging with old ones.")

    return(df)
  }

}






