IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.qutl_format_string') AND xtype in (N'FN', N'IF', N'TF'))
  DROP FUNCTION dbo.qutl_format_string
GO

CREATE FUNCTION [dbo].[qutl_format_string]  
(  
  @i_value as NUMERIC(20,4),  
  @i_format as VARCHAR(40)  
)  
RETURNS VARCHAR(40)  
  
/***************************************************************************************************************  
**  Name: qutl_format_string  
**  Desc: This function takes 2 input parameters - a float VALUE to be converted to string, and a string FORMAT.  
**        FORMAT is the standard format/edit mask string used in Powerbuilder/Oracle to format numeric values   
**        using the given format style.  
**        Numeric format strings usually consist of the following characters:   
**          # (in Powerbuilder - used here) OR 9 (in Oracle) - Each # or 9 represents a significant digit  
**          0 - Each 0 represents a required digit (leading/trailing zeros would appear instead of blanks)  
**          , - Comma separators  
**          . - Decimal point  
**        Function returns the passed value, formatted as a string according to the format passed.  
**  
**  Auth: Kate Wiewiora  
**  Date: 2 February 2007  
****************************************************************************************************************  
**    Change History  
*******************************************************************************  
**    Date:    Author:     Description:  
**	  2/17/16  Bill Adams  Procedure was deleting zeros that occured after a decimal and before a number   
**		''		''		   ie. '0.08' was formatted as '0.8'. Fix : ADDED in zero while loop... and nullif(@v_tempstring,'') IS NULL  
**    -------- --------    -------------------------------------------  
**     
*******************************************************************************/  
   
BEGIN  
  DECLARE @v_commafound CHAR(1),  
	@v_formatchar CHAR(1),  
	@v_valuechar CHAR(1),  
	@v_pos INT,  
	@v_valuelength INT,  
	@v_formatlength INT,  
	@v_decpos INT,  
	@v_counter INT,  
	@v_fractiondec FLOAT,  
	@v_fractionstr VARCHAR(20),  
	@v_intvaluestr VARCHAR(40),  
	@v_fractionvaluestr VARCHAR(40),  
	@v_intformatstr VARCHAR(40),  
	@v_fractionformatstr VARCHAR(40),  
	@v_formatted_intstr VARCHAR(20),  
	@v_formatted_fractionstr VARCHAR(20),  
	@v_formatted_string VARCHAR(40),  
	@v_tempstring VARCHAR(40),  
	@v_valuestring VARCHAR(40),  
	@v_isNegativeNumber INT  
  
  SET @v_isNegativeNumber = 0  
  /** If NULL value was passed in, return NULL **/  
  IF @i_value IS NULL  
	  RETURN NULL  
  
  /*** If no format was provided, return the passed value as string ***/  
  IF @i_format IS NULL OR RTRIM(@i_format) = ''  
	  SET @i_format = '########'  
	    
  IF @i_value < 0 BEGIN  
	SET @i_value = ABS(@i_value)  
	SET @v_isNegativeNumber = 1  
  END	    
  
  
  /** Separate Integer and Fraction portions of the passed FORMAT **/  
  SET @v_decpos = CHARINDEX('.', @i_format)  
  IF @v_decpos > 0  
	BEGIN  
	  SET @v_intformatstr = SUBSTRING(@i_format, 1, @v_decpos - 1)  
	  SET @v_fractionformatstr = SUBSTRING(@i_format, @v_decpos + 1, 40)  
	END  
  ELSE  
	BEGIN  
	  SET @v_intformatstr = @i_format  
	  SET @v_fractionformatstr = ''  
	END  
  
  /** Separate Integer and Fraction portions of the passed VALUE **/  
  SET @v_valuestring = CAST(@i_value AS VARCHAR(40))  
  SET @v_decpos = CHARINDEX('.', @v_valuestring)  
  IF @v_decpos > 0  
	BEGIN  
	  SET @v_intvaluestr = SUBSTRING(@v_valuestring, 1, @v_decpos - 1)  
	  SET @v_fractionvaluestr = SUBSTRING(@v_valuestring, @v_decpos + 1, 40)  
	END  
  ELSE  
	BEGIN  
	  SET @v_intvaluestr = @v_valuestring  
	  SET @v_fractionvaluestr = ''  
	END  
  
  /** Get rid of trailing zeros in the fraction portion of the VALUE - this is because of the numeric datatype **/  
  /** Reverse the fraction string and work from the end. **/  
  SET @v_fractionvaluestr = REVERSE(@v_fractionvaluestr)  
  SET @v_tempstring = ''  
  SET @v_pos = 1  
  SET @v_valuelength = DATALENGTH(@v_fractionvaluestr)  
  
  WHILE @v_pos <= @v_valuelength  
	BEGIN  
	  /** Get the next VALUE character **/  
	  SET @v_valuechar = SUBSTRING(@v_fractionvaluestr, @v_pos, 1)  
  
	  IF @v_valuechar = '0' and nullif(@v_tempstring,'') IS NULL  
		SET @v_tempstring = @v_tempstring + ''  
	  ELSE  
		SET @v_tempstring = @v_tempstring + @v_valuechar  
  
	  SET @v_pos = @v_pos + 1  
	END  
  
  SET @v_fractionvaluestr = REVERSE(@v_tempstring)  
  
  /********************* INTEGER PORTION PROCESSING **************************/  
  /** Check if a comma was entered in the format string - if so, WE WILL ASSUME AN IMPLIED COMMA SEPARATOR **/  
  /** between each 3 digits in the integer portion of the FORMAT **/  
  IF CHARINDEX(',', @v_intformatstr) > 0  
	SET @v_commafound = 'Y'  
  ELSE  
	SET @v_commafound = 'N'  
  
  /** Reverse the integer portion of the VALUE and FORMAT strings for easier processing **/  
  SET @v_intvaluestr = REVERSE(@v_intvaluestr)  
  SET @v_intformatstr = REVERSE(@v_intformatstr)  
  
  /** Default all variables **/  
  SET @v_counter = 0  
  SET @v_pos = 1  
  SET @v_formatted_intstr = ''  
  SET @v_valuelength = DATALENGTH(@v_intvaluestr)  
  SET @v_formatlength = DATALENGTH(@v_intformatstr)    
  
  /** Loop through the integer portion of the VALUE string to apply format to it **/  
  WHILE @v_pos <= @v_valuelength  
	BEGIN  
	  /** Get the next VALUE character **/  
	  SET @v_valuechar = SUBSTRING(@v_intvaluestr, @v_pos, 1)  
  
	  IF @v_counter = 3 AND @v_commafound = 'Y'  
		BEGIN  
		  SET @v_formatted_intstr = @v_formatted_intstr + ',' + @v_valuechar  
		  SET @v_counter = 0  
		END  
	  ELSE  
		SET @v_formatted_intstr = @v_formatted_intstr + @v_valuechar  
  
	  /** Accumulate the counter and character position **/  
	  SET @v_counter = @v_counter + 1  
	  SET @v_pos = @v_pos + 1  
  	END  
  
  /** If length of FORMAT exceeds length of VALUE string, must check if leading zeros should be added **/  
  SET @v_valuelength = DATALENGTH(@v_intvaluestr)  
  SET @v_formatlength = DATALENGTH(@v_intformatstr)    
  
  IF @v_formatlength > @v_valuelength  
	BEGIN  
	  /** Set the start position at the position just after the length of VALUE string **/  
	  SET @v_pos = @v_valuelength + 1  
  
	  /** Loop through the integer portion of the FORMAT string to add leading zeros, if necessary **/  
	  WHILE @v_pos <= @v_formatlength  
		BEGIN  
		  /** Get the next FORMAT character **/  
		  SET @v_formatchar = SUBSTRING(@v_intformatstr, @v_pos, 1)  
  
		  /** If the next format character is a zero, add a leading zero. Otherwise, ignore and exit **/  
		  IF @v_formatchar = '0'  
			SET @v_formatted_intstr = @v_formatted_intstr + '0'  
		  ELSE  
			BREAK  
  
		  /** Accumulate the character position **/  
		  SET @v_pos = @v_pos + 1  
		END  
	END  
  
  /** Reverse the integer VALUE string back **/  
  SET @v_formatted_intstr = REVERSE(@v_formatted_intstr)  
  
  /** If no fraction exists in the VALUE or FORMAT string, we are done - RETURN **/  
  IF @v_formatlength = 0 AND @v_valuelength = 0 BEGIN  
	  IF @v_isNegativeNumber = 1 BEGIN  
		SET @v_formatted_intstr = '-' + @v_formatted_intstr  
	  END	  
	    
	  RETURN @v_formatted_intstr  
  END	    
  
  /********************* FRACTION PORTION PROCESSING **************************/  
  /** Compare the lengths of FORMAT and VALUE fraction strings. **/  
  /** If the number of decimal places in the VALUE string exceeds the number of decimal places in the FORMAT string, **/  
  /** then we must round the fraction to the number of decimal digits specified in the FORMAT. **/  
  SET @v_valuelength = DATALENGTH(@v_fractionvaluestr)  
  SET @v_formatlength = DATALENGTH(@v_fractionformatstr)    
  
  IF @v_valuelength > @v_formatlength AND @v_formatlength > 0  
	BEGIN  
	  /** Convert the fraction string to a float and round it to the specified number of decimal places **/  
	  SET @v_fractiondec = CAST(('.' + @v_fractionvaluestr) AS FLOAT)  
	  SET @v_fractiondec = ROUND(@v_fractiondec, @v_formatlength)  
  
	  /** Instead of rounding off fraction to 1 (integer), leave 9's in fraction **/  
	  IF @v_fractiondec = 1  
		BEGIN  
		  SET @v_fractionvaluestr = SUBSTRING(@v_fractionvaluestr, 1, @v_formatlength)  
		END  
	  ELSE  
		/** Convert the rounded fraction back to string only if fraction value didn't get rounded off to integer **/  
		BEGIN		  
		  SET @v_fractionstr = CAST(@v_fractiondec AS VARCHAR(20))  
	  	  SET @v_fractionvaluestr = SUBSTRING(@v_fractionstr, CHARINDEX('.', @v_fractionstr) + 1, 20)  
		END  
	END  
  
  /** Reset variables for reuse **/  
  SET @v_pos = 1  
  SET @v_valuelength = DATALENGTH(@v_fractionvaluestr)  
  SET @v_formatlength = DATALENGTH(@v_fractionformatstr)   
  SET @v_formatted_fractionstr = ''  
  
  /** Loop through the fraction portion of the FORMAT string to apply format to the VALUE string **/  
  WHILE @v_pos <= @v_formatlength  
	BEGIN  
	  /** Get the next FORMAT character **/  
	  SET @v_formatchar = SUBSTRING(@v_fractionformatstr, @v_pos, 1)  
  
	  /** Get the next VALUE character **/  
	  IF @v_pos <= @v_valuelength  
		SET @v_valuechar = SUBSTRING(@v_fractionvaluestr, @v_pos, 1)  
	  ELSE  
		SET @v_valuechar = '0'	  /** this will force adding a trailing zero if FORMAT calls for it **/  
  
	  IF @v_formatchar = '0' AND @v_valuechar = '0'  
		SET @v_formatted_fractionstr = @v_formatted_fractionstr + '0'  
	  ELSE  
		SET @v_formatted_fractionstr = @v_formatted_fractionstr + @v_valuechar  
  
	  /** Accumulate the character position **/  
	  SET @v_pos = @v_pos + 1  
  	END  
    
  /** If length of VALUE exceeds length of FORMAT string, must add remaining VALUE fraction digits **/  
  IF @v_valuelength > @v_formatlength  
	BEGIN  
	  /** Set the start position at the position just after the length of FORMAT string **/  
	  SET @v_pos = @v_formatlength + 1  
  
	  /** Loop through the fraction portion of the VALUE string to add trailing zeros, if necessary **/  
	  WHILE @v_pos <= @v_valuelength  
		BEGIN  
		  /** Get the next VALUE character **/  
		  SET @v_valuechar = SUBSTRING(@v_fractionvaluestr, @v_pos, 1)  
  
		  /** Add this VALUE fraction digit character to the formatted fraction string **/  
		  SET @v_formatted_fractionstr = @v_formatted_fractionstr + @v_valuechar  
  
		  /** Accumulate the character position **/  
		  SET @v_pos = @v_pos + 1  
		END  
	END  
  
  /*********** BUILD THE FORMATTED STRING VALUE AND RETURN *************/  
  IF @v_formatted_fractionstr IS NULL OR @v_formatted_fractionstr = ''  
    SET @v_formatted_string = @v_formatted_intstr  
  ELSE  
    SET @v_formatted_string = @v_formatted_intstr + '.' + @v_formatted_fractionstr  
      
  IF @v_isNegativeNumber = 1 BEGIN  
	SET @v_formatted_string = '-' + @v_formatted_string  
  END      
  
  RETURN @v_formatted_string  
  
END  
GO

GRANT EXEC ON dbo.qutl_format_string TO public
GO