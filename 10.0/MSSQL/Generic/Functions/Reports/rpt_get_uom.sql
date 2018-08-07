/****** Object:  UserDefinedFunction [dbo].[rpt_get_uom]    Script Date: 10/26/2016 11:48:46 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_uom]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[rpt_get_uom]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create function [dbo].[rpt_get_uom](@bookkey int, @type varchar(2), @column varchar(2))
returns varchar (50)
as begin
declare @Desc varchar(50),@ShortDesc varchar(50) 
/*
Jason Donovan
10-26-2016- Fixed @type  = 'B' 
was using the bookweight to get the datadesc 
from gentables and needs to use bookweightunitofmeasure
*/


if @type  = 'T'  begin 
			if @column ='D' begin
							Select @Desc= dbo.rpt_get_gentables_field(613,p.trimsizeunitofmeasure,'d') from printing p where p.bookkey=@bookkey end
			else begin Select @ShortDesc= dbo.rpt_get_gentables_field(613,p.trimsizeunitofmeasure,'S') from printing p where p.bookkey=@bookkey end
end
else if @type  = 'S'  begin 
		if @column ='D' begin 
						Select @Desc= dbo.rpt_get_gentables_field(613,p.spinesizeunitofmeasure,'d') from printing p where p.bookkey=@bookkey end
		else begin Select @ShortDesc= dbo.rpt_get_gentables_field(613,p.spinesizeunitofmeasure,'S') from printing p where p.bookkey=@bookkey end
end
else if @type  = 'B'  begin 
		if @column ='D' begin
						Select @Desc= dbo.rpt_get_gentables_field(613,p.bookweightunitofmeasure,'d') from printing p where p.bookkey=@bookkey end
		else begin Select @ShortDesc= dbo.rpt_get_gentables_field(613,p.bookweightunitofmeasure,'S') from printing p where p.bookkey=@bookkey end
end

return coalesce(@desc,@shortDesc)
end


Go
Grant all on rpt_get_uom to Public