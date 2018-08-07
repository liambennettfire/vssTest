if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[delete_orphan_html_ext]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[delete_orphan_html_ext]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Desc: This stored procedure remove orphane rows from passed extension table
**    Auth: Anes Hrenovica
**    Date: 7/6/2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

CREATE    PROCEDURE dbo.delete_orphan_html_ext
		     @i_table_name varchar(100)

AS
DECLARE 
@v_commentkey int,
@v_bookkey int,
@v_printingkey int,
@v_commenttypecode int,
@v_commenttypesubcode int

DECLARE crbookcomments_ext CURSOR FOR
    select bookkey, printingkey, commenttypecode, commenttypesubcode
    from bookcomments_ext
    where NOT EXISTS
	   (select *
	   from bookcomments
	   where bookcomments_ext.bookkey = bookcomments.bookkey
	   and bookcomments_ext.printingkey = bookcomments.printingkey
	   and bookcomments_ext.commenttypecode = bookcomments.commenttypecode
	   and bookcomments_ext.commenttypesubcode = bookcomments.commenttypesubcode)

DECLARE crqsicomments_ext CURSOR FOR
    select commentkey, commenttypecode, commenttypesubcode
    from qsicomments_ext
    where NOT EXISTS
	   (select *
	   from qsicomments
	   where qsicomments_ext.commentkey = qsicomments.commentkey
	   and qsicomments_ext.commenttypecode = qsicomments.commenttypecode
	   and qsicomments_ext.commenttypesubcode = qsicomments.commenttypesubcode)

BEGIN 

IF upper(@i_table_name) = 'BOOKCOMMENTS_EXT' 
BEGIN
 OPEN crbookcomments_ext 
 FETCH NEXT FROM crbookcomments_ext INTO @v_bookkey, @v_printingkey, @v_commenttypecode, @v_commenttypesubcode
   WHILE (@@FETCH_STATUS <> -1)
    BEGIN

	delete from bookcomments_ext
	where bookkey = @v_bookkey
	and printingkey = @v_printingkey
	and commenttypecode = @v_commenttypecode 
	and commenttypesubcode = @v_commenttypesubcode
	FETCH NEXT FROM crbookcomments_ext INTO @v_bookkey, @v_printingkey, @v_commenttypecode, @v_commenttypesubcode
   END /* WHILE FECTHING */
close crbookcomments_ext
END


IF upper(@i_table_name) = 'QSICOMMENTS_EXT' 
BEGIN
 OPEN crqsicomments_ext 
 FETCH NEXT FROM crqsicomments_ext INTO @v_commentkey,@v_commenttypecode, @v_commenttypesubcode
   WHILE (@@FETCH_STATUS <> -1)
    BEGIN

	delete from qsicomments_ext
	where commentkey = @v_commentkey
	and commenttypecode = @v_commenttypecode 
	and commenttypesubcode = @v_commenttypesubcode

	FETCH NEXT FROM crqsicomments_ext INTO @v_commentkey, @v_commenttypecode, @v_commenttypesubcode
   END /* WHILE FECTHING */
close crqsicomments_ext
END


deallocate crbookcomments_ext
deallocate crqsicomments_ext
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


