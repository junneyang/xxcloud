import gearman
import time
import json

from addtask import addtask
from lib.cmdLib import *

def gearmanwork(gearman_worker, gearman_job):
    params = {"RET":"INTERNAL ERROR"}
    try:
        params = json.loads(gearman_job.data)
        '''addtask(params['JenkinsURL'], params['JobName'], params['BuildParams'])'''
        cmdstr = "python addtask.py " + params['JenkinsURL'] + " " + params['JobName'] + " '" + json.dumps(params['BuildParams']) + "'"
        print cmdstr
        status,output=cmd_execute(cmdstr)
    except Exception as e:
        print(e)
    finally:
        print json.dumps(params)
        return json.dumps(params)

if __name__ == '__main__':
    try:
        worker = gearman.GearmanWorker(["127.0.0.1:8899"])
        worker.register_task('gearmanwork', gearmanwork)
        worker.work()
    except Exception as e:
        print(e)

