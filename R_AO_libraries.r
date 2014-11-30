################################################################################
# Load/ install Required packages

if (!require(RCurl)) {install.packages("RCurl"); library(RCurl)}
if (!require(plyr)) {install.packages("plyr"); library(plyr)}
if (!require(XML)) {install.packages("XML"); library(XML)}
if (!require(jsonlite)) {install.packages("jsonlite"); library(jsonlite)}
if (!require(httr)) {install.packages("httr"); library(httr)}
if (!require(RSQLite)) {install.packages("RSQLite"); library(RSQLite)}
if (!require(ggplot2)) {install.packages("ggplot2"); library(ggplot2)}
if (!require(scales)) {install.packages("scales");  library(scales)}
if (!require(xts)) {install.packages("xts"); library(xts)}
if (!require(weatherData)) {install.packages('weatherData'); library(weatherData)}
if (!require(devtools)) {install.packages("devtools"); library(devtools)}
if (!require(Rforecastio)) {install_github("Rforecastio", "hrbrmstr"); library(Rforecastio)}
if (!require(rjson)) {install.packages("rjson"); library(rjson)}
if (!require(bit64)) {install.packages("bit64"); library(bit64)}
if (!require(twitteR)) {install_github("twitteR", username="geoffjentry"); library(twitteR)}
if (!require(chron)) {install.packages("chron"); library(chron)}
if (!require(stringr)) {install.packages("stringr"); library(stringr)}
