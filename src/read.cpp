#include <iostream>
#include <string>
#include <sstream>
#include <fstream>

#include "user_proto.h"

using namespace std;

void disinfo(helloworld::helloworld &hw) {
	cout << hw.id() << endl;
	cout << hw.str() << endl;
	if (hw.has_opt()) { 
		cout << hw.opt() << endl;
	}
	for (int i=0; i<hw.phonenumbers_size(); i++) {
		helloworld::phonenumber ph= hw.phonenumbers(i);
		string number = ph.number();
		string type;
		switch (ph.type()) {
			case helloworld::MOBILE :
				type = "MOBILE";
				break;
			case helloworld::HOME :
				type = "HOME";
				break;
			case helloworld::WORK :
				type = "WORK";
				break;
		}
		cout << number << " " << type << endl;
	}
}

int main(int argc, char **argv) {
	string filepath;
	if (argc != 2) {
		cout << "ERROR : args error\n";
	} else {
		filepath = argv[1];
	}
	
	helloworld::helloworld hw;
	fstream input(filepath.c_str(), ios::in | ios::binary);
	hw.ParseFromIstream(&input);
	
	disinfo(hw);
	
	return 0;
}
