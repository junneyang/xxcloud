#!/usr/bin/env python
#-*- coding: utf-8 -*-
import tornado.web
import tornado.httpserver
import tornado.options
import tornado.ioloop
from tornado.options import define,options

import sys
import os
import time
import json


from common.logLib import *
from common.mysqlLib import *
from common.cmdLib import *
from common.sftpLib import *

import urlparse

defaultport=8886
import socket
hostname=socket.gethostname()
hostname=socket.gethostbyname(hostname)
#print hostname

import re
import urllib
#CAS setting
CAS_SETTINGS = {
	#replace this with your cas server url
	#'cas_server' : 'https://uuap.baidu.com/',
    'cas_server' : 'http://itebeta.baidu.com:8100',

	#replace this with your website url
	'service_url' : "http://"+hostname+":"+str(defaultport)+"/pb/",
	#CAS protocol version, 1.0 or 2.0? default is 2.0.
	'version' : 2
}

sys.path.append('../')
import gearmanjobclient
import querynodes
import gearmanjobstop

########################################
class authenticateBase(tornado.web.RequestHandler):
    def get_upps_user(self):
        #what you finally get
        userid = None
        try:
            server_ticket = self.get_argument( 'ticket' )
        except Exception, e:
            #print(str(e))
            return userid
        #validate the STprint server_ticket
        validate_suffix = '/validate' if CAS_SETTINGS[ 'version' ] == 1 else '/proxyValidate'
        validate_url = CAS_SETTINGS[ 'cas_server'] + validate_suffix + '?service=' + urllib.quote( CAS_SETTINGS[ 'service_url' ] ) + '&ticket=' + urllib.quote( server_ticket )
        #validate_url = CAS_SETTINGS[ 'cas_server'] + validate_suffix + '?service=' + urllib.quote( CAS_SETTINGS[ 'service_url' ] )
        response = urllib.urlopen( validate_url ).read()
        pattern = r'<cas:user>(.*)</cas:user>'
        match = re.search( pattern, response )
        if match:
            userid = match.groups()[ 0 ]
        if not userid:
            pass
        return userid
    def get_cookie_user(self):
        return self.get_secure_cookie("user")

class LoginHandler(authenticateBase):
    def get(self):
        userid=self.get_upps_user()
        if(userid):
            self.set_secure_cookie("user",userid)
            self.render("pb.html",usrname=userid)
        else:
            redirect_url = CAS_SETTINGS[ 'cas_server' ] + '/login?service=' + CAS_SETTINGS[ 'service_url' ]
            self.redirect( redirect_url )

class LogoutHandler(tornado.web.RequestHandler):
    def get( self ):
        #redirect to cas server
        self.clear_cookie("user")
        redirect_url = CAS_SETTINGS[ 'cas_server' ] + '/pb/logout'
        self.redirect( redirect_url )
########################################
class test(authenticateBase):
    def get(self):
        userid=self.get_cookie_user()
        testtype=pjt_id=self.get_argument("testtype").encode('utf-8')
        if(userid):
            if(testtype == "testpjt"):
                self.render("./test/test.testpjt.html",usrname=userid)
            elif(testtype == "testdown"):
                self.render("./test/test.testdown.html",usrname=userid)
            elif(testtype == "addtesttask"):
                self.render("./test/test.addtesttask.html",usrname=userid)
            else:
                pass
        else:
            redirect_url=CAS_SETTINGS[ 'cas_server' ] + '/login?service=' + CAS_SETTINGS[ 'service_url' ]
            self.redirect(redirect_url)
class task(authenticateBase):
    def get(self):
        userid=self.get_cookie_user()
        task=self.get_argument("task").encode('utf-8')
        if(userid):
            self.render("./test/test.querytask.html",usrname=userid)
        else:
            redirect_url=CAS_SETTINGS[ 'cas_server' ] + '/login?service=' + CAS_SETTINGS[ 'service_url' ]
            self.redirect(redirect_url)

class conf(authenticateBase):
    def get(self):
        userid=self.get_cookie_user()
        conftype=self.get_argument("conftype").encode('utf-8')
        if(userid):
            if(conftype == "testsrv"):
                self.render("./conf/conf.testsrv.html",usrname=userid)
            elif(conftype == "testdata"):
                self.render("./conf/conf.testdata.html",usrname=userid)
            elif(conftype == "addsrv"):
                self.render("./conf/conf.addsrv.html",usrname=userid)
            elif(conftype == "adddata"):
                self.render("./conf/conf.adddata.html",usrname=userid)
            else:
                pass
        else:
            redirect_url=CAS_SETTINGS[ 'cas_server' ] + '/login?service=' + CAS_SETTINGS[ 'service_url' ]
            self.redirect(redirect_url)

class stat(authenticateBase):
    def get(self):
        userid=self.get_cookie_user()
        if(userid):
            self.render("./stat/stat.stat.html",usrname=userid)
        else:
            redirect_url=CAS_SETTINGS[ 'cas_server' ] + '/login?service=' + CAS_SETTINGS[ 'service_url' ]
            self.redirect(redirect_url)

class add_server(authenticateBase):
    def post(self):
        post_param=urlparse.parse_qs(self.request.body,True)
        name=post_param['name'][0]
        ip=post_param['ip'][0]
        username=post_param['username'][0]
        password=post_param['password'][0]
        workspace=post_param['workspace'][0]
        belong=post_param['belong'][0]
        descpt=post_param['descpt'][0]

        param=(name,ip,username,password,workspace,belong,descpt)
        mysql=mysqlLib()
        n,last_id=mysql.add_server(param)
        mysql.close()
        ret_dict={"errcode":n}
        self.write(json.dumps(ret_dict))
class query_server(authenticateBase):
    def post(self):
        post_param=urlparse.parse_qs(self.request.body,True)
        limit=int(post_param['limit'][0])
        offset=int(post_param['offset'][0])
        belong=post_param['belong'][0]

        param={"belong":belong,"limit":limit,"offset":offset}
        mysql=mysqlLib()
        serverlist=mysql.query_server(param)

        param={"belong":belong}
        server_totalcnt=mysql.query_server_totalcnt(param)
        mysql.close()

        serverlist_info={}
        serverlist_info['server_totalcnt']=server_totalcnt
        ret_dict=[]
        for index,item in enumerate(serverlist):
            sub_ret_dict={}
            sub_ret_dict['id']=str(int(item[0]))
            sub_ret_dict['name']=item[1]
            sub_ret_dict['ip']=item[2]
            sub_ret_dict['workspace']=item[3]
            sub_ret_dict['belong']=item[4]
            sub_ret_dict['descpt']=item[5]
            ret_dict.append(sub_ret_dict)
        serverlist_info['ret_dict']=ret_dict

        self.write(json.dumps(serverlist_info))

class query_server_workspace(authenticateBase):
    def post(self):
        post_param=urlparse.parse_qs(self.request.body,True)
        srv_id=int(post_param['id'][0])

        param={"id":srv_id}
        mysql=mysqlLib()
        serverlist=mysql.query_server(param)
        mysql.close()

        ret_dict={}
        workspace=serverlist[0][3]
        ret_dict['workspace']=workspace

        self.write(json.dumps(ret_dict))

class del_server(authenticateBase):
    def post(self):
        post_param=urlparse.parse_qs(self.request.body,True)
        server_id=post_param['id'][0]

        param=(server_id,)
        mysql=mysqlLib()
        n=mysql.del_server(param)
        mysql.close()
        ret_dict={"errcode":n}
        self.write(json.dumps(ret_dict))

class add_testdata(authenticateBase):
    def post(self):
        post_param=urlparse.parse_qs(self.request.body,True)
        datatype=post_param['type'][0]
        name=post_param['name'][0]
        belong=post_param['belong'][0]
        filenum=post_param['filenum'][0]
        descpt=post_param['desc'][0]

        param=(datatype,name,belong,filenum,descpt)
        mysql=mysqlLib()
        n,last_id=mysql.add_testdata(param)
        mysql.close()
        ret_dict={"errcode":n,"last_id":last_id}
        self.write(json.dumps(ret_dict))

class upload_testdata(authenticateBase):
    def post(self):
        post_param=urlparse.parse_qs(self.request.body,True)
        json_postdata={}
        try:
            for i in post_param[' name']:
                json_postdata[i.split("\r\n")[0].strip("\"")]=i.split("\r\n")[2]
        except Exception:
            pass
        #print json_postdata
        mysql=mysqlLib()
        param=(json_postdata['last_id'],self.request.files['Filedata'][0]['filename'],self.request.files['Filedata'][0]['body'])
        n,last_id=mysql.add_datastr(param)
        mysql.close()
        ret_dict={"errcode":n}
        self.write(json.dumps(ret_dict))

        '''file_dict_list = self.request.files['Filedata']
        for file_dict in file_dict_list:
            filename = file_dict["filename"]
            f = open("../proto/" + filename, "wb")
            f.write(file_dict["body"])
            f.close()
        sub_ret_dict={}
        ret=u"文件上传成功"
        sub_ret_dict['msg']=ret
        self.write(json.dumps(sub_ret_dict))'''

class download_testtool(authenticateBase):
    def post(self):
        post_param=urlparse.parse_qs(self.request.body,True)
        tooltype=post_param['tooltype'][0]
        proto=post_param['proto'][0]
        srv=post_param['srv'][0]
        path=post_param['path'][0]
        belong=post_param['belong'][0]
        cutime=datetime.datetime.now().strftime("%y-%m-%d %H:%M:%S")

        param=(tooltype,belong,cutime)
        mysql=mysqlLib()
        n,last_id=mysql.add_downloadstat(param)
        '''param={}
        downloadstat=mysql.query_downloadstat(1,param)
        print downloadstat
        downloadstat=mysql.query_downloadstat(0,param)
        print downloadstat'''
        mysql.close()

        if(int(tooltype) == 1 or int(tooltype) == 3):
            param={"testdata_id":proto}
            mysql=mysqlLib()
            datafilelist=mysql.query_datafile(param)
            mysql.close()
            for item in datafilelist:
                filename=item[0]
                filestr=item[1]
                #print filename
                #print filestr
                f = open("../proto/" + filename, "w")
                f.write(filestr)
                f.close()
            cmdstr="cd ../proto/ && ./build.sh"
            status,output=cmd_execute(cmdstr)
            cmdstr="cd .. && comake2 && make"
            status,output=cmd_execute(cmdstr)
            if(int(tooltype) == 1):
                cmdstr="cd .. && tar -czvf pb.tar.gz conf data log pbrpcbenchmark proto README"
                status,output=cmd_execute(cmdstr)
            if(int(tooltype) == 3):
                cmdstr="cd .. && tar -czvf pb.tar.gz case conf data log pbrpcclient pbunittest.py proto pub README"
                status,output=cmd_execute(cmdstr)

            param={"id":srv}
            mysql=mysqlLib()
            srvlist=mysql.query_server(param)
            ip=srvlist[0][2]
            username=srvlist[0][6]
            password=srvlist[0][7]
            #workspace=srvlist[0][3]
            mysql.close()
            rootdir="/home/users/yangjun03/protobuf/workspace/app-test/search/lbs-stat/upps_test/jenkinsFramework/protobuf/"
            filepath="pb.tar.gz"
            remotepath=path + "/pb/"
            ssh_cmd(ip,22,username,password,"mkdir -p " + remotepath)
            put_file(ip,22,username,password,rootdir+filepath,remotepath+"/"+filepath)
            ssh_cmd(ip,22,username,password,"cd " + remotepath + " && tar -xzvf " + filepath)
            #删除tar包
            ssh_cmd(ip,22,username,password,"cd " + remotepath + " && rm " + filepath)
            #删除所有.svn
            ssh_cmd(ip,22,username,password,"cd " + remotepath + " && find . -type d -name '.svn' | xargs rm -rf")

            sub_ret_dict={}
            ret=u"测试工具下载成功"
            sub_ret_dict['msg']=ret
            self.write(json.dumps(sub_ret_dict))
        else:
            if(int(tooltype) == 2):
                cmdstr="cd ~/httpclient/ && tar -czvf http.tar.gz conf data dep httpbenchmark.jar log README simplehttpserver.jar"
                status,output=cmd_execute(cmdstr)
            if(int(tooltype) == 4):
                cmdstr="cd ~/httpclient/ && tar -czvf http.tar.gz case com conf data dep httpclient.jar httpunittest.py log README simplehttpserver.jar"
                status,output=cmd_execute(cmdstr)

            param={"id":srv}
            mysql=mysqlLib()
            srvlist=mysql.query_server(param)
            ip=srvlist[0][2]
            username=srvlist[0][6]
            password=srvlist[0][7]
            #workspace=srvlist[0][3]
            mysql.close()
            rootdir="/home/users/yangjun03/httpclient/"
            filepath="http.tar.gz"
            remotepath=path + "/http/"
            ssh_cmd(ip,22,username,password,"mkdir -p " + remotepath)
            put_file(ip,22,username,password,rootdir+filepath,remotepath+"/"+filepath)
            ssh_cmd(ip,22,username,password,"cd " + remotepath + " && tar -xzvf " + filepath)
            #删除tar包
            ssh_cmd(ip,22,username,password,"cd " + remotepath + " && rm " + filepath)
            #删除所有.svn
            ssh_cmd(ip,22,username,password,"cd " + remotepath + " && find . -type d -name '.svn' | xargs rm -rf")

            sub_ret_dict={}
            ret=u"测试工具下载成功"
            sub_ret_dict['msg']=ret
            self.write(json.dumps(sub_ret_dict))

class query_downloadstat(authenticateBase):
    def post(self):
        param={}
        mysql=mysqlLib()
        downloadstat_week=mysql.query_downloadstat(1,param)
        downloadstat_all=mysql.query_downloadstat(0,param)
        mysql.close()

        datalist_info={}
        ret_dict=[]
        tmp = {}
        for index,item in enumerate(downloadstat_week):
            tmp[int(item[0])] = int(item[1])
        for i in xrange(1,5):
            if(i not in tmp):
                ret_dict.append(0)
            else:
                ret_dict.append(tmp[i])
        datalist_info['week']=ret_dict

        ret_dict=[]
        for index,item in enumerate(downloadstat_all):
            ret_dict.append(int(item[1]))
        datalist_info['all']=ret_dict

        self.write(json.dumps(datalist_info))

class del_testdata(authenticateBase):
    def post(self):
        post_param=urlparse.parse_qs(self.request.body,True)
        testdata_id=post_param['id'][0]

        param=(testdata_id,)
        mysql=mysqlLib()
        n=mysql.del_testdata(param)
        m=mysql.del_datafile(param)
        mysql.close()
        ret_dict={"errcoden":n,"errcodem":m}
        self.write(json.dumps(ret_dict))

class query_testdata(authenticateBase):
    def post(self):
        post_param=urlparse.parse_qs(self.request.body,True)
        limit=int(post_param['limit'][0])
        offset=int(post_param['offset'][0])
        belong=post_param['belong'][0]
        datatype=post_param['datatype'][0]

        if(datatype == -1):
            param={"belong":belong,"limit":limit,"offset":offset}
        else:
            param={"belong":belong,"type":datatype,"limit":limit,"offset":offset}
        mysql=mysqlLib()
        datalist=mysql.query_testdata(param)

        if(datatype == -1):
            param={"belong":belong}
        else:
            param={"belong":belong,"type":datatype}
        data_totalcnt=mysql.query_testdata_totalcnt(param)
        mysql.close()

        datalist_info={}
        datalist_info['data_totalcnt']=data_totalcnt
        ret_dict=[]
        for index,item in enumerate(datalist):
            sub_ret_dict={}
            sub_ret_dict['id']=str(int(item[0]))
            sub_ret_dict['name']=item[1]
            sub_ret_dict['type']=item[2]
            sub_ret_dict['belong']=item[3]
            sub_ret_dict['filenum']=item[4]
            sub_ret_dict['descpt']=item[5]
            ret_dict.append(sub_ret_dict)
        datalist_info['ret_dict']=ret_dict

        self.write(json.dumps(datalist_info))

class jobstatusubmit(tornado.web.RequestHandler):
    def post(self):
        try:
            jsonobj = json.loads(self.request.body)
            UserName = jsonobj['UserName']
            JenkinsURL = jsonobj['JenkinsURL']
            JobName = jsonobj['JobName']
            SpecifyNode = int(jsonobj['SpecifyNode'])
            JobParameter = jsonobj['JobParameter']

            for item in JobParameter:
                if(type(JobParameter[item]) == list or type(JobParameter[item]) == dict):
                    JobParameter[item] = json.dumps(JobParameter[item])
            #print JobParameter
            url = gearmanjobclient.addtask(UserName, JenkinsURL, JobName, SpecifyNode, JobParameter)
            ret_info = {"ret":url}
            self.write(json.dumps(ret_info))
        except Exception as e:
            print(e)
            ret_info = {"ret":"ERROR : internal error"}
            self.write(json.dumps(ret_info))

class query_nodes(tornado.web.RequestHandler):
    def post(self):
        try:
            jsonobj = json.loads(self.request.body)
            UserName = jsonobj['UserName']
            JenkinsURL = jsonobj['JenkinsURL']
            nodelist = querynodes.querynodes(JenkinsURL)
            print nodelist
            ret_info = {"ret":nodelist}
            self.write(json.dumps(ret_info))
        except Exception as e:
            print(e)
            ret_info = {"ret":"ERROR : internal error"}
            self.write(json.dumps(ret_info))

class jobstatus(tornado.web.RequestHandler):
    def post(self):
        #post_param=urlparse.parse_qs(self.request.body,True)
        #print self.request.body
        jsonobj = json.loads(self.request.body)
        unique_id = jsonobj['build']['parameters']['UNIQUE_ID']
        number = jsonobj['build']['number']
        phase = jsonobj['build']['phase']
        if (phase == "STARTED"):
            mysql = mysqlLib()
            param=(2, unique_id)
            mysql.update_task_status(param)
            print(u"#RUNNING, job running, 2")

            param=(number, unique_id)
            mysql.update_task_build_number(param)
            mysql.close()
        elif (phase == "FINALIZED" or phase == "COMPLETED"):
            status = jsonobj['build']['status']
            if (status == "SUCCESS"):
                mysql = mysqlLib()
                param=(3, unique_id)
                mysql.update_task_status(param)
                print(u"#SUCCESS, job complete, 3")
                mysql.close()
            elif (status == "ABORTED"):
                mysql = mysqlLib()
                param=(5, unique_id)
                mysql.update_task_status(param)
                print(u"#ABORTED, job aborted, 3")
                mysql.close()
            else:
                mysql = mysqlLib()
                param=(4, unique_id)
                mysql.update_task_status(param)
                print(u"#ERROR, job failed, 4")
                mysql.close()
        else:
            mysql = mysqlLib()
            param=(4, unique_id)
            mysql.update_task_status(param)
            print(u"#ERROR, job failed, 4")
            mysql.close()
    def get(self):
        unique_id = self.get_argument("job").encode('utf-8')
        param={"id":unique_id}
        mysql=mysqlLib()
        datalist=mysql.query_task(param)
        mysql.close()
        #print datalist
        datalist_info={}
        datalist_info['submit'] = datalist[0][1]
        datalist_info['url'] = datalist[0][2]
        datalist_info['jobname'] = datalist[0][3]
        datalist_info['status'] = datalist[0][5]
        datalist_info['build_number'] = datalist[0][6]
        #print datalist_info
        cmdstr = "curl " + datalist_info['url'] + "job/" + datalist_info['jobname'] + "/" + str(datalist_info['build_number']) + "/logText/progressiveText?start=0"
        #print cmdstr
        if (datalist_info['status'] == 3 or datalist_info['status'] == 4 or datalist_info['status'] == 5):
            status,output=cmd_execute(cmdstr)
        else:
            output = "INFO, job is running now"
        datalist_info['output'] = output
        self.write(json.dumps(datalist_info))

class jobstop(tornado.web.RequestHandler):
    def post(self):
        jsonobj = json.loads(self.request.body)
        unique_id = jsonobj['UNIQUE_ID']
        datalist_info = gearmanjobstop.gearmanjobstop(unique_id)
        print datalist_info
        self.write(json.dumps(datalist_info))

if __name__ == "__main__":
    settings={"template_path": os.path.join(os.path.dirname(__file__), "template") ,
    "static_path": os.path.join(os.path.dirname(__file__), "static") ,
    "debug":False,
    "cookie_secret":"61oETzKXQAGaYdkL5gEmGeJJFuYh7EQnp2XdTP1o/Vo="}
    define("port", default=defaultport, help="run on the given port", type=int)

    tornado.options.parse_command_line()
    app=tornado.web.Application(handlers=[
    ( r'/pb/test/', test),
    ( r'/pb/task/', task),
    ( r'/pb/conf/', conf),
    ( r'/pb/stat/', stat),
    ( r'/pb/add_server/', add_server),
    ( r'/pb/query_server/', query_server),
    ( r'/pb/del_server/', del_server),
    ( r'/pb/query_server_workspace/', query_server_workspace),
    ( r'/pb/add_testdata/', add_testdata),
    ( r'/pb/upload_testdata/', upload_testdata),
    ( r'/pb/query_testdata/', query_testdata),
    ( r'/pb/del_testdata/', del_testdata),
    ( r'/pb/download_testtool/', download_testtool),
    ( r'/pb/query_downloadstat/', query_downloadstat),
    ( r'/pb/', LoginHandler),
    ( r'/pb/logout/',LogoutHandler),

    ( r'/pb/jenkins/submit/',jobstatusubmit),
    ( r'/pb/jenkins/status/',jobstatus),
    ( r'/pb/jenkins/jobstop/',jobstop),
    ( r'/pb/jenkins/querynodes/',query_nodes),

    ],**settings
    )
    HttpServer=tornado.httpserver.HTTPServer(app)
    HttpServer.listen(options.port)
    tornado.ioloop.IOLoop.instance().start()

