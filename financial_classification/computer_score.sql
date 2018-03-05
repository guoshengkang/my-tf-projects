-- 建表
drop table config_city_region_tier_dim;
CREATE TABLE config_city_region_tier_dim
(province   string,
city        string,
region      string,
tier        string
)
PARTITIONED BY (ds string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;

-------------------------------------------
idl_limao_uid_agg
idl_limao_active_moblie_agg

DROP TABLE tmp_kgs_all_uids_with_token;
CREATE TABLE tmp_kgs_all_uids_with_token AS
SELECT
t1.uid,
t1.title_id,
t2.token
FROM
    (SELECT *
    FROM idl_limao_user_title_agg
    WHERE ds="2018-01-10"
    ) t1
LEFT JOIN
    (SELECT *
    FROM  idl_titel_token_log
    WHERE ds="2018-01-10"
    ) t2
ON t1.title_id=t2.sentence_id
WHERE t2.sentence_id IS NOT NULL;


DROP TABLE  tmp_kgs_all_uids_with_keywords;
CREATE TABLE tmp_kgs_all_uids_with_keywords AS
SELECT
uid,
collect_set(keyword) AS keywords
FROM
    (SELECT
    DISTINCT uid,
    keyword
    FROM tmp_kgs_all_uids_with_token
    LATERAL VIEW explode(token) mytable AS keyword
    ) t1
GROUP BY uid;

DROP TABLE tmp_kgs_all_uids_with_data;
CREATE TABLE tmp_kgs_all_uids_with_data AS
SELECT
t3.uid,
t3.keywords,
t3.province,
t4.tier,
t3.head,
t3.tail
FROM
    (SELECT
    t1.uid,
    t1.keywords,
    t2.province,
    t2.city,
    t2.head,
    t2.tail
    FROM tmp_kgs_all_uids_with_keywords t1
    LEFT JOIN 
        (SELECT 
        uid,
        mobile_province AS province,
        mobile_city AS city,
        substring(mobile_mark,1,3) AS head,
        substring(mobile_mark,-1,1) AS tail
        FROM idl_limao_active_moblie_agg
        WHERE ds="2018-01-10"
        ) t2
    ON t1.uid=t2.uid
    ) t3
LEFT JOIN config_city_region_tier_dim t4
ON t3.city=t4.city;

-- 330907553
select count(distinct uid) from tmp_kgs_all_uids_with_data;

drop table tmp_kgs_all_uids_with_data_input;
CREATE TABLE tmp_kgs_all_uids_with_data_input
(  
uid        string, 
keywords   ARRAY<STRING>,
province   string,
tier       string,
head       string,
tail       string
)
-- PARTITIONED BY (ds string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;

set mapreduce.map.memory.mb=2048;
set mapreduce.map.java.opts=-Xmx1600m;
INSERT INTO tmp_kgs_all_uids_with_data_input
SELECT
DISTINCT uid,
keywords,
province,
tier,
head,
tail
FROM tmp_kgs_all_uids_with_data;


-- 插入5各分区 
drop table tmp_kgs_all_uids_with_data_input_final;
CREATE TABLE tmp_kgs_all_uids_with_data_input_final
(  
uid        string, 
keywords   ARRAY<STRING>,
province   string,
tier       string,
head       string,
tail       string
)
PARTITIONED BY (ds string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;

set hive.exec.compress.output=false;
set mapreduce.output.fileoutputformat.compress=false;
INSERT INTO tmp_kgs_all_uids_with_data_input_final PARTITION (ds)
SELECT
uid,
keywords,
province,
tier,
head,
tail,
concat("group_",cast(pmod(rk,5) as string)) as ds
FROM
    (SELECT
    uid,
    keywords,
    province,
    tier,
    head,
    tail,
    ceil(rand()*100) AS rk
    FROM tmp_kgs_all_uids_with_data_input
    ) t1;

-- 将每个分区插入100各分区
drop table tmp_kgs_all_uids_with_data_input_final_4;
CREATE TABLE tmp_kgs_all_uids_with_data_input_final_4
(  
uid        string, 
keywords   ARRAY<STRING>,
province   string,
tier       string,
head       string,
tail       string
)
PARTITIONED BY (ds string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;

set hive.exec.compress.output=false;
set mapreduce.output.fileoutputformat.compress=false;
INSERT INTO tmp_kgs_all_uids_with_data_input_final_4 PARTITION (ds)
SELECT
uid,
keywords,
province,
tier,
head,
tail,
concat("group_",cast(rk as string)) as ds
FROM
    (SELECT
    uid,
    keywords,
    province,
    tier,
    head,
    tail,
    ceil(rand()*100) AS rk
    FROM tmp_kgs_all_uids_with_data_input_final
    WHERE ds="group_0"
    ) t1;

    
drop table tmp_kgs_all_uids_with_data_input_final_copy_4;
CREATE TABLE tmp_kgs_all_uids_with_data_input_final_copy_4
(  
uid        string, 
keywords   ARRAY<STRING>,
province   string,
tier       string,
head       string,
tail       string
)
PARTITIONED BY (ds string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;

set hive.exec.compress.output=false;
set mapreduce.output.fileoutputformat.compress=false;
INSERT INTO tmp_kgs_all_uids_with_data_input_final_copy_4 PARTITION (ds)
SELECT
uid,
keywords,
province,
tier,
head,
tail,
ds
FROM tmp_kgs_all_uids_with_data_input_final_4
distribute by ds;

DROP TABLE tmp_kgs_financial_uid_score_load;
CREATE TABLE tmp_kgs_financial_uid_score_load
(
uid          STRING COMMENT 'uid',
score        FLOAT COMMENT 'score'
)
comment "click_uid_score"
PARTITIONED BY (ds string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;

DROP TABLE tmp_kgs_financial_uid_score;
CREATE TABLE tmp_kgs_financial_uid_score
(
uid          STRING COMMENT 'uid',
score        FLOAT COMMENT 'score'
)
comment "click_uid_score"
PARTITIONED BY (ds string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;

set hive.exec.compress.output=false;
set mapreduce.output.fileoutputformat.compress=false;
INSERT INTO tmp_kgs_financial_uid_score PARTITION (ds='2018-02-26')
SELECT 
uid,
score
FROM tmp_kgs_financial_uid_score_load;


ALTER TABLE tmp_kgs_financial_uid_score_load ADD PARTITION(ds='0');
ALTER TABLE tmp_kgs_financial_uid_score_load ADD PARTITION(ds='1');
ALTER TABLE tmp_kgs_financial_uid_score_load ADD PARTITION(ds='4');

load data inpath '/tmp/kgstmp/outputfile0' overwrite into table leesdata.tmp_kgs_financial_uid_score_load partition(ds='0');
load data inpath '/tmp/kgstmp/outputfile1' overwrite into table leesdata.tmp_kgs_financial_uid_score_load partition(ds='1');
load data inpath '/tmp/kgstmp/outputfile2' overwrite into table leesdata.tmp_kgs_financial_uid_score_load partition(ds='2');
load data inpath '/tmp/kgstmp/outputfile3' overwrite into table leesdata.tmp_kgs_financial_uid_score_load partition(ds='3');
load data inpath '/tmp/kgstmp/outputfile4' overwrite into table leesdata.tmp_kgs_financial_uid_score_load partition(ds='4');

load data local inpath '/home/kangguosheng/tmp/input_data1' 
overwrite into table tmp_kgs_click_uid_score_load partition(ds='0');

    
hive -e "load data local inpath '/root/kgstmp/output_files/input_data1' overwrite into table leesdata.tmp_kgs_test_load_score partition(ds='test')"

sudo nohup python -u get_score.py >>py_log.log 2>&1 &

sudo nohup python -u get_score3.py >>print_3.log 2>&1 &
sudo nohup python -u get_score4.py >>print_4.log 2>&1 &

hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_click_uid_score_load/ds=0

-- 将目录下的所有文件传输到hdfs目录
hadoop fs -put /data1/service/kgs_tmp/outputfile0/* hdfs://172.31.31.115:8020/tmp/kgstmp/outputfile0
hadoop fs -put /data1/service/kgs_tmp/outputfile1/* hdfs://172.31.31.115:8020/tmp/kgstmp/outputfile1
hadoop fs -put /data1/service/kgs_tmp/outputfile2/* hdfs://172.31.31.115:8020/tmp/kgstmp/outputfile2
hadoop fs -put /data1/service/kgs_tmp/outputfile3/* hdfs://172.31.31.115:8020/tmp/kgstmp/outputfile3
hadoop fs -put /data1/service/kgs_tmp/outputfile4/* hdfs://172.31.31.115:8020/tmp/kgstmp/outputfile4

-- 查看目录下的文件列表
hadoop fs -ls hdfs://172.31.31.115:8020/tmp/kgstmp/outputfile0
hadoop fs -ls hdfs://172.31.31.115:8020/tmp/kgstmp/outputfile2

hadoop fs -ls hdfs://172.31.31.115:8020/tmp/kgstmp/outputfile4
hadoop fs -ls hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_click_uid_score_load/ds=0


hadoop fs -mkdir hdfs://172.31.31.115:8020/tmp/kgstmp/outputfile0
hadoop fs -mkdir hdfs://172.31.31.115:8020/tmp/kgstmp/outputfile1
hadoop fs -mkdir hdfs://172.31.31.115:8020/tmp/kgstmp/outputfile2
hadoop fs -mkdir hdfs://172.31.31.115:8020/tmp/kgstmp/outputfile3
hadoop fs -mkdir hdfs://172.31.31.115:8020/tmp/kgstmp/outputfile4

hadoop fs -ls hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_click_uid_score_load

-- 以下两个创建目录的命令是等价的
hadoop fs -mkdir /tmp/kgs
hadoop fs -mkdir hdfs://172.31.31.115:8020/tmp/kgs
-- 删除文件夹
hadoop fs -rm -r hdfs://172.31.31.115:8020/tmp/kgs
-- 删除文件
hadoop fs -rm hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_test_load_score/derby.log

load data inpath '/tmp/kgstmp/*' overwrite into table leesdata.tmp_kgs_test_load_score

hadoop fs -ls hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_test_load_score

hadoop fs -du -h hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_all_uids_with_data

hadoop fs -du -s -h hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_all_uids_with_data_input_final_4/

hadoop fs -ls hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_all_uids_with_data_input_final_4

hadoop fs -get hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_all_uids_with_data_input_final_4/* /data1/service/kgs_tmp/inputfile1
hadoop fs -ls hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_all_uids_with_data_input_final_4/ds=group_1
hadoop fs -du -s -h hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_all_uids_with_data_input_final_copy_0/ds=*/*

hadoop fs -ls hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_all_uids_with_data_input_final_copy_0/*

-- 将数据传到本地目录下
hadoop fs -get hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_all_uids_with_data_input_final_copy_0/* /data1/service/kgs_tmp/inputfile0
hadoop fs -get hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_all_uids_with_data_input_final_copy_1/* /data1/service/kgs_tmp/inputfile1
hadoop fs -get hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_all_uids_with_data_input_final_copy_2/* /data1/service/kgs_tmp/inputfile2

hadoop fs -get hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_all_uids_with_data_input_final_copy_4/* /data1/service/kgs_tmp/inputfile4
hadoop fs -get hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_all_uids_with_data_input_final_copy_3/* /data1/service/kgs_tmp/inputfile3


hadoop fs -du -s -h hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/idl_limao_user_cidset_agg/*

*/

DROP TABLE tmp_kgs_financial_uid_std_score;
CREATE TABLE tmp_kgs_financial_uid_std_score
(
uid          STRING COMMENT 'uid',
score        FLOAT COMMENT 'score'
)
comment "click_uid_score"
PARTITIONED BY (ds string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;

set hive.exec.compress.output=false;
set mapreduce.output.fileoutputformat.compress=false;
INSERT INTO tmp_kgs_financial_uid_std_score PARTITION (ds='2018-02-26')
SELECT
uid,
1/(1+exp(-1*y)) AS score
FROM
    (SELECT
    uid,
    0.5*log((1+y)/(1-y)) AS y
    FROM
        (SELECT
        uid,
        log(score/(1-score)) AS y
        FROM tmp_kgs_financial_uid_score
        ) t1
    ) t2;






