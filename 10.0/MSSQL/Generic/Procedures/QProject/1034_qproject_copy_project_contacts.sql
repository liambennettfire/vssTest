IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_contacts]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_copy_project_contacts]
/****** Object:  StoredProcedure [dbo].[qproject_copy_project_contacts]    Script Date: 07/16/2008 10:33:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_contacts]
  (@i_copy_projectkey integer,
  @i_copy2_projectkey integer,
  @i_new_projectkey    integer,
  @i_userid        varchar(30),
  @i_cleardatagroups_list  varchar(max),
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS

/******************************************************************************
**  Name: [qproject_copy_project_contacts]
**  Desc: This stored procedure copies the details of 1 or all elements to new elements.
**        The project key to copy and the data groups to copy are passed as arguments.
**
**      If you call this procedure from anyplace other than qproject_copy_project,
**      you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Jennifer Hurd
**    Date: 23 June 2008
****************************************************************************************************************************
**    Date:        Author:       Description:
**    --------     --------      --------------------------------------------------------------------------------------
**    05/18/2016   Colman         37920 Duplicate categories and roles when copying from master acquisition 
**    10/05/2016   Colman        40948 Participants duplicating in the participant by role section
**    12/19/2016   Dustin         Case 42246
**    03/09/2017   Colman        43727 Multiple participant by role rows appear on new contract (Do not copy PBR section 1 contacts)
**    06/06/2017   Colman        45522 Fixed taqprojectcontactrole format key logic
*****************************************************************************************************************************/

SET @o_error_code = 0
SET @o_error_desc = ''

DECLARE @error_var    INT,
  @rowcount_var INT,
  @newkeycount  int,
  @tobecopiedkey  int,
  @newkey  int,
  @counter    int,
  @newkeycount2  int,
  @tobecopiedkey2  int,
  @newkey2    int,
  @counter2    int,
  @v_itemtype_qsicode INT,
  @v_usageclass_qsicode INT,
  @v_is_titleacq  TINYINT,  
  @v_readerrolecode INT,
  @v_manuscriptcode INT,
  @v_iterationcode  INT,
  @v_rolecode  INT,
  @v_globalcontactkey  INT,
  @v_taqelementkey  INT,
  @v_taqelementnumber INT,
  @v_maxsort  int,
  @v_sortorder  int,
  @v_itemtypecode int,
  @v_usageclasscode int,
  @v_activeind TINYINT, 
  @v_authortypecode INT,
  @v_primaryind TINYINT, 
  @v_ratetypecode INT, 
  @v_workrate FLOAT, 
  @v_quantity INT, 
  @v_shippingmethodcode INT, 
  @v_globalcontactrelationshipkey INT,
  @v_indicator1 TINYINT,
  @v_globalcontactrelationshipkey_value INT,
  @v_indicator TINYINT,
  @v_taqversionformatkey INT,
  @v_new_taqversionformatkey INT,
  @v_shippinglocationcode INT
  
if @i_copy_projectkey is null or @i_copy_projectkey = 0
begin
  SET @o_error_code = -1
  SET @o_error_desc = 'copy project key not passed to copy contacts (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
  RETURN
end

if @i_new_projectkey is null or @i_new_projectkey = 0
begin
  SET @o_error_code = -1
  SET @o_error_desc = 'new project key not passed to copy contacts (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
  RETURN
end   

SELECT @v_itemtype_qsicode = g.qsicode, @v_usageclass_qsicode = sg.qsicode
FROM taqproject p
  JOIN gentables g ON p.searchitemcode = g.datacode AND g.tableid = 550
  JOIN subgentables sg ON p.searchitemcode = sg.datacode AND p.usageclasscode = sg.datasubcode AND sg.tableid = 550
WHERE taqprojectkey = @i_new_projectkey

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
  SET @o_error_code = -1
  SET @o_error_desc = 'Error getting project Item Type and Usage Class.'
  RETURN
END
   
SELECT @v_itemtypecode = sg.datacode, @v_usageclasscode = sg.datasubcode
FROM taqproject p
  JOIN subgentables sg ON p.searchitemcode = sg.datacode AND p.usageclasscode = sg.datasubcode AND sg.tableid = 550
WHERE taqprojectkey = @i_new_projectkey    
   
 SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
 IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
   SET @o_error_code = -1
   SET @o_error_desc = 'Error getting project Item Type and Usage Class datacode / datasubcode.'
   RETURN
 END

-- Get the rolecode for 'Reader' (gentable 285, qsicode=3)
SELECT @v_readerrolecode = datacode
FROM gentables 
WHERE tableid = 285 AND qsicode = 3

SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
  SET @o_error_code = -1
  SET @o_error_desc = 'Error getting rolecode for Reader (gentables 285, qsicode=3).'
  RETURN
END

-- Get the rolecode for 'Shipping Location' (gentable 285, qsicode=17)
SELECT @v_shippinglocationcode = datacode 
FROM gentables 
WHERE tableid=285 and qsicode=17

SELECT @error_var = @@ERROR
IF @error_var <> 0 BEGIN
  SET @o_error_code = -1
  SET @o_error_desc = 'Error getting rolecode for Shipping Location (gentables 285, qsicode=17).'
  RETURN
END

SET @v_is_titleacq = 0
IF @v_itemtype_qsicode = 3 AND @v_usageclass_qsicode = 1  -- Project/Title Acquisition
BEGIN
  SET @v_is_titleacq = 1
  
  -- Get the elementtypecode for 'Manuscript'
  SELECT @v_manuscriptcode = datacode
  FROM gentables
  WHERE tableid = 287 AND qsicode = 1

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error getting elementtypecode for Manuscript (gentables 287, qsicode=1).'
    RETURN
  END
      
  -- Get the elementtypesubcode for 'Iteration' (subgentable 287, qsicode=1)
  SELECT @v_iterationcode = datasubcode
  FROM subgentables
  WHERE tableid = 287 AND datacode = @v_manuscriptcode AND qsicode = 1

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not get elementtypesubcode for Iteration (subgentable 287, qsicode=1).'
    RETURN
  END
END

select DISTINCT @newkeycount = count(*), @tobecopiedkey = min(c.taqprojectcontactkey), @v_maxsort = max(c.sortorder)
from taqprojectcontact c, taqprojectcontactrole r
WHERE c.taqprojectkey = r.taqprojectkey AND
  c.taqprojectcontactkey = r.taqprojectcontactkey AND
  r.rolecode IN 
   (SELECT DISTINCT datacode from gentablesitemtype
    where tableid = 285
    and itemtypecode = @v_itemtypecode
    and itemtypesubcode in (@v_usageclasscode,0)
    and ISNULL(relateddatacode, 0) <> 1) AND                
  c.taqprojectkey = @i_copy_projectkey     

set @counter = 1
while @counter <= @newkeycount
begin

  SET @v_globalcontactrelationshipkey_value = 0
  SELECT TOP(1) @v_globalcontactrelationshipkey_value = COALESCE(globalcontactrelationshipkey, 0) 
  FROM taqprojectcontactrole where taqprojectcontactkey = @tobecopiedkey AND taqprojectkey = @i_copy_projectkey 

  IF EXISTS (SELECT * from taqprojectcontact c
        where taqprojectkey = @i_copy_projectkey 
          and taqprojectcontactkey = @tobecopiedkey
          AND EXISTS (SELECT * FROM taqprojectcontact c2 
            WHERE c.globalcontactkey = c2.globalcontactkey AND c2.taqprojectkey = @i_new_projectkey)
          AND EXISTS (SELECT * FROM taqprojectcontactrole r WHERE COALESCE(globalcontactrelationshipkey, 0) = @v_globalcontactrelationshipkey_value
            AND r.taqprojectkey = @i_new_projectkey) 
      ) 
  BEGIN
      
    SELECT TOP(1) @newkey = c.taqprojectcontactkey from taqprojectcontact c
        where taqprojectkey = @i_new_projectkey  AND globalcontactkey IN (SELECT c.globalcontactkey 
                                        FROM taqprojectcontact c where c.taqprojectkey = @i_copy_projectkey     
                                        AND c.taqprojectcontactkey = @tobecopiedkey)    
  END  
  ELSE BEGIN
    exec get_next_key @i_userid, @newkey output

    insert into taqprojectcontact
      (taqprojectcontactkey, taqprojectkey, globalcontactkey, participantnote, 
      keyind, sortorder, addresskey, lastuserid, lastmaintdate)
    select @newkey, @i_new_projectkey, c.globalcontactkey, c.participantnote,
      c.keyind, c.sortorder, c.addresskey, @i_userid, getdate()
    from taqprojectcontact c
    where taqprojectkey = @i_copy_projectkey 
      and taqprojectcontactkey = @tobecopiedkey 
      AND NOT EXISTS (
        SELECT * FROM taqprojectcontact c2 
        WHERE c.globalcontactkey = c2.globalcontactkey 
          AND c2.taqprojectkey = @i_new_projectkey
          AND EXISTS (
            SELECT * FROM taqprojectcontactrole r 
            WHERE COALESCE(globalcontactrelationshipkey, 0) = @v_globalcontactrelationshipkey_value
              AND r.taqprojectkey = @i_new_projectkey) 
      )

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'copy/insert into taqprojectcontact failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy_projectkey AS VARCHAR)   
      RETURN
    END 
  END

  select @newkeycount2 = count(*), @tobecopiedkey2 = min(taqprojectcontactrolekey)
  from taqprojectcontactrole
  where taqprojectkey = @i_copy_projectkey and
         rolecode IN (SELECT DISTINCT datacode from gentablesitemtype
                    where tableid = 285
                      and itemtypecode = @v_itemtypecode
                      and itemtypesubcode in (@v_usageclasscode,0)
                      and ISNULL(relateddatacode, 0) <> 1) AND                
     taqprojectcontactkey = @tobecopiedkey

  set @counter2 = 1

  while @counter2 <= @newkeycount2
  begin

    DECLARE taqprojectcontactrole_iteration_cur CURSOR FOR
      select r.rolecode, r.activeind,
           r.authortypecode, r.primaryind,
           r.ratetypecode, r.workrate, 
           r.quantity, r.shippingmethodcode, 
           r.globalcontactrelationshipkey,
           r.indicator,
           r.taqversionformatkey           
      from taqprojectcontactrole r
      where taqprojectkey = @i_copy_projectkey
        and taqprojectcontactrolekey = @tobecopiedkey2
        and taqprojectcontactkey = @tobecopiedkey
        AND NOT EXISTS 
          ( SELECT * FROM taqprojectcontact c2, taqprojectcontactrole r2 
            WHERE c2.taqprojectkey = r2.taqprojectkey
              AND c2.taqprojectcontactkey = r2.taqprojectcontactkey 
              AND c2.globalcontactkey IN 
                ( SELECT globalcontactkey 
                  FROM taqprojectcontact t 
                  INNER JOIN taqprojectcontactrole r3 
                    ON t.taqprojectcontactkey = r3.taqprojectcontactkey
                  WHERE t.taqprojectkey = @i_copy_projectkey 
                  AND r3.rolecode = r.rolecode
                  AND r3.taqprojectcontactrolekey = @tobecopiedkey2 
                  AND r3.taqprojectcontactkey = @tobecopiedkey ) 
              AND r2.taqprojectkey = @i_new_projectkey
              AND r2.rolecode = r.rolecode
              AND r2.globalcontactrelationshipkey = @v_globalcontactrelationshipkey_value
              AND COALESCE(r2.taqversionformatkey, 0) = COALESCE(r.taqversionformatkey, 0)
              AND COALESCE(r2.shippingmethodcode, 0) = COALESCE(r.shippingmethodcode, 0) )

        OPEN taqprojectcontactrole_iteration_cur

        FETCH NEXT FROM taqprojectcontactrole_iteration_cur 
        INTO @v_rolecode, @v_activeind, @v_authortypecode, @v_primaryind, @v_ratetypecode, @v_workrate, @v_quantity, @v_shippingmethodcode, @v_globalcontactrelationshipkey, @v_indicator, @v_taqversionformatkey
    
        WHILE (@@FETCH_STATUS = 0) 
        BEGIN
        
          SELECT TOP(1) @v_indicator1 = COALESCE(i.indicator1, 0)
          FROM gentables g, gentablesitemtype i
          WHERE g.tableid = i.tableid  AND
            g.datacode = i.datacode  AND
            g.tableid = 285
            and i.itemtypecode = @v_itemtypecode
            and i.itemtypesubcode in (@v_usageclasscode,0) 
            and i.datacode = @v_rolecode
        ORDER BY itemtypesubcode DESC              

      SET @v_new_taqversionformatkey = NULL

      -- Try to find a taqversionformat on the new project that corresponds to the format on the taqprojectcontactrole row to be copied
      SELECT TOP(1) @v_new_taqversionformatkey = newf.taqprojectformatkey 
      FROM taqversionformat newf, taqversionformat copyf
      WHERE copyf.taqprojectformatkey = @v_taqversionformatkey
        AND copyf.mediatypecode = newf.mediatypecode 
        AND copyf.mediatypesubcode = newf.mediatypesubcode
        AND copyf.description = newf.description
        AND newf.taqprojectkey = @i_new_projectkey

    -- IF this contact/role does not exist and duplicate roles are allowed or this role does not exist
    IF NOT EXISTS (
      SELECT * FROM taqprojectcontactrole 
      WHERE taqprojectkey = @i_new_projectkey 
        AND rolecode = @v_rolecode 
        AND taqprojectcontactkey = @newkey 
        AND COALESCE(taqversionformatkey, 0) = COALESCE(@v_new_taqversionformatkey, 0) 
        AND COALESCE(shippingmethodcode, 0) = COALESCE(@v_shippingmethodcode, 0) )
      AND (@v_indicator1 <> 1 OR NOT EXISTS(SELECT * FROM taqprojectcontactrole WHERE taqprojectkey = @i_new_projectkey AND rolecode = @v_rolecode))
    BEGIN
      exec get_next_key @i_userid, @newkey2 output
      insert into taqprojectcontactrole
          (taqprojectcontactrolekey, taqprojectcontactkey, taqprojectkey, rolecode, activeind,
          authortypecode, primaryind, lastuserid, lastmaintdate, ratetypecode, workrate, quantity, 
          shippingmethodcode, globalcontactrelationshipkey, indicator, taqversionformatkey)        
      values(@newkey2, @newkey, @i_new_projectkey, @v_rolecode, @v_activeind,
           @v_authortypecode, @v_primaryind, @i_userid, getdate(), @v_ratetypecode, @v_workrate, @v_quantity,
           @v_shippingmethodcode, @v_globalcontactrelationshipkey, @v_indicator, @v_new_taqversionformatkey)
                 
      SELECT @error_var = @@ERROR
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'copy/insert into taqprojectcontactrole failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy_projectkey AS VARCHAR)   
        RETURN
      END
    END

    FETCH NEXT FROM taqprojectcontactrole_iteration_cur 
    INTO @v_rolecode, @v_activeind, @v_authortypecode, @v_primaryind, @v_ratetypecode, @v_workrate, @v_quantity, @v_shippingmethodcode, @v_globalcontactrelationshipkey, @v_indicator, @v_taqversionformatkey
  END

  CLOSE taqprojectcontactrole_iteration_cur 
  DEALLOCATE taqprojectcontactrole_iteration_cur  
    
  -- If this is Title Acquisition and the contact role is Reader, copy taqprojectreaderiteration records    
  IF @v_is_titleacq = 1
  BEGIN

      -- Get the rolecode and globalcontactkey just copied
      SELECT @v_rolecode = r.rolecode, @v_globalcontactkey = c.globalcontactkey
      FROM taqprojectcontactrole r, taqprojectcontact c
      WHERE r.taqprojectkey = c.taqprojectkey AND
        r.taqprojectcontactkey = c.taqprojectcontactkey AND
        r.taqprojectkey = @i_new_projectkey AND 
        r.taqprojectcontactrolekey = @newkey2

      IF @v_rolecode = @v_readerrolecode
      BEGIN

        -- Loop through manuscript iteration records for the new project
        DECLARE manuscript_iteration_cur CURSOR FOR
          SELECT taqelementkey, taqelementnumber
          FROM taqprojectelement
          WHERE taqprojectkey = @i_new_projectkey AND
            taqelementtypecode = @v_manuscriptcode AND
            taqelementtypesubcode = @v_iterationcode
          ORDER BY taqelementnumber

        OPEN manuscript_iteration_cur

        FETCH NEXT FROM manuscript_iteration_cur INTO @v_taqelementkey, @v_taqelementnumber

        WHILE (@@FETCH_STATUS = 0) 
        BEGIN

          INSERT INTO taqprojectreaderiteration
            (taqprojectkey, taqprojectcontactrolekey, taqelementkey, readitrecommendation, readitsummary, 
            statuscode, ratingcode, recommendationcode, lastuserid, lastmaintdate)
          SELECT @i_new_projectkey, @newkey2, @v_taqelementkey, i.readitrecommendation, i.readitsummary, 
            i.statuscode, i.ratingcode, i.recommendationcode, @i_userid, getdate()
          FROM taqprojectreaderiteration i, taqprojectcontactrole r, taqprojectcontact c, taqprojectelement e
          WHERE i.taqprojectkey = @i_copy_projectkey AND
            i.taqprojectcontactrolekey = r.taqprojectcontactrolekey AND
            r.taqprojectcontactkey = c.taqprojectcontactkey AND 
            i.taqelementkey = e.taqelementkey AND
            c.globalcontactkey = @v_globalcontactkey AND 
            r.rolecode = @v_readerrolecode AND 
            e.taqelementnumber = @v_taqelementnumber AND
            e.taqelementtypecode = @v_manuscriptcode AND
            e.taqelementtypesubcode = @v_iterationcode

          FETCH NEXT FROM manuscript_iteration_cur INTO @v_taqelementkey, @v_taqelementnumber
        END

        CLOSE manuscript_iteration_cur 
        DEALLOCATE manuscript_iteration_cur

      END --IF @v_rolecode = @v_readerrolecode
  END --IF @v_is_titleacq = 1
    
  set @counter2 = @counter2 + 1

  select @tobecopiedkey2 = min(taqprojectcontactrolekey)
  from taqprojectcontactrole
  where taqprojectkey = @i_copy_projectkey
    and taqprojectcontactkey = @tobecopiedkey
    and rolecode IN (SELECT DISTINCT datacode from gentablesitemtype
              where tableid = 285
                 and itemtypecode = @v_itemtypecode
                 and itemtypesubcode in (@v_usageclasscode,0)
                 and ISNULL(relateddatacode, 0) <> 1)                
    and taqprojectcontactrolekey > @tobecopiedkey2      
  end

  set @counter = @counter + 1

  select DISTINCT @tobecopiedkey = min(c.taqprojectcontactkey)
  from taqprojectcontact c, taqprojectcontactrole r
  where c.taqprojectkey = r.taqprojectkey AND
        c.taqprojectcontactkey = r.taqprojectcontactkey AND
        r.rolecode IN (SELECT DISTINCT datacode from gentablesitemtype
                    where tableid = 285
                      and itemtypecode = @v_itemtypecode
                      and itemtypesubcode in (@v_usageclasscode,0)
                      and ISNULL(relateddatacode, 0) <> 1) AND                
        c.taqprojectkey = @i_copy_projectkey AND
        c.taqprojectcontactkey > @tobecopiedkey  

END -- while @counter <= @newkeycount (@i_copy_projectkey)

/* 5/1/12 - KW - From case 17842:
Contacts (9): copy from i_copy_projectkey; add non-existing contact/roles from i_copy2_projectkey */
IF @i_copy2_projectkey > 0
BEGIN
  SELECT DISTINCT @newkeycount = COUNT(*), @tobecopiedkey = MIN(c1.taqprojectcontactkey)
  FROM taqprojectcontact c1, taqprojectcontactrole r
  WHERE c1.taqprojectkey = @i_copy2_projectkey AND
               c1.taqprojectcontactkey = r.taqprojectcontactkey AND
         r.rolecode IN (SELECT DISTINCT datacode from gentablesitemtype
                    where tableid = 285
                      and itemtypecode = @v_itemtypecode
                      and itemtypesubcode in (@v_usageclasscode,0)
                      and ISNULL(relateddatacode, 0) <> 1)            

  SET @v_sortorder = @v_maxsort + 1
  SET @counter = 1
  
  WHILE @counter <= @newkeycount
  BEGIN
    SET @v_globalcontactrelationshipkey_value = 0
    SELECT TOP(1) @v_globalcontactrelationshipkey_value = COALESCE(globalcontactrelationshipkey, 0) 
    FROM taqprojectcontactrole where taqprojectcontactkey = @tobecopiedkey AND taqprojectkey = @i_copy2_projectkey 
    
    IF EXISTS (SELECT * from taqprojectcontact c
          where taqprojectkey = @i_copy2_projectkey 
          and taqprojectcontactkey = @tobecopiedkey AND 
          EXISTS (SELECT * FROM taqprojectcontact c2 
          WHERE c.globalcontactkey = c2.globalcontactkey AND c2.taqprojectkey = @i_new_projectkey) 
          AND EXISTS (SELECT * FROM taqprojectcontactrole r WHERE COALESCE(globalcontactrelationshipkey, 0) = @v_globalcontactrelationshipkey_value
          AND r.taqprojectkey = @i_new_projectkey)         
          ) 
    BEGIN
        
      SELECT TOP(1) @newkey = c.taqprojectcontactkey from taqprojectcontact c
          where taqprojectkey = @i_new_projectkey  AND globalcontactkey IN (SELECT c.globalcontactkey 
                                          FROM taqprojectcontact c where c.taqprojectkey = @i_copy2_projectkey     
                                          AND c.taqprojectcontactkey = @tobecopiedkey)    
    END  
    ELSE BEGIN
      EXEC get_next_key @i_userid, @newkey OUTPUT
      
      INSERT INTO taqprojectcontact
        (taqprojectcontactkey, taqprojectkey, globalcontactkey, participantnote, 
        keyind, sortorder, addresskey, lastuserid, lastmaintdate)
      SELECT @newkey, @i_new_projectkey, c.globalcontactkey, c.participantnote, 
        keyind, @v_sortorder, c.addresskey, @i_userid, getdate()
      FROM taqprojectcontact c
      where taqprojectkey = @i_copy2_projectkey 
        and taqprojectcontactkey = @tobecopiedkey AND 
           NOT EXISTS (SELECT * FROM taqprojectcontact c2 
              WHERE c.globalcontactkey = c2.globalcontactkey AND c2.taqprojectkey = @i_new_projectkey
              AND EXISTS (SELECT * FROM taqprojectcontactrole r WHERE COALESCE(globalcontactrelationshipkey, 0) = @v_globalcontactrelationshipkey_value
                    AND r.taqprojectkey = @i_new_projectkey)                  
              )   

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Copy/insert into taqprojectcontact failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy2_projectkey AS VARCHAR)   
        RETURN
      END 
    END

    SELECT @newkeycount2 = COUNT(*), @tobecopiedkey2 = MIN(taqprojectcontactrolekey)
    FROM taqprojectcontactrole
    WHERE taqprojectkey = @i_copy2_projectkey AND 
      rolecode IN (SELECT DISTINCT datacode from gentablesitemtype
                where tableid = 285
                   and itemtypecode = @v_itemtypecode
                   and itemtypesubcode in (@v_usageclasscode,0)
                   and ISNULL(relateddatacode, 0) <> 1) AND                
    taqprojectcontactkey = @tobecopiedkey  

    SET @counter2 = 1

    WHILE @counter2 <= @newkeycount2
    BEGIN
    
        DECLARE taqprojectcontactrole_iteration_cur CURSOR FOR                                   
        SELECT r.rolecode, r.activeind,
        r.authortypecode, r.primaryind, r.ratetypecode, r.workrate, r.quantity, r.shippingmethodcode, r.globalcontactrelationshipkey, r.indicator, r.taqversionformatkey
        from taqprojectcontactrole r
        where taqprojectkey = @i_copy2_projectkey
          and taqprojectcontactrolekey = @tobecopiedkey2
          and taqprojectcontactkey = @tobecopiedkey AND
         NOT EXISTS (SELECT * FROM taqprojectcontact c2, taqprojectcontactrole r2 
                WHERE c2.taqprojectkey = r2.taqprojectkey AND
                    c2.taqprojectcontactkey = r2.taqprojectcontactkey AND c2.globalcontactkey IN (SELECT globalcontactkey 
                                                          FROM taqprojectcontact t 
                                                          INNER JOIN taqprojectcontactrole r3 
                                                              ON t.taqprojectcontactkey = r3.taqprojectcontactkey
                                                           WHERE t.taqprojectkey = @i_copy2_projectkey 
                                                           AND r3.rolecode = r.rolecode
                                                           AND r3.taqprojectcontactrolekey = @tobecopiedkey2 
                                                           AND r3.taqprojectcontactkey = @tobecopiedkey) 
                                             AND r2.taqprojectkey = @i_new_projectkey
                                             AND r2.rolecode = r.rolecode
                                             AND r2.globalcontactrelationshipkey = @v_globalcontactrelationshipkey_value
                                             AND COALESCE(r2.taqversionformatkey, 0) = COALESCE(r.taqversionformatkey, 0)
                                             AND COALESCE(r2.shippingmethodcode, 0) = COALESCE(r.shippingmethodcode, 0))                                           

        OPEN taqprojectcontactrole_iteration_cur

        FETCH NEXT FROM taqprojectcontactrole_iteration_cur 
        INTO @v_rolecode, @v_activeind, @v_authortypecode, @v_primaryind, @v_ratetypecode, @v_workrate, @v_quantity, @v_shippingmethodcode, @v_globalcontactrelationshipkey, @v_indicator, @v_taqversionformatkey

        WHILE (@@FETCH_STATUS = 0) 
        BEGIN        
          SELECT TOP(1) @v_indicator1 = COALESCE(i.indicator1, 0)
          FROM gentables g, gentablesitemtype i
          WHERE g.tableid = i.tableid  AND
              g.datacode = i.datacode  AND
              g. tableid = 285
             and i.itemtypecode = @v_itemtypecode
             and i.itemtypesubcode in (@v_usageclasscode,0) 
               and i.datacode = @v_rolecode         
          ORDER BY itemtypesubcode DESC         
      
          SET @v_new_taqversionformatkey = NULL

          -- Try to find a taqversionformat on the new project that corresponds to the format on the taqprojectcontactrole row to be copied
          SELECT TOP(1) @v_new_taqversionformatkey = newf.taqprojectformatkey 
          FROM taqversionformat newf, taqversionformat copyf
          WHERE copyf.taqprojectformatkey = @v_taqversionformatkey 
            AND copyf.mediatypecode = newf.mediatypecode 
            AND copyf.mediatypesubcode = newf.mediatypesubcode
            AND copyf.description = newf.description
            AND newf.taqprojectkey = @i_new_projectkey

          IF NOT EXISTS(SELECT * FROM taqprojectcontactrole WHERE taqprojectkey = @i_new_projectkey AND rolecode = @v_rolecode AND taqprojectcontactkey = @newkey AND COALESCE(taqversionformatkey, 0) = COALESCE(@v_taqversionformatkey, 0) AND COALESCE(shippingmethodcode, 0) = COALESCE(@v_shippingmethodcode, 0)) 
          BEGIN                        
            exec get_next_key @i_userid, @newkey2 output
            insert into taqprojectcontactrole
                (taqprojectcontactrolekey, taqprojectcontactkey, taqprojectkey, rolecode, activeind,
                authortypecode, primaryind, lastuserid, lastmaintdate, ratetypecode, workrate, quantity, 
                shippingmethodcode, globalcontactrelationshipkey, indicator, taqversionformatkey)        
            values(@newkey2, @newkey, @i_new_projectkey, @v_rolecode, @v_activeind,
                 @v_authortypecode, @v_primaryind, @i_userid, getdate(), @v_ratetypecode, @v_workrate, @v_quantity,
                 @v_shippingmethodcode, @v_globalcontactrelationshipkey, @v_indicator, @v_new_taqversionformatkey)   
                 
            SELECT @error_var = @@ERROR
            IF @error_var <> 0 BEGIN
              SET @o_error_code = -1
              SET @o_error_desc = 'Copy/insert into taqprojectcontactrole failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey=' + cast(@i_copy2_projectkey AS VARCHAR)   
              RETURN
            END
          END                         

          FETCH NEXT FROM taqprojectcontactrole_iteration_cur 
          INTO @v_rolecode, @v_activeind, @v_authortypecode, @v_primaryind, @v_ratetypecode, @v_workrate, @v_quantity, @v_shippingmethodcode, @v_globalcontactrelationshipkey, @v_indicator, @v_taqversionformatkey
        END

        CLOSE taqprojectcontactrole_iteration_cur 
        DEALLOCATE taqprojectcontactrole_iteration_cur    

      -- If this is Title Acquisition and the contact role is Reader, copy taqprojectreaderiteration records    
      IF @v_is_titleacq = 1
      BEGIN

        -- Get the rolecode and globalcontactkey just copied
        SELECT @v_rolecode = r.rolecode, @v_globalcontactkey = c.globalcontactkey
        FROM taqprojectcontactrole r, taqprojectcontact c
        WHERE r.taqprojectkey = c.taqprojectkey AND
          r.taqprojectcontactkey = c.taqprojectcontactkey AND
          r.taqprojectkey = @i_new_projectkey AND 
          r.taqprojectcontactrolekey = @newkey2

        IF @v_rolecode = @v_readerrolecode
        BEGIN

          -- Loop through manuscript iteration records for the new project
          DECLARE manuscript_iteration_cur CURSOR FOR
            SELECT taqelementkey, taqelementnumber
            FROM taqprojectelement
            WHERE taqprojectkey = @i_new_projectkey AND
              taqelementtypecode = @v_manuscriptcode AND
              taqelementtypesubcode = @v_iterationcode
            ORDER BY taqelementnumber

          OPEN manuscript_iteration_cur

          FETCH NEXT FROM manuscript_iteration_cur INTO @v_taqelementkey, @v_taqelementnumber

          WHILE (@@FETCH_STATUS = 0) 
          BEGIN

            INSERT INTO taqprojectreaderiteration
              (taqprojectkey, taqprojectcontactrolekey, taqelementkey, readitrecommendation, readitsummary, 
              statuscode, ratingcode, recommendationcode, lastuserid, lastmaintdate)
            SELECT @i_new_projectkey, @newkey2, @v_taqelementkey, i.readitrecommendation, i.readitsummary, 
              i.statuscode, i.ratingcode, i.recommendationcode, @i_userid, getdate()
            FROM taqprojectreaderiteration i, taqprojectcontactrole r, taqprojectcontact c, taqprojectelement e
            WHERE i.taqprojectkey = @i_copy2_projectkey AND
              i.taqprojectcontactrolekey = r.taqprojectcontactrolekey AND
              r.taqprojectcontactkey = c.taqprojectcontactkey AND 
              i.taqelementkey = e.taqelementkey AND
              c.globalcontactkey = @v_globalcontactkey AND 
              r.rolecode = @v_readerrolecode AND 
              e.taqelementnumber = @v_taqelementnumber AND
              e.taqelementtypecode = @v_manuscriptcode AND
              e.taqelementtypesubcode = @v_iterationcode

            FETCH NEXT FROM manuscript_iteration_cur INTO @v_taqelementkey, @v_taqelementnumber
          END

          CLOSE manuscript_iteration_cur 
          DEALLOCATE manuscript_iteration_cur

        END --IF @v_rolecode = @v_readerrolecode
      END --IF @v_is_titleacq = 1

      SET @counter2 = @counter2 + 1

      SELECT @tobecopiedkey2 = MIN(taqprojectcontactrolekey)
      FROM taqprojectcontactrole
      WHERE taqprojectkey = @i_copy2_projectkey AND
        taqprojectcontactkey = @tobecopiedkey AND
        rolecode IN (SELECT DISTINCT datacode from gentablesitemtype
                where tableid = 285
                   and itemtypecode = @v_itemtypecode
                   and itemtypesubcode in (@v_usageclasscode,0)
                   and ISNULL(relateddatacode, 0) <> 1) AND                
        taqprojectcontactrolekey > @tobecopiedkey2
    END

    SET @counter = @counter + 1
    SET @v_sortorder = @v_sortorder + 1

    SELECT DISTINCT @tobecopiedkey = MIN(c1.taqprojectcontactkey)
    FROM taqprojectcontact c1, taqprojectcontactrole r
    WHERE c1.taqprojectkey = @i_copy2_projectkey AND
      c1.taqprojectcontactkey = r.taqprojectcontactkey AND
      r.rolecode IN (SELECT DISTINCT datacode from gentablesitemtype
                  where tableid = 285
                    and itemtypecode = @v_itemtypecode
                    and itemtypesubcode in (@v_usageclasscode,0)
                    and ISNULL(relateddatacode, 0) <> 1) AND                
          c1.taqprojectcontactkey > @tobecopiedkey   

  END -- WHILE @counter <= @newkeycount
END -- IF @i_copy2_projectkey > 0

DELETE FROM taqprojectcontact 
WHERE taqprojectkey = @i_new_projectkey 
  AND NOT EXISTS (SELECT * FROM taqprojectcontactrole r 
          WHERE r.taqprojectcontactkey = taqprojectcontact.taqprojectcontactkey 
          AND r.taqprojectkey = @i_new_projectkey)


RETURN