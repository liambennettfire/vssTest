
GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_primary__secondary_bookkey]    Script Date: 08/26/2015 10:10:32 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_primary__secondary_bookkey]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_primary__secondary_bookkey]
GO


GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_primary__secondary_bookkey]    Script Date: 08/26/2015 10:10:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[rpt_get_primary__secondary_bookkey](@i_bookkey int, @i_Type int)

	/*
		@i_Type 1=primary bookkey
		@i_Type 2=secondary bookkey(non-e-book)
		
		
	*/

Returns int
AS
BEGIN
	Declare @return int
	Declare @i_bookkey_primary_secondary int
	If @i_Type=1 
	BEGIN
		Select @i_bookkey_primary_secondary=b.bookkey from book b
		inner join bookdetail bd
		on b.bookkey=bd.bookkey where linklevelcode=10
		and b.workkey=@i_bookkey
		
	END
	
	If @i_Type=2 
	BEGIN
		Select @i_bookkey_primary_secondary=b.bookkey from book b
		inner join bookdetail bd
		on b.bookkey=bd.bookkey where linklevelcode <> 10
		and bd.mediatypecode <>16
		and b.workkey=@i_bookkey
	END
	
	Select @return=@i_bookkey_primary_secondary
	Return @Return
END


GO
Grant all on rpt_get_primary__secondary_bookkey to public

