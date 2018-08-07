/****** Object:  UserDefinedFunction [dbo].[qpl_get_format_totalrequiredqty]    Script Date: 01/11/2015 15:40:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_get_specitem_value]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[qpl_get_specitem_value]
GO

/****** Object:  UserDefinedFunction [dbo].[[qpl_get_specitem_value]]    Script Date: 01/11/2015 15:40:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE FUNCTION [dbo].[qpl_get_specitem_value]
(  
  @i_bookkey int,
  @i_printingkey int,
  @i_itemcategorycode int,
  @i_itemcode int,
  @v_valuetype varchar(10)
)
RETURNS varchar(255)

/* will return the specitemvalue for the the passed projectkey for the selected version*/

BEGIN

  DECLARE
  @v_value varchar(255),
  @i_projectkey int,
  @i_selectedversionkey int,
  @i_numericvalue int
  
  --get the projectkey for the printing
  select @i_projectkey = taqprojectkey from taqprojecttitle where bookkey=@i_bookkey and printingkey=@i_printingkey and titlerolecode=9 and projectrolecode=5
  
  --get the selectedversionkey
  select @i_selectedversionkey = [dbo].[qpl_get_selected_version] (@i_projectkey)
  
  IF @v_valuetype in ('Q','DT','DT2','DEC','U')
	begin
		begin
		IF @v_valuetype = 'Q'
			select @i_numericvalue = i.quantity from taqversionspecitems i inner join taqversionspeccategory c on i.taqversionspecategorykey = c.taqversionspecategorykey
			and i.itemcode=@i_itemcode and c.itemcategorycode=@i_itemcategorycode and c.taqprojectkey=@i_projectkey and c.taqversionkey=@i_selectedversionkey
		IF @v_valuetype = 'DEC'
			select @i_numericvalue = i.decimalvalue from taqversionspecitems i inner join taqversionspeccategory c on i.taqversionspecategorykey = c.taqversionspecategorykey
			and i.itemcode=@i_itemcode and c.itemcategorycode=@i_itemcategorycode and c.taqprojectkey=@i_projectkey and c.taqversionkey=@i_selectedversionkey
		IF @v_valuetype = 'DT'
			select @i_numericvalue = i.itemdetailcode from taqversionspecitems i inner join taqversionspeccategory c on i.taqversionspecategorykey = c.taqversionspecategorykey
			and i.itemcode=@i_itemcode and c.itemcategorycode=@i_itemcategorycode and c.taqprojectkey=@i_projectkey and c.taqversionkey=@i_selectedversionkey
		IF @v_valuetype = 'DT2'
			select @i_numericvalue = i.itemdetailsubcode from taqversionspecitems i inner join taqversionspeccategory c on i.taqversionspecategorykey = c.taqversionspecategorykey
			and i.itemcode=@i_itemcode and c.itemcategorycode=@i_itemcategorycode and c.taqprojectkey=@i_projectkey and c.taqversionkey=@i_selectedversionkey
		IF @v_valuetype = 'U'
			select @i_numericvalue = i.unitofmeasurecode from taqversionspecitems i inner join taqversionspeccategory c on i.taqversionspecategorykey = c.taqversionspecategorykey
			and i.itemcode=@i_itemcode and c.itemcategorycode=@i_itemcategorycode and c.taqprojectkey=@i_projectkey and c.taqversionkey=@i_selectedversionkey	
		end
		
		select @v_value = CAST(@i_numericvalue as varchar(255))
  	end
  	
  IF @v_valuetype in ('D','D2')
	begin
  		IF @v_valuetype = 'D'
			select @v_value = i.description from taqversionspecitems i inner join taqversionspeccategory c on i.taqversionspecategorykey = c.taqversionspecategorykey
			and i.itemcode=@i_itemcode and c.itemcategorycode=@i_itemcategorycode and c.taqprojectkey=@i_projectkey and c.taqversionkey=@i_selectedversionkey
		IF @v_valuetype = 'D2'
			select @v_value = i.description2 from taqversionspecitems i inner join taqversionspeccategory c on i.taqversionspecategorykey = c.taqversionspecategorykey
			and i.itemcode=@i_itemcode and c.itemcategorycode=@i_itemcategorycode and c.taqprojectkey=@i_projectkey and c.taqversionkey=@i_selectedversionkey
  	end
   
  RETURN @v_value
  
END

GO

GRANT exec on [dbo].[qpl_get_specitem_value] to public
go


