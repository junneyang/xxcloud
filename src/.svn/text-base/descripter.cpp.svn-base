#include <iostream>
#include <string>
#include <sstream>
#include <fstream>

#include "user_proto.h"

#include <google/protobuf/message.h>
#include <google/protobuf/descriptor.h>

#include "pb_to_json.h"
#include "json_to_pb.h"

using namespace std;

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

int main(int argc, char **argv) {
	string filepath_in;
	string filepath_out;
	if (argc != 3) {
		cout << "ERROR : args error\n";
	} else {
		filepath_in = argv[1];
		filepath_out = argv[2];
	}
	
	string filestr = getfilestr(filepath_in);
	google::protobuf::Message* msg = createMessage("helloworld.helloworld");
	string error;
	if(JsonToProtoMessage(filestr, msg, &error)) {
	} else {
		cout << "JsonToProtoMessage ERROR : " << error << endl;
	}
	fstream output(filepath_out.c_str(), ios::out | ios::trunc | ios::binary);
	msg->SerializeToOstream(&output);
	output.close();
	
	fstream input(filepath_out.c_str(), ios::in | ios::binary);
	msg->ParseFromIstream(&input);
	//cout << msg->DebugString() << endl;
	//msg->PrintDebugString();
	string json_string;
	if(ProtoMessageToJson(*msg, &json_string, &error)) {
		cout << json_string << endl;
	} else {
		cout << "ProtoMessageToJson ERROR : " << error << endl;
	}
	input.close();
	
	return 0;
}
