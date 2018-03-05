#!/usr/bin/python
# -*- coding: utf-8 -*-
# import tensorflow as tf  
from numpy.random import RandomState  
import numpy as np
import math
import datetime
import time,os
from numpy import *
starttime = datetime.datetime.now()    
###################################
score_stat_path = os.path.join(os.path.split(os.path.realpath(__file__))[0], "top_label_score_stat.csv")
fout=open(score_stat_path,'w')
data=np.loadtxt('uid_label_score.txt',delimiter=',', usecols=(1,2))
print data.shape,data.shape
sorted_data=data[np.lexsort(-data.T)] # 按最后一列逆序排序
num=200000
stat=dict()
# 字典初始化
interval=0.05
interval_num=int(interval*num)
print "interval_num",interval_num
for start in arange(0,1.0,interval):
  end=start+interval
  myrange="[top%.0f-%.0f)"%(end*100,start*100)
  up_bound=int(num*start)
  low_bound=int(num*end)
  positive_num=int(sum(data[up_bound:low_bound,0]))
  nagative_num=interval_num-positive_num
  line="%s,%d-%d,%d,%d"%(myrange,up_bound,low_bound,nagative_num,positive_num)
  fout.write(line+'\n')
  print line
fout.close()
########################################
endtime = datetime.datetime.now()
print (endtime - starttime),"time used!!!" #0:00:00.280797
print "Finished!!!"

