USE [BT_SD_ECF]
GO
/****** Object:  UserDefinedFunction [dbo].[qweb_ecf_get_product_metakeywords]    Script Date: 01/27/2010 16:30:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER function [dbo].[qweb_ecf_get_product_metakeywords] (@i_workkey int) 

RETURNS varchar(512)

as

BEGIN

DECLARE @v_metakeywords varchar(512),
		@i_bookkey int,
		@i_titlefetchstatus int

	Select @v_metakeywords = BT.dbo.qweb_get_Title(@i_workkey,'F') + ', '

	DECLARE c_pss_titles CURSOR
	FOR

	Select b.bookkey
	from BT..book b
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

		Select @v_metakeywords = ISNULL(@v_metakeywords,'') +
		BT.dbo.qweb_get_Isbn(@i_bookkey,10) + ', ' +
		BT.dbo.qweb_get_Isbn(@i_bookkey,13) + ', ' +
		BT.dbo.qweb_get_Isbn(@i_bookkey,16) + ', ' +
		BT.dbo.qweb_get_Isbn(@i_bookkey,17) + ', ' 

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



