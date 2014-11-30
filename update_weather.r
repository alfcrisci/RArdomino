################################################################################################
# PURPOSE:
# Procedure to read meteo cloud data: example made for two weather station by wunderground.com platform 
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
# Retrieve geolocation data   

AOnode_geolat=as.numeric(ao_init$AOnode_geolat$a)
AOnode_geolon=as.numeric(ao_init$AOnode_geolon$a)

#####################################################################################
# Retrieve data by wunderground.com data  network  

firenze_wunder_ID=ao_init$AOmino_weather$firenze_wunder_ID
prato_wunder_ID=ao_init$AOmino_weather$prato_wunder_ID


#####################################################################################
# Create names to store datafile in serial R object: 


name_meteo_firenze=paste0("data/dati_firenze_",firenze_wunder_ID,"_",as.character(today),".rds")
name_meteo_prato=paste0("data/dati_prato_",prato_wunder_ID,"_",as.character(today),".rds")


name_meteo_firenze_last=paste0("data/dati_firenze_",firenze_wunder_ID,"_",as.character(today),"_last.rds")
name_meteo_prato_last=paste0("data/dati_prato_",prato_wunder_ID,"_",as.character(today),"_last.rds")

clo_firenze_last=paste0("data/clo_firenze_",firenze_wunder_ID,"_last.rds")
clo_prato_last=paste0("data/clo_prato_",prato_wunder_ID,"_last.rds")

####################################################################################################################
# Checking data wunderground availability


data_okay_FI <- checkDataAvailability(firenze_wunder_ID, today,station_type="id")
data_okay_PO <- checkDataAvailability(prato_wunder_ID, today,station_type="id")

if (data_okay_PO ==1) { dati_prato_oggi <- wunder_station_daily(prato_wunder_ID, today)}
if (data_okay_FI ==1) { dati_firenze_oggi <- wunder_station_daily(firenze_wunder_ID, today)}

####################################################################################################################
# Inizialization biometerological slot

dati_prato_oggi$tapp=NA;
dati_prato_oggi$wind=NA;

####################################################################################################################
# Calculation of biometeorological index by Rmeteosalute package

for ( i in 1:nrow(dati_prato_oggi)){
      dati_prato_oggi$wind[i]=0

      if (!is.na(dati_prato_oggi$WindSpeedKMH[i])) 
      {dati_prato_oggi$wind[i]=dati_prato_oggi$WindSpeedKMH[i]/3.6};

      dati_prato_oggi$tapp[i]=outdoor_shade(dati_prato_oggi$TemperatureC[i],dati_prato_oggi$Humidity[i],dati_prato_oggi$wind[i])

     }


dati_firenze_oggi$tapp=NA;
dati_firenze_oggi$wind=NA;

for ( i in 1:nrow(dati_firenze_oggi)){
      dati_firenze_oggi$wind[i]=0

      if (!is.na(dati_firenze_oggi$WindSpeedKMH[i])) 
      {dati_firenze_oggi$wind[i]=dati_firenze_oggi$WindSpeedKMH[i]/3.6};

      dati_firenze_oggi$tapp[i]=outdoor_shade(dati_firenze_oggi$TemperatureC[i],dati_firenze_oggi$Humidity[i],dati_firenze_oggi$wind[i])

     }


####################################################################################################################
# Create time series object 

dati_firenze_xts=xts(dati_firenze_oggi,dati_firenze_oggi$Time)
dati_prato_xts=xts(dati_prato_oggi,dati_prato_oggi$Time)

####################################################################################################################
# Define colors for line graph

myColors=c("darkblue","red")


####################################################################################################################
# Create  biometerological current images of wether station data and comparison to save in  directory images


png("images/last_weather_firenze.png")

plot(dati_firenze_xts[,"TemperatureC"], xlab = "Ora", ylab = "Temperatura (Gradi Celsius)",
     main = paste0("Termometria Firenze ",today,"\n Dati: Wunderground ID ITOSCANA194"), 
	 ylim = c(min(dati_firenze_oggi$TemperatureC)-2, max(dati_firenze_oggi$TemperatureC)+5), 
	 major.ticks= "hours",
	 minor.ticks = FALSE, 
	 col = "darkblue",
	 major.format="%H:00");
     lines(x = dati_firenze_xts[,"tapp"], col = "red")
    legend(x = 'topleft', legend = c("Temperatura aria", "Temperatura Apparente"),
      lty = 1, col = myColors)

dev.off()

png("images/last_weather_prato.png")
plot(dati_prato_xts[,"TemperatureC"], xlab = "Ora", ylab = "Temperatura (Gradi Celsius)",
     main = paste0("Termometria prato ",today,"\n Dati: Wunderground ID ITOSCANA124"), 
	 ylim = c(min(dati_prato_oggi$TemperatureC)-2, max(dati_prato_oggi$TemperatureC)+5), 
	 major.ticks= "hours",
	 minor.ticks = FALSE, 
	 col = "darkblue",
	 major.format="%H:00");
     lines(x = dati_prato_xts[,"tapp"], col = "red")
    legend(x = 'topleft', legend = c("Temperatura aria", "Temperatura Apparente"),
      lty = 1, col = myColors)

dev.off()

png("images/last_firenze_vs_prato.png")
plot(dati_prato_xts[,"tapp"], xlab = "Ora", ylab = "Temperatura (Gradi Celsius)",
     main = paste0("Temperatura percepita Prato vs Firenze t\n",today," Dati: Wunderground.com"), 
	 ylim = c(min(dati_prato_oggi$TemperatureC)-2, max(dati_prato_oggi$TemperatureC)+5), 
	 major.ticks= "hours",
	 minor.ticks = FALSE, 
	 col = "darkblue",
	 major.format="%H:00");
     lines(x = dati_firenze_xts[,"tapp"], col = "red")
     legend(x = 'topleft', legend = c("Prato Temperatura percepita", "Firenze Temperatura percepita"),
      lty = 1, col = myColors)

dev.off()

#######################################################################
# Calculate biometeorological data following "Come Vestirsi" scheme of Rmeteosalute

last_prato_data=dati_prato_oggi[nrow(dati_prato_oggi),]
last_firenze_data=dati_firenze_oggi[nrow(dati_firenze_oggi),]
last_clothing_prato=clothing_ens(last_prato_data$TemperatureC,last_prato_data$Humidity)
last_clothing_firenze=clothing_ens(last_firenze_data$TemperatureC,last_firenze_data$Humidity)

#######################################################################
# Store updated data

saveRDS(dati_firenze_oggi,file=name_meteo_firenze)
saveRDS(dati_prato_oggi,file=name_meteo_prato)
saveRDS(last_prato_data,file=name_meteo_firenze_last)
saveRDS(last_firenze_data,file=name_meteo_prato_last)	
saveRDS(last_clothing_prato,file=clo_prato_last)	
saveRDS(last_clothing_firenze,file=clo_firenze_last)				
#######################################################################
