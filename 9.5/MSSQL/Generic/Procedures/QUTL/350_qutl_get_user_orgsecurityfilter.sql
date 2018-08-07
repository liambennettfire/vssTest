if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_user_orgsecurityfilter') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_user_orgsecurityfilter
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_get_user_orgsecurityfilter
 (@i_userkey      integer,
  @i_updateonly   integer,
  @i_filterkey    integer,
  @o_orgfilter    varchar(MAX) output,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/*****************************************************************************************
**  Name: qutl_get_user_orgsecurityfilter
**  Desc: This stored procedure returns a string of all orgentrykeys
**        this user has either ReadOnly or Update access.
**        The returned orgentrykeys are at the level we check orglevel security AND ABOVE.
**
**    Auth: Kate
**    Date: 14 October 2004 
**
**  Changes:
**      7/7/9 - Lisa - passing filterkey so I can use with filters other
**                      than user org access level
**
****************************************************************************************/

  DECLARE
    @v_checkorgentrykey INT,
    @v_accessind  INT,
    @v_orgentryparentkey  INT,
    @v_charindex  INT,
    @v_temporgentrykey  INT,
    @v_temporgentrykeystr VARCHAR(10),
    @v_filterorglevelkey  INT,
    @v_orgsecurityfilter  VARCHAR(MAX),
    @error_var  INT,
    @rowcount_var INT

  SET @v_orgsecurityfilter = '-1'
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- Get the level for org access security
  SELECT @v_filterorglevelkey = filterorglevelkey
  FROM filterorglevel
  WHERE filterkey = @i_filterkey
  
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to get filterorglevelkey for filterkey=' + CONVERT(VARCHAR, @i_filterkey) + '.'
    RETURN
  END
  
  -- Get all orglevel security rows for this user and user's security group
  IF (@i_updateonly > 0)
   BEGIN
    -- Get only Full Access rows (accessind=2)
    DECLARE orgsecurity_cur CURSOR FOR
      SELECT orgentrykey, accessind
      FROM securityorglevel 
      WHERE orglevelkey = @v_filterorglevelkey AND
        userkey = @i_userkey AND
        accessind = 2
    UNION
      SELECT orgentrykey, accessind
      FROM securityorglevel
      WHERE orglevelkey = @v_filterorglevelkey AND
        accessind = 2 AND
        securitygroupkey IN 
          (SELECT securitygroupkey FROM qsiusers 
          WHERE userkey = @i_userkey) AND
        orgentrykey NOT IN 
          (SELECT orgentrykey FROM securityorglevel s
          WHERE s.orglevelkey = @v_filterorglevelkey AND
                s.userkey = @i_userkey AND
                s.accessind <> 2)
   END
  ELSE
   BEGIN
    -- Get Full Access (accessind=2) and Read Only rows (accessind=1)
    DECLARE orgsecurity_cur CURSOR FOR
      SELECT orgentrykey, accessind
      FROM securityorglevel 
      WHERE orglevelkey = @v_filterorglevelkey AND
        userkey = @i_userkey AND
        accessind > 0
    UNION
      SELECT orgentrykey, accessind
      FROM securityorglevel
      WHERE orglevelkey = @v_filterorglevelkey AND
        accessind > 0 AND
        securitygroupkey IN 
          (SELECT securitygroupkey FROM qsiusers 
          WHERE userkey = @i_userkey) AND
        orgentrykey NOT IN 
          (SELECT orgentrykey FROM securityorglevel s
          WHERE s.orglevelkey = @v_filterorglevelkey AND
                s.userkey = @i_userkey AND
                s.accessind = 0)
   END
  
  OPEN orgsecurity_cur  
  FETCH NEXT FROM orgsecurity_cur INTO @v_checkorgentrykey, @v_accessind
  
  WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
  BEGIN
    -- Initialize parentkey to the org security orgentrykey being processed so that it gets processed first
    SET @v_temporgentrykey = @v_checkorgentrykey
    
    WHILE (@v_temporgentrykey <> 0 )
    BEGIN
      -- Set the org security filter
      IF @v_orgsecurityfilter = '-1'
        SET @v_orgsecurityfilter = CONVERT(VARCHAR, @v_temporgentrykey)
      ELSE
        BEGIN
          -- 8/3/05 KW - Add this orgentrykey only if not found in the orgentryfilter
          SET @v_temporgentrykeystr = CONVERT(VARCHAR, @v_temporgentrykey)
          SET @v_charindex = CHARINDEX(@v_temporgentrykeystr + ',', @v_orgsecurityfilter + ',')
          IF @v_charindex > 1
            BEGIN
              SET @v_charindex = CHARINDEX(',' + @v_temporgentrykeystr + ',', @v_orgsecurityfilter)
            END            
          IF @v_charindex = 0
            BEGIN
              SET @v_orgsecurityfilter = @v_orgsecurityfilter + ',' + @v_temporgentrykeystr
            END
        END
   
      -- Get the parent orgentrykey for the selected orgentry
      SELECT @v_orgentryparentkey = orgentryparentkey
      FROM orgentry
      WHERE orgentrykey = @v_temporgentrykey
      
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 OR @rowcount_var = 0
      BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to get orgentryparentkey from orgentry table (orgentrykey=' + CONVERT(VARCHAR, @v_temporgentrykey) + ')'
        BREAK
      END
      
      -- Include parent orgentrykey in the org security filter           
      SET @v_temporgentrykey = @v_orgentryparentkey
      
    END --WHILE (@v_temporgentrykey <> 0 )
          
    FETCH NEXT FROM orgsecurity_cur INTO @v_checkorgentrykey, @v_accessind
  END --WHILE (@@FETCH_STATUS = 0)
    
  CLOSE orgsecurity_cur 
  DEALLOCATE orgsecurity_cur

  SET @o_orgfilter = @v_orgsecurityfilter
  
  -- For scales, include scale orgentrykey=0 (ALL orgentries)
  IF @i_filterkey = 11
    SET @o_orgfilter = @o_orgfilter + ',0'
    
GO
GRANT EXEC ON qutl_get_user_orgsecurityfilter TO PUBLIC
GO


