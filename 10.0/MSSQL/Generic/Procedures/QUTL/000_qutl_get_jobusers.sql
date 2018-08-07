if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_jobusers') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_jobusers
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****************************************************************************************************************************
**  Name: qutl_get_jobusers
**  Desc: Get distinct list of users from qsijobs table
**
*****************************************************************************************************************************
**    Change History
*****************************************************************************************************************************
**    Date:        Author:         Description:
**    --------     --------        --------------------------------------------------------------------------------------
**    09/06/17     Colman          Case 46736
*****************************************************************************************************************************/

CREATE PROCEDURE [dbo].[qutl_get_jobusers]
(@o_error_code		int output,
 @o_error_desc		varchar(2000) output)
AS
	SET @o_error_code = 0
	SET @o_error_desc = ''
	
	SELECT DISTINCT j.runuserid, u.userkey
	FROM qsijob j
    JOIN qsiusers u ON u.userid = j.runuserid
	
	IF @@ERROR <> 0
	BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Failed to retrieve data from qsijob table.'
		RETURN
	END
GO

GRANT EXEC ON qutl_get_jobusers TO PUBLIC
GO