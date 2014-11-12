#include <iostream>
#include <stdio.h>
#include <sys/time.h>
#include <errno.h>

void seconds_sleep(unsigned seconds){
    struct timeval tv;
    tv.tv_sec=seconds;
    tv.tv_usec=0;
    int err;
    do{
       err=select(0,NULL,NULL,NULL,&tv);
    }while(err<0 && errno==EINTR);
}

void milliseconds_sleep(unsigned long mSec){
    struct timeval tv;
    tv.tv_sec=mSec/1000;
    tv.tv_usec=(mSec%1000)*1000;
    int err;
    do{
       err=select(0,NULL,NULL,NULL,&tv);
    }while(err<0 && errno==EINTR);
}

void microseconds_sleep(unsigned long uSec){
    struct timeval tv;
    tv.tv_sec=uSec/1000000;
    tv.tv_usec=uSec%1000000;
    int err;
    do{
        err=select(0,NULL,NULL,NULL,&tv);
    }while(err<0 && errno==EINTR);
}

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

int main()
{
    /*int i;
    for(i=0;i<5;++i){
    printf("%d\n",i);
    seconds_sleep(1);
    //milliseconds_sleep(1500);
    //microseconds_sleep(1900000);
    }*/
	long tmp_start = getCurrentTimeInUSec();
	long current = getCurrentTimeInMSec();
	long tmp_end = getCurrentTimeInUSec();
	int interval = tmp_end - tmp_start;
	tmp_end = getCurrentTimeInUSec();
	interval = tmp_end - tmp_start;
	std::cout << interval << std::endl;
}
