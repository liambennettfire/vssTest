/****** Object:  UserDefinedFunction [dbo].[rpt_taq_pl_get_client_value]    Script Date: 04/13/2010 10:06:45 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_taq_pl_get_client_value]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_taq_pl_get_client_value]
GO


Create FUNCTION [dbo].[rpt_taq_pl_get_client_value]
		(@i_taqprojectkey INT,
		@i_plstagecode INT,
		@i_taqversionkey INT,
		@i_clientvaluecode INT)


RETURNS VARCHAR(100)


AS

BEGIN

	DECLARE @RETURN			VARCHAR(100)

    Select @RETURN = clientvalue 
	from taqversionclientvalues 
	where taqprojectkey = @i_taqprojectkey
	and plstagecode= @i_plstagecode
	and taqversionkey = @i_taqversionkey
	and clientvaluecode= @i_clientvaluecode



	RETURN @RETURN


END

GO
GRANT ALL ON [rpt_taq_pl_get_client_value] TO PUBLIC