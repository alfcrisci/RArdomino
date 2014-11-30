
Sys.setlocale('LC_ALL','C')

rshortenize<-function(longurl,gekey) {
                
require(httr)
require(jsonlite)
response=POST("https://www.googleapis.com/urlshortener/v1/url",body= list(key=gekey,longUrl=longurl),encode = "json")
text <- content(response, as = "text")
res=fromJSON(text)
return(res$id)

} 

parse.ini <- function(INI.filename)
{ # https://stat.ethz.ch/pipermail/r-help/2007-June/134115.html
  connection <- file(INI.filename)
  Lines  <- readLines(connection)
  close(connection)

  Lines <- chartr("[]", "==", Lines)  # change section headers

  connection <- textConnection(Lines)
  d <- read.table(connection, as.is = TRUE, sep = "=", fill = TRUE)
  close(connection)

  L <- d$V1 == ""                    # location of section breaks
  d <- subset(transform(d, V3 = V2[which(L)[cumsum(L)]])[1:3],
                           V1 != "")

  ToParse  <- paste("INI.list$", d$V3, "$",  d$V1, " <- '",
                    d$V2, "'", sep="")

  INI.list <- list()
  eval(parse(text=ToParse))

  return(INI.list)
}

toLocalEncoding <-
function(x, sep="\t", quote=FALSE, encoding="utf-8")
{
  rawtsv <- tempfile()
  write.table(x, file=rawtsv, sep=sep, quote=quote)
  result <- read.table(file(rawtsv, encoding=encoding), sep=sep, quote=quote)
  unlink(rawtsv)
  result
}
  
savePlot <- function(myPlot,filename) {
        png("filename")
        print(myPlot)
        dev.off()
}


  
if (file.exists("proverbi_autunno.csv")){
                                           proverbi=read.csv("proverbi_autunno.csv");
                                          }                                        


dfClean <- function(df){
    nms <- t(df[1,])
    names(df) <- nms
    df <- df[-1,-1] 
    row.names(df) <- seq(1,nrow(df))
    df
  }

readSpreadsheet <- function(url, sheet = 1){
   library(httr)
   r <- GET(url)
   html <- content(r)
   sheets <- readHTMLTable(html, header=FALSE, stringsAsFactors=FALSE)
   df <- sheets[[sheet]]
   df=dfClean(df)
   return(df)
}

plot.xts2 <- function (x, y = NULL, type = "l", auto.grid = TRUE, major.ticks = "auto", 
    minor.ticks = TRUE, major.format = TRUE, bar.col = "grey", 
    candle.col = "white", ann = TRUE, axes = TRUE, col = "black", ...) 
{
    series.title <- deparse(substitute(x))
    ep <- axTicksByTime(x, major.ticks, format = major.format)
    otype <- type
    if (xts:::is.OHLC(x) && type %in% c("candles", "bars")) {
        x <- x[, xts:::has.OHLC(x, TRUE)]
        xycoords <- list(x = .index(x), y = seq(min(x), max(x), 
                length.out = NROW(x)))
        type <- "n"
    }
    else {
        if (NCOL(x) > 1) 
            warning("only the univariate series will be plotted")
        if (is.null(y)) 
            xycoords <- xy.coords(.index(x), x[, 1])
    }
    plot(xycoords$x, xycoords$y, type = type, axes = FALSE, ann = FALSE, 
        col = col, ...)
    if (auto.grid) {
        abline(v = xycoords$x[ep], col = "grey", lty = 4)
        grid(NA, NULL)
    }
    if (xts:::is.OHLC(x) && otype == "candles") 
        plot.ohlc.candles(x, bar.col = bar.col, candle.col = candle.col, 
            ...)
    dots <- list(...)
    if (axes) {
        if (minor.ticks) 
            axis(1, at = xycoords$x, labels = FALSE, col = "#BBBBBB", 
                ...)
        axis(1, at = xycoords$x[ep], labels = names(ep), las = 1, 
            lwd = 1, mgp = c(3, 2, 0), ...)
        axis(2, ...)
    }
    box()
    if (!"main" %in% names(dots)) 
        title(main = series.title)
    do.call("title", list(...))
    assign(".plot.xts", recordPlot(), .GlobalEnv)
}			 

wunder_station_daily <- function(station, date)
  {
  base_url <- 'http://www.wunderground.com/weatherstation/WXDailyHistory.asp?'
 
  # parse date
  m <- as.integer(format(date, '%m'))
  d <- as.integer(format(date, '%d'))
  y <- format(date, '%Y')
 
  # compose final url
  final_url <- paste(base_url,
  'ID=', station,
  '&month=', m,
  '&day=', d,
  '&year=', y,
  '&format=1', sep='')
 
  # reading in as raw lines from the web server
  # contains <br> tags on every other line
  u <- url(final_url)
  the_data <- readLines(u)
  close(u)
 
  # only keep records with more than 5 rows of data
  if(length(the_data) > 5 )
        {
        # remove the first and last lines
        the_data <- the_data[-c(1, length(the_data))]
       
        # remove odd numbers starting from 3 --> end
        the_data <- the_data[-seq(3, length(the_data), by=2)]
       
        # extract header and cleanup
        the_header <- the_data[1]
        the_header <- make.names(strsplit(the_header, ',')[[1]])
       
        # convert to CSV, without header
        tC <- textConnection(paste(the_data, collapse='\n'))
        the_data <- read.csv(tC, as.is=TRUE, row.names=NULL, header=FALSE, skip=1)
        close(tC)
       
        # remove the last column, created by trailing comma
        the_data <- the_data[, -ncol(the_data)]
       
        # assign column names
        names(the_data) <- the_header
       
        # convert Time column into properly encoded date time
        the_data$Time <- as.POSIXct(strptime(the_data$Time, format='%Y-%m-%d %H:%M:%S'))
       
        # remove UTC and software type columns
        the_data$DateUTC.br. <- NULL
        the_data$SoftwareType <- NULL
       
        # sort and fix rownames
        the_data <- the_data[order(the_data$Time), ]
        row.names(the_data) <- 1:nrow(the_data)
       
        # done
        return(the_data)
        }
  }
  
  
#####################################################################################
# Create regular sampling of day

require(xts)

regular_timeseries=ISOdatetime(format(Sys.Date(),"%Y"),format(Sys.Date(),"%m"),format(Sys.Date(),"%d"),0,0,0) + seq(0:46)*30*60
xts_today <- xts(1:length(regular_timeseries),regular_timeseries))
  
#####################################################################################
# Retrieve data from sensor


get_weather_lamma<-function (comune="Prato") 
                      {
					   webstring="http://www.lamma.rete.toscana.it/previ/ita/xml/comuni_web/dati/";
					   url_tuscan_weather=paste0(webstring,tolower(comune),".xml");
                       xml_foreast=xmlParse(url_tuscan_weather);
					   data_list <- xmlToList(xml_foreast);
					   name_file=paste0("data/lamma_forecast_",tolower(comune),"_",as.character(today),".rds")
                       saveRDS(data_list[[1]],file=name_file)
                       return(data_list) 					   
					  }
					  


get_acqualta_data<-function (urlsensor="http://api.acqualta.org/api/data") 
                          { require(xts)
						    dataweb <- jsonlite::fromJSON(urlsensor,flatten=T)
						    res=data.frame(daydate=as.Date(dataweb$data$date_sent),time_sensor=strptime(dataweb$data$date_sent, "%FT%T"),level=dataweb$data$level)
							today_date=Sys.Date()
						    res$weekday=weekdays(as.Date(res$daydate))
                            res$hour=format(strptime(dataweb$data$date_sent, "%FT%T"), "%H")						
							res$hour_minute=format(strptime(dataweb$data$date_sent, "%FT%T"), "%H:%M")	
							res_last_day=res[which(res$daydate==res$daydate[1]),]
							level=xts(res_last_day$level,res_last_day$time_sensor)
							title_fig=paste("Livello Venezia Ognissanti - www.acqualta.org \n Data:",as.character(today_date))
							namefig="images/last_aqualta.png"
							png(filename = namefig,width = 800, height = 600, units = "px")
                            plot.xts2(level,col="red",type="b",major.ticks="Ora",major.format="%H:%M",ylab="Livello (cm)",main=title_fig)
						    dev.off()
							name_file=paste0("data/aqualta_",as.character(today),".rds")
                            saveRDS(res_last_day,file=name_file)
						  } 





 						  