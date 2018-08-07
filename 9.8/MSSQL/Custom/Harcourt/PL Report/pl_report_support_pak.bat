call set_connection.bat
 

osql -U%userid% -P%password% -S%server% -d%database% -ifnc_rpt_qpl_calc_version_by_format.sql -oc:\qsilogs\functions\fnc_rpt_qpl_calc_version_by_format.txt
osql -U%userid% -P%password% -S%server% -d%database% -ifnc_rpt_taq_pl_advance_by_year.sql -oc:\qsilogs\functions\fnc_rpt_taq_pl_advance_by_year.txt
osql -U%userid% -P%password% -S%server% -d%database% -ifnc_rpt_taq_pl_get_client_value.sql -oc:\qsilogs\functions\fnc_rpt_taq_pl_get_client_value.txt
osql -U%userid% -P%password% -S%server% -d%database% -ifnc_rpt_taq_pl_get_unitcosts_rev.sql -oc:\qsilogs\functions\fnc_rpt_taq_pl_get_unitcosts_rev.txt
osql -U%userid% -P%password% -S%server% -d%database% -ifnc_rpt_taq_pl_priceby_formatyear.sql -oc:\qsilogs\functions\fnc_rpt_taq_pl_priceby_formatyear.txt
osql -U%userid% -P%password% -S%server% -d%database% -ifnc_rpt_taq_pl_royalty_by_year.sql -oc:\qsilogs\functions\func_rpt_taq_pl_royalty_by_year.txt
osql -U%userid% -P%password% -S%server% -d%database% -ivw_rpt_taq_pl_advance_by_year_view.sql -oc:\qsilogs\views\vw_rpt_taq_pl_advance_by_year_view.txt
osql -U%userid% -P%password% -S%server% -d%database% -ivw_rpt_taq_pl_discountpercent_bysaleschannel_format_view.sql -oc:\qsilogs\views\vw_rpt_taq_pl_discountpercent_bysaleschannel_format_view.txt
osql -U%userid% -P%password% -S%server% -d%database% -ivw_rpt_taq_pl_discountpercent_bysaleschannel_view.sql -oc:\qsilogs\views\vw_rpt_taq_pl_discountpercent_bysaleschannel_view.txt
osql -U%userid% -P%password% -S%server% -d%database% -ivw_rpt_taq_pl_priceby_formatyear_view.sql -oc:\qsilogs\views\vw_rpt_taq_pl_priceby_formatyear_view.txt
osql -U%userid% -P%password% -S%server% -d%database% -ivw_rpt_taq_pl_royalty_by_format_view.sql -oc:\qsilogs\views\vw_rpt_taq_pl_royalty_by_format_view.txt
osql -U%userid% -P%password% -S%server% -d%database% -ivw_rpt_taq_pl_stage_list_view.sql -oc:\qsilogs\views\vw_rpt_taq_pl_stage_list_view.txt
osql -U%userid% -P%password% -S%server% -d%database% -iprc_rpt_BUILD_rpt_taq_plsummaryitem_by_versionyear_with_version.sql -oc:\qsilogs\procedures\prc_rpt_BUILD_rpt_taq_plsummaryitem_by_versionyear_with_version.txt
osql -U%userid% -P%password% -S%server% -d%database% -iexec_prc_rpt_BUILD.sql -oc:\qsilogs\procedures\exec_prc_rpt_BUILD.txt