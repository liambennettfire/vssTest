IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qean_generate_check_digit')
BEGIN
  DROP PROCEDURE qean_generate_check_digit
END
GO

CREATE PROCEDURE dbo.qean_generate_check_digit
  @passed_string	  varchar(50),
  @checkdigit	char(1) output,		
  @type		int
AS
  
BEGIN

  SET @checkdigit = dbo.qean_checkdigit(@passed_string, @type)

END
GO

GRANT EXEC ON dbo.qean_generate_check_digit TO PUBLIC
GO
