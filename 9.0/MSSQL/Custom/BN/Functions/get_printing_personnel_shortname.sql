if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_printing_personnel_shortname]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[get_printing_personnel_shortname]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO





CREATE FUNCTION dbo.get_printing_personnel_shortname(@i_bookkey INT, @i_printingkey INT, @i_roletypecode INT)

RETURNS VARCHAR(10)

AS
BEGIN
	DECLARE @RETURN VARCHAR(10)

select @RETURN = shortname 
	from person where contributorkey IN
		(select contributorkey from bookcontributor 
		where roletypecode = @i_roletypecode and 
		      bookkey = @i_bookkey and 
		      printingkey = @i_printingkey)

	RETURN @RETURN
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



GRANT EXEC ON [dbo].[get_printing_personnel_shortname]  TO [public]
GO
