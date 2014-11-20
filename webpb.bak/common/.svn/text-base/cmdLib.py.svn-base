#!/usr/bin/env python
#-*- coding: utf-8 -*-
from logLib import *
import subprocess
import commands

def cmd_execute(cmd,mode="commands"):
    logging.debug("cmdStr:"+cmd)
    if(mode == "subprocess"):
        ps=subprocess.Popen(cmd,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
        ps.wait()
        stdout,stderror=ps.communicate()
        return stdout,stderror
    if(mode == "commands"):
        status,output=commands.getstatusoutput(cmd)
        return status,output

if __name__ == "__main__":
    status,output=cmd_execute("ps -ef | grep redis-server | grep -v grep | wc -l")
    print status
    print output

