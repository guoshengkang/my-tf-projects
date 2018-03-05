项目:互联网金融用户分类
见文件夹:financial_classification
★★Task_1:建立模型★★
◎准备所有用户数据,随机平分成训练及测试样本
◎取16万训练样本(正:6万-负:10万),取50万测试样本
◎训练模型(tf_financial_tanh_l2.py)
◎依据模型的参数,计算50万测试样本的得分,并统计得分分段
◎观察50万测试样本统计得分分段的分布,评价模型的优劣
★★Task_2:模型测试★★
【Hive源代码:test_send_data.sql】
◎取1000000样本,计算得分
◎取40000得分较高的样本,分成4组,看实际发送的点击效果
◎观察1000000样本得分与之前短信点击模型得分的相关性
★★Task_3:计算所有淘宝用户的模型得分★★
【Hive源代码:computer_score.sql】
◎取得所有用户的数据(330907553个用户)
◎将数据平均插入另一个表的5个分区
◎将表的5个分区分别插入另外5张的100个分区
注:设置不压缩,且每个分区一个文件

项目:用户对短信的点击预测
见文件夹:thq_click
★★Task_1:建立模型★★
Step1:准备样本数据,将其分为训练和测试两部分,在训练样本中抽取160000(负:100000+正:60000)来训练,在测试样本中抽取200000来评估
Step2:模型训练(code:tf_financial_tanh_l2_4hiddenlayer_15_20.py),模型评估(code:evaluation.py)
Step3:观察200000测试样本的得分分布,挑选得分提升度较高的模型
★★Task_2:计算用户在推荐group_name的点击得分★★
Step1:根据给用户推荐的subroot,计算用户在其subroot对应的group_name
【Hive源代码:find_thq_group_name.sql】
注:group_name需在训练样本中出现才有意义
Step2:连接用户关键词、电话号码信息及subroot信息,作为计算用户在各group_name下得分的输入
Step3:计算得分
【python源程序见get_score_thq文件夹】
★★Task_3:模型应用测试★★
【Hive源代码:model_test.sql】
Step1:根据用户在推荐group_name的点击得分,选择一个得分最高的group_name
用户在推荐group_name的点击得分表:tmp_kgs_thq_uid_score
Step2:统计每个group_name中top_10用户点击得分的分布
统计结果表见文件:distribution_top10.xlsx
Step3:挑选3个大组进行对比测试,看点击率是否有提升
挑选的大组:男装,女装,食品