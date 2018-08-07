IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_get_season_criteria')
  DROP PROCEDURE  qse_get_season_criteria
GO

CREATE PROCEDURE qse_get_season_criteria
(
  @o_error_code		INT OUT,
  @o_error_desc		VARCHAR(2000) OUT 
)
AS

/*****************************************************************************************************
**  Name: qse_get_season_criteria
**  Desc: This stored procedure returns Season gentable values for the search criteria drop-down.
**        It includes 'UNSCHEDULED' season criteria which will return all seasons that are not Actual.
**
**  Auth: Kate
**  Date: 30 June 2009
******************************************************************************************************/

BEGIN
  DECLARE 
    @v_error  INT,
    @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT s.seasonkey, s.seasondesc
  FROM season s 
  WHERE s.activeind=1
  UNION
  SELECT 99999 seasonkey, 'UNSCHEDULED' seasondesc
    
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access season table.'
    RETURN
  END

END
GO

GRANT EXEC ON qse_get_season_criteria TO PUBLIC
GO
