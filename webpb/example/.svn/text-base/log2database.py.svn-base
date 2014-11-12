#-*- coding: utf-8 -*-
#!/usr/bin/env python
import sys
import os
sys.path.append("%s/../"%os.path.dirname(os.path.realpath(__file__)))
from common.mysqlLib import mysqlLib
from common.cmdLib import cmd_execute

if __name__ == "__main__":
    cmdstr=""" free | grep 'buffers/cache:' | awk -F' ' '{ print strftime("%H:%M:%S",systime())"\t",$3"\t",$4 }' """
    logstr=''
    mysql=mysqlLib()
    for i in xrange(10):
        status,output=cmd_execute(cmdstr)
        print output
        logstr+=output
        cmdstr="""python ./example/traditional_testCase.py"""
        status,output=cmd_execute(cmdstr)
        print output
        logstr+=output
    #logstr=logstr.replace("\n","<br/>")
    mysql.update_test_management_log((logstr,66))
    testlist=mysql.query_test_management({"id":66})
    print testlist[0][7]
    mysql.close()
