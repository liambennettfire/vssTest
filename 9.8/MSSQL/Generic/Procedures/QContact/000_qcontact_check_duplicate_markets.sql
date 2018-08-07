if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_check_duplicate_markets') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_check_duplicate_markets
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[qcontact_check_duplicate_markets]
 (@i_contactkey     integer,
  @i_commenttype    integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qcontact_check_duplicate_markets
**  Desc: Check that no two comments with the same eloquence tag have the same market(s)
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
DECLARE @v_fieldtag VARCHAR(30)

SELECT @v_fieldtag = eloquencefieldtag FROM gentables WHERE tableid=528 AND datacode=@i_commenttype

SELECT COUNT(*) as duplicatecount FROM qsicommentmarkets m 
WHERE m.commentkey=@i_contactkey AND m.commenttypecode in (SELECT datacode from gentables WHERE tableid=528 AND eloquencefieldtag=@v_fieldtag)
AND m.commenttypecode <> @i_commenttype AND m.marketcode IN (SELECT marketcode FROM qsicommentmarkets m WHERE m.commentkey=@i_contactkey AND m.commenttypecode = @i_commenttype)

-- Save the @@ERROR and @@ROWCOUNT values in local 
-- variables before they are cleared.
SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 or @rowcount_var = 0 BEGIN
SET @o_error_code = 1
SET @o_error_desc = 'no data found: contact comment markets on qsicommentmarkets.'   
END 
GO

GRANT EXEC ON qcontact_check_duplicate_markets TO PUBLIC
GO

