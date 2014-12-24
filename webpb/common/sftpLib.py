#!/usr/bin/python
# -*- coding: utf-8 -*-
'''
hostname='st01-lbs-upps-import00.st01'
port=22
username='root'
password='UIOJKL'
'''

import paramiko

def get_file(hostname,port,username,password,remotefilepath,localfilepath):
    try:
        t=paramiko.Transport((hostname, port))
        t.connect(username=username, password=password)
        sftp=paramiko.SFTPClient.from_transport(t)
        sftp.get(remotefilepath,localfilepath)
    except Exception as e:
        print(e)
    finally:
        t.close()

def put_file(hostname,port,username,password,localfilepath,remotefilepath):
    try:
        t=paramiko.Transport((hostname, port))
        t.connect(username=username, password=password)
        sftp=paramiko.SFTPClient.from_transport(t)
        #sftp.mkdir(remotefiledir)
        #sftp.chdir(remotefiledir)
        sftp.put(localfilepath,remotefilepath)
    except Exception as e:
        print(e)
    finally:
        t.close()

def ssh_cmd(hostname,port,username,password,cmd_str):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname,22,username, password)
    stdin, stdout, stderr = ssh.exec_command(cmd_str)
    retstr=""
    for line in stdout:
        retstr+=line
    ssh.close()
    return retstr

if __name__ == "__main__":
    get_file('/home/map/importer/TgBrand0_import/status.txt','status.txt')
    import fileLib
    status=fileLib.get_file_lines('status.txt')
    print status
    print status[0]
    print status[0].strip()
