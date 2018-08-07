SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.additional_cloud_verification') AND (type = 'P' or type = 'RF')) BEGIN
	DROP PROC additional_cloud_verification 
END
GO

CREATE PROCEDURE dbo.additional_cloud_verification 
(@i_bookkey		integer,
 @i_printingkey integer, 
 @i_verificationtypecode integer,
 @i_username varchar(15),
 @o_error_code     integer output,
 @o_error_desc     varchar(2000) output)
AS
/***********************************************************************************
**    History
************************************************************************************
**    Date:       Author:      Case #:   Description:
**   ---------    --------     -------   --------------------------------------------
**   04/11/2016   Kusum        37519     Additional Cloud Verification    
*************************************************************************************/
BEGIN
	DECLARE @v_returncode INT
	
	-- the code for the customer additional validation procedure will be inserted here and the correct values set for the output parameters
	SET @v_returncode = 1
	SET @o_error_code = @v_returncode
	SET @o_error_desc = 'Validation message'
	RETURN
END
GO

GRANT EXECUTE on additional_cloud_verification TO PUBLIC
GO
