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

dictionary_path = os.path.join(os.path.split(os.path.realpath(__file__))[0], "dict-label.txt")
dictionary=[]
with open(dictionary_path, "r") as fin:
  for line in fin.readlines():
    line=unicode(line.strip(), "utf-8")
    dictionary.append(line)
print "There are %d keywords in the dictionary file!!!"%len(dictionary)

samples_path = os.path.join(os.path.split(os.path.realpath(__file__))[0], "test_500000")
fin=open(samples_path)
lines=fin.readlines()
row_num=len(lines) #文件的行数
col_num=len(dictionary)
print "There are %d lines in the input file!!!"%row_num

fout_path=os.path.join(os.path.split(os.path.realpath(__file__))[0], "uid_label_score.txt")
fout=open(fout_path,'w')

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

stat=dict()
# 字典初始化
interval=0.05
for start in arange(0,1.0,interval):
  end=start+interval
  key="[%.2f-%.2f)"%(start,end)
  stat[key]=[0,0]

for row,line in enumerate(lines): # row：0,1,2,3,...
  tmp_arr=np.zeros((1,col_num)) # 初始化(1L, 6416L) tmp_arr.dtype=float64
  line=unicode(line.strip(),'utf-8')
  uid,label,keywords,province,tier,head,tail=line.split(unicode(',','utf-8'))
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
  new_line="%s,%s,%.9f"%(uid,label,y)
  fout.write(new_line+'\n')
  #统计得分所在的分段
  for start in arange(0,1.0,interval):
    end=start+interval
    key="[%.2f-%.2f)"%(start,end)
    if start<=y<end:
      if label==u'0':
        stat[key][0]=stat[key][0]+1
      else:
        stat[key][1]=stat[key][1]+1
      break
  if row % 10000 == 0 :
    print "time:%s,row_no:%d"%(time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time())),row) # 打印当前时间
fin.close()
fout.close()

score_stat_path = os.path.join(os.path.split(os.path.realpath(__file__))[0], "label_score_stat.csv")
fout=open(score_stat_path,'w')
for start in arange(0,1.0,interval):
  end=start+interval
  key="[%.2f-%.2f)"%(start,end)
  print key,stat[key][0],stat[key][1]
  line="%s,%d,%d"%(key,stat[key][0],stat[key][1])
  fout.write(line+'\n')
fout.close()
########################################
endtime = datetime.datetime.now()
print (endtime - starttime),"time used!!!" #0:00:00.280797
print "Finished!!!"


# #定义输入和输出  
# x = tf.placeholder(tf.float32,shape=(None,x_dim),name="x-input")  
# y = tf.placeholder(tf.float32,shape=(None,1),name="y-input")  

# #定义神经网络的参数
# #第一个隐层
# w1 = tf.Variable(tf.random_normal([x_dim,unit_num],stddev=1,seed=1)) #6235行,10列
# b1 = tf.Variable(tf.zeros([1,unit_num])) # 1,10
# z1 = tf.matmul(x, w1)+b1 # 
# a1 = tf.nn.tanh(z1) #使用tanh函数作为激活函数
# #第二个隐层
# w2 = tf.Variable(tf.random_normal([unit_num,unit_num])) #10行10列
# b2 = tf.Variable(tf.zeros([1,unit_num])) # 1,10
# z2 = tf.matmul(a1, w2)+b2 # 
# a2 = tf.nn.tanh(z2) #使用tanh函数作为激活函数
# #第三个隐层
# w3 = tf.Variable(tf.random_normal([unit_num,unit_num])) #10行10列
# b3 = tf.Variable(tf.zeros([1,unit_num])) # 1,10
# z3 = tf.matmul(a2, w3)+b3 # 
# a3 = tf.nn.tanh(z3) #使用tanh函数作为激活函数

# #定义神经网络输出层
# w4 = tf.Variable(tf.random_normal([unit_num,1]))
# b4 = tf.Variable(tf.zeros([1,1]))
# z4 = tf.matmul(a3,w4) + b4
# prediction = tf.nn.sigmoid(z4)

# # 训练数据集 
# X_train = np.load('160000_X_train.npy')   
# print "train samples:",X_train.shape
# y_train = np.load('160000_y_train.npy') 
# train_num = y_train.shape[0]
# top20_train = int(top_percentage*train_num)
# y_train = y_train.reshape([train_num,1]) # 转成nx1数组
# dataset_size=train_num # 训练样本数目

# # 测试数据集
# X_test = np.load('160000_X_test.npy')   
# print "test samples:",X_test.shape
# y_test = np.load('160000_y_test.npy') 
# test_num = y_test.shape[0]
# print y_test.shape
# top20_test = int(top_percentage*test_num)
# y_test = y_test.reshape([test_num,1]) # 转成nx1数组

# # 定义损失函数,这里只需要刻画模型在训练数据上表现的损失函数
# mse_loss = tf.reduce_mean(tf.square(y - prediction))
# # 这个函数第一个参数是'losses'是集合的名字,第二个参数是要加入这个集合的内容
# tf.add_to_collection('losses',tf.contrib.layers.l2_regularizer(0.001)(w1))
# tf.add_to_collection('losses',tf.contrib.layers.l2_regularizer(0.001)(w2))
# tf.add_to_collection('losses',tf.contrib.layers.l2_regularizer(0.001)(w3))
# tf.add_to_collection('losses',tf.contrib.layers.l2_regularizer(0.001)(w4))
# # 将均方误差损失函数加入损失集合
# tf.add_to_collection('losses',mse_loss)
# # 将集合中的元素加起来,得到最终的损失函数
# loss=tf.add_n(tf.get_collection('losses'))

# # 定义反向传播算法的优化函数
# global_step=tf.Variable(0)
# decay_steps = 2*int(math.ceil(train_num/batch_size)) #衰减速度
# decay_rate = 0.96 # 衰减系数
# learning_rate = tf.train.exponential_decay(0.2,global_step,decay_steps,decay_rate,staircase=True) #初始学习率为0.2
# my_opt = tf.train.GradientDescentOptimizer(learning_rate)
# train_step = my_opt.minimize(loss,global_step=global_step)

# # 参数输出格式
# fmt=['%.9f']
# w1_fmt=unit_num*fmt
# w2_fmt=unit_num*fmt
# w3_fmt=unit_num*fmt
# w4_fmt=fmt

# #创建会话运行TensorFlow程序  
# with tf.Session() as sess:  
#     #初始化变量  tf.initialize_all_variables()  
#     init = tf.initialize_all_variables()  
#     sess.run(init)  
#     for i in range(steps):  
#         #每次选取batch_size个样本进行训练  
#         start = (i * batch_size) % dataset_size  
#         end = min(start + batch_size,dataset_size)
#         #通过选取样本训练神经网络并更新参数  
#         X_batch=X_train[start:end];y_batch=y_train[start:end]
#         sess.run(train_step,feed_dict={x:X_batch,y:y_batch})  
#         #每迭代100次输出一次日志信息  
#         if i % 100 == 0 :
#             print "time:%s,"%(time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))), # 打印当前时间
#             # print "learning_rate:%0.6f,"%sess.run(learning_rate), # 打印学习率
#             # 计算训练数据的损失之和  
#             total_loss = sess.run(loss,feed_dict={x:X_batch,y:y_batch})  
#             print "training_steps:%05d, total_loss:%0.6f,"%(i,total_loss),
#             # 对训练数据进行预测
#             # prediction_value = sess.run(prediction,feed_dict={x:X_batch}) # mx1
#             # c= np.c_[y_batch,prediction_value] # 将标签和得分合在一个数组中
#             # sorted_c=c[np.lexsort(-c.T)] # 按最后一列逆序排序
#             # print "[%0.6f,%0.6f],"%(sorted_c[top20_train-1,1],sorted_c[0,1]),
#             # positive_num=sum(sorted_c[:top20_train,0]);negative_num=top20_train-positive_num
#             # print "positive_rate:%0.6f,"%(positive_num/top20_train),
#             # prediction_label = np.array([[1 if p_value[0]>=0.5 else 0] for p_value in prediction_value]) # mx1
#             # yes_no=(prediction_label==y_train)
#             # print "prediction_accuracy:%0.6f on train data;"%(yes_no.sum()/float(train_num)),
#             # 对测试数据进行预测
#             prediction_value = sess.run(prediction,feed_dict={x:X_test}) # mx1
#             c= np.c_[y_test,prediction_value] # 将标签和得分合在一个数组中
#             sorted_c=c[np.lexsort(-c.T)] # 按最后一列逆序排序
#             print "[%0.6f,%0.6f],"%(sorted_c[top20_test-1,1],sorted_c[0,1]),
#             positive_num=sum(sorted_c[:top20_test,0]);negative_num=top20_test-positive_num
#             print "positive_rate:%0.6f,"%(positive_num/top20_test),
#             prediction_label = np.array([[1 if p_value[0]>=0.5 else 0] for p_value in prediction_value]) # mx1
#             yes_no=(prediction_label==y_test)
#             print "prediction_accuracy:%0.6f on test data"%(yes_no.sum()/float(test_num))
#     #模型训练结束,输出和保存参数
#     # print(w1.eval(session=sess)) 
#     parameter_w1=w1.eval(session=sess)
#     np.savetxt('w1.txt',parameter_w1,fmt=w1_fmt,delimiter=',') 
#     parameter_b1=b1.eval(session=sess)
#     np.savetxt('b1.txt',parameter_b1,fmt=w1_fmt,delimiter=',') 
    
#     parameter_w2=w2.eval(session=sess)
#     np.savetxt('w2.txt',parameter_w2,fmt=w2_fmt,delimiter=',') 
#     parameter_b2=b2.eval(session=sess)
#     np.savetxt('b2.txt',parameter_b2,fmt=w2_fmt,delimiter=',') 

#     parameter_w3=w3.eval(session=sess)
#     np.savetxt('w3.txt',parameter_w3,fmt=w3_fmt,delimiter=',') 
#     parameter_b3=b3.eval(session=sess)
#     np.savetxt('b3.txt',parameter_b3,fmt=w3_fmt,delimiter=',') 

#     parameter_w4=w4.eval(session=sess)
#     np.savetxt('w4.txt',parameter_w4,fmt=w4_fmt,delimiter=',') 
#     parameter_b4=b4.eval(session=sess)
#     np.savetxt('b4.txt',parameter_b4,fmt=w4_fmt,delimiter=',') 

# endtime = datetime.datetime.now()
# print (endtime - starttime),"time used!!!" #0:00:00.280797

# print "Finished!!!"