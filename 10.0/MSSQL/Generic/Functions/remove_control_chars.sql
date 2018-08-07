
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.remove_control_chars') AND type = 'FN')
	DROP function [dbo].remove_control_chars
GO

create FUNCTION [dbo].remove_control_chars
    ( @i_string as varchar(MAX))

RETURNS varchar(MAX)

BEGIN 
	DECLARE @o_string varchar(MAX)

	set @o_string = cast(@i_string as varchar(MAX))

	set @o_string = replace(@o_string,CHAR(1),'') --control char
	set @o_string = replace(@o_string,CHAR(2),'') --control char
	set @o_string = replace(@o_string,CHAR(3),'') --control char
	set @o_string = replace(@o_string,CHAR(4),'') --control char
	set @o_string = replace(@o_string,CHAR(5),'') --control char
	set @o_string = replace(@o_string,CHAR(6),'') --control char
	set @o_string = replace(@o_string,CHAR(7),'') --control char
	set @o_string = replace(@o_string,CHAR(8),'') --control char
	set @o_string = replace(@o_string,CHAR(9),'') --control char
	set @o_string = replace(@o_string,CHAR(10),'') --control char
	set @o_string = replace(@o_string,CHAR(11),'') --control char
	set @o_string = replace(@o_string,CHAR(12),'') --control char
	set @o_string = replace(@o_string,CHAR(13),'') --control char
	set @o_string = replace(@o_string,CHAR(14),'') --control char
	set @o_string = replace(@o_string,CHAR(15),'') --control char
	set @o_string = replace(@o_string,CHAR(16),'') --control char
	set @o_string = replace(@o_string,CHAR(17),'') --control char
	set @o_string = replace(@o_string,CHAR(18),'') --control char
	set @o_string = replace(@o_string,CHAR(19),'') --control char
	set @o_string = replace(@o_string,CHAR(20),'') --control char
	set @o_string = replace(@o_string,CHAR(21),'') --control char
	set @o_string = replace(@o_string,CHAR(22),'') --control char
	set @o_string = replace(@o_string,CHAR(23),'') --control char
	set @o_string = replace(@o_string,CHAR(24),'') --control char
	set @o_string = replace(@o_string,CHAR(25),'') --control char
	set @o_string = replace(@o_string,CHAR(26),'') --control char
	set @o_string = replace(@o_string,CHAR(27),'') --control char
	set @o_string = replace(@o_string,CHAR(28),'') --control char
	set @o_string = replace(@o_string,CHAR(29),'') --control char
	set @o_string = replace(@o_string,CHAR(30),'') --control char
	set @o_string = replace(@o_string,CHAR(31),'') --control char

   RETURN @o_string
END

go





 



