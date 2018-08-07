 if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qelement_get_elements_for_task') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qelement_get_elements_for_task
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qelement_get_elements_for_task
 (@i_taqtaskkey           integer,
  @i_taqelementkey        integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  File: qelement_get_elements_for_task.sql
**  Name: qelement_get_elements_for_task
**  Desc: This stored procedure gets all elements for a task.  
**
**    Auth: Alan Katzen
**    Date: 7 September 2012
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/
BEGIN
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_quote    VARCHAR(2)

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_quote = ''''
    
  IF @i_taqtaskkey > 0 BEGIN
    SELECT te.taqelementdesc, te.taqelementtypecode, COALESCE(te.taqelementtypesubcode, 0) taqelementtypesubcode, 
      cast(te.taqelementtypecode as varchar) + ',' + cast(COALESCE(te.taqelementtypesubcode,0) as varchar) elementcodestring, 
      tptev.taqtaskkey, tptev.taqelementkey, tptev.overridetableind, tptev.overridetableind origoverridetableind, COALESCE(tptev.scheduleind, 0) scheduleind, tptev.lag, te.taqelementdesc,
      CASE 
        WHEN te.taqelementtypesubcode > 0 THEN 
          COALESCE(LTRIM(RTRIM(dbo.get_gentables_desc(287,te.taqelementtypecode,''))),'') + '/' + COALESCE(LTRIM(RTRIM(dbo.get_subgentables_desc(287,te.taqelementtypecode,te.taqelementtypesubcode,''))),'') 
        ELSE COALESCE(LTRIM(RTRIM(dbo.get_gentables_desc(287,te.taqelementtypecode,''))),'')
      END AS elementtypedetaildesc           
    FROM taqprojectelement te, taqprojecttaskelement_view tptev
    WHERE te.taqelementkey = tptev.taqelementkey
      and tptev.taqtaskkey = @i_taqtaskkey
    UNION
    SELECT te.taqelementdesc, te.taqelementtypecode, COALESCE(te.taqelementtypesubcode, 0) taqelementtypesubcode, 
      cast(te.taqelementtypecode as varchar) + ',' + cast(COALESCE(te.taqelementtypesubcode,0) as varchar) elementcodestring, 
      0 taqtaskkey, te.taqelementkey, 1 overridetableind, 0 origoverridetableind, 0 scheduleind, null lag, te.taqelementdesc,
      CASE 
        WHEN te.taqelementtypesubcode > 0 THEN 
          COALESCE(LTRIM(RTRIM(dbo.get_gentables_desc(287,te.taqelementtypecode,''))),'') + '/' + COALESCE(LTRIM(RTRIM(dbo.get_subgentables_desc(287,te.taqelementtypecode,te.taqelementtypesubcode,''))),'') 
        ELSE COALESCE(LTRIM(RTRIM(dbo.get_gentables_desc(287,te.taqelementtypecode,''))),'')
      END AS elementtypedetaildesc           
    FROM taqprojectelement te
    WHERE te.taqelementkey = @i_taqelementkey  
      AND NOT EXISTS (SELECT * FROM taqprojecttaskelement_view tptev WHERE te.taqelementkey = tptev.taqelementkey)
  END
  ELSE BEGIN
    SELECT te.taqelementdesc, te.taqelementtypecode, COALESCE(te.taqelementtypesubcode, 0) taqelementtypesubcode, 
      cast(te.taqelementtypecode as varchar) + ',' + cast(COALESCE(te.taqelementtypesubcode,0) as varchar) elementcodestring, 
      0 taqtaskkey, te.taqelementkey, 0 overridetableind, 0 origoverridetableind, 0 scheduleind, null lag, te.taqelementdesc,
      CASE 
        WHEN te.taqelementtypesubcode > 0 THEN 
          COALESCE(LTRIM(RTRIM(dbo.get_gentables_desc(287,te.taqelementtypecode,''))),'') + '/' + COALESCE(LTRIM(RTRIM(dbo.get_subgentables_desc(287,te.taqelementtypecode,te.taqelementtypesubcode,''))),'') 
        ELSE COALESCE(LTRIM(RTRIM(dbo.get_gentables_desc(287,te.taqelementtypecode,''))),'')
      END AS elementtypedetaildesc           
    FROM taqprojectelement te
    WHERE te.taqelementkey = @i_taqelementkey
  END
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error accessing taqprojecttaskelement_view'  
  END
END

GO
GRANT EXEC ON qelement_get_elements_for_task TO PUBLIC
GO


