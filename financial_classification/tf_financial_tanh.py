#!/usr/bin/python
# -*- coding: utf-8 -*-
import tensorflow as tf  
from numpy.random import RandomState  
import numpy as np
import datetime
import time
starttime = datetime.datetime.now()    
###################################
# 参数设置
x_dim = 6212 # 样本数据的维度
unit_num = 128 # 每个隐层包含的神经元数
batch_size = 5000 # 定义每次训练数据batch的大小,防止内存溢出 
steps = 100000 # 设置神经网络的迭代次数 
top_percentage = 0.2 # 用于统计前%20得分的正负样本数
###################################

#定义输入和输出  
x = tf.placeholder(tf.float32,shape=(None,x_dim),name="x-input")  
y = tf.placeholder(tf.float32,shape=(None,1),name="y-input")  

#定义神经网络的参数
#第一个隐层
w1 = tf.Variable(tf.random_normal([x_dim,unit_num],stddev=1,seed=1)) #6235行,10列
b1 = tf.Variable(tf.zeros([1,unit_num])) # 1,10
z1 = tf.matmul(x, w1)+b1 # 
a1 = tf.nn.tanh(z1) #使用tanh函数作为激活函数
#第二个隐层
w2 = tf.Variable(tf.random_normal([unit_num,unit_num])) #10行10列
b2 = tf.Variable(tf.zeros([1,unit_num])) # 1,10
z2 = tf.matmul(a1, w2)+b2 # 
a2 = tf.nn.tanh(z2) #使用tanh函数作为激活函数
#第三个隐层
w3 = tf.Variable(tf.random_normal([unit_num,unit_num])) #10行10列
b3 = tf.Variable(tf.zeros([1,unit_num])) # 1,10
z3 = tf.matmul(a2, w3)+b3 # 
a3 = tf.nn.tanh(z3) #使用tanh函数作为激活函数

#定义神经网络输出层
w4 = tf.Variable(tf.random_normal([unit_num,1]))
b4 = tf.Variable(tf.zeros([1,1]))
z4 = tf.matmul(a3,w4) + b4
prediction = tf.nn.sigmoid(z4)

#定义损失函数
loss = tf.reduce_mean(tf.square(y - prediction))
#定义优化函数
my_opt = tf.train.GradientDescentOptimizer(learning_rate=0.02)
train_step = my_opt.minimize(loss)

# 训练数据集 
X_train = np.load('60000_X_train.npy')   
print "train samples:",X_train.shape
y_train = np.load('60000_y_train.npy') 
train_num = y_train.shape[0]
top20_train = int(top_percentage*train_num)
y_train = y_train.reshape([train_num,1]) # 转成nx1数组
dataset_size=train_num # 训练样本数目

# 测试数据集
X_test = np.load('60000_X_test.npy')   
print "test samples:",X_test.shape
y_test = np.load('60000_y_test.npy') 
test_num = y_test.shape[0]
top20_test = int(top_percentage*test_num)
y_test = y_test.reshape([test_num,1]) # 转成nx1数组

# 参数输出格式
fmt=['%.9f']
w1_fmt=unit_num*fmt
w2_fmt=unit_num*fmt
w3_fmt=unit_num*fmt
w4_fmt=fmt

#创建会话运行TensorFlow程序  
with tf.Session() as sess:  
    #初始化变量  tf.initialize_all_variables()  
    init = tf.initialize_all_variables()  
    sess.run(init)  
    for i in range(steps):  
        #每次选取batch_size个样本进行训练  
        start = (i * batch_size) % dataset_size  
        end = min(start + batch_size,dataset_size)  
        #通过选取样本训练神经网络并更新参数  
        sess.run(train_step,feed_dict={x:X_train[start:end],y:y_train[start:end]})  
        #每迭代100次输出一次日志信息  
        if i % 100 == 0 :
            print "time:%s,"%(time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))), # 打印当前时间
            # 计算所有数据的损失,输出交叉熵之和  
            total_loss = sess.run(loss,feed_dict={x:X_train,y:y_train})  
            print "training_steps:%05d, total_loss:%0.6f,"%(i,total_loss),
            # 对训练数据进行预测
            prediction_value = sess.run(prediction,feed_dict={x:X_train}) # mx1
            c= np.c_[y_train,prediction_value] # 将标签和得分合在一个数组中
            sorted_c=c[np.lexsort(-c.T)] # 按最后一列逆序排序
            print "[%0.6f,%0.6f],"%(sorted_c[top20_train-1,1],sorted_c[0,1]),
            positive_num=sum(sorted_c[:top20_train,0]);negative_num=top20_train-positive_num
            print "positive_rate:%0.6f,"%(positive_num/top20_train),
            prediction_label = np.array([[1 if p_value[0]>=0.5 else 0] for p_value in prediction_value]) # mx1
            yes_no=(prediction_label==y_train)
            print "prediction_accuracy:%0.6f on train data;"%(yes_no.sum()/float(train_num)),
            # 对测试数据进行预测
            prediction_value = sess.run(prediction,feed_dict={x:X_test}) # mx1
            c= np.c_[y_test,prediction_value] # 将标签和得分合在一个数组中
            sorted_c=c[np.lexsort(-c.T)] # 按最后一列逆序排序
            print "[%0.6f,%0.6f],"%(sorted_c[top20_test-1,1],sorted_c[0,1]),
            positive_num=sum(sorted_c[:top20_test,0]);negative_num=top20_test-positive_num
            print "positive_rate:%0.6f,"%(positive_num/top20_test),
            prediction_label = np.array([[1 if p_value[0]>=0.5 else 0] for p_value in prediction_value]) # mx1
            yes_no=(prediction_label==y_test)
            print "prediction_accuracy:%0.6f on test data"%(yes_no.sum()/float(test_num))
    #模型训练结束,输出和保存参数
    # print(w1.eval(session=sess)) 
    parameter_w1=w1.eval(session=sess)
    np.savetxt('w1_tanh.txt',parameter_w1,fmt=w1_fmt,delimiter=',') 
    parameter_b1=b1.eval(session=sess)
    np.savetxt('b1_tanh.txt',parameter_b1,fmt=w1_fmt,delimiter=',') 
    
    parameter_w2=w2.eval(session=sess)
    np.savetxt('w2_tanh.txt',parameter_w2,fmt=w2_fmt,delimiter=',') 
    parameter_b2=b2.eval(session=sess)
    np.savetxt('b2_tanh.txt',parameter_b2,fmt=w2_fmt,delimiter=',') 

    parameter_w3=w3.eval(session=sess)
    np.savetxt('w3_tanh.txt',parameter_w3,fmt=w3_fmt,delimiter=',') 
    parameter_b3=b3.eval(session=sess)
    np.savetxt('b3_tanh.txt',parameter_b3,fmt=w3_fmt,delimiter=',') 

    parameter_w4=w4.eval(session=sess)
    np.savetxt('w4_tanh.txt',parameter_w4,fmt=w4_fmt,delimiter=',') 
    parameter_b4=b4.eval(session=sess)
    np.savetxt('b4_tanh.txt',parameter_b4,fmt=w4_fmt,delimiter=',') 

endtime = datetime.datetime.now()
print (endtime - starttime),"time used!!!" #0:00:00.280797

print "Finished!!!"