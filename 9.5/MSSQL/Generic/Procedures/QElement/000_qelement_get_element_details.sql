if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qelement_get_element_details') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qelement_get_element_details
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qelement_get_element_details
 (@i_elementkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qelement_get_element_details
**  Desc: This stored procedure returns element information
**        from the taqprojectelement table for a specific element. 
**
**    Auth: Alan Katzen
**    Date: 5/14/08
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var      INT,
          @rowcount_var   INT,
          @v_bookkey      INT,
          @v_projectkey   INT,
          @v_title        varchar(80),
          @v_projectname  varchar(80)

  -- get projectname and title
  SELECT @v_bookkey = COALESCE(bookkey,0),
         @v_projectkey = COALESCE(taqprojectkey,0)
    FROM taqprojectelement e
   WHERE e.taqelementkey = @i_elementkey
         
  IF @v_projectkey > 0 BEGIN
    SELECT @v_projectname = projecttitle
      FROM coreprojectinfo
     WHERE projectkey = @v_projectkey
  END

  IF @v_bookkey > 0 BEGIN
    SELECT @v_title = title
      FROM coretitleinfo
     WHERE bookkey = @v_bookkey
  END
          
  SELECT e.*, p.printingnum, @v_title booktitle, @v_projectname projectname,
    CASE 
      WHEN e.taqelementtypesubcode > 0 THEN 
        COALESCE(dbo.get_gentables_desc(287,e.taqelementtypecode,'long'),'') + '/' + 
			  COALESCE(dbo.get_subgentables_desc(287,e.taqelementtypecode,e.taqelementtypesubcode,'long'),'')
      ELSE COALESCE(dbo.get_gentables_desc(287,e.taqelementtypecode,'long'),'')
    END AS detaildesc
  FROM taqprojectelement e
    LEFT OUTER JOIN printing p ON e.bookkey = p.bookkey AND e.printingkey = p.printingkey  
  WHERE e.taqelementkey = @i_elementkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: elementkey = ' + cast(@i_elementkey AS VARCHAR)
  END 

GO
GRANT EXEC ON qelement_get_element_details TO PUBLIC
GO


