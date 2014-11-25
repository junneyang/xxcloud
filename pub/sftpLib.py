#!/usr/bin/python
# -*- coding: utf-8 -*-

import paramiko

def get_file(remotefilepath,localfilepath):
    try:
        t=paramiko.Transport((hostname, port))
        t.connect(username=username, password=password)
        sftp=paramiko.SFTPClient.from_transport(t)
        sftp.get(remotefilepath,localfilepath)
    except:
        print('get file error')
    finally:
        t.close()

if __name__ == "__main__":
    get_file('/home/map/importer/TgBrand0_import/status.txt','status.txt')
    import fileLib
    status=fileLib.get_file_lines('status.txt')
    print status
    print status[0]
    print status[0].strip()
