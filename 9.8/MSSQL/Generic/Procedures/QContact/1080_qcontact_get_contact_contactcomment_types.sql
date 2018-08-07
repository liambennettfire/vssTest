if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_contact_contactcomment_types') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_get_contact_contactcomment_types
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[qcontact_get_contact_contactcomment_types]
 (@i_contactkey     integer,
  @v_showall		    integer,
  @i_userkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qcontact_get_contact_contactcomment_types
**  Desc: This stored procedure returns a list of contact comment types
**        from qsicomments for given contackey. 
**
**
**    Auth: Jonathan Hess
**    Date: 16 July 2009
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    02/18/14 Kusum          Case 26987 Select only active commenttypes
**    --------    --------        -------------------------------------------
**    exec dbo.qcontact_get_contact_contactcomment_types 3118056,1, 0, 0
**
**    exec dbo.qcontact_get_specific_contactcomment 3118056, 1, 0, 0, 0
*******************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE @tableid				INT
SET @tableid = 528
DECLARE @datacode				INT
DECLARE @error_var				INT
DECLARE @rowcount_var			INT


IF (@v_showall = 1) BEGIN
  SELECT datacode, 
         CASE WHEN ( dbo.qcontact_contact_comment_exists(@i_contactkey, datacode) = 1 ) THEN @i_contactkey ELSE 0 END  commentkey,
				 dbo.qcontact_contact_comment_exists(@i_contactkey, datacode) commentsexist,	datadesc, 
				 CASE WHEN (COALESCE(gentables.exporteloquenceind,0) = 1 AND COALESCE(gentables.acceptedbyeloquenceind,0) = 1) THEN 1 ELSE 0 END elocommentind,
         dbo.qutl_check_gentable_value_security(@i_userkey,'contactcomments',gentables.tableid,gentables.datacode) accesscode
		FROM gentables
	 WHERE (tableid = 528)
     AND upper(COALESCE(deletestatus,'N')) = 'N'
END
ELSE BEGIN
  SELECT gentables.*, qsicomments.*, CASE WHEN (COALESCE(gentables.exporteloquenceind,0) = 1 AND COALESCE(gentables.acceptedbyeloquenceind,0) = 1) THEN 1 ELSE 0 END elocommentind,
         dbo.qutl_check_gentable_value_security(@i_userkey,'contactcomments',gentables.tableid,gentables.datacode) accesscode
		FROM gentables RIGHT OUTER JOIN qsicomments ON gentables.datacode = qsicomments.commenttypecode
	 WHERE (qsicomments.commentkey = @i_contactkey) AND (tableid = 528) AND upper(COALESCE(deletestatus,'N')) = 'N'
END


-- Save the @@ERROR and @@ROWCOUNT values in local 
-- variables before they are cleared.
SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 or @rowcount_var = 0 BEGIN
SET @o_error_code = 1
SET @o_error_desc = 'no data found: contact comments on qsicomments.'   
END 
GO

GRANT EXEC ON qcontact_get_contact_contactcomment_types TO PUBLIC
GO

