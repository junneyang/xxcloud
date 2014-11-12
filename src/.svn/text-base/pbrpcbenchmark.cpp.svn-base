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
#include "common.h"
#include "requestthreadpool.h"

using namespace std;

int main(int argc, char **argv) {
	//params args = (params)malloc(sizeof(struct _params));
	params args = new _params;
	if (argc != 13) {
		benchmarkhelpinfo();
		return -1;
	} else {
		args->pbrpc_type = string(argv[1]);
		args->ip_port = string(argv[2]);
		args->service_name = string(argv[3]);
		args->method_name = string(argv[4]);
		args->work_thread_num = atoi(argv[5]);
		args->send_threadnum = atoi(argv[6]);
		args->client_num = atoi(argv[7]);
		args->send_rate = atoi(argv[8]);
		args->is_random = atoi(argv[9]);
		args->test_time = atof(argv[10]);
		args->is_output = atoi(argv[11]);
		string filepath = string(argv[12]);
		if (fileexist(filepath) == 1) {
			args->testdata = getfilestr(filepath);
		} else {
			args->testdata = filepath;
		}
		//args->testdata = getfilestr(filepath);
	}
	if (args->work_thread_num <= 0 || args->work_thread_num%2 != 0) {
		cout << "ERROR : thread number 2*N is suggested \n";
		return -1;
	}
	vector<google::protobuf::RpcChannel *> rpc_channels = channelinit(args->pbrpc_type, args->ip_port, 
		args->work_thread_num, args->client_num, args->service_name);
	args->rpc_channels = rpc_channels;
	requestthreadpool(args);
	
	long start = getCurrentTimeInMSec();
	long total_time = (long)(args->test_time*60*1000);
	long end = start + total_time;
	long current = getCurrentTimeInMSec();
	while(current <= end){
		usleep(1000000);
		current = getCurrentTimeInMSec();
	}
	testreport(start, end, args->work_thread_num, args->send_threadnum, args->client_num, args->test_time);
	
	return 0;
}

