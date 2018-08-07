if exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_edition_description') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function rpt_get_edition_description
GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_edition_description]    Script Date: 10/08/2010 12:58:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE FUNCTION [dbo].[rpt_get_edition_description] 
			(@i_bookkey	INT,
			 @v_column varchar(1))

RETURNS	VARCHAR(120)

/*  
Created by Ben Todd and Paul Milana 2010/10/08

The purpose of the ips_rpt_get_edition_description functions is to return a value for editiondescription based on editioncode, editionnumber and additionaleditinfo.

Parameters

@v_column
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2

*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(500)
	DECLARE @v_desc			VARCHAR(500)
	DECLARE @v_edition		varchar(120)		
	DECLARE @v_edition_number		VARCHAR(120)
	DECLARE @v_edition_add_info		VARCHAR(120)


/* GET AUTHOR NAME		*/


/* Begin Edition Procedure */

				BEGIN
					SELECT @v_edition = dbo.rpt_get_edition(@i_bookkey, @v_column)
					SELECT @v_edition_number = dbo.rpt_get_edition_number(@i_bookkey, @v_column)
					SELECT @v_edition_add_info = additionaleditinfo
						FROM bookdetail
						WHERE bookkey = @i_bookkey
	
		 
					SELECT @v_desc =  
						CASE 
							WHEN @v_edition IS NULL THEN  ''
							WHEN @v_edition = '' THEN ''
							WHEN @v_edition IS NOT NULL or @v_edition <> ''
								THEN @v_edition
            						ELSE ''
          					END
						
						+CASE
							WHEN ISNULL(@v_edition,'') <> '' and ISNULL(@v_edition_number,'') <> ''
								THEN ', ' 
									ELSE ''
							END

						+CASE 
							WHEN @v_edition_number IS  NULL THEN ''
							WHEN @v_edition_number = '' THEN ''
							WHEN @v_edition_number IS NOT NULL or @v_edition_number <> '' and @v_desc = ''
								THEN @v_edition_number
									ELSE ''
	          				END

						+CASE
							WHEN (ISNULL(@v_edition,'') <> '' or ISNULL(@v_edition_number,'') <> '') 
								and (ISNULL(@v_edition_add_info,'') <> '')
								THEN ', ' 
									ELSE ''
							END

						+CASE 
							WHEN @v_edition_add_info IS  NULL THEN ''
							WHEN @v_edition_add_info = '' THEN ''
							WHEN @v_edition_add_info IS NOT NULL or @v_edition_add_info <> '' and @v_desc = ''
								THEN @v_edition_add_info
            						ELSE ''
	          				END

			
				END

		IF LEN(@v_desc) > 0
			BEGIN
				SELECT @RETURN = LTRIM(RTRIM(@v_desc))
			END

			ELSE
				BEGIN
					SELECT @RETURN = ''
				END




RETURN @RETURN


END

