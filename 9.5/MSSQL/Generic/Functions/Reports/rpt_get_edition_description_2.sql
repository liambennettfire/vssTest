if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_edition_description_2') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.rpt_get_edition_description_2
GO

CREATE FUNCTION dbo.rpt_get_edition_description_2
			(@i_bookkey	INT
			 )

RETURNS	VARCHAR(120)

/*  
Created by Tolga Tuncer 2013/01/18

The purpose of the ips_rpt_get_edition_description functions is to return a value for editiondescription based on editioncode, editionnumber and additionaleditinfo.

This function returns edition description just like TM web does. 

Edition Number descriptions are pulled from Alternate Description 1
Edition is retrieved from Description. 


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
					SELECT @v_edition = dbo.rpt_get_edition(@i_bookkey, 'D')
					SELECT @v_edition_number = dbo.rpt_get_edition_number(@i_bookkey, '1')
					SELECT @v_edition_add_info = additionaleditinfo
						FROM bookdetail
						WHERE bookkey = @i_bookkey
	
		 
					SELECT @v_desc =  
						CASE 
							WHEN @v_edition_number IS NULL THEN  ''
							WHEN @v_edition_number = '' THEN ''
							WHEN @v_edition_number IS NOT NULL or @v_edition_number <> ''
								THEN @v_edition_number
            						ELSE ''
          					END
						
						+CASE
							WHEN ISNULL(@v_edition_number,'') <> '' and ISNULL(@v_edition,'') <> ''
								THEN ', ' 
									ELSE ''
							END

						+ CASE 
							WHEN @v_edition IS  NULL THEN ''
							WHEN @v_edition = '' THEN ''
							WHEN @v_edition IS NOT NULL or @v_edition <> '' and @v_desc = ''
								THEN @v_edition
									ELSE ''
	          				END

						+CASE
							WHEN (ISNULL(@v_edition_number,'') <> '' or ISNULL(@v_edition,'') <> '') 
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
GO
GRANT EXECUTE ON dbo.rpt_get_edition_description_2 TO PUBLIC 

