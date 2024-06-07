# telescrapeR
Work in Progress.

With `TelescrapeR` you can download text messages from public Telegram groups and channels. The package has only two useful functions so far (`get_messages` and `update_messages`),both of which are expected to work. I created the package to extract messages from channels conveniently in `R`, and to learn how to create `R` packages. Since this is my first package, maybe not everything runs smoothly. Any suggestions are welcome.


## Installation

``` r
# install.packages("devtools")
devtools::install_github("mwgnd/telescrapeR")
```
## Reticulate
As this package uses the telethon python library via reticulate (R Interface to Python), you should have Python installed on your machine. This could also be done by the Reticulate package. You will also need to create a virtual environment in which the Telethon Python library will be installed. `install_telethon()` will create an environment for you called "r-telescrapeR" with Telethon installed.

Install `reticulate`.
```r
install.packages("reticulate")
```
If you do not have Python on your machine, you can install it via `reticulate` with `install_python()`.

```r
reticulate::install_python()

#If you want to use a particular version of Python from your machine, you can specify this with `use_python()`.
reticulate::use_python("/usr/local/bin/python")
```
Create a virtual environment and install Telethon in it.
```r
telescrapeR::install_telethon()

```


## Telegram API
This package uses the Telegram API via the Python Telethon library, so you'll need to have access to the API. You can easily get your API credentials from Telegram: 
* Sign up for Telegram using any application.
* Log in to your Telegram core: https://my.telegram.org.
* Go to "API development tools" and fill out the form.
* You will get basic addresses as well as the api_id and api_hash parameters required for user authorization.
* For the moment each number can only have one api_id connected to it.

Source: https://core.telegram.org/api/obtaining_api_id

## Usage
Load the package.
``` r
library(telescrapeR)
```
Install the Telethon library in an Python virtual environment called `r-telescrapeR`.
``` r
install_telethon()
```
Define your api credentials and start `TelescrapeR`.
``` r
api_id <- 123456789
api_hash <- "******************"

start_ts(api_id, api_hash)
```
Define channels and scrape Messages.
``` r
# channels to be scraped (vector of t.me urls)
channels <- c("Spiegel_Online",
              "corona_infokanal_bmg")

df <- get_messages(channels)
```
You can also update a previously fetched dataframe with new messages.
``` r
df_update <- update_messages(df)

```

#### Data fetched
 * Chat Name
 * Chat ID
 * Chat Title
 * Message Chat ID
 * Is Reply
 * Reply to message ID
 * Message views
 * Datetime
 * Sender ID
 * Message Text
 * Forward from
