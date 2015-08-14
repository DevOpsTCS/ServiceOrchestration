import sys
import MySQLdb

cnx = MySQLdb.connect(user='root', passwd="test",db="Devops")
cur= cnx.cursor()
cur.execute("update devops_images set Deployed_VM_IP='"+sys.argv[1]+"' where image_name='"+sys.argv[2]+"'")
cnx.commit()
