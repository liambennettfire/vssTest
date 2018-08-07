if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_comment_types') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_comment_types
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO



CREATE PROCEDURE [dbo].[qproject_get_comment_types]
 (@i_projectkey     integer,
  @i_existingonly   bit,
  @i_itemtype       integer,
  @i_usageclass     integer,
  @i_userkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: qproject_get_comment_types.sql
**  Name: qproject_get_comment_types
**  Desc: This stored procedure returns all of the valid comment types
**        for a project
**
**    Auth: Joshua Robinson
**    Date: 3 April 2015
*******************************************************************************
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  -- Get comments types 
  SELECT DISTINCT g.datadesc, g.datacode
    FROM gentables g, subgentables s, gentablesitemtype i 
   WHERE g.tableid = s.tableid and
         g.datacode = s.datacode and
         g.tableid = 284 and
         (s.deletestatus is null OR upper(s.deletestatus) = 'N') and
         s.tableid = i.tableid  and
         s.datacode = i.datacode  and 
         s.datasubcode = i.datasubcode and 
         i.itemtypecode = @i_itemtype  and 
         COALESCE(i.itemtypesubcode,0) in (@i_usageclass,0)

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = 'no data found: distinct project comment types.'   
  END 



GO

GRANT EXEC ON qproject_get_comment_types TO PUBLIC
GO


