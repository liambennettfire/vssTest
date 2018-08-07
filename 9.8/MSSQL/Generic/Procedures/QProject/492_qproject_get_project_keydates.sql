if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_project_keydates') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_project_keydates
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_project_keydates
 (@i_projectkey   integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_project_keydates
**  Desc: This stored procedure returns formatted dates for the Key Dates
**        section of Project Summary. For new projects (projectkey=0),
**        dates are initialized from Project Dates task group (taskviewkey=11).
**
**    Auth: Kate W.
**    Date: 5/30/04
**
*******************************************************************************
** 08/26/08 Lisa - removing taqprojectcontactrolekey from taqprojecttask 
**					table.  Using join on globalcontactkey now.  Case 05322
**
** 11/05/08 Lisa - Removed hard-coded taskviewkeys see case 05565
** 03/07/16 Uday - Case 36706
*******************************************************************************/

  DECLARE @v_manuscriptcode INT,
    @v_iterationcode  INT,
    @v_taqelementnumber INT,
    @v_taqelementkey  INT,
    @v_error    INT,
    @v_rowcount INT
  
  SET @o_error_code = 0
  SET @o_error_desc = ''
    
  /** NOTE: When projectkey=0, this is a new Project. **/
  /** Dates on new projects must be initialized from ProjectDates taskgroup **/
  /** (taskviewkey=11). All dates for taskgroups associated with an element **/
  /** or a participant will NOT be added until that element/participant gets **/
  /** added to the project. Contract tasks (taskviewkey=5) will not be added **/
  /** either, since they would be added through the Contract Section. **/
  
  -- 11/11/2008 Lisa -- Currently, when a new project/book key is added there can
  -- be multiple Initial taskviews set up based on element type/code.  The tasks
  -- associated with these taskviews are automatically added at that time.  There
  -- is no longer a hard-coded taskview 11 key.
  IF @i_projectkey = 0  --NEW project
   BEGIN   
      SELECT @o_error_code = 1
      SELECT @o_error_desc = 'tasks are no longer added via this stored procedured'
--    SELECT
--      CASE
--        WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) = '' THEN d.description
--        ELSE d.datelabel
--      END AS datelabel,
--      d.sortorder, '' AS detaildesc, vdt1.datetypecode, 0 taqtaskkey, 
--      NULL activedate, NULL originaldate, NULL actualind, d.taqkeyind AS keyind,
--      dbo.qproject_is_sent_to_tmm(N'date',0,d.datetypecode,0) sendtotmm
--    FROM taskviewdatetype vdt1, datetype d
--    WHERE vdt1.datetypecode = d.datetypecode AND
--      vdt1.taskviewkey = 11 AND
--      vdt1.datetypecode NOT IN
--      (SELECT DISTINCT datetypecode 
--      FROM taskview v, taskviewdatetype vdt2
--      WHERE v.taskviewkey = vdt2.taskviewkey AND 
--        v.taskgroupind = 1 AND 
--        (v.elementtypecode IS NOT NULL OR v.rolecode IS NOT NULL OR v.qsicode = 5))        
   END   
  ELSE  --existing project
   BEGIN
   
    /** Get the elementtypecode for 'Manuscript' for comparison (gentable 287, qsicode=1) **/
    SELECT @v_manuscriptcode = datacode
    FROM gentables
    WHERE tableid = 287 AND qsicode = 1

    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'Error getting elementtypecode for Manuscript (gentables 287, qsicode=1)'
    END
    
    /** Get the elementtypesubcode for 'Iteration' (subgentable 287, qsicode=1) **/
    SELECT @v_iterationcode = datasubcode
    FROM subgentables
    WHERE tableid = 287 AND datacode = @v_manuscriptcode AND qsicode = 1
    
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'Could not get elementtypesubcode for Iteration (subgentable 287, qsicode=1)'
    END
    
    /* Get the most recent Manuscript Iteration element number */
    EXEC qproject_get_max_element_number @i_projectkey, 0, @v_manuscriptcode,
      @v_iterationcode, @v_taqelementnumber OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
      
    IF @v_taqelementnumber IS NULL
      SET @v_taqelementnumber = 0

    IF @o_error_code = 0
    BEGIN      
      /* Get the taqelementkey for the most recent Manuscript Iteration */
      SELECT @v_taqelementkey = taqelementkey
      FROM taqprojectelement
      WHERE taqprojectkey = @i_projectkey AND
          taqelementtypecode = @v_manuscriptcode AND
          taqelementtypesubcode = @v_iterationcode AND
          taqelementnumber = @v_taqelementnumber
          
      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
        SET @o_error_code = 1
        SET @o_error_desc = 'Could not get taqelementkey for current iteration'
      END    
      
      /********* GET TASKS ********/
      /* NOTE:  There are 4 parts to this UNION select: */
      /* (1) most recent Manuscript Iteration tasks w/contact assigned (detaildesc=Lastname of contact) */
      /* (2) most recent Manuscript Iteration tasks without contact info (BLANK detaildesc) */
      /* (3) all other element tasks (detaildesc=Element description) */
      /* (4) tasks not associated with any element (BLANK detaildesc) */
      SELECT 
        CASE
          WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) = '' THEN d.description
          ELSE d.datelabel
        END AS datelabel,
        d.sortorder, g.lastname AS detaildesc, t.datetypecode, t.taqtaskkey, 
        t.activedate, t.originaldate, t.actualind, t.keyind,
        dbo.qproject_is_sent_to_tmm(N'date',0,d.datetypecode,0) sendtotmm
      FROM taqprojecttask t, datetype d, taqprojectelement e, 
        taqprojectcontactrole r, taqprojectcontact c, globalcontact g
      WHERE t.datetypecode = d.datetypecode AND 
        t.taqprojectkey = e.taqprojectkey AND
        t.taqelementkey = e.taqelementkey AND
        t.taqprojectkey = r.taqprojectkey AND
        r.taqprojectkey = c.taqprojectkey AND
        r.taqprojectcontactkey = c.taqprojectcontactkey AND
        c.globalcontactkey = g.globalcontactkey AND
        t.taqprojectkey = @i_projectkey AND
		-- 08/26/08 Lisa removed this column, the join to taqprojectcontactrole table should provide same check
        --t.taqprojectcontactrolekey IS NOT NULL AND
        e.taqelementtypecode = @v_manuscriptcode AND
        t.taqelementkey = @v_taqelementkey AND
        t.keyind = 1
      UNION
      SELECT 
        CASE
          WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) = '' THEN d.description
          ELSE d.datelabel
        END AS datelabel,
        d.sortorder, '' AS detaildesc, t.datetypecode, t.taqtaskkey, 
        t.activedate, t.originaldate, t.actualind, t.keyind,
        dbo.qproject_is_sent_to_tmm(N'date',0,d.datetypecode,0) sendtotmm
      FROM taqprojecttask t, datetype d, taqprojectelement e
      WHERE t.datetypecode = d.datetypecode AND 
        t.taqprojectkey = e.taqprojectkey AND
        t.taqelementkey = e.taqelementkey AND
        t.taqprojectkey = @i_projectkey AND
        e.taqelementtypecode = @v_manuscriptcode AND
        t.globalcontactkey IS NULL AND -- added on 08/26/08
		--t.taqprojectcontactrolekey IS NULL AND
        t.taqelementkey = @v_taqelementkey AND
        t.keyind = 1
      UNION
      SELECT 
        CASE
          WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) = '' THEN d.description
          ELSE d.datelabel
        END AS datelabel,
        d.sortorder, e.taqelementdesc AS detaildesc, t.datetypecode, t.taqtaskkey, 
        t.activedate, t.originaldate, t.actualind, t.keyind,
        dbo.qproject_is_sent_to_tmm(N'date',0,d.datetypecode,0) sendtotmm
      FROM taqprojecttask t, datetype d, taqprojectelement e
      WHERE t.datetypecode = d.datetypecode AND 
        t.taqprojectkey = e.taqprojectkey AND
        t.taqelementkey = e.taqelementkey AND
        t.taqprojectkey = @i_projectkey AND
        e.taqelementtypecode <> @v_manuscriptcode AND
        t.keyind = 1
      UNION
      SELECT 
        CASE
          WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) = '' THEN d.description
          ELSE d.datelabel
        END AS datelabel,
        d.sortorder, '' AS detaildesc, t.datetypecode, t.taqtaskkey, 
        t.activedate, t.originaldate, t.actualind, t.keyind,
        dbo.qproject_is_sent_to_tmm(N'date',0,d.datetypecode,0) sendtotmm
      FROM taqprojecttask t, datetype d
      WHERE t.datetypecode = d.datetypecode AND 
        t.taqprojectkey = @i_projectkey AND
        t.taqelementkey IS NULL AND
        t.keyind = 1      
      ORDER BY d.sortorder, datelabel
      
    END --IF @o_error_code = 0
   END
   
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: projectkey = ' + cast(@i_projectkey AS VARCHAR)   
  END

GO

GRANT EXEC ON qproject_get_project_keydates TO PUBLIC
GO

