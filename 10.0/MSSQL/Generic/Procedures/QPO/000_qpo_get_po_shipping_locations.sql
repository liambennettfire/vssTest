IF EXISTS (
    SELECT *
    FROM dbo.sysobjects
    WHERE id = object_id(N'dbo.qpo_get_po_shipping_locations')
      AND OBJECTPROPERTY(id, N'IsProcedure') = 1
    )
  DROP PROCEDURE dbo.qpo_get_po_shipping_locations
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

CREATE PROCEDURE qpo_get_po_shipping_locations (
  @i_projectkey INTEGER,
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS
/*****************************************************************************************************************
**  Name: qpo_get_po_shipping_locations
**  Desc: This stored procedure gets the Shipping Locations Information for PO reports.
**
**  Auth: Uday A. Khisty
**  Date: 17 February 2017
**
*********************************************************************************************************************
**  Change History
**********************************************************************************************************************
**  Date:      Author:   Description:
**  --------   ------    ---------------------------------------------------------------------------------
**  05/10/17   Uday      Case 42347 - Task 001
**  03/22/18   Colman    Case 50385 - Add text field to Participant by Role section
**  05/08/18   Olivia	 Added gpokey to the gposection subquery
******************************************************************************************************************/
SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE @v_error_var INT,
  @v_rowcount_var INT

SELECT CASE 
    WHEN s.sectionkey > 0
      THEN (
          SELECT description
          FROM gposection
          WHERE sectionkey = s.sectionkey and gpokey = s.gpokey
          )
    ELSE NULL
    END AS productdescription,
  s.detaillinenbr,
  s.shiptoname,
  s.shiptoattn,
  COALESCE(s.shiptoaddress1, '') + '<br />' + COALESCE(s.shiptoaddress2, '') + '<br />' + COALESCE(s.shiptostate, '') + '<br />' + COALESCE(s.shiptozipcode, '') AS address,
  s.shipquantity,
  s.tobesoldind,
  CASE 
    WHEN s.shipmethod IS NOT NULL
      THEN (
          SELECT datadesc
          FROM gentables
          WHERE tableid = 1004
            AND datacode = cast(s.shipmethod AS INT)
          )
    ELSE NULL
    END AS shipmethoddesc,
  s.gposhippinginstructions,
  s.shipdate,
  s.dcponum
FROM gposhiptovendor s
WHERE gpokey = @i_projectkey

SELECT @v_error_var = @@ERROR,
  @v_rowcount_var = @@ROWCOUNT

IF @v_error_var <> 0
  OR @v_rowcount_var = 0
BEGIN
  SET @o_error_code = 1
  SET @o_error_desc = 'error accessing taqprojectcontact: taqprojectkey = ' + cast(@i_projectkey AS VARCHAR)
END
GO

GRANT EXEC
  ON qpo_get_po_shipping_locations
  TO PUBLIC
GO


