#!/usr/bin/env python
#-*- coding: utf-8 -*-
import tornado.web
import tornado.httpserver
import tornado.options
import tornado.ioloop
from tornado.options import define,options

class helloworld(tornado.web.RequestHandler):
    def get(self):
        Name=self.get_argument("Name")
        Info=self.get_argument("Info")
        self.render("helloworld.html",Method="GET_Test",Name=Name,Info=Info)
    def post(self):
        Name=self.get_argument("Name")
        Info=self.get_argument("Info")
        self.render("helloworld.html",Method="POST_Test",Name=Name,Info=Info)
class asyntest(tornado.web.RequestHandler):
    def get(self):
        Para=self.get_argument("Para")
        #构造延时说明同步模式客户端效率不高
        #time.sleep(0.001)
        self.write("Result:"+Para+"\n")

if __name__ == "__main__":
    define("port", default=8080, help="run on the given port", type=int)
    tornado.options.parse_command_line()
    app=tornado.web.Application(handlers=[
    (r"/helloworld/",helloworld),
    (r"/asyntest/",asyntest),
    ])
    HttpServer=tornado.httpserver.HTTPServer(app)
    HttpServer.listen(options.port)
    tornado.ioloop.IOLoop.instance().start()
