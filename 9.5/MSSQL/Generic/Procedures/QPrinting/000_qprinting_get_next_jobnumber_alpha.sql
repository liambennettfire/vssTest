if exists (select * from dbo.sysobjects where id = Object_id('dbo.qprinting_get_next_jobnumber_alpha') and (type = 'P' or type = 'RF'))
  begin
    drop proc dbo.qprinting_get_next_jobnumber_alpha
  end

GO

CREATE PROCEDURE dbo.qprinting_get_next_jobnumber_alpha
  (@o_JobNumberSeq          char(7) output,
  @o_error_code              integer       output,
  @o_error_desc              varchar(2000) output) 
AS

DECLARE @v_jobnumber int
DECLARE @v_jobnumberalpha char(7)
DECLARE @v_jobnumber_temp char(6)
DECLARE @v_jobnumber_zeros char(6)
DECLARE @error_var             INT
DECLARE  @rowcount_var          INT

BEGIN 

  SET @o_error_code = 0
  SET @o_error_desc = ''

  
  SELECT @v_jobnumber = numericdesc1 FROM gentables WHERE tableid = 594 AND qsicode = 14
  
  SELECT @v_jobnumber = @v_jobnumber + 1

  SELECT  @v_jobnumber_zeros = STR(@v_jobnumber,6,0)

  SELECT @v_jobnumber_zeros = REPLACE(@v_jobnumber_zeros,' ','0')

  --SELECT @o_JobNumberSeq = 'J' + @v_jobnumber_zeros
  
  UPDATE gentables 
    SET numericdesc1 = @v_jobnumber
   WHERE tableid = 594 AND qsicode = 14
  
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error updating numericdesc1 on gentables 594 for Job Number Alpha row'  
      RETURN 
    END     
  
   SELECT @o_JobNumberSeq = 'J' + @v_jobnumber_zeros  
    --RETURN   @o_JobNumberSeq
END

GO

GRANT EXECUTE ON dbo.qprinting_get_next_jobnumber_alpha TO PUBLIC

GO