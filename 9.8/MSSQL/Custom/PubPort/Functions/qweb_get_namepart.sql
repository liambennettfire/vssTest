SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_namepart]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_namepart]
GO





CREATE FUNCTION dbo.qweb_get_namepart (
	@v_displayname	VARCHAR(80),
	@v_namepart	VARCHAR(1))

RETURNS	VARCHAR(40)

BEGIN

DECLARE @i_indexcount	INT
DECLARE @i_wordlen	INT
DECLARE @v_firstname	VARCHAR(40)
DECLARE @v_middlename	VARCHAR(40)
DECLARE @v_lastname	VARCHAR(40)
DECLARE @v_name		VARCHAR(80)
DECLARE @v_ReturnName	VARCHAR(40)




	SELECT @v_displayname = ltrim(rtrim(dbo.proper_case(@v_displayname)))
	SELECT @i_indexcount = PATINDEX ( '% %' , @v_displayname )
	

-- The section gets a one word name and sets it as a Last Name

	IF @i_indexcount < 1

		SELECT @v_LastName = @v_displayname
	


--This section gets the first name

	IF @i_indexcount > 0
   		BEGIN
   			SELECT @i_WordLen = Datalength(rtrim(ltrim(@v_displayname)))
   			SELECT @v_FirstName = Left(@v_displayname , (@i_indexcount - 1))
   			SELECT @v_name = (Right(@v_displayname,@i_wordlen - (@i_indexcount)))
		
   		

--This section gets the Middle name

			SELECT @i_indexcount = PATINDEX ( '% %' , @v_name )
			IF @i_indexcount > 0
				BEGIN
	       
					SELECT @i_wordlen = Datalength(rtrim(ltrim(@v_name)))
					SELECT @v_middlename = Left(@v_name , (@i_indexcount - 1))
					SELECT @v_lastname = Rtrim(LTrim(Right(@v_name,@i_wordlen - (@i_indexcount - 1))))

		  		END
			

				ELSE
   		-- If No Middle Name set Last Name
   					BEGIN
		       				SELECT @v_middlename = ''
		       				SELECT @v_lastname = lTrim(Rtrim(@v_name))

					END

		END


	IF @v_NamePart = 'F'

		SELECT @v_ReturnName = @v_FirstName

	IF @v_NamePart = 'M'

		SELECT @v_ReturnName = @v_MiddleName

	IF @v_NamePart = 'L'

		SELECT @v_ReturnName = @v_LastName


RETURN @v_ReturnName

END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

