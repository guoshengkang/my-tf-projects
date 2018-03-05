配置表:
config_bef_keyword_log;
config_back_keyword_log;
config_unionroot_to_category_log;
config_user_group_log;

tmp_lj_limao_recom_item_tmp

-- 所有用户的keywords
DROP TABLE tmp_kgs_thq_keywords_tid_num;
CREATE TABLE tmp_kgs_thq_keywords_tid_num AS
SELECT
uid,
STR_TO_MAP(CONCAT_WS("\073",COLLECT_SET(CONCAT_WS("\072",keyword,CAST(all_tid_num AS STRING)))),"\073","\072") AS keywords
FROM
    (SELECT
    uid,
    keyword,
    sum(tid_num) AS all_tid_num
    FROM
        (SELECT
        t1.uid,
        t1.title_id,
        t1.tid_num,
        t2.crf_token
        FROM
            (SELECT
            uid,
            title_id,
            tid_num
            FROM idl_limao_user_title_agg
            WHERE ds="2018-01-29"
            ) t1
        LEFT JOIN 
            (SELECT
            title_id,
            crf_token
            FROM idl_taobao_title_dim
            WHERE ds="2018-01-30"
            ) t2
        ON t1.title_id=t2.title_id
        WHERE t2.title_id IS NOT NULL
        ) t3
    LATERAL VIEW OUTER EXPLODE(crf_token) s1 AS keyword
    GROUP BY uid,keyword
    ) t4
GROUP BY uid;

-- 取用户前3个推荐的subroot,共出现87个
DROP TABLE tmp_kgs_thq_recom_item_tmp;
CREATE TABLE tmp_kgs_thq_recom_item_tmp AS
SELECT
uid,
subroot_back,
p_recom
FROM
    (SELECT
    uid,
    subroot_back,
    p_recom,
    ROW_NUMBER()OVER(PARTITION BY uid ORDER BY p_recom DESC) AS ranks
    FROM tmp_lj_limao_recom_item_tmp
    WHERE ds<="2018-01-29"
    ) t1
WHERE ranks<=3;

-- 90637439
SELECT count(distinct uid) FROM tmp_kgs_thq_recom_item_tmp;

-- 合并用户的推荐subroot为MAP类型
DROP TABLE tmp_kgs_thq_union_root;
CREATE TABLE tmp_kgs_thq_union_root AS
SELECT
uid,
STR_TO_MAP(CONCAT_WS("\073",COLLECT_SET(CONCAT_WS("\072",subroot_back,CAST(p_recom AS STRING)))),"\073","\072") AS union_root
FROM tmp_kgs_thq_recom_item_tmp
GROUP BY uid;

-- 连接用户的subroot和keywords
DROP TABLE tmp_kgs_thq_recom_final_agg;
CREATE TABLE tmp_kgs_thq_recom_final_agg AS
SELECT
t1.uid,
t1.union_root,
t2.keywords
FROM tmp_kgs_thq_union_root t1
LEFT JOIN tmp_kgs_thq_keywords_tid_num t2
ON t1.uid=t2.uid
WHERE t2.uid IS NOT NULL;

-- 89415687
SELECT count(distinct uid) FROM tmp_kgs_thq_recom_final_agg;
-- 63739763
SELECT count(distinct uid) FROM tmp_kgs_thq_user_class_info_tmp;
-- 原因:config_bef_keyword_log中只有41个union_root

DROP TABLE tmp_kgs_thq_user_class_info_tmp;
CREATE TABLE tmp_kgs_thq_user_class_info_tmp AS
SELECT 
t1.uid,
t1.subroot_name,
t1.weigth_value1,
t2.class_no,
sum(tid_num1*weight_adjust) AS class_score
FROM
    (SELECT 
    uid,
    subroot_name,
    cast(weigth_value AS float) AS weigth_value1,
    keyword,
    cast(tid_num AS bigint) AS tid_num1
    FROM tmp_kgs_thq_recom_final_agg 
    LATERAL VIEW OUTER EXPLODE(union_root) s0 AS subroot_name,weigth_value 
    LATERAL VIEW OUTER EXPLODE(keywords) s1 AS keyword,tid_num
    ) t1
JOIN
    (SELECT 
    union_root,
    class_no,
    keyword,
    weight/SUM(weight)OVER(PARTITION BY CONCAT_WS("|",union_root,class_no)) AS weight_adjust
    FROM config_bef_keyword_log
    ) t2 
ON t1.subroot_name=t2.union_root AND t1.keyword=t2.keyword
GROUP BY t1.uid,t1.subroot_name,t1.weigth_value1,t2.class_no;


DROP TABLE tmp_kgs_thq_user_category_score_tmp;
CREATE TABLE tmp_kgs_thq_user_category_score_tmp AS
SELECT 
t1.uid,
t1.subroot_name,
t1.root_weigth,
t2.field,
t2.class,
SUM(t2.score*t1.class_score_adjust) AS score
FROM
    (SELECT 
    uid,
    subroot_name,
    weigth_value1 AS root_weigth,
    class_no,
    class_score/SUM(class_score)OVER(PARTITION BY CONCAT_WS("|",uid,subroot_name)) AS class_score_adjust
    FROM tmp_kgs_thq_user_class_info_tmp
    ) t1
LEFT JOIN
    (SELECT 
    s1.union_root,
    s1.class_no,
    s2.field,
    s2.class,
    SUM(s2.parameter*s1.weight_adjust) AS score
    FROM
        (SELECT 
        union_root,
        class_no,
        keyword,
        weight/SUM(weight)OVER(PARTITION BY CONCAT_WS("&",union_root,class_no)) AS weight_adjust
        FROM config_back_keyword_log
        ) s1
   LEFT JOIN config_unionroot_to_category_log s2 
   ON s1.union_root=s2.union_root AND s1.keyword=s2.keyword
   WHERE s2.union_root IS NOT NULL AND s2.keyword IS NOT NULL
   GROUP BY s1.union_root,s1.class_no,s2.field,s2.class
   ) t2 
ON t1.subroot_name=t2.union_root AND t1.class_no=t2.class_no
WHERE t2.union_root IS NOT NULL AND t2.class_no IS NOT NULL
GROUP BY t1.uid,t1.subroot_name,t1.root_weigth,t2.field,t2.class 
HAVING SUM(t2.score*t1.class_score_adjust)>0;

DROP TABLE tmp_kgs_thq_user_category_info_agg;
CREATE TABLE tmp_kgs_thq_user_category_info_agg AS
SELECT 
uid,
union_root,
split(union_root,'&')[0] AS root,
split(union_root,'&')[1] AS subroot,
root_weigth,
collect_set(concat_ws('|',field,class,CAST(score_adjust*count_adjust AS STRING))) AS category_info
FROM
    (SELECT 
    uid,
    subroot_name AS union_root,
    root_weigth,
    field,
    class,
    score/SUM(score)OVER(PARTITION BY uid,subroot_name,field) AS score_adjust,
    COUNT(1)OVER(PARTITION BY uid,subroot_name,field) AS count_adjust
    FROM
        (SELECT uid,
        subroot_name,
        field,
        root_weigth,
        class,
        score,
        SUM(score)OVER(PARTITION BY uid,subroot_name,field ORDER BY score) AS score_c,
        SUM(score)OVER(PARTITION BY uid,subroot_name,field) AS score_t
        FROM tmp_kgs_thq_user_category_score_tmp
        ) t2
    WHERE score_c>score_t*0.3
    ) s1
GROUP BY uid,union_root,root_weigth;

-- 63727171
select count(distinct uid) from tmp_kgs_thq_user_category_info_agg;
         
DROP TABLE tmp_kgs_thq_user_group_join_tmp;
CREATE TABLE tmp_kgs_thq_user_group_join_tmp AS        
SELECT 
t1.uid,
t1.union_root,
t1.root_weigth AS root_weight,
t2.root_group,
t2.group_name,
t2.task,
count(1) AS con_num,
SUM(t1.score) AS t_score
FROM
    (SELECT 
    uid,
    union_root,
    root_weigth,
    split(category,'\\|')[0] AS item,
    split(category,'\\|')[1] AS value,
    CAST(split(category,'\\|')[2] AS FLOAT) AS score
    FROM tmp_kgs_thq_user_category_info_agg 
    LATERAL VIEW explode(category_info) mytable AS category
    ) t1
LEFT JOIN config_user_group_log t2 
ON t1.union_root=t2.union_root AND t1.item=t2.item AND t1.value=t2.value
WHERE t2.union_root IS NOT NULL AND t2.item IS NOT NULL AND t2.value IS NOT NULL
GROUP BY t1.uid,
         t1.union_root,
         t1.root_weigth,
         t2.root_group,
         t2.group_name,
         t2.task;

DROP TABLE tmp_kgs_thq_user_group_info_tmp;
CREATE TABLE tmp_kgs_thq_user_group_info_tmp AS  
SELECT 
uid,
union_root,
root_weight,
t_score,
group_name
FROM
    (SELECT 
    s1.uid,
    s1.union_root,
    s1.root_weight,
    s1.t_score,
    s1.root_group,
    s1.group_name,
    s1.task,
    ROW_NUMBER()OVER(PARTITION BY s1.uid,s1.union_root ORDER BY s1.t_score DESC) AS ranks
    FROM tmp_kgs_thq_user_group_join_tmp s1
    LEFT JOIN
        (SELECT 
        union_root,
        group_name,
        task,
        COUNT(1) AS con_num
        FROM config_user_group_log
        GROUP BY union_root,group_name,task
        ) s2 
    ON s1.union_root=s2.union_root AND s1.group_name=s2.group_name AND s1.task=s2.task
    WHERE s2.union_root IS NOT NULL AND s2.group_name IS NOT NULL AND s2.task IS NOT NULL
    AND s1.con_num=s2.con_num
    ) t1
WHERE t1.ranks=1;

DROP TABLE tmp_kgs_thq_user_group_name;
CREATE TABLE tmp_kgs_thq_user_group_name AS  
SELECT 
t1.uid,
t1.group_name
FROM 
    (SELECT 
    DISTINCT uid,
    group_name
    FROM tmp_kgs_thq_user_group_info_tmp
    ) t1
LEFT JOIN tmp_kgs_group_name_in_train_data t2
ON t1.group_name=t2.group_name
WHERE t2.group_name IS NOT NULL;

-- 训练数据中只出现了32个group_name,导致用户减少了一半
select count(1) from tmp_kgs_group_name_in_train_data;

-- 63331815
select  count(distinct uid) from tmp_kgs_thq_user_group_info_tmp;

-- 59137764	36017986
select 
count(1),
count(distinct uid) 
from tmp_kgs_thq_user_group_name;


