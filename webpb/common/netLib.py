#!/usr/bin/env python
#-*- coding: utf-8 -*-
#-------------------------------------------------------------------------------
# Name:        模块1
# Purpose:
#
# Author:      yangjun03
#
# Created:     25/11/2014
# Copyright:   (c) yangjun03 2014
# Licence:     <your licence>
#-------------------------------------------------------------------------------
import sys, socket

def gethostname():
    hostname = socket.gethostname()
    return hostname

def getipaddrs(hostname):
    result = socket.getaddrinfo(hostname, None, 0, socket.SOCK_STREAM)
    return [x[4][0] for x in result]

if __name__ == '__main__':
    hostname = gethostname()
    try:
        print "IP addresses:", ", ".join(getipaddrs(hostname))
    except socket.gaierror, e:
        print "Couldn't not get IP addresses:", e

