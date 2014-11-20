#!/usr/bin/python
# -*- coding: utf-8 -*-
import logging
from logging.handlers import RotatingFileHandler

LogFilePath="./log/pb.log"
logging.basicConfig(level=logging.DEBUG,
                format='[%(levelname)s] [%(asctime)s] [%(filename)s-line:%(lineno)d] [%(funcName)s-%(threadName)s] %(message)s',
                datefmt='%a,%Y-%m-%d %H:%M:%S',
                filename=LogFilePath,
                filemode='a')

'''#定义一个RotatingFileHandler，最多备份5个日志文件，每个日志文件最大10M
Rthandler=RotatingFileHandler(LogFilePath, maxBytes=10*1024*1024,backupCount=5)
Rthandler.setLevel(logging.DEBUG)
formatter=logging.Formatter('[%(levelname)s] [%(asctime)s] [%(filename)s-line:%(lineno)d] [%(funcName)s-%(threadName)s] %(message)s',datefmt='%a,%Y-%m-%d %H:%M:%S')
Rthandler.setFormatter(formatter)
logging.getLogger('./log/autotestPlatform').addHandler(Rthandler)'''


if __name__ == "__main__":
    logging.debug("HelloWorld")
    logging.info("HelloWorld")
