KB 10/04/06
Process Order for Bisac Code Update v2006:


1.  SQL files to load seed data from www.bisg.org  (http://www.bisg.org/standards/bisac_subject/changes.html)

	temp_sgt_bisaccodes_2006.sql   (load temporary table with all bisac codes and descriptions)
		- creates and loads table temp_sgt_bisaccodes_29
	temp_inactivecodes_2006.sql load table with inactive bisac codes
      - creates and loads table temp_inactivecodes_29_2
   temp_sgt_bisaccodes_2006_nocodes.sql load table with descriptions for those categories with no codes supplied
		- creates and loads table temp_sgt_bisaccodes_29_nocodes


2.  SQL file to update datadesc for existing datacodes:  

		updexisting_2006.sql
	
			 Compares the datadesc on existing rows between subgentable 339 and the category desc on the temporary 
     		 table temp_sgt_bisaccodes_29 and updates the datadesc on the subgentable from the one on the temporary
	  		 table if filled in, otherwise updates it from the subgentable row
   

3.  The following is a stored procedure to insert missing data into subgentable 339. This looks 
    for any rows on the appropriate temporary table that are missing on the subgentable and 
    inserts these rows into the subgentable.

	       insertmissing_sgt_2006.sql	  

4.  The following is a stored procedure to inserts rows into subgentable 339 from table temp_sgt_bisaccodes_29_nocodes
      (although these rows are marked as changes on the BISG website these descriptions did not exist on the 
       databases so per Brock inserted these rows into the subgentable)

          insertmissing_sgt_2006_nocodes.sql

5.   This is a SQL file to update datadesc on subgentable 339 to remove leading and trailing 
     spaces for '/' in the datadesc (added during the execution of the stored procedures): 
			
          code_upd_2006.sql


6.   setinactive_2006.sql - marks deletestatus to 'Y' for rows on subgentable from table temp_inactivecodes_29_2

		
7.   delete_sgt_2006.sql - deletes rows marked for deletion on the BISG web site - deletes based on datadesc as no
     bisac codes supplied - did not match any rows on GENMSQC/GENMSDEV