#!/usr/bin/python
# -*- coding: utf-8 -*-
import numpy as np
import math
import datetime
import time,os
from numpy import *
###################################
# 函数定义
def fun_tanh(x):
    y=(1.0-np.exp(-2.0*x))/(1.0+np.exp(-2.0*x))
    return y

def fun_sigmoid(x):
    y=1.0/(1.0+np.exp(-x))
    return y

def deep_learning_score(wb,x):
    # wb=[(w1,b1),(w2,b2),(w3,b3),(w4,b4)]
    x=mat(x)
    length=len(wb)
    for (w,b) in wb[:length-1]:
        x=fun_tanh(x*w+b)
    (w,b)=wb[-1] #输出层的结果
    y=fun_sigmoid(x*w+b)
    return y[0,0] #返回一个数,而不是矩阵

def process_file(input_file_path,output_file_path,dictionary,col_num,wb):
  starttime = datetime.datetime.now() 
  if not os.path.exists(input_file_path):
    input_file_tag = -1
    print input_file_path,'does not exist!!!'
  else:
    input_file_data = open(input_file_path, "r")
    input_file_tag = 1
  result_num=0
  if input_file_tag==1:
    result_data=open(output_file_path,"w") #创建输出文件
    result_data.close()
    while True:
      full_line=input_file_data.readline()
      if not full_line:
        break
      result_num+=1
      if result_num % 10000 == 0 :
        print "%s,line_no:%d in file:%s"%(time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time())),result_num,input_file_path)
      tmp_arr=np.zeros((1,col_num)) # 初始化(1L, 6416L) tmp_arr.dtype=float64
      line=unicode(full_line.strip(),'utf-8')
      uid,keywords,province,tier,head,tail=line.split(unicode(',','utf-8'))
      keyword_list=keywords.split(unicode(';','utf-8'))
      for keyword in keyword_list:
        if keyword in dictionary:
          index=dictionary.index(keyword)
          tmp_arr[0,index]=1.0
      keyword_province='province_'+province
      keyword_tier='tier_'+tier
      keyword_head='head_'+head
      keyword_tail='tail_'+tail
      for keyword in [keyword_province,keyword_tier,keyword_head,keyword_tail]:
        if keyword in dictionary:
          index=dictionary.index(keyword)
          tmp_arr[0,index]=1.0
      x=tmp_arr
      y=deep_learning_score(wb,x)
      new_line="%s,%.9f"%(uid,y)
      result_data = open(output_file_path, "a")
      result_data.write(new_line.encode('utf-8')+'\n')
      result_data.close()          
  print "There are %d lines in file '%s'," % (result_num,os.path.basename(input_file_path)),
  endtime = datetime.datetime.now()
  print "and %s time was used for processing file '%s'!!!"%((endtime - starttime),os.path.basename(input_file_path))#0:00:00.280797

##################################################
# 读取数据
w1=np.loadtxt('w1.txt',delimiter=',')
w2=np.loadtxt('w2.txt',delimiter=',')
w3=np.loadtxt('w3.txt',delimiter=',')
w4=np.loadtxt('w4.txt',delimiter=',')
w5=np.loadtxt('w5.txt',delimiter=',')
w5=w5.reshape(-1,1) #(128L,)-->(128L,1)
# print w1.shape,w2.shape,w3.shape,w4.shape
# (6416L, 128L) (128L, 128L) (128L, 128L) (128L, 1L)
b1=np.loadtxt('b1.txt',delimiter=',')
b2=np.loadtxt('b2.txt',delimiter=',')
b3=np.loadtxt('b3.txt',delimiter=',')
b4=np.loadtxt('b4.txt',delimiter=',') #<type 'numpy.ndarray'>
b5=np.loadtxt('b5.txt',delimiter=',') 
wb=[(w1,b1),(w2,b2),(w3,b3),(w4,b4),(w5,b5)]

dictionary_path = os.path.join(os.path.split(os.path.realpath(__file__))[0], "dict-label.txt")
dictionary=[]
with open(dictionary_path, "r") as fin:
  for line in fin.readlines():
    line=unicode(line.strip(), "utf-8")
    dictionary.append(line)
print "There are %d keywords in the dictionary file!!!"%len(dictionary)
col_num=len(dictionary) 

# -------------------------------修改参数-----------------------------------------------
log_path = os.path.join(os.path.split(os.path.realpath(__file__))[0], "log1.txt") # 日志文件记录已处理的文件名称
fin_path = os.path.join(os.path.split(os.path.realpath(__file__))[0], 'inputfile1')
fout_path = os.path.join(os.path.split(os.path.realpath(__file__))[0], 'outputfile1')
# ---------------------------------------------------------------------------------------

if not os.path.exists(log_path): #若日志文件不存在,则创建该文件
  log_file=open(log_path,"w")
  log_file.close()
log=[]
with open(log_path, "r") as fin:
  for line in fin.readlines():
    line=unicode(line.strip(), "utf-8")
    log.append(line)
##################################################################
# 处理文件
tuples=os.walk(fin_path) #返回生成器
file_number=0
file_paths=[]
for tup in tuples:
  files=tup[2] #tup[2]为tup[0]目录下的文件名列表=tup[2]
  if files: #不为[]
    for file in files:
      sourcefile_path=os.path.join(tup[0], file)
      file_paths.append(sourcefile_path)
print "there are %d files in %s"%(len(file_paths),fin_path)
print "and %d files have been processed already!!!"%len(log)

for index,file_path in enumerate(file_paths):
  input_file_path=file_path
  file_name=str(index)+'_'+os.path.basename(input_file_path)
  output_file_path=os.path.join(fout_path, file_name)
  if input_file_path not in log:
    try:
      process_file(input_file_path,output_file_path,dictionary,col_num,wb)
      print "in/output filenames:%s-->%s"%(os.path.basename(input_file_path),os.path.basename(output_file_path))
      log_fout = open(log_path, "a")
      log_fout.write(input_file_path+'\n')
      log_fout.close()   
    except Exception as e:
      print 'ERROR:[%s]' % e
  else:
    print "file '%s' has been processed already!!!"%os.path.basename(input_file_path)
########################################