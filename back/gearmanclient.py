import gearman
import json
import sys

def gearmanclient(jenkinsurl, jobname, build_params):
    gm_client = gearman.GearmanClient(['127.0.0.1:8899'])
    params = {'JenkinsURL':jenkinsurl, 'JobName':jobname, 'BuildParams':build_params}
    paramsstr = json.dumps(params)
    submitted_job_request = gm_client.submit_job("gearmanwork", paramsstr, wait_until_complete = False, background = True)
    #print submitted_job_request.result


if __name__ == '__main__':
    try:
        jenkinsurl = sys.argv[1]
        jobname = sys.argv[2]
        build_params = json.loads(sys.argv[3])
        gearmanclient(jenkinsurl, jobname, build_params)
    except Exception as e:
        print(e)
