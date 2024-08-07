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
#' @param reverse The default order (FALSE) is from newest to oldest, but this behavior can be changed with the reverse parameter (TRUE).
#' @param min_id All the messages with a lower (older) message_id or equal to this will be excluded .
#' @param max_id All the messages with a higher (newer) message_id or equal to this will be excluded.
#' @param offset_date  Optional offset date (messages previous to this date will be retrieved). Use reverse for messages newer to this date.
#' @param verbose If TRUE, the function will print the channels and the number of messages being scraped.
#' @importFrom reticulate py
#' @importFrom stringr str_extract_all
#' @return A data frame containing scraped Telegram messages.
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
  #turn list into a data frame
  df <- do.call(rbind.data.frame, list_of_messages)
  # change types
  df$message_views <- as.integer(df$message_views)
  df$reply_to_message_id <- as.integer(df$reply_to_message_id)
  df$date <- as.POSIXct(df$date, format = "%Y-%m-%d %H:%M:%S")

  # extract links in text messages
  pattern <- "http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+"
  df$links_in_text <- sapply(stringr::str_extract_all(df$message_text, pattern),
                             function(x) paste(x, collapse = "|"))


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

#' Perform a snowball sampling scrape based on forwarded messages.
#'
#' Given a seed list of Telegram channels or groups, this function iteratively collects
#' messages and identifies new channels or groups based on forwarded messages and scrapes them.
#' The function collects all messages of a channel if no offset date is set.
#'
#' @param x A Seedlist specifying Telegram channels or users to start the snowball sampling. Character vector containing the `Telegram`` entities. Could be in the format of "t.me/xxx", https://t.me/xxx" or "xxx".
#' @param batch_size Numeric, number of new entities to scrape in each iteration.
#' @param iterations Numeric, number of iterations to perform for the snowball sampling.
#' @param offset_date Optional offset date (messages previous to this date will be retrieved). Use reverse for messages newer to this date.
#' @param reverse Logical, whether to scrape messages in reverse order. The default order (FALSE) is from newest to oldest, but this behavior can be changed with the reverse parameter (TRUE).
#' @importFrom dplyr filter mutate
#' @importFrom rlang .data
#' @return A data frame containing scraped Telegram messages with additional columns 'seed' indicating
#'         if the message originated from the seed list, and 'iteration' denoting the snowball iteration.
#' @details The function \code{snowball_scrape} starts by scraping an initial seed list of channels or groups.
#' It then iterates multiple times, searching for new scraping candidates based on forwarded messages. Each iteration retrieves
#' a batch of new entities and appends them to the existing data frame. The candidate selection is based on a calculated score, which is
#' calculated using the formula:  \deqn{score = n \times \log(w + 1)}
#' where \eqn{n} is the total number of occurrences of forwarded messages from a specific channel collected in the current iteration,
#' and \eqn{w} is the number of different unique channels in the current iteration that forwarded messages from this specific channel.
#'
#' If you have a initial seed list of 50 Telegram channels or groups and you set the batch size to 25 and the number of iterations to 3,
#' you will scrape a total of 125 channels or groups. It will start by scraping the initial seed list of 50 channels or groups,
#' then it will evaluate the forwarded messages and select the 25 channels or groups with the highest score not in the seed list.
#' Then it will scrape these 25 channels or groups and evaluate the forwarded messages in this batch, and so on for multiple iterations.
#' If the batch size is higher than the number of new entities found in the forwarded messages of an iteration, the function will scrape all the new entities found.
#' @examples
#' \dontrun{
#' # Perform snowball sampling on a seed list of Telegram channels
#' snowball_scrape(c("channel1", "channel2"), batch_size = 10, iterations = 3)
#' }
#'
#' @export



snowball_scrape <- function(x, batch_size, iterations, offset_date = NULL, reverse = FALSE) {

  cat("Scraping seedlist...", "\n")
  # scraping the initial seedlist
  df <- telescrapeR::get_messages(x, offset_date = offset_date, reverse = reverse) |>
    mutate(seed = TRUE,
           iteration = 0)

  cat("Scraping seedlist complete. Starting snowball iterations...", "\n")

  # starting the iterations after seedlist
  for (i in 1:iterations) {

    cat("Starting iteration", i, "of", iterations, "\n","Analyzing forwarded messages...", "\n")
    # searching for new scraping candidates based on a calculated score of forwarded messages
    candidates <- df |>
      filter(.data$iteration == i - 1) |>
      filter(.data$forward_from != "") |>
      dplyr::group_by(.data$forward_from) |>
      dplyr::summarise(
        count = dplyr::n(),
        unique_chat_ids = dplyr::n_distinct(.data$chat_id)
      ) |>
      mutate(score = .data$count * log(.data$unique_chat_ids + 1)) |>
      filter(!.data$forward_from %in% df$chat_name) |>
      dplyr::arrange(dplyr::desc(.data$score)) |>
      dplyr::slice_head(n = batch_size) |>
      dplyr::pull(.data$forward_from)

    cat("Scraping new entities...", "\n")
    # scraping the new entities
    new_df <- get_messages(candidates, offset_date = offset_date, reverse = reverse) |>
      dplyr::mutate(seed = FALSE,
             iteration = i)
    # binding the new entities to the existing dataframe
    df <- dplyr::bind_rows(df, new_df)

  }

  cat("Scraping finished. Total number of messages:", nrow(df), "messages from", length(unique(df$chat_name)), "channels.", "\n")
  return(df)
}







