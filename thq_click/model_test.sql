DROP table tmp_kgs_thq_uid_score_unique;
CREATE TABLE tmp_kgs_thq_uid_score_unique AS
SELECT 
uid,
group_name,
score
FROM
    (SELECT 
    uid,
    group_name,
    score,
    row_number()over(Partition BY uid ORDER BY score DESC) AS ranks
    FROM tmp_kgs_thq_uid_score
    ) t1
WHERE ranks=1;

DROP table tmp_kgs_thq_uid_score_distribfution;
CREATE TABLE tmp_kgs_thq_uid_score_distribution AS
SELECT
group_name,
COUNT(1) AS num,
max(score) AS max_score,
min(score) AS min_score,
avg(score) AS avg_score
FROM tmp_kgs_thq_uid_score_unique
GROUP BY group_name;

set hive.auto.convert.join=false;
DROP table tmp_kgs_thq_uid_score_distribution_top10;
CREATE TABLE tmp_kgs_thq_uid_score_distribution_top10 AS
SELECT
group_name,
COUNT(1),
max(score) AS max_score,
min(score) AS min_score,
avg(score) AS avg_score
FROM 
    (SELECT
    t1.uid,
    t1.group_name,
    t1.score,
    t2.num,
    row_number()over(Partition BY t1.group_name ORDER BY t1.score DESC) AS ranks
    FROM tmp_kgs_thq_uid_score_unique t1
    LEFT JOIN tmp_kgs_thq_uid_score_distribution t2
    ON t1.group_name=t2.group_name
    ) t3
WHERE ranks<=INT(num*0.1)
GROUP BY group_name;

set hive.auto.convert.join=false;
DROP table tmp_kgs_thq_uid_score_top10;
CREATE TABLE tmp_kgs_thq_uid_score_top10 AS
SELECT
uid,
group_name,
score
FROM 
    (SELECT
    t1.uid,
    t1.group_name,
    t1.score,
    t2.num,
    row_number()over(Partition BY t1.group_name ORDER BY t1.score DESC) AS ranks
    FROM tmp_kgs_thq_uid_score_unique t1
    LEFT JOIN tmp_kgs_thq_uid_score_distribution t2
    ON t1.group_name=t2.group_name
    ) t3
WHERE ranks<=INT(num*0.1);

-- 创建表
drop table tmp_kgs_group_name_selection;
CREATE TABLE tmp_kgs_group_name_selection
(  
group_name             string,
union_group_name       string
)
-- PARTITIONED BY (ds string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;

INSERT INTO tmp_kgs_group_name_selection
SELECT "男士针织衫" AS group_name, "nanzhuang" AS union_group_name
UNION ALL
SELECT "男士短外套" AS group_name, "nanzhuang" AS union_group_name
UNION ALL
SELECT "男士衬衫长裤厚外套爸爸装" AS group_name, "nanzhuang" AS union_group_name
UNION ALL
SELECT "羊绒衫" AS group_name, "nvzhuang" AS union_group_name
UNION ALL
SELECT "皮毛类外套" AS group_name, "nvzhuang" AS union_group_name
UNION ALL
SELECT "女士普通外套" AS group_name, "nvzhuang" AS union_group_name
UNION ALL
SELECT "针织衫" AS group_name, "nvzhuang" AS union_group_name
UNION ALL
SELECT "女裤" AS group_name, "nvzhuang" AS union_group_name
UNION ALL
SELECT "半身裙" AS group_name, "nvzhuang" AS union_group_name
UNION ALL
SELECT "卤味" AS group_name, "shipin" AS union_group_name
UNION ALL
SELECT "糕点" AS group_name, "shipin" AS union_group_name;

DROP TABLE tmp_kgs_thq_test_send_group_uids;
CREATE TABLE tmp_kgs_thq_test_send_group_uids AS
SELECT
uid,
topic_name
FROM
    (SELECT
    uid,
    topic_name,
    row_number()over(Partition BY topic_name ORDER BY r_score) AS ranks
    FROM
        (select
        t1.uid,
        t2.union_group_name AS topic_name,
        rand() AS r_score
        FROM tmp_kgs_thq_uid_score_top10 t1
        LEFT JOIN tmp_kgs_group_name_selection t2
        ON t1.group_name=t2.group_name
        WHERE t2.group_name IS NOT NULL
        ) t3
    ) t4
WHERE ranks<=10000;

set hive.exec.compress.output=false;
set mapreduce.output.fileoutputformat.compress=false;
DROP TABLE tmp_kgs_thq_test_send_group_uids_final;
CREATE TABLE tmp_kgs_thq_test_send_group_uids_final AS
SELECT
t1.uid,
t2.info,
t1.topic_name
FROM tmp_kgs_thq_test_send_group_uids t1
LEFT JOIN
    (SELECT
    distinct uid,
    concat_ws("|",mobile_province,mobile_city,mobile_operators) AS info
    FROM idl_limao_uid_agg
    WHERE ds="2018-02-26"
    ) t2 
ON t1.uid=t2.uid
WHERE t2.uid IS NOT NULL;

SELECT topic_name,count(1) from tmp_kgs_thq_test_send_group_uids_final group by topic_name;
nanzhuang	9989
nvzhuang	9892
shipin	9939

-- 建立分区表,不压缩
set hive.exec.compress.output=false;
set mapreduce.output.fileoutputformat.compress=false;
drop table tmp_kgs_thq_uid_test_output;
CREATE TABLE tmp_kgs_thq_uid_test_output
(  
uid string, 
info string
)
PARTITIONED BY (ds string, topic_name string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;

SET hive.exec.compress.output=FALSE;
SET mapreduce.output.fileoutputformat.compress=FALSE;
ALTER TABLE tmp_kgs_thq_uid_test_output DROP PARTITION (ds="2018-02-27");
INSERT INTO tmp_kgs_thq_uid_test_output PARTITION (ds,topic_name)
SELECT 
uid,
info,
'2018-02-27' AS ds,
topic_name
FROM tmp_kgs_thq_test_send_group_uids_final;

ds=2018-02-27/topic_name=nanzhuang
ds=2018-02-27/topic_name=nvzhuang
ds=2018-02-27/topic_name=shipin

INSERT INTO api_channel.idl_dataflow_msguser_jobs (user_key, value_number, group_id, session_id, is_used, insertdt, updatedt, hdfs_path, info)
VALUES ('85t3p8aiplj5',
       9989,
       "2018-02-27",
       substring(MD5(RAND()),1,20),
       '0',
       now(),
       now(),
       '/user/hive/warehouse/leesdata.db/tmp_kgs_thq_uid_test_output/ds=2018-02-27/topic_name=nanzhuang',
       '男装测试');
INSERT INTO api_channel.idl_dataflow_msguser_jobs (user_key, value_number, group_id, session_id, is_used, insertdt, updatedt, hdfs_path, info)
VALUES ('85t3p8aiplj5',
       9892,
       "2018-02-27",
       substring(MD5(RAND()),1,20),
       '0',
       now(),
       now(),
       '/user/hive/warehouse/leesdata.db/tmp_kgs_thq_uid_test_output/ds=2018-02-27/topic_name=nvzhuang',
       '女装测试');
INSERT INTO api_channel.idl_dataflow_msguser_jobs (user_key, value_number, group_id, session_id, is_used, insertdt, updatedt, hdfs_path, info)
VALUES ('85t3p8aiplj5',
       9939,
       "2018-02-27",
       substring(MD5(RAND()),1,20),
       '0',
       now(),
       now(),
       '/user/hive/warehouse/leesdata.db/tmp_kgs_thq_uid_test_output/ds=2018-02-27/topic_name=shipin',
       '食品测试');       
