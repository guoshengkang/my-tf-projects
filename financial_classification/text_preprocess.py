#!/usr/bin/python
# -+- coding: utf-8 -+-
import re,os
import pickle
import sys
reload(sys)
sys.setdefaultencoding('utf-8')
import datetime
starttime = datetime.datetime.now()
'''
输入:sample_60000 #id,label,keywords
输出:sample_60000_final #label,keywords
关键词词典:dictionary.txt
手机号码信息词典:dictionary.txt
'''
####################################################
input_file_path = os.path.join(os.path.split(os.path.realpath(__file__))[0], "sample_60000")

dictionary=set() #所有的词汇
dictionary_add=set() #所有的词汇
line_no=0
positive=0;negative=0 #正负样本的数量
with open(input_file_path, "r") as fin:
  for line in fin.readlines():
    line=unicode(line.strip(), "utf-8")
    uid,label,keywords,province,tier,head,tail=line.split(unicode(',','utf-8'))
    if label=='1':
      positive+=1
    else:
      negative+=1
    keyword_list=keywords.split(unicode(';','utf-8'))
    dictionary=dictionary|set(keyword_list)
    dictionary_add.add('province_'+province)
    dictionary_add.add('tier_'+tier)
    dictionary_add.add('province_'+province)
    dictionary_add.add('head_'+head)
    dictionary_add.add('tail_'+tail)

print "There are %d keywords in dictionary!!!"%len(dictionary)
print "%d positive samples, and %d negative samples!!!"%(positive,negative)

dictionary_path = os.path.join(os.path.split(os.path.realpath(__file__))[0], "dictionary.txt")
dict_fout=open(dictionary_path,'w')
for keyword in dictionary:
  dict_fout.write(keyword.encode('utf-8')+'\n')
dict_fout.close()

dictionary_path = os.path.join(os.path.split(os.path.realpath(__file__))[0], "dictionary_add.txt")
dict_fout=open(dictionary_path,'w')
for keyword in dictionary_add:
  dict_fout.write(keyword.encode('utf-8')+'\n')
dict_fout.close()

###########################################################
endtime = datetime.datetime.now()
print "There are %s time used!!!"%(endtime - starttime) #0:00:00.280797
print "Finished!!!!"