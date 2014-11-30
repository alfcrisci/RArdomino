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

######################################################################################
# Set up twitter engine by OAuth 2.0

consumer_key <- ao_init$AOmino_oauth_consumer_key_tw$API_key
consumer_secret <- ao_init$AOnode_OA_consumer_secret_tw$API_secret
access_token <- ao_init$AOmino_OA__token_tw$Access_token
access_secret <- ao_init$AOmino_OA_token_secret_tw$Access_token_secret

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

######################################################################################
# Build dinamic file path and read data 

nome_file=paste0("contents/frasi_",classe,".rds")
frasi=readRDS(nome_file)
frase=frasi[which(frasi$ID==ID),]

if ( nrow(frase) !=0) { tweet(frase$Frase,mediaPath=paste0("images/",as.character(frase$ID),".png"));quit()}

######################################################################################
