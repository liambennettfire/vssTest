SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_FormatBorders]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_FormatBorders]
GO






CREATE FUNCTION dbo.qweb_get_FormatBorders 
			(@i_bookkey	INT)


RETURNS	VARCHAR (2)

/*  The purpose of the qweb_get_FormatBorders function is to return a specific format for the BORDERS e-cat spreadsheet
     the results of this function will be placed in the 'category' column on the spreadsheet  


	
*/
AS

BEGIN

	DECLARE @RETURN			VARCHAR(2)
	DECLARE @v_desc			VARCHAR(2)
	DECLARE @v_formatdesc		VARCHAR(40)



/*  GET  format 	*/
	
	SELECT 	 @v_formatdesc = dbo.qweb_get_Format(@i_bookkey, 'B')

	IF @v_formatdesc is NULL
		BEGIN
			SELECT @v_desc = ''
		END
	ELSE
		BEGIN

		/* TRANSLATE TO BORDERS SPECS */

		IF (LTRIM(RTRIM(@v_formatdesc)) = 'SS')
		OR (LTRIM(RTRIM(@v_formatdesc)) = 'TC')
		OR (LTRIM(RTRIM(@v_formatdesc)) = 'SC')
		OR (LTRIM(RTRIM(@v_formatdesc)) = 'LB')
		OR (LTRIM(RTRIM(@v_formatdesc)) = 'LE')
		OR (LTRIM(RTRIM(@v_formatdesc)) = 'RL')
		OR (LTRIM(RTRIM(@v_formatdesc)) = 'BL')
		OR (LTRIM(RTRIM(@v_formatdesc)) = 'CT')
		   BEGIN
			SELECT @v_desc = 'CL'
		   END
		ELSE IF (LTRIM(RTRIM(@v_formatdesc)) = 'TP')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'PT')
		        BEGIN
         		 	SELECT @v_desc = 'QP'
		        END
		ELSE IF (LTRIM(RTRIM(@v_formatdesc)) = 'ST')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'MI')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'FB')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'BD')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'PO')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'BA')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'WC')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'VB')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'DE')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'FF')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'CB')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'FU')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'SP')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'MO')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'BI')
		        BEGIN
         		 	SELECT @v_desc = 'JU'
		        END
		ELSE IF (LTRIM(RTRIM(@v_formatdesc)) = 'MM')
		        BEGIN
         		 	SELECT @v_desc = 'MM'
		        END
		ELSE IF (LTRIM(RTRIM(@v_formatdesc)) = 'TY')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'MU')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'PL')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'OO')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'DL')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'MX')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'BZ')
		        BEGIN
         		 	SELECT @v_desc = 'MU'
		        END
		ELSE IF (LTRIM(RTRIM(@v_formatdesc)) = 'BG')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'ZZ')
		        BEGIN
         		 	SELECT @v_desc = 'SL'
		        END
		ELSE IF (LTRIM(RTRIM(@v_formatdesc)) = 'DA')
	             OR (LTRIM(RTRIM(@v_formatdesc)) = 'AA')
		        BEGIN
         		 	SELECT @v_desc = 'TA'
		        END
		ELSE IF (LTRIM(RTRIM(@v_formatdesc)) = 'CD')
		        BEGIN
         		 	SELECT @v_desc = 'CD'
		        END
		ELSE 
		        BEGIN
         		 	SELECT @v_desc = ''
		        END



		END
	
	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = UPPER(LTRIM(RTRIM(@v_desc)))
		END

	ELSE
		BEGIN
			SELECT @RETURN = ''
		END




RETURN @RETURN


END







GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

