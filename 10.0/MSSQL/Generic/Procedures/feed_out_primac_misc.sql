SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[feed_out_primac_misc]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[feed_out_primac_misc]
GO


create proc dbo.feed_out_primac_misc 
 @feed_estkey int,
 @feed_versionkey int,
 @feed_compkey int,
 @feed_tableid int,
 @feed_miscdesc varchar(255) OUTPUT 
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/

DECLARE @i_misckey int
DECLARE @i_length int
DECLARE @feed_desc varchar(40)


DECLARE feed_estmiscspecs INSENSITIVE CURSOR
FOR

select datadesc 
	from estmiscspecs e, misctypetable m, gentables g
				where estkey = @feed_estkey
					   and versionkey = @feed_versionkey
						and compkey= @feed_compkey
						and e.datacode = g.datacode 
						and e.tableid = m.datacode    
         					and m.tablecode = g.tableid   
         					and e.misctypetableid = m.tableid 
						and e.misctypetableid = @feed_tableid

FOR READ ONLY
		
OPEN feed_estmiscspecs

FETCH NEXT FROM feed_estmiscspecs
INTO @feed_desc

select @i_misckey = @@FETCH_STATUS
select @feed_miscdesc = ''

while (@i_misckey<>-1 )  /* sttus 1*/
  begin
	IF (@i_misckey<>-2) /* status 2*/
	 begin
		if datalength(@feed_desc)> 0
		  begin
			select @feed_miscdesc = @feed_miscdesc + @feed_desc + ', '
		   end
	   end 
	FETCH NEXT FROM feed_estmiscspecs
	INTO @feed_desc

	select @i_misckey = @@FETCH_STATUS
 end
if datalength(@feed_miscdesc) > 0
  begin
	select @i_length= datalength( @feed_miscdesc) - 2
	select @feed_miscdesc= substring(@feed_miscdesc ,1,@i_length)
  end

close feed_estmiscspecs 
deallocate feed_estmiscspecs 

return 


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[feed_out_primac_misc]  TO [public]
GO

