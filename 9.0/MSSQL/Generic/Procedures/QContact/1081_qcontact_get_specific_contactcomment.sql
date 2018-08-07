if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_specific_contactcomment') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_get_specific_contactcomment
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[qcontact_get_specific_contactcomment]
 (@i_contactkey        integer,
  @i_datacode       integer,
  @i_datasubcode    integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qcontact_get_specific_contactcomment
**  Desc: This stored procedure returns comment information
**        from the qsicomments table for a datacode/datasubcode. 
**
**    Auth: Jon Hess
**    Date: 16 July 2009
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************
Test String: genmsdevweb_71 exec dbo.qcontact_get_specific_contactcomment 3118736,1,0,0,0
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT

SELECT     gentables.*, subgentables.*, qsicomments.*, gentables.datacode AS gentables_datacode
FROM         subgentables RIGHT OUTER JOIN
                      gentables ON subgentables.tableid = gentables.tableid RIGHT OUTER JOIN
                      qsicomments ON gentables.datacode = qsicomments.commenttypecode
WHERE     (qsicomments.commentkey = @i_contactkey) AND (gentables.tableid = 528) AND (gentables.datacode = @i_datacode )

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing contactcomments: contactkey = ' + cast(@i_contactkey AS VARCHAR) + 
                        ' / datacode = ' + cast(@i_datacode AS VARCHAR) + 
                        ' / datasubcode = ' + cast(@i_datasubcode AS VARCHAR)
    RETURN 
  END 

GO

GRANT EXEC ON qcontact_get_specific_contactcomment TO PUBLIC
GO