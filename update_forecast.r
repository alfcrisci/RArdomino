################################################################################################
# PURPOSE:
# Procedure to read and update weather forecast provided by forecast.io and LaMMA  Consortium Regione Toscana
# 
# INSTITUTIONS:
# 
# Consorzio LaMMA - www.lamma.rete.toscana.it 
# Istituto di Biometeorologia - www.ibimet.cnr.it
# FBK  Fondazione Bruno Kessler - Trento
# Opensensors - Venezia
# Università di Parma 
# 
# Authors:
#
# Alfonso Crisci - a.crisci@ibimet.cnr.it; alfcrisci@gmail.com
# Valentina Grasso - grasso@lamma.rete.toscana.it
# Francesca De Chiara - francesca.dechiara@gmail.com  
# Luca Corsato - lucors@gmail.com  
# Mirko Mancin - mirkomancin90@gmail.com  
#
# CREDITS AND REFERENCES:
# 
#####################################################################################

#####################################################################################
# Set up working directory correspondent to server's user  eg. ardomino 

setwd("/home/ardomino")

#####################################################################################
# Set up timezone and date

Sys.setenv(TZ="Europe/Paris")
today=Sys.Date()


#####################################################################################
# Load code to set-up framework 

source("R_AO_libraries.r")
source("R_AO_utils.r")
library(Rmeteosalute)

#####################################################################################
# Load parameters  linked to social and sensor sources

ao_init=parse.ini("ao_data.ini")

#####################################################################################
# Fix library for R graphics unix environment - Fedora 19

options(bitmapType='cairo')
 
#####################################################################################
# Retrieve a key for forecast.io

fio.api.key=ao_init$AOmino_fioapikey$fio.api.key

#####################################################################################
# Retrieve location

AOnode_geolat=as.numeric(ao_init$AOnode_geolat$a)
AOnode_geolon=as.numeric(ao_init$AOnode_geolon$a)

#####################################################################################
# Get also istitutional regional forecast see 

get_weather_lamma();

#######################################################################
# name date of today

name_lamma_forecast_oggi=paste0("data/lamma_prato_",as.character(today),".rds")
name_node_forecast=paste0("data/forecast_node_",as.character(today),".rds")

#######################################################################
# Retrieve data and convert units


fio.list <- fio.forecast(fio.api.key, AOnode_geolat, AOnode_geolon, ssl.verifypeer =FALSE)
fio.list$daily.df$temperatureMin=FtoC(fio.list$daily.df$temperatureMin)            
fio.list$daily.df$temperatureMax=FtoC(fio.list$daily.df$temperatureMax)            
fio.list$daily.df$apparentTemperatureMin=FtoC(fio.list$daily.df$apparentTemperatureMin)    
fio.list$daily.df$apparentTemperatureMax= FtoC(fio.list$daily.df$apparentTemperatureMax)
fio.list$daily.df$dewPoint=FtoC(fio.list$daily.df$dewPoint)
fio.list$hourly.df$temperature=FtoC(fio.list$hourly.df$temperature)                     
fio.list$hourly.df$apparentTemperature=FtoC(fio.list$hourly.df$apparentTemperature)    
fio.list$hourly.df$dewPoint=FtoC(fio.list$hourly.df$dewPoint)

#######################################################################
# save images 5-day daily  forecast by forecast.io

TMAX=data.frame(data=as.character(as.Date(fio.list$daily.df$time[1:5])),Temperatura=fio.list$daily.df$temperatureMax[1:5])
TMAX$Previsione="T Max"
TMIN=data.frame(data=as.character(as.Date(fio.list$daily.df$time[1:5])),Temperatura=fio.list$daily.df$temperatureMin[1:5])
TMIN$Previsione="T Min"
d <- rbind(TMAX, TMIN)
p <- ggplot(d, aes(data,Temperatura, fill = Previsione)) + geom_bar(stat="identity",position = "dodge")+theme_bw()
ggsave(filename="images/previsioni_daily.jpg", plot=p)


#######################################################################
# save images hourly forecast by forecast.io

fio.hh <- ggplot(data=fio.list$hourly.df, aes(x=time, y=temperature))
fio.hh <- fio.hh + labs(y="Temperatura", x="", title="Previsione orarie by Forecast.io")
fio.hh <- fio.hh + geom_line(aes(y=temperature), color="red", size=0.25)+ scale_x_datetime(limits = c(as.POSIXct(today), as.POSIXct(today+3)),labels = date_format("%d-%H:00"))
fio.hh <- fio.hh + theme_bw()
ggsave(filename="images/previsioni_orarie.png", plot=fio.hh)

#######################################################################

saveRDS(fio.list,file=name_node_forecast)

