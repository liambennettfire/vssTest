if exists (select * from dbo.sysobjects where id = Object_id('dbo.htmllite_to_custom_html_new') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.htmllite_to_custom_html_new 
end
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Desc: This stored procedure will refresh custom html lite for passed type
**        and update bookcomment_ext or qsicomment_ext.
**        Full refresh ('Y') or incremental.
**        page.      
**
**    Auth: Anes Hrenovica
**    Date: 10/6/2006
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

CREATE      PROCEDURE dbo.htmllite_to_custom_html_new
		     @o_full_refresh_ind char(1),
		     @i_commentstyle int,
		     @i_table_name varchar(100),
		     @o_error_code     int 		output,
		     @o_error_desc     varchar(2000) 

AS

BEGIN 
DECLARE 
@blob_pointer varbinary (16),
@v_printingkey int,
@v_commenttypecode int,
@v_commenttypesubcode int,
@v_commentkey int,
@v_dynamic_cur varchar(4000),
@v_where  varchar(2000),
@v_last_run datetime,
@v_commentstyle tinyint, 
@v_openingtag varchar(50), 
@v_closingtag varchar(50),
@v_replacewith varchar(50),
@v_remain int,
@v_invalid int,
@i_update_table_name VARCHAR(100)


IF @o_full_refresh_ind = 'Y' begin
   set @v_where = ''
end else begin
	IF Upper(@i_table_name) = 'BOOKCOMMENTS_EXT' BEGIN
 		select @v_last_run = max(lastmaintdate) from bookcomments_ext
	end
	IF Upper(@i_table_name) = 'QSICOMMENTS_EXT' BEGIN
		select @v_last_run = max(lastmaintdate) from qsicomments_ext
	end
	if @v_last_run is null  begin
		set @v_where = ''
	end else begin
		set @v_where = ' where lastmaintdate between ''' + cast(@v_last_run as varchar(50)) + ''' and getdate()'
	end
END

IF Upper(@i_table_name) = 'BOOKCOMMENTS_EXT' BEGIN
	set @v_dynamic_cur = '
	DECLARE cr_comments CURSOR FOR
	select 	bookkey, printingkey, commenttypecode, commenttypesubcode
	from bookcomments ' + @v_where
END
IF Upper(@i_table_name) = 'QSICOMMENTS_EXT' BEGIN
	SET @v_dynamic_cur = '
	DECLARE cr_comments CURSOR FOR
	select commentkey, 0, commenttypecode, commenttypesubcode 
	from qsicomments ' + @v_where 
END

EXEC (@v_dynamic_cur)


--delete orphan rows from extension table
exec delete_orphan_html_ext @i_table_name


OPEN cr_comments 
FETCH NEXT FROM cr_comments INTO @v_commentkey, @v_printingkey, @v_commenttypecode, @v_commenttypesubcode
   WHILE (@@FETCH_STATUS <> -1)
    BEGIN
     if  upper(@i_table_name) = 'BOOKCOMMENTS_EXT' begin
	delete from bookcomments_ext
	where bookkey  = @v_commentkey and   printingkey  = @v_printingkey and   commenttypecode  = @v_commenttypecode and   commenttypesubcode  = @v_commenttypesubcode and   commentstyle  = @i_commentstyle
	insert into bookcomments_ext(commentbody, bookkey, printingkey, commenttypecode, commenttypesubcode, commentstyle, lastuserid, lastmaintdate)
	select commenthtml, @v_commentkey, @v_printingkey, @v_commenttypecode, @v_commenttypesubcode, @i_commentstyle,  'QSIDBA',  getdate()
	from bookcomments where bookkey = @v_commentkey and printingkey = @v_printingkey and commenttypecode = @v_commenttypecode and commenttypesubcode = @v_commenttypesubcode

	select @blob_pointer = textptr(commentbody) from bookcomments_ext
	where bookkey  = @v_commentkey and printingkey = @v_printingkey and commenttypecode = @v_commenttypecode and commenttypesubcode = @v_commenttypesubcode and commentstyle = @i_commentstyle
     end
     if  upper(@i_table_name) = 'QSICOMMENTS_EXT' begin
	delete from qsicomments_ext
	where commentkey  = @v_commentkey and commenttypecode = @v_commenttypecode and commenttypesubcode  = @v_commenttypesubcode and commentstyle  = @i_commentstyle
	insert into qsicomments_ext(commentbody, commentkey, commenttypecode, commenttypesubcode, commentstyle, lastuserid, lastmaintdate)
	select commenthtml, @v_commentkey, @v_commenttypecode, @v_commenttypesubcode, @i_commentstyle,  'QSIDBA',  getdate()
	from qsicomments where commentkey = @v_commentkey and commenttypecode = @v_commenttypecode and commenttypesubcode = @v_commenttypesubcode

	select @blob_pointer = textptr(commentbody) from qsicomments_ext
	where commentkey  = @v_commentkey and commenttypecode = @v_commenttypecode and commenttypesubcode = @v_commenttypesubcode and commentstyle  = @i_commentstyle
     end
     
    IF upper(@i_table_name) = 'BOOKCOMMENTS_EXT'
	BEGIN
		UPDATE bookcomments_ext
		SET commentbody = dbo.udf_StripSelectedHTMLTags(commentbody, 1)
		WHERE bookkey = @v_commentkey
			AND printingkey = @v_printingkey
			AND commenttypecode = @v_commenttypecode
			AND commenttypesubcode = @v_commenttypesubcode
			
		UPDATE bookcomments_ext
		SET commentbody = dbo.udf_StripDIVHTMLTags(commentbody)
		WHERE bookkey = @v_commentkey
			AND printingkey = @v_printingkey
			AND commenttypecode = @v_commenttypecode
			AND commenttypesubcode = @v_commenttypesubcode
	END
	
	IF upper(@i_table_name) = 'QSICOMMENTS_EXT'
	BEGIN
		UPDATE qsicomments_ext
		SET commentbody = dbo.udf_StripSelectedHTMLTags(commentbody, 1)
		WHERE commentkey = @v_commentkey
			AND commenttypecode = @v_commenttypecode
			AND commenttypesubcode = @v_commenttypesubcode
			
		UPDATE qsicomments_ext
		SET commentbody = dbo.udf_StripDIVHTMLTags(commentbody)
		WHERE commentkey = @v_commentkey
			AND commenttypecode = @v_commenttypecode
			AND commenttypesubcode = @v_commenttypesubcode
	END

--DECLARE html_cur CURSOR FOR 
--    select commentstyle, openingtag, closingtag, replacewith, remain 
--    from htmllitetags
--    where commentstyle = @i_commentstyle
--    order by sortorder
--FOR READ ONLY

--	--FLAG HTML TAGS TO REMAIN 
--	OPEN html_cur 
--	FETCH NEXT FROM html_cur INTO @v_commentstyle, @v_openingtag, @v_closingtag, @v_replacewith, @v_remain
--	  WHILE (@@FETCH_STATUS <> -1) BEGIN
--		exec  html_to_lite_from_row_process   @v_commentkey, @v_printingkey, @v_commenttypecode, @v_commenttypesubcode, @i_table_name, @v_openingtag, @v_replacewith, @v_closingtag, @blob_pointer, 0, @v_remain, @i_commentstyle,  @v_invalid output
--		if @v_invalid = 1 goto the_end
--	  FETCH NEXT FROM html_cur INTO @v_commentstyle, @v_openingtag, @v_closingtag, @v_replacewith, @v_remain
	
--	  END 
	
--	--REMOVE THE REST OF HTML TAGS THAT WE DON'T NEED TO KEEP
--	if @v_invalid = 0 begin
--	   exec  html_to_lite_from_row_process   @v_commentkey, @v_printingkey, @v_commenttypecode, @v_commenttypesubcode, @i_table_name,'<', '', '>', @blob_pointer, 0, 0, @i_commentstyle,  @v_invalid output
--	   if @v_invalid = 1 goto the_end
--	end
--	--PUT BACK THML TAGS THAT ARE FLAGED ABOVE
--	if @v_invalid = 0 begin
--	   exec  html_to_lite_from_row_process   @v_commentkey, @v_printingkey, @v_commenttypecode, @v_commenttypesubcode, @i_table_name, '&&L', '<', 'L', @blob_pointer, 1, 0, @i_commentstyle,  @v_invalid output
-- 	   if @v_invalid = 1 goto the_end 
--        end
--	if @v_invalid = 0 begin
--	   exec  html_to_lite_from_row_process   @v_commentkey, @v_printingkey, @v_commenttypecode, @v_commenttypesubcode, @i_table_name, '&&R', '>', 'R', @blob_pointer, 1, 0, @i_commentstyle,  @v_invalid output
--	   if @v_invalid = 1 goto the_end 
--        end
--	the_end:
--	close html_cur
--        deallocate html_cur		
--	--REPLACE SPECIAL CHARACTHERS
--	if @v_invalid = 0 begin
--	   exec html_to_lite_from_row_spec_char  @v_commentkey, @v_printingkey, @v_commenttypecode, @v_commenttypesubcode, @i_table_name, @blob_pointer, @i_commentstyle
--	end
FETCH NEXT FROM cr_comments INTO @v_commentkey, @v_printingkey, @v_commenttypecode, @v_commenttypesubcode
END
close cr_comments
deallocate cr_comments
END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXEC ON dbo.htmllite_to_custom_html_new TO PUBLIC
GO



