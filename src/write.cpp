#include <iostream>
#include <string>
#include <sstream>
#include <fstream>

#include "user_proto.h"

using namespace std;

int main(int argc, char **argv) {
	string filepath;
	if (argc != 2) {
		cout << "ERROR : args error\n";
	} else {
		filepath = argv[1];
	}
	
	helloworld::helloworld hw;
	hw.set_id(100);
	hw.set_str("helloworld");
	
	for (int i=0; i<10; i++) {
		hw.set_opt(i);
		
		helloworld::phonenumber *ph = hw.add_phonenumbers();
		stringstream ss;
		ss << "1866581768" << i;
		ph->set_number(ss.str());
		if (i == 0) {
			ph->set_type(helloworld::MOBILE);
		} else if (i == 1) {
			ph->set_type(helloworld::HOME);
		} else if (i == 2) {
			ph->set_type(helloworld::WORK);
		} else {
		}
		
	}
	
	fstream output(filepath.c_str(), ios::out | ios::trunc | ios::binary);
	hw.SerializeToOstream(&output);
	
	return 0;
}
