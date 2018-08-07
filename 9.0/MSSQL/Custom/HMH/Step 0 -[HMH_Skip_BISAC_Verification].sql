GO

/****** Object:  UserDefinedFunction [dbo].[HMH_Skip_BISAC_Verification]    Script Date: 05/22/2014 14:01:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HMH_Skip_BISAC_Verification]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[HMH_Skip_BISAC_Verification]
GO

GO

/****** Object:  UserDefinedFunction [dbo].[HMH_Skip_BISAC_Verification]    Script Date: 05/22/2014 14:01:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create function [dbo].[HMH_Skip_BISAC_Verification](@i_bookkey int)
returns varchar(5)
as begin
declare @return varchar(5)
set @return ='false' 

declare @previousBisacStatus varchar(50), @TitleHistory_max_IDNum int

set @TitleHistory_max_IDNum = (Select MAX(id_num) from titlehistory where bookkey = @i_bookkey and columnkey=4)


select @previousBisacStatus = stringvalue
from titlehistory where id_num = @TitleHistory_max_IDNum

if @previousBisacStatus in ('Active', 'Out of Stock Indefin','Out of Stock Indefinitely','Not Yet Published')
begin 
	set @return= 'true'
end



return @return
end
GO


grant all on [HMH_Skip_BISAC_Verification] to public