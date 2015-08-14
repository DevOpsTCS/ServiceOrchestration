from django.shortcuts import render
from django.shortcuts import render_to_response
from django.template import RequestContext, loader
from django.http import HttpResponse
import MySQLdb
import subprocess
import os
from os import listdir
from os.path import isfile, join

def files_in_path():
    mypath='/home/tcs/DEVOPS/repo_iso'
    onlyfiles = [ f for f in listdir(mypath) if isfile(join(mypath,f))]
    return onlyfiles

def database_path():
    try:
        cnx = MySQLdb.connect(user='root', passwd="test",db="Devops")
        cur= cnx.cursor()
        cur.execute("select * from devops_images")
        a= cur.fetchall()
        b= list(a)
    except:
        b=()
    return b

def database_status(path_var):
    try:
        cnx = MySQLdb.connect(user='root', passwd="test",db="Devops")
        cur= cnx.cursor()
        cur.execute("select status from devops_images where image_name="+`str(path_var)`)
        a= cur.fetchall()
        b= a[0][0]
        print b
    except:
        b=()
    return b

def index(request):
    t = loader.get_template('click.html')
    files_path=database_path()
    c = RequestContext(request,{'test':files_path})
    return HttpResponse(t.render(c))

def click(request):
    t = loader.get_template('click.html')
    files_path=database_path()
    c = RequestContext(request,{'test':files_path})
    return HttpResponse(t.render(c))


def run(request):
    PATH_VAR=request.path
    path=PATH_VAR.split('/')    
    path_var=path[1]
    output= None
    status=database_status(path_var)
    if status == "disable":
        p= subprocess.Popen(["/bin/bash","/home/tcs/DEVOPS_MIGRATION/myproject/vm_launch1.sh",path_var,' &'], stdout=subprocess.PIPE)
        output, err = p.communicate()
        print output
        cnx = MySQLdb.connect(user='root', passwd="test",db="Devops")
        cur = cnx.cursor()
        cur.execute("update devops_images set status='running' where image_name="+`str(path_var)`)
        cnx.commit()
    elif status == "running":
        p= subprocess.Popen(["/bin/bash","/home/tcs/DEVOPS_MIGRATION/myproject/vm_terminate.sh",path_var], stdout=subprocess.PIPE)
        output, err = p.communicate()
        cnx = MySQLdb.connect(user='root', passwd="test",db="Devops")
        cur = cnx.cursor()
        cur.execute("update devops_images set status='disable' where image_name="+`str(path_var)`)
        cnx.commit()       
    
    t = loader.get_template('click.html')
    files_path=database_path()
#    bashCommand = "sh /home/tcs/test-launch.sh "+path_var
#    os.system(bashCommand)
    if status=="running":
        
        c = RequestContext(request,{'path':path_var,'button_name':'Terminate','test':files_path})
        return HttpResponse(t.render(c))

    else:
        #print "OUTPUT HI"
        c = RequestContext(request,{'path':path_var,'button_name':'Deploy','test':files_path})
        return HttpResponse(t.render(c))
    


    #return render(request,'click.html')
