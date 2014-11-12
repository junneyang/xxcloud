#!/usr/bin/env python
#-*- coding: utf-8 -*-
import sys
import os
import time
import json
import types

from lib.logLib import *
from lib.cmdLib import *
from lib.sftpLib import *
from lib.mysqlLib import *

import jenkinsapi
from jenkinsapi.jenkins import Jenkins
from jenkinsapi.jobs import Jobs
from jenkinsapi.job import Job
from jenkinsapi.build import Build

def addtask(jenkinsurl, jobname, build_params):
    mysql = mysqlLib()
    try:
        #任务初始化，0
        param = (jenkinsurl, jobname, json.dumps(build_params), 0)
        n,last_id = mysql.add_task(param)
        print(u"#任务初始化，0")

        J = Jenkins(jenkinsurl)
        jobs = Jobs(J)
        job = jobs[jobname]
        invoke = job.invoke(build_params=build_params)

        '''is_queued = invoke.is_queued()
        while(is_queued is False):
            time.sleep(1)
            is_queued = invoke.is_queued()
        #任务排队中，1
        param=(1, last_id)
        mysql.update_task_status(param)
        print(u"#任务排队，1")

        is_running = invoke.is_running()
        while(is_running is False):
            time.sleep(1)
            is_running = invoke.is_running()
        #任务执行中，2
        param=(2, last_id)
        mysql.update_task_status(param)
        print(u"#任务执行，2")'''


        #更新任务 build_number
        build_number = invoke.get_build_number()
        param=(build_number, last_id)
        mysql.update_task_build_number(param)
        print build_number


        '''is_running = invoke.is_running()
        while(is_running is True):
            time.sleep(1)
            is_running = invoke.is_running()
        #任务执行完成，3
        param=(3, last_id)
        mysql.update_task_status(param)
        print(u"#任务完成，3")'''

    except Exception as e:
        logging.ERROR(e)
        #任务执行异常，4
        param=(4, last_id)
        mysql.update_task_status(param)
        print(u"#任务异常，4")
    finally:
        mysql.close()

if __name__ == '__main__':
    #jenkinsurl = 'http://10.48.55.39:8898/'
    '''jobname = 'addnode'
    build_params = {'JenkinsURL':'http://10.48.55.39:8898/','NodeName':'da02','WorkPath':'/home/map/workspace','IP':'10.99.36.61','PORT':'22','UserName':'map','PassWord':'mapapptest'}
    '''
    #jobname = 'pbdownload'
    #build_params = {'ProtoFileSVNPath':'https://svn.baidu.com/app-test/search/lbs-stat/trunk/upps_test/jenkinsFramework/protobuf/proto',
    #                'IPPort':'10.48.55.39:22','UserName':'yangjun03','PassWord':'Admin2123','ToolType':'pbrpcclient','RemotePath':'/home/users/yangjun03/workspace'}
    #build_number = addtask(jenkinsurl, jobname, build_params)
    #result = get_result(jenkinsurl, jobname, build_number)
    #print result

    jenkinsurl = sys.argv[1]
    jobname = sys.argv[2]
    build_params = json.loads(sys.argv[3])
    for item in build_params:
        '''try:
            if(build_params[item]):
                #tmpstr = json.dumps(build_params[item])
                print build_params[item]
        except Exception as e:
            pass'''
        if(type(build_params[item]) == list or type(build_params[item]) == dict):
            print build_params[item]
            print str(build_params[item])
            build_params[item] = json.dumps(build_params[item])
    print build_params
    addtask(jenkinsurl, jobname, build_params)

