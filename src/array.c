#include<stdio.h>
#define MAX_LEN 20480

void printArray(char (*p)[MAX_LEN], int n) {
	for (int i = 0; i < n; i++) {
		for (int j = 0; j < MAX_LEN; j++) {
			printf("%c", p[i][j]);
		}
		printf("\n");
	}
}

int main() {
	int n = 256;
	char a[n][MAX_LEN];
	for (int i = 0; i < n; i++) {
		for (int j = 0; j < MAX_LEN; j++) {
			a[i][j] = 'a';
		}
	}
	printArray(a, n);
}

