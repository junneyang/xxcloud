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
#include "requestthreadpool.h"

using namespace std;

void *requestthread(void *data) {
	params args = (params)data;
	string pbrpc_type = args->pbrpc_type;
	string ip_port = args->ip_port;
	string service_name = args->service_name;
	string method_name = args->method_name;
	//int work_thread_num = args->work_thread_num;
	//int send_threadnum = args->send_threadnum;
	//int client_num = args->client_num;
	int send_rate = args->send_rate;
	int is_random = args->is_random;
	double test_time = args->test_time;
	int is_output = args->is_output;
	string testdata = args->testdata;
	vector<google::protobuf::RpcChannel *> rpc_channels = args->rpc_channels;
	//动态创建方法
	const google::protobuf::MethodDescriptor *method = FindMethodByName(service_name, method_name);
	if (method == NULL) {
		return NULL;
	}
	
	long start = getCurrentTimeInMSec();
	long total_time = (long)(test_time*60*1000);
	long end = start + total_time;
	vector<google::protobuf::RpcChannel *>::iterator iter;
	vector<google::protobuf::RpcChannel *>::iterator last = rpc_channels.end();
	//cout << rpc_channels.size();
	int avg_interval = (1000*1000)/(send_rate);
	int interval;
	long current = getCurrentTimeInMSec();
	/*vector<string> filestr_array = split_string(testdata, "##########");
	int filestr_array_size = filestr_array.size();*/
	/*Document d;
	d.Parse(testdata.c_str());*/
	
	Json::Reader reader;
	Json::Value jsondata;
	if (!reader.parse(testdata, jsondata, false)) { 
		return NULL; 
	}
	int filestr_array_size = jsondata.size();
	int index = 0;
	
	string current_reqstr;
	string current_expjson;
	if (filestr_array_size == 1) {
		SizeType i_index = (SizeType)index;
		current_reqstr = jsondata[index]["input"].toStyledString();
		
		/*Value &ss = d[i_index]["expect"];
		StringBuffer buffer2;
		Writer<StringBuffer> writer2(buffer2);
		ss.Accept(writer2);
		current_expjson = buffer2.GetString();*/
		current_expjson = jsondata[index]["expect"].toStyledString();
		
		while(current <= end){
			long tmp_start = getCurrentTimeInUSec();
			for (iter = rpc_channels.begin(); iter != last; ++iter) {
				async_request(*iter, pbrpc_type, service_name, method, is_output, current_reqstr, current_expjson);
			}
			long tmp_end = getCurrentTimeInUSec();
			interval = avg_interval - tmp_end + tmp_start;
			if (interval > 0) {
				microseconds_sleep(interval);
			}
			current = getCurrentTimeInMSec();
		}
	} else if ( filestr_array_size != 1 && is_random == 1){
		while(current <= end){
			long tmp_start = getCurrentTimeInUSec();
			srand((int) time(0));
			index = rand() % filestr_array_size;
			
			SizeType i_index = (SizeType)index;
			current_reqstr = jsondata[index]["input"].toStyledString();
			
			/*Value &ss = d[i_index]["expect"];
			StringBuffer buffer2;
			Writer<StringBuffer> writer2(buffer2);
			ss.Accept(writer2);
			current_expjson = buffer2.GetString();*/
			current_expjson = jsondata[index]["expect"].toStyledString();
			
			for (iter = rpc_channels.begin(); iter != last; ++iter) {
				async_request(*iter, pbrpc_type, service_name, method, is_output, current_reqstr, current_expjson);
			}
			long tmp_end = getCurrentTimeInUSec();
			interval = avg_interval - tmp_end + tmp_start;
			if (interval > 0) {
				microseconds_sleep(interval);
			}
			current = getCurrentTimeInMSec();
		}
	} else if ( filestr_array_size != 1 && is_random == 0){
		int tmp_index = 0;
		while(current <= end){
			long tmp_start = getCurrentTimeInUSec();
			
			SizeType i_index = (SizeType)tmp_index;
			current_reqstr = jsondata[tmp_index]["input"].toStyledString();
			
			/*Value &ss = d[i_index]["expect"];
			StringBuffer buffer2;
			Writer<StringBuffer> writer2(buffer2);
			ss.Accept(writer2);
			current_expjson = buffer2.GetString();*/
			current_expjson = jsondata[tmp_index]["expect"].toStyledString();
			
			if (tmp_index != filestr_array_size - 1) {
				tmp_index += 1;
			} else {
				tmp_index = 0;
			}
			for (iter = rpc_channels.begin(); iter != last; ++iter) {
				async_request(*iter, pbrpc_type, service_name, method, is_output, current_reqstr, current_expjson);
			}
			long tmp_end = getCurrentTimeInUSec();
			interval = avg_interval - tmp_end + tmp_start;
			if (interval > 0) {
				microseconds_sleep(interval);
			}
			current = getCurrentTimeInMSec();
		}
	} 
	return NULL;
}

void requestthreadpool(void *data){
	params args = (params)data;
	int send_threadnum = args->send_threadnum;
	
	std::vector<pthread_t> threads;
	int i;
	for(i=0; i < send_threadnum; i++){
		pthread_t pid;
		threads.push_back(pid);
		int ret=pthread_create(&pid, NULL, requestthread, args);
		if(ret!=0){
			printf ("create pthread error!\n");
			exit (1);
		}
	}
	/*for(i=0; i < send_threadnum; i++){
		int rc = pthread_join(threads[i], NULL);
		if (rc){
			printf("pthread join error %d\n", rc);
			exit (1);
		}
	}*/
}

