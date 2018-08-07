if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_misc_value_gentable') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.rpt_get_misc_value_gentable
GO


CREATE FUNCTION dbo.rpt_get_misc_value_gentable
(
  @i_bookkey as integer,
  @v_misckey as integer,
  @v_datacode as int,
  @c_desctype as varchar (10)
) 
RETURNS VARCHAR(255)

/******************************************************************************
**  Name: rpt_get_misc_value_gentable
**  Desc: This function returns the gentabled miscellaneous item value based on
**        Bookkey and MiscKey passed
**        Field Type is only used for gentables values - which column is desired
**        c_desctype = 'long' or empty --> return datadesc
**        c_desctype = 'short' --> return datadescshort
**        c_desctype = 'external' --> return externalcode
**        c_desctype = 'altdesc1' --> return alternatedesc1
**        c_desctype = 'altdesc2' --> return alternatedesc2

**
**  Auth: Tolga Tuncer
**  Date: 17 February 2012
*******************************************************************************/



BEGIN
 
DECLARE @Return VARCHAR(255)
SET @Return = ''

	IF @c_desctype = 'long' or @c_desctype = '' or @c_desctype is null
		BEGIN
			Select @Return = datadesc 
			from bookmisc bm 
			join subgentables s
			on bm.longvalue = s.datasubcode 
			where bm.bookkey = @i_bookkey and bm.misckey = @v_misckey and s.tableid = 525 and s.datacode = @v_datacode
		END
	else if @c_desctype = 'short'
		begin
			SELECT @Return = datadescshort
			from bookmisc bm 
			join subgentables s
			on bm.longvalue = s.datasubcode 
			where bm.bookkey = @i_bookkey and bm.misckey = @v_misckey and s.tableid = 525 and s.datacode = @v_datacode
		end
	else if @c_desctype = 'external'
		begin
			SELECT @Return = externalcode
			from bookmisc bm 
			join subgentables s
			on bm.longvalue = s.datasubcode 
			where bm.bookkey = @i_bookkey and bm.misckey = @v_misckey and s.tableid = 525 and s.datacode = @v_datacode
		end
	else if @c_desctype = 'altdesc1'
		begin
			SELECT @Return = alternatedesc1
			from bookmisc bm 
			join subgentables s
			on bm.longvalue = s.datasubcode 
			where bm.bookkey = @i_bookkey and bm.misckey = @v_misckey and s.tableid = 525 and s.datacode = @v_datacode
		end          
	    
	else if @c_desctype = 'altdesc2'
		begin
			SELECT @Return = alternatedesc2
			from bookmisc bm 
			join subgentables s
			on bm.longvalue = s.datasubcode 
			where bm.bookkey = @i_bookkey and bm.misckey = @v_misckey and s.tableid = 525 and s.datacode = @v_datacode
		end  



If @Return is NULL 
	SET @Return = ''
  
RETURN @Return
  
END
GO
GRANT EXEC ON dbo.rpt_get_misc_value_gentable TO PUBLIC
GO