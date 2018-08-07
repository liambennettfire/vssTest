if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_contracts_by_bookkey') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_contracts_by_bookkey
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_contracts_by_bookkey
 (@i_bookkey							integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_contracts_by_bookkey
**  Desc: This procedure retrieves all associated contract project keys associated with the given book key
**
**	Auth: Dustin Miller
**	Date: May 22 2012
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:      Author:   Case:   Description:
**  --------   ------    ------  ----------------------------------------------
**  04/23/18   Alan      48098 - Switched contracttitlesview to functional table due to speed issues
*******************************************************************************/
	DECLARE @v_error			INT,
          @v_rowcount		INT
	
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT contractprojectkey
  FROM dbo.qtitle_contractstitleview_by_bookkey(@i_bookkey)
  WHERE templateind <> 1

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning territory by formatlanguage details (projectkey=' + cast(@i_bookkey as varchar) + ')'
    RETURN  
  END   
GO

GRANT EXEC ON qtitle_get_contracts_by_bookkey TO PUBLIC
GO