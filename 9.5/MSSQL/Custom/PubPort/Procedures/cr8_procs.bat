call set_connection.bat

osql -U%userid% -P%password% -S%server% -d%database% -n -iqweb_config_websites.sql >cr8_procs.log
osql -U%userid% -P%password% -S%server% -d%database% -n -iqweb_get_obj_children.sql >>cr8_procs.log
osql -U%userid% -P%password% -S%server% -d%database% -n -iqweb_set_left_xml.sql >>cr8_procs.log
osql -U%userid% -P%password% -S%server% -d%database% -n -iqweb_get_data_element.sql >>cr8_procs.log
osql -U%userid% -P%password% -S%server% -d%database% -n -iqweb_titlesearch.sql >>cr8_procs.log
osql -U%userid% -P%password% -S%server% -d%database% -n -iqweb_get_title_detail.sql >>cr8_procs.log
osql -U%userid% -P%password% -S%server% -d%database% -n -iqweb_wh_load.sql >>cr8_procs.log

