#include <stdio.h>
#include <string.h>

char& mem(int length) {
	char* p = new char[length];
	return p;
}

int main() {
	char& p = mem(20);
	strcpy("helloworld!!!", p);
	printf("%d\n", strlen(p));
	
	return 0;
}
