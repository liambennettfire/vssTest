GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_sub2gentables_field]    Script Date: 12/09/2014 09:49:14 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_sub2gentables_field]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_sub2gentables_field]
GO

GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_sub2gentables_field]    Script Date: 12/09/2014 09:49:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



Create FUNCTION [dbo].[rpt_get_sub2gentables_field]
    ( @i_tableid as integer,@i_datacode as integer, @i_datasubcode as integer,@i_datasub2code as integer,@i_desctype as varchar) 

RETURNS varchar(255)

/******************************************************************************
**  File: 
**  Name: rpt_get_gentables_desc
**  Desc: This function returns the gentable value based on @i_desctype parameter:
**    
**		@i_desctype Parameter Options
**		D = Data Description
**		E = External code
**		S = Short Description
**		B = BISAC Data Code
**		T = Eloquence Field Tag
**		1 = Alternative Description 1
**		2 = Alternative Deccription 2
**      Q = Export to eloquence Indicator
**
**
**    Auth: Tolga Tuncer
**    Date: 05 FEB 2010
**    Editor: Navroop Singh
	  Date: 12/9/2014

*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @RETURN				VARCHAR(255)
  DECLARE @v_desc       VARCHAR(255)
  

  SET @v_desc = ''

  IF @i_tableid is null OR @i_tableid <= 0 OR
     @i_datacode is null OR @i_datacode <= 0 or
     @i_datasubcode is null OR @i_datasubcode <= 0 
     BEGIN
     RETURN ''
  END

  IF @i_desctype = 'D'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(datadesc))
			FROM	sub2gentables  
			WHERE  tableid = @i_tableid
					AND datacode = @i_datacode
					AND datasubcode = @i_datasubcode
					AND datasub2code = @i_datasub2code
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @i_desctype = 'E'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(externalcode))
			FROM	sub2gentables  
			WHERE  tableid = @i_tableid
					AND datacode = @i_datacode
					AND datasubcode = @i_datasubcode
					AND datasub2code = @i_datasub2code
			
						IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @i_desctype = 'S'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(datadescshort))
			FROM	sub2gentables  
			WHERE  tableid = @i_tableid
					AND datacode = @i_datacode
					AND datasubcode = @i_datasubcode
					AND datasub2code = @i_datasub2code
								
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @i_desctype = 'B'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(bisacdatacode))
			FROM	sub2gentables  
			WHERE  tableid = @i_tableid
					AND datacode = @i_datacode
					AND datasubcode = @i_datasubcode
					AND datasub2code = @i_datasub2code
			
					
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @i_desctype = '1'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(alternatedesc1))
			FROM	sub2gentables  
			WHERE  tableid = @i_tableid
					AND datacode = @i_datacode
					AND datasubcode = @i_datasubcode
					AND datasub2code = @i_datasub2code
			
					
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END

	ELSE IF @i_desctype = '2'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(alternatedesc2))
			FROM	sub2gentables  
			WHERE  tableid = @i_tableid
					AND datacode = @i_datacode
					AND datasubcode = @i_datasubcode
					AND datasub2code = @i_datasub2code
			
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END
	ELSE IF @i_desctype = 'T'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(eloquencefieldtag))
			FROM	sub2gentables  
			WHERE  tableid = @i_tableid
					AND datacode = @i_datacode
					AND datasubcode = @i_datasubcode
					AND datasub2code = @i_datasub2code
			
					
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END
	ELSE IF @i_desctype = 'Q'
		BEGIN
			SELECT @v_desc = cast (exporteloquenceind as varchar(1))
			FROM	sub2gentables  
			WHERE  tableid = @i_tableid
					AND datacode = @i_datacode
					AND datasubcode = @i_datasubcode
					AND datasub2code = @i_datasub2code
			
			
			IF @v_desc = '1'
				BEGIN
					SELECT @RETURN = 'Y'
				END
			ELSE
				BEGIN
					SELECT @RETURN = 'N'
				END
		END


  IF @i_desctype = 'N'
		BEGIN
			SELECT @v_desc = ltrim(rtrim(numericdesc1))
			FROM	sub2gentables  
			WHERE  tableid = @i_tableid
					AND datacode = @i_datacode
					AND datasubcode = @i_datasubcode
					AND datasub2code = @i_datasub2code
								
			IF datalength(@v_desc) > 0
				BEGIN
					SELECT @RETURN = @v_desc
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
		END
RETURN @RETURN

END


GO

grant all on [rpt_get_sub2gentables_field] to public