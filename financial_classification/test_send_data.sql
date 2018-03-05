-- 6949673
set mapreduce.map.memory.mb=2048;
set mapreduce.map.java.opts=-Xmx1600m; 
CREATE TABLE tmp_kgs_test_send_uids_with_label0 AS
SELECT
t1.uid,
t1.label
FROM tmp_kgs_all_uids_with_label t1
LEFT JOIN
    (SELECT 
    DISTINCT uid
    FROM idl_limao_uid_agg
    WHERE ds="2018-01-09" 
    AND mobile_city="上海"
    AND mobile_operators="中国移动"
    ) t2
ON t1.uid=t2.uid
WHERE t2.uid IS NOT NULL
AND t1.label='0';

-- 抽取1000000样本做为发送测试数据
DROP TABLE tmp_kgs_all_test_uids_with_label;
CREATE TABLE tmp_kgs_all_test_uids_with_label AS
SELECT
uid,
label
FROM tmp_kgs_test_send_uids_with_label0 
ORDER BY rand()
limit 1000000;

set mapreduce.map.memory.mb=2048;
set mapreduce.map.java.opts=-Xmx1600m;
DROP table tmp_kgs_all_test_user_titleid;
CREATE TABLE tmp_kgs_all_test_user_titleid AS
SELECT
s1.uid,
s1.label,
s2.title_id
FROM tmp_kgs_all_test_uids_with_label s1
LEFT JOIN
    (SELECT *
    FROM idl_limao_user_title_agg
    WHERE ds="2018-01-03"
    ) s2
ON s1.uid=s2.uid;

set mapreduce.map.memory.mb=2048;
set mapreduce.map.java.opts=-Xmx1600m;
DROP table tmp_kgs_all_test_user_token;
CREATE TABLE tmp_kgs_all_test_user_token AS
SELECT
t1.uid,
t1.label,
t1.title_id,
t2.token
FROM tmp_kgs_all_test_user_titleid t1
LEFT JOIN
    (SELECT *
    FROM  idl_titel_token_log
    WHERE ds="2018-01-07"
    ) t2
ON t1.title_id=t2.sentence_id
WHERE t2.sentence_id IS NOT NULL;

set mapreduce.map.memory.mb=2048;
set mapreduce.map.java.opts=-Xmx1600m;
DROP TABLE  tmp_kgs_all_test_user_token_explode;
CREATE TABLE tmp_kgs_all_test_user_token_explode AS
SELECT
uid,
label,
keyword
FROM tmp_kgs_all_test_user_token
LATERAL VIEW explode(token) mytable AS keyword;

set mapreduce.map.memory.mb=2048;
set mapreduce.map.java.opts=-Xmx1600m; 
DROP table tmp_kgs_all_test_user_keywords;
CREATE TABLE tmp_kgs_all_test_user_keywords AS
SELECT
uid,
label,
collect_set(keyword) AS keywords
FROM 
    (SELECT 
    DISTINCT uid,
    label,
    keyword
    FROM tmp_kgs_all_test_user_token_explode
    ) t1
GROUP BY uid,label;

DROP TABLE tmp_kgs_all_test_user_data;
CREATE TABLE tmp_kgs_all_test_user_data AS
SELECT
t3.uid,
t3.label,
t3.keywords,
t3.province,
t4.tier,
t3.head,
t3.tail
FROM
    (SELECT
    t1.uid,
    t1.label,
    t1.keywords,
    t2.province,
    t2.city,
    t2.head,
    t2.tail
    FROM tmp_kgs_all_test_user_keywords t1
    LEFT JOIN 
        (SELECT 
        uid,
        mobile_province AS province,
        mobile_city AS city,
        substring(mobile_mark,1,3) AS head,
        substring(mobile_mark,-1,1) AS tail
        FROM idl_limao_uid_agg
        WHERE ds="2018-01-07"
        ) t2
    ON t1.uid=t2.uid
    ) t3
LEFT JOIN config_city_region_tier_dim t4
ON t3.city=t4.city;

-- 导出数据--993164
set mapreduce.job.reduces=1;
insert overwrite local directory '/home/kangguosheng/tmp'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE
select
uid,
label,
keywords,
province,
tier,
head,
tail
from tmp_kgs_all_test_user_data
order by rand();

-------------------------------------------------------
-- 993164
DROP TABLE tmp_kgs_test_send_financial_uids;
CREATE TABLE tmp_kgs_test_send_financial_uids
(
uid          STRING COMMENT 'uid',
label        STRING COMMENT 'label',
score        FLOAT COMMENT 'score'
)
comment "hotkeyword_subroot"
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;

load data local inpath '/home/kangguosheng/tmp/send_test_uid_label_score.txt' 
overwrite into table tmp_kgs_test_send_financial_uids;

set hive.exec.compress.output=false;
set mapreduce.output.fileoutputformat.compress=false;
DROP TABLE tmp_kgs_test_send_group_uids;
CREATE TABLE tmp_kgs_test_send_group_uids AS
SELECT
uid,
CASE  WHEN ranks<=10000 THEN 'test_financial_group1'
      WHEN ranks>10000 AND ranks<=20000 THEN 'test_financial_group2'
      WHEN ranks>20000 AND ranks<=30000 THEN 'test_financial_group3'
      WHEN ranks>30000 THEN 'test_financial_group4'
END AS topic_name,
score
FROM
    (SELECT
    uid,
    score,
    row_number()over(ORDER BY score DESC) AS ranks
    FROM tmp_kgs_test_send_financial_uids
    ) t1
WHERE ranks<=40000;

set hive.exec.compress.output=false;
set mapreduce.output.fileoutputformat.compress=false;
DROP TABLE tmp_kgs_test_send_group_uids_final;
CREATE TABLE tmp_kgs_test_send_group_uids_final AS
SELECT
t1.uid,
t2.info,
t1.topic_name
FROM tmp_kgs_test_send_group_uids t1
LEFT JOIN
    (SELECT
    distinct uid,
    concat_ws("|",mobile_province,mobile_city,mobile_operators) AS info
    FROM idl_limao_uid_agg
    WHERE ds="2018-01-10"
    ) t2 
ON t1.uid=t2.uid
WHERE t2.uid IS NOT NULL;

set hive.exec.compress.output=false;
set mapreduce.output.fileoutputformat.compress=false;
DROP TABLE tmp_kgs_test_send_group_uids_final_all;
CREATE TABLE tmp_kgs_test_send_group_uids_final_all AS
SELECT
t1.uid,
t2.info,
t1.topic_name
FROM tmp_kgs_test_send_group_uids t1
LEFT JOIN
    (SELECT
    distinct uid,
    concat_ws("|",mobile_province,mobile_city,mobile_operators) AS info
    FROM idl_limao_uid_agg
    WHERE ds="2018-01-10"
    ) t2 
ON t1.uid=t2.uid;

SELECT 
topic_name,
count(1)
FROM tmp_kgs_test_send_group_uids_final
GROUP BY topic_name;

SET hive.exec.compress.output=FALSE;
SET mapreduce.output.fileoutputformat.compress=FALSE;
ALTER TABLE adl_zhzlong_msguser_output DROP PARTITION (ds="2018-01-11");
INSERT INTO adl_zhzlong_msguser_output PARTITION (ds,topic_name)
SELECT 
uid,
info,
'2018-01-11' AS ds,
topic_name
FROM tmp_kgs_test_send_group_uids_final;

ds=2018-01-11/topic_name=test_financial_group1
ds=2018-01-11/topic_name=test_financial_group2
ds=2018-01-11/topic_name=test_financial_group3
ds=2018-01-11/topic_name=test_financial_group4


INSERT INTO `api_channel`.`hdfs_2_kafka_dim` (`user_key`, `session_id`, `insertdt`, `hdfs_path`, `task_status`)
VALUES ('LwCnAVktFP5hAn7Q',
        substring(MD5(RAND()),1,20),
        now(),
        '/user/hive/warehouse/leesdata.db/adl_zhzlong_msguser_output/ds=2018-01-11/topic_name=test_financial_group1',
        '0');
INSERT INTO `api_channel`.`hdfs_2_kafka_dim` (`user_key`, `session_id`, `insertdt`, `hdfs_path`, `task_status`)
VALUES ('LwCnAVktFP5hAn7Q',
        substring(MD5(RAND()),1,20),
        now(),
        '/user/hive/warehouse/leesdata.db/adl_zhzlong_msguser_output/ds=2018-01-11/topic_name=test_financial_group2',
        '0');
INSERT INTO `api_channel`.`hdfs_2_kafka_dim` (`user_key`, `session_id`, `insertdt`, `hdfs_path`, `task_status`)
VALUES ('LwCnAVktFP5hAn7Q',
        substring(MD5(RAND()),1,20),
        now(),
        '/user/hive/warehouse/leesdata.db/adl_zhzlong_msguser_output/ds=2018-01-11/topic_name=test_financial_group3',
        '0');
INSERT INTO `api_channel`.`hdfs_2_kafka_dim` (`user_key`, `session_id`, `insertdt`, `hdfs_path`, `task_status`)
VALUES ('LwCnAVktFP5hAn7Q',
        substring(MD5(RAND()),1,20),
        now(),
        '/user/hive/warehouse/leesdata.db/adl_zhzlong_msguser_output/ds=2018-01-11/topic_name=test_financial_group4',
        '0');
        
-- 326283043
adl_message_source_data_agg
-- 993164
tmp_kgs_test_send_financial_uids
-- 983895
tmp_kgs_test_send_uid_two_score

set hive.exec.compress.output=false;
set mapreduce.output.fileoutputformat.compress=false;
DROP TABLE tmp_kgs_test_send_uid_two_score;
CREATE TABLE tmp_kgs_test_send_uid_two_score AS
SELECT
DISTINCT t1.uid,
t1.score,
t2.click_value
FROM tmp_kgs_test_send_financial_uids t1
LEFT JOIN 
    (SELECT * 
    FROM adl_message_source_data_agg
    WHERE ds="2017-12-31"
    ) t2
ON t1.uid=t2.uid
WHERE t2.uid IS NOT NULL;

-- 计算相关系数
SELECT
AVG(score)  AS avg_score, --0.5323737799658171
AVG(click_value)  AS avg_click_value --0.44705762569758234
FROM tmp_kgs_test_send_uid_two_score;

SELECT
SUM(x*y)/(sqrt(SUM(pow(x,2)))*sqrt(SUM(pow(y,2)))) AS corr
FROM
    (SELECT
    score-0.5323737799658171 AS x,
    click_value-0.44705762569758234 AS y
    FROM tmp_kgs_test_send_uid_two_score
    ) t1;

corr
-0.019295280842823146

-- 分段观察相关性
DROP TABLE tmp_kgs_test_send_uid_two_score_correlation;
CREATE TABLE tmp_kgs_test_send_uid_two_score_correlation AS
SELECT
ds,
avg(score) AS avg_score,
avg(click_value) AS avg_click_value
FROM
    (SELECT
    uid,
    score,
    click_value,
    NTILE(20) over(order by score desc) ds
    FROM tmp_kgs_test_send_uid_two_score
    ) t1
GROUP BY ds
ORDER BY ds;

SELECT * FROM tmp_kgs_test_send_uid_two_score_correlation;
1	0.6992675487037256	0.4464205646835361
2	0.6732421165656869	0.4479168796275178
3	0.6545367153682703	0.44735704257316444
4	0.6379421526211188	0.44670675361101336
5	0.6223343708127698	0.4460658010310038
6	0.6071922951142518	0.4463909413369827
7	0.5922711807182255	0.4457595533657176
8	0.5773557292420346	0.44632176462621853
9	0.5623122009807927	0.44590440035587237
10	0.5471065195392625	0.445902830404423
11	0.5316065831147555	0.44618710892503854
12	0.5157279948015888	0.4464111313725138
13	0.4992816451337597	0.44660948731754113
14	0.4822104797359404	0.4467475750022502
15	0.46433189889439386	0.44715062351818796
16	0.44529840819534305	0.4476009534987152
17	0.4247192160532756	0.4480248727345121
18	0.40191451889492413	0.4481854405970953
19	0.3747730504364125	0.44877956887641157
20	0.3340371289466287	0.45070938335785166
说明两者并没有相关性


DROP TABLE tmp_kgs_test_send_uid_names;
CREATE TABLE tmp_kgs_test_send_uid_names AS
SELECT
DISTINCT t1.uid,
t1.topic_name,
t2.max_name
FROM tmp_kgs_test_send_group_uids t1
LEFT JOIN adl_message_source_data_agg t2
ON t1.uid=t2.uid
WHERE t2.uid IS NOT NULL;

DROP TABLE tmp_kgs_test_send_reg_names;
CREATE TABLE tmp_kgs_test_send_reg_names
(
max_name          STRING
)
comment "tmp_kgs_test_send_reg_names"
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;
-------------
鲁子明
余文洁
步臣泽
孔丽娜
周婷婷
-------------

load data local inpath '/home/kangguosheng/tmp/max_name.txt' 
overwrite into table tmp_kgs_test_send_reg_names;

DROP TABLE tmp_kgs_test_send_find_names;
CREATE TABLE tmp_kgs_test_send_find_names AS 
SELECT
t1.uid,
t1.topic_name,
t1.max_name
FROM tmp_kgs_test_send_uid_names t1
LEFT JOIN tmp_kgs_test_send_reg_names
ON t1.max_name=t2.max_name
WHERE t2.max_name IS NOT NULL;


