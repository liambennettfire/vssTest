if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_comments_missing_markets') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_get_comments_missing_markets
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[qcontact_get_comments_missing_markets]
 (@i_contactkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qcontact_get_comments_missing_markets
**  Desc: This stored procedure returns a list of contact comment types
**        that require a designated market but are missing one. 
**
**
**    Auth: Colman
**    Date: 04 Aug 2015
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
*******************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE @error_var				INT
DECLARE @rowcount_var			INT

SELECT datacode
	FROM gentables RIGHT OUTER JOIN qsicomments ON gentables.datacode = qsicomments.commenttypecode AND gentables.gen1ind=1
	WHERE (qsicomments.commentkey = @i_contactkey) AND (tableid = 528) AND upper(COALESCE(deletestatus,'N')) = 'N'
EXCEPT
SELECT datacode
	FROM gentables RIGHT OUTER JOIN qsicomments ON gentables.datacode = qsicomments.commenttypecode AND gentables.gen1ind=1
		RIGHT OUTER JOIN qsicommentmarkets ON gentables.datacode = qsicommentmarkets.commenttypecode
	WHERE (qsicomments.commentkey = @i_contactkey) AND  (qsicommentmarkets.commentkey = @i_contactkey) AND (tableid = 528) AND upper(COALESCE(deletestatus,'N')) = 'N'


-- Save the @@ERROR and @@ROWCOUNT values in local 
-- variables before they are cleared.
SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 or @rowcount_var = 0 BEGIN
SET @o_error_code = 1
SET @o_error_desc = 'no data found: contact comments on qsicomments.'   
END 
GO

GRANT EXEC ON qcontact_get_comments_missing_markets TO PUBLIC
GO

