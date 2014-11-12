import gear
import json
import sys

from lib.logLib import *

def gearmanjob(gearman_srv_list, jobname, build_params):
    client = gear.Client()
    for item in gearman_srv_list:
        item_list = item.split(":")
        client.addServer(item_list[0], port = int(item_list[1]))
    client.waitForServer()  # Wait for at least one server to be connected
    job = gear.Job('build:' + jobname, json.dumps(build_params))
    client.submitJob(job)

if __name__ == '__main__':
    try:
        #gearman_srv_list = ['127.0.0.1:8899']
        gearman_srv_list = sys.argv[1].split(",")
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
                '''print build_params[item]
                print str(build_params[item])'''
                build_params[item] = json.dumps(build_params[item])
        #print build_params

        gearmanjob(gearman_srv_list, jobname, build_params)
    except Exception as e:
        print(e)

