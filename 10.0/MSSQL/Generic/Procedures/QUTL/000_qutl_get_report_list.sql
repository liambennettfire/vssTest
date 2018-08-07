IF EXISTS (
    SELECT *
    FROM dbo.sysobjects
    WHERE id = object_id(N'dbo.qutl_get_report_list')
      AND OBJECTPROPERTY(id, N'IsProcedure') = 1
    )
  DROP PROCEDURE dbo.qutl_get_report_list
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

CREATE PROCEDURE qutl_get_report_list (
  @i_reporttype INT,
  @i_reportsubtype INT,
  @i_itemtype INT,
  @i_usageclass INT,
  @o_error_code INT OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS
/*****************************************************************************************************************
**  Name: qutl_get_report_list
**  Desc: Returns a list of item type filtered Reports.
**
**  Auth: Colman
**  Date: 5/30/2018
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

DECLARE @v_tableid INT

SET @v_tableid = 509 -- Report Menu table

SELECT datacode, datasubcode, datasub2code, datadesc, sortorder, alternatedesc2
FROM sub2gentables
WHERE tableid = @v_tableid
  AND datacode = @i_reporttype
  AND datasubcode = @i_reportsubtype
  AND deletestatus = 'N'
  AND datasub2code IN (
    SELECT datasub2code
    FROM qutl_get_gentable_itemtype_filtering(@v_tableid, @i_itemtype, @i_usageclass)
    WHERE datacode = @i_reporttype
      AND datasubcode = @i_reportsubtype
    )

IF @@ERROR <> 0
BEGIN
  SET @o_error_code = - 1
  SET @o_error_desc = 'Error getting Report list'
END
GO

GRANT EXEC
  ON qutl_get_report_list
  TO PUBLIC
GO


