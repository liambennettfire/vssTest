GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_import]    Script Date: 05/08/2009 11:04:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DECLARE @sql varchar(8000),
		@i_bookkey int,
		@i_mediatypecode int,
		@i_mediatypesubcode int,
		@i_titlefetchstatus int,
		@v_importtype varchar(10)

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecfbookkeys]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
create table [dbo].[qweb_ecfbookkeys] (bookkey int, mediatypecode int, mediatypesubcode int)
else truncate table [dbo].[qweb_ecfbookkeys]

select @v_importtype = 'F'

If @v_importtype = 'F' --Full Import
	begin
	Select @sql = 
	'Insert into qweb_ecfbookkeys (bd.bookkey, bd.mediatypecode, bd.mediatypesubcode, sortorder)
	Select bd.bookkey, mediatypecode, mediatypesubcode, 1 
	from APH..bookdetail bd, APH..book b 
	where bd.bookkey = b.bookkey and b.workkey = b.bookkey'
	
	--print @sql
	exec sp_sqlexec @sql

	Select @sql = 
	'Insert into qweb_ecfbookkeys (bd.bookkey, bd.mediatypecode, bd.mediatypesubcode, sortorder)
	Select bd.bookkey, mediatypecode, mediatypesubcode, 0
	from APH..bookdetail bd, APH..book b 
	where bd.bookkey = b.bookkey and b.workkey <> b.bookkey'

	--print @sql
	exec sp_sqlexec @sql

	end

	DECLARE c_qweb_titles INSENSITIVE CURSOR
	FOR

	Select bookkey, mediatypecode, mediatypesubcode
	from qweb_ecfbookkeys
	order by sortorder desc

	FOR READ ONLY
			
	OPEN c_qweb_titles 

	FETCH NEXT FROM c_qweb_titles 
		INTO @i_bookkey, @i_mediatypecode, @i_mediatypesubcode

	select  @i_titlefetchstatus  = @@FETCH_STATUS

	 while (@i_titlefetchstatus >-1 )
		begin
		IF (@i_titlefetchstatus <>-2) 
		begin

		exec qweb_ecf_Categorization_Insert_UNP_Category @i_bookkey
			print 'qweb_ecf_Categorization_Insert_UNP_Category COMPLETE - BookKey:' print @i_bookkey

		end

	FETCH NEXT FROM c_qweb_titles
		INTO @i_bookkey, @i_mediatypecode, @i_mediatypesubcode
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
		end

close c_qweb_titles
deallocate c_qweb_titles


