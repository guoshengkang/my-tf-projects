DROP TABLE tmp_kgs_thq_all_user_data_all;
CREATE TABLE tmp_kgs_thq_all_user_data_all AS
SELECT
t1.uid,
t1.group_name,
t2.keywords,
t2.province,
t2.tier,
t2.head,
t2.tail,
t2.subroots
FROM tmp_kgs_thq_user_group_name t1
LEFT JOIN tmp_kgs_thq_all_user_data t2
ON t1.uid=t2.uid
WHERE t2.uid IS NOT NULL;

-- 59198792	35768978
select 
count(1),count(distinct uid) 
from tmp_kgs_thq_all_user_data_all;

-- 将每个分区插入100各分区
drop table tmp_kgs_thq_all_user_data_all_input;
CREATE TABLE tmp_kgs_thq_all_user_data_all_input
(  
uid        string, 
group_name string, 
keywords   ARRAY<STRING>,
province   string,
tier       string,
head       string,
tail       string,
subroots   ARRAY<STRING>
)
PARTITIONED BY (ds string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;

set hive.exec.compress.output=false;
set mapreduce.output.fileoutputformat.compress=false;
INSERT INTO tmp_kgs_thq_all_user_data_all_input PARTITION (ds)
SELECT
uid,
group_name,
keywords,
province,
tier,
head,
tail,
subroots,
concat("group_",cast(rk as string)) as ds
FROM
    (SELECT
    uid,
    group_name,
    keywords,
    province,
    tier,
    head,
    tail,
    subroots,
    ceil(rand()*100) AS rk
    FROM tmp_kgs_thq_all_user_data_all
    ) t1;


drop table tmp_kgs_thq_all_user_data_all_input_copy;
CREATE TABLE tmp_kgs_thq_all_user_data_all_input_copy
(  
uid        string, 
group_name string, 
keywords   ARRAY<STRING>,
province   string,
tier       string,
head       string,
tail       string,
subroots   ARRAY<STRING>
)
PARTITIONED BY (ds string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;
    
set hive.exec.compress.output=false;
set mapreduce.output.fileoutputformat.compress=false;
INSERT INTO tmp_kgs_thq_all_user_data_all_input_copy PARTITION (ds)
SELECT
uid,
group_name,
keywords,
province,
tier,
head,
tail,
subroots,
ds
FROM tmp_kgs_thq_all_user_data_all_input
distribute by ds;

-- hadoop fs -get hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_thq_all_user_data_all_input_copy/* /data1/service/kgs_thq/inputfile0
-- hadoop fs -ls hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_thq_all_user_data_all_input_copy/*
-- hadoop fs -du -h hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_thq_all_user_data_all_input_copy
-- hadoop fs -du -s -h hdfs://172.31.31.115:8020/user/hive/warehouse/leesdata.db/tmp_kgs_thq_all_user_data_all_input_copy

DROP TABLE tmp_kgs_thq_uid_score_load;
CREATE TABLE tmp_kgs_thq_uid_score_load
(
uid          STRING COMMENT 'uid',
group_name   STRING COMMENT 'group_name',
score        FLOAT COMMENT 'score'
)
comment "click_uid_score"
PARTITIONED BY (ds string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;

DROP TABLE tmp_kgs_thq_uid_score;
CREATE TABLE tmp_kgs_thq_uid_score
(
uid          STRING COMMENT 'uid',
group_name   STRING COMMENT 'group_name',
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
INSERT INTO tmp_kgs_thq_uid_score PARTITION (ds='2018-02-26')
SELECT 
uid,
group_name,
score
FROM tmp_kgs_thq_uid_score_load;

ALTER TABLE tmp_kgs_thq_uid_score_load ADD PARTITION(ds='0');
load data inpath '/tmp/kgs_thq/outputfile1' overwrite into table leesdata.tmp_kgs_thq_uid_score_load partition(ds='0');

hadoop fs -mkdir hdfs://172.31.31.115:8020/tmp/kgs_thq
hadoop fs -mkdir hdfs://172.31.31.115:8020/tmp/kgs_thq/outputfile0
hadoop fs -mkdir hdfs://172.31.31.115:8020/tmp/kgs_thq/outputfile1

hadoop fs -put /data1/service/kgs_thq/outputfile1/* hdfs://172.31.31.115:8020/tmp/kgs_thq/outputfile1

-- 查看目录下的文件列表
hadoop fs -ls hdfs://172.31.31.115:8020/tmp/kgs_thq/outputfile1

sudo nohup python -u get_score_thq.py >>py_log.log 2>&1 &
*/

-------------------------------------------------------
DROP table tmp_kgs_thq_all_user_token;
CREATE TABLE tmp_kgs_thq_all_user_token AS
SELECT
t1.uid,
t1.title_id,
t2.token
FROM
    (SELECT
    uid,
    title_id
    FROM idl_limao_user_title_agg
    WHERE ds="2018-01-29"
    ) t1
LEFT JOIN 
    (SELECT
    sentence_id,
    token
    FROM idl_titel_token_log
    WHERE ds="2018-01-29"
    ) t2
ON t1.title_id=t2.sentence_id
WHERE t2.sentence_id IS NOT NULL;

DROP table tmp_kgs_thq_all_user_keywords;
CREATE TABLE tmp_kgs_thq_all_user_keywords AS
SELECT
uid,
collect_set(keyword) AS keywords
FROM
    (SELECT 
    DISTINCT uid,
    keyword
    FROM tmp_kgs_thq_all_user_token
    LATERAL VIEW explode(token) mytable AS keyword
    ) t1
GROUP BY uid;

DROP TABLE tmp_kgs_thq_all_user_keywords_phone;
CREATE TABLE tmp_kgs_thq_all_user_keywords_phone AS
SELECT
DISTINCT t3.uid,
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
    FROM tmp_kgs_thq_all_user_keywords t1
    LEFT JOIN 
        (SELECT 
        uid,
        mobile_province AS province,
        mobile_city AS city,
        substring(mobile_mark,1,3) AS head,
        substring(mobile_mark,-1,1) AS tail
        FROM idl_limao_active_moblie_agg
        WHERE ds="2018-01-29"
        ) t2
    ON t1.uid=t2.uid
    ) t3
LEFT JOIN config_city_region_tier_dim t4
ON t3.city=t4.city;

DROP TABLE tmp_kgs_thq_all_user_subroot;
CREATE TABLE tmp_kgs_thq_all_user_subroot AS
SELECT
uid,
collect_set(subroot_name) subroots
FROM
    (SELECT
    DISTINCT t1.uid,
    t2.subroot_name
    FROM tmp_kgs_thq_all_user_keywords_phone t1
    LEFT JOIN
        (SELECT *
        FROM idl_limao_user_cidset_agg
        WHERE ds="2018-01-29"
        ) t2
    ON t1.uid=t2.uid
    WHERE t2.uid IS NOT NULL
    ) t3
GROUP BY uid;

-- 340400798
set hive.exec.compress.output=false;
set mapreduce.output.fileoutputformat.compress=false;
DROP TABLE tmp_kgs_thq_all_user_data;
CREATE TABLE tmp_kgs_thq_all_user_data AS
SELECT
t1.uid,
t1.keywords,
t1.province,
t1.tier,
t1.head,
t1.tail,
t2.subroots
FROM tmp_kgs_thq_all_user_keywords_phone t1
LEFT JOIN tmp_kgs_thq_all_user_subroot t2
ON t1.uid=t2.uid
WHERE t2.uid IS NOT NULL;
