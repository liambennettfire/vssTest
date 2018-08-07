if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_relationships_contract_titles') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_relationships_contract_titles
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_relationships_contract_titles
 (@i_projectkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_relationships_contract_titles
**  Desc: This stored procedure gets all titles related to the given contract.
**
**  Auth: Kate W.
**  Date: 17 May 2012
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:      Author:   Case:   Description:
**  --------   ------    ------  ----------------------------------------------
**  04/23/18   Alan      48098 - Switched contracttitlesview to functional table due to speed issues
*******************************************************************************/

DECLARE
  @v_error INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT * FROM dbo.qcontract_contractstitlesinfo(@i_projectkey)
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error getting related titles for contract from contractstitlesview (' + cast(@v_error AS VARCHAR) + '): contractprojectkey=' + cast(@i_projectkey AS VARCHAR)   
  END 
    
END
go

GRANT EXEC ON qproject_get_relationships_contract_titles TO PUBLIC
GO

