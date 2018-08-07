SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_statuscode]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_statuscode]
GO




CREATE FUNCTION qweb_get_statuscode
    ( @i_bookkey as int ) 

RETURNS int

BEGIN 
   DECLARE @i_statuscode int

  select @i_statuscode = bisacstatuscode from bookdetail  where bookkey = @i_bookkey 

  RETURN  @i_statuscode 
END






GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

