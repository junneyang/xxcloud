#!/usr/bin/env python
#-*- coding: utf-8 -*-
import json

build_params = {
	"ClientNode":"yangjun03",
	"WorkPath":"/home/users/yangjun03/workspace",
	"PBTYPE":"PUBLIC-PBRPC",
	"IPPORT":"127.0.0.1:7788",
	"ServiceName":"lbs.da.openservice.ItemService",
	"MethodName":"GetItemsByItem",
        "TestData":[
	{
		"header": {
			"subservice":"sub",
			"secretkey": "pass",
			"servicekey": "key1"
		},
		"algorithmId": "topic_rev_poi",
		"item_ids": ["9977193541978760286"]
	},
	{
		"header": {
			"subservice":"sub",
			"secretkey": "pass",
			"servicekey": "key1"
		},
		"algorithmId": "topic_rev_poi",
		"item_ids": ["9977193541978760286"]
	}
]
}

for item in build_params:
    if(type(build_params[item]) == list or type(build_params[item]) == dict):
        build_params[item] = json.dumps(build_params[item])
print build_params
print json.dumps(build_params)



