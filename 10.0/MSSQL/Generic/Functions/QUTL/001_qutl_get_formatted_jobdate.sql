IF EXISTS (
    SELECT *
    FROM dbo.sysobjects
    WHERE id = object_id(N'dbo.qutl_get_formatted_jobdate')
      AND xtype IN (N'FN', N'IF', N'TF')
    )
  DROP FUNCTION dbo.qutl_get_formatted_jobdate
GO

CREATE FUNCTION qutl_get_formatted_jobdate (
  @i_datetime DATETIME
)
RETURNS VARCHAR(255)

/******************************************************************************
**  Name: qutl_get_formatted_jobdate
**  Desc: Returns a date string formatted using client settings for job messages
**
**  Auth: Colman
**  Date: 3/16/2018
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:      Description:
**  --------  ----------   ----------------------------------------------------
**    
*******************************************************************************/
BEGIN
  DECLARE @v_dateformatcode INT,
          @v_clientdefaultvalue INT,
          @v_dateformat_value VARCHAR(40),
          @v_dateformat_conversionvalue INT,
          @v_formatteddate VARCHAR(255),
          @v_datacode INT,
          @v_startpos INT

  SELECT @v_clientdefaultvalue = COALESCE(CAST(clientdefaultvalue AS INT), 1)
  FROM clientdefaults
  WHERE clientdefaultid = 80   -- Date Format Default for Job Messages

  SELECT @v_dateformat_value = LTRIM(RTRIM(UPPER(datadesc))), @v_datacode = datacode
  FROM gentables
  WHERE tableid = 607
    AND qsicode = @v_clientdefaultvalue

  SELECT @v_dateformat_conversionvalue = CAST(COALESCE(gentext2, '101') AS INT)
  FROM gentables_ext
  WHERE tableid = 607
    AND datacode = @v_datacode

  SELECT @v_startpos = CHARINDEX(':', CONVERT(VARCHAR(25), CONVERT(VARCHAR(25), @i_datetime, 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), @i_datetime, 22), 11))), - 1) + 1

  SELECT @v_formatteddate = REPLACE(STUFF(CONVERT(VARCHAR(25), CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), @i_datetime, 22), 11))), CHARINDEX(':', CONVERT(VARCHAR(25), CONVERT(VARCHAR(25), @i_datetime, @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), @i_datetime, 22), 11))), @v_startpos), 3, ''), '  ', ' ')

  RETURN @v_formatteddate
END
GO

GRANT EXEC ON dbo.qutl_get_formatted_jobdate TO PUBLIC
GO


