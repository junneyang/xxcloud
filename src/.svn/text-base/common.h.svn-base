 /*
 *Copyright (c) 2014-2014, yangjun <597092663@qq.com>
 *All rights reserved.
 * 
 *Redistribution and use in source and binary forms, with or without
 *modification, are permitted provided that the following conditions are met:
 * 
 *  * Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *  * Neither the name of Redis nor the names of its contributors may be used
 *    to endorse or promote products derived from this software without
 *    specific prior written permission.
 * 
 *THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS 
 *BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
 *THE POSSIBILITY OF SUCH DAMAGE.
 */
#ifndef COMMON__H_
#define COMMON__H_
#include <iostream>
#include <string>
#include <sstream>
#include <fstream>
#include <cstring>
#include <vector>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include <algorithm>
#include <pthread.h>
#include <unistd.h>
#include <cstdio>

//json
#include "rapidjson/document.h"
#include "rapidjson/writer.h"
#include "rapidjson/stringbuffer.h"

#include "user_proto.h"

#include <google/protobuf/message.h>
#include <google/protobuf/descriptor.h>

#include "pb_to_json.h"
#include "json_to_pb.h"

//SOFA-PBRPC
#include "sofa/pbrpc/rpc_channel.h"
#include "sofa/pbrpc/common.h"
#include "sofa/pbrpc/rpc_controller.h"
#include "sofa/pbrpc/pbrpc.h"

//PUBLIC-PBRPC
#include <ub_log.h>
#include <ubclient_include.h>
#include "ubclient_manager2.h"
#include <comlogplugin.h>
#include "BlockingClient.h"
#include "NonblockingClient.h"
#include "AsyncClient.h"
#include "UbTransport.h"
#include "PbProtocol.h"
#include <Configure.h>
#include "util/pbrpc_log.h"

//HULU-PBRPC
#include "hulu/pbrpc/rpc_channel.h"
#include "hulu/pbrpc/sync_point.h"
#include "hulu/pbrpc/common.h"
#include "hulu/pbrpc/rpc_client_controller.h"

//jsoncpp
#include "json/json.h"

using namespace std;
using namespace rapidjson;

extern pthread_mutex_t mutex;
extern long total_req;
extern long total_res;
extern long total_err;

extern long below_10;
extern long between_10_20;
extern long between_20_30;
extern long over_30;
extern double total_res_time;

/*google::protobuf::Message* createMessage(const string& type_name);
const google::protobuf::MethodDescriptor* FindMethodByName(const string& service_name, const string& method_name);
google::protobuf::Message* GetMessageByMethodDescriptor(const google::protobuf::MethodDescriptor* descripter, bool is_input);
google::protobuf::Message* GetMessageByName(const string& service_name, const string& method_name, bool is_input);*/

//inline functions for performance optimization
inline google::protobuf::Message* createMessage(const string& type_name) {
	google::protobuf::Message* message = NULL;
	const google::protobuf::Descriptor* descriptor = google::protobuf::DescriptorPool::generated_pool()->FindMessageTypeByName(type_name);
	if (descriptor) {
		const google::protobuf::Message* prototype = google::protobuf::MessageFactory::generated_factory()->GetPrototype(descriptor);
		if (prototype) {
			message = prototype->New();
		}
	}
	return message;
}

inline const google::protobuf::MethodDescriptor* FindMethodByName(const string& service_name, const string& method_name) {
	const google::protobuf::ServiceDescriptor* descriptor =
		google::protobuf::DescriptorPool::generated_pool()->FindServiceByName(service_name);
	if (NULL == descriptor) {
		cout << "ERROR : method not fund error" << endl;
		return NULL;
	}
	return descriptor->FindMethodByName(method_name);
}

inline google::protobuf::Message* GetMessageByMethodDescriptor(const google::protobuf::MethodDescriptor* descripter, bool is_input) {
	if (NULL == descripter) {
		cout << "ERROR : descripter null error" << endl;
		return NULL;
	}
	const google::protobuf::Descriptor* message_descriptor = NULL;
	if (is_input) {
		message_descriptor = descripter->input_type();
	} else {
		message_descriptor = descripter->output_type();
	}
	const google::protobuf::Message* prototype = google::protobuf::MessageFactory::generated_factory()->GetPrototype(message_descriptor);
	if (NULL == prototype) {
		cout << "ERROR : get prototype null error" << endl;
		return NULL;
	}
	google::protobuf::Message* message = prototype->New();
	return message;
}

inline google::protobuf::Message* GetMessageByName(const string& service_name, const string& method_name, bool is_input) {
	const google::protobuf::MethodDescriptor* descripter = FindMethodByName(service_name, method_name);
	return GetMessageByMethodDescriptor(descripter, is_input);
}

//for client tool
void callback (google::protobuf::Message* request_msg, google::protobuf::Message* response_msg, google::protobuf::RpcController* cntl, int *params);
//for benchmark
void async_request(google::protobuf::RpcChannel *rpc_channel, string pbrpc_type, string service_name,
	const google::protobuf::MethodDescriptor *method, int is_output, string filestr, string current_expjson);
void async_callback(google::protobuf::Message* response_msg, google::protobuf::RpcController* cntl, int is_output, long para_starttime, string current_expjson);
//socket客户端初始化
vector<google::protobuf::RpcChannel *> channelinit(string pbrpc_type, string ip_port, int work_thread_num, int client_num, string service_name);


string getfilestr(string filepath);//获取文件内容字符串
std::vector<std::string> split_string(const std::string& str, const std::string& sep);//字符串分割
int fileexist(string filepath);	//判断文件是否存在
string get_randomdata(vector<string> testdata);//获取随机字符串
long getCurrentTimeInMSec();//获取当前时间函数，返回单位ms
long getCurrentTimeInUSec();//获取当前时间函数，返回单位us
string timestr(long time);//时间戳转化为 "%Y-%m-%d %H:%M:%S" 格式的时间, 输入单位为s
void microseconds_sleep(int usecd);//select实现精准延时，精确到us级
std::string exec_cmd(const char* cmd);//执行shell命令
void helpinfo();//打印帮助信息
//for benchmark
void benchmarkhelpinfo();
//testreport
void testreport(long start, long end, int work_thread_num, int send_threadnum, int client_num, double test_time);
#endif /* COMMON__H_ */

