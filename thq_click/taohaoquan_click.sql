idl_taohaoquan_msg_send_log
idl_taohaoquan_sms_click_log
idl_taohaoquan_member_agg

-- 总的发送人数 16388221	10318714
SELECT 
count(1),
count(distinct uid)
FROM idl_taohaoquan_msg_send_log;
-- 总的点击人数 267067
SELECT count(distinct uid)
FROM idl_taohaoquan_sms_click_log;
-- 总的会员数 376373
SELECT count(distinct uid)
FROM idl_taohaoquan_member_agg;

-- 所有的样本及标签,所有发送样本的uid和session_id
DROP TABLE tmp_kgs_thq_click_all_sample_uids;
CREATE TABLE tmp_kgs_thq_click_all_sample_uids AS
SELECT 
t1.uid,
t1.ds as send_date,
t1.session_id as send_session,
t2.insertdt as member_date,
t2.session_id as member_session,
IF(t2.uid IS NULL,'0','1') AS label
FROM
   (SELECT 
   DISTINCT uid,
   session_id,
   ds
   FROM idl_taohaoquan_msg_send_log
   ) t1
LEFT JOIN
    (SELECT 
    DISTINCT uid,
    insertdt,
    session_id
    FROM idl_taohaoquan_member_agg
    WHERE ds="2018-01-26"
    ) t2 
ON t1.uid=t2.uid;

select label, count(distinct uid) FROM tmp_kgs_thq_click_all_sample_uids GROUP BY label;
0	10756186
1	406579

DROP TABLE tmp_kgs_thq_click_all_sample_uids01;
CREATE TABLE tmp_kgs_thq_click_all_sample_uids01 AS
SELECT 
uid,
send_date,
send_session,
member_date,
member_session,
label
FROM
    (SELECT 
    uid,
    send_date,
    send_session,
    member_date,
    member_session,
    label,
    ROW_NUMBER()OVER(PARTITION BY uid ORDER BY same_session DESC,i_diff,r_value) AS ranks
    FROM
        (SELECT uid,
        send_date,
        send_session,
        member_date,
        member_session,
        label,
        if(send_session=member_session,1,0) AS same_session,
        if(label=1,datediff(member_date,send_date),0) AS i_diff,
        rand() AS r_value
        FROM tmp_kgs_thq_click_all_sample_uids
        WHERE (send_date<=member_date OR ISNULL(member_date))
        AND send_date>="2017-12-21"
        AND NOT ISNULL(send_session)
        AND length(send_session)>0
        ) s
    ) s1
WHERE ranks=1;

select label,count(1) from tmp_kgs_thq_click_all_sample_uids01 group by label;
0	8662813
1	201980
正样本比例:201980/(201980+8662813)=0.02278

-- 找到session_id对应的组别名称:7076108+172969=7249077
DROP TABLE tmp_kgs_thq_click_all_sample_uid_group;
CREATE TABLE tmp_kgs_thq_click_all_sample_uid_group
(
uid          STRING COMMENT 'uid',
label        STRING COMMENT 'label',
group_name   STRING COMMENT 'group_name',
send_date    STRING COMMENT 'send_date'
)
comment "click_uid_score"
-- PARTITIONED BY (ds string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;

set hive.exec.compress.output=false;
set mapreduce.output.fileoutputformat.compress=false;
INSERT INTO tmp_kgs_thq_click_all_sample_uid_group
SELECT 
distinct t1.uid,
t1.label,
t2.group_name,
t1.send_date --发送日期
FROM tmp_kgs_thq_click_all_sample_uids01 t1
LEFT JOIN 
    (SELECT *
    FROM idl_taohaoquan_session_config_dim
    WHERE ds="2018-01-26"
    ) t2
ON t1.send_session=t2.session_id
WHERE t2.session_id IS NOT NULL;

select label,count(1) from tmp_kgs_thq_click_all_sample_uid_group group by label;
179306+6061424=6240730
0	6061424
1	179306
179306/(179306+6061424)=0.028

-- 查找短信发送之前购买商品的titleid
set mapreduce.map.memory.mb=2048;
set mapreduce.map.java.opts=-Xmx1600m;
DROP table tmp_kgs_thq_sample_user_titleid;
CREATE TABLE tmp_kgs_thq_sample_user_titleid AS
SELECT
s1.uid,
s1.label,
s1.group_name,
s2.title_id
FROM tmp_kgs_thq_click_all_sample_uid_group s1
LEFT JOIN
    (SELECT *
    FROM idl_limao_user_title_agg
    WHERE ds="2018-01-25"
    ) s2
ON s1.uid=s2.uid
WHERE s2.uid IS NOT NULL AND s1.send_date>s2.last_date;

-- select label,count(distinct uid) from tmp_kgs_thq_sample_user_titleid group by label;
-- 0	5610643
-- 1	151841

set mapreduce.map.memory.mb=2048;
set mapreduce.map.java.opts=-Xmx1600m;
DROP table tmp_kgs_thq_sample_user_token;
CREATE TABLE tmp_kgs_thq_sample_user_token AS
SELECT
t1.uid,
t1.label,
t1.group_name,
t1.title_id,
t2.token
FROM tmp_kgs_thq_sample_user_titleid t1
LEFT JOIN
    (SELECT *
    FROM  idl_titel_token_log
    WHERE ds="2018-01-25"
    ) t2
ON t1.title_id=t2.sentence_id
WHERE t2.sentence_id IS NOT NULL;

set mapreduce.map.memory.mb=2048;
set mapreduce.map.java.opts=-Xmx1600m; 
DROP table tmp_kgs_thq_sample_user_keywords;
CREATE TABLE tmp_kgs_thq_sample_user_keywords AS
SELECT
uid,
label,
group_name,
collect_set(keyword) AS keywords
FROM 
    (SELECT 
    DISTINCT uid,
    label,
    group_name,
    keyword
    FROM tmp_kgs_thq_sample_user_token
    LATERAL VIEW explode(token) mytable AS keyword
    ) t1
GROUP BY uid,label,group_name;

set hive.exec.compress.output=false;
set mapreduce.output.fileoutputformat.compress=false;
DROP TABLE tmp_kgs_thq_sample_user_data;
CREATE TABLE tmp_kgs_thq_sample_user_data AS
SELECT
t3.uid,
t3.label,
t3.group_name,
t3.keywords,
t3.province,
t4.tier,
t3.head,
t3.tail
FROM
    (SELECT
    t1.uid,
    t1.label,
    t1.group_name,
    t1.keywords,
    t2.province,
    t2.city,
    t2.head,
    t2.tail
    FROM tmp_kgs_thq_sample_user_keywords t1
    LEFT JOIN 
        (SELECT 
        uid,
        mobile_province AS province,
        mobile_city AS city,
        substring(mobile_mark,1,3) AS head,
        substring(mobile_mark,-1,1) AS tail
        FROM idl_limao_active_moblie_agg
        WHERE ds="2018-01-25"
        ) t2
    ON t1.uid=t2.uid
    ) t3
LEFT JOIN config_city_region_tier_dim t4
ON t3.city=t4.city;

select label,count(1) from tmp_kgs_thq_sample_user_data group by label;
0	6043296
1	178565

set mapreduce.map.memory.mb=2048;
set mapreduce.map.java.opts=-Xmx1600m; 
set hive.exec.compress.output=false;
set mapreduce.output.fileoutputformat.compress=false;
DROP TABLE tmp_kgs_thq_all_sample_uid_subroot;
CREATE TABLE tmp_kgs_thq_all_sample_uid_subroot AS
SELECT
uid,
collect_set(subroot_name) subroots
FROM
    (SELECT
    DISTINCT t1.uid,
    t2.subroot_name
    FROM tmp_kgs_thq_click_all_sample_uid_group t1
    LEFT JOIN
        (SELECT *
        FROM idl_limao_user_cidset_agg
        WHERE ds="2018-01-24"
        ) t2
    ON t1.uid=t2.uid
    WHERE t2.uid IS NOT NULL AND t1.send_date>t2.last_date
    ) t3
GROUP BY uid;

-- 全部样本数据,并传回国内
DROP TABLE tmp_kgs_thq_click_all_sample_data;
CREATE TABLE tmp_kgs_thq_click_all_sample_data
(
uid          STRING COMMENT 'uid',
label        STRING COMMENT 'label',
group_name   STRING COMMENT 'group_name',
keywords     ARRAY<STRING> COMMENT 'keywords',
province     STRING COMMENT 'province',
tier         STRING COMMENT 'tier',
head         STRING COMMENT 'head',
tail         STRING COMMENT 'tail',
subroots     ARRAY<STRING> COMMENT 'subroots'
)
comment "click_uid_score"
-- PARTITIONED BY (ds string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE;

set hive.exec.compress.output=false;
set mapreduce.output.fileoutputformat.compress=false;
INSERT INTO tmp_kgs_thq_click_all_sample_data
SELECT
t1.uid,
t1.label,
t1.group_name,
t1.keywords,
t1.province,
t1.tier,
t1.head,
t1.tail,
t2.subroots
FROM tmp_kgs_thq_sample_user_data t1
LEFT JOIN tmp_kgs_thq_all_sample_uid_subroot t2
ON t1.uid=t2.uid
WHERE t2.uid IS NOT NULL;

SELECT label,count(1) from tmp_kgs_thq_click_all_sample_data group by label;
0	5986350
1	176932
176932+5986350=6163282
176932/6163282=0.0287
共 6163282/2=3081641

-- 生成训练-测试数据
set mapreduce.map.memory.mb=2048;
set mapreduce.map.java.opts=-Xmx1600m; 
DROP TABLE tmp_kgs_thq_all_sample_train_test_data;
CREATE TABLE tmp_kgs_thq_all_sample_train_test_data AS
select
uid,
label,
group_name,
keywords,
province,
tier,
head,
tail,
subroots,
IF(rand()<0.5,'train','test') AS train_test
from tmp_kgs_thq_click_all_sample_data t1;

select train_test,label,count(1) from tmp_kgs_thq_all_sample_train_test_data group by train_test,label;
test	0	2995250
test	1	88527
train	0	2991100
train	1	88405

-- 生成训练数据
set mapreduce.map.memory.mb=2048;
set mapreduce.map.java.opts=-Xmx1600m; 
DROP TABLE tmp_kgs_thq_160000_sample_train_data;
CREATE TABLE tmp_kgs_thq_160000_sample_train_data AS
select *
from tmp_kgs_thq_all_sample_train_test_data t1
where label='0' AND train_test='train'
order by rand()
limit 100000
UNION ALL
select *
from tmp_kgs_thq_all_sample_train_test_data t2
where label='1' AND train_test='train'
order by rand()
limit 60000;

-- 导出训练数据
set mapreduce.job.reduces=1;
insert overwrite local directory '/home/kangguosheng/tmp'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE
select
uid,
label,
group_name,
keywords,
province,
tier,
head,
tail,
subroots
from tmp_kgs_thq_160000_sample_train_data t1
order by rand();

-- 生成测试数据
set mapreduce.map.memory.mb=2048;
set mapreduce.map.java.opts=-Xmx1600m; 
DROP TABLE tmp_kgs_thq_200000_sample_test_data;
CREATE TABLE tmp_kgs_thq_200000_sample_test_data AS
select *
from tmp_kgs_thq_all_sample_train_test_data t1
WHERE train_test='test'
order by rand()
limit 200000;

select label,count(1) from tmp_kgs_thq_200000_sample_test_data group by label;
0	194180
1	5820

-- 导出测试数据
set mapreduce.job.reduces=1;
insert overwrite local directory '/home/kangguosheng/tmp'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
COLLECTION ITEMS TERMINATED BY '\073'
MAP KEYS TERMINATED BY '\072'
STORED AS TEXTFILE
select
t1.uid,
t1.label,
t1.group_name,
t1.keywords,
t1.province,
t1.tier,
t1.head,
t1.tail,
t1.subroots
from tmp_kgs_thq_200000_sample_test_data t1
order by rand();