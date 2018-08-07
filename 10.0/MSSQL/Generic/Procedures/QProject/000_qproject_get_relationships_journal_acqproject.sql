if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_relationships_journal_acqproject') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_relationships_journal_acqproject
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_relationships_journal_acqproject
 (@i_projectkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_relationships_journal_acqproject
**  Desc: This stored procedure returns all relationships for the 
**        Journal(Acquisition Project) Tab. 
**
**    Auth: Alan Katzen
**    Date: 6 March 2008
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
**  --------     --------    -------------------------------------------
**  06/21/2018   Colman      51369 - DUP: Edits to 'Journal Information' Tab 
**  06/21/2018   Colman      51661
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @qsiRoleType1 varchar(3)
  DECLARE @qsiRoleType2 varchar(3)

  DECLARE @Misc114    varchar(50)    -- For DUP, holds Journal Title
  DECLARE @Misc114Label  varchar(100)
  DECLARE @ProdNum2    varchar(50)    -- For DUP, holds ISSN
  DECLARE @ProdNum2Label  varchar(100)
  DECLARE @ProdNum3    varchar(50)    -- For DUP, holds eISSN
  DECLARE @ProdNum3Label  varchar(100)
  DECLARE @ProdNum13    varchar(50)    -- For DUP, holds Acct. Code
  DECLARE @ProdNum13Label  varchar(100)
  DECLARE @ECollection       varchar(50)     -- Holds Electronic collections for DUP
  DECLARE @ECollectionLabel  varchar(100)
  
  DECLARE @v_journalkey INT
  DECLARE @v_thisrelationship_qsicode INT
  DECLARE @v_otherrelationship_qsicode INT
  DECLARE @ElectronicCollection varchar(1000)
  DECLARE @TempStr      varchar(1000)

  -- Get the location with the projectkey, this will also return the element key as well.
  -- The current @i_projectkey is for the acq_project and I need to resolve for the Journal for the elements below...

  -- get journalkey from relationship
  SET @v_thisrelationship_qsicode = 5 -- Acquisition Project (for Journal)
  SET @v_otherrelationship_qsicode = 6 -- Journal
  SELECT @v_journalkey = COALESCE(dbo.qproject_get_otherprojectkey(@i_projectkey,@v_thisrelationship_qsicode,@v_otherrelationship_qsicode),0)

  --SELECT @qsiRoleType1 = 10 -- Production Coordinator
  SELECT @qsiRoleType2 = 11 -- AME (Assistant Managing Editor)

/************************************************************************************
 **   Build the Electronic Collections string required by DUP
 ************************************************************************************/
  SELECT @TempStr = ''
    
  DECLARE cur1 CURSOR FOR
  SELECT CASE WHEN g2.datadesc is null
          THEN rtrim(ltrim(g1.datadesc))
          ELSE rtrim(g1.datadesc) + '/' + ltrim(rtrim(g2.datadesc))
      END AS ecollection
  FROM taqprojectsubjectcategory c
  JOIN gentables g1 ON c.categorytableid = g1.tableid and c.categorycode = g1.datacode
  LEFT JOIN subgentables g2 ON c.categorysubcode = g2.datasubcode and c.categorycode = g2.datacode
  WHERE categorytableid = 435 and c.taqprojectkey = @v_journalkey
      
  OPEN cur1
    
  FETCH NEXT FROM cur1 INTO @ElectronicCollection
    
  WHILE (@@FETCH_STATUS = 0) 
  BEGIN    
      if LEN(@TempStr) = 0 
      begin
        select @TempStr = @ElectronicCollection 
      end
      else
      begin
        select @TempStr = @TempStr + ',' + @ElectronicCollection
      end
      FETCH NEXT FROM cur1 INTO @ElectronicCollection
  END
    
  CLOSE cur1 
  DEALLOCATE cur1
     
  select @ECollection = substring(@TempStr, 1, 50);
  select @ECollectionLabel = 'Electronic Collections'
   
  /********************************************************************************************/
   
  -- ISSN 
  SELECT @ProdNum2 = ( SELECT p.productnumber
  FROM taqproductnumbers p, gentables g
  WHERE p.productidcode = g.datacode AND
      g.tableid = 594 AND
      p.taqprojectkey = @v_journalkey AND
    ( p.productidcode = 2 ) )
  SELECT @ProdNum2Label = ( select datadesc from gentables where tableid = 594 and datacode = 2 )

  -- EISSN
  SELECT @ProdNum3 = ( SELECT p.productnumber
  FROM taqproductnumbers p, gentables g
  WHERE p.productidcode = g.datacode AND
      g.tableid = 594 AND
      p.taqprojectkey = @v_journalkey AND
    ( p.productidcode = 3 ) )
  SELECT @ProdNum3Label = ( select datadesc from gentables where tableid = 594 and datacode = 3 )

  --  Acct. Code
  SELECT @ProdNum13 = ( SELECT p.productnumber
  FROM taqproductnumbers p, gentables g
  WHERE p.productidcode = g.datacode AND
      g.tableid = 594 AND
      p.taqprojectkey = @v_journalkey AND
    ( p.productidcode = 13 ) )
  SELECT @ProdNum13Label = ( select datadesc from gentables where tableid = 594 and datacode = 13 )

  -- Journal Title
  SELECT @Misc114Label = misclabel
  FROM bookmiscitems WHERE misckey = 114
  SELECT @Misc114 = textvalue
    FROM taqprojectmisc
   WHERE (misckey = 114) AND (taqprojectkey = @i_projectkey)
 
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT,
          @v_gentablesrelationshipkey INT,
          @v_thisreldatacode INT,
          @v_otherreldatacode INT,
          @v_qsicode INT

  SELECT @v_gentablesrelationshipkey = COALESCE(gentablesrelationshipkey,0)
    FROM gentablesrelationships
   WHERE gentable1id = 582
     and gentable2id = 583

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error acessing gentablesrelationships: projectkey = ' + cast(@i_projectkey AS VARCHAR)
    RETURN  
  END 

  IF @v_gentablesrelationshipkey <= 0 BEGIN
    RETURN
  END

  SELECT @v_thisreldatacode = COALESCE(datacode,0)
    FROM gentables
   WHERE tableid = 582
     AND qsicode = 5 -- Acq Project (for Journal)

  SELECT @v_otherreldatacode = COALESCE(datacode,0)
    FROM gentables
   WHERE tableid = 582
     AND qsicode = 6  -- Journal(for Acq Project)

  -- Journal for Acq Project tab
  SET @v_qsicode = 10

  SELECT 
      relatedprojectkey thisprojectkey, 
      taqprojectkey otherprojectkey, 
      relationshipcode thisrelationshipcode, 
      dbo.get_gentables_desc(582,relationshipcode,'long') thisrelationshipdesc,
      relationshipcode2 otherrelationshipcode, 
      c.projecttitle otherprojectdisplayname,
      c.projectstatusdesc otherprojectstatus,  
      COALESCE(c.projectstatus,0) otherprojectstatuscode,  
      c.projectparticipants otherprojectparticipants,  
      r.taqprojectrelationshipkey, r.relationshipaddtldescription, r.keyind, r.sortorder,
      c.searchitemcode otheritemtypecode, c.usageclasscode otherusageclasscode, 
      cast(COALESCE(c.searchitemcode,0) AS VARCHAR) + '|' + cast(COALESCE(c.usageclasscode,0) AS VARCHAR) otheritemtypeusageclass,
      c.usageclasscodedesc otherusageclasscodedesc, c.projecttype, c.projecttypedesc, c.projectowner, 0 hiddenorder,
      r.indicator1, quantity1, quantity2, quantity3, quantity4,

      @ECollectionLabel ecollectionlabel, @ECollection ecollection,

      -- Product Number fields
      @ProdNum2 prodnum2, @ProdNum2Label prodnum2label, 
      @ProdNum3 prodnum3, @ProdNum3Label prodnum3label, 
      @ProdNum13 prodnum13, @ProdNum13Label prodnum13label, 
            
      -- Misc Fields
      dbo.qproject_get_misc_value(@v_journalkey,114) misc114, dbo.qutl_get_misc_label(114) misc114label,
      dbo.qproject_get_misc_value(@v_journalkey,115) misc115, dbo.qutl_get_misc_label(115) misc115label,
      dbo.qproject_get_misc_value(@v_journalkey,125) misc125, dbo.qutl_get_misc_label(125) misc125label,
      dbo.qproject_get_misc_value(@v_journalkey,278) misc278, dbo.qutl_get_misc_label(278) misc278label,
      dbo.qutl_get_misc_label(47)  misc47label,
      dbo.qproject_get_misc_datacode_value(@v_journalkey,47)  misc47datacode,
      dbo.qproject_get_misc_datasubcode_value(@v_journalkey,47)  misc47datasubcode,
      dbo.qutl_get_misc_label(734)  misc734label,
      dbo.qproject_get_misc_datacode_value(@v_journalkey, 734)  misc734datacode,
      dbo.qproject_get_misc_datasubcode_value(@v_journalkey, 734)  misc734datasubcode

  FROM projectrelationshipview r, coreprojectinfo c 
  WHERE r.taqprojectkey = c.projectkey AND 
      r.relatedprojectkey > 0 AND 
      r.relatedprojectkey = @i_projectkey AND 
      relationshipcode = @v_thisreldatacode AND 
      relationshipcode2 = @v_otherreldatacode     
  ORDER BY r.keyind DESC, r.sortorder ASC, thisrelationshipcode ASC, otherrelationshipcode ASC

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found on taqprojectrelationship (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_projectkey AS VARCHAR)   
  END 

GO

GRANT EXEC ON qproject_get_relationships_journal_acqproject TO PUBLIC
GO
