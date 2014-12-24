#!/usr/bin/env python
#-*- coding: utf-8 -*-

def str2File(dataStr,filepath):
    fp=open(filepath,'w')
    fp.write(dataStr)
    fp.close()

if __name__ == "__main__":
    dataStr="""{	"PROTOCOL_TYPE":"HTTP_POST_JSON",
	"URL":"http://localhost:18080/lbs/da/openservice",
	"HEADERS":{"Content-type":"application/json"},
	"_BODY":"BODY列表表示消息发送时随机读取，可以只配置一个",
	"BODY":[{
		"service": "ItemService",
		"method": "GetItemsByItem",
		"request": {
		"header": {
				"subservice":"sub",
				"secretkey": "pass",
				"servicekey": "key1"
		},
		"algorithmId": "ass_a2c",
		"userid":"10002",
		"useridtype":"just test",
		"item_ids": ["10000258075758756529"]
		}
	}],
	"_EXP_DATA":"期望返回值，可不配置，默认只校验数据返回，不校验返回是否正确",
	"EXP_DATA":[{"id":"18012202574307917823","value":[0.3,0.5,0.4]},{"id":"12313225205891489106","value":[1]},{"id":"18119621412888245380","value":[0.7]},{"id":"2071168565446484381","value":[0.3]},{"id":"11710154692952313709","value":[0.3]}],
	"_CONNECTION_TMOUT":"连接超时时间配置，单位：ms",
	"CONNECTION_TMOUT":200,
	"REQUEST_TMOUT":"请求超时时间设置，单位：ms",
	"REQUEST_TMOUT":200
}
    """
    filepath='test.txt'
    str2File(dataStr,filepath)

