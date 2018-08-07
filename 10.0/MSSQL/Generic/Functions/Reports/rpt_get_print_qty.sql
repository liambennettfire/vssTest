/****** Object:  UserDefinedFunction [dbo].[rpt_get_print_qty]    Script Date: 03/11/2015 14:10:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_print_qty]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_print_qty]
GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_print_qty]    Script Date: 03/11/2015 14:10:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[rpt_get_print_qty] (@i_taqporeportkey int)

RETURNS int

AS  

BEGIN 

DECLARE @i_printqty  INT,
@RETURN	INT,
@i_printitemcode int

	select @i_printitemcode = datacode from gentables where tableid=616 and externalcode=2

	SELECT @i_printqty = quantity
	FROM  rpt_poreport_components_view
	WHERE poreportprojectkey =  @i_taqporeportkey
	and itemcategorycode=@i_printitemcode

		
	IF @i_printqty > 0  
		select @RETURN = @i_printqty
	Else 
		select @RETURN = 0


    RETURN @RETURN

END

GO

GRANT EXEC on [dbo].[rpt_get_print_qty] to PUBLIC
go


