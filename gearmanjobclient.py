#!/usr/bin/env python
#-*- coding: utf-8 -*-
import sys
import os
import time
import json

from lib.logLib import *
from lib.cmdLib import *
from lib.sftpLib import *
from lib.mysqlLib import *

import jenkinsapi
from jenkinsapi.jenkins import Jenkins
from jenkinsapi.jobs import Jobs
from jenkinsapi.job import Job
from jenkinsapi.build import Build

import gear
gear_server = "127.0.0.1"
gear_port = 8899

def addtask(username, jenkinsurl, jobname, specifynode, build_params):
    mysql = mysqlLib()
    url = None
    try:
        param = (username ,jenkinsurl, jobname, json.dumps(build_params), 0)
        n,last_id = mysql.add_task(param)
        print(u"INFO, job initial, 0")
        unique_id = last_id
        if (specifynode == 1):
            J = Jenkins(jenkinsurl)
            jobs = Jobs(J)
            job = jobs[jobname]
            build_params['UNIQUE_ID'] = unique_id
            invoke = job.invoke(build_params=build_params)
            print("INFO, specifynode true")
        elif (specifynode == 0):
            client = gear.Client()
            client.addServer(gear_server, port = gear_port)
            client.waitForServer()  # Wait for at least one server to be connected
            build_params['UNIQUE_ID'] = unique_id
            job = gear.Job('build:' + jobname, json.dumps(build_params))
            client.submitJob(job)
            print("INFO, specifynode false")
        param=(1, unique_id)
        mysql.update_task_status(param)
        print(u"INFO, job submit, 1")
        print(u"INFO, job unique id :" + str(unique_id))
        url = "http://10.48.55.39:8889/pb/jenkins/status/?job=" + str(unique_id)
        print(u"INFO, you could link " + url + " to trace the job status")
    except Exception as e:
        print(e)
    finally:
        mysql.close()
        return url

if __name__ == '__main__':
    '''unique_id = '1'
    username = 'yangjun03'
    password = 'yangjun03'
    jenkinsurl = 'http://10.48.55.39:8898/'
    jobname = 'pbrpcclient'
    build_params = {
    	"ClientNode":"yangjun03",
    	"WorkPath":"/home/users/yangjun03/workspace",
    	"PBTYPE":"PUBLIC-PBRPC",
    	"IPPORT":"127.0.0.1:7788",
    	"ServiceName":"lbs.da.openservice.ItemService",
    	"MethodName":"GetItemsByItem",
            "TestData":[
    	{
    		"header": {
    			"subservice":"sub",
    			"secretkey": "pass",
    			"servicekey": "key1"
    		},
    		"algorithmId": "topic_rev_poi",
    		"item_ids": ["9977193541978760286"]
    	},
    	{
    		"header": {
    			"subservice":"sub",
    			"secretkey": "pass",
    			"servicekey": "key1"
    		},
    		"algorithmId": "topic_rev_poi",
    		"item_ids": ["9977193541978760286"]
    	}
    ]
    }'''


    username = sys.argv[1]
    jenkinsurl = sys.argv[2]
    jobname = sys.argv[3]
    specifynode = int(sys.argv[4])
    build_params = json.loads(sys.argv[5])
    for item in build_params:
        if(type(build_params[item]) == list or type(build_params[item]) == dict):
            build_params[item] = json.dumps(build_params[item])
    #print build_params
    addtask(username, jenkinsurl, jobname, specifynode, build_params)

