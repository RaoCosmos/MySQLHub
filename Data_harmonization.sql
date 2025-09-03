/* 
	Author:Sohan Rao
    Purpose: Data Cleaning, Column Cleaning & Data Harmonization
*/

SELECT * 
FROM award_master 
JOIN award_survey_master 
	ON award_master.survey_master_id=award_survey_master.id
      JOIN award_master_status_history 
	     ON award_master_status_history.history_id=award_master.award_master_status_history_id
          JOIN status_ref 
	          ON status_ref.status_id= award_master_status_history.award_master_status_id 
WHERE
	(bi_rtc_kharab_area, 
 		bi_rtc_remaining_extent,
 			bi_final_notification,
 				bi_rtc_total_area) IS NOT NULL AND status_id=24
ORDER BY 1 ASC;

-- Column Cleaning 
---bi_final_notification - has 1/2 -
SELECT  award_master.ID,
CAST(split_part(left(bi_final_notification,4),'-',1) as INTEGER) bi_final_notification1, 
CAST(split_part(left(bi_final_notification,4),'-',2) as INTEGER) bi_final_notification2
FROM award_master 
JOIN award_survey_master ON award_master.survey_master_id=award_survey_master.id
JOIN award_master_status_history ON award_master_status_history.history_id=award_master.award_master_status_history_id
JOIN status_ref ON status_ref.status_id= award_master_status_history.award_master_status_id
WHERE
(bi_rtc_kharab_area, 
 	bi_rtc_remaining_extent,
 		bi_final_notification,
 			bi_rtc_total_area) is not null and status_id=24
ORDER BY id ASC;
	
--- bi-rtc-kharab_area ----------------
UPDATE award_master SET bi_rtc_kharab_area=regexp_replace(bi_rtc_kharab_area,'[^\w]+','');
	
SELECT ID, BI_RTC_KHARAB_AREA FROM AWARD_MASTER;
	
SELECT award_master.ID,
LEFT(replace(BI_RTC_KHARAB_AREA,'  ',''),1),
RIGHT(replace(BI_RTC_KHARAB_AREA,'  ',''),2) 
FROM AWARD_MASTER 
JOIN award_survey_master ON award_master.survey_master_id=award_survey_master.id
JOIN award_master_status_history ON award_master_status_history.history_id=award_master.award_master_status_history_id
JOIN status_ref ON status_ref.status_id= award_master_status_history.award_master_status_id
WHERE
(bi_rtc_kharab_area, 
 	bi_rtc_remaining_extent,
 		bi_final_notification,
 			bi_rtc_total_area) is not null and status_id=24
ORDER BY id ASC;
	
-- bi_rtc_remaining_extent has 1/2 ----
select id, bi_rtc_remaining_extent from award_master order by id asc;

SELECT award_master.ID,
SPLIT_PART(bi_rtc_remaining_extent, '-', 1),
SPLIT_PART(bi_rtc_remaining_extent, '-', 2),
SPLIT_PART(bi_rtc_remaining_extent, '--', 2)
FROM AWARD_MASTER 
JOIN award_survey_master ON award_master.survey_master_id=award_survey_master.id
JOIN award_master_status_history ON award_master_status_history.history_id=award_master.award_master_status_history_id
JOIN status_ref ON status_ref.status_id= award_master_status_history.award_master_status_id
WHERE
(bi_rtc_kharab_area, 
 	bi_rtc_remaining_extent,
 		bi_final_notification,
 			bi_rtc_total_area) is not null and status_id=24
ORDER BY 1 ASC;

-- bi_rtc_total_area - had 1/2 -------
SELECT ID, BI_RTC_TOTAL_AREA FROM AWARD_MASTER ORDER BY 1 ASC;
	
SELECT award_master.ID,
CAST(split_part(left(bi_rtc_total_area,4),'-',1) AS INTEGER) totacre1,
CAST(split_part(left(bi_rtc_total_area,4),'-',2) AS INTEGER) totacre2
FROM award_master 
JOIN award_survey_master ON award_master.survey_master_id=award_survey_master.id
JOIN award_master_status_history ON award_master_status_history.history_id=award_master.award_master_status_history_id
JOIN status_ref ON status_ref.status_id= award_master_status_history.award_master_status_id
WHERE
(bi_rtc_kharab_area, 
 	bi_rtc_remaining_extent,
 		bi_final_notification,
 			bi_rtc_total_area) is not null and status_id=24
ORDER BY 1 ASC;

-----------------------------------------------------------------------------------
SELECT 

	award_master.id,
	award_skl_no,	

bi_rtc_total_area,	
CAST(split_part(left(bi_rtc_total_area,4),'-',1) as INTEGER) bi_extent_land_rtc_total_area_acre, 
CAST(split_part(left(bi_rtc_total_area,4),'-',2) as INTEGER) bi_extent_land_rtc_total_area_gunta,

bi_rtc_kharab_area,
LEFT(replace(BI_RTC_KHARAB_AREA,'  ',''),1) bi_extent_land_rtc_kharab_area_acre,
RIGHT(replace(BI_RTC_KHARAB_AREA,'  ',''),2)bi_extent_land_rtc_kharab_area_gunta,

bi_rtc_remaining_extent,
SPLIT_PART(bi_rtc_remaining_extent,'-', 1) bi_extent_land_rtc_remaining_acre,
SUBSTRING(SPLIT_PART(bi_rtc_remaining_extent,'-', 2), 1,2) bi_extent_land_rtc_remaining_gunta, 

bi_final_notification,
CAST(split_part(left(bi_final_notification,4),'-',1) as INTEGER) bi_extent_notification_acre, 
CAST(split_part(left(bi_final_notification,4),'-',2) as INTEGER) bi_extent_notification_gunta,

coalesce(bi_column_ext_difference,'NA')bi_column_ext_difference,
split_part(bi_column_ext_difference,'-',1) bi_extent_difference_acre,
substring(split_part(bi_column_ext_difference,'-',2),1,2) bi_extent_difference_gunta,
coalesce(sd_comment,'NA') bi_comments,

rtrim(coalesce(ad_compensation_amount),'/- For Revenue Site owners')ad_compensation_amount,
coalesce(sd_extent,'NA')sd_extent

FROM award_master
    JOIN award_survey_master
 	   ON award_master.survey_master_id=award_survey_master.id
  	     JOIN award_master_status_history 
             ON award_master_status_history.history_id=award_master.award_master_status_history_id
               JOIN status_ref  
                  ON status_ref.status_id= award_master_status_history.award_master_status_id
WHERE (bi_rtc_kharab_area, bi_rtc_remaining_extent, bi_final_notification, bi_rtc_total_area) 
IS NOT null AND status_id=24
ORDER BY 1 ASC;





