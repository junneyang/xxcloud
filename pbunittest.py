#!/usr/bin/env python
#-*- coding: utf-8 -*-
import sys
import codecs
import json
import unittest

from pub.cmdLib import *
from pub.logLib import *
from pub.parsetestcaseLib import *

filepath="./case/items.test.case"
testcase=get_testcase(filepath)
protocol="PUBLIC-PBRPC"
ip="127.0.0.1"
port="7790"
service="lbs.da.openservice.ItemService"
method="GetItemsByItem"

class pbunittest(unittest.TestCase):
    def service_proc(self,test_case_id):
        logging.debug("***********************************************************************************************")
        logging.debug("test_case_id : " + test_case_id)
        case_name=testcase[test_case_id]['info']['name']
        case_input=testcase[test_case_id]['input']
        case_expect=testcase[test_case_id]['expect']

        fp=codecs.open("./data/tmp.data","w","utf-8")
        fp.write(json.dumps(case_input))
        fp.close()
        cmdstr="./pbrpcclient " + protocol + " " + ip + ":" + port + " " + service + " " + method + " ./data/tmp.data"
        logging.debug("cmdstr : " + cmdstr)
        status,output=cmd_execute(cmdstr)
        output=json.loads(output)
        logging.debug("expect : " + json.dumps(case_expect))
        logging.debug("output : " + json.dumps(output))
        assert(output == case_expect)
        logging.debug("***********************************************************************************************\n\n")

    for test_case_id in testcase:
        exec("def test_%s(self): self.service_proc('%s')" %(test_case_id,test_case_id))

if __name__ == '__main__':
    TestSuit=unittest.TestLoader().loadTestsFromTestCase(pbunittest)
    unittest.TextTestRunner(verbosity=2).run(TestSuit)


