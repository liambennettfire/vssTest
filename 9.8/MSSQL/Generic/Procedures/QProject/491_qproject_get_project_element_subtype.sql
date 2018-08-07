if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_project_element_subtype') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_project_element_subtype
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_project_element_subtype
 (@i_projectkey     integer,
  @i_bookkey        integer,
  @i_printingkey    integer,
  @i_usedetaildesc  bit,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_project_element_subtype
**  Desc: This stored procedure returns all of the valid element subtypes
**        for a project.    
**
**    Auth: Kate W.
**    Date: 29 November 2004
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  IF (COALESCE(@i_projectkey,0) <= 0 AND COALESCE(@i_bookkey,0) <= 0) BEGIN
    return
  END
  
  -- retrieve given printing
  -- (elements with no subtypes UNION elements with subtypes)
  IF @i_bookkey > 0 AND @i_printingkey > 0
    SELECT g.datadesc detaildesc,
      g.datacode elementtypecode, 0 elementtypesubcode, o.orgentrykey, 
      g.sortorder gensortorder, 0 subgensortorder, 
      cast(g.datacode as varchar) + ',0' elementcodestring,
      e.taqelementdesc, e.elementstatus, e.taqelementkey, COALESCE(e.taqprojectkey,0) taqprojectkey, 
      COALESCE(e.bookkey,0) bookkey, COALESCE(e.printingkey,0) printingkey,
      dbo.qproject_is_sent_to_tmm(N'gentables',g.tableid,g.datacode,0) sendtotmm,
      p.printingnum, e.sortorder as elementsortorder, COALESCE(e.sortorder, 32767) elementsortordervalue
    FROM gentables g 
      LEFT OUTER JOIN gentablesorglevel o ON g.tableid = o.tableid AND g.datacode = o.datacode,
      taqprojectelement e
      LEFT OUTER JOIN printing p ON e.bookkey = p.bookkey AND e.printingkey = p.printingkey
    WHERE ((e.taqprojectkey = @i_projectkey AND COALESCE(@i_projectkey, 0) > 0) OR (e.bookkey = @i_bookkey AND COALESCE(@i_bookkey, 0) > 0 AND e.printingkey = @i_printingkey)) and
      e.taqelementtypecode = g.datacode and
      e.taqelementtypesubcode = 0 and         
      g.tableid = 287 and 
      COALESCE(upper(g.deletestatus),'N') = 'N' and
      COALESCE(g.gen1ind,0) <> 1
    UNION
    SELECT 
      CASE 
        WHEN @i_usedetaildesc = 1 THEN COALESCE(LTRIM(RTRIM(g.datadesc)),'') + '/' + COALESCE(LTRIM(RTRIM(s.datadesc)),'')
        ELSE COALESCE(LTRIM(RTRIM(s.datadesc)),'')
      END AS detaildesc,
      g.datacode elementtypecode, s.datasubcode elementtypesubcode, o.orgentrykey,           
      g.sortorder gensortorder, s.sortorder subgensortorder, 
      cast(g.datacode as varchar) + ',' + cast(s.datasubcode as varchar) elementcodestring,
      e.taqelementdesc, e.elementstatus, e.taqelementkey, COALESCE(e.taqprojectkey,0) taqprojectkey, 
      COALESCE(e.bookkey,0) bookkey, COALESCE(e.printingkey,0) printingkey,
      dbo.qproject_is_sent_to_tmm(N'subgentables',s.tableid,s.datacode,s.datasubcode) sendtotmm,
      p.printingnum, e.sortorder as elementsortorder, COALESCE(e.sortorder, 32767) elementsortordervalue
    FROM subgentables s 
      LEFT OUTER JOIN gentablesorglevel o ON s.tableid = o.tableid AND s.datacode = o.datacode,
      gentables g, 
      taqprojectelement e
      LEFT OUTER JOIN printing p ON e.bookkey = p.bookkey AND e.printingkey = p.printingkey
    WHERE ((e.taqprojectkey = @i_projectkey AND COALESCE(@i_projectkey, 0) > 0) OR (e.bookkey = @i_bookkey AND COALESCE(@i_bookkey, 0) > 0 AND e.printingkey = @i_printingkey)) and
      e.taqelementtypecode = s.datacode and
      e.taqelementtypesubcode = s.datasubcode and         
      g.tableid = 287 and 
      g.tableid = s.tableid and
      g.datacode = s.datacode and
      COALESCE(upper(s.deletestatus),'N') = 'N' and
      COALESCE(g.gen1ind,0) <> 1
    ORDER BY gensortorder asc,subgensortorder asc,detaildesc asc 
  ELSE  --retrieve all printings
    SELECT g.datadesc detaildesc,
      g.datacode elementtypecode, 0 elementtypesubcode, o.orgentrykey, 
      g.sortorder gensortorder, 0 subgensortorder, 
      cast(g.datacode as varchar) + ',0' elementcodestring,
      e.taqelementdesc, e.elementstatus, e.taqelementkey, COALESCE(e.taqprojectkey,0) taqprojectkey, 
      COALESCE(e.bookkey,0) bookkey, COALESCE(e.printingkey,0) printingkey,
      dbo.qproject_is_sent_to_tmm(N'gentables',g.tableid,g.datacode,0) sendtotmm,
      p.printingnum, e.sortorder as elementsortorder, COALESCE(e.sortorder, 32767) elementsortordervalue
    FROM gentables g 
      LEFT OUTER JOIN gentablesorglevel o ON g.tableid = o.tableid AND g.datacode = o.datacode,
      taqprojectelement e
      LEFT OUTER JOIN printing p ON e.bookkey = p.bookkey AND e.printingkey = p.printingkey
    WHERE ((e.taqprojectkey = @i_projectkey AND COALESCE(@i_projectkey, 0) > 0) OR (e.bookkey = @i_bookkey AND COALESCE(@i_bookkey, 0) > 0)) and
      e.taqelementtypecode = g.datacode and
      e.taqelementtypesubcode = 0 and         
      g.tableid = 287 and 
      COALESCE(upper(g.deletestatus),'N') = 'N' and
      COALESCE(g.gen1ind,0) <> 1
    UNION
    SELECT 
      CASE 
        WHEN @i_usedetaildesc = 1 THEN COALESCE(LTRIM(RTRIM(g.datadesc)),'') + '/' + COALESCE(LTRIM(RTRIM(s.datadesc)),'')
        ELSE COALESCE(LTRIM(RTRIM(s.datadesc)),'')
      END AS detaildesc,
      g.datacode elementtypecode, s.datasubcode elementtypesubcode, o.orgentrykey,           
      g.sortorder gensortorder, s.sortorder subgensortorder, 
      cast(g.datacode as varchar) + ',' + cast(s.datasubcode as varchar) elementcodestring,
      e.taqelementdesc, e.elementstatus, e.taqelementkey, COALESCE(e.taqprojectkey,0) taqprojectkey, 
      COALESCE(e.bookkey,0) bookkey, COALESCE(e.printingkey,0) printingkey,
      dbo.qproject_is_sent_to_tmm(N'subgentables',s.tableid,s.datacode,s.datasubcode) sendtotmm,
      p.printingnum, e.sortorder as elementsortorder, COALESCE(e.sortorder, 32767) elementsortordervalue
    FROM subgentables s 
      LEFT OUTER JOIN gentablesorglevel o ON s.tableid = o.tableid AND s.datacode = o.datacode,
      gentables g, 
      taqprojectelement e
      LEFT OUTER JOIN printing p ON e.bookkey = p.bookkey AND e.printingkey = p.printingkey
    WHERE ((e.taqprojectkey = @i_projectkey AND COALESCE(@i_projectkey, 0) > 0) OR (e.bookkey = @i_bookkey AND COALESCE(@i_bookkey, 0) > 0)) and
      e.taqelementtypecode = s.datacode and
      e.taqelementtypesubcode = s.datasubcode and         
      g.tableid = 287 and 
      g.tableid = s.tableid and
      g.datacode = s.datacode and
      COALESCE(upper(s.deletestatus),'N') = 'N' and
      COALESCE(g.gen1ind,0) <> 1
    ORDER BY elementsortordervalue asc,gensortorder asc,subgensortorder asc,detaildesc asc
    
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT

  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: element types on gentables/subgentables (for qproject_get_project_element_subtype).'   
  END 

GO

GRANT EXEC ON qproject_get_project_element_subtype TO PUBLIC
GO



