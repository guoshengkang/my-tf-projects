-- 查找互联网金融的号码
DROP TABLE tmp_kgs_financial_user_all;
CREATE TABLE tmp_kgs_financial_user_all AS
SELECT
DISTINCT mobile_no
FROM idl_msg_received_join_log
WHERE msg_type='消息通知' AND msg_industry='互联网金融';

-- 10214970
select count(1) 
from tmp_kgs_financial_user_all;

DROP TABLE tmp_kgs_msguser_financial_all_user_new;
CREATE TABLE tmp_kgs_msguser_financial_all_user_new AS
SELECT
mobile_no,  
create_time
FROM
    (SELECT
    mobile_no,   
    create_time,
    row_number()over(Partition BY mobile_no ORDER BY create_time DESC) AS ranks
    FROM idl_msg_received_join_log
    WHERE status='1' 
    AND receive_code='0' 
    AND msg_type='消息通知'
    AND msg_industry='互联网金融'
    ) t1
WHERE t1.ranks=1;

select count(1) --8136140
from tmp_kgs_msguser_financial_all_user_new;
--------------------------------------------
idl_limao_user_title_agg

idl_taobao_title_dim

idl_limao_uid_agg

-- 528754623
select count(1)
FROM idl_limao_uid_agg
where ds='2017-12-26';
-- 525165508
select count(DISTINCT uid)
FROM idl_limao_uid_agg
where ds='2017-12-26';
-- 326664537
SELECT count(DISTINCT uid)
FROM idl_limao_user_title_agg
WHERE ds='2017-12-25';

-- 幢上的用户 8136140
CREATE TABLE tmp_kgs_financial_user_meet_all AS 
SELECT
DISTINCT uid
FROM 
    (SELECT uid
    FROM idl_limao_uid_agg
    where ds='2017-12-26'
    ) t1
LEFT JOIN tmp_kgs_msguser_financial_all_user_new t2
ON t1.uid=t2.mobile_no
WHERE t2.mobile_no IS NOT NULL;
-- 未幢上的用户 514950538
CREATE TABLE tmp_kgs_financial_user_notmeet_all AS 
SELECT
DISTINCT uid
FROM 
    (SELECT uid
    FROM idl_limao_uid_agg
    where ds='2017-12-26'
    ) t1
LEFT JOIN tmp_kgs_financial_user_all t2
ON t1.uid=t2.mobile_no
WHERE t2.mobile_no IS NULL;

-- 抽取用户样本各1000000
CREATE TABLE tmp_kgs_financial_user_sample AS 
SELECT
uid,
'1' AS label
FROM tmp_kgs_financial_user_meet_all
ORDER BY rand()
limit 1000000
UNION ALL
SELECT
uid,
'0' AS label
FROM tmp_kgs_financial_user_notmeet_all
ORDER BY rand()
limit 1000000;

-- 建立表结构,传到国外
drop table tmp_kgs_financial_user_sample_new;
CREATE TABLE tmp_kgs_financial_user_sample_new
(
uid STRING COMMENT 'uid',
label STRING COMMENT 'label'
)
comment "financial_user_sample"
-- PARTITIONED BY (ds STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;

INSERT INTO tmp_kgs_financial_user_sample_new
SELECT *
FROM tmp_kgs_financial_user_sample;

DROP TABLE tmp_kgs_financial_user_sample;
ALTER TABLE tmp_kgs_financial_user_sample_new rename to tmp_kgs_financial_user_sample;

-- 建立表结构,传到国外
drop table tmp_kgs_financial_user_sample;
CREATE TABLE tmp_kgs_financial_user_sample
(
uid STRING COMMENT 'uid',
label STRING COMMENT 'label'
)
comment "financial_user_sample"
-- PARTITIONED BY (ds STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;

select count(distinct uid)
from tmp_kgs_financial_user_sample;

-- 找到用户的title_id (国外)
CREATE TABLE tmp_kgs_financial_user_sample_titleid AS
SELECT
t1.uid,
t1.label,
t2.title_id
FROM tmp_kgs_financial_user_sample t1
LEFT JOIN
    (SELECT *
    FROM idl_limao_user_title_agg
    WHERE ds='2017-12-25'
    ) t2
ON t1.uid=t2.uid
WHERE t2.uid IS NOT NULL;

-- 找到用户的title_id对应的分词
DROP TABLE tmp_kgs_financial_user_sample_token;
CREATE TABLE tmp_kgs_financial_user_sample_token AS
SELECT 
t1.uid,
t1.label,
t2.token
FROM tmp_kgs_financial_user_sample_titleid t1
LEFT JOIN 
    (SELECT *
    FROM idl_titel_token_log
    WHERE ds='2017-12-26'
    ) t2
ON t1.title_id=t2.sentence_id
WHERE t2.sentence_id IS NOT NULL;

-- 找到用户的title_id对应的token
drop table tmp_kgs_financial_user_sample_keywords;
CREATE TABLE tmp_kgs_financial_user_sample_keywords
(
uid         STRING COMMENT 'uid',
label       STRING COMMENT 'label',
keywords    ARRAY<STRING> COMMENT 'keywords'
)
comment "financial_user_sample_keywords"
-- PARTITIONED BY (ds STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;

label	_c1

SET mapreduce.output.fileoutputformat.compress.codec=org.apache.hadoop.io.compress.GzipCodec;
INSERT INTO tmp_kgs_financial_user_sample_keywords
SELECT
uid,
label,
collect_set(keyword) AS keywords
FROM
    (SELECT
    uid,
    label,
    keyword
    FROM tmp_kgs_financial_user_sample_token
    LATERAL VIEW explode(token) mytable AS keyword
    ) t1
GROUP BY uid,label;

SELECT 
label,
count(1)
FROM tmp_kgs_financial_user_sample_keywords
GROUP BY label;
0	613809
1	496990
1110802

-- 建立表结构,传到国内token
drop table tmp_kgs_financial_user_sample_keywords;
CREATE TABLE tmp_kgs_financial_user_sample_keywords
(
uid         STRING COMMENT 'uid',
label       STRING COMMENT 'label',
keywords    ARRAY<STRING> COMMENT 'keywords'
)
comment "financial_user_sample_keywords"
-- PARTITIONED BY (ds STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;

drop table tmp_kgs_financial_user_sample_info;
CREATE TABLE tmp_kgs_financial_user_sample_info
(
uid        STRING COMMENT 'uid',
label      STRING COMMENT 'label',
keywords   ARRAY<STRING> COMMENT 'keywords',
province   STRING COMMENT 'province',
tier       STRING COMMENT 'tier',
head       STRING COMMENT 'head',
tail       STRING COMMENT 'tail'
)
comment "financial_user_sample_info"
-- PARTITIONED BY (ds STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;

INSERT INTO tmp_kgs_financial_user_sample_info
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
    t2.mobile_province AS province,
    t2.mobile_city AS city,
    substring(t2.mobile_mark,1,3) AS head,
    substring(t2.mobile_mark,-1,1) AS tail
    FROM tmp_kgs_financial_user_sample_keywords t1
    LEFT JOIN
        (SELECT *
        FROM idl_limao_uid_agg
        WHERE ds="2017-12-28"
        ) t2
    ON t1.uid=t2.uid
    WHERE t2.uid IS NOT NULL
    ) t3
LEFT JOIN config_city_region_tier_dim t4
ON t3.city=t4.city
WHERE t4.city IS NOT NULL;

-- 抽取最终的用户样本500000
DROP TABLE tmp_kgs_financial_user_final_sample;
CREATE TABLE tmp_kgs_financial_user_final_sample AS 
SELECT
uid,
label,
keywords,
province,
tier,
head,
tail
FROM tmp_kgs_financial_user_sample_info
WHERE label='1'
ORDER BY rand()
limit 200000
UNION ALL
SELECT
uid,
label,
keywords,
province,
tier,
head,
tail
FROM tmp_kgs_financial_user_sample_info
WHERE label='0'
ORDER BY rand()
limit 300000;

-- 导出数据
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
from tmp_kgs_financial_user_final_sample
order by rand();


