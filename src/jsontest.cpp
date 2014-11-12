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

/*int main() {
    // 1. Parse a JSON string into DOM.
    const char* json = "{\"project\":\"rapidjson\",\"stars\":10}";
    Document d;
    d.Parse(json);

    // 2. Modify it by DOM.
    Value& s = d["stars"];
    s.SetInt(s.GetInt() + 1);

    // 3. Stringify the DOM
    StringBuffer buffer;
    Writer<StringBuffer> writer(buffer);
    d.Accept(writer);

    // Output {"project":"rapidjson","stars":11}
    std::cout << buffer.GetString() << std::endl;
    return 0;
}*/

int main (void) {
	string filestr = getfilestr("./data/item_benchmark_json.data");
	Document d;
	d.Parse(filestr.c_str());
	
	// Stringify the DOM
	StringBuffer buffer;
	Writer<StringBuffer> writer(buffer);
	d.Accept(writer);

	// Output {"project":"rapidjson","stars":11}
	std::cout << buffer.GetString() << std::endl;
	std::cout << d.Size() << std::endl;
	
	int a = 0;
	SizeType i = (SizeType)a;
	Value &s = d[i]["input"];
	StringBuffer buffer2;
	Writer<StringBuffer> writer2(buffer2);
	s.Accept(writer2);
	std::cout << buffer2.GetString() << std::endl;
	
	return 0;
}

