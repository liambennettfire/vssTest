if exists (select * from dbo.sysobjects where id = object_id(N'dbo.po_get_po_details') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.po_get_po_details
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE po_get_po_details
 (@i_projectkey           integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************************************************
**  Name: po_get_po_details
**  Desc: This procedure returns gpodetail information for the Purchase Order project.  
**
**	Auth: Uday
**	Date: 24 June 2014
*******************************************************************************************************************
**	Change History
*******************************************************************************************************************
**	Date:     Author:   Case #:   Description:
**	--------  -------   -------   --------------------------------------
**	10/29/15  Kate      34067     Add section Quantity at specific level of detail - project or component level.
*******************************************************************************************************************/

DECLARE
  @v_error	INT,
  @v_rowcount INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
       
  SELECT 
    CASE m.longvalue
    WHEN 1	--Title/Project Detail report level
      THEN CASE
        WHEN d.reportformatcode = 2 THEN s.quantity
        ELSE NULL
      END
    WHEN 2	--Summary Component report level
      THEN CASE
        WHEN d.reportformatcode = 2 THEN s.quantity
        ELSE NULL
      END
    ELSE   --Detail Specs report level
      CASE
        WHEN d.subsectionkey > 0 AND d.reportformatcode = 3 THEN u.quantity
        WHEN d.reportformatcode = 3 THEN s.quantity
        ELSE NULL
      END
    END quantity,   
    d.*
  FROM gpodetail d
    LEFT OUTER JOIN taqprojectmisc m ON m.taqprojectkey = d.gpokey AND m.misckey IN (SELECT misckey FROM bookmiscitems WHERE qsicode=10)
    JOIN gposection s ON s.gpokey = d.gpokey AND s.sectionkey = d.sectionkey
    LEFT OUTER JOIN gposubsection u ON u.gpokey = d.gpokey AND u.sectionkey = d.sectionkey AND u.subsectionkey = d.subsectionkey
  WHERE d.gpokey = @i_projectkey
  ORDER BY d.sectionkey, d.subsectionkey, d.detaillinenbr

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning file locations for project (projectkey = ' + cast(@i_projectkey as varchar) + ')'
    RETURN  
  END 

END
GO

GRANT EXEC ON po_get_po_details TO PUBLIC
GO


