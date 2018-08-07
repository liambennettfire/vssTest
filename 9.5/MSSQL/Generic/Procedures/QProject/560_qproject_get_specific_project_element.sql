if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_specific_project_element') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_specific_project_element
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_specific_project_element
 (@i_projectkey     integer,
  @i_elementkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qproject_get_specific_project_element
**  Desc: This stored procedure returns element information
**        from the taqprojectelement table for a specific element. 
**
**    Auth: Alan Katzen
**    Date: 9/23/04
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  IF (@i_elementkey > 0) BEGIN
    -- elements with no subtypes UNION elements with subtypes
    SELECT g.tableid, g.datacode, g.datadesc gentabledatadesc, o.orgentrykey, g.datadesc displayname,
           ' ' subgentabledatadesc, 0 datasubcode, g.sortorder gensortorder, 0 subgensortorder, e.*
      FROM gentables g LEFT OUTER JOIN  gentablesorglevel o ON
		   g.tableid = o.tableid and 
           g.datacode = o.datacode,
		   taqprojectelement e
     WHERE e.taqprojectkey = @i_projectkey and
           e.taqelementkey = @i_elementkey and
           e.taqelementtypecode = g.datacode and
           e.taqelementtypesubcode = 0 and         
           g.tableid = 287 and 
          (g.deletestatus is null OR upper(g.deletestatus) = 'N')
  UNION
    SELECT g.tableid, g.datacode, g.datadesc gentabledatadesc, o.orgentrykey,
           ltrim(rtrim(COALESCE(g.datadesc,' '))) + '/' + ltrim(rtrim(COALESCE(s.datadesc,' '))) displayname,
           s.datadesc subgentabledatadesc, s.datasubcode, g.sortorder gensortorder, s.sortorder subgensortorder, e.*
      FROM  subgentables s LEFT OUTER JOIN  gentablesorglevel o ON
           s.tableid = o.tableid and 
           s.datacode = o.datacode,
		   taqprojectelement e, gentables g
     WHERE e.taqprojectkey = @i_projectkey and
           e.taqelementkey = @i_elementkey and
           e.taqelementtypecode = s.datacode and
           e.taqelementtypesubcode = s.datasubcode and         
           g.tableid = 287 and 
           g.tableid = s.tableid and
           g.datacode = s.datacode and
          (s.deletestatus is null OR upper(s.deletestatus) = 'N')
  ORDER BY gensortorder asc,subgensortorder asc,gentabledatadesc asc,subgentabledatadesc asc 
  END
  ELSE BEGIN
    SELECT g.tableid, g.datacode, g.datadesc gentabledatadesc, o.orgentrykey, g.datadesc displayname,
           ' ' subgentabledatadesc, 0 datasubcode, g.sortorder gensortorder, 0 subgensortorder, e.*
      FROM gentables g LEFT OUTER JOIN gentablesorglevel o ON
           g.tableid = o.tableid and 
           g.datacode = o.datacode,
		   taqprojectelement e
     WHERE e.taqprojectkey = @i_projectkey and
           e.taqelementtypecode = g.datacode and
           e.taqelementtypesubcode = 0 and         
           g.tableid = 287 and 
          (g.deletestatus is null OR upper(g.deletestatus) = 'N')
  UNION
    SELECT g.tableid, g.datacode, g.datadesc gentabledatadesc, o.orgentrykey,
           ltrim(rtrim(COALESCE(g.datadesc,' '))) + '/' + ltrim(rtrim(COALESCE(s.datadesc,' '))) displayname,
           s.datadesc subgentabledatadesc, s.datasubcode, g.sortorder gensortorder, s.sortorder subgensortorder, e.*
      FROM  subgentables s LEFT OUTER JOIN gentablesorglevel o ON
           s.tableid = o.tableid and 
           s.datacode = o.datacode,
		   taqprojectelement e, gentables g
     WHERE e.taqprojectkey = @i_projectkey and
           e.taqelementtypecode = s.datacode and
           e.taqelementtypesubcode = s.datasubcode and         
           g.tableid = 287 and 
           g.tableid = s.tableid and
           g.datacode = s.datacode and
          (s.deletestatus is null OR upper(s.deletestatus) = 'N')
  ORDER BY gensortorder asc,subgensortorder asc,gentabledatadesc asc,subgentabledatadesc asc 
  END

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: projectkey = ' + cast(@i_projectkey AS VARCHAR) + ' elementkey = ' + cast(@i_elementkey AS VARCHAR)
  END 

GO
GRANT EXEC ON qproject_get_specific_project_element TO PUBLIC
GO


