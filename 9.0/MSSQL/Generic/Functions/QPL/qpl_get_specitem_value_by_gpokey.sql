/****** Object:  UserDefinedFunction [dbo].[qpl_get_specitem_value_by_gpokey]    Script Date: 04/06/2015 12:02:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_get_specitem_value_by_gpokey]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[qpl_get_specitem_value_by_gpokey]
GO

/****** Object:  UserDefinedFunction [dbo].[qpl_get_specitem_value_by_gpokey]    Script Date: 04/06/2015 12:02:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE FUNCTION [dbo].[qpl_get_specitem_value_by_gpokey]
(  
  @i_gpokey int,
  @i_itemcategorycode int,
  @i_itemcode int,
  @v_valuetype varchar(10)
)
RETURNS varchar(255)

/* will return the specitemvalue for the the passed projectkey for the selected version for the gpo*/

BEGIN

  DECLARE
  @v_value varchar(255),
  @i_projectkey int,
  @i_selectedversionkey int,
  @i_numericvalue int,
  @i_printingprojectkey int,
  @i_posummarykey int,
  @i_isrelated int
  
  
  --get the projectkey for the printing
  select @i_printingprojectkey = taqprojectkey1 from taqprojectrelationship where taqprojectkey2=@i_gpokey and relationshipcode1=16 and relationshipcode2=17 
  
  --get the projectkey for the po
  select @i_posummarykey = taqprojectkey2 from taqprojectrelationship where taqprojectkey1=@i_gpokey and relationshipcode1=15 and relationshipcode2=14 
  
  --evaluate where the value is being stored, could be on either the PO or the printing based on the relatedspeccategorykey
  select @i_isrelated = relatedspeccategorykey from taqversionspeccategory where taqprojectkey=@i_posummarykey and itemcategorycode=@i_itemcategorycode
  
  IF coalesce(@i_isrelated,0)<>0
	select @i_projectkey = @i_printingprojectkey
  ELSE
  	select @i_projectkey = @i_posummarykey		
  
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


GRANT exec ON [dbo].[qpl_get_specitem_value_by_gpokey] to PUBLIC
go