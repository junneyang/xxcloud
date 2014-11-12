#!/usr/bin/env python
#-*- coding: utf-8 -*-

from subprocess import call
from logLib import *
def msgSend(phonenum_list,msg_content):
    for phonenum in phonenum_list:
        cmd = "gsmsend -s emp01.baidu.com:15003 "+phonenum+"@"+"\""+msg_content+"\""
        print cmd
        Ret=call(cmd, shell=True)
        if(Ret != 0):
            logging.error("msgSend failed!")

if __name__ == '__main__':
    msgSend(['18665817689','15220056030'],u'TASK FINISHED:tuangou_brand badcase mining.')
