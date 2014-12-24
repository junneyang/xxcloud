#include <stdio.h>

void strRvs(const char *s) {
	if(s[0] == '\0') {
		return;
	}
	else {
		strRvs(&s[1]);
	}
	printf("%c",s[0]);
}

int main(int argc, char** argv) {
	char *str = argv[1];
	strRvs(str);
	printf("\n");
	
	return 0;
}
