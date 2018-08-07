IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.qproject_relate_mktg_plans_HMH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.qproject_relate_mktg_plans_HMH
GO

CREATE PROCEDURE dbo.qproject_relate_mktg_plans_HMH
 (@i_campaignprojectkey integer,
  @i_orgentrychangeind  integer,
  @i_lastuserid     varchar(30),
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/***************************************************************************************************
**  Name: qproject_relate_mktg_plans_HMH
**  Desc: Relate a Marketing Campaign to a Marketing Plan with the same season and orgentry.
**        Replace existing relationship.
**  Case: 39202
**
**  Auth: Colman
**  Date: Sept 1, 2016
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
  @v_seasoncode1 INT,
  @v_seasoncode2 INT,
  @v_count INT,
  @v_related_plan_count INT,
  @v_orglevelkey INT,
  @v_orgentrykey INT,
  @v_plancode INT,
  @v_plansubcode INT,
  @v_campaigncode INT,
  @v_campaignsubcode INT,
  @v_planprojectkey INT,
  @v_existingplanprojectkey INT,
  @v_taqprojectrelationshipkey INT,
  @v_donotrelateind INT,
  @v_donotrelatemisckey INT,
  @v_relationshipcodecampaign INT,
  @v_relationshipcodeplan INT

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_taqprojectrelationshipkey = 0
  SET @v_seasoncode1 = 0
  SET @v_seasoncode2 = 0

  IF @i_campaignprojectkey IS NULL OR @i_campaignprojectkey <= 0 BEGIN
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

  -- Check for flag disabling auto relate for this campaign
  SELECT @v_donotrelatemisckey = misckey FROM bookmiscitems WHERE miscname = 'Do Not Relate'
  SET @v_donotrelateind = 0
  SELECT @v_donotrelateind = COALESCE(longvalue,0) FROM taqprojectmisc WHERE taqprojectkey = @i_campaignprojectkey AND misckey = @v_donotrelatemisckey
  IF @v_donotrelateind > 0
    RETURN
    
  SET @v_relationshipcodecampaign = 20 -- HMH specific -- Marketing Campaign (Plan)
  SET @v_relationshipcodeplan     = 18 -- HMH specific -- Marketing Plan
  
  -- Check if the Campaign is currently related to a Plan
  SELECT @v_taqprojectrelationshipkey = r.taqprojectrelationshipkey, @v_existingplanprojectkey = r.taqprojectkey, @v_seasoncode1 = coalesce(pc.seasoncode,0), @v_seasoncode2 = coalesce(pp.seasoncode, 0)
  FROM projectrelationshipview r
    JOIN taqproject pc ON pc.taqprojectkey = r.relatedprojectkey
    JOIN taqproject pp ON pp.taqprojectkey = r.taqprojectkey
  WHERE relatedprojectkey = @i_campaignprojectkey 
    AND relationshipcode = @v_relationshipcodecampaign
    
  IF @v_taqprojectrelationshipkey > 0 
  BEGIN
    -- delete the relationship if the seasons no longer match or the campaign orgentry changed
    IF @i_orgentrychangeind = 1 OR (@v_seasoncode1 <> @v_seasoncode2 AND @v_seasoncode1 <> 0 AND @v_seasoncode2 <> 0)
      DELETE FROM taqprojectrelationship WHERE taqprojectrelationshipkey = @v_taqprojectrelationshipkey
    -- If seasons match, we are done
    ELSE IF @v_seasoncode1 = @v_seasoncode2
      RETURN
  END

  SELECT @v_campaigncode = datacode, @v_campaignsubcode = datasubcode from subgentables where tableid = 550 and qsicode = 9
  SELECT @v_plancode = datacode, @v_plansubcode = datasubcode from subgentables where tableid = 550 and qsicode = 10
  SELECT @v_seasoncode = COALESCE(seasoncode,0) FROM taqproject where taqprojectkey = @i_campaignprojectkey

  -- Get orgentry and orglevel for lowest (most specific) campaign orglevel
  SELECT @v_orglevelkey = a.orglevelkey, @v_orgentrykey = a.orgentrykey
  FROM taqprojectorgentry a
  INNER JOIN (
      SELECT taqprojectkey, MAX(orglevelkey) orglevelkey
      FROM taqprojectorgentry
      GROUP BY taqprojectkey
  ) b ON a.taqprojectkey = b.taqprojectkey AND a.orglevelkey = b.orglevelkey AND a.taqprojectkey = @i_campaignprojectkey

  SET @v_planprojectkey = 0
  
  -- Find the first Marketing Plan with the Marketing Campaign's seasoncode and orginfo
  WHILE (@v_orglevelkey > 0)
  BEGIN
    SELECT @v_count = COUNT(*) 
    FROM taqproject p 
    INNER JOIN taqprojectorgentry o 
      ON p.taqprojectkey = o.taqprojectkey AND o.orglevelkey = @v_orglevelkey AND o.orgentrykey = @v_orgentrykey
    WHERE p.searchitemcode = @v_plancode AND p.usageclasscode = @v_plansubcode AND p.seasoncode = @v_seasoncode
      AND NOT EXISTS (SELECT * FROM taqprojectorgentry so WHERE so.taqprojectkey = o.taqprojectkey AND so.orglevelkey > o.orglevelkey)
    
    -- exec qutl_trace 'qproject_relate_mktg_plans_HMH', '@v_count', @v_count, NULL, '@v_orglevelkey', @v_orglevelkey, NULL, '@v_orgentrykey', @v_orgentrykey, NULL

    IF @v_count > 0 
    BEGIN
      -- Select Plan with matching orgentry and season (there should only be one, but if not take the first)
      SELECT TOP(1) @v_planprojectkey = p.taqprojectkey
      FROM taqproject p 
      INNER JOIN taqprojectorgentry o 
        ON p.taqprojectkey = o.taqprojectkey AND o.orglevelkey = @v_orglevelkey AND o.orgentrykey = @v_orgentrykey
      WHERE p.searchitemcode = @v_plancode AND p.usageclasscode = @v_plansubcode AND p.seasoncode = @v_seasoncode
        AND NOT EXISTS (SELECT * FROM taqprojectorgentry so WHERE so.taqprojectkey = o.taqprojectkey AND so.orglevelkey > o.orglevelkey)
      
      SELECT @v_related_plan_count = COUNT(*) FROM projectrelationshipview WHERE relatedprojectkey = @i_campaignprojectkey AND relationshipcode = @v_relationshipcodecampaign
      IF @v_related_plan_count = 1
      BEGIN
        -- Select existing Campaign to Plan relationship key
        SELECT @v_taqprojectrelationshipkey = taqprojectrelationshipkey, @v_existingplanprojectkey = taqprojectkey
        FROM projectrelationshipview
        WHERE relatedprojectkey = @i_campaignprojectkey 
          AND relationshipcode = @v_relationshipcodecampaign 
        
        -- exec qutl_trace 'qproject_relate_mktg_plans_HMH', '@v_existingplanprojectkey', @v_existingplanprojectkey, NULL, '@v_planprojectkey', @v_planprojectkey
        
        -- Check if the Campaign is already related to the correct plan
        IF @v_existingplanprojectkey = @v_planprojectkey
          RETURN
        ELSE
          DELETE FROM taqprojectrelationship WHERE taqprojectrelationshipkey = @v_taqprojectrelationshipkey
      END
      ELSE
      BEGIN
        IF @v_related_plan_count > 1 -- This should not happen but we need to handle it if it does
          DELETE FROM taqprojectrelationship WHERE taqprojectkey1 = @i_campaignprojectkey AND relationshipcode1 = @v_relationshipcodecampaign AND relationshipcode2 = @v_relationshipcodeplan
      END
      
      EXEC get_next_key @v_lastuserid, @v_taqprojectrelationshipkey OUTPUT
      
      INSERT INTO taqprojectrelationship 
        (taqprojectrelationshipkey, taqprojectkey1, taqprojectkey2, 
         relationshipcode1, relationshipcode2, keyind, lastuserid, lastmaintdate)
      VALUES
        (@v_taqprojectrelationshipkey, @i_campaignprojectkey, @v_planprojectkey, 
         @v_relationshipcodecampaign, @v_relationshipcodeplan, 0, @v_lastuserid, getdate())

      RETURN
    END

    -- No Plan found, try the next higher orglevel
    SET @v_orglevelkey = @v_orglevelkey - 1
    SELECT @v_orgentrykey = orgentrykey
    FROM taqprojectorgentry
    WHERE taqprojectkey = @i_campaignprojectkey AND orglevelkey = @v_orglevelkey

  END -- WHILE (@v_orglevelkey > 0)
  
END

GO

GRANT EXEC on dbo.qproject_relate_mktg_plans_HMH to PUBLIC
GO
