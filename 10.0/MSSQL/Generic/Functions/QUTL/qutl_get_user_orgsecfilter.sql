if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_user_orgsecfilter') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qutl_get_user_orgsecfilter
GO

CREATE FUNCTION dbo.qutl_get_user_orgsecfilter
(
  @i_userkey      integer,
  @i_updateonly   integer,
  @i_filterkey    integer
) 
RETURNS VARCHAR(MAX)

/*******************************************************************************************************
**  Name: qutl_get_user_orgsecfilter
**  Desc: This function returns a string of all orgentrykeys this user has either ReadOnly or Update access.
**        The returned orgentrykeys are at the level we check orglevel security AND ABOVE.
**
**  Auth: Kate Wiewiora
**  Date: May 9 2014
*******************************************************************************************************/

BEGIN
  DECLARE
    @v_checkorgentrykey INT,
    @v_accessind  INT,
    @v_orgentryparentkey  INT,
    @v_charindex  INT,
    @v_temporgentrykey  INT,
    @v_temporgentrykeystr VARCHAR(10),
    @v_filterorglevelkey  INT,
    @v_orgsecurityfilter  VARCHAR(MAX),
    @v_orgfilter VARCHAR(MAX)

  SET @v_orgsecurityfilter = '-1'
  
  -- Get the level for org access security
  SELECT @v_filterorglevelkey = filterorglevelkey
  FROM filterorglevel
  WHERE filterkey = @i_filterkey
   
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
            
      -- Include parent orgentrykey in the org security filter           
      SET @v_temporgentrykey = @v_orgentryparentkey
      
    END --WHILE (@v_temporgentrykey <> 0 )
          
    FETCH NEXT FROM orgsecurity_cur INTO @v_checkorgentrykey, @v_accessind
  END --WHILE (@@FETCH_STATUS = 0)
    
  CLOSE orgsecurity_cur 
  DEALLOCATE orgsecurity_cur

  SET @v_orgfilter = @v_orgsecurityfilter
  
  -- For scales, include scale orgentrykey=0 (ALL orgentries)
  IF @i_filterkey = 11
    SET @v_orgfilter = @v_orgfilter + ',0'

  RETURN '(' + @v_orgfilter + ')'
  
END
GO

GRANT EXEC ON dbo.qutl_get_user_orgsecfilter TO public
GO
