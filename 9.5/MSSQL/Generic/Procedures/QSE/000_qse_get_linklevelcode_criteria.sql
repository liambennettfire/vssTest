IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_get_linklevelcode_criteria')
  DROP PROCEDURE  qse_get_linklevelcode_criteria
GO

CREATE PROCEDURE qse_get_linklevelcode_criteria
(
  @o_error_code		INT OUT,
  @o_error_desc		VARCHAR(2000) OUT 
)
AS

/*****************************************************************************************************
**  Name: qse_get_linklevelcode_criteria
**  Desc: This stored procedure returns linklevelcode values for the search criteria drop-down.
**
**  Auth: Kate
**  Date: March 5 2010
******************************************************************************************************/

BEGIN
  DECLARE 
    @v_error  INT,
    @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT DISTINCT CONVERT(INT,linklevelcode) linklevelcode, CASE linklevelcode WHEN 20 THEN 'Secondary' WHEN 30 THEN 'Set' ELSE 'Primary' END linkleveldesc
  FROM book
    
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access the book table.'
    RETURN
  END

END
GO

GRANT EXEC ON qse_get_linklevelcode_criteria TO PUBLIC
GO
