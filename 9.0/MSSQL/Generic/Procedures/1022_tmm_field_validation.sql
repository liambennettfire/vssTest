IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.tmm_field_validation') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.tmm_field_validation
END
GO

CREATE PROCEDURE tmm_field_validation @w_window_name varchar(100), @v_bookkey int, @v_msg varchar(400) output
 AS
BEGIN

DECLARE
@v_string_value varchar(8000), 
@v_long_value int

set @v_msg = ''


END
GO

GRANT EXECUTE ON dbo.tmm_field_validation TO PUBLIC
GO


