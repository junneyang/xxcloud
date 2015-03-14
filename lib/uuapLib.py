#!/usr/bin/env python
#icas.py
import urllib2
from urllib import urlencode
import re, os, traceback

class uuapLib(object):
    def __init__(self, username, password, url="https://uuap.baidu.com/", service="your-service"):
        self.url = url.rstrip("/")
        self.username = username
        self.password = password
        self.service = service

        self.__tgtpath = "/rest/tickets"
        self.__TGT = self.get_TGT()

        self.__stpath = "/rest/tickets/%s" %self.__TGT
        self.__ST = self.get_ST()
        self.__valipath = "/serviceValidate?service=%s&ticket=%s" %(self.service, self.__ST)

    def get_TGT(self,):
        data = urlencode( {'username':self.username, 'password':self.password} )
        try:
            req = urllib2.Request(self.url + self.__tgtpath, data)
            res = urllib2.urlopen(req)
        except urllib2.URLError, e:
            if hasattr(e, 'reason'):
                print "Reason:", e.reason
            elif hasattr(e,'code'):
                if e.code == 201:
                    page = e.read()
                    tgt_pattern = '''<form action=\"%s%s(TGT-[^\"]+)\" ''' %(self.url + self.__tgtpath, os.sep)
                    m = re.search(tgt_pattern, page)
                    if m:
                        return m.group(1)
                    else:
                        print "TGT not matched"
                        return None
            else:
                return None
        return None


    def get_ST(self):
        data = urlencode( {'service':self.service} )
        try:
            req = urllib2.Request(self.url + self.__stpath, data)
            res = urllib2.urlopen(req)
            return res.read()
        except:
            print traceback.format_exc()
        return None

    def get_user(self):
        if self.__ST is not None:
            try:
                req = urllib2.Request(self.url + self.__valipath)
                res = urllib2.urlopen(req)
                page = res.read()
                user_pattern = '''<cas:user>%s</cas:user>''' %self.username
                m = re.search(user_pattern, page)
                if m:
                    return self.username
            except:
                print traceback.format_exc()
        return None

if __name__ =="__main__":
    u = uuapLib('XXX','XXX',service='http%3A%2F%2F10.81.12.113%3A8088%2Faccounts%2Flogin%2F%3Fnext%3Dhttp%253A%252F%252Fcq01-rdqa-pool094.cq01.baidu.com%253A8080%252Fbadcase%252Fmainframework%252F')
    r = u.get_user()
    if r is not None:
        print "login ok"
    else:
        print "login fail"
