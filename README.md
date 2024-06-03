# telescrapeR
Work in Progress.

With TelescrapeR you can download text messages from public Telegram groups and channels. The package has only one useful function so far (`get_messages()`), which should work. I created the package to extract messages from channels conveniently in R, and to learn how to create R packages. Since this is my first package, maybe not everything runs smoothly. Any suggestions are welcome.


## Installation

``` r
devtools::install_github("mwgnd/telescrapeR")
```
### Reticulate
As this package uses the telethon python library via reticulate (R Interface to Python), you should have python installed on your machine. This could also be done by the Reticulate package. You will also need to create a virtual environment in which the Telethon Rython library will be installed. `install_telethon()` will create an environment for you called "r-telescrapeR" with Telethon installed.

```r
install.packages("reticulate")

# Download and install Python
reticulate::install_python()

# The use_python() function enables you to specify an alternate python

reticulate::use_python("/usr/local/bin/python")

# create virtual env and load telethon

telescrapeR::install_telethon()

```


#### Telegram API
This package uses the Telegram API via the Python Telethon library, so you'll need to have access to the API. You can easily get your API credentials from Telegram: 
* Sign up for Telegram using any application.
* Log in to your Telegram core: https://my.telegram.org.
* Go to "API development tools" and fill out the form.
* You will get basic addresses as well as the api_id and api_hash parameters required for user authorization.
* For the moment each number can only have one api_id connected to it.

Source: https://core.telegram.org/api/obtaining_api_id

##### Demo

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
channels <- c("Spiegel_Online",
              "corona_infokanal_bmg")

df <- get_messages(channels, api_id, api_hash, n = n)

```
