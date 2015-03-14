#!/usr/bin/env python
#-*- coding: utf-8 -*-
from logLib import *
import datetime

import MySQLdb
host='XXX'
user='root'
passwd='XXX'
db='db_pb'
port=33306

from dynsqlLib import *

class mysqlLib():
    def __init__(self,host=host,user=user,passwd=passwd,db=db,port=port,charset='utf8'):
        try:
            self.host=host
            self.user=user
            self.passwd=passwd
            self.db=db
            self.port=port
            self.charset=charset
            self.conn=MySQLdb.connect(host=self.host,user=self.user,passwd=self.passwd,db=self.db,port=self.port,charset=self.charset)
            self.cursor=self.conn.cursor()
        except Exception as e:
            logging.error(str(e))
    def close(self):
        try:
            self.cursor.close()
            self.conn.close()
        except Exception as e:
            logging.error(str(e))
    ##################################################################task操作####################################################
    def add_task(self, param):
        try:
            sql="""insert into tbl_task(id,submit,jenkinsurl,jobname,build_params,status) values(NULL,%s,%s,%s,%s,%s)"""
            n=self.cursor.execute(sql,param)
            last_id=int(self.cursor.lastrowid)
            self.conn.commit()
            return n,last_id
        except Exception as e:
            logging.error(str(e))
            return 0,0

    def update_task_status(self,param):
        try:
            sql="""update tbl_task set status=%s where id=%s"""
            n=self.cursor.execute(sql,param)
            self.conn.commit()
            return n
        except Exception as e:
            logging.error(str(e))
    def update_task_build_number(self,param):
        try:
            sql="""update tbl_task set build_number=%s where id=%s"""
            n=self.cursor.execute(sql,param)
            self.conn.commit()
            return n
        except Exception as e:
            logging.error(str(e))

    def query_task(self, param):
        try:
            s=DynSql("""select id,submit,jenkinsurl,jobname,build_params,status,build_number from tbl_task where 1=1
            { and id=$id} { and submit=$submit}
            ORDER BY id DESC {limit {$offset,} $limit}""")
            sql=s(param)
            cnt=self.cursor.execute(sql[0],sql[1])
            ret=self.cursor.fetchall()
            return ret
        except Exception as e:
            logging.error(str(e))

if __name__ == "__main__":
    pass

