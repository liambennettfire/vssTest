/****** Object:  UserDefinedFunction [dbo].[rpt_Get_Contact_Comments]    Script Date: 08/09/2011 11:10:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_Get_Contact_Comments]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_Get_Contact_Comments]

GO
/****** Object:  UserDefinedFunction [dbo].[rpt_Get_Contact_Comments]    Script Date: 08/09/2011 11:10:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[rpt_Get_Contact_Comments] (@i_globalContactkey int ,@i_CommentTypeCode int,@i_commenttypesubcode int)

Returns varchar (250)

AS
BEGIN
	Declare @String_Value as varchar (250)
	Declare @Return as varchar (250)
	Select @String_Value=(Select Commenttext from qsicomments where commentkey=@i_globalContactkey
	and CommentTypecode=@i_commenttypecode and commenttypesubcode=@i_Commenttypesubcode)
	
	Select @Return=@String_Value
Return @Return
END


GO
GRANT ALL ON rpt_Get_Contact_Comments TO PUBLIC
