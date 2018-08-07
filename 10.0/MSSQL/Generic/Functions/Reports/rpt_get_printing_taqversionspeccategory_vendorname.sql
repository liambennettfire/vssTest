/****** Object:  UserDefinedFunction [dbo].[rpt_get_printing_taqversionspeccategory_vendorname]    Script Date: 05/11/2015 14:00:43 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_printing_taqversionspeccategory_vendorname]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_printing_taqversionspeccategory_vendorname]
GO


/****** Object:  UserDefinedFunction [dbo].[rpt_get_printing_taqversionspeccategory_vendorname]    Script Date: 05/11/2015 14:00:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[rpt_get_printing_taqversionspeccategory_vendorname] (@i_bookkey int,@i_printingkey int,@i_itemcategorycode int,@v_type varchar(10))
RETURNS VARCHAR(255)
AS

BEGIN
Declare @i_vendorkey int,
@i_taqprojectkey int,
@i_projectrolecode int,
@i_titlerolecode int,
@i_taqversionspecategorykey int,
@i_relatedspecctegorykey int,
@v_return varchar(255)

--get the rolecodes for prinitng and title
select @i_projectrolecode = datacode from gentables where tableid=604 and qsicode=3
select @i_titlerolecode = datacode from gentables where tableid=605 and qsicode=7

--get the printing projectkey from taqprojecttitle
select @i_taqprojectkey = taqprojectkey from taqprojecttitle where bookkey=@i_bookkey and printingkey=@i_printingkey
and projectrolecode = @i_projectrolecode and titlerolecode=@i_titlerolecode

--get the taqversionspecategorykey for the passed itemcategorycode
select @i_taqversionspecategorykey = taqversionspecategorykey from taqversionspeccategory where taqprojectkey = @i_taqprojectkey and itemcategorycode=@i_itemcategorycode

select @i_relatedspecctegorykey = relatedspeccategorykey from taqversionspeccategory where taqprojectkey = @i_taqprojectkey and itemcategorycode=@i_itemcategorycode

--get the vendorkey from the associated component
select @i_vendorkey = vendorcontactkey from taqversionspeccategory where taqversionspecategorykey=@i_taqversionspecategorykey

--if no vendorkey, check the related component 
IF coalesce(@i_vendorkey,0)=0
	select @i_vendorkey = vendorcontactkey from taqversionspeccategory where taqversionspecategorykey=@i_relatedspecctegorykey

--get the value based on the @v_type
IF @v_type = 'D' --displayname
	select @v_return = displayname from globalcontact where globalcontactkey = @i_vendorkey

IF @v_type = 'S' --shortdesc
	select @v_return = shortname from globalcontact where globalcontactkey = @i_vendorkey	
	
IF @v_type = 'G' --groupname
	select @v_return = groupname from globalcontact where globalcontactkey = @i_vendorkey
	
IF @v_type = 'C' --country
	select @v_return = ge.datadesc 
	from globalcontact g inner join globalcontactaddress ga on g.globalcontactkey=ga.globalcontactkey and ga.addresstypecode = 1  and ga.primaryind=1 --co mailing
	inner join gentables ge on ga.countrycode = ge.datacode and ge.tableid =114 
	where g.globalcontactkey = @i_vendorkey
	
IF @v_type = 'CC' --country code
	select @v_return = ga.countrycode
	from globalcontact g inner join globalcontactaddress ga on g.globalcontactkey=ga.globalcontactkey and ga.addresstypecode = 1  and ga.primaryind=1 --co mailing
	where g.globalcontactkey = @i_vendorkey	
	
	RETURN coalesce(@v_return,'')

END
GO

GRANT EXEC ON dbo.rpt_get_printing_taqversionspeccategory_vendorname to public
go


