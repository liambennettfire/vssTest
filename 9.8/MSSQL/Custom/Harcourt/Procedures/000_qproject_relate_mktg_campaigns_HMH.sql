IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.qproject_relate_mktg_campaigns_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.qproject_relate_mktg_campaigns_HMH
GO

CREATE PROCEDURE dbo.qproject_relate_mktg_campaigns_HMH
 (@i_planprojectkey integer,
  @i_lastuserid     varchar(30),
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/***************************************************************************************************
**  Name: qproject_relate_mktg_campaigns_HMH
**  Desc: Relate a Marketing Plan to all Marketing Campaigns by season and orgentry that
**        are not already related to a Marketing Plan. Return message listing all qualifying
**        Campaigns that already have a related Plan
**        Relate to all Marketing Campaigns with the Marketing Plan's seasoncode and orglevel/orgentry 
**        from most specific to least. For example, if the Plan is at orglevel 3, relate Campaigns at 
**        orglevel 3 that match, then Campaigns at orglevel 2 etc.
**        Also match any Campaigns at lower orglevels that match at the Plan's orglevel.
**
**  Auth: Colman
**  Date: July 15 2016
**
****************************************************************************************************
**  Change History
****************************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -----------------------------------------------------------------------
*
****************************************************************************************************/

DECLARE
  @v_lastuserid  varchar(30),
  @v_seasoncode INT,
  @v_orglevelkey INT,
  @v_orgentrykey INT,
  @v_plancode INT,
  @v_plansubcode INT,
  @v_campaigncode INT,
  @v_campaignsubcode INT,
  @v_campaignprojectkey INT,
  @v_taqprojectrelationshipkey INT,
  @v_new_taqprojecctrelationshipkey INT,
  @v_donotrelateind INT,
  @v_donotrelatemisckey INT,
  @v_campaigntitle varchar(255)

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_planprojectkey IS NULL OR @i_planprojectkey <= 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Invalid projectkey.'
    RETURN
  END

  IF @i_lastuserid IS NULL BEGIN
	SELECT @v_lastuserid = 'QSIADMIN'
  END
  ELSE BEGIN
    SET @v_lastuserid = @i_lastuserid
  END

  SELECT @v_campaigncode = datacode, @v_campaignsubcode = datasubcode from subgentables where tableid = 550 and qsicode = 9
  SELECT @v_plancode = datacode, @v_plansubcode = datasubcode from subgentables where tableid = 550 and qsicode = 10
  SELECT @v_seasoncode = COALESCE(seasoncode,0) FROM taqproject where taqprojectkey = @i_planprojectkey
  -- Check for flag disabling auto relate for this campaign
  SELECT @v_donotrelatemisckey = misckey FROM bookmiscitems WHERE miscname = 'Do Not Relate'

  -- Get orgentry and orglevel for most specific plan orglevel
  SELECT @v_orglevelkey = a.orglevelkey, @v_orgentrykey = a.orgentrykey
  FROM taqprojectorgentry a
  INNER JOIN (
      SELECT taqprojectkey, MAX(orglevelkey) orglevelkey
      FROM taqprojectorgentry
      GROUP BY taqprojectkey
  ) b ON a.taqprojectkey = b.taqprojectkey AND a.orglevelkey = b.orglevelkey AND a.taqprojectkey = @i_planprojectkey

  -- First look for campaigns that match on the plan's orglevel regardless of whether the campaign is actually at a lower level
  -- For example a Plan at orglevel 3 will also match campaigns at orglevel 4 and 5 that match at orglevel 3
  DECLARE marketingcampaign_cur CURSOR FOR
  SELECT COALESCE(r.taqprojectrelationshipkey, 0), p.taqprojectkey, p.taqprojecttitle, COALESCE(m.longvalue,0) donotrelate
  FROM taqproject p
  LEFT OUTER JOIN taqprojectmisc m ON m.taqprojectkey = p.taqprojectkey AND m.misckey = @v_donotrelatemisckey
  LEFT OUTER JOIN projectrelationshipview r ON p.taqprojectkey = r.taqprojectkey AND r.relationshipcode = 18
  WHERE 
    p.searchitemcode = @v_campaigncode AND 
    p.usageclasscode = @v_campaignsubcode AND 
    p.seasoncode = @v_seasoncode AND
    p.taqprojectkey IN (SELECT taqprojectkey FROM taqprojectorgentry WHERE orglevelkey = @v_orglevelkey AND orgentrykey = @v_orgentrykey)

  OPEN marketingcampaign_cur

  FETCH marketingcampaign_cur
  INTO @v_taqprojectrelationshipkey, @v_campaignprojectkey, @v_campaigntitle, @v_donotrelateind

  WHILE (@@FETCH_STATUS = 0)
  BEGIN
    IF @v_taqprojectrelationshipkey = 0 AND @v_donotrelateind = 0
    BEGIN
      EXEC get_next_key @v_lastuserid, @v_new_taqprojecctrelationshipkey OUTPUT
      
      INSERT INTO taqprojectrelationship 
        (taqprojectrelationshipkey, taqprojectkey1, taqprojectkey2, 
         relationshipcode1, relationshipcode2, keyind, lastuserid, lastmaintdate)
      VALUES
        (@v_new_taqprojecctrelationshipkey, @v_campaignprojectkey, @i_planprojectkey, 
         20, 18, 0, @v_lastuserid, getdate())
    END 
    ELSE IF @v_donotrelateind = 0
    BEGIN
      IF @o_error_desc = ''
        SET @o_error_desc = 'Marketing Campaign(s) found that match this Plan’s org level and season but are already attached to another Plan:<br/><br/>'
      ELSE
        SET @o_error_desc = @o_error_desc + '<br/>'

      SET @o_error_desc = @o_error_desc + @v_campaigntitle
    END

    FETCH marketingcampaign_cur
    INTO @v_taqprojectrelationshipkey, @v_campaignprojectkey, @v_campaigntitle, @v_donotrelateind
  END

  CLOSE marketingcampaign_cur
  DEALLOCATE marketingcampaign_cur

  -- Now look for Campaigns at higher org levels
  SET @v_orglevelkey = @v_orglevelkey - 1
  SELECT @v_orgentrykey = orgentrykey
  FROM taqprojectorgentry
  WHERE taqprojectkey = @i_planprojectkey AND orglevelkey = @v_orglevelkey
  
  WHILE (@v_orglevelkey > 0)
  BEGIN
    DECLARE marketingcampaign_cur CURSOR FOR
    SELECT COALESCE(r.taqprojectrelationshipkey, 0), p.taqprojectkey, p.taqprojecttitle 
    FROM taqproject p
    LEFT OUTER JOIN projectrelationshipview r ON p.taqprojectkey = r.taqprojectkey AND r.relationshipcode = 18
    WHERE 
      p.searchitemcode = @v_campaigncode AND 
      p.usageclasscode = @v_campaignsubcode AND 
      p.seasoncode = @v_seasoncode AND
      p.taqprojectkey IN (SELECT taqprojectkey FROM taqprojectorgentry WHERE orglevelkey = @v_orglevelkey AND orgentrykey = @v_orgentrykey) AND
      p.taqprojectkey NOT IN (SELECT taqprojectkey FROM taqprojectorgentry WHERE orglevelkey > @v_orglevelkey) -- exclude campaigns at lower levels

      OPEN marketingcampaign_cur

      FETCH marketingcampaign_cur
      INTO @v_taqprojectrelationshipkey, @v_campaignprojectkey, @v_campaigntitle

      WHILE (@@FETCH_STATUS = 0)
      BEGIN
        IF @v_taqprojectrelationshipkey = 0
        BEGIN
          EXEC get_next_key @v_lastuserid, @v_new_taqprojecctrelationshipkey OUTPUT
          
          INSERT INTO taqprojectrelationship 
            (taqprojectrelationshipkey, taqprojectkey1, taqprojectkey2, 
             relationshipcode1, relationshipcode2, keyind, lastuserid, lastmaintdate)
          VALUES
            (@v_new_taqprojecctrelationshipkey, @v_campaignprojectkey, @i_planprojectkey, 
             20, 18, 0, @v_lastuserid, getdate())
          -- PRINT 'Inserted relationship: ' + convert(varchar, @v_campaignprojectkey) + ' ' + convert(varchar, @i_planprojectkey)
        END 
        ELSE BEGIN
          IF @o_error_desc = ''
            SET @o_error_desc = 'Marketing Campaign(s) found that match this Plan’s org level and season but are already attached to another Plan:<br/><br/>'
          ELSE
            SET @o_error_desc = @o_error_desc + '<br/>'

          SET @o_error_desc = @o_error_desc + @v_campaigntitle
        END

        FETCH marketingcampaign_cur
        INTO @v_taqprojectrelationshipkey, @v_campaignprojectkey, @v_campaigntitle
      END

      CLOSE marketingcampaign_cur
      DEALLOCATE marketingcampaign_cur
    
      -- Try the next higher orglevel
      SET @v_orglevelkey = @v_orglevelkey - 1
      SELECT @v_orgentrykey = orgentrykey
      FROM taqprojectorgentry
      WHERE taqprojectkey = @i_planprojectkey AND orglevelkey = @v_orglevelkey
    END -- WHILE
    
    IF @o_error_desc <> ''
      SET @o_error_code = 1    
  
END

GO

GRANT EXEC on dbo.qproject_relate_mktg_campaigns_HMH to PUBLIC
GO
