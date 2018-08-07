if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_journal_volume_for_issue') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_journal_volume_for_issue
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_journal_volume_for_issue
 (@i_projectkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_journal_volume_for_issue
**  Desc: This stored procedure returns Journal Volume info for the 
**        Journal Volume Tab for Issues. 
**
**    Auth: Alan Katzen
**    Date: 6 March 2008
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT,
          @v_gentablesrelationshipkey INT,
          @v_journalkey INT,
          @v_volumekey INT,
          @v_journalname varchar(80),
          @v_volumename varchar(80),
          @v_qsicode INT

  SELECT @v_journalkey = journalkey,@v_volumekey = volumekey 
    FROM dbo.qproject_get_issue()
   WHERE issuekey = @i_projectkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error acessing Issue View: projectkey = ' + cast(@i_projectkey AS VARCHAR)
    RETURN  
  END 

  SET @v_journalname = ''
  IF @v_journalkey > 0 BEGIN
    SELECT @v_journalname = projecttitle
      FROM coreprojectinfo
     WHERE projectkey = @v_journalkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error acessing coreprojectinfo: projectkey = ' + cast(@v_journalkey AS VARCHAR)
      RETURN  
    END  
  END

  SET @v_volumename = ''
  IF @v_volumekey > 0 BEGIN
    SELECT @v_volumename = projecttitle
      FROM coreprojectinfo
     WHERE projectkey = @v_volumekey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error acessing coreprojectinfo: projectkey = ' + cast(@v_volumekey AS VARCHAR)
      RETURN  
    END  
  END

  SELECT @v_journalname journalname, COALESCE(@v_journalkey,0) journalkey,
    @v_volumename volumename, COALESCE(@v_volumekey,0) volumekey,
    dbo.qproject_get_misc_value(COALESCE(@v_journalkey,0),96) jmisc1, dbo.qutl_get_misc_label(96) jmisc1label,
    dbo.qproject_get_misc_value(COALESCE(@v_journalkey,0),97) jmisc2, dbo.qutl_get_misc_label(97) jmisc2label,
    dbo.qproject_get_misc_value(COALESCE(@v_journalkey,0),11) jmisc3, dbo.qutl_get_misc_label(11) jmisc3label,
    dbo.qproject_get_misc_value(COALESCE(@v_journalkey,0),124) jmisc4, 'Accounting Code' jmisc4label,
    dbo.qproject_get_misc_value(COALESCE(@v_volumekey,0),53) vmisc1, 'Volume Year' vmisc1label,
    dbo.qproject_get_price_by_pricetype(COALESCE(@v_volumekey,0), 21) price1, 'Individual Single Issue Price' price1label,
    dbo.qproject_get_price_by_pricetype(COALESCE(@v_volumekey,0), 22) price2, 'Institutional Single Issue Price' price2label,
    dbo.qproject_get_price_by_pricetype(COALESCE(@v_volumekey,0), 23) price3, 'Individual Double Issue Price' price3label    
  FROM coreprojectinfo
  WHERE projectkey = @i_projectkey
    
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error acessing coreprojectinfo: projectkey = ' + cast(@i_projectkey AS VARCHAR)
  END 

GO

GRANT EXEC ON qproject_get_journal_volume_for_issue TO PUBLIC
GO

