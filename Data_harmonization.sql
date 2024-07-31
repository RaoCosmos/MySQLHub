SELECT * 
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
/*survey_no,
--coalesce(ad_have_allotment_of_alternate_site,'NA') ad_have_allotment_of_alternate_site,
--coalesce(ad_supreme_court_order_dated, 'NA') ad_supreme_court_order_dated,
--coalesce(ad_award_has_been_approved,'NA')ad_award_has_been_approved,
--coalesce(ad_award_has_been_approved_yes, 0)ad_award_has_been_approved_yes, -- 
--coalesce(ad_award_in_favour_of,-1)ad_award_in_favour_of,  --- -1 for null values
--coalesce(ad_is_govt_land_award_passed, 'NA')ad_is_govt_land_award_passed,
--coalesce(ad_govt_land_passed_value_yes,-1)ad_govt_land_passed_value_yes,  -- -1 for null values
--coalesce(ad_khatedar_notified_in_final_notification,'NA')ad_khatedar_notified_in_final_notification,
--coalesce(ad_khatedar_notified_in_final_notification_no,0)ad_khatedar_notified_in_final_notification_no,
--award_no, 
--village_id,*/
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

/*	coalesce(document_extension,'NA')document_extension,
document_name,
coalesce(bi_extend_land_per_rtc, 'NA')bi_extend_land_per_rtc,
CAST(split_part(left(bi_final_notification,4),'-',1) as INTEGER) bi_final_notification1, 
CAST(split_part(left(bi_final_notification,4),'-',2) as INTEGER) bi_final_notification2,
is_one_time_edit,
LEFT(replace(BI_RTC_KHARAB_AREA,'  ',''),1) bi_rtc_kharab_area1,
RIGHT(replace(BI_RTC_KHARAB_AREA,'  ',''),2)bi_rtc_kharab_area2,
bi_rtc_remaining_extent,
CAST(split_part(left(bi_rtc_remaining_extent,4),'-',1) as INTEGER) bi_rtc_remaining_extent1, 
CAST(split_part(left(bi_rtc_remaining_extent,4),'-',2) as INTEGER) bi_rtc_remaining_extent2,

CAST(split_part(left(bi_rtc_total_area,4),'-',1) as INTEGER) bi_rtc_total_area1, 
CAST(split_part(left(bi_rtc_total_area,4),'-',2) as INTEGER) bi_rtc_total_area2,

coalesce(sd_application_filled_before_jcc, 'NA')sd_application_filled_before_jcc,
coalesce(sd_is_award_compensation_for_structures, 'NA')sd_is_award_compensation_for_structures,
coalesce(sd_is_building_valuation_done,'NA')sd_is_building_valuation_done,
coalesce(sd_comment,'NA')sd_comment,
coalesce(sd_compensation_for_foot_print,'NA')sd_compensation_for_foot_print,
sd_entitlement_cert_issued,
sd_entitlement_cert_issued_yes,
coalesce(sd_hand_over_to_department, 'NA')sd_hand_over_to_department,
coalesce(sd_is_land_structure_exist,'NA')sd_is_land_structure_exist,
coalesce(sd_structure_has_been_taken,'NA')sd_structure_has_been_taken,
award_master_status_history_id,
award_approved_value_yes,
award_in_favour_of_value,
gov_land_award_passed_yes_value,
khatedar_notified_final_notification_value_no,
entitlement_certificate_issued_value_yes,
survey_master_id,
original_document_name,
coalesce(aa_award_passed_contravention,'NA')aa_award_passed_contravention,
coalesce(aa_award_passed_for_construction,'NA')aa_award_passed_for_construction,
coalesce(aa_award_passed_for_rtc,'NA')aa_award_passed_for_rtc,
coalesce(aa_award_passed_gomal,'NA')aa_award_passed_goma,
coalesce(aa_award_passed_govt_land,'NA')aa_award_passed_govt_land,
coalesce(aa_award_passed_in_application_not_submitted,'NA')aa_award_passed_in_application_not_submitted,
coalesce(aa_award_passed_in_application_submitted,'NA')aa_award_passed_in_application_submitted,
coalesce(aa_award_passed_in_favour_katheadar,'NA')aa_award_passed_in_favour_katheadar,
coalesce(aa_award_passed_kharab_land,'NA')aa_award_passed_kharab_land,
coalesce(aa_award_passed_revenue_act,'NA')aa_award_passed_revenue_act,
coalesce(aa_building_constructed_after,'NA')aa_building_constructed_after,
coalesce(aa_is_award_regular,'NA')aa_is_award_regular,
coalesce(aa_violation_of_laq,'NA')aa_violation_of_laq,
coalesce(aa_violation_of_supreme_court,'NA')aa_violation_of_supreme_court,
coalesce(ad_is_issued_to_land_owner,'NA')ad_is_issued_to_land_owner,
coalesce(ad_is_revenue_layout_formed,'NA')ad_is_revenue_layout_formed,
coalesce(sd_is_possession_hand_to_engg_dept,'NA')sd_is_possession_hand_to_engg_dept,
coalesce(ad_no_of_applications,'NA')ad_no_of_applications,
coalesce(sd_application_filled_yes,'NA')sd_application_filled_yes,
coalesce(sd_extent,'NA')sd_extent,
coalesce(sd_no_of_structure_award_sketch,'NA')sd_no_of_structure_award_sketch,
coalesce(sd_no_of_structure_mahazar,'NA')sd_no_of_structure_mahazar,
coalesce(sd_no_of_structure_discussed_in_award,'NA')sd_no_of_structure_discussed_in_award,
coalesce(sd_no_of_structure_yes,'NA')sd_no_of_structure_yes,
rtrim(coalesce(ad_compensation_amount),'/-')ad_compensation_amount,
coalesce(ad_extent_ratio,'NA')ad_extent_ratio,
coalesce(ad_is_converted,'NA')ad_is_converted,
status_code,
created_by */

FROM award_master
JOIN award_survey_master
 ON award_master.survey_master_id=award_survey_master.id
  JOIN award_master_status_history 
   ON award_master_status_history.history_id=award_master.award_master_status_history_id
    JOIN status_ref  
     ON status_ref.status_id= award_master_status_history.award_master_status_id
WHERE
(bi_rtc_kharab_area, bi_rtc_remaining_extent,
  bi_final_notification, bi_rtc_total_area) 
 IS NOT null 
  AND status_id=24
   ORDER BY 1 ASC;





