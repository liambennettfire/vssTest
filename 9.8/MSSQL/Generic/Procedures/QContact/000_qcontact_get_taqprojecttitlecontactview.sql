IF EXISTS (SELECT *
             FROM dbo.sysobjects
             WHERE id = object_id(N'dbo.qcontact_get_taqprojecttitlecontactview')
               AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.qcontact_get_taqprojecttitlecontactview
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE qcontact_get_taqprojecttitlecontactview
(
  @i_contactkey INTEGER,
  @i_tabqsicode INTEGER,
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS

  /******************************************************************************
  **  File: 
  **  Name: qcontact_get_taqprojecttitlecontactview
  **  Desc: This stored procedure returns all taqprojecttitlecontactview data
  **        for a global contact filtered for TitleRequested rows only.
  **
  **    Auth: Jon Hess
  **    Date: 02/03/2012
  *******************************************************************************
  **    Change History
  *******************************************************************************
  **    Date:    Author:        Description:
  **    --------    --------        -------------------------------------------
  **    
  *******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var INTEGER
  DECLARE @rowcount_var INTEGER

  DECLARE @v_tab_qsicode INTEGER
  DECLARE @role_code INTEGER
  DECLARE @title_role_code INTEGER
  DECLARE @v_webtab INTEGER

  -- Set some givens
  SET @v_tab_qsicode = @i_tabqsicode

  -- Convert from qsicode to datacode for the webrelationshiptab title request entry. 
  SELECT @v_webtab = datacode
    FROM gentables g
    WHERE tableid = 583
      AND qsicode = @v_tab_qsicode

  SELECT *
    FROM taqprojecttitlecontact_view
    WHERE globalcontactkey = @i_contactkey
      AND rolecode IN (SELECT code1
                         FROM gentablesrelationshipdetail
                         WHERE gentablesrelationshipkey = 19
                           -- contact role to web relationship tab
                           AND code2 = @v_webtab)
      AND titlerolecode IN (SELECT code1
                              FROM gentablesrelationshipdetail
                              WHERE gentablesrelationshipkey = 11
                                -- title role to web relationship tab
                                AND code2 = @v_webtab)


  SELECT @error_var = @@ERROR,
         @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0
    BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'no data found on qcontact_get_taqprojecttitlecontactview (' +
      cast(@error_var AS VARCHAR) + '): globalcontactkey = ' + cast(@i_contactkey AS
      VARCHAR)
    END

GO
GRANT EXEC ON qcontact_get_taqprojecttitlecontactview TO PUBLIC
GO