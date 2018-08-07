if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_all_orgentries_for_scale') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_all_orgentries_for_scale
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qscale_get_all_orgentries_for_scale
 (@i_projectkey          integer,
  @i_orglevelkey         integer,
  @i_userkey             integer,
  @i_updateonly          integer,
  @o_error_code          integer output,
  @o_error_desc          varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qscale_get_all_orgentries_for_scale
**  Desc: This stored procedure returns all organizational entries
**        for a given level and whether or not they are selected for a scale. 
**
**    Auth: Alan Katzen
**    Date: 24 January 2012
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @orglevel_access_filterkey_var INT,
          @securitygroupkey_var INT,
          @filterorglevelkey_var INT,
          @userid_var VARCHAR(30)

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
      SELECT o.*, CASE WHEN (select count(*) from taqprojectscaleorgentry where taqprojectkey = @i_projectkey and orgentrykey = o.orgentrykey) > 0 THEN 1 
                  ELSE 0 END selectedind
        FROM orgentry o, securityorglevel s
       WHERE o.orglevelkey = s.orglevelkey AND
             o.orgentrykey = s.orgentrykey AND
             o.orglevelkey = @i_orglevelkey AND
             (UPPER(o.deletestatus) = 'N' OR o.deletestatus is null) AND
             s.accessind = 2 AND
             s.userkey = @i_userkey 
      UNION
      SELECT o.*, CASE WHEN (select count(*) from taqprojectscaleorgentry where taqprojectkey = @i_projectkey and orgentrykey = o.orgentrykey) > 0 THEN 1 
                  ELSE 0 END selectedind
        FROM orgentry o, securityorglevel s
       WHERE o.orglevelkey = s.orglevelkey AND
             o.orgentrykey = s.orgentrykey AND
             o.orglevelkey = @i_orglevelkey AND
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
      SELECT o.*, CASE WHEN (select count(*) from taqprojectscaleorgentry where taqprojectkey = @i_projectkey and orgentrykey = o.orgentrykey) > 0 THEN 1 
                  ELSE 0 END selectedind
        FROM orgentry o, securityorglevel s
       WHERE o.orglevelkey = s.orglevelkey AND
             o.orgentrykey = s.orgentrykey AND
             o.orglevelkey = @i_orglevelkey AND
             (UPPER(o.deletestatus) = 'N' OR o.deletestatus is null) AND
             s.accessind > 0 AND
             s.userkey = @i_userkey 
      UNION
      SELECT o.*, CASE WHEN (select count(*) from taqprojectscaleorgentry where taqprojectkey = @i_projectkey and orgentrykey = o.orgentrykey) > 0 THEN 1 
                  ELSE 0 END selectedind
        FROM orgentry o, securityorglevel s
       WHERE o.orglevelkey = s.orglevelkey AND
             o.orgentrykey = s.orgentrykey AND
             o.orglevelkey = @i_orglevelkey AND
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
  
GO
GRANT EXEC ON qscale_get_all_orgentries_for_scale TO PUBLIC
GO


