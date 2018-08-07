if exists (select * from dbo.sysobjects where id = Object_id('dbo.get_next_jobnumber') and (type = 'P' or type = 'RF'))
  begin
    drop proc dbo.get_next_jobnumber
  end

GO

CREATE PROCEDURE dbo.get_next_jobnumber
  (@jobnumberseq CHAR(7) OUTPUT) 
AS

DECLARE @v_jobnumber int
DECLARE @v_jobnumberalpha char(7)
DECLARE @v_jobnumber_temp char(6)
DECLARE @v_jobnumber_zeros char(6)

BEGIN 
  SELECT @v_jobnumberalpha = jobnumberseq FROM defaults

  SELECT @v_jobnumber_temp = SUBSTRING(@v_jobnumberalpha,2,6)	

  SELECT @v_jobnumber = CONVERT(NUMERIC(6,0),@v_jobnumber_temp)

  SELECT @v_jobnumber = @v_jobnumber + 1

  SELECT  @v_jobnumber_zeros = STR(@v_jobnumber,6,0)

  SELECT @v_jobnumber_zeros = REPLACE(@v_jobnumber_zeros,' ','0')

  SELECT @jobnumberseq = 'J' + @v_jobnumber_zeros
  

  UPDATE defaults 
    SET jobnumberseq = @jobnumberseq
   WHERE defaultkey = 1
END

GO

GRANT EXECUTE ON dbo.get_next_jobnumber TO PUBLIC

GO