KB 11/19/03
Process Order for Bisac Code Update v2.7:


1.  SQL files to load seed data
	These files were created by importing the excel worksheet provided by PGW using Enterprise
	Manager into a temporary table, opening up the table in Powerbuilder and using the save rows
	as feature to save to a sql file. This sql file was then edited to create the two sql files below:

	temp_gt_bisaccodes_2.7.sql    (load temporary table with all bisac categories and prefixes)
		- creates and loads table temp_gt_bisaccodes
	temp_sgt_bisaccodes_2.7.sql   (load temporary table with all bisac codes and descriptions)
		- creates and loads table temp_sgt_bisaccodes
	temp_inactivecodes_2.7.sql

2.  SQL file to update datadesc for existing datacodes:  updexisting.sql
	A)Compares the datadesc on existing rows between gentable 339 and the category desc on the temporary 
          table temp_gt_bisaccodes and updates the datadesc on the gentable from the one on the temporary
	  table if filled in, otherwise updates it from the gentable row

	B)Compares the datadesc on existing rows between subgentable 339 and the category desc on the temporary 
          table temp_sgt_bisaccodes and updates the datadesc on the subgentable from the one on the temporary
	  table if filled in, otherwise updates it from the subgentable row


3.  The following are stored procedures to insert missing data into gentable and subgentable 339. This looks 
      for any rows on the appropriate temporary table that are missing on the corresponding gentable/
	 subgentable and inserts these rows into the gentable/subgentable.

	  insertmissing_gt.sql    (gentable)
          insertmissing_sgt.sql	  (subgentable)

4.   This is a SQL file to update datadesc on subgentable 339 to remove leading and trailing 
     spaces for '/' in the datadesc (added during the execution of the stored procedures): code_upd.sql


5.  setinactive_sql

		
