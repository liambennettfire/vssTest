SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_getLastImageRecDate]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_getLastImageRecDate]
GO

CREATE FUNCTION [qweb_getLastImageRecDate](
	@i_bookkey as INT
)

RETURNS datetime
BEGIN 
	declare @lastProcDate datetime
	select @lastProcDate=max(lastProcessedDate) 
	from elo_image_report
	where bookkey=@i_bookkey

  RETURN @lastProcDate
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

grant execute on qweb_getLastImageRecDate to public
go