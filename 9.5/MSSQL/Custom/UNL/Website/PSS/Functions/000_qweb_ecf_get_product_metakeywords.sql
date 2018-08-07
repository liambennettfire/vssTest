if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qweb_ecf_get_product_metakeywords') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qweb_ecf_get_product_metakeywords
GO


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go
create function qweb_ecf_get_product_metakeywords (@i_workkey int) 

RETURNS varchar(512)

as

BEGIN

DECLARE @v_metakeywords varchar(512),
		@i_bookkey int,
		@i_titlefetchstatus int,
		@v_authorbylineprepro varchar (8000),
		@v_unformatted_metakeywords varchar(512)

	Select @v_metakeywords = UNL.dbo.qweb_get_Title(@i_workkey,'F')
	select @v_unformatted_metakeywords = UNL.dbo.replace_xchars (@v_metakeywords) 
	
	DECLARE c_pss_titles CURSOR
	FOR

	Select b.bookkey
	from UNL..book b
	where b.workkey = @i_workkey
	
	FOR READ ONLY
			
	OPEN c_pss_titles
	
	FETCH NEXT FROM c_pss_titles
		INTO @i_bookkey

	select  @i_titlefetchstatus  = @@FETCH_STATUS

	 while (@i_titlefetchstatus >-1 )
		begin
		IF (@i_titlefetchstatus <>-2) 
		begin

		Select @v_authorbylineprepro = commenttext from UNL..bookcomments where commenttypecode = 3 
		and commenttypesubcode = 73 and bookkey = @i_bookkey

		Select @v_metakeywords = ISNULL(@v_metakeywords,'') + ', '+
		@v_unformatted_metakeywords + ', ' +
		UNL.dbo.qweb_get_Isbn(@i_bookkey,10) + ', ' +
		UNL.dbo.qweb_get_Isbn(@i_bookkey,13) + ', ' +
		UNL.dbo.qweb_get_Isbn(@i_bookkey,16) + ', ' +
		UNL.dbo.qweb_get_Isbn(@i_bookkey,17) + ', ' +
		ISNULL (@v_authorbylineprepro,'') + ', ' + 
		UNL.dbo.qweb_get_series(@i_bookkey,'1')

		end


	FETCH NEXT FROM c_pss_titles
		INTO @i_bookkey
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
		end

close c_pss_titles
deallocate c_pss_titles

Select @v_metakeywords = SUBSTRING(@v_metakeywords,1,len(@v_metakeywords)-1)

RETURN @v_metakeywords

END

