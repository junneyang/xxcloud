#!/usr/bin/env python
#-*- coding: utf-8 -*-
import sys
import os
import time
import json

from lib.logLib import *
from lib.cmdLib import *
from lib.sftpLib import *

import jenkinsapi
from jenkinsapi.jenkins import Jenkins

def addnode(jenkinsurl, nodename, remote_fs, ip, port, username, password):
    J = Jenkins(jenkinsurl)
    node = J.create_node(nodename, num_executors = 1, node_description = None, remote_fs = remote_fs, labels = nodename)
    put_file(ip, port, username, password, "./jenkins/slave.jar", remote_fs + "/" + "slave.jar")

    cmdstr = "cd " + remote_fs + " &&java -jar slave.jar -jnlpUrl " + jenkinsurl + "computer/" + nodename + "/slave-agent.jnlp"
    async_ssh_cmd(ip, port, username, password, cmdstr)
    #time.sleep(5)
    is_online = False
    while(is_online is False):
        is_online = node.is_online()
        time.sleep(1)

if __name__ == '__main__':
    '''jenkinsurl = 'http://10.48.55.39:8898/'
    nodename = 'da02'
    remote_fs = '/home/map/workspace'
    ip = '10.99.36.61'
    port = 22
    username = 'map'
    password = 'mapapptest' '''
    try:
        jenkinsurl = sys.argv[1]
        nodename = sys.argv[2]
        remote_fs = sys.argv[3]
        ip = sys.argv[4]
        port = int(sys.argv[5])
        username = sys.argv[6]
        password = sys.argv[7]
        addnode(jenkinsurl, nodename, remote_fs, ip, port, username, password)
    except Exception as e:
        raise Exception(e)

