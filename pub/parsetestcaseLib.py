#!/usr/bin/env python
#-*- coding: utf-8 -*-
import json
import sys

def get_testcase(filepath):
    testcase=json.load(open(filepath, "r"),encoding='utf-8')
    return testcase

if __name__ == "__main__":
    pass

