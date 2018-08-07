if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_all_orgentries_for_level') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_all_orgentries_for_level
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qutl_get_all_orgentries_for_level
 (@i_orglevelkey         integer,
  @i_orgentryparentkey   integer,
  @i_userkey             integer,
  @i_updateonly          integer,
  @o_error_code          integer output,
  @o_error_desc          varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qutl_get_all_orgentries_for_level
**  Desc: This stored procedure returns all organizational levels
**        for a given level based on the orgentryparentkey. 
**
**              
**
**    Auth: Alan Katzen
**    Date: 20 April 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:        Description:
**    --------    --------       ----------------------------------------------
**    20-Apr-04   AK             Initial Creation
**    05-Oct-04   AK             Added update security check at filterorglevel 
**                               security level
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @orglevel_access_filterkey_var INT,
          @securitygroupkey_var INT,
          @filterorglevelkey_var INT,
          @userid_var VARCHAR(30)

  -- Userorglevelaccess filterkey on filterorglevel table
  SET @orglevel_access_filterkey_var = 7
  
  -- Check if we are retrieving orgentries for security orglevel
  SELECT @filterorglevelkey_var=filterorglevelkey
    FROM filterorglevel
   WHERE filterkey = @orglevel_access_filterkey_var;

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to load orgentries: Could not access filterorglevel table.'
    RETURN
  END 

  IF @filterorglevelkey_var IS NULL BEGIN
    SET @filterorglevelkey_var = 0
  END 

  IF (@filterorglevelkey_var = @i_orglevelkey) BEGIN
    -- this is the level for orgentry security
    SELECT @securitygroupkey_var=securitygroupkey, @userid_var=userid
      FROM qsiusers
     WHERE userkey = @i_userkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to load orgentries: Userid not setup on qsiusers table.'
      RETURN
    END 

    -- All users must be part of a security group
    IF @securitygroupkey_var IS NULL OR @securitygroupkey_var = 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to load orgentries: Userid is not a member of a security group.'
      RETURN
    END 

    IF (@i_updateonly > 0) BEGIN
      -- retrieve orgentries that user has only update access for 
      SELECT o.*
        FROM orgentry o, securityorglevel s
       WHERE o.orglevelkey = s.orglevelkey AND
             o.orgentrykey = s.orgentrykey AND
             o.orglevelkey = @i_orglevelkey AND
             o.orgentryparentkey = @i_orgentryparentkey AND
             (UPPER(o.deletestatus) = 'N' OR o.deletestatus is null) AND
             s.accessind = 2 AND
             s.userkey = @i_userkey 
      UNION
      SELECT o.*
        FROM orgentry o, securityorglevel s
       WHERE o.orglevelkey = s.orglevelkey AND
             o.orgentrykey = s.orgentrykey AND
             o.orglevelkey = @i_orglevelkey AND
             o.orgentryparentkey = @i_orgentryparentkey AND
             (UPPER(o.deletestatus) = 'N' OR o.deletestatus is null) AND
             s.accessind = 2 AND
             s.securitygroupkey = @securitygroupkey_var AND
             s.orgentrykey NOT IN (select orgentrykey from securityorglevel s
                                    where s.orglevelkey = @i_orglevelkey AND
                                          s.accessind <> 2 AND
                                          s.userkey = @i_userkey )
    ORDER BY o.orgentrydesc

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to load orgentries: Could not access securityorglevel table.'
        RETURN
      END 
    END
    ELSE BEGIN
      -- retrieve orgentries that user has update and read only access for 
      SELECT o.*
        FROM orgentry o, securityorglevel s
       WHERE o.orglevelkey = s.orglevelkey AND
             o.orgentrykey = s.orgentrykey AND
             o.orglevelkey = @i_orglevelkey AND
             o.orgentryparentkey = @i_orgentryparentkey AND
             (UPPER(o.deletestatus) = 'N' OR o.deletestatus is null) AND
             s.accessind > 0 AND
             s.userkey = @i_userkey 
      UNION
      SELECT o.*
        FROM orgentry o, securityorglevel s
       WHERE o.orglevelkey = s.orglevelkey AND
             o.orgentrykey = s.orgentrykey AND
             o.orglevelkey = @i_orglevelkey AND
             o.orgentryparentkey = @i_orgentryparentkey AND
             (UPPER(o.deletestatus) = 'N' OR o.deletestatus is null) AND
             s.accessind > 0 AND
             s.securitygroupkey = @securitygroupkey_var AND
             s.orgentrykey NOT IN (select orgentrykey from securityorglevel s
                                    where s.orglevelkey = @i_orglevelkey AND
                                          s.accessind = 0 AND
                                          s.userkey = @i_userkey )
    ORDER BY o.orgentrydesc

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to load orgentries: Could not access securityorglevel table.'
        RETURN
      END 
    END
  END
  ELSE BEGIN
    -- this is the NOT level for orgentry security
    SELECT o.*
      FROM orgentry o 
     WHERE o.orglevelkey = @i_orglevelkey and
           o.orgentryparentkey = @i_orgentryparentkey AND
          (UPPER(o.deletestatus) = 'N' OR o.deletestatus is null)
  ORDER BY o.orgentrydesc

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 or @rowcount_var = 0 BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'no data found: orglevelkey = ' + cast(@i_orglevelkey AS VARCHAR) + ' orgentryparentkey = ' + cast(@i_orgentryparentkey AS VARCHAR)
    END 
  END
GO
GRANT EXEC ON qutl_get_all_orgentries_for_level TO PUBLIC
GO


