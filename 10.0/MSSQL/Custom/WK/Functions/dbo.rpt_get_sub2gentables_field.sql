if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_sub2gentables_field') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.rpt_get_sub2gentables_field
GO
CREATE FUNCTION dbo.rpt_get_sub2gentables_field
    (@i_tableid as integer,@i_datacode as integer,@i_datasubcode as integer,@i_datasub2code as integer, @i_desctype as varchar) 

RETURNS varchar(255)



/******************************************************************************
**  File: 
**  Name: rpt_get_subgentables_desc
**  Desc: This function returns the sub2gentable value based on @i_desctype parameter:
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
**    Date: 15 FEB 2010
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @v_desc varchar(255)
  DECLARE @RETURN VARCHAR(255)


  SET @v_desc = ''

  IF @i_tableid is null OR @i_tableid <= 0 OR
     @i_datacode is null OR @i_datacode <= 0  OR
     @i_datasubcode is null OR @i_datasubcode <=0 OR
	@i_datasub2code is null OR @i_datasub2code <=0 BEGIN
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

  RETURN @RETURN
END
