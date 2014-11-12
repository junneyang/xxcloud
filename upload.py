#!/usr/bin/env python
#-*- coding: utf-8 -*-
import sys
import os
import time
import json


from lib.logLib import *
from lib.cmdLib import *
from lib.sftpLib import *

def upload(ip, port, username, password, pbtype, remotepath):
    workspace = "/home/users/yangjun03/protobuf/workspace/app-test/search/lbs-stat/upps_test/jenkinsFramework/protobuf/"
    tarname = "pb.tar.gz"
    if(pbtype == "pbrpcclient"):
        cmdstr="cd " + workspace + " && mkdir -p pb && cp -rf case conf data log pbrpcclient pbunittest.py proto pub README ./pb/ && find ./pb/ -type d -name '.svn' | xargs rm -rf && tar -czvf pb.tar.gz pb"
        status,output=cmd_execute(cmdstr)
    if(pbtype == "pbrpcbenchmark"):
        cmdstr="cd " + workspace + " && mkdir -p pb && cp -rf conf data log pbrpcbenchmark proto README ./pb/ && find ./pb/ -type d -name '.svn' | xargs rm -rf && tar -czvf pb.tar.gz pb"
        status,output=cmd_execute(cmdstr)
    ssh_cmd(ip, port, username, password, "mkdir -p " + remotepath)
    put_file(ip, port, username, password, workspace + tarname, remotepath + "/" + tarname)
    ssh_cmd(ip , port, username, password, "cd " + remotepath + " && tar -xzvf " + tarname)
    cmdstr="cd " + workspace + " && rm -rf ./pb && rm pb.tar.gz"
    status,output=cmd_execute(cmdstr)

if __name__ == "__main__" :
    try:
        ipport = sys.argv[1]
        ip = ipport.split(":")[0]
        port = int(ipport.split(":")[1])
        username = sys.argv[2]
        password = sys.argv[3]
        pbtype = sys.argv[4]
        remotepath = sys.argv[5]
        upload(ip, port, username, password, pbtype, remotepath)
    except Exception as e:
        raise Exception(e)

