
if exists (select * from dbo.sysobjects where id = Object_id('dbo.get_publicity_bu') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.get_publicity_bu
end

GO

CREATE PROCEDURE dbo.get_publicity_bu 
  (@userid VARCHAR(30), @bucode INT OUTPUT) 
AS

BEGIN

  SELECT @bucode = NULL

  SELECT @bucode = userbusinessunit.bucode
   FROM qsiusers LEFT OUTER JOIN userbusinessunit ON qsiusers.userkey = userbusinessunit.userkey 
   WHERE LTRIM(RTRIM(UPPER(qsiusers.userid))) = LTRIM(RTRIM(UPPER(@userid)))

END
    
GO

GRANT EXECUTE ON dbo.get_publicity_bu TO PUBLIC

GO
