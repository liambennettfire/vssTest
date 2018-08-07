
if exists (select * from dbo.sysobjects where id = Object_id('dbo.get_publicity_co') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.get_publicity_co
end

GO

CREATE PROCEDURE dbo.get_publicity_co 
  (@companyname VARCHAR(50), @bucode INT, @cocode INT OUTPUT) 
AS

BEGIN

  SELECT @cocode = NULL

  SELECT @cocode = companykey
    FROM company
   WHERE UPPER(companydesc) = UPPER(@companyname) AND
         bucode = @bucode

END
    
GO

GRANT EXECUTE ON dbo.get_publicity_co TO PUBLIC

GO