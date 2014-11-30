################################################################################################
# PURPOSE:
# Procedure to send regular twitter status by using TwitteR package.
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
# Set up argument readings for batch works 

args<-commandArgs(TRUE);
classe=args[1]
ID=args[2]

######################################################################################

library(Rmeteosalute)
source("R_AO_libraries.r")
source("R_AO_utils.r")

#####################################################################################
# Set up timezone and date

Sys.setenv(TZ="Europe/Paris")
today=Sys.Date()


#####################################################################################
# Load code to set-up framework 


source("R_AO_libraries.r")
source("R_AO_utils.r")

#####################################################################################
# Load parameters  linked to social and sensor sources

ao_init=parse.ini("ao_data.ini")

#####################################################################################

firenze_wunder_ID=ao_init$AOmino_weather$firenze_wunder_ID
prato_wunder_ID=ao_init$AOmino_weather$prato_wunder_ID
AOnode_geolat=as.numeric(ao_init$AOnode_geolat$a)
AOnode_geolon=as.numeric(ao_init$AOnode_geolon$a)

###################################################################################
# Build link with openstreet map links at various scale


link_mappa_16=paste0("www.openstreetmap.org/#map=16/",AOnode_geolat,"/",AOnode_geolon)
link_mappa_17=paste0("www.openstreetmap.org/#map=17/",AOnode_geolat,"/",AOnode_geolon)
link_mappa_15=paste0("www.openstreetmap.org/#map=15/",AOnode_geolat,"/",AOnode_geolon)

###################################################################################
# Shortenize link for map using google API

gekey=ao_init$AOmino_google_key$gekey
s_link_mappa_16=rshortenize(link_mappa_16,"http://www.lamma.rete.toscana.it/previ/ita/xml/comuni_web/dati/",gekey)

######################################################################################
# Set up twitter engine by OAuth 2.0

consumer_key <- ao_init$AOmino_oauth_consumer_key_tw$API_key
consumer_secret <- ao_init$AOnode_OA_consumer_secret_tw$API_secret
access_token <- ao_init$AOmino_OA__token_tw$Access_token
access_secret <- ao_init$AOmino_OA_token_secret_tw$Access_token_secret

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

######################################################################################
# Build dinamic file path and read data 

nome_file_frasi=paste0("contents/frasi_","biometeo",".rds")
name_meteo_prato=paste0("data/dati_prato_",prato_wunder_ID,"_",as.character(today),".rds")
nome_file_sensore_last="data/last_data_sensor.rds"
name_meteo_prato_last=paste0("data/dati_prato_",prato_wunder_ID,"_",as.character(today),"_last.rds")

frasi=readRDS(nome_file_frasi)
last_data_sensore=readRDS(nome_file_sensore_last)
last_data_meteo=readRDS(name_meteo_prato_last)
data_meteo=readRDS(name_meteo_prato)
clo_meteo=readRDS(name_meteo_prato)

######################################################################################
# Random sampling for data parossism to create engaging tweet

piut=sample(-10:10,1,replace=T)
umipiu=sample(-20:20,1,replace=T)
tappdipiu=sprintf("%.1f",indoor_tapp(last_data_sensore$temp+piut,last_data_sensore$hum))
rhdipiu=sprintf("%.1f",indoor_tapp(last_data_sensore$temp,last_data_sensore$hum+umipiu))

######################################################################################
# define data summaries of day

delta=sprintf("%.1f",abs(last_data_meteo$TemperatureC-last_data_sensore$temp))
tmaxoggi=max(data_meteo$TemperatureC)
tminoggi=min(data_meteo$TemperatureC)
comfort=pmv_indoor_class(last_data_sensore$temp,last_data_sensore$hum,0.5,last_data_sensore$temp,70,0,1)
clothing=clothing_ens(last_data_sensore$temp,last_data_sensore$hum)

#####n#################################################################################
# Data sentences string replacing         

frasi$Frase=gsub("TEMPCITTA",paste0(last_data_meteo$TemperatureC," g"),frasi$Frase,ignore.case = FALSE,fixed=TRUE)
frasi$Frase=gsub("CITTA",ao_init$AOnode_address$a,frasi$Frase,ignore.case = FALSE,fixed=TRUE)
frasi$Frase=gsub("TEMP",paste0(last_data_sensore$temp," gradi"),frasi$Frase,ignore.case = FALSE,fixed=TRUE)
frasi$Frase=gsub("RH",paste0(last_data_sensore$hum," %"),frasi$Frase,ignore.case = FALSE,fixed=TRUE)
frasi$Frase=gsub("DELTAINDOOR",paste0(delta," gradi"),frasi$Frase,ignore.case = FALSE,fixed=TRUE)
frasi$Frase=gsub("GRADIPIU",paste0(as.character(piut)," g"),frasi$Frase,ignore.case = FALSE,fixed=TRUE)
frasi$Frase=gsub("PERCPIU",paste0(as.character(umipiu)," %"),frasi$Frase,ignore.case = FALSE,fixed=TRUE)
frasi$Frase=gsub("TAPPIUT",paste0(tappdipiu," gradi"),frasi$Frase,ignore.case = FALSE,fixed=TRUE)
frasi$Frase=gsub("TAPPRH",paste0(rhdipiu," gradi"),frasi$Frase,ignore.case = FALSE,fixed=TRUE)
frasi$Frase=gsub("TMAXOUT",paste0(tmaxoggi," gradi"),frasi$Frase,ignore.case = FALSE,fixed=TRUE)
frasi$Frase=gsub("TMINOUT",paste0(tminoggi," gradi"),frasi$Frase,ignore.case = FALSE,fixed=TRUE)
frasi$Frase=gsub("TMINOUT",paste0(tminoggi," gradi"),frasi$Frase,ignore.case = FALSE,fixed=TRUE)
frasi$Frase=gsub("DISAGIOCOND",tolower(comfort$classe),frasi$Frase,ignore.case = FALSE,fixed=TRUE)
frasi$Frase=gsub("TAPP",paste0(sprintf("%.1f",last_data_sensore$tapp)," gradi"),frasi$Frase,ignore.case = FALSE,fixed=TRUE)
frasi$Frase=gsub("TAPP",paste0(sprintf("%.1f",last_data_sensore$tapp)," gradi"),frasi$Frase,ignore.case = FALSE,fixed=TRUE)
frasi$Frase=gsub("LINKMAPPA",s_link_mappa_16,frasi$Frase,ignore.case = FALSE,fixed=TRUE)

######################################################################################
# Sending status messages in function of comunication 

if ( classe=="realtime") { r=sample(1:nrow(frasi),1,replace=T);tweet(frasi$Frase[r]);quit()}


if ( classe=="biometeo") { random=r=sample(1:6,1,replace=T)
							if (random ==6) {  tweet(clothing$frase,mediaPath=paste0("images/",as.character(clothing$nomeimg)));quit()}
							if (random ==5) {  tweet(comfort$frase);quit()}
							if (random <5) { r=sample(1:nrow(frasi),1,replace=T);
							        tweet(frasi$Frase[r]);quit()}
						 }
						 
if ( classe=="weather") { random=r=sample(1:7,1,replace=T);
                          if (random ==7) {  tweet("Un confronto fra Prato e Firenze #ardOmino #digit14",mediaPath=paste0("images/last_firenze_vs_prato.png"));quit()}
                          if (random ==6) {  tweet("Le previsioni di massima e minima per i prox gg a Prato #ardOmino",mediaPath=paste0("images/previsioni_daily_5.jpg"));quit()}
						  if (random ==5) {  tweet("Il profilo termico giornaliero a Prato  #ardOmino #digit14",mediaPath=paste0("images/last_weather_prato.png"));quit()}
						  if (random <5) { r=sample(1:nrow(frasi),1,replace=T);tweet(frasi$Frase[r]);quit()}
						 } 
						 
						 
if ( classe=="engagement") { 
                             r=sample(1:nrow(frasi),1,replace=T)
							 if (frasi$note[r] =="foto") {  tweet(frase$Frase[r],mediaPath=paste0("images/",as.character(frase$ID),".png"));quit()}
							 else
							    {tweet(frasi$Frase[r]);quit()}
						 }
						 
if ( classe=="history") { 
                         tweet("Il profilo dei dati termici misurati dal sensore #ardOmino #digit14",mediaPath=paste0("images/last_day_sensor.png"));
						 quit() 
						 }

if ( classe=="proverbial") { r=sample(1:nrow(frasi),1,replace=T)
                             tweet(frasi$Frase[r],mediaPath=paste0("images/proverbi.png"));
						     quit();
						 }
if ( classe=="acqualta") { tweet("Gli ultimi dati sopra i 70 cm di #acqualta #digit14",mediaPath=paste0("images/","last_acqualta.png"));quit()}
						 
######################################################################################
