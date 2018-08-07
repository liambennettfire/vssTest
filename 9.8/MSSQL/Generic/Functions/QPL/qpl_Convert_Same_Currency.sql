IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_Convert_Same_Currency]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[qpl_Convert_Same_Currency]
GO


/******************************************************************************
**  Name: qpl_Convert_Same_Currency
**  Desc: This function is used to determine currency/exchange, called off in the following stored procedure
**		  qpl_calc_Production_Expense_version_by_format_YUP, if currency is different, it will return the exchange rate
**        	
**    Auth: Jason Donovan
**    Date: 1-25-2016
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:     Description:
**    -------- --------    -------------------------------------------
**   2/3/16 	OA		Corrected IF Exists syntax
*******************************************************************************/

CREATE function [dbo].[qpl_Convert_Same_Currency](@iprojectkey int,@i_entered_Currency int,@i_Main_project_Currency int)

Returns float

AS

BEGIN

		Declare @Return float

		If @i_Main_project_Currency=@i_entered_Currency

		BEGIN

			Select  @return=1.0
		END



		If @i_Main_project_Currency<>@i_entered_Currency

		BEGIN

			 Select @return= decimal1 from gentablesrelationshipdetail where gentablesrelationshipkey=27 and code1=@i_entered_Currency

		END

		Return @return

END
GO

GRANT EXEC ON dbo.qpl_Convert_Same_Currency TO PUBLIC
GO
