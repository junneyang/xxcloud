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
    ##################################################################server操作####################################################
    def add_server(self,param):
        try:
            sql="""insert into tbl_server(id,name,exenum,workspace,ip,username,password,belong,descpt) values(NULL,%s,%s,%s,%s,%s,%s,%s,%s)"""
            n=self.cursor.execute(sql,param)
            last_id=int(self.cursor.lastrowid)
            self.conn.commit()
            return n,last_id
        except Exception as e:
            logging.error(str(e))
            return 0,0
    def query_server(self,param):
        try:
            s=DynSql("""select id,name,exenum,workspace,ip,username,password,belong,descpt from tbl_server where 1=1
            { and id=$id} { and belong=$belong} { and name=$name}
            ORDER BY id DESC {limit {$offset,} $limit}""")
            sql=s(param)
            cnt=self.cursor.execute(sql[0],sql[1])
            ret=self.cursor.fetchall()
            return ret
        except Exception as e:
            logging.error(str(e))
    def query_server_totalcnt(self,param):
        try:
            s=DynSql("""select count(*) from tbl_server where 1=1
            { and belong=$belong}
            """)
            sql=s(param)
            cnt=self.cursor.execute(sql[0],sql[1])
            ret=self.cursor.fetchall()
            totalcnt=ret[0][0]
            return ret
        except Exception as e:
            logging.error(str(e))
    def del_server(self,param):
        try:
            sql="delete from tbl_server where id=%s"
            n=self.cursor.execute(sql,param)
            self.conn.commit()
            return n
        except Exception as e:
            logging.error(str(e))

    ##################################################################testdata操作####################################################
    def add_testdata(self,param):
        try:
            sql="""insert into tbl_testdata(id,type,name,belong,filenum,descpt) values(NULL,%s,%s,%s,%s,%s)"""
            n=self.cursor.execute(sql,param)
            last_id=int(self.cursor.lastrowid)
            self.conn.commit()
            return n,last_id
        except Exception as e:
            logging.error(str(e))
            return 0,0
    def query_testdata(self,param):
        try:
            s=DynSql("""select id,name,type,belong,filenum,descpt from tbl_testdata where 1=1
            { and id=$id} { and belong=$belong} { and type=$datatype}
            ORDER BY id DESC {limit {$offset,} $limit}""")
            sql=s(param)
            cnt=self.cursor.execute(sql[0],sql[1])
            ret=self.cursor.fetchall()
            return ret
        except Exception as e:
            logging.error(str(e))
    def query_testdata_totalcnt(self,param):
        try:
            s=DynSql("""select count(*) from tbl_testdata where 1=1
            { and belong=$belong} { and type=$datatype}
            """)
            sql=s(param)
            cnt=self.cursor.execute(sql[0],sql[1])
            ret=self.cursor.fetchall()
            totalcnt=ret[0][0]
            return ret
        except Exception as e:
            logging.error(str(e))
    def add_datastr(self,param):
        try:
            sql="""insert into tbl_datafile(id,testdata_id,filename,filestr) values(NULL,%s,%s,%s)"""
            n=self.cursor.execute(sql,param)
            last_id=int(self.cursor.lastrowid)
            self.conn.commit()
            return n,last_id
        except Exception as e:
            logging.error(str(e))
            return 0,0
    def del_testdata(self,param):
        try:
            sql="delete from tbl_testdata where id=%s"
            n=self.cursor.execute(sql,param)
            self.conn.commit()
            return n
        except Exception as e:
            logging.error(str(e))
    def del_datafile(self,param):
        try:
            sql="delete from tbl_datafile where testdata_id=%s"
            n=self.cursor.execute(sql,param)
            self.conn.commit()
            return n
        except Exception as e:
            logging.error(str(e))

    def query_datafile(self,param):
        try:
            s=DynSql("""select filename,filestr from tbl_datafile where 1=1
            { and testdata_id=$testdata_id}
            ORDER BY id DESC {limit {$offset,} $limit}""")
            sql=s(param)
            cnt=self.cursor.execute(sql[0],sql[1])
            ret=self.cursor.fetchall()
            return ret
        except Exception as e:
            logging.error(str(e))
    ##################################################################download stat操作####################################################
    def add_downloadstat(self,param):
        try:
            sql="""insert into tbl_downloadstat(id,type,user,time) values(NULL,%s,%s,%s)"""
            n=self.cursor.execute(sql,param)
            last_id=int(self.cursor.lastrowid)
            self.conn.commit()
            return n,last_id
        except Exception as e:
            logging.error(str(e))
            return 0,0
    def query_downloadstat(self,period,param):
        try:
            if(period == 1):
                s=DynSql("""select type,count(*) from tbl_downloadstat where 1=1
                { and id=$id} and DATE_SUB(CURDATE(), INTERVAL 7 DAY) <= date(time)
                group by type order by type""")
            else:
                s=DynSql("""select type,count(*) from tbl_downloadstat where 1=1
                { and id=$id}
                group by type order by type""")
            sql=s(param)
            #print sql[0] %sql[1]
            cnt=self.cursor.execute(sql[0],sql[1])
            ret=self.cursor.fetchall()
            return ret
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
    def query_task_totalcnt(self,param):
        try:
            s=DynSql("""select count(*) from tbl_task where 1=1
            { and belong=$belong}
            """)
            sql=s(param)
            cnt=self.cursor.execute(sql[0],sql[1])
            ret=self.cursor.fetchall()
            totalcnt=ret[0][0]
            return ret
        except Exception as e:
            logging.error(str(e))




if __name__ == "__main__":
    pass

