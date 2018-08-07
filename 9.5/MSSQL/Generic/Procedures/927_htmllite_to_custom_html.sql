if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[htmllite_to_custom_html]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[htmllite_to_custom_html]
GO

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
**    Date: 7/6/2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

CREATE    PROCEDURE dbo.htmllite_to_custom_html
		     @o_full_refresh_ind char(1),
		     @i_html_type int,
		     @i_table_name varchar(100),
		     @o_error_code     int 		output,
		     @o_error_desc     varchar(2000) output

AS

BEGIN 
DECLARE 
@v_sec_adjust int,
@v_sec_point int,
@v_length_org int,
@v_complete int,
@relative_pos_start int,
@insert_offset int,
@loop int,
@blob_pointer varbinary (16),
@pos_start int,
@pos_end   int,
@v_trim varchar(8000),
@blob_portion varchar(8000),
@substr_blob varchar(8000), 
@v_printingkey int,
@v_commenttypecode int,
@v_commenttypesubcode int,
@div_start int,
@div_end int,
@cnt int,
@v_sec_length int,
@v_commentkey int,
@v_dynamic_cur varchar(4000),
@v_where  varchar(2000),
@v_last_run datetime,
@v_infinity int,
@v_error_ind int,
@v_ext_table varchar(30)

IF @o_full_refresh_ind = 'Y' begin
 	set @v_where = ''
end else begin
	IF Upper(@i_table_name) = 'BOOKCOMMENTS' BEGIN
		set @v_ext_table = 'BOOKCOMMENTS_EXT'
 		select @v_last_run = max(lastmaintdate) from bookcomments_ext
	end else begin
		set @v_ext_table = 'QSICOMMENTS_EXT'
		select @v_last_run = max(lastmaintdate) from qsicomments_ext
	end
	if @v_last_run is null  begin
		set @v_where = ''
	end else begin
		set @v_where = ' and lastmaintdate between ''' + cast(@v_last_run as varchar(50)) + ''' and getdate()'
	end
END

IF Upper(@i_table_name) = 'BOOKCOMMENTS' BEGIN
	set @v_dynamic_cur = '
	DECLARE cr_comments CURSOR FOR
	select 	bookkey, printingkey, commenttypecode, commenttypesubcode
	from bookcomments 
	where (invalidhtmlind = 0 or (invalidhtmlind is null and commenthtmllite is not null)) ' + @v_where
END ELSE BEGIN
	SET @v_dynamic_cur = '
	DECLARE cr_comments CURSOR FOR
	select commentkey, 0, commenttypecode, commenttypesubcode 
	from qsicomments 
	where (invalidhtmlind = 0 or (invalidhtmlind is null and commenthtmllite is not null)) ' + @v_where
END

EXEC (@v_dynamic_cur)



--delete orphan rows from extension table
exec delete_orphan_html_ext @v_ext_table


OPEN cr_comments 
FETCH NEXT FROM cr_comments INTO @v_commentkey, @v_printingkey, @v_commenttypecode, @v_commenttypesubcode

   WHILE (@@FETCH_STATUS <> -1)
    BEGIN
    --Init variables
    set @loop = 0
    set @insert_offset = 0
    set @v_complete = 0
    set @v_sec_length = 7000
    set @v_sec_point = 0

     --BOOKCOMMENTS - check if there is existing ro in extension table, set blob to empty, get set the pointer
     if  upper(@i_table_name) = 'BOOKCOMMENTS'  
     begin
	select @cnt = count(*)
	from bookcomments_ext
	where bookkey  = @v_commentkey
	and   printingkey  = @v_printingkey 
	and   commenttypecode  = @v_commenttypecode
	and   commenttypesubcode  = @v_commenttypesubcode
	and   commentstyle  = @i_html_type	

	if @cnt = 0 begin
	insert into bookcomments_ext(bookkey, printingkey, commenttypecode, commenttypesubcode, commentstyle, lastuserid, lastmaintdate)
	values (@v_commentkey, @v_printingkey, @v_commenttypecode, @v_commenttypesubcode, @i_html_type,  'QSIDBA',  getdate())
	end 

	update bookcomments_ext
	set commentbody = ''
	where bookkey  = @v_commentkey
	and   printingkey  = @v_printingkey 
	and   commenttypecode  = @v_commenttypecode
	and   commenttypesubcode  = @v_commenttypesubcode
	and   commentstyle  = @i_html_type

	select @blob_pointer = textptr(commentbody)
	from bookcomments_ext
	where bookkey  = @v_commentkey
	and   printingkey  = @v_printingkey 
	and   commenttypecode  = @v_commenttypecode
	and   commenttypesubcode  = @v_commenttypesubcode
	and   commentstyle  = @i_html_type

    	select @blob_portion =  SUBSTRING(commenthtmllite, 1, @v_sec_length)  
        from bookcomments
	where bookkey = @v_commentkey 
	and printingkey = @v_printingkey 
	and commenttypecode = @v_commenttypecode 
	and commenttypesubcode = @v_commenttypesubcode
     end

     --QSICOMMENTS - check if there is existing ro in extension table, set blob to empty, get set the pointer
    if  upper(@i_table_name) = 'QSICOMMENTS'  
     begin
	select @cnt = count(*)
	from qsicomments_ext
	where commentkey  = @v_commentkey
	and   commenttypecode  = @v_commenttypecode
	and   commenttypesubcode  = @v_commenttypesubcode
	and   commentstyle  = @i_html_type	

	if @cnt = 0 begin
	insert into qsicomments_ext(commentkey, commenttypecode, commenttypesubcode, commentstyle, lastuserid, lastmaintdate)
	values (@v_commentkey, @v_commenttypecode, @v_commenttypesubcode, @i_html_type,  'QSIDBA',  getdate())
	end 

	update qsicomments_ext
	set commentbody = ''
	where commentkey  = @v_commentkey
	and   commenttypecode  = @v_commenttypecode
	and   commenttypesubcode  = @v_commenttypesubcode
	and   commentstyle  = @i_html_type

	select @blob_pointer = textptr(commentbody)
	from qsicomments_ext
	where commentkey  = @v_commentkey
	and   commenttypecode  = @v_commenttypecode
	and   commenttypesubcode  = @v_commenttypesubcode
	and   commentstyle  = @i_html_type

    	select @blob_portion =  SUBSTRING(commenthtmllite, 1, @v_sec_length)  
        from qsicomments
	where commentkey = @v_commentkey
	and commenttypecode = @v_commenttypecode 
	and commenttypesubcode = @v_commenttypesubcode
     end

--skip preocessing if htmllite is null
if @blob_portion is Null 
begin
goto fetch_next
end 

set @v_length_org = len(@blob_portion+'x')-1
                  
  WHILE @v_complete = 0
    BEGIN -- loop full comment 
                    
      WHILE @loop = 0
        BEGIN -- loop comment part
       	  --###############################################################################
	  --TAG REPLACEMENT START HERE
	  --###############################################################################

	  --find opening <DIV ... and get rid of it.
	  --openinf <div ...> can be different so loop throught to replace them all
	  -- with simple <&&&> 
	  set @v_infinity = 0
	  set @v_error_ind = 0
 	  WHILE @loop = 0 
	  BEGIN
	  set @v_infinity = @v_infinity + 1
	    if @v_infinity > 10000 begin
 	    set @v_error_ind = 1
	    goto fetch_next
	    end

	     select @div_start =  CHARINDEX('<DIV', @blob_portion)

	     if @div_start = 0 begin
		break
	      end

		set @div_end = CHARINDEX('>', @blob_portion, @div_start)
		set @substr_blob = SUBSTRING (@blob_portion, @div_start , @div_end - @div_start + 1) 
		set @blob_portion = REPLACE (@blob_portion , @substr_blob , '<&&&>' )
	  END

 	  --find closing <\DIV> and replace with <BR>
	  select @blob_portion = REPLACE (@blob_portion , '</DIV><&&&>' , '<BR>' ) 
	  select @blob_portion = REPLACE (@blob_portion , '<&&&>' , '' )  
	  select @blob_portion = REPLACE (@blob_portion , '</DIV>' , '' )  
     


       	  --###############################################################################
	  --TAG REPLACEMENT END HERE
	  --###############################################################################
                                
          IF upper(@i_table_name) = 'BOOKCOMMENTS' BEGIN
              updatetext bookcomments_ext.commentbody @blob_pointer @insert_offset 0  @blob_portion
	  END ELSE BEGIN
              updatetext qsicomments_ext.commentbody @blob_pointer @insert_offset 0  @blob_portion
          END

          set @insert_offset = @insert_offset+len(@blob_portion+'x')-1

          if @v_length_org < @v_sec_length
            begin
              --set @blob_portion = dbo.comment_trim(@blob_portion,'TEXT')
              --remove trailing newline
              if substring(@blob_portion,datalength(@blob_portion)-2,2)=char(13)+char(10)
                begin
                  set @blob_portion=substring(@blob_portion,datalength(@blob_portion)-2,2)
                end
              set @v_complete = 1 --nothing left to read
              break
            end
          else 
            begin
              set @v_sec_point = @v_sec_point + @v_sec_length - @v_sec_adjust

	IF upper(@i_table_name) = 'BOOKCOMMENTS' BEGIN
	        select @blob_portion =  SUBSTRING(commenthtmllite, @v_sec_point+1, @v_sec_length) 
	        from bookcomments
		where bookkey = @v_commentkey 
		and printingkey = @v_printingkey 
		and commenttypecode = @v_commenttypecode 
		and commenttypesubcode = @v_commenttypesubcode
        END ELSE BEGIN
	        select @blob_portion =  SUBSTRING(commenthtmllite, @v_sec_point+1, @v_sec_length) 
	        from qsicomments
		where commentkey = @v_commentkey
		and commenttypecode = @v_commenttypecode 
		and commenttypesubcode = @v_commenttypesubcode
        END
print @blob_portion
              set @v_length_org = len(@blob_portion+'x')-1
              if @v_length_org  = 0
                begin
                  set @v_complete = 1
                  break
                end 
            end 
        end  -- loop comment part
    END -- loop full comment

    --set time stemp and user
    if upper(@i_table_name) = 'BOOKCOMMENTS' BEGIN
	    update bookcomments_ext
	    set lastuserid = 'QSIDBA', lastmaintdate = getdate()
	    where bookkey = @v_commentkey
	    and printingkey = @v_printingkey
	    and commenttypecode = @v_commenttypecode
	    and commenttypesubcode = @v_commenttypesubcode
	    and commentstyle = @i_html_type
     END ELSE BEGIN
	    update qsicomments_ext
	    set lastuserid = 'QSIDBA', lastmaintdate = getdate()
	    where commentkey = @v_commentkey
	    and commenttypecode = @v_commenttypecode
	    and commenttypesubcode = @v_commenttypesubcode
	    and commentstyle = @i_html_type
    END
 fetch_next:
    FETCH NEXT FROM cr_comments INTO @v_commentkey, @v_printingkey, @v_commenttypecode, @v_commenttypesubcode

   END /* WHILE FECTHING */

close cr_comments
deallocate cr_comments


END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO






