
GO

/****** Object:  StoredProcedure [dbo].[rpt_BUILD_rpt_taq_plsummaryitem_by_versionyear]    Script Date: 08/25/2015 14:09:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_BUILD_rpt_taq_plsummaryitem_by_versionyear]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[rpt_BUILD_rpt_taq_plsummaryitem_by_versionyear]
GO


GO

/****** Object:  StoredProcedure [dbo].[rpt_BUILD_rpt_taq_plsummaryitem_by_versionyear]    Script Date: 08/25/2015 14:09:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- exec rpt_BUILD_rpt_taq_plsummaryitem_by_versionyear 4

CREATE PROCEDURE [dbo].[rpt_BUILD_rpt_taq_plsummaryitem_by_versionyear] @i_summaryheadingcode int as

-- The purpose of this procedure is to dynamically create a table (stored proc output in this case) to be 
-- used in a crystal report.  This procedure dynamically creates another procedure that can be used in a 
-- Crystal report.  The only parameter needed is the summaryheading code.  Typically we will use a summary
-- heading explicitly designated for report development and manipulation.  Each time the summary items are 
-- reconfigured this process will need to be re-run.


DECLARE @v_sql varchar(max)
DECLARE @v_sql_grant varchar(max)
--drop table #tempindex 

Select distinct d.plsummaryitemkey, d.fieldformat, d.assocplsummaryitemkey as plsummaryitemkey_version, d.fieldformat as fieldformat_version
into #tempindex 
from plsummaryitemdefinition d 
	 --LEFT OUTER JOIN 
     --gentablesrelationshipdetail r on d.assocplsummaryitemkey = r.code1 
	 --LEFT OUTER JOIN 
	 --plsummaryitemdefinition d2 on r.code2 = d2.assocplsummaryitemkey
where d.summarylevelcode = 4
and d.activeind = 1

/*
Select distinct d.plsummaryitemkey, d.fieldformat, r.code2 as plsummaryitemkey_version, d2.fieldformat as fieldformat_version
into #tempindex 
from plsummaryitemdefinition d 
	 LEFT OUTER JOIN 
     gentablesrelationshipdetail r on d.plsummaryitemkey = r.code1 
	 LEFT OUTER JOIN 
	 plsummaryitemdefinition d2 on r.code2 = d2.plsummaryitemkey
where d.summarylevelcode = 4
and d.activeind = 1
--and d.plsummaryitemkey not in (100,103,111,129,133) -- missing procs
--and d.plsummaryitemkey not in (91,92,94,95,96,97,98,99,100,101)
*/

alter table #tempindex
add plsummaryitemdetailkey int identity(1,1)


Create table #tempyear(yearcode int)
Insert into #tempyear
Select 1 UNION Select 2 UNION Select 3 UNION Select 4 UNION Select 5

--drop table #tempprocitems

Select distinct
i.plsummaryitemkey,i.fieldformat,y.yearcode,i.plsummaryitemkey_version, i.fieldformat_version,
'@summaryitem_' + Cast(i.plsummaryitemkey as varchar) + '_year_' + CAST(y.yearcode as varchar) as itemvariable_name,
'DECLARE @summaryitem_' + Cast(i.plsummaryitemkey as varchar) + '_year_' + CAST(y.yearcode as varchar) + ' float ' as itemvariable_declaration,
' ' + REPLACE(REPLACE(c.calcsql,'@yearcode',y.yearcode ),'@result', '@summaryitem_' + Cast(i.plsummaryitemkey as varchar) + '_year_' + CAST(y.yearcode as varchar)) as itemvariable_assignment 
into #tempprocitems
from #tempindex i, #tempyear y, plsummaryitemcalc c
where i.plsummaryitemkey = c.plsummaryitemkey

alter table #tempprocitems
add itemvariable_assignment_version varchar(8000)

alter table #tempprocitems
add itemvariable_name_version varchar(8000)

update #tempprocitems
set itemvariable_name_version = '@summaryitem_' + Cast(plsummaryitemkey as varchar) + '_' + CAST(plsummaryitemkey_version as varchar) + '_version'
--from plsummaryitemcalc c, #tempindex i
--where c.plsummaryitemkey = #tempprocitems.plsummaryitemkey_version
--and i.plsummaryitemkey_version = c.plsummaryitemkey

--Select plsummaryitemkey, plsummaryitemkey_version, itemvariable_name_version,* from  #tempprocitems




update #tempprocitems
set itemvariable_assignment_version = REPLACE(c.calcsql, '@result',itemvariable_name_version)
from plsummaryitemcalc c
where c.plsummaryitemkey = #tempprocitems.plsummaryitemkey_version



alter table #tempprocitems
add itemvariable_declaration_version varchar(8000)

update #tempprocitems
set itemvariable_declaration_version = 'DECLARE  ' + itemvariable_name_version + ' float'


-- drop the procedure if it already exists
If exists(Select * from sysobjects where name = 'rpt_taq_plsummaryitem_by_versionyear' and xtype = 'P')
drop procedure rpt_taq_plsummaryitem_by_versionyear

Select 	@v_sql = '-- This prodecure is dynamically built by rpt_BUILD_rpt_taq_plsummaryitem_by_versionyear and any changes to ' + CHAR(10)
Select 	@v_sql = @v_sql + '--plsummmaryitems for report purposes will requre that this procedure be rebuilt'+ CHAR(10)


Select 	@v_sql = @v_sql + 'Create procedure [dbo].[rpt_taq_plsummaryitem_by_versionyear] (@i_reportinstancekey int, @stagekey int, @versionkey int) as
				 DECLARE @i_plsummaryitemkey int
				 DECLARE @plstagecode int
				 DECLARE @projectkey int
				 DECLARE @result int' + CHAR(10)

Select 	@v_sql = @v_sql + itemvariable_declaration + CHAR(10) from #tempprocitems

Select 	@v_sql = @v_sql + itemvariable_declaration_version + CHAR(10) from #tempprocitems
where itemvariable_declaration_version is not null
and yearcode = 1 -- year actually has nothign to do with version variables but since distinct does not work here, year code 1 gets all distinct version summary items

Select 	@v_sql = @v_sql + 'Select @projectkey = key1 from qsrpt_instance_item where instancekey = @i_reportinstancekey' + CHAR(10)
Select 	@v_sql = @v_sql + 'Select @plstagecode = @stagekey' + CHAR(10)

Select 	@v_sql = @v_sql + itemvariable_assignment + CHAR(10) from #tempprocitems

Select 	@v_sql = @v_sql + itemvariable_assignment_version + CHAR(10) from #tempprocitems
where itemvariable_assignment_version is not null
and yearcode = 1



Select 	@v_sql = @v_sql + 'Select @projectkey as taqprojectkey, ' 
						+ CAST(plsummaryitemkey as varchar) 
						+ ' as plsummaryitemkey, ' 
						+ itemvariable_name + CASE WHEN i.fieldformat like '%[%]%' THEN ' *100' ELSE '' END + ' as versionyear_' + cast(y1.yearcode as varchar) + ', '
						+ REPLACE(itemvariable_name, 'year_1', 'year_2') + CASE WHEN i.fieldformat like '%[%]%' THEN ' *100' ELSE '' END + ' as versionyear_' + cast(y2.yearcode as varchar) + ', '
						+ REPLACE(itemvariable_name, 'year_1', 'year_3') + CASE WHEN i.fieldformat like '%[%]%' THEN ' *100' ELSE '' END + ' as versionyear_' + cast(y3.yearcode as varchar) + ', '
						+ REPLACE(itemvariable_name, 'year_1', 'year_4') + CASE WHEN i.fieldformat like '%[%]%' THEN ' *100' ELSE '' END + ' as versionyear_' + cast(y4.yearcode as varchar) + ', '
						+ REPLACE(itemvariable_name, 'year_1', 'year_5') + CASE WHEN i.fieldformat like '%[%]%' THEN ' *100' ELSE '' END +' as versionyear_' + cast(y5.yearcode as varchar)  + ', '
						+ CASE WHEN itemvariable_name_version is not null THEN itemvariable_name_version + CASE WHEN i.fieldformat like '%[%]%' THEN ' *100' ELSE '' END Else '''''' END +  ' as version_total'  +
						CASE WHEN plsummaryitemkey not in (Select max(plsummaryitemkey) from #tempprocitems) THEN ' UNION' ELSE '' END + CHAR(10)
						from #tempprocitems i, #tempyear y1, #tempyear y2, #tempyear y3, #tempyear y4 ,#tempyear y5 
						where (i.yearcode = y1.yearcode 
						  or i.yearcode = y2.yearcode 
						  or  i.yearcode = y3.yearcode 
						  or  i.yearcode = y4.yearcode
						  or  i.yearcode = y5.yearcode)
						and y1.yearcode = 1 
						and y2.yearcode = 2
						and y3.yearcode = 3
						and y4.yearcode = 4
						and y5.yearcode = 5
						and i.yearcode = 1
				
							  									
/*
	print substring(@v_sql,1,8000)
	print substring(@v_sql,8001,16000)
	print substring(@v_sql,16001,24000)
	print substring(@v_sql,24001,32000)
	print substring(@v_sql,32001,40000)
	print substring(@v_sql,40001,48000)
	print substring(@v_sql,48001,56000)
	print substring(@v_sql,56001,64000)
	print substring(@v_sql,64001,72000)
*/

	exec sp_sqlexec @v_sql

Select 	@v_sql_grant = 'GRANT ALL ON [dbo].[rpt_taq_plsummaryitem_by_versionyear] to PUBLIC'

exec sp_sqlexec @v_sql_grant


--Select 'Select @i_taqprojectkey as taqprojectkey, ' 
--+ CAST(plsummaryitemkey as varchar) 
--+ ' as plsummaryitemkey, ' 
--+ itemvariable_name + ' as versionyear_' 
--+ cast(y.yearcode as varchar) 
--+ CASE 
--  WHEN y.yearcode = 4 and plsummaryitemkey in (Select max(plsummaryitemkey) from #tempprocitems) THEN '' 
--  WHEN y.yearcode = 4 THEN ' UNION' 
--  else ',' END
--from #tempprocitems i, #tempyear y
--where i.yearcode = y.yearcode





GO


