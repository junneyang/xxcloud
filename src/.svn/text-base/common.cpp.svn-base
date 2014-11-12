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
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
long total_req = 0;
long total_res = 0;
long total_err = 0;

long below_10=0;
long between_10_20=0;
long between_20_30=0;
long over_30=0;
double total_res_time=0.0;

void callback (google::protobuf::Message* request_msg, google::protobuf::Message* response_msg, google::protobuf::RpcController* cntl, int *params) {
	string json_string;
	string error;
	if(ProtoMessageToJson(*response_msg, &json_string, &error)) {
		cout << json_string << endl;
	} else {
		cout << "ERROR : proto message to json error" << error << endl;
	}
	*params = 1;
	
	delete cntl;
	delete request_msg;
	delete response_msg;
}

void async_callback(google::protobuf::Message* response_msg, google::protobuf::RpcController* cntl, 
		int is_output, long para_starttime, google::protobuf::Message* exp_msg) {
	long para_endtime = getCurrentTimeInUSec();
	double cost_time = (para_endtime - para_starttime)/1000.0;	//us 2 ms
	pthread_mutex_lock(&mutex);
	total_res_time += cost_time;
	if(cost_time < 10.0){
		below_10++;
	}else if(cost_time >= 10.0 && cost_time < 20.0){
		between_10_20++;
	}else if(cost_time >= 20 && cost_time < 30){
		between_20_30++;
	}else{
		over_30++;
	}
	pthread_mutex_unlock(&mutex);
	
	string json_string;
	string exp_json_string;
	string error;
	if (ProtoMessageToJson(*response_msg, &json_string, &error) && ProtoMessageToJson(*exp_msg, &exp_json_string, &error)) {
		if (is_output) {
			cout << json_string << endl;
		}
		if (json_string == exp_json_string) {
			pthread_mutex_lock(&mutex);
			total_res += 1;
			pthread_mutex_unlock(&mutex);
		} else {
			pthread_mutex_lock(&mutex);
			total_err += 1;
			pthread_mutex_unlock(&mutex);
		}
	} else {
		pthread_mutex_lock(&mutex);
		total_err += 1;
		pthread_mutex_unlock(&mutex);
		cout << "ERROR : proto message to json error" << error << endl;
	}
	
	delete cntl;
	delete response_msg;
	delete exp_msg;
	//async_request(rpc_channel, pbrpc_type, service_name, method_name, method, filestr);
}

void async_request(google::protobuf::RpcChannel *rpc_channel, string pbrpc_type, string service_name, 
	const google::protobuf::MethodDescriptor *method, int is_output, string filestr, string current_expjson) {
	string error;
	google::protobuf::Message* request_msg = GetMessageByMethodDescriptor(method, true);
	if (request_msg == NULL) {
		return;
	}
	
	if(JsonToProtoMessage(filestr, request_msg, &error)) {
	} else {
		cout << "ERROR : json to proto message error" << error << endl;
		return;
	}
	
	//构造返回
	google::protobuf::Message* response_msg = GetMessageByMethodDescriptor(method, false);
	if (response_msg == NULL) {
		return;
	}
	//构造期望返回
	google::protobuf::Message* exp_msg = GetMessageByMethodDescriptor(method, false);
	if (exp_msg == NULL) {
		return;
	}
	if(JsonToProtoMessage(current_expjson, exp_msg, &error)) {
	} else {
		cout << "ERROR : json to proto message error" << error << endl;
		return;
	}
	
	//构造回调
	google::protobuf::RpcController * cntl;
	if (pbrpc_type == "SOFA-PBRPC") {
		cntl = new sofa::pbrpc::RpcController();
	} else if (pbrpc_type == "HULU-PBRPC") {
		cntl = new baidu::hulu::pbrpc::RpcClientContext();
	} else if (pbrpc_type == "PUBLIC-PBRPC") {
		vector<string> tmpv = split_string(service_name, ".");
		string service = tmpv[tmpv.size()-1];
		cntl = new pbrpc::RpcClientController();
		(static_cast<pbrpc::RpcClientController *> (cntl))->set_log_id(1);
		(static_cast<pbrpc::RpcClientController *> (cntl))->setChannel(service.c_str());
	} else {
		cout << "ERROR : not supported pbrpc type\n";
		return;
	}
	long para_starttime = getCurrentTimeInUSec();
	google::protobuf::Closure* done = google::protobuf::NewCallback(&async_callback, response_msg, cntl, is_output, para_starttime, exp_msg);
	
	//请求
	rpc_channel->CallMethod(method, cntl, request_msg, response_msg, done);
	pthread_mutex_lock(&mutex);
	total_req += 1;
	pthread_mutex_unlock(&mutex);
	delete request_msg;
}

vector<google::protobuf::RpcChannel *> channelinit(string pbrpc_type, string ip_port, int work_thread_num, int client_num, string service_name) {
	freopen("./log/pbrpc.log.wf", "a", stderr);
	//初始化客户端
	vector<google::protobuf::RpcChannel *> rpc_channels;
	if (pbrpc_type == "SOFA-PBRPC") {
		sofa::pbrpc::RpcClientOptions client_options;
		client_options.work_thread_num = work_thread_num/2;
		client_options.callback_thread_num = work_thread_num - work_thread_num/2;
		client_options.keep_alive_time = -1;
		sofa::pbrpc::RpcClient *rpc_client = new sofa::pbrpc::RpcClient(client_options);
		for (int i=0; i<client_num; i++) {
			google::protobuf::RpcChannel *rpc_channel = new sofa::pbrpc::RpcChannel(rpc_client, ip_port);
			if (rpc_channel != NULL) {
				rpc_channels.push_back(rpc_channel);
			}
		}
	} else if (pbrpc_type == "HULU-PBRPC") {
		comcfg::Configure conf;
		assert (conf.load("./conf", "pbrpc.conf") == 0);
		comlog_init(conf["Log"]);
		baidu::hulu::pbrpc::RpcClient *rpc_client = new baidu::hulu::pbrpc::RpcClient();
		baidu::hulu::pbrpc::RpcClientOptions options;
		options.net_threads_num = work_thread_num/2;
		options.worker_threads_num = work_thread_num - work_thread_num/2;
		//options.keepalive_timeout_second(50000); 默认
		rpc_client->set_options(options);
		rpc_client->Start();
		for (int i=0; i<client_num; i++) {
			baidu::hulu::pbrpc::RpcChannelOptions channel_options;
			//set tmout with a large number
			channel_options.connect_timeout_ms = 50000000;
			channel_options.session_timeout_ms = 50000000;
			channel_options.once_talk_timeout_ms = 50000000;
			google::protobuf::RpcChannel *rpc_channel = new baidu::hulu::pbrpc::RpcChannel(ip_port, rpc_client);
			if (rpc_channel != NULL) {
				(static_cast<baidu::hulu::pbrpc::RpcChannel*> (rpc_channel))->set_options(channel_options);
				rpc_channels.push_back(rpc_channel);
			}
		}
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
		
		stringstream ss;
		ss << work_thread_num/2;
		cmd_str = "sed -i 's/^ThreadNum:.*/ThreadNum:" + ss.str() + "/'" + " ./conf/pbrpc.conf";
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
			exit(-1);
		}
		pbrpc::UbTransport* transport = new pbrpc::UbTransport(ubmgr2);
		pbrpc::PbProtocol* protocol = new pbrpc::PbProtocol(transport);
		for (int i=0; i<client_num; i++) {
			google::protobuf::RpcChannel *rpc_channel = new pbrpc::AsyncClient(protocol);
			if (rpc_channel != NULL) {
				rpc_channels.push_back(rpc_channel);
			}
		}
	} else {
		cout << "ERROR : not supported pbrpc type\n";
		exit(-1);
	}
	fclose(stderr);
	return rpc_channels;
}

//以下为通用辅助接口
///////////////////////////////////////////////////////////////////////////////
long getCurrentTimeInMSec() {
	struct timeval tv;
	gettimeofday(&tv,NULL);
	return tv.tv_sec * 1000 + tv.tv_usec / 1000;
}

long getCurrentTimeInUSec() {
	struct timeval tv;
	gettimeofday(&tv,NULL);
	return tv.tv_sec * 1000 * 1000 + tv.tv_usec;
}

string timestr(long time) {
	char now[64];
	time_t tt = time;
	struct tm *ttime; 
	ttime = localtime(&tt);
	strftime(now,64,"%Y-%m-%d %H:%M:%S",ttime); 
	return now;
}

void microseconds_sleep(int usecd) {
	struct timeval tv;
	tv.tv_sec = 0;
	tv.tv_usec = usecd;
	int err;
	do {
		err=select(0,NULL,NULL,NULL,&tv);
	} while (err < 0 && errno == EINTR);
}

string getfilestr(string filepath) {
	ifstream file(filepath.c_str());
	ostringstream filestr;
	char temp;
	if (file.is_open() == true) {
		while (file.peek() != EOF) {
			file.get(temp);	// read the data one character by another
			filestr << temp;
		}
	}
	file.close();
	return filestr.str();
}

std::vector<std::string> split_string(const std::string& str, const std::string& sep){
	std::vector<std::string> ret;
	size_t start = 0;
	size_t str_len = str.size();
	size_t found = std::string::npos;
	while (start < str_len && (found = str.find(sep, start)) != std::string::npos)
	{
		if (found > start)
		{
			std::string sub = str.substr(start, found - start);
			if (!sub.empty())
			{
				ret.push_back(sub);
			}
		}
		start = (found + sep.size());
	}
	if (start < str_len)
	{
		std::string sub = str.substr(start);
		if (!sub.empty())
		{
			ret.push_back(sub);
		}
	}
	return ret;
}

int fileexist(string filepath) {
	FILE * fp;
	fp=fopen(filepath.c_str(), "r");
	if (NULL == fp) {
		return 0;
	} else {
		fclose(fp);
		return 1;
	}
}

string get_randomdata(vector<string> testdata){
	srand((unsigned)time(NULL));
	random_shuffle(testdata.begin(),testdata.end());
	return (*testdata.begin());
}

std::string exec_cmd(const char* cmd) {
	FILE* pipe = popen(cmd, "r");
	if (!pipe) return "ERROR";
	char buffer[128];
	std::string result = "";
	while(!feof(pipe)) {
		if(fgets(buffer, 128, pipe) != NULL)
			result += buffer;
	}
	pclose(pipe);
	return result;
}

//以下为帮助&测试报告接口
///////////////////////////////////////////////////////////////////////////////
void helpinfo() {
	cout << "======================================================================================\n";
	cout << "|                                 Usage Instructions                                 |\n";
	cout << "======================================================================================\n";
	cout << "|USAGE          : ./pbrpcclient <PBTYPE> <IPPORT> <ServiceName> <MethodName> <TestData>\n";
	cout << "|       PBTYPE  : type of pbrpc, currently supported PUBLIC-PBRPC/SOFA-PBRPC/HULU-PBRPC, eg : SOFA-PBRPC \n";
	cout << "|       IPPORT  : sever ip port pair, eg : 127.0.0.1:7789 \n";
	cout << "|  ServiceName  : service name, eg : lbs.da.openservice.ItemService \n";
	cout << "|   MethodName  : method name, eg : GetItemsByItem \n";
	cout << "|     TestData  : test data file path, eg : ./data/item_function_json.data \n|\n";
	cout << "|EXAMPLE        : ./pbrpcclient HULU-PBRPC 127.0.0.1:7790 lbs.da.openservice.ItemService GetItemsByItem ./data/item_function_json.data \n";
	cout << "|-------------------------------------------------------------------------------------\n";
	cout << "|MORE           : if any questions, please contact 597092663@qq.com \n";
	cout << "======================================================================================\n";
}

void benchmarkhelpinfo() {
	cout << "======================================================================================\n";
	cout << "|                                 Usage Instructions                                 |\n";
	cout << "======================================================================================\n";
	cout << "|USAGE          : ./pbrpcbenchmark <PBTYPE> <IPPORT> <ServiceName> <MethodName> <WorkThreadNum> <SendThreadNum> <ClientNum> <SendRate> <IsRandom> <TestTime> <IsOutput> <TestData>\n";
	cout << "|       PBTYPE  : type of pbrpc, currently supported PUBLIC-PBRPC/SOFA-PBRPC/HULU-PBRPC, eg : SOFA-PBRPC \n";
	cout << "|       IPPORT  : sever ip port pair, eg : 127.0.0.1:7789 \n";
	cout << "|  ServiceName  : service name, eg : lbs.da.openservice.ItemService \n";
	cout << "|   MethodName  : method name, eg : GetNuomiUserPreference \n";
	cout << "|WorkThreadNum  : numbers of work thread, less than the number of processors and 2*N is suggested. eg : 2 4 6 8 10 etc \n";
	cout << "|SendThreadNum  : numbers of send thread, less than the number of processors is suggested. eg : 2 \n";
	cout << "|    ClientNum  : numbers of socket connections, eg : 20 \n";
	cout << "|     SendRate  : rate of request sending per thread per client per minute, -1 represents the maximum ability to send, eg : 200 \n";
	cout << "|     IsRandom  : flag of whether to send the request with random sequence, 0 represents ordinal, 1 represents random, eg : 1 \n";
	cout << "|     TestTime  : total test time(min), eg : 1.0 \n";
	cout << "|     IsOutput  : flag of whether print the response content. eg : 0 \n";
	cout << "|     TestData  : test data file path, eg : ./data/item_benchmark_json.data \n|\n";
	cout << "|EXAMPLE        : ./pbrpcbenchmark HULU-PBRPC 127.0.0.1:7790 lbs.da.openservice.ItemService GetItemsByItem 8 2 20 200 1 1.0 0 ./data/item_benchmark_json.data \n";
	cout << "|-------------------------------------------------------------------------------------\n";
	cout << "|MORE           : if any questions, please contact 597092663@qq.com \n";
	cout << "======================================================================================\n";
}

void testreport(long start, long end, int work_thread_num, int send_threadnum, int client_num, double test_time) {
	string start_time = timestr(start/1000);
	string end_time = timestr(end/1000);
	double avg_latency = total_res_time/(total_res + total_err);
	
	cout << "======================================================================================\n";
	cout << "|                                 TEST REPORT                                        |\n";
	cout << "======================================================================================\n";
	cout << "| StartTime             : " << start_time << "\n";
	cout << "| EndTime               : " << end_time << "\n";
	cout << "|-------------------------------------------------------------------------------------\n";
	cout << "| WorkThreadNum         : " << work_thread_num << "\n";
	cout << "| SendThreadNum         : " << send_threadnum << "\n";
	cout << "| ClientNum             : " << client_num << "\n";
	cout << "| TestTime              : " << test_time << " min \n";
	cout << "|-------------------------------------------------------------------------------------\n";
	cout << "| TotalReq              : " << total_req << "\n";
	cout << "| TotalRes              : " << total_res << "\n";
	cout << "| TotalErr              : " << total_err << "\n";
	cout << "| QPS                   : " << total_res/(test_time*60) << "\n";
	cout << "|-------------------------------------------------------------------------------------\n";
	cout << "| AvgLatency            : " << avg_latency << " ms \n";
	cout << "| Below_10              : " << below_10 << "\n";
	cout << "| Between_10_20         : " << between_10_20 << "\n";
	cout << "| Between_20_30         : " << between_20_30 << "\n";
	cout << "| Over_30               : " << over_30 << "\n";
	cout << "======================================================================================\n";
}

