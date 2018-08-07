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
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @qsiRoleType1 varchar(3)
  DECLARE @qsiRoleType2 varchar(3)

  DECLARE @Misc13		varchar(50)		-- For DUP, holds product acronym
  DECLARE @Misc13Label	varchar(100)
  DECLARE @Misc14		varchar(50)		-- For DUP, holds ISSN
  DECLARE @Misc14Label	varchar(100)
  DECLARE @Misc15		varchar(50)		-- For DUP, holds eISSN
  DECLARE @Misc15Label	varchar(100)
  DECLARE @Misc16		varchar(50)		-- For DUP, holds Linking ISSN
  DECLARE @Misc16Label	varchar(100)
  DECLARE @Misc32		varchar(50)		-- Holds contact role
  DECLARE @Misc32Label	varchar(100)
  DECLARE @Misc33		varchar(50)		-- Holds contact role
  DECLARE @Misc33Label	varchar(100)
  DECLARE @Misc35       varchar(50)     -- Holds Electronic collections for DUP
  DECLARE @Misc35Label  varchar(100)
  
  DECLARE @Misc23		varchar(50)		-- Holds online content location 
  DECLARE @Misc23Label	varchar(100)
	  SET @Misc23Label = 'Online Content Location'
  DECLARE @v_journalkey INT
  DECLARE @v_thisrelationship_qsicode INT
  DECLARE @v_otherrelationship_qsicode INT
  DECLARE @v_elementkey INT
  
  DECLARE @Misc22		varchar(50)		-- Holds online content date range 1
  DECLARE @v_beginDate varchar(20)
  DECLARE @v_endDate varchar (20)
  DECLARE @Misc22Label	varchar(100)
  
  DECLARE @Misc34		varchar(50)		-- Holds online content volume range 1
  DECLARE @Misc34Label	varchar(100)

  DECLARE @Misc119      varchar(50)     -- Holds Acct.Code for DUP
  
  DECLARE @Society1		varchar(255)
  DECLARE @Society1Label varchar(100)
  DECLARE @Society2		varchar(255)
  DECLARE @Society2Label varchar(100)
  DECLARE @loopCtr		INT
  DECLARE @GroupName	varchar(255)
  DECLARE @ElectronicCollection varchar(1000)
  DECLARE @TempStr      varchar(1000)

  SELECT @loopCtr = 1
  
  -- Get the location with the projectkey, this will also return the element key as well.
  -- The current @i_projectkey is for the acq_project and I need to resolve for the Journal for the elements below...

      -- get journalkey from relationship
      SET @v_thisrelationship_qsicode = 5 -- Acquisition Project (for Journal)
      SET @v_otherrelationship_qsicode = 6 -- Journal
   SELECT @v_journalkey = COALESCE(dbo.qproject_get_otherprojectkey(@i_projectkey,@v_thisrelationship_qsicode,@v_otherrelationship_qsicode),0)

  SELECT @qsiRoleType1 = 10 -- Production Coordinator
  SELECT @qsiRoleType2 = 11 -- AME (Assistant Managing Editor)

  SELECT @Misc33 = ( select top 1 g.displayname/*, t.sortorder, tr.rolecode*/ 
					from globalcontact g, taqprojectcontact t, taqprojectcontactrole tr
					where g.globalcontactkey=t.globalcontactkey
					and t.taqprojectcontactkey=tr.taqprojectcontactkey
					and tr.rolecode = ( select datacode from gentables 
										where tableid = 285 and qsicode = @qsiRoleType1 AND (t.taqprojectkey = @v_journalkey)  ) )

  SELECT @Misc33Label = ( select datadesc from gentables where tableid = 285 and qsicode = @qsiRoleType1 )

  SELECT @Misc32 = ( select top 1 g.displayname/*, t.sortorder, tr.rolecode*/ 
					from globalcontact g, taqprojectcontact t, taqprojectcontactrole tr
					where g.globalcontactkey=t.globalcontactkey
					and t.taqprojectcontactkey=tr.taqprojectcontactkey
					and tr.rolecode = ( select datacode from gentables 
										where tableid = 285 and qsicode = @qsiRoleType2 AND (t.taqprojectkey = @v_journalkey) ) )

  SELECT @Misc32Label = ( select datadesc from gentables where tableid = 285 and qsicode = @qsiRoleType2 )


/************************************************************************************
 **   Build the Online Content strings
 ************************************************************************************/
print 'Element key = ' + convert(varchar, @v_elementkey)
 -- Location
	SELECT @Misc23 = filelocation.pathname, @v_elementkey = taqprojectelement.taqelementkey
	  FROM taqprojectelement INNER JOIN filelocation ON taqprojectelement.taqelementkey = filelocation.taqelementkey
	 WHERE (filelocation.filetypecode = 10) AND (taqprojectelement.taqelementtypecode = 20115) AND (taqprojectelement.taqprojectkey = @v_journalkey )

 -- Date Range
	  SET @Misc22Label = 'Online Content Date Range'
	SELECT @v_beginDate = ( SELECT longvalue FROM taqelementmisc WHERE (misckey = 120) AND (taqelementkey = @v_elementkey ) )
	SELECT @v_endDate = ( SELECT longvalue FROM taqelementmisc WHERE (misckey = 121) AND (taqelementkey = @v_elementkey ) )

	SELECT @Misc22 = @v_beginDate + '-' + @v_endDate

 -- Volume Range
	  SET @Misc34Label = 'Online Content Volume Range'
	SELECT @Misc34 = textvalue
	  FROM taqelementmisc
	 WHERE (misckey = 492) AND (taqelementkey = @v_elementkey)


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
     
   select @Misc35 = substring(@TempStr, 1, 50);
   select @Misc35Label = 'Electronic Collections'
   
  /********************************************************************************************/
   
  -- ISSN 
  SELECT @Misc14 = ( SELECT p.productnumber
  FROM taqproductnumbers p, gentables g
  WHERE p.productidcode = g.datacode AND
      g.tableid = 594 AND
      p.taqprojectkey = @v_journalkey AND
	  ( p.productidcode = 2 ) )
  SELECT @Misc14Label = ( select datadesc from gentables where tableid = 594 and qsicode = 2 )

  -- EISSN
  SELECT @Misc15 = ( SELECT p.productnumber
  FROM taqproductnumbers p, gentables g
  WHERE p.productidcode = g.datacode AND
      g.tableid = 594 AND
      p.taqprojectkey = @v_journalkey AND
	  ( p.productidcode = 3 ) )
  SELECT @Misc15Label = ( select datadesc from gentables where tableid = 594 and qsicode = 3 )

   -- Linking ISSN
  SELECT @Misc16 = ( SELECT p.productnumber
  FROM taqproductnumbers p, gentables g
  WHERE p.productidcode = g.datacode AND
      g.tableid = 594 AND
      p.taqprojectkey = @v_journalkey AND
	  ( p.productidcode = 8 ) )
SELECT @Misc16Label = ( select datadesc from gentables where tableid = 594 and datacode = 8 )

  -- Journal Acronym	  
  SELECT @Misc13 = ( SELECT p.productnumber
  FROM taqproductnumbers p, gentables g
  WHERE p.productidcode = g.datacode AND
      g.tableid = 594 AND
      p.taqprojectkey = @v_journalkey AND
	  ( p.productidcode = 4 ) )
  SELECT @Misc13Label = ( select datadesc from gentables where tableid = 594 and qsicode = 4 )
 
  -- Account Code
  SELECT @Misc119 = ( SELECT p.productnumber
  FROM taqproductnumbers p, gentables g
  WHERE p.productidcode = g.datacode AND
      g.tableid = 594 AND
      p.taqprojectkey = @v_journalkey AND
	  ( p.productidcode = 13 ) )  

  -- Cursor to obtain Society Values
  DECLARE society_cur CURSOR FOR 
	SELECT TOP (2) c.displayname as groupname
	FROM            taqprojectcontact AS p INNER JOIN
                         corecontactinfo AS c ON p.globalcontactkey = c.contactkey INNER JOIN
                         taqprojectcontactrole ON p.taqprojectcontactkey = taqprojectcontactrole.taqprojectcontactkey
	WHERE        (p.taqprojectkey = @v_journalkey) AND (taqprojectcontactrole.rolecode = 6)
	ORDER BY p.sortorder, c.displayname

   OPEN society_cur FETCH society_cur INTO @GroupName

  WHILE @@fetch_status = 0 
  BEGIN
    --PRINT 'Loop: ' + @GroupName
    IF ( @loopCtr = 1 ) 
		SELECT @Society1 = @GroupName
	ELSE
		SELECT @Society2 = @GroupName
	
	SELECT @loopCtr = @loopCtr + 1
	FETCH society_cur INTO @GroupName
  END

  CLOSE society_cur 
  DEALLOCATE society_cur 

  SELECT @Society1Label = 'Society'
  SELECT @Society2Label = 'Add''l Affiliated Society'
  
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

  -- need to retrieve relationships in both directions
  SELECT 1 projectnumber,
	    taqprojectkey1 thisprojectkey, 
	    taqprojectkey2 otherprojectkey, 
	    relationshipcode1 thisrelationshipcode, 
	    dbo.get_gentables_desc(582,relationshipcode1,'long') thisrelationshipdesc,
	    relationshipcode2 otherrelationshipcode, 
	    c.projecttitle otherprojectdisplayname,
	    c.projectstatusdesc otherprojectstatus,  
	    COALESCE(c.projectstatus,0) otherprojectstatuscode,  
	    c.projectparticipants otherprojectparticipants,  
	    r.taqprojectrelationshipkey, r.relationshipaddtldesc, r.keyind, r.sortorder,
	    c.searchitemcode otheritemtypecode, c.usageclasscode otherusageclasscode, 
	    cast(COALESCE(c.searchitemcode,0) AS VARCHAR) + '|' + cast(COALESCE(c.usageclasscode,0) AS VARCHAR) otheritemtypeusageclass,
	    c.usageclasscodedesc otherusageclasscodedesc, c.projecttype, c.projecttypedesc, c.projectowner, 0 hiddenorder,
	    r.indicator1, quantity1, quantity2,
    	
	    -- Misc Fields
	    @Society1 society1, @Society1Label society1label, 
	    @Society2 society2, @Society2Label society2label,
	    -- Column 1
	    dbo.qproject_get_misc_value(@v_journalkey,114) misc11, dbo.qutl_get_misc_label(114) misc11label,
	    dbo.qproject_get_misc_value(@v_journalkey,115) misc12, dbo.qutl_get_misc_label(115) misc12label,
	    ----@Misc119 misc119, dbo.qutl_get_misc_label(119) misc119label,
	    @Misc13 misc13, @Misc13Label misc13label,
	    dbo.qproject_get_misc_value(@v_journalkey,125) misc31, dbo.qutl_get_misc_label(125) misc31label,
	   ---- @Misc14 misc14, dbo.qutl_get_misc_label(96) misc14label,
	   ---- @Misc15 misc15, dbo.qutl_get_misc_label(97) misc15label,
        @Misc16 misc16, @Misc16Label misc16label, 
        @Misc14 misc14, @Misc14Label misc14label, 
        @Misc15 misc15, @Misc15Label misc15label,
	    -- Column 2
	    dbo.qproject_get_misc_value(@v_journalkey,200) misc21, dbo.qutl_get_misc_label(200) misc21label,
	    @Misc22Label misc22label, @Misc22 misc22,
	    @misc23Label misc23Label, @Misc23 misc23,
	    @misc35Label misc35Label, @Misc35 misc35,
	    -- Column 3
	    dbo.qproject_get_misc_value(@v_journalkey,47) misc47, dbo.qutl_get_misc_label(47) misc47label,
	    --@Misc32 misc32, @Misc32Label misc32label,
	    @Misc33 misc33, @Misc33Label misc33label,
        dbo.qproject_get_misc_value(@v_journalkey,278) misc278, dbo.qutl_get_misc_label(278) misc278label,
	    @misc34Label misc34Label, @Misc34 misc34

  FROM taqprojectrelationship r, coreprojectinfo c 
  WHERE r.taqprojectkey2 = c.projectkey AND 
      r.taqprojectkey1 > 0 AND 
      r.taqprojectkey1 = @i_projectkey AND 
      relationshipcode1 = @v_thisreldatacode AND 
      relationshipcode2 = @v_otherreldatacode     
  UNION
  SELECT 2 projectnumber, 
      taqprojectkey2 thisprojectkey, 
      taqprojectkey1 otherprojectkey, 
      relationshipcode2 thisrelationshipcode, 
      dbo.get_gentables_desc(582,relationshipcode2,'long') thisrelationshipdesc,
      relationshipcode1 otherrelationshipcode, 
      c.projecttitle otherprojectdisplayname,
      c.projectstatusdesc otherprojectstatus,  
      COALESCE(c.projectstatus,0) otherprojectstatuscode,  
      c.projectparticipants otherprojectparticipants,  
      r.taqprojectrelationshipkey, r.relationshipaddtldesc, r.keyind, r.sortorder,
      c.searchitemcode otheritemtypecode, c.usageclasscode otherusageclasscode, 
      cast(COALESCE(c.searchitemcode,0) AS VARCHAR) + '|' + cast(COALESCE(c.usageclasscode,0) AS VARCHAR) otheritemtypeusageclass,
      c.usageclasscodedesc otherusageclasscodedesc, c.projecttype, c.projecttypedesc, c.projectowner, 0 hiddenorder,
      r.indicator1, quantity1, quantity2,
      
    	-- Misc Fields  
	    @Society1 society1, @Society1Label society1label, 
	    @Society2 society2, @Society2Label society2label,
 	    -- Column 1
	    dbo.qproject_get_misc_value(@v_journalkey,114) misc11, dbo.qutl_get_misc_label(114) misc11label,
	    dbo.qproject_get_misc_value(@v_journalkey,115) misc12, dbo.qutl_get_misc_label(115) misc12label,
        ----@Misc119 misc119, dbo.qutl_get_misc_label(119) misc119label,
	    @Misc13 misc13, @Misc13Label misc13label,
	    dbo.qproject_get_misc_value(@v_journalkey,125) misc31, dbo.qutl_get_misc_label(125) misc31label,
	    ----@Misc14 misc14, dbo.qutl_get_misc_label(96) misc14label,
	    ---@Misc15 misc15, dbo.qutl_get_misc_label(97) misc15label,
        @Misc16 misc16, @Misc16Label misc16label, 
        @Misc14 misc14, @Misc14Label misc14label, 
        @Misc15 misc15, @Misc15Label misc15label, 
	    -- Column 2
      dbo.qproject_get_misc_value(@v_journalkey,200) misc21, dbo.qutl_get_misc_label(200) misc21label,
 	    @Misc22Label misc22label, @Misc22 misc22, 
	    @misc23Label misc23Label, @Misc23 misc23, 
	    @misc35Label misc35Label, @Misc35 misc35,
	    -- Column 3
      dbo.qproject_get_misc_value(@v_journalkey,47) misc47, dbo.qutl_get_misc_label(47) misc47label,
	    --@Misc32 misc32, @Misc32Label misc32label,
	    @Misc33 misc33, @Misc33Label misc33label,
      dbo.qproject_get_misc_value(@v_journalkey,278) misc278, dbo.qutl_get_misc_label(278) misc278label,
	    @misc34Label misc34Label, @Misc34 misc34

  FROM taqprojectrelationship r, coreprojectinfo c 
  WHERE r.taqprojectkey1 = c.projectkey AND 
      r.taqprojectkey2 > 0 AND 
      r.taqprojectkey2 = @i_projectkey AND 
      relationshipcode2 = @v_thisreldatacode AND 
      relationshipcode1 = @v_otherreldatacode     
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
