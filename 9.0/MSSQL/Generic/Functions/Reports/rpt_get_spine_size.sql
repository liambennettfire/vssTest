
/****** Object:  UserDefinedFunction [dbo].[rpt_get_spine_size]    Script Date: 03/24/2009 13:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_spine_size') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_spine_size
GO
CREATE FUNCTION [dbo].[rpt_get_spine_size] 
            (@i_bookkey INT,
            @i_printingkey INT)
		

 
/*          The rpt_get_spine_size function is used to retrieve the spine size from the printing
            table.   

            The parameters are for the book key and printing key.  

*/

RETURNS VARCHAR(15)

AS  

BEGIN 

DECLARE @RETURN		VARCHAR(15)


	SELECT @RETURN = COALESCE(spinesize,'')
	FROM  printing
	WHERE  bookkey = @i_bookkey and printingkey = @i_printingkey

RETURN @RETURN

END
go
Grant All on dbo.rpt_get_spine_size to Public
go