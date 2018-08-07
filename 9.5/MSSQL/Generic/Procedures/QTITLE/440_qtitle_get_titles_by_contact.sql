
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_titles_by_contact') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_titles_by_contact
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_titles_by_contact
 (@i_contactkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qtitle_get_titles_by_contact
**  Desc: This stored procedure gets all of the titles that have been written
**        by the specified contact.  For now the the results will be limited to
**        the first printing.
**
**              
**
**    Auth: James P. Weber
**    Date: 28 Jan 2005
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:              Description:
**    --------    -------------        -------------------------------------------
**    03/08/2016  Uday A. Khisty	   Case 36678
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT distinct c.*, bd.csapprovalcode, bd.editiondescription, 
         dbo.get_gentables_desc(312,c.mediatypecode,'long') mediadesc,
         dbo.qutl_get_gentables_ext_gentext1(620, bd.csapprovalcode) iconfilename
    FROM coretitleinfo c, bookauthor ba, bookdetail bd 
   WHERE ba.authorkey = @i_contactkey and
         c.bookkey = ba.bookkey and
         c.bookkey = bd.bookkey and 
		 c.printingkey  = 1
  UNION
  SELECT distinct c.*, bd.csapprovalcode, bd.editiondescription, 
         dbo.get_gentables_desc(312,c.mediatypecode,'long') mediadesc,
         dbo.qutl_get_gentables_ext_gentext1(620, bd.csapprovalcode) iconfilename
    FROM coretitleinfo c, bookcontact bc, bookdetail bd
   WHERE bc.globalcontactkey = @i_contactkey and
         c.bookkey = bc.bookkey and
         c.printingkey = bc.printingkey and
         c.bookkey = bd.bookkey and
		 c.printingkey  = 1
  ORDER BY c.title asc

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: contactkey  = ' + cast(@i_contactkey AS VARCHAR)  
  END 

GO
GRANT EXEC ON qtitle_get_titles_by_contact TO PUBLIC
GO


