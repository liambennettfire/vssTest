 if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_derive_from_contract_by_bookkey') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_derive_from_contract_by_bookkey
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_derive_from_contract_by_bookkey
 (@i_bookkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/************************************************************************************************
**  File: 
**  Name: qtitle_get_derive_from_contract_by_bookkey
**  Desc: This stored procedure returns all related contract found that matches the criteria
**        Format and Language from the bookdetail table. It is designed to be used 
**        in conjunction with a title classification controls, derive from Contract link.
**        contract project Status = Active (using clientdefault 85) 
**        contracts Rights Impact code = Granted to Publisher      
**
**    Auth: Uday A. Khisty
**    Date: 20 January 2017
*************************************************************************************************
**    Change History
*******************************************************************************
**    Date:         Author:           Description:
**    --------      --------          -------------------------------------------
**    02/13/17      Uday              Case 42617 - Task 001
**    04/23/18      Alan              48098 - Switched contracttitlesview to functional table due to speed issues
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''

  DECLARE @error_var    INT,
          @rowcount_var INT,
		  @v_clientdefaultvalue FLOAT,
          @v_rightsimpactcode INT,
		  @v_mediatypecode SMALLINT,
		  @v_mediatypesubcode SMALLINT,
		  @v_languagecode INT

  SET @v_clientdefaultvalue = NULL
  SET @v_rightsimpactcode = NULL
  SET @v_mediatypecode = NULL
  SET @v_mediatypesubcode = NULL
  SET @v_languagecode = NULL

  SELECT @v_clientdefaultvalue = clientdefaultvalue from clientdefaults where clientdefaultid = 85
  SELECT @v_rightsimpactcode = dbo.qutl_get_gentables_datacode(685, NULL, 'Granted to Publisher')
  SELECT @v_mediatypecode = mediatypecode, @v_mediatypesubcode = mediatypesubcode, @v_languagecode = languagecode 
  FROM bookdetail WHERE bookkey = @i_bookkey

  SELECT v.*
  FROM dbo.qtitle_contractstitleview_by_bookkey(@i_bookkey) v
  INNER JOIN taqproject t ON  t.taqprojectkey = v.contractprojectkey
  WHERE v.templateind = 0
  AND v.mediatypecode = @v_mediatypecode 
  AND v.mediatypesubcode = @v_mediatypesubcode
  --AND t.languagecode = @v_languagecode
  AND t.taqprojectstatuscode = @v_clientdefaultvalue
  AND t.rightsimpactcode = @v_rightsimpactcode

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: bookkey = ' + cast(@i_bookkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qtitle_get_derive_from_contract_by_bookkey TO PUBLIC
GO