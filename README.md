# telescrapeR
Work in Progress.


## Installation

``` r
devtools::install_github("mwgnd/telescrapeR")
```

### Telegram API
This package uses the Telegram API via the Python Telethon library, so you'll need to have access to the API. You can easily get your API credentials from Telegram: 
* Sign up for Telegram using any application.
* Log in to your Telegram core: https://my.telegram.org.
* Go to "API development tools" and fill out the form.
* You will get basic addresses as well as the api_id and api_hash parameters required for user authorization.
* For the moment each number can only have one api_id connected to it.

Source: https://core.telegram.org/api/obtaining_api_id

#### Demo

``` r
library(telescrapeR)

# install the Telethon library in an Python virtual environment called "r-telescrapeR"
install_telethon()

# api credentials
api_id <- 123456789
api_hash <- "******************"

# number of messages
n = 100

# channels to be scraped (vector of t.me urls)
channels <- c("https://t.me/Spiegel_Online",
              "https://t.me/corona_infokanal_bmg")

df <- get_messages(channels, n = n, api_id, api_hash)

```
