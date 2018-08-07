if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpo_get_po_description') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpo_get_po_description
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpo_get_po_description
 (@i_projectkey  integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************
**  Name: qpo_get_po_description
**  Desc: This stored procedure returns teh description for PO Report Costs. 
**
**  Auth: Uday A. Khisty
**  Date: 09/18/2014
*******************************************************************************/

  DECLARE
    @error_var  INT,
    @rowcount_var INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
   
  SELECT DISTINCT g.gpokey as projectkey, g.sectionkey, COALESCE(s.subsectionkey, 0) as subsectionkey,
	CASE
	  WHEN s.description IS NULL OR s.description='' THEN
		CASE
		  WHEN g.description IS NULL OR g.description='' THEN NULL
		  ELSE g.description
		END
	  WHEN g.description IS NULL OR g.description='' THEN s.description
	  ELSE LTRIM(g.description + ', ' + s.description)
	END AS description 
  from gposection g LEFT OUTER JOIN gposubsection s ON g.gpokey = s.gpokey AND g.sectionkey = s.sectionkey 
  WHERE g.gpokey = @i_projectkey
  AND EXISTS (SELECT * FROM gpocost c WHERE c.gpokey = g.gpokey AND c.sectionkey = g.sectionkey AND COALESCE(c.subsectionkey, 0) = COALESCE(s.subsectionkey, 0))
  Order by g.sectionkey,COALESCE(s.subsectionkey, 0)
    
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not retrieve rows from gposection / gposubsection table'
  END  

GO

GRANT EXEC ON qpo_get_po_description TO PUBLIC
GO
