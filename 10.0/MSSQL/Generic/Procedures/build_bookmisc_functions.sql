if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[build_bookmisc_functions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[build_bookmisc_functions]
GO

CREATE procedure [dbo].[build_bookmisc_functions]
as
begin
declare @c_sqlstmt varchar (8000)
declare @c_sqlstmtdrop varchar (8000)
declare @c_sqlstmtgrant varchar (8000)
declare @i_cursor_status int 
declare @i_misckey int
declare @c_outputvar varchar(50)
declare @i_datacode int
declare @i_misctype int
declare @c_functionname varchar(8000)




DECLARE cursor_bookmiscitems INSENSITIVE CURSOR
FOR

Select i.misckey , misctype, i.datacode, 'get_'+'Tab_'+ REPLACE(RTRIM(LTRIM(t.tabname)), ' ', '_') + '_' + REPLACE(RTRIM(LTRIM(i.miscname)), ' ','_')
	from bookmisctabs t, bookmiscitems i, miscitemtab mt
	where t.tabkey = mt.tabkey
	  and mt.misckey = i.misckey
	  and i.activeind = 1
          and t.tabkey not in (1,2)
order by i.misckey
FOR READ ONLY

OPEN cursor_bookmiscitems

FETCH NEXT FROM cursor_bookmiscitems
INTO @i_misckey, @i_misctype,@i_datacode,@c_functionname

select @i_cursor_status = @@FETCH_STATUS
select @c_sqlstmt=''
while (@i_cursor_status<>-1 )
begin
	IF (@i_cursor_status<>-2)
	begin

	select @c_sqlstmtdrop = '
			if exists (select * from dbo.sysobjects where id = object_id(N''[dbo].[' + @c_functionname + ']'') and xtype in (N''FN'', N''IF'', N''TF''))
			drop function [dbo].[' + @c_functionname + ']' 

	select @c_outputvar =  CASE @i_misctype 
				WHEN 1 THEN ' INT '
			        WHEN 2 THEN ' FLOAT '
			        WHEN 3 THEN ' VARCHAR(255) '
			        WHEN 4 THEN ' INT '
			        WHEN 5 THEN ' VARCHAR(40) '
		     	       END



	select @c_sqlstmt = 'CREATE FUNCTION [dbo].[' + @c_functionname + '] (@i_bookkey INT) RETURNS ' + @c_outputvar

	select @c_sqlstmt = @c_sqlstmt +'
			     --This function was created dynamically by build_bookmisc_functions.  Any changes should be 
			     --saved under a different function name or they will be overwritten if the build_bookmisc_functions
			     -- procedure is run again. 
				'
  
	select @c_sqlstmt = @c_sqlstmt + ' BEGIN 
				 	   DECLARE @RETURN ' + @c_outputvar +
					 ' DECLARE @misc_value ' + @c_outputvar

				
	select @c_sqlstmt = @c_sqlstmt + '
					  SELECT @misc_value = '

	select @c_sqlstmt = @c_sqlstmt + CASE @i_misctype 
					     WHEN 1 THEN ' longvalue '
			                     WHEN 2 THEN ' floatvalue '
			                     WHEN 3 THEN ' textvalue '
			                     WHEN 4 THEN ' longvalue ' --checkbox (This misctype is not used)
			                     WHEN 5 THEN ' s.datadesc '
			    		  END

	select @c_sqlstmt = @c_sqlstmt + CASE 
					     WHEN @i_misctype IN (1,2,3,4) 
						THEN 'FROM   bookmisc
						      WHERE  bookkey = @i_bookkey and
		                           	             misckey = ' + CAST(@i_misckey as varchar)  
					     WHEN @i_misctype = 5 
					        THEN 'FROM bookmisc b, gentables g, subgentables s, bookmiscitems i
						      WHERE g.tableid = 525 and
						            g.tableid = s.tableid and
							    g.datacode = s.datacode and
							    g.datacode = i.datacode and
							    s.datasubcode = b.longvalue and
							    i.misctype = ' + CAST(@i_misctype as varchar) + ' and
							    b.misckey = ' + CAST(@i_misckey as varchar) + ' and	
							    i.misckey = ' + CAST(@i_misckey as varchar) + ' and	
							    b.bookkey =  @i_bookkey'
			    		 END
					 
					
					
							
	select @c_sqlstmt = @c_sqlstmt + '
					  IF @misc_value is not null
			                  BEGIN
			                      SELECT @RETURN = @misc_value
			                  END
 	 			 	  ELSE
			                  BEGIN
			                      SELECT @RETURN = ''''
			                  END
			
			                  RETURN @RETURN
			
			  	          END'

	Select @c_sqlstmtgrant = 'GRANT ALL ON [dbo].[' + @c_functionname + ']'  + ' to Public'

-- Uncomment print functions to see sql that will be executed
	
--	print @c_sqlstmtdrop
	EXECUTE (@c_sqlstmtdrop)
--	print @c_sqlstmt
	EXECUTE (@c_sqlstmt)
--      print @c_sqlstmtgrant
	EXECUTE (@c_sqlstmtgrant)
		
	end /*End If Status */

	FETCH NEXT FROM cursor_bookmiscitems
	INTO @i_misckey, @i_misctype,@i_datacode,@c_functionname

        select @i_cursor_status = @@FETCH_STATUS

end /* End While Cursor*/

close cursor_bookmiscitems
deallocate cursor_bookmiscitems

select @c_sqlstmt = ''

end


