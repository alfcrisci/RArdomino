################################################################################################
# PURPOSE:
# Procedure to read sensor cloud data.
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

#######################################################################

# try(get_sensor_data());
# try(get_acqualta_data());						  
