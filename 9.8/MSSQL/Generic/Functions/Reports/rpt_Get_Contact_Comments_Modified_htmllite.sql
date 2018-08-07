GO

/****** Object:  UserDefinedFunction [dbo].rpt_Get_Contact_Comments_Modified_htmllite]    Script Date: 12/09/2014 09:54:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_Get_Contact_Comments_Modified_htmllite]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_Get_Contact_Comments_Modified_htmllite]
GO


/****** Object:  UserDefinedFunction [dbo].[rpt_Get_Contact_Comments_Modified_htmllite]    Script Date: 2/1/2016 12:54:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[rpt_Get_Contact_Comments_Modified_htmllite] (@i_globalContactkey int ,@i_CommentTypeCode int,@i_commenttypesubcode int)

Returns varchar (5000)

AS
BEGIN
	Declare @String_Value as varchar (5000)
	Declare @Return as varchar (5000)
	Select @String_Value=(Select commenthtmllite from qsicomments where commentkey=@i_globalContactkey
	and CommentTypecode=@i_commenttypecode and commenttypesubcode=@i_Commenttypesubcode)
	
	Select @Return=@String_Value
Return @Return
END



GO

Grant All on dbo.rpt_Get_Contact_Comments_Modified_htmllite to Public
go