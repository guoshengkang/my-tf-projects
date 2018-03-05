#!/usr/bin/python
# -*- coding: utf-8 -*-
import numpy as np
import pandas as pd
import os,sys,re
from pandas import Series,DataFrame
import datetime
import time
reload(sys)
sys.setdefaultencoding('utf-8')
starttime = datetime.datetime.now()    

#######################################################
dictionary_path = os.path.join(os.path.split(os.path.realpath(__file__))[0], "dict.txt")
dictionary=[]
with open(dictionary_path, "r") as fin:
  for line in fin.readlines():
    line=unicode(line.strip(), "utf-8")
    dictionary.append(line)
print "There are %d keywords in the dictionary file!!!"%len(dictionary)

df_path=os.path.join(os.path.split(os.path.realpath(__file__))[0], "df.csv")
fout=open(df_path,'w')
fout.write(','.join(dictionary).encode('utf-8')+'\n')

samples_path = os.path.join(os.path.split(os.path.realpath(__file__))[0], "sample_160000_test")
fin=open(samples_path)
lines=fin.readlines()
row_num=len(lines) #文件的行数
col_num=len(dictionary)
print "There are %d lines in the input file!!!"%row_num

for row,line in enumerate(lines): #row：0,1,2,3,...
  tmp_list=[u'0']*col_num # 初始化
  line=unicode(line.strip(),'utf-8')
  uid,label,group_name,keywords,province,tier,head,tail,subroots=line.split(unicode(',','utf-8'))
  tmp_list[0]=label
  group_feature='group_'+group_name
  if group_feature in dictionary:
      index=dictionary.index(group_feature)
      tmp_list[index]=u'1'
  keyword_list=keywords.split(unicode(';','utf-8'))
  for keyword in keyword_list:
    if keyword in dictionary:
      index=dictionary.index(keyword)
      tmp_list[index]=u'1'
  subroot_list=subroots.split(unicode(';','utf-8'))
  for subroot in subroot_list:
    subroot_feature='subroot_'+subroot
    if subroot_feature in dictionary:
      index=dictionary.index(subroot_feature)
      tmp_list[index]=u'1'
  keyword_province='province_'+province
  keyword_tier='tier_'+tier
  keyword_head='head_'+head
  keyword_tail='tail_'+tail
  for keyword in [keyword_province,keyword_tier,keyword_head,keyword_tail]:
    if keyword in dictionary:
      index=dictionary.index(keyword)
      tmp_list[index]=u'1'
  fout.write(','.join(tmp_list).encode('utf-8')+'\n')
  if row % 10000 == 0 :
    print "time:%s,"%(time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))), # 打印当前时间
    print '%d rows have been written!!!'%row
fin.close()
fout.close()
#####################################################

endtime = datetime.datetime.now()
print (endtime - starttime),"time used!!!" #0:00:00.280797