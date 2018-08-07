IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.taqprojectrelationship_dupcheck_HMH') AND type = 'TR')
	DROP TRIGGER dbo.taqprojectrelationship_dupcheck_HMH
GO

CREATE TRIGGER taqprojectrelationship_dupcheck_HMH ON taqprojectrelationship
FOR INSERT AS

BEGIN

  DECLARE @v_projectkey1 INT,
          @v_projectkey2 INT,
          @v_relationshipcode1 INT,
          @v_relationshipcode2 INT,
          @v_taqprojectrelationshipkey INT,
          @v_count INT
          
    SELECT  @v_taqprojectrelationshipkey = i.taqprojectrelationshipkey, 
            @v_projectkey1 = i.taqprojectkey1, @v_projectkey2 = i.taqprojectkey2, 
            @v_relationshipcode1 = i.relationshipcode1, @v_relationshipcode2 = i.relationshipcode2
    FROM inserted i

    -- If there is a pre-existing duplicate row, delete it.
    -- This will occur, for example, when a new Mktg Campaign is created from the Campaign tab on the Mktg Plan.
    -- The qproject_relate_mktg_plans_HMH procedure will auto-create a relationship that will then be duplicated
    -- by the code creating the new campaign because it originates from the campaign tab.
    SELECT @v_count = COUNT(*) 
    FROM taqprojectrelationship 
    WHERE taqprojectrelationshipkey <> @v_taqprojectrelationshipkey
      AND @v_projectkey1 = taqprojectkey1
      AND @v_projectkey2 = taqprojectkey2
      AND @v_relationshipcode1 = relationshipcode1
      AND @v_relationshipcode2 = relationshipcode2

    IF @v_count > 0
      DELETE FROM taqprojectrelationship 
      WHERE taqprojectrelationshipkey = @v_taqprojectrelationshipkey

END
