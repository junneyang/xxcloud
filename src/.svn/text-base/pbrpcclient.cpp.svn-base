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

using namespace std;

int main(int argc, char **argv) {
	string pbrpc_type;
	string ip_port;
	string service_name;
	string method_name;
	string testdata;
	
	if (argc != 6) {
		helpinfo();
		return 0;
	} else {
		pbrpc_type = argv[1];
		ip_port = argv[2];
		service_name = argv[3];
		method_name = argv[4];
		testdata = argv[5];
	}
	
	freopen("./log/pbrpc.log.wf", "a", stderr);
	//构造请求
	string filestr;
	if (fileexist(testdata) == 1) {
		filestr = getfilestr(testdata);
	} else {
		filestr = testdata;
		//cout << endl << filestr << endl;
	}
	/*std::ifstream ifs;
	ifs.open(testdata.c_str());*/
	Json::Reader reader;
	Json::Value jsondata;
	if (!reader.parse(filestr, jsondata, false)) { 
		return -1; 
	}
	vector<string> filestr_array;
	for (int i = 0; i < jsondata.size(); i ++) {
		filestr_array.push_back(jsondata[i].toStyledString());
	}
	
	for (size_t i=0; i<filestr_array.size(); i++) {
		//初始化客户端
		google::protobuf::RpcChannel *rpc_channel;
		google::protobuf::RpcController * cntl;
		if (pbrpc_type == "SOFA-PBRPC") {
			sofa::pbrpc::RpcClientOptions client_options;
			sofa::pbrpc::RpcClient *rpc_client = new sofa::pbrpc::RpcClient(client_options);
			rpc_channel = new sofa::pbrpc::RpcChannel(rpc_client, ip_port);
			cntl = new sofa::pbrpc::RpcController();
		} else if (pbrpc_type == "HULU-PBRPC") {
			comcfg::Configure conf;
			assert (conf.load("./conf", "pbrpc.conf") == 0);
			comlog_init(conf["Log"]);
			baidu::hulu::pbrpc::RpcClient *rpc_client = new baidu::hulu::pbrpc::RpcClient();
			baidu::hulu::pbrpc::RpcClientOptions options;
			rpc_client->set_options(options);
			rpc_client->Start();
			baidu::hulu::pbrpc::RpcChannelOptions channel_options;
			//set tmout with a large number
			channel_options.connect_timeout_ms = 50000000;
			channel_options.session_timeout_ms = 50000000;
			channel_options.once_talk_timeout_ms = 50000000;
			rpc_channel = new baidu::hulu::pbrpc::RpcChannel(ip_port, rpc_client);
			(static_cast<baidu::hulu::pbrpc::RpcChannel*> (rpc_channel))->set_options(channel_options);
			cntl = new baidu::hulu::pbrpc::RpcClientContext();
		} else if (pbrpc_type == "PUBLIC-PBRPC") {
			vector<string> tmpv = split_string(service_name, ".");
			string service = tmpv[tmpv.size()-1];
			string cmd_str = "sed -i 's/^Name:.*/Name:" +service+ "/'" + " ./conf/pbrpc.conf";
			exec_cmd(cmd_str.c_str());
			
			vector<string> split_ip_port = split_string(ip_port, ":");
			cmd_str = "sed -i 's/^IP:.*/IP:" +split_ip_port[0]+ "/'" + " ./conf/pbrpc.conf";
			exec_cmd(cmd_str.c_str());
			cmd_str = "sed -i 's/^Port:.*/Port:" +split_ip_port[1]+ "/'" + " ./conf/pbrpc.conf";
			exec_cmd(cmd_str.c_str());
			
			ub::UbClientManager2* ubmgr2 = new ub::UbClientManager2();
			comcfg::Configure conf;
			assert (conf.load("./conf", "pbrpc.conf") == 0);
			//freopen ("./log/pbrpc.log.err","a",stderr);
			comlog_init(conf["Log"]);
			int ret = ubmgr2->load(conf["UbClientConfig"]);
			if (ret == 0) {
				//fprintf(stderr, "%s\n", "init ok");
			} else {
				//fprintf(stderr, "%s\n", "init error");
				return -1;
			}
			pbrpc::UbTransport* transport = new pbrpc::UbTransport(ubmgr2);
			pbrpc::PbProtocol* protocol = new pbrpc::PbProtocol(transport);
			rpc_channel = new pbrpc::AsyncClient(protocol);
			cntl = new pbrpc::RpcClientController();
			(static_cast<pbrpc::RpcClientController *> (cntl))->set_log_id(1);
			(static_cast<pbrpc::RpcClientController *> (cntl))->setChannel(service.c_str());
		} else {
			cout << "ERROR : not supported pbrpc type\n";
			return 0;
		}
		
		//动态创建方法
		const google::protobuf::MethodDescriptor *method = FindMethodByName(service_name, method_name);
		if (method == NULL) {
			return 0;
		}
		
		string currentstr = filestr_array[i];
		//cout << currentstr << endl;
		google::protobuf::Message* request_msg = GetMessageByMethodDescriptor(method, true);
		if (request_msg == NULL) {
			return 0;
		}
		
		string error;
		if(JsonToProtoMessage(currentstr, request_msg, &error)) {
		} else {
			cout << "ERROR : json to proto message error" << error << endl;
			return 0;
		}
		
		//构造返回
		google::protobuf::Message* response_msg = GetMessageByMethodDescriptor(method, false);
		if (response_msg == NULL) {
			return 0;
		}
		
		//构造回调
		int flag;
		int *params = &flag;
		*params = 0;
		google::protobuf::Closure* done = google::protobuf::NewCallback(&callback, request_msg, response_msg, cntl, params);
		
		//请求
		rpc_channel->CallMethod(method, cntl, request_msg, response_msg, done);
		
		while (!(*params)){
			usleep(100000);
		}
	}
	fclose(stderr);
	
	return 0;
}

