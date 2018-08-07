if exists (select * from dbo.sysobjects where id = Object_id('dbo.webvirtcatout_sp') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.webvirtcatout_sp
end

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
CREATE  proc dbo.webvirtcatout_sp 
	@c_output_dir VARCHAR(256),
	@c_user VARCHAR(30),
	@c_password VARCHAR(30)
AS

DECLARE @i_categorycode int
DECLARE @c_externalcode varchar (100)
DECLARE @i_cats_cursor_status int
DECLARE @i_output_onix_book int
DECLARE @i_count int
DECLARE @cmd NVARCHAR(1000)

/*9-30-04 crm 01936:  add parameters output dir, user and password*/

/* Truncate the output table in preparation for new feed */
truncate table webcat

select @i_count = 0

select @i_count = count(*)
	from booksubjectcategory where categorytableid=414
if @i_count > 0 
  begin

/*Virtual CAtalogs -- files will be name subject externalcode.html*/

	DECLARE cursor_catalogs INSENSITIVE CURSOR
	  FOR
			select distinct categorycode,externalcode
			from booksubjectcategory b,gentables g 
		 		 where  categorytableid=414 and tableid=414 
					and categorycode=datacode
					order by externalcode
	  FOR READ ONLY

	  OPEN cursor_catalogs

		FETCH NEXT FROM cursor_catalogs
		   INTO @i_categorycode,@c_externalcode

			select @i_cats_cursor_status = @@FETCH_STATUS

			while (@i_cats_cursor_status<>-1 )
			   begin
				IF (@i_cats_cursor_status<>-2)
				   begin

begin tran
					exec @i_output_onix_book=webvirtcatdetail_sp @i_categorycode
commit tran

	
					set @cmd = 'bcp '
					set @cmd = @cmd + '"select fdtxt from PSS5..webcat order by sqn" queryout ' 
					set @cmd = @cmd + ' ' + @c_output_dir + upper(@c_externalcode) + '.HTML '  
					set @cmd = @cmd + ' -U' + @c_user + ' -P' + @c_password + ' '
					set @cmd = @cmd + ' -c -CACP'

					exec master..xp_cmdshell  @cmd


				end

				FETCH NEXT FROM cursor_catalogs
				  INTO @i_categorycode,@c_externalcode
       					 select @i_cats_cursor_status = @@FETCH_STATUS
			end					
  end

close cursor_catalogs
deallocate cursor_catalogs

return 0

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO