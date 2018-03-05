(60000, 6213)
X_train: (48000, 6212)
X_test: (12000, 6212)


(1000, 6213)
X_train_test: (800, 6212)
X_test_test: (200, 6212)

sudo nohup python -u get_score.py >>log.log 2>&1 &

tail -f tf.log

ps aux|grep tf_financial_tanh_l2

kill -9 25006
ps aux|grep python
-----------------------
-- result1
batch_size = 5000 # 定义每次训练数据batch的大小,防止内存溢出 
steps = 100000 # 设置神经网络的迭代次数 
learning_rate=0.02
48000*0.2=9600,9600*0.54=5184
12000*0.2=2400,2400*0.47=1128

top20% 正样本数:
time:2018-01-03 10:20:11, training_steps:00000, total_loss:0.366555, [0.023542,0.999890], positive_rate:0.372396, prediction_accuracy:0.613771 on train data; [0.023649,0.999054], positive_rate:0.359583, prediction_accuracy:0.624083 on test data
time:2018-01-03 10:21:12, training_steps:00100, total_loss:0.363047, [0.050115,0.999946], positive_rate:0.370833, prediction_accuracy:0.610146 on train data; [0.050331,0.999494], positive_rate:0.360417, prediction_accuracy:0.618417 on test data
time:2018-01-03 10:22:13, training_steps:00200, total_loss:0.359886, [0.098800,0.999972], positive_rate:0.371875, prediction_accuracy:0.604812 on train data; [0.097057,0.999710], positive_rate:0.360833, prediction_accuracy:0.612417 on test data
time:2018-01-03 10:23:13, training_steps:00300, total_loss:0.357708, [0.163124,0.999983], positive_rate:0.371563, prediction_accuracy:0.598375 on train data; [0.161882,0.999809], positive_rate:0.361250, prediction_accuracy:0.606000 on test data
time:2018-01-03 10:24:14, training_steps:00400, total_loss:0.356458, [0.218737,0.999987], positive_rate:0.371667, prediction_accuracy:0.594375 on train data; [0.219222,0.999852], positive_rate:0.361250, prediction_accuracy:0.602417 on test data
time:2018-01-03 10:25:14, training_steps:00500, total_loss:0.355574, [0.262402,0.999990], positive_rate:0.372396, prediction_accuracy:0.591146 on train data; [0.263760,0.999876], positive_rate:0.362500, prediction_accuracy:0.597083 on test data
time:2018-01-03 10:26:15, training_steps:00600, total_loss:0.354826, [0.286315,0.999990], positive_rate:0.373437, prediction_accuracy:0.589250 on train data; [0.289043,0.999885], positive_rate:0.362083, prediction_accuracy:0.595167 on test data
time:2018-01-03 10:27:15, training_steps:00700, total_loss:0.354085, [0.304812,0.999991], positive_rate:0.373958, prediction_accuracy:0.588271 on train data; [0.306170,0.999888], positive_rate:0.363333, prediction_accuracy:0.593917 on test data
..............................................................................
time:2018-01-04 08:57:42, training_steps:99500, total_loss:0.223634, [0.471721,0.921078], positive_rate:0.548750, prediction_accuracy:0.641042 on train data; [0.470779,0.947828], positive_rate:0.470833, prediction_accuracy:0.629000 on test data
time:2018-01-04 08:59:25, training_steps:99600, total_loss:0.223625, [0.471415,0.921003], positive_rate:0.548854, prediction_accuracy:0.641104 on train data; [0.470469,0.947752], positive_rate:0.470833, prediction_accuracy:0.629083 on test data
time:2018-01-04 09:00:58, training_steps:99700, total_loss:0.223615, [0.471484,0.921035], positive_rate:0.548854, prediction_accuracy:0.641104 on train data; [0.470546,0.947758], positive_rate:0.471250, prediction_accuracy:0.629083 on test data
time:2018-01-04 09:02:42, training_steps:99800, total_loss:0.223606, [0.470945,0.920895], positive_rate:0.548750, prediction_accuracy:0.641167 on train data; [0.470043,0.947642], positive_rate:0.471250, prediction_accuracy:0.629250 on test data
time:2018-01-04 09:04:14, training_steps:99900, total_loss:0.223597, [0.471048,0.920943], positive_rate:0.548854, prediction_accuracy:0.641167 on train data; [0.470115,0.947657], positive_rate:0.471250, prediction_accuracy:0.629083 on test data
22:46:03.607038 time used!!!

-----------------------
-- result2
x_dim = 6212 # 样本数据的维度
unit_num = 128 # 每个隐层包含的神经元数
batch_size = 5000 # 定义每次训练数据batch的大小,防止内存溢出 
steps = 100000 # 设置神经网络的迭代次数 
top_percentage = 0.2 # 用于统计前%20得分的正负样本数
learning_rate = 0.002 # 学习率
+ L2正则化
top20% 正样本数:
48000*0.2=9600,9600*0.46=4416
12000*0.2=2400,2400*0.43=1032
time:2018-01-03 18:26:08, training_steps:00000, total_loss:414.110657, [0.999433,1.000000], positive_rate:0.378437, prediction_accuracy:0.383729 on train data; [0.999425,1.000000], positive_rate:0.371250, prediction_accuracy:0.374750 on test data
time:2018-01-03 18:27:22, training_steps:00100, total_loss:413.936432, [0.999194,1.000000], positive_rate:0.377812, prediction_accuracy:0.385542 on train data; [0.999180,1.000000], positive_rate:0.371250, prediction_accuracy:0.376917 on test data
time:2018-01-03 18:28:24, training_steps:00200, total_loss:413.759308, [0.998790,1.000000], positive_rate:0.377396, prediction_accuracy:0.387958 on train data; [0.998757,0.999999], positive_rate:0.370417, prediction_accuracy:0.380417 on test data
time:2018-01-03 18:29:39, training_steps:00300, total_loss:413.578430, [0.998061,0.999999], positive_rate:0.376771, prediction_accuracy:0.392333 on train data; [0.997995,0.999999], positive_rate:0.371250, prediction_accuracy:0.386083 on test data
time:2018-01-03 18:30:53, training_steps:00400, total_loss:413.393097, [0.996679,0.999999], positive_rate:0.376354, prediction_accuracy:0.399042 on train data; [0.996546,0.999999], positive_rate:0.369167, prediction_accuracy:0.392417 on test data
time:2018-01-03 18:31:54, training_steps:00500, total_loss:413.202545, [0.993912,0.999998], positive_rate:0.376458, prediction_accuracy:0.409667 on train data; [0.993675,0.999997], positive_rate:0.367083, prediction_accuracy:0.402417 on test data
...........................................................................
time:2018-01-04 11:18:09, training_steps:99200, total_loss:278.337402, [0.485549,0.959648], positive_rate:0.460000, prediction_accuracy:0.607583 on train data; [0.481903,0.926672], positive_rate:0.438333, prediction_accuracy:0.613583 on test data
time:2018-01-04 11:19:25, training_steps:99300, total_loss:278.226166, [0.485375,0.959557], positive_rate:0.460104, prediction_accuracy:0.607583 on train data; [0.481866,0.926490], positive_rate:0.437917, prediction_accuracy:0.613667 on test data
time:2018-01-04 11:20:28, training_steps:99400, total_loss:278.114990, [0.485429,0.959486], positive_rate:0.460208, prediction_accuracy:0.607583 on train data; [0.481970,0.926345], positive_rate:0.437917, prediction_accuracy:0.613667 on test data
time:2018-01-04 11:21:32, training_steps:99500, total_loss:278.003906, [0.485304,0.959392], positive_rate:0.460208, prediction_accuracy:0.607688 on train data; [0.481867,0.926158], positive_rate:0.437917, prediction_accuracy:0.613667 on test data
time:2018-01-04 11:22:36, training_steps:99600, total_loss:277.892792, [0.485176,0.959299], positive_rate:0.460208, prediction_accuracy:0.607708 on train data; [0.481812,0.925971], positive_rate:0.438333, prediction_accuracy:0.613583 on test data
time:2018-01-04 11:23:40, training_steps:99700, total_loss:277.781586, [0.485103,0.959212], positive_rate:0.460208, prediction_accuracy:0.607646 on train data; [0.481714,0.925796], positive_rate:0.438333, prediction_accuracy:0.613500 on test data
time:2018-01-04 11:24:56, training_steps:99800, total_loss:277.670593, [0.484857,0.959105], positive_rate:0.460208, prediction_accuracy:0.607625 on train data; [0.481474,0.925586], positive_rate:0.437917, prediction_accuracy:0.613583 on test data
time:2018-01-04 11:25:58, training_steps:99900, total_loss:277.559814, [0.484780,0.959022], positive_rate:0.460417, prediction_accuracy:0.607646 on train data; [0.481483,0.925418], positive_rate:0.437500, prediction_accuracy:0.613583 on test data
17:00:56.764149 time used!!!

-----------------------
-- result3
x_dim = 6212 # 样本数据的维度
unit_num = 128 # 每个隐层包含的神经元数
batch_size = 5000 # 定义每次训练数据batch的大小,防止内存溢出 
steps = 100000 # 设置神经网络的迭代次数 
top_percentage = 0.2 # 用于统计前%20得分的正负样本数
learning_rate = 0.002 # 学习率
tanh + L2正则化
top20% 正样本数:
48000*0.2=9600,9600*0.92=9600*0.92
12000*0.2=2400,2400*0.52=1248
time:2018-01-04 18:09:37, training_steps:00000, total_loss:414.090759, [0.998982,1.000000], positive_rate:0.390000, prediction_accuracy:0.516396 on train data; [0.999251,1.000000], positive_rate:0.381250, prediction_accuracy:0.514833 on test data
time:2018-01-04 18:11:20, training_steps:00100, total_loss:412.430145, [0.998742,1.000000], positive_rate:0.389583, prediction_accuracy:0.527979 on train data; [0.999085,1.000000], positive_rate:0.383750, prediction_accuracy:0.516917 on test data
time:2018-01-04 18:12:19, training_steps:00200, total_loss:410.777161, [0.998506,1.000000], positive_rate:0.389583, prediction_accuracy:0.539396 on train data; [0.998903,1.000000], positive_rate:0.382917, prediction_accuracy:0.518917 on test data
time:2018-01-04 18:13:31, training_steps:00300, total_loss:409.131897, [0.998231,1.000000], positive_rate:0.390208, prediction_accuracy:0.549042 on train data; [0.998695,1.000000], positive_rate:0.383750, prediction_accuracy:0.520750 on test data
time:2018-01-04 18:14:31, training_steps:00400, total_loss:407.494019, [0.997973,1.000000], positive_rate:0.390625, prediction_accuracy:0.557063 on train data; [0.998481,1.000000], positive_rate:0.382917, prediction_accuracy:0.522250 on test data
time:2018-01-04 18:15:44, training_steps:00500, total_loss:405.863434, [0.997698,1.000000], positive_rate:0.391042, prediction_accuracy:0.564646 on train data; [0.998246,1.000000], positive_rate:0.384167, prediction_accuracy:0.523833 on test data
time:2018-01-04 18:16:58, training_steps:00600, total_loss:404.239624, [0.997409,1.000000], positive_rate:0.391979, prediction_accuracy:0.570417 on train data; [0.998087,1.000000], positive_rate:0.384583, prediction_accuracy:0.523833 on test data
..................................................................
time:2018-01-05 11:47:09, training_steps:99200, total_loss:8.070906, [0.628747,0.994156], positive_rate:0.922708, prediction_accuracy:0.841354 on train data; [0.611734,0.995165], positive_rate:0.521250, prediction_accuracy:0.618083 on test data
time:2018-01-05 11:47:54, training_steps:99300, total_loss:8.039681, [0.627623,0.994117], positive_rate:0.923021, prediction_accuracy:0.841313 on train data; [0.610314,0.995182], positive_rate:0.521250, prediction_accuracy:0.618583 on test data
time:2018-01-05 11:48:39, training_steps:99400, total_loss:8.008591, [0.628828,0.994124], positive_rate:0.923021, prediction_accuracy:0.841479 on train data; [0.611694,0.995179], positive_rate:0.522083, prediction_accuracy:0.618750 on test data
time:2018-01-05 11:49:23, training_steps:99500, total_loss:7.977619, [0.629225,0.994132], positive_rate:0.923125, prediction_accuracy:0.841667 on train data; [0.611517,0.995189], positive_rate:0.522083, prediction_accuracy:0.618833 on test data
time:2018-01-05 11:50:08, training_steps:99600, total_loss:7.946763, [0.627548,0.994103], positive_rate:0.923125, prediction_accuracy:0.841375 on train data; [0.610524,0.995152], positive_rate:0.522917, prediction_accuracy:0.619250 on test data
time:2018-01-05 11:50:53, training_steps:99700, total_loss:7.916035, [0.628074,0.994087], positive_rate:0.923125, prediction_accuracy:0.841458 on train data; [0.611590,0.995171], positive_rate:0.521667, prediction_accuracy:0.619333 on test data
time:2018-01-05 11:51:38, training_steps:99800, total_loss:7.885433, [0.626523,0.994052], positive_rate:0.923646, prediction_accuracy:0.841208 on train data; [0.610518,0.995152], positive_rate:0.522500, prediction_accuracy:0.620083 on test data
time:2018-01-05 11:52:22, training_steps:99900, total_loss:7.854951, [0.627988,0.994074], positive_rate:0.923229, prediction_accuracy:0.841375 on train data; [0.611175,0.995153], positive_rate:0.521667, prediction_accuracy:0.620167 on test data
17:44:24.903315 time used!!!
----------------------------------------------------
-- result4  3个隐层+迭代100000
X_train: (140000, 6416)
X_test: (20000, 6416)
tanh + L2正则化
top20% 正样本数:
140000*0.2=28000
20000*0.2=4000,4000*0.61=2440
Use `tf.global_variables_initializer` instead.
time:2018-01-05 16:33:35, training_steps:00000, total_loss:427.059296, [0.999867,1.000000], positive_rate:0.378250, prediction_accuracy:0.498800 on test data
time:2018-01-05 16:34:21, training_steps:00100, total_loss:425.351685, [0.999826,1.000000], positive_rate:0.377500, prediction_accuracy:0.500850 on test data
time:2018-01-05 16:35:08, training_steps:00200, total_loss:423.646515, [0.999778,1.000000], positive_rate:0.379000, prediction_accuracy:0.503900 on test data
time:2018-01-05 16:35:54, training_steps:00300, total_loss:421.967285, [0.999723,1.000000], positive_rate:0.379500, prediction_accuracy:0.505850 on test data
time:2018-01-05 16:36:40, training_steps:00400, total_loss:420.260437, [0.999656,1.000000], positive_rate:0.380750, prediction_accuracy:0.507250 on test data
time:2018-01-05 16:37:26, training_steps:00500, total_loss:418.588562, [0.999586,1.000000], positive_rate:0.380250, prediction_accuracy:0.508900 on test data
time:2018-01-05 16:38:12, training_steps:00600, total_loss:416.925323, [0.999518,1.000000], positive_rate:0.381250, prediction_accuracy:0.510550 on test data
time:2018-01-05 16:38:59, training_steps:00700, total_loss:415.251617, [0.999439,1.000000], positive_rate:0.383500, prediction_accuracy:0.512350 on test data
time:2018-01-05 16:39:45, training_steps:00800, total_loss:413.596008, [0.999341,1.000000], positive_rate:0.384500, prediction_accuracy:0.513350 on test data
................................................................
time:2018-01-06 04:43:42, training_steps:99300, total_loss:8.249344, [0.516760,0.908387], positive_rate:0.612500, prediction_accuracy:0.671950 on test data
time:2018-01-06 04:44:26, training_steps:99400, total_loss:8.219539, [0.517143,0.908621], positive_rate:0.612750, prediction_accuracy:0.672050 on test data
time:2018-01-06 04:45:09, training_steps:99500, total_loss:8.189322, [0.516416,0.908585], positive_rate:0.612250, prediction_accuracy:0.671700 on test data
time:2018-01-06 04:45:53, training_steps:99600, total_loss:8.153068, [0.516896,0.908933], positive_rate:0.613000, prediction_accuracy:0.671900 on test data
time:2018-01-06 04:46:37, training_steps:99700, total_loss:8.123104, [0.517038,0.909027], positive_rate:0.612750, prediction_accuracy:0.672050 on test data
time:2018-01-06 04:47:20, training_steps:99800, total_loss:8.089092, [0.516727,0.909464], positive_rate:0.612750, prediction_accuracy:0.671950 on test data
time:2018-01-06 04:48:04, training_steps:99900, total_loss:8.058606, [0.517134,0.909542], positive_rate:0.612750, prediction_accuracy:0.672350 on test data
12:16:34.843308 time used!!!
Finished!!!

--------------------------------------------
-- result5 3个隐层+迭代100000
train samples: (140000, 6416)
test samples: (20000, 6416)
sigm + L2正则化
top20% 正样本数:
140000*0.2=28000
20000*0.2=4000,4000*0.60=2400
Use `tf.global_variables_initializer` instead.
time:2018-01-08 13:50:13, training_steps:00000, total_loss:426.918152, [0.982208,0.999975], positive_rate:0.360000, prediction_accuracy:0.429400 on test data
time:2018-01-08 13:52:17, training_steps:00100, total_loss:425.097351, [0.572825,0.999026], positive_rate:0.365250, prediction_accuracy:0.562200 on test data
time:2018-01-08 13:53:01, training_steps:00200, total_loss:423.398651, [0.469575,0.998425], positive_rate:0.367250, prediction_accuracy:0.574700 on test data
time:2018-01-08 13:53:41, training_steps:00300, total_loss:421.715607, [0.459376,0.998214], positive_rate:0.367750, prediction_accuracy:0.575900 on test data
time:2018-01-08 13:54:38, training_steps:00400, total_loss:420.015381, [0.461598,0.998063], positive_rate:0.368000, prediction_accuracy:0.576400 on test data
time:2018-01-08 13:57:02, training_steps:00500, total_loss:418.349091, [0.469022,0.997928], positive_rate:0.368750, prediction_accuracy:0.576150 on test data
time:2018-01-08 13:58:41, training_steps:00600, total_loss:416.676971, [0.473144,0.997759], positive_rate:0.368000, prediction_accuracy:0.576650 on test data
time:2018-01-08 14:01:08, training_steps:00700, total_loss:415.014618, [0.480820,0.997592], positive_rate:0.371250, prediction_accuracy:0.576050 on test data
time:2018-01-08 14:02:01, training_steps:00800, total_loss:413.356628, [0.482875,0.997343], positive_rate:0.370500, prediction_accuracy:0.576300 on test data
.................................
time:2018-01-10 00:18:04, training_steps:99500, total_loss:8.193927, [0.462114,0.826237], positive_rate:0.602000, prediction_accuracy:0.663650 on test data
time:2018-01-10 00:19:21, training_steps:99600, total_loss:8.158801, [0.463339,0.827147], positive_rate:0.602250, prediction_accuracy:0.664100 on test data
time:2018-01-10 00:20:38, training_steps:99700, total_loss:8.130507, [0.464965,0.828243], positive_rate:0.602500, prediction_accuracy:0.664450 on test data
time:2018-01-10 00:21:53, training_steps:99800, total_loss:8.095969, [0.462832,0.827308], positive_rate:0.602500, prediction_accuracy:0.663850 on test data
time:2018-01-10 00:23:00, training_steps:99900, total_loss:8.064979, [0.464010,0.828216], positive_rate:0.602500, prediction_accuracy:0.664550 on test data
--------------------------
-- result6 3个隐层+迭代150000
X_train: (140000, 6416)
X_test: (20000, 6416)
tanh + L2正则化
top20% 正样本数:
140000*0.2=28000
20000*0.2=4000,4000*0.63=2520
time:2018-01-11 15:02:37, training_steps:149100, total_loss:1.302045, [0.530254,0.956198], positive_rate:0.633750, prediction_accuracy:0.679800 on test data
time:2018-01-11 15:03:14, training_steps:149200, total_loss:1.297892, [0.527459,0.956021], positive_rate:0.632750, prediction_accuracy:0.679650 on test data
time:2018-01-11 15:03:52, training_steps:149300, total_loss:1.290972, [0.528703,0.956152], positive_rate:0.633000, prediction_accuracy:0.679850 on test data
time:2018-01-11 15:04:29, training_steps:149400, total_loss:1.287463, [0.529112,0.956170], positive_rate:0.633750, prediction_accuracy:0.679800 on test data
time:2018-01-11 15:05:07, training_steps:149500, total_loss:1.282699, [0.527818,0.956239], positive_rate:0.632750, prediction_accuracy:0.679600 on test data
time:2018-01-11 15:05:45, training_steps:149600, total_loss:1.278600, [0.528686,0.956267], positive_rate:0.633250, prediction_accuracy:0.679950 on test data
time:2018-01-11 15:06:22, training_steps:149700, total_loss:1.271711, [0.528153,0.956364], positive_rate:0.632500, prediction_accuracy:0.679750 on test data
time:2018-01-11 15:07:00, training_steps:149800, total_loss:1.271643, [0.530252,0.956508], positive_rate:0.633500, prediction_accuracy:0.679750 on test data
time:2018-01-11 15:07:38, training_steps:149900, total_loss:1.267577, [0.527425,0.956329], positive_rate:0.633250, prediction_accuracy:0.679650 on test data
17:14:20.043031 time used!!!

--------------------------
-- result7 4个隐层+迭代200000  使用中
X_train: (140000, 6416)
X_test: (20000, 6416)
tanh + L2正则化
top20% 正样本数:
140000*0.2=28000
20000*0.2=4000,4000*0.61=2440
time:2018-01-13 08:44:55, training_steps:199100, total_loss:0.362187, [0.645302,0.998524], positive_rate:0.615750, prediction_accuracy:0.658900 on test data
time:2018-01-13 08:45:31, training_steps:199200, total_loss:0.354218, [0.567898,0.997707], positive_rate:0.618000, prediction_accuracy:0.669000 on test data
time:2018-01-13 08:46:07, training_steps:199300, total_loss:0.353759, [0.593289,0.997734], positive_rate:0.617000, prediction_accuracy:0.666300 on test data
time:2018-01-13 08:46:43, training_steps:199400, total_loss:0.351913, [0.613621,0.998240], positive_rate:0.617500, prediction_accuracy:0.665750 on test data
time:2018-01-13 08:47:19, training_steps:199500, total_loss:0.361264, [0.642751,0.998480], positive_rate:0.618750, prediction_accuracy:0.660550 on test data
time:2018-01-13 08:47:55, training_steps:199600, total_loss:0.353636, [0.599489,0.998126], positive_rate:0.616250, prediction_accuracy:0.665800 on test data
time:2018-01-13 08:48:31, training_steps:199700, total_loss:0.355794, [0.607649,0.998312], positive_rate:0.618500, prediction_accuracy:0.667400 on test data
time:2018-01-13 08:49:07, training_steps:199800, total_loss:0.357658, [0.646352,0.998517], positive_rate:0.614750, prediction_accuracy:0.658350 on test data
time:2018-01-13 08:49:43, training_steps:199900, total_loss:0.349666, [0.569737,0.997926], positive_rate:0.617750, prediction_accuracy:0.668800 on test data
19:59:44.312887 time used!!!
--------------------------
-- result8 4个隐层+迭代200000+初始化 不行
train samples: (80000, 6416)
test samples: (20000, 6416)
(20000,)
WARNING:tensorflow:From /home/mine/.local/lib/python2.7/site-packages/tensorflow/python/util/tf_should_use.py:133: initialize_all_variables (from tensorflow.python.ops.variables) is deprecated and will be removed after 2017-03-02.
Instructions for updating:
Use `tf.global_variables_initializer` instead.
time:2018-01-15 10:08:27, training_steps:00000, total_loss:0.405522, [0.824665,0.999493], positive_rate:0.737750, prediction_accuracy:0.629650 on test data
time:2018-01-15 10:09:58, training_steps:00100, total_loss:0.387968, [0.694860,0.998859], positive_rate:0.746000, prediction_accuracy:0.641400 on test data
time:2018-01-15 10:11:34, training_steps:00200, total_loss:0.381193, [0.717484,0.998834], positive_rate:0.748500, prediction_accuracy:0.642750 on test data
time:2018-01-15 10:13:14, training_steps:00300, total_loss:0.381851, [0.691367,0.998123], positive_rate:0.751000, prediction_accuracy:0.641400 on test data
time:2018-01-15 10:14:50, training_steps:00400, total_loss:0.379426, [0.679858,0.997738], positive_rate:0.750500, prediction_accuracy:0.642900 on test data
time:2018-01-15 10:16:25, training_steps:00500, total_loss:0.377149, [0.694469,0.997522], positive_rate:0.748750, prediction_accuracy:0.643500 on test data
time:2018-01-15 10:17:58, training_steps:00600, total_loss:0.372751, [0.710950,0.997435], positive_rate:0.750000, prediction_accuracy:0.643550 on test data
time:2018-01-15 10:19:35, training_steps:00700, total_loss:0.374299, [0.684202,0.996585], positive_rate:0.747000, prediction_accuracy:0.643050 on test data
.......................................................................
time:2018-01-16 17:03:12, training_steps:199100, total_loss:0.125105, [0.983184,1.000000], positive_rate:0.674500, prediction_accuracy:0.597900 on test data
time:2018-01-16 17:03:57, training_steps:199200, total_loss:0.143646, [0.994582,1.000000], positive_rate:0.674000, prediction_accuracy:0.595450 on test data
time:2018-01-16 17:04:53, training_steps:199300, total_loss:0.142478, [0.994055,1.000000], positive_rate:0.676000, prediction_accuracy:0.593450 on test data
time:2018-01-16 17:05:37, training_steps:199400, total_loss:0.124972, [0.988202,1.000000], positive_rate:0.672250, prediction_accuracy:0.596450 on test data
time:2018-01-16 17:06:22, training_steps:199500, total_loss:0.147147, [0.969472,1.000000], positive_rate:0.670750, prediction_accuracy:0.596600 on test data
time:2018-01-16 17:07:18, training_steps:199600, total_loss:0.138889, [0.961504,1.000000], positive_rate:0.676500, prediction_accuracy:0.598500 on test data
time:2018-01-16 17:08:02, training_steps:199700, total_loss:0.129957, [0.986873,1.000000], positive_rate:0.672500, prediction_accuracy:0.594850 on test data
time:2018-01-16 17:08:59, training_steps:199800, total_loss:0.158000, [0.997223,1.000000], positive_rate:0.682000, prediction_accuracy:0.597200 on test data
time:2018-01-16 17:09:43, training_steps:199900, total_loss:0.125450, [0.990060,1.000000], positive_rate:0.673000, prediction_accuracy:0.594350 on test data
1 day, 7:02:05.778318 time used!!!


