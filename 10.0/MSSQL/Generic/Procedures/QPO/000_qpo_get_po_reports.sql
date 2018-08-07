IF EXISTS (
    SELECT *
    FROM dbo.sysobjects
    WHERE id = object_id(N'dbo.qpo_get_po_reports')
      AND OBJECTPROPERTY(id, N'IsProcedure') = 1
    )
  DROP PROCEDURE dbo.qpo_get_po_reports
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

CREATE PROCEDURE qpo_get_po_reports (
  @i_projectkey INT,
  @i_itemtype INT,
  @i_usageclass INT,
  @o_error_code INT OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS
/*****************************************************************************************************************
**  Name: qpo_get_po_reports
**  Desc: Returns a list of PO Reports that are available for this PO.
**
**  Auth: Colman
**  Date: 4/26/2018
**
******************************************************************************************************************
**  Change History
******************************************************************************************************************
**  Date:      Author:   Description:
**  --------   ------    -----------------------------------------------------------------------------------------
**
******************************************************************************************************************/
SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE @v_tableid INT,
  @v_datacode INT,
  @v_datasubcode INT,
  @v_itemtype INT,
  @v_usageclass INT,
  @v_error_var INT

SET @v_tableid = 509 -- Report Menu table

SELECT @v_datacode = datacode,
  @v_datasubcode = datasubcode
FROM subgentables
WHERE tableid = @v_tableid
  AND qsicode = 1

IF ISNULL(@i_projectkey, 0) > 0
  SELECT @v_itemtype = searchitemcode,
    @v_usageclass = usageclasscode
  FROM taqproject
  WHERE taqprojectkey = @i_projectkey
ELSE
  SELECT @v_itemtype = @i_itemtype,
    @v_usageclass = @i_usageclass

SELECT *
FROM sub2gentables
WHERE tableid = @v_tableid
  AND datacode = @v_datacode
  AND datasubcode = @v_datasubcode
  AND deletestatus = 'N'
  AND datasub2code IN (
    SELECT datasub2code
    FROM qutl_get_gentable_itemtype_filtering(@v_tableid, @v_itemtype, @v_usageclass)
    WHERE datacode = @v_datacode
      AND datasubcode = @v_datasubcode
    )

SELECT @v_error_var = @@ERROR

IF @v_error_var <> 0
BEGIN
  SET @o_error_code = - 1
  SET @o_error_desc = 'Error getting PO Report list'
END
GO

GRANT EXEC
  ON qpo_get_po_reports
  TO PUBLIC
GO


