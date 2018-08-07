
if exists (select * from dbo.sysobjects where id = Object_id('dbo.get_publicity_dp') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.get_publicity_dp
end

GO

CREATE PROCEDURE dbo.get_publicity_dp
  (@deptname VARCHAR(50), @companycode INT, @bucode INT, @deptcode INT OUTPUT) 
AS

BEGIN

  SELECT @deptcode = NULL

  SELECT @deptcode = deptkey
    FROM dept
   WHERE UPPER(deptdesc) = UPPER(@deptname) AND
         companykey = @companycode AND
         bucode = @bucode

END
    
GO

GRANT EXECUTE ON dbo.get_publicity_dp TO PUBLIC

GO