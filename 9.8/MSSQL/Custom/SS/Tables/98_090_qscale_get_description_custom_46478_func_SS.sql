if exists (select * from dbo.sysobjects where id = object_id(N'dbo.get_description_custom') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.get_description_custom
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE FUNCTION [dbo].[get_description_custom] (@i_taqversionformatyearkey as integer, @i_qsicode as integer) 
RETURNS VARCHAR(4000)
AS
  
BEGIN
	
	DECLARE @v_desc VARCHAR(4000)

	SET @v_desc = ''
  
  	declare @pages int = 0			-- page count
	declare @paper_bulk int = 0		-- pages per inch

	if @i_qsicode=10013				-- Book Bulk
		begin

			set @pages = 0			-- page count
			select @pages = [dbo].[get_quantity] (@i_taqversionformatyearkey, 2)

			select top 1 @paper_bulk = isnull(c.quantity,0)	
			from taqversionformatyear a
				join taqversionspeccategory b on a.taqprojectkey=b.taqprojectkey and a.plstagecode=b.plstagecode and a.taqversionkey=b.taqversionkey
				join taqversionspecitems c on b.taqversionspecategorykey=c.taqversionspecategorykey
				join subgentables d on d.tableid=616 and b.itemcategorycode=d.datacode and c.itemcode=d.datasubcode and d.qsicode=10005
			 where 1=1
			 and a.taqversionformatyearkey=@i_taqversionformatyearkey
			 order by b.sortorder, b.taqversionspecategorykey

			if ((@pages=0) or (@paper_bulk=0))
				begin
					set @v_desc=''
				end
			else
				begin
					set @v_desc=dbo.ufn_util$decimal_to_fraction(convert(decimal(10,5),@pages)/convert(decimal(10,5),@paper_bulk))
				end
		end

	if @i_qsicode=10052				-- [Printing Type] 1st printing or reprint
		begin

			select @v_desc = case a.printingnumber when 1 then '1st Printing' else 'Reprint' end
			from taqversionformatyear a
			where 1=1
			and a.taqversionformatyearkey=@i_taqversionformatyearkey

		end


 
	RETURN @v_desc
   
END


GO