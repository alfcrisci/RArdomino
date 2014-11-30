#!/usr/bin/python
# -*- coding: utf-8 -*- 

################################################################################################
# PURPOSE:
# Procedure to schedule sending message 
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

import os
import stat  
import sys
import logging
import subprocess 
from StringIO import StringIO
from datetime import datetime, timedelta, time, date
from time import sleep
from apscheduler.scheduler import Scheduler
import logging

##############################################################

logging.basicConfig(filename='ardomino.log',level=logging.DEBUG)

##############################################################

def update_frasi():
    subprocess.call(['Rscript --vanilla update_frasi.r'],shell=True)
    print >> test_log, "Lancio aggiornamento frasi."

def update_sensors():
    subprocess.call(['Rscript --vanilla update_sensor.r'],shell=True)
    print >> test_log, "Lancio aggiornamento sensori."

def update_weather():
    subprocess.call(['Rscript --vanilla update_weather.r'],shell=True)
    print >> test_log, "Lancio aggiornamento dati_meteo."

def update_forecast():
    subprocess.call(['Rscript --vanilla update_forecast.r'],shell=True)
    print >> test_log, "Lancio aggiornamento previsioni."


def send_message(classe,ID):
    subprocess.call(['Rscript', 'send_message.r', classe,ID], shell=True)

def send_message_p(classe):
    subprocess.call(['Rscript', 'send_message_interval.r', classe], shell=True)


def schedule_job(sched, function, periodicity, start_time,args):
    sched.add_interval_job(function, seconds=periodicity, start_date=start_time,args=args)




##############################################################

if __name__ == "__main__":
	
	
	#########################################################
	# Palinsesto ArOmino
	
	sched = Scheduler()
	sched.configure({'apscheduler.daemonic': False})
	sched.start()        # start the scheduler
	
    #UPDATE

	schedule_job(sched, update_frasi, 600, '2014-09-19 22:00:00',args=[''])
	schedule_job(sched, update_sensors, 300, '2014-09-19 22:00:00',args=[''])
	schedule_job(sched, update_weather, 3000, '2014-09-19 22:00:00',args=[''])
	schedule_job(sched, update_forecast, 86400, '2014-09-20 8:00:00',args=[''])
    #PERIODIC

	
	schedule_job(sched, send_message_p, 1800,'2014-09-20 8:10:00',args=['realtime'])
	schedule_job(sched, send_message_p, 1800,'2014-09-20 8:10::00',args=['history'])
	schedule_job(sched, send_message_p, 1800,'2014-09-20 8:10::00',args=['weather'])
	schedule_job(sched, send_message_p, 1800,'2014-09-20 8:10::00',args=['biometeo'])
	schedule_job(sched, send_message_p, 1800,'2014-09-20 8:10::00',args=['engagement'])
	schedule_job(sched, send_message_p, 1800,'2014-09-20 8:10::00',args=['proverbial'])
      
	#FIXED
        
	job_I1=sched.add_date_job(send_message,'2014-09-20 8:01:00',args=['identity','I1'])
	job_I2=sched.add_date_job(send_message,'2014-09-20 9:01:00',args=['identity','I2'])
	job_I2=sched.add_date_job(send_message,'2014-09-20 11:00:00',args=['identity','I3'])
	job_aqualta=sched.add_date_job(send_message,'2014-09-20 9:05:00',args=['acqualta','AQ1'])
  
  
	while True:
		pass
		

##############################################################
#		
			