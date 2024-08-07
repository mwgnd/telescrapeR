% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_messages.R
\name{snowball_scrape}
\alias{snowball_scrape}
\title{Perform a snowball sampling scrape based on forwarded messages.}
\usage{
snowball_scrape(x, batch_size, iterations, offset_date = NULL, reverse = FALSE)
}
\arguments{
\item{x}{A Seedlist specifying Telegram channels or users to start the snowball sampling. Character vector containing the `Telegram`` entities. Could be in the format of "t.me/xxx", https://t.me/xxx" or "xxx".}

\item{batch_size}{Numeric, number of new entities to scrape in each iteration.}

\item{iterations}{Numeric, number of iterations to perform for the snowball sampling.}

\item{offset_date}{Optional offset date (messages previous to this date will be retrieved). Use reverse for messages newer to this date.}

\item{reverse}{Logical, whether to scrape messages in reverse order. The default order (FALSE) is from newest to oldest, but this behavior can be changed with the reverse parameter (TRUE).}
}
\value{
A data frame containing scraped Telegram messages with additional columns 'seed' indicating
if the message originated from the seed list, and 'iteration' denoting the snowball iteration.
}
\description{
Given a seed list of Telegram channels or groups, this function iteratively collects
messages and identifies new channels or groups based on forwarded messages and scrapes them.
The function collects all messages of a channel if no offset date is set.
}
\details{
The function \code{snowball_scrape} starts by scraping an initial seed list of channels or groups.
It then iterates multiple times, searching for new scraping candidates based on forwarded messages. Each iteration retrieves
a batch of new entities and appends them to the existing data frame. The candidate selection is based on a calculated score, which is
calculated using the formula:  \deqn{score = n \times \log(w + 1)}
where \eqn{n} is the total number of occurrences of forwarded messages from a specific channel collected in the current iteration,
and \eqn{w} is the number of different unique channels in the current iteration that forwarded messages from this specific channel.

If you have a initial seed list of 50 Telegram channels or groups and you set the batch size to 25 and the number of iterations to 3,
you will scrape a total of 125 channels or groups. It will start by scraping the initial seed list of 50 channels or groups,
then it will evaluate the forwarded messages and select the 25 channels or groups with the highest score not in the seed list.
Then it will scrape these 25 channels or groups and evaluate the forwarded messages in this batch, and so on for multiple iterations.
If the batch size is higher than the number of new entities found in the forwarded messages of an iteration, the function will scrape all the new entities found.
}
\examples{
\dontrun{
# Perform snowball sampling on a seed list of Telegram channels
snowball_scrape(c("channel1", "channel2"), batch_size = 10, iterations = 3)
}

}
