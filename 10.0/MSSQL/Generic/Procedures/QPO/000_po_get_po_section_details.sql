if exists (select * from dbo.sysobjects where id = object_id(N'dbo.po_get_po_section_details') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.po_get_po_section_details
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE po_get_po_section_details
 (@i_taqprojectformatkey  integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************************************************
**  Name: po_get_po_section_details
**  Desc: This procedure returns section details for PO
**
**	Auth: Dustin
**	Date: 22 November 2016
*******************************************************************************************************************
**	Change History
*******************************************************************************************************************
**	Date:     Author:   Case #:   Description:
**	--------  -------   -------   --------------------------------------
**  02/13/17  Colman    42803
**  06/02/17  Uday      45218
*******************************************************************************************************************/

DECLARE
  @v_error	INT,
  @v_rowcount INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
       
  SELECT frp.taqversionformatrelatedkey, frp.taqversionformatkey, frp.taqprojectkey, frp.relatedprojectkey, frp.relatedversionformatkey, 
    frp.plantcostpercent, frp.editioncostpercent, frp.ponote,
    CASE WHEN tvf.sharedposectionind = 1
    THEN frp.quantity
    ELSE dbo.qpo_get_po_section_quantity(frp.taqversionformatkey) END AS quantity,
    tp.taqprojecttitle AS printingtitle, tvf.allocationtype, tpv.bookkey, tpv.printingkey 
  FROM taqversionformatrelatedproject frp
  JOIN taqproject tp
  ON frp.relatedprojectkey=tp.taqprojectkey
  JOIN taqversionformat tvf
  ON frp.taqversionformatkey = tvf.taqprojectformatkey
  JOIN taqprojectprinting_view tpv ON tpv.taqprojectkey = frp.relatedprojectkey
  WHERE frp.taqversionformatkey = @i_taqprojectformatkey

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning PO section detail (taqprojectformatkey = ' + cast(@i_taqprojectformatkey as varchar) + ')'
    RETURN  
  END 

END
GO

GRANT EXEC ON po_get_po_section_details TO PUBLIC
GO


