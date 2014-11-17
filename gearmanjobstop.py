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
gear_server = "cq01-rdqa-pool094.cq01.baidu.com"
gear_port = 8899

def gearmanjobstop(unique_id):
    datalist_info = {}
    output = None
    try:
        client = gear.Client()
        client.addServer(gear_server, port = gear_port)
        client.waitForServer()  # Wait for at least one server to be connected
        param={"id":unique_id}
        mysql=mysqlLib()
        datalist=mysql.query_task(param)
        mysql.close()
        jobname = datalist[0][3]
        status = datalist[0][5]
        build_number = datalist[0][6]

        if (int(status) == 2):
            build_params = {"name":jobname, "number":str(build_number)}
            job = gear.Job("stop:" + gear_server, json.dumps(build_params))
            client.submitJob(job)
            print("INFO, job aborte start")
            output = "INFO, job aborte start"
        else:
            print("INFO, job not running now")
            output = "INFO, job not running now"
    except Exception as e:
        print(e)
        output = "ERROR, " + str(e)
    finally:
        datalist_info['output'] = output
        return datalist_info

if __name__ == '__main__':
    unique_id = sys.argv[1]
    datalist_info = gearmanjobstop(unique_id)
    print json.dumps(datalist_info)


