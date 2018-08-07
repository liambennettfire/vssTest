/****** Object:  UserDefinedFunction [dbo].rpt_taq_pl_priceby_formatyear    Script Date: 04/13/2010 10:06:45 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].rpt_taq_pl_priceby_formatyear') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].rpt_taq_pl_priceby_formatyear
GO
CREATE FUNCTION [dbo].rpt_taq_pl_priceby_formatyear
   (@i_taqprojectkey int, @i_plstagecode int, @i_taqversionkey int, @i_yearcode int, @v_mediatype varchar(255))
    
RETURNS FLOAT

BEGIN 
  DECLARE @f_activeprice float
BEGIN
If @v_mediatype = 'HC List Price' begin
Select @f_activeprice = f.activeprice
	from taqversionformat f, taqversionformatyear y
	where f.taqprojectkey = y.taqprojectkey
	and f.plstagecode = y.plstagecode
	and f.taqversionkey = y.taqversionkey
	and f.taqprojectformatkey = y.taqprojectformatkey
	and f.plstagecode = @i_plstagecode
	and f.taqversionkey = @i_taqversionkey
	and y.yearcode = @i_yearcode
	and f.mediatypecode = 2
	and f.mediatypesubcode in (6,26)   
	and f.taqprojectkey = @i_taqprojectkey
end
If @v_mediatype = 'PB List Price' begin
Select @f_activeprice = f.activeprice
	from taqversionformat f, taqversionformatyear y
	where f.taqprojectkey = y.taqprojectkey
	and f.plstagecode = y.plstagecode
	and f.taqversionkey = y.taqversionkey
	and f.taqprojectformatkey = y.taqprojectformatkey
	and f.plstagecode = @i_plstagecode
	and f.taqversionkey = @i_taqversionkey
	and y.yearcode = @i_yearcode
	and f.mediatypecode = 2
	and f.mediatypesubcode in (20,27)   
	and f.taqprojectkey = @i_taqprojectkey
end
If @v_mediatype = 'Ebook List Price' begin
Select @f_activeprice = f.activeprice
	from taqversionformat f, taqversionformatyear y
	where f.taqprojectkey = y.taqprojectkey
	and f.plstagecode = y.plstagecode
	and f.taqversionkey = y.taqversionkey
	and f.taqprojectformatkey = y.taqprojectformatkey
	and f.plstagecode = @i_plstagecode
	and f.taqversionkey = @i_taqversionkey
	and y.yearcode = @i_yearcode
	and f.mediatypecode = 4
	and f.taqprojectkey = @i_taqprojectkey
end

  
END
RETURN @f_activeprice
END
GO 
GRANT ALL ON rpt_taq_pl_priceby_formatyear TO PUBLIC


--Select dbo.rpt_taq_pl_priceby_formatyear(5839644, 1, 2, 1, 2, 27)
