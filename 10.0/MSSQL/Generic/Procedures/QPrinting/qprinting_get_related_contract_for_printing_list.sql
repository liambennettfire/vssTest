if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qprinting_get_related_contract_for_printing_list') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qprinting_get_related_contract_for_printing_list
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qprinting_get_related_contract_for_printing_list
 (@i_projectkeys    VARCHAR(MAX),
  @o_error_code     integer       output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qprinting_get_related_contract_for_printing_list
**  Desc: returns all the printing projectkeys alongside their related contract key
**				for those that have them.
**
**    Auth: Dustin Miller
**    Date: March 8, 2017
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:     Description:
**  --------  --------    -----------------------------------------------------
**  
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
	DECLARE @projectkeys VARCHAR(MAX)
	DECLARE @projectkey VARCHAR(MAX)
	DECLARE @projectkeyval INT
	DECLARE @contractkey  INT
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

	DECLARE @relatedContractTable TABLE
	(
		projectkey INT,
		relatedcontractkey INT
	)

  SET @projectkeys = @i_projectkeys
	SET @projectkey = null
	SET @projectkeyval = null
	WHILE LEN(@projectkeys) > 0
	BEGIN
		IF PATINDEX('%,%',@projectkeys) > 0
		BEGIN
			SET @projectkey = SUBSTRING(@projectkeys, 0, PATINDEX('%,%', @projectkeys))
			SET @projectkeys = SUBSTRING(@projectkeys, LEN(@projectkey + ',') + 1, LEN(@projectkeys))
		END
		ELSE BEGIN
			SET @projectkey = @projectkeys
			SET @projectkeys = NULL
		END

		SET @projectkeyval = CAST(@projectkey AS INT)
		SET @contractkey = NULL

		DECLARE contract_cur CURSOR FOR
		SELECT rp.taqprojectkey as contractkey
    FROM taqproject p
		JOIN taqprojectrights r ON r.taqprojectprintingkey = p.taqprojectkey
		JOIN taqproject rp ON rp.taqprojectkey = r.taqprojectkey
		WHERE p.taqprojectkey = @projectkeyval      
        
		OPEN contract_cur

		FETCH NEXT FROM contract_cur INTO @contractkey
  
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
			IF COALESCE(@contractkey, 0) > 0
			BEGIN
				INSERT INTO @relatedContractTable
				(projectkey, relatedcontractkey)
				VALUES
				(@projectkeyval, @contractkey)
			END

			FETCH NEXT FROM contract_cur INTO @contractkey
		END

		CLOSE contract_cur
		DEALLOCATE contract_cur
	END

	SELECT *
	FROM @relatedContractTable

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: taqprojectkeys = ' + @i_projectkeys
  END 

GO
GRANT EXEC ON qprinting_get_related_contract_for_printing_list TO PUBLIC
GO


