if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_titles_from_contract') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_titles_from_contract
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_titles_from_contract
 (@i_contractprojectkey		integer,
	@o_error_code						integer output,
  @o_error_desc						varchar(2000) output)
AS

/************************************************************************************
**  Name: qtitle_get_titles_from_contract
**  Desc: This stored procedure returns all title bookkeys that are derived from the given contract
**
**  Auth: Dustin Miller
**  Date: 8/10/12
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:      Author:   Case:   Description:
**  --------   ------    ------  ----------------------------------------------
**  04/23/18   Alan      48098 - Switched contracttitlesview to functional table due to speed issues
*******************************************************************************/

BEGIN

  DECLARE
    @v_error  INT,
    @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
	SELECT tv.bookkey, tv.printingkey
	FROM dbo.qcontract_contractstitlesinfo(@i_contractprojectkey) tv
	JOIN bookdetail bd
	ON (tv.bookkey = bd.bookkey)
	WHERE bd.territoryderivedfromcontractind = 1
  
END
GO

GRANT EXEC ON qtitle_get_titles_from_contract TO PUBLIC
GO
