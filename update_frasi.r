################################################################################################
# PURPOSE:
# Procedure to read and update sentences from a cloud googlesheet 
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

#####################################################################################
# Load parameters  linked to social and sensor sources

ao_init=parse.ini("ao_data.ini")

#####################################################################################
# Update textual contents
# Example: 
# Sheet of sentences "https://docs.google.com/spreadsheets/d/1ecQyo1d8RS4VRY6Bq0pSnHpVR4Df78QKeIc45H9f8Xc/pubhtml?gid=0&single=true",sheet=1)
# Palisesto scheme   "https://docs.google.com/spreadsheets/d/1ecQyo1d8RS4VRY6Bq0pSnHpVR4Df78QKeIc45H9f8Xc/pubhtml?gid=0&single=true",sheet=2)


						
tryCatch(
        {
            
            AO_sets=readSpreadsheet(ao_init$AOmino_frase$frasi,sheet=1)
            classi=unique(AO_sets$Classe)
			for ( i in seq(classi)) {

                          saveRDS(AO_sets[which(AO_sets$Classe==classi[i]),],file=paste0("contents/frasi_",as.character(classi[i]),".rds"))
              
			            }
        },
        error=function(cond) {
		
            message("Google Sheet not available!")
        },
        
		finally={
             message("Tutto bene!")
        }
        )		