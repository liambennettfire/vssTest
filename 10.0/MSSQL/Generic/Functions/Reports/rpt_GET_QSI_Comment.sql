SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_GET_QSI_Comment') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_GET_QSI_Comment
GO

CREATE FUNCTION [dbo].[rpt_GET_QSI_Comment](@i_Commentkey as int, @i_code as int, @i_SubCode as int)  
  
Returns varchar (8000)  
AS  
  
BEGIN  
Declare @Return varchar(max)  
Declare @Comment varchar(max)  
Select @Comment=commenthtmllite from qsicomments where commentkey=@i_Commentkey and commenttypecode=@i_code  
and commenttypesubcode=@i_subcode   
Select @Return=@Comment  
Return @Return   
END  

Go
Grant all on rpt_GET_QSI_Comment to public