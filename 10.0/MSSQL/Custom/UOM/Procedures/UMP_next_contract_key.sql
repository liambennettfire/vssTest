SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'UMP_next_contract_key' ) 
     DROP PROCEDURE UMP_next_contract_key 
go


CREATE PROCEDURE [dbo].[UMP_next_contract_key]
	@i_projectkey		  INT,
	@i_elementkey         INT,
	@i_related_journalkey INT,
	@i_productidcode      INT,
        @o_result             VARCHAR(50) OUTPUT,
        @o_error_code         INT OUTPUT,
        @o_error_desc         VARCHAR(2000)   OUTPUT 
AS
/******************************************************************************
**  
**  Desc: This stored procedure is gets the next contract key in the format of 
**  YYYY-XXXXX
**    
*******************************************************************************/
BEGIN

BEGIN TRANSACTION getkey


	UPDATE keys SET generickey = generickey+1, 
		 lastuserid = 'sp_next_generic_key', lastmaintdate = getdate()

	if @@Error <> 0
	BEGIN
	  ROLLBACK TRANSACTION;
	  print 'Error creating the next key.  Rollback';
	  SET @o_error_code = 1;
	  SET @o_error_desc = 'Error updating the generic key';
	  SET @o_result = 0;
	  return;
	END

	SELECT @o_result = CAST(YEAR(GETDATE()) as VARCHAR) + '-' + CAST(generickey as VARCHAR) FROM keys

COMMIT TRANSACTION getkey

END

 
GO

GRANT EXEC on UMP_next_contract_key TO PUBLIC
GO