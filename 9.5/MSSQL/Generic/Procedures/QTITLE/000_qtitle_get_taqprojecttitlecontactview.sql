IF EXISTS (SELECT *
             FROM dbo.sysobjects
             WHERE id = object_id(N'dbo.qtitle_get_taqprojecttitlecontactview')
               AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.qtitle_get_taqprojecttitlecontactview
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE qtitle_get_taqprojecttitlecontactview
(
  @i_bookkey INTEGER,
  @i_userkey INTEGER,
  @i_tabdatacode INTEGER,
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS

  /******************************************************************************
  **  File: 
  **  Name: qtitle_get_taqprojecttitlecontactview
  **  Desc: This stored procedure returns all taqprojecttitlecontactview data
  **        for a bookkey filtered for TitleRequested rows only.
  **
  **    Auth: Jon Hess
  **    Date: 02/08/2012
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

  DECLARE @role_code INTEGER
  DECLARE @title_role_code INTEGER
  DECLARE @v_webtab INTEGER
  DECLARE @v_contactrelationshipcode1 int
  DECLARE @v_contactrelationshipcode2 int

  -- Set some givens
  SET @v_webtab = @i_tabdatacode

  SELECT @v_contactrelationshipcode1 = COALESCE(contactrelationship1,0),
         @v_contactrelationshipcode2 = COALESCE(contactrelationship2,0) 
    FROM taqrelationshiptabconfig 
   WHERE relationshiptabcode = @v_webtab

  SELECT *, dbo.qcontact_is_contact_private(v.globalcontactkey, @i_userkey) AS isprivate, 
         dbo.get_gentables_desc(285,rolecode,'long') as contactroledesc,
         dbo.qcontact_get_related_contact_displayname(v.globalcontactkey,@v_contactrelationshipcode1) as relatedcontactname1,
         dbo.qcontact_get_related_contact_displayname(v.globalcontactkey,@v_contactrelationshipcode2) as relatedcontactname2
    FROM taqprojecttitlecontact_view v
    WHERE bookkey = @i_bookkey
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
      cast(@error_var AS VARCHAR) + '): bookkey = ' + cast(@i_bookkey AS
      VARCHAR)
    END

GO
GRANT EXEC ON qtitle_get_taqprojecttitlecontactview TO PUBLIC
GO