if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qelement_get_elements') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qelement_get_elements
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qelement_get_elements
 (@i_projectkeylist varchar(max),
  @i_bookkeylist    varchar(max),
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qelement_get_elements
**  Desc: This stored procedure returns all elements for a list of projectkeys,
**        bookkeys, or contactkeys.
**
**    Auth: Alan Katzen
**    Date: 7/25/08
*******************************************************************************/

  DECLARE
    @v_quote    VARCHAR(2),
    @v_sqlselect  VARCHAR(4000),
    @v_sqlfrom    VARCHAR(2000),
    @v_sqlwhere   VARCHAR(max),
    @v_sqlwhere_keys  VARCHAR(max),
    @v_sqlstring  NVARCHAR(max),
    @error_var  INT,
    @rowcount_var INT

  SET @v_quote = ''''
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- must have at least one list of keys
  IF (@i_projectkeylist is null OR ltrim(rtrim(@i_projectkeylist)) = '') AND
     (@i_bookkeylist is null OR ltrim(rtrim(@i_bookkeylist)) = '') BEGIN
    return
  END
     
  -- ***** Build the dynamic SQL which will be used to retrieve tasks ***** --
  -- For drop-downs, get distinct elements 
  ---SET @v_sqlselect = 'SELECT e.taqelementkey,e.taqelementdesc,COALESCE(e.sortorder,0) sortorder,' +
  ---    'e.taqelementtypecode elementtypecode,COALESCE(e.taqelementtypesubcode,0) elementtypesubcode,' +
 ---     'cast(e.taqelementtypecode as varchar) + ' + @v_quote + ',' + @v_quote +  
 ---     ' + cast(COALESCE(e.taqelementtypesubcode,0) as varchar) elementcodestring,' + 
----      'CASE 
----        WHEN taqelementtypesubcode > 0 THEN 
 ----         COALESCE(LTRIM(RTRIM(dbo.get_gentables_desc(287,e.taqelementtypecode,' + @v_quote + 'long' + @v_quote + '))),'''') + ' + 
----          @v_quote + '/' + @v_quote + 
  ----        ' + COALESCE(LTRIM(RTRIM(dbo.get_subgentables_desc(287,e.taqelementtypecode,e.taqelementtypesubcode,' + @v_quote + 'long' + @v_quote + '))),'''')
  ----      ELSE LTRIM(RTRIM(dbo.get_gentables_desc(287,e.taqelementtypecode,' + @v_quote + 'long' + @v_quote + ')))' +
  ---    'END AS detaildesc'

	SET @v_sqlselect = 'SELECT e.taqelementkey,e.taqelementdesc,COALESCE(e.sortorder,0) sortorder,' +
	'e.taqelementtypecode elementtypecode,COALESCE(e.taqelementtypesubcode,0) elementtypesubcode,' +
	'cast(e.taqelementtypecode as varchar) + ' + @v_quote + ',' + @v_quote +  
	' + cast(COALESCE(e.taqelementtypesubcode,0) as varchar) elementcodestring,' + 
     'CASE 
        WHEN e.taqelementtypecode > 0 THEN 
          (select COALESCE(gen1ind,0) from gentables where tableid=287 and datacode=e.taqelementtypecode)
        ELSE 0 ' +
      'END AS digitalassetind,' + 
	'CASE 
			  WHEN taqelementtypesubcode > 0 THEN 
				 COALESCE(LTRIM(RTRIM(g.datadesc)),'''') + ' + @v_quote + '/'+ @v_quote + ' + COALESCE(LTRIM(RTRIM(s.datadesc)),'''') 
			  ELSE COALESCE(LTRIM(RTRIM(g.datadesc)),'''')' +
	 'END AS detaildesc'

  SET @v_sqlfrom = ' FROM taqprojectelement e ' +
  ' LEFT OUTER JOIN gentables g ON e.taqelementtypecode = g.datacode AND g.tableid = 287 ' +
  ' LEFT OUTER JOIN subgentables s ON e.taqelementtypecode = s.datacode AND e.taqelementtypesubcode = s.datasubcode AND s.tableid = 287  '
  
  -- add in keylists
  SET @v_sqlwhere_keys = '('
  IF (@i_projectkeylist is not null AND ltrim(rtrim(@i_projectkeylist)) <> '') BEGIN
    IF @v_sqlwhere_keys = '(' BEGIN
      SET @v_sqlwhere_keys = @v_sqlwhere_keys + ' (e.taqprojectkey in (' + @i_projectkeylist + '))'
    END
    ELSE BEGIN
      SET @v_sqlwhere_keys = @v_sqlwhere_keys + ' OR (e.taqprojectkey in (' + @i_projectkeylist + '))'
    END
  END

  IF (@i_bookkeylist is not null AND ltrim(rtrim(@i_bookkeylist)) <> '') BEGIN
    IF @v_sqlwhere_keys = '(' BEGIN
      SET @v_sqlwhere_keys = @v_sqlwhere_keys + ' (e.bookkey in (' + @i_bookkeylist + '))'
    END
    ELSE BEGIN
      SET @v_sqlwhere_keys = @v_sqlwhere_keys + ' OR (e.bookkey in (' + @i_bookkeylist + '))'
    END
  END      
  SET @v_sqlwhere_keys = @v_sqlwhere_keys + ')'
  
  SET @v_sqlwhere = ' WHERE ' + @v_sqlwhere_keys + ' AND (g.deletestatus = null or g.deletestatus = ''N'') '
    
  -- Set and execute the full sqlstring
  SET @v_sqlstring = @v_sqlselect + @v_sqlfrom + @v_sqlwhere + ' ORDER BY sortorder'

PRINT @v_sqlstring

      
  EXECUTE sp_executesql @v_sqlstring

  --PRINT @v_sqlstring

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no elements found'
  END 

GO

GRANT EXEC ON qelement_get_elements TO PUBLIC
GO