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

def delnode(jenkinsurl, nodename):
    J = Jenkins(jenkinsurl)
    J.delete_node(nodename)

if __name__ == '__main__':
    '''jenkinsurl = 'http://10.48.55.39:8898/'
    nodename = 'da02' '''
    try:
        jenkinsurl = sys.argv[1]
        nodename = sys.argv[2]
        delnode(jenkinsurl, nodename)
    except Exception as e:
        raise Exception(e)


