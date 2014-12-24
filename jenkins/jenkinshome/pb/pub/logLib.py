#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import os
sys.path.append("%s/../"%os.path.dirname(os.path.realpath(__file__)))
import logging

LogFilePath="./log/pbunittest.log"
logging.basicConfig(level=logging.DEBUG,
                format='[%(levelname)s] [%(asctime)s] [%(filename)s-line:%(lineno)d] [%(funcName)s-%(threadName)s] %(message)s',
                datefmt='%a,%Y-%m-%d %H:%M:%S',
                filename=LogFilePath,
                filemode='a')


if __name__ == "__main__":
    logging.debug("HelloWorld")
