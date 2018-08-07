IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'xml_escape_element_value')
	BEGIN
		PRINT 'Dropping Procedure xml_escape_element_value'
		DROP  Procedure  xml_escape_element_value
	END

GO

PRINT 'Creating Procedure xml_escape_element_value'
GO
CREATE Procedure xml_escape_element_value
	/* Param List */
    @elementAsText text = null
AS

/******************************************************************************
**		File: 
**		Name: xml_escape_element_value
**		Desc: This stored procedure is a building block
**            for doing xml development.  It takes in a text
**            string and returns a text string.  The values 
**            to the length currently supported, have been
**            changes so that they can be ouput as part of
**            an XML element value.  (See return value description below.)
**            
**
**              
**		Return values:
**
**              returns a text type with all of the 
**              '&' replaced by '&amp;' and '<' with '&lt;'.
** 
**
**		Auth: James P. Weber
**		Date: 25 Feb 2003
*******************************************************************************
**		Change History
*******************************************************************************
**		Date:		Author:				Description:
**		--------	--------			-------------------------------------------
**      
*******************************************************************************/

    DECLARE @c_tempstring   varchar (8000)
    DECLARE @c_tempstring01 varchar (8000)
    DECLARE @c_tempstring02 varchar (8000)
    DECLARE @c_tempstring03 varchar (8000)
    DECLARE @c_tempstring04 varchar (8000)
    DECLARE @c_tempstring05 varchar (8000)
    DECLARE @c_tempstring06 varchar (8000)
    DECLARE @c_tempstring07 varchar (8000)
    DECLARE @c_tempstring08 varchar (8000)
    DECLARE @c_tempstring09 varchar (8000)
    DECLARE @c_tempstring10 varchar (8000)
    DECLARE @c_tempstring11 varchar (8000)
    DECLARE @c_tempstring12 varchar (8000)
    DECLARE @c_tempstring13 varchar (8000)
    DECLARE @c_tempstring14 varchar (8000)
    DECLARE @c_tempstring15 varchar (8000)
    DECLARE @c_tempstring16 varchar (8000)
    DECLARE @c_tempstring17 varchar (8000)
    DECLARE @c_tempstring18 varchar (8000)
    DECLARE @c_tempstring19 varchar (8000)
    DECLARE @c_tempstring20 varchar (8000)
    DECLARE @c_tempstring21 varchar (8000)
    DECLARE @c_tempstring22 varchar (8000)
    DECLARE @c_tempstring23 varchar (8000)
    DECLARE @c_tempstring24 varchar (8000)
    DECLARE @c_tempstring25 varchar (8000)
    DECLARE @c_tempstring26 varchar (8000)
    DECLARE @c_tempstring27 varchar (8000)
    DECLARE @c_tempstring28 varchar (8000)
    DECLARE @c_tempstring29 varchar (8000)
    DECLARE @c_tempstring30 varchar (8000)
    DECLARE @c_tempstring31 varchar (8000)
    DECLARE @c_tempstring32 varchar (8000)
    DECLARE @c_tempstring33 varchar (8000)
    DECLARE @c_tempstring34 varchar (8000)
    DECLARE @c_tempstring35 varchar (8000)
    DECLARE @c_tempstring36 varchar (8000)
    DECLARE @c_tempstring37 varchar (8000)
    DECLARE @c_tempstring38 varchar (8000)
    DECLARE @c_tempstring39 varchar (8000)
    DECLARE @c_tempstring40 varchar (8000)


    SET @c_tempstring = replace (substring (@elementAsText,     1, 1600), '&','&amp;')
    SET @c_tempstring01 = replace (@c_tempstring, '<','&lt;')

    SET @c_tempstring = replace (substring (@elementAsText,  1601, 1600), '&','&amp;')
    SET @c_tempstring02 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText,  3201, 1600), '&','&amp;')
    SET @c_tempstring03 = replace (@c_tempstring, '<','&lt;')

    SET @c_tempstring = replace (substring (@elementAsText,  4801, 1600), '&','&amp;')
    SET @c_tempstring04 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText,  6401, 1600), '&','&amp;')
    SET @c_tempstring05 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText,  8001, 1600), '&','&amp;')
    SET @c_tempstring06 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText,  9601, 1600), '&','&amp;')
    SET @c_tempstring07 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 11201, 1600), '&','&amp;')
    SET @c_tempstring08 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 12801, 1600), '&','&amp;')
    SET @c_tempstring09 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 14401, 1600), '&','&amp;')
    SET @c_tempstring10 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 16001, 1600), '&','&amp;')
    SET @c_tempstring11 = replace (@c_tempstring, '<','&lt;')

    SET @c_tempstring = replace (substring (@elementAsText, 17601, 1600), '&','&amp;')
    SET @c_tempstring12 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 19201, 1600), '&','&amp;')
    SET @c_tempstring13 = replace (@c_tempstring, '<','&lt;')

    SET @c_tempstring = replace (substring (@elementAsText, 20801, 1600), '&','&amp;')
    SET @c_tempstring14 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 22401, 1600), '&','&amp;')
    SET @c_tempstring15 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 24001, 1600), '&','&amp;')
    SET @c_tempstring16 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 25601, 1600), '&','&amp;')
    SET @c_tempstring17 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 27201, 1600), '&','&amp;')
    SET @c_tempstring18 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 28801, 1600), '&','&amp;')
    SET @c_tempstring19 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 30401, 1600), '&','&amp;')
    SET @c_tempstring20 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 32001, 1600), '&','&amp;')
    SET @c_tempstring21 = replace (@c_tempstring, '<','&lt;')

    SET @c_tempstring = replace (substring (@elementAsText, 33601, 1600), '&','&amp;')
    SET @c_tempstring22 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 35201, 1600), '&','&amp;')
    SET @c_tempstring23 = replace (@c_tempstring, '<','&lt;')

    SET @c_tempstring = replace (substring (@elementAsText, 36801, 1600), '&','&amp;')
    SET @c_tempstring24 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 38401, 1600), '&','&amp;')
    SET @c_tempstring25 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 40001, 1600), '&','&amp;')
    SET @c_tempstring26 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 41601, 1600), '&','&amp;')
    SET @c_tempstring27 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 43201, 1600), '&','&amp;')
    SET @c_tempstring28 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 44801, 1600), '&','&amp;')
    SET @c_tempstring29 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 46401, 1600), '&','&amp;')
    SET @c_tempstring30 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 48001, 1600), '&','&amp;')
    SET @c_tempstring31 = replace (@c_tempstring, '<','&lt;')

    SET @c_tempstring = replace (substring (@elementAsText, 49601, 1600), '&','&amp;')
    SET @c_tempstring32 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 51201, 1600), '&','&amp;')
    SET @c_tempstring33 = replace (@c_tempstring, '<','&lt;')

    SET @c_tempstring = replace (substring (@elementAsText, 52801, 1600), '&','&amp;')
    SET @c_tempstring34 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 54401, 1600), '&','&amp;')
    SET @c_tempstring35 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 56001, 1600), '&','&amp;')
    SET @c_tempstring36 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 57601, 1600), '&','&amp;')
    SET @c_tempstring37 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 59201, 1600), '&','&amp;')
    SET @c_tempstring38 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 60801, 1600), '&','&amp;')
    SET @c_tempstring39 = replace (@c_tempstring, '<','&lt;')
    
    SET @c_tempstring = replace (substring (@elementAsText, 62401, 1600), '&','&amp;')
    SET @c_tempstring40 = replace (@c_tempstring, '<','&lt;')
 
--    print @c_tempstring01 +  @c_tempstring02 +  @c_tempstring03 +  @c_tempstring04 +  @c_tempstring05 +  @c_tempstring06 +  @c_tempstring07 +  @c_tempstring08 +  @c_tempstring09  +  @c_tempstring10 +  @c_tempstring11 +  @c_tempstring12 +  @c_tempstring13 +  @c_tempstring14 +  @c_tempstring15 +  @c_tempstring16 +  @c_tempstring17 +  @c_tempstring18 +  @c_tempstring19 +  @c_tempstring20 +  @c_tempstring21 +  @c_tempstring22 +  @c_tempstring23 +  @c_tempstring24 +  @c_tempstring25 +  @c_tempstring26 +  @c_tempstring27 +  @c_tempstring28 +  @c_tempstring29 +  @c_tempstring30 +  @c_tempstring31 +  @c_tempstring32 +  @c_tempstring33 +  @c_tempstring34 +  @c_tempstring35 +  @c_tempstring36 +  @c_tempstring37 +  @c_tempstring38 +  @c_tempstring39 +  @c_tempstring40 
    select CAST(@c_tempstring01 +  @c_tempstring02 +  @c_tempstring03 +  @c_tempstring04 +  @c_tempstring05 +  @c_tempstring06 +  @c_tempstring07 +  @c_tempstring08 +  @c_tempstring09  +  @c_tempstring10 +  @c_tempstring11 +  @c_tempstring12 +  @c_tempstring13 +  @c_tempstring14 +  @c_tempstring15 +  @c_tempstring16 +  @c_tempstring17 +  @c_tempstring18 +  @c_tempstring19 +  @c_tempstring20 +  @c_tempstring21 +  @c_tempstring22 +  @c_tempstring23 +  @c_tempstring24 +  @c_tempstring25 +  @c_tempstring26 +  @c_tempstring27 +  @c_tempstring28 +  @c_tempstring29 +  @c_tempstring30 +  @c_tempstring31 +  @c_tempstring32 +  @c_tempstring33 +  @c_tempstring34 +  @c_tempstring35 +  @c_tempstring36 +  @c_tempstring37 +  @c_tempstring38 +  @c_tempstring39 +  @c_tempstring40 As text)


GO

GRANT EXEC ON xml_escape_element_value TO PUBLIC

GO
