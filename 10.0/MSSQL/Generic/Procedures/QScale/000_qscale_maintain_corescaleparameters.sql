if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_maintain_corescaleparameters') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_maintain_corescaleparameters
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_maintain_corescaleparameters
 (@i_projectkey          integer,
  @i_userid              varchar(30),
  @o_error_code          integer output,
  @o_error_desc          varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qscale_maintain_corescaleparameters
**  Desc: This stored procedure deletes and then reinserts the corescaleparameters 
**        data for a scale.  NOTE:  corescaleparameterkey is an identity column 
**
**    Auth: Alan Katzen
**    Date: 14 March 2012
*******************************************************************************/

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_num_orgentries INT,
          @v_all_orgentries TINYINT,
          @v_orgentrykey INT,
          @v_fieldtype  INT,
          @v_scalename VARCHAR(255),
          @v_scaletype INT,
          @v_scaletypedesc VARCHAR(50),
          @v_statuscode INT,
          @v_statusdesc VARCHAR(50),
          @v_effectivedate_datetype INT,
          @v_effectivedate datetime,
          @v_expirationdate_datetype INT,
          @v_expirationdate datetime,
          @v_vendorkey INT,
          @v_num_vendors INT,
          @v_num_parameters INT,
          --@v_itemcategorycode INT,
          --@v_itemcategorycode_desc VARCHAR(50),
          --@v_itemcode INT,
          --@v_itemcode_desc VARCHAR(50),
          --@v_value1 INT,
          --@v_value2 INT,
          
          @v_parameter1categorycode int,
          @v_parameter1categorydesc varchar(50),
          @v_parameter1code int,
          @v_parameter1desc varchar(50),
          @v_parameter1value1 int,
          @v_parameter1value2 int,
          @v_parameter2categorycode int,
          @v_parameter2categorydesc varchar(50),
          @v_parameter2code int,
          @v_parameter2desc varchar(50),
          @v_parameter2value1 int,
          @v_parameter2value2 int,
          @v_parameter3categorycode int,
          @v_parameter3categorydesc varchar(50),
          @v_parameter3code int,
          @v_parameter3desc varchar(50),
          @v_parameter3value1 int,
          @v_parameter3value2 int,
          @v_parameter4categorycode int,
          @v_parameter4categorydesc varchar(50),
          @v_parameter4code int,
          @v_parameter4desc varchar(50),
          @v_parameter4value1 int,
          @v_parameter4value2 int,
          @v_parameter5categorycode int,
          @v_parameter5categorydesc varchar(50),
          @v_parameter5code int,
          @v_parameter5desc varchar(50),
          @v_parameter5value1 int,
          @v_parameter5value2 int,
          @v_parameter6categorycode int,
          @v_parameter6categorydesc varchar(50),
          @v_parameter6code int,
          @v_parameter6desc varchar(50),
          @v_parameter6value1 int,
          @v_parameter6value2 int,
          @v_parameter7categorycode int,
          @v_parameter7categorydesc varchar(50),
          @v_parameter7code int,
          @v_parameter7desc varchar(50),
          @v_parameter7value1 int,
          @v_parameter7value2 int,
          @v_parameter8categorycode int,
          @v_parameter8categorydesc varchar(50),
          @v_parameter8code int,
          @v_parameter8desc varchar(50),
          @v_parameter8value1 int,
          @v_parameter8value2 int,
          @v_parameter9categorycode int,
          @v_parameter9categorydesc varchar(50),
          @v_parameter9code int,
          @v_parameter9desc varchar(50),
          @v_parameter9value1 int,
          @v_parameter9value2 int,
          @v_parameter10categorycode int,
          @v_parameter10categorydesc varchar(50),
          @v_parameter10code int,
          @v_parameter10desc varchar(50),
          @v_parameter10value1 int,
          @v_parameter10value2 int,
          @v_parameter11categorycode int,
          @v_parameter11categorydesc varchar(50),
          @v_parameter11code int,
          @v_parameter11desc varchar(50),
          @v_parameter11value1 int,
          @v_parameter11value2 int,
          @v_parameter12categorycode int,
          @v_parameter12categorydesc varchar(50),
          @v_parameter12code int,
          @v_parameter12desc varchar(50),
          @v_parameter12value1 int,
          @v_parameter12value2 int,
          @v_parameter13categorycode int,
          @v_parameter13categorydesc varchar(50),
          @v_parameter13code int,
          @v_parameter13desc varchar(50),
          @v_parameter13value1 int,
          @v_parameter13value2 int,
          @v_parameter14categorycode int,
          @v_parameter14categorydesc varchar(50),
          @v_parameter14code int,
          @v_parameter14desc varchar(50),
          @v_parameter14value1 int,
          @v_parameter14value2 int,
          @v_parameter15categorycode int,
          @v_parameter15categorydesc varchar(50),
          @v_parameter15code int,
          @v_parameter15desc varchar(50),
          @v_parameter15value1 int,
          @v_parameter15value2 int,
          @v_parameter16categorycode int,
          @v_parameter16categorydesc varchar(50),
          @v_parameter16code int,
          @v_parameter16desc varchar(50),
          @v_parameter16value1 int,
          @v_parameter16value2 int,
          @v_parameter17categorycode int,
          @v_parameter17categorydesc varchar(50),
          @v_parameter17code int,
          @v_parameter17desc varchar(50),
          @v_parameter17value1 int,
          @v_parameter17value2 int,
          @v_parameter18categorycode int,
          @v_parameter18categorydesc varchar(50),
          @v_parameter18code int,
          @v_parameter18desc varchar(50),
          @v_parameter18value1 int,
          @v_parameter18value2 int,
          @v_parameter19categorycode int,
          @v_parameter19categorydesc varchar(50),
          @v_parameter19code int,
          @v_parameter19desc varchar(50),
          @v_parameter19value1 int,
          @v_parameter19value2 int,
          @v_parameter20categorycode int,
          @v_parameter20categorydesc varchar(50),
          @v_parameter20code int,
          @v_parameter20desc varchar(50),
          @v_parameter20value1 int,
          @v_parameter20value2 int         

  IF COALESCE(@i_projectkey,0) = 0 BEGIN
    return
  END
  
  -- remove existing rows
  DELETE FROM corescaleparameters
   WHERE taqprojectkey = @i_projectkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to delete from corescaleparameters table.'
    RETURN
  END 
   
  -- get scale info
  SELECT @v_scalename = taqprojecttitle, @v_scaletype = taqprojecttype,
         @v_scaletypedesc = dbo.get_gentables_desc(521,taqprojecttype,'long'),
         @v_statuscode = taqprojectstatuscode,
         @v_statusdesc = dbo.get_gentables_desc(522,taqprojectstatuscode,'long')
    FROM taqproject
   WHERE taqprojectkey = @i_projectkey
   
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to access taqproject table.'
    RETURN
  END 

  -- get Effective Date (qsicode 14)
  SELECT @v_effectivedate_datetype = datetypecode
    FROM datetype 
   WHERE qsicode = 14

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to access datetype table (effective date).'
    RETURN
  END 
 
  SET @v_effectivedate = null
  IF @v_effectivedate_datetype > 0 BEGIN
    SELECT @v_effectivedate = activedate
      FROM taqprojecttask
     WHERE taqprojectkey = @i_projectkey
       AND datetypecode = @v_effectivedate_datetype

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to access taqprojecttask table (effective date).'
      RETURN
    END 
  END
   
  -- get Expiration Date (qsicode 15)
  SELECT @v_expirationdate_datetype = datetypecode
    FROM datetype 
   WHERE qsicode = 15

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to access datetype table (expiration date).'
    RETURN
  END 
  
  SET @v_expirationdate = null
  IF @v_expirationdate_datetype > 0 BEGIN
    SELECT @v_expirationdate = activedate
      FROM taqprojecttask
     WHERE taqprojectkey = @i_projectkey
       AND datetypecode = @v_expirationdate_datetype

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to access taqprojecttask table (expiration date).'
      RETURN
    END 
  END
   
  -- NOTE: Uncomment if rows needed for all orgentries instead of one row with 0 
  ---- orgentrykey of 0 means all orgentries at the filterorglevel for scales
  --SELECT @v_num_orgentries = count(*)
  --  FROM taqprojectscaleorgentry
  -- WHERE taqprojectkey = @i_projectkey
  --   AND orgentrykey = 0

  --SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  --IF @error_var <> 0 BEGIN
  --  SET @o_error_code = -1
  --  SET @o_error_desc = 'Unable to access taqprojectscaleorgentry.'
  --  RETURN
  --END 
   
  SET @v_all_orgentries = 0
  --IF @v_num_orgentries = 1 BEGIN
  --  SET @v_all_orgentries = 1
  --END

  -- determine the number of vendors defined for this scale
  SELECT @v_num_vendors = count(*) 
    FROM (SELECT distinct globalcontactkey 
            FROM taqprojectcontact tpc, taqprojectcontactrole tpcr
           WHERE tpc.taqprojectcontactkey = tpcr.taqprojectcontactkey
             and tpc.taqprojectkey = tpcr.taqprojectkey
             and tpc.taqprojectkey = @i_projectkey
             and (tpcr.rolecode in (select datacode from gentables
                                     where tableid = 285
                                       and qsicode = 15)
              or tpcr.rolecode in (select code2 from gentablesrelationshipdetail
                                    where gentablesrelationshipkey = 20))) t

--print 'Num Vendors: ' + cast(@v_num_vendors as varchar)

  -- determine the number of parameters defined for this scale
  SELECT @v_num_parameters = count(*) 
    FROM (SELECT distinct itemcategorycode,itemcode
            FROM taqprojectscaleparameters
           WHERE taqprojectkey = @i_projectkey) t

--print 'Num Parameters: ' + cast(@v_num_parameters as varchar)

  -- get all the different parameters because there can be multiples of each
  DECLARE all_parameters_cur CURSOR fast_forward FOR
   SELECT distinct itemcategorycode,itemcode
     FROM taqprojectscaleparameters
    WHERE taqprojectkey = @i_projectkey
 ORDER BY itemcategorycode, itemcode
 
  OPEN all_parameters_cur

  IF @v_num_parameters > 0 BEGIN
    -- process parameter1
    FETCH from all_parameters_cur INTO @v_parameter1categorycode,@v_parameter1code
  END
  IF @@fetch_status = 0 and @v_num_parameters > 1 BEGIN
    FETCH NEXT from all_parameters_cur INTO @v_parameter2categorycode,@v_parameter2code
  END
  IF @@fetch_status = 0 and @v_num_parameters > 2 BEGIN
    FETCH NEXT from all_parameters_cur INTO @v_parameter3categorycode,@v_parameter3code
  END
  IF @@fetch_status = 0 and @v_num_parameters > 3 BEGIN
    FETCH NEXT from all_parameters_cur INTO @v_parameter4categorycode,@v_parameter4code
  END
  IF @@fetch_status = 0 and @v_num_parameters > 4 BEGIN
    FETCH NEXT from all_parameters_cur INTO @v_parameter5categorycode,@v_parameter5code
  END
  IF @@fetch_status = 0 and @v_num_parameters > 5 BEGIN
    FETCH NEXT from all_parameters_cur INTO @v_parameter6categorycode,@v_parameter6code
  END
  IF @@fetch_status = 0 and @v_num_parameters > 6 BEGIN
    FETCH NEXT from all_parameters_cur INTO @v_parameter7categorycode,@v_parameter7code
  END
  IF @@fetch_status = 0 and @v_num_parameters > 7 BEGIN
    FETCH NEXT from all_parameters_cur INTO @v_parameter8categorycode,@v_parameter8code
  END
  IF @@fetch_status = 0 and @v_num_parameters > 8 BEGIN
    FETCH NEXT from all_parameters_cur INTO @v_parameter9categorycode,@v_parameter9code
  END
  IF @@fetch_status = 0 and @v_num_parameters > 9 BEGIN
    FETCH NEXT from all_parameters_cur INTO @v_parameter10categorycode,@v_parameter10code
  END
  IF @@fetch_status = 0 and @v_num_parameters > 10 BEGIN
    FETCH NEXT from all_parameters_cur INTO @v_parameter11categorycode,@v_parameter11code
  END
  IF @@fetch_status = 0 and @v_num_parameters > 11 BEGIN
    FETCH NEXT from all_parameters_cur INTO @v_parameter12categorycode,@v_parameter12code
  END
  IF @@fetch_status = 0 and @v_num_parameters > 12 BEGIN
    FETCH NEXT from all_parameters_cur INTO @v_parameter13categorycode,@v_parameter13code
  END
  IF @@fetch_status = 0 and @v_num_parameters > 13 BEGIN
    FETCH NEXT from all_parameters_cur INTO @v_parameter14categorycode,@v_parameter14code
  END
  IF @@fetch_status = 0 and @v_num_parameters > 14 BEGIN
    FETCH NEXT from all_parameters_cur INTO @v_parameter15categorycode,@v_parameter15code
  END
  IF @@fetch_status = 0 and @v_num_parameters > 15 BEGIN
    FETCH NEXT from all_parameters_cur INTO @v_parameter16categorycode,@v_parameter16code
  END
  IF @@fetch_status = 0 and @v_num_parameters > 16 BEGIN
    FETCH NEXT from all_parameters_cur INTO @v_parameter17categorycode,@v_parameter17code
  END
  IF @@fetch_status = 0 and @v_num_parameters > 17 BEGIN
    FETCH NEXT from all_parameters_cur INTO @v_parameter18categorycode,@v_parameter18code
  END
  IF @@fetch_status = 0 and @v_num_parameters > 18 BEGIN
    FETCH NEXT from all_parameters_cur INTO @v_parameter19categorycode,@v_parameter19code
  END
  IF @@fetch_status = 0 and @v_num_parameters > 19 BEGIN
    FETCH NEXT from all_parameters_cur INTO @v_parameter20categorycode,@v_parameter20code
  END

  CLOSE all_parameters_cur
  DEALLOCATE all_parameters_cur

  -- process orgentries
  IF @v_all_orgentries = 1 BEGIN
    -- get all orgentrykeys from orgentry for filterorgelevel for scales
    DECLARE orgentry_cur CURSOR fast_forward FOR
     SELECT orgentrykey
       FROM orgentry
      WHERE orglevelkey in (SELECT filterorglevelkey FROM filterorglevel WHERE filterkey = 11)
   ORDER BY orgentrykey    
  END
  ELSE BEGIN
    DECLARE orgentry_cur CURSOR fast_forward FOR
     SELECT orgentrykey
       FROM taqprojectscaleorgentry
      WHERE taqprojectkey = @i_projectkey
        --AND orgentrykey > 0
   ORDER BY orgentrykey    
  END

  OPEN orgentry_cur

  FETCH from orgentry_cur INTO @v_orgentrykey

  WHILE @@fetch_status = 0 BEGIN
    -- process vendorkeys
    IF @v_num_vendors > 0 BEGIN
      DECLARE vendorkey_cur CURSOR fast_forward FOR
      SELECT distinct globalcontactkey 
        FROM taqprojectcontact tpc, taqprojectcontactrole tpcr
       WHERE tpc.taqprojectcontactkey = tpcr.taqprojectcontactkey
         and tpc.taqprojectkey = tpcr.taqprojectkey
         and tpc.taqprojectkey = @i_projectkey
         and (tpcr.rolecode in (select datacode from gentables
                                 where tableid = 285
                                   and qsicode = 15)
          or tpcr.rolecode in (select code2 from gentablesrelationshipdetail
                                where gentablesrelationshipkey = 20))
      ORDER BY globalcontactkey
    END
    ELSE BEGIN
      DECLARE vendorkey_cur CURSOR FOR
      SELECT 0
    END
        
    OPEN vendorkey_cur

    FETCH from vendorkey_cur INTO @v_vendorkey

    WHILE @@fetch_status = 0 BEGIN
      -- process scaleparameters
      -- we can store up to 20 parameters on corescaleparameters at this time
      -- there can be multiples of each individual parameter 
      IF (@v_num_parameters > 0) BEGIN
        -- process parameter1
        IF @v_parameter1categorycode > 0 and @v_parameter1code > 0 BEGIN
          DECLARE parameter1_cur CURSOR fast_forward FOR
           SELECT value1,value2,dbo.get_gentables_desc(616,itemcategorycode,'long'),
                  dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
             FROM taqprojectscaleparameters
            WHERE taqprojectkey = @i_projectkey
              AND itemcategorycode = @v_parameter1categorycode
              AND itemcode = @v_parameter1code
              
          OPEN parameter1_cur

          FETCH from parameter1_cur INTO @v_parameter1value1,@v_parameter1value2,
                                         @v_parameter1categorydesc,@v_parameter1desc

          WHILE @@fetch_status = 0 BEGIN
            --print '@v_parameter1categorycode: ' + cast(@v_parameter1categorycode as varchar)          
            --print '@v_parameter1code: ' + cast(@v_parameter1code as varchar)          
            --print '@v_parameter1value1: ' + cast(@v_parameter1value1 as varchar)          
            --print '@v_parameter1value2: ' + cast(@v_parameter1value2 as varchar)          
          
            IF (@v_num_parameters > 1) BEGIN
              -- process parameter2
              IF @v_parameter2categorycode > 0 and @v_parameter2code > 0 BEGIN
                DECLARE parameter2_cur CURSOR fast_forward FOR
                 SELECT value1,value2,dbo.get_gentables_desc(616,itemcategorycode,'long'),
                        dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
                   FROM taqprojectscaleparameters
                  WHERE taqprojectkey = @i_projectkey
                    AND itemcategorycode = @v_parameter2categorycode
                    AND itemcode = @v_parameter2code
                    
                OPEN parameter2_cur

                FETCH from parameter2_cur INTO @v_parameter2value1,@v_parameter2value2,
                                               @v_parameter2categorydesc,@v_parameter2desc

                WHILE @@fetch_status = 0 BEGIN
                  --print '@v_parameter2categorycode: ' + cast(@v_parameter2categorycode as varchar)          
                  --print '@v_parameter2code: ' + cast(@v_parameter2code as varchar)          
                  --print '@v_parameter2value1: ' + cast(@v_parameter2value1 as varchar)          
                  --print '@v_parameter2value2: ' + cast(@v_parameter2value2 as varchar)          

                  IF (@v_num_parameters > 2) BEGIN
                    -- process parameter3
                    IF @v_parameter3categorycode > 0 and @v_parameter3code > 0 BEGIN
                      DECLARE parameter3_cur CURSOR fast_forward FOR
                       SELECT value1,value2,dbo.get_gentables_desc(616,itemcategorycode,'long'),
                              dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
                         FROM taqprojectscaleparameters
                        WHERE taqprojectkey = @i_projectkey
                          AND itemcategorycode = @v_parameter3categorycode
                          AND itemcode = @v_parameter3code
                          
                      OPEN parameter3_cur

                      FETCH from parameter3_cur INTO @v_parameter3value1,@v_parameter3value2,
                                                     @v_parameter3categorydesc,@v_parameter3desc

                      WHILE @@fetch_status = 0 BEGIN
                        IF (@v_num_parameters > 3) BEGIN
                          -- process parameter4
                          IF @v_parameter4categorycode > 0 and @v_parameter4code > 0 BEGIN
                            DECLARE parameter4_cur CURSOR fast_forward FOR
                             SELECT value1,value2,dbo.get_gentables_desc(616,itemcategorycode,'long'),
                                    dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
                               FROM taqprojectscaleparameters
                              WHERE taqprojectkey = @i_projectkey
                                AND itemcategorycode = @v_parameter4categorycode
                                AND itemcode = @v_parameter4code
                                
                            OPEN parameter4_cur

                            FETCH from parameter4_cur INTO @v_parameter4value1,@v_parameter4value2,
                                                           @v_parameter4categorydesc,@v_parameter4desc

                            WHILE @@fetch_status = 0 BEGIN
                              IF (@v_num_parameters > 4) BEGIN
                                -- process parameter5
                                IF @v_parameter5categorycode > 0 and @v_parameter5code > 0 BEGIN
                                  DECLARE parameter5_cur CURSOR fast_forward FOR
                                   SELECT value1,value2,dbo.get_gentables_desc(616,itemcategorycode,'long'),
                                          dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
                                     FROM taqprojectscaleparameters
                                    WHERE taqprojectkey = @i_projectkey
                                      AND itemcategorycode = @v_parameter5categorycode
                                      AND itemcode = @v_parameter5code
                                      
                                  OPEN parameter5_cur

                                  FETCH from parameter5_cur INTO @v_parameter5value1,@v_parameter5value2,
                                                                 @v_parameter5categorydesc,@v_parameter5desc

                                  WHILE @@fetch_status = 0 BEGIN
                                    IF (@v_num_parameters > 5) BEGIN
                                      -- process parameter6
                                      IF @v_parameter6categorycode > 0 and @v_parameter6code > 0 BEGIN
                                        DECLARE parameter6_cur CURSOR fast_forward FOR
                                         SELECT value1,value2,dbo.get_gentables_desc(616,itemcategorycode,'long'),
                                                dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
                                           FROM taqprojectscaleparameters
                                          WHERE taqprojectkey = @i_projectkey
                                            AND itemcategorycode = @v_parameter6categorycode
                                            AND itemcode = @v_parameter6code
                                            
                                        OPEN parameter6_cur

                                        FETCH from parameter6_cur INTO @v_parameter6value1,@v_parameter6value2,
                                                                       @v_parameter6categorydesc,@v_parameter6desc

                                        WHILE @@fetch_status = 0 BEGIN
                                          IF (@v_num_parameters > 6) BEGIN
                                            -- process parameter7
                                            IF @v_parameter7categorycode > 0 and @v_parameter7code > 0 BEGIN
                                              DECLARE parameter7_cur CURSOR fast_forward FOR
                                               SELECT value1,value2,dbo.get_gentables_desc(616,itemcategorycode,'long'),
                                                      dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
                                                 FROM taqprojectscaleparameters
                                                WHERE taqprojectkey = @i_projectkey
                                                  AND itemcategorycode = @v_parameter7categorycode
                                                  AND itemcode = @v_parameter7code
                                                  
                                              OPEN parameter7_cur

                                              FETCH from parameter7_cur INTO @v_parameter7value1,@v_parameter7value2,
                                                                             @v_parameter7categorydesc,@v_parameter7desc

                                              WHILE @@fetch_status = 0 BEGIN
                                                IF (@v_num_parameters > 7) BEGIN
                                                  -- process parameter8
                                                  IF @v_parameter8categorycode > 0 and @v_parameter8code > 0 BEGIN
                                                    DECLARE parameter8_cur CURSOR fast_forward FOR
                                                     SELECT value1,value2,dbo.get_gentables_desc(616,itemcategorycode,'long'),
                                                            dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
                                                       FROM taqprojectscaleparameters
                                                      WHERE taqprojectkey = @i_projectkey
                                                        AND itemcategorycode = @v_parameter8categorycode
                                                        AND itemcode = @v_parameter8code
                                                        
                                                    OPEN parameter8_cur

                                                    FETCH from parameter8_cur INTO @v_parameter8value1,@v_parameter8value2,
                                                                                   @v_parameter8categorydesc,@v_parameter8desc

                                                    WHILE @@fetch_status = 0 BEGIN
                                                      IF (@v_num_parameters > 8) BEGIN
                                                        -- process parameter9
                                                        IF @v_parameter9categorycode > 0 and @v_parameter9code > 0 BEGIN
                                                          DECLARE parameter9_cur CURSOR fast_forward FOR
                                                           SELECT value1,value2,dbo.get_gentables_desc(616,itemcategorycode,'long'),
                                                                  dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
                                                             FROM taqprojectscaleparameters
                                                            WHERE taqprojectkey = @i_projectkey
                                                              AND itemcategorycode = @v_parameter9categorycode
                                                              AND itemcode = @v_parameter9code
                                                              
                                                          OPEN parameter9_cur

                                                          FETCH from parameter9_cur INTO @v_parameter9value1,@v_parameter9value2,
                                                                                         @v_parameter9categorydesc,@v_parameter9desc

                                                          WHILE @@fetch_status = 0 BEGIN
                                                            IF (@v_num_parameters > 9) BEGIN
                                                              -- process parameter10
                                                              IF @v_parameter10categorycode > 0 and @v_parameter10code > 0 BEGIN
                                                                DECLARE parameter10_cur CURSOR fast_forward FOR
                                                                 SELECT value1,value2,dbo.get_gentables_desc(616,itemcategorycode,'long'),
                                                                        dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
                                                                   FROM taqprojectscaleparameters
                                                                  WHERE taqprojectkey = @i_projectkey
                                                                    AND itemcategorycode = @v_parameter10categorycode
                                                                    AND itemcode = @v_parameter10code
                                                                    
                                                                OPEN parameter10_cur

                                                                FETCH from parameter10_cur INTO @v_parameter10value1,@v_parameter10value2,
                                                                                               @v_parameter10categorydesc,@v_parameter10desc

                                                                WHILE @@fetch_status = 0 BEGIN
                                                                  IF (@v_num_parameters > 10) BEGIN
                                                                    -- process parameter11
                                                                    IF @v_parameter11categorycode > 0 and @v_parameter11code > 0 BEGIN
                                                                      DECLARE parameter11_cur CURSOR fast_forward FOR
                                                                       SELECT value1,value2,dbo.get_gentables_desc(616,itemcategorycode,'long'),
                                                                              dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
                                                                         FROM taqprojectscaleparameters
                                                                        WHERE taqprojectkey = @i_projectkey
                                                                          AND itemcategorycode = @v_parameter11categorycode
                                                                          AND itemcode = @v_parameter11code
                                                                          
                                                                      OPEN parameter11_cur

                                                                      FETCH from parameter11_cur INTO @v_parameter11value1,@v_parameter11value2,
                                                                                                     @v_parameter11categorydesc,@v_parameter11desc

                                                                      WHILE @@fetch_status = 0 BEGIN
                                                                        IF (@v_num_parameters > 11) BEGIN
                                                                          -- process parameter12
                                                                          IF @v_parameter12categorycode > 0 and @v_parameter12code > 0 BEGIN
                                                                            DECLARE parameter12_cur CURSOR fast_forward FOR
                                                                             SELECT value1,value2,dbo.get_gentables_desc(616,itemcategorycode,'long'),
                                                                                    dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
                                                                               FROM taqprojectscaleparameters
                                                                              WHERE taqprojectkey = @i_projectkey
                                                                                AND itemcategorycode = @v_parameter12categorycode
                                                                                AND itemcode = @v_parameter12code
                                                                                
                                                                            OPEN parameter12_cur

                                                                            FETCH from parameter12_cur INTO @v_parameter12value1,@v_parameter12value2,
                                                                                                           @v_parameter12categorydesc,@v_parameter12desc

                                                                            WHILE @@fetch_status = 0 BEGIN
                                                                              IF (@v_num_parameters > 12) BEGIN
                                                                                -- process parameter13
                                                                                IF @v_parameter13categorycode > 0 and @v_parameter13code > 0 BEGIN
                                                                                  DECLARE parameter13_cur CURSOR fast_forward FOR
                                                                                   SELECT value1,value2,dbo.get_gentables_desc(616,itemcategorycode,'long'),
                                                                                          dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
                                                                                     FROM taqprojectscaleparameters
                                                                                    WHERE taqprojectkey = @i_projectkey
                                                                                      AND itemcategorycode = @v_parameter13categorycode
                                                                                      AND itemcode = @v_parameter13code
                                                                                      
                                                                                  OPEN parameter13_cur

                                                                                  FETCH from parameter13_cur INTO @v_parameter13value1,@v_parameter13value2,
                                                                                                                 @v_parameter13categorydesc,@v_parameter13desc

                                                                                  WHILE @@fetch_status = 0 BEGIN
                                                                                    IF (@v_num_parameters > 13) BEGIN
                                                                                      -- process parameter14
                                                                                      IF @v_parameter14categorycode > 0 and @v_parameter14code > 0 BEGIN
                                                                                        DECLARE parameter14_cur CURSOR fast_forward FOR
                                                                                         SELECT value1,value2,dbo.get_gentables_desc(616,itemcategorycode,'long'),
                                                                                                dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
                                                                                           FROM taqprojectscaleparameters
                                                                                          WHERE taqprojectkey = @i_projectkey
                                                                                            AND itemcategorycode = @v_parameter14categorycode
                                                                                            AND itemcode = @v_parameter14code
                                                                                            
                                                                                        OPEN parameter14_cur

                                                                                        FETCH from parameter14_cur INTO @v_parameter14value1,@v_parameter14value2,
                                                                                                                       @v_parameter14categorydesc,@v_parameter14desc

                                                                                        WHILE @@fetch_status = 0 BEGIN
                                                                                          IF (@v_num_parameters > 14) BEGIN
                                                                                            -- process parameter15
                                                                                            IF @v_parameter15categorycode > 0 and @v_parameter15code > 0 BEGIN
                                                                                              DECLARE parameter15_cur CURSOR fast_forward FOR
                                                                                               SELECT value1,value2,dbo.get_gentables_desc(616,itemcategorycode,'long'),
                                                                                                      dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
                                                                                                 FROM taqprojectscaleparameters
                                                                                                WHERE taqprojectkey = @i_projectkey
                                                                                                  AND itemcategorycode = @v_parameter15categorycode
                                                                                                  AND itemcode = @v_parameter15code
                                                                                                  
                                                                                              OPEN parameter15_cur

                                                                                              FETCH from parameter15_cur INTO @v_parameter15value1,@v_parameter15value2,
                                                                                                                             @v_parameter15categorydesc,@v_parameter15desc

                                                                                              WHILE @@fetch_status = 0 BEGIN
                                                                                                IF (@v_num_parameters > 15) BEGIN
                                                                                                  -- process parameter16
                                                                                                  IF @v_parameter16categorycode > 0 and @v_parameter16code > 0 BEGIN
                                                                                                    DECLARE parameter16_cur CURSOR fast_forward FOR
                                                                                                     SELECT value1,value2,dbo.get_gentables_desc(616,itemcategorycode,'long'),
                                                                                                            dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
                                                                                                       FROM taqprojectscaleparameters
                                                                                                      WHERE taqprojectkey = @i_projectkey
                                                                                                        AND itemcategorycode = @v_parameter16categorycode
                                                                                                        AND itemcode = @v_parameter16code
                                                                                                        
                                                                                                    OPEN parameter16_cur

                                                                                                    FETCH from parameter16_cur INTO @v_parameter16value1,@v_parameter16value2,
                                                                                                                                   @v_parameter16categorydesc,@v_parameter16desc

                                                                                                    WHILE @@fetch_status = 0 BEGIN
                                                                                                      IF (@v_num_parameters > 16) BEGIN
                                                                                                        -- process parameter17
                                                                                                        IF @v_parameter17categorycode > 0 and @v_parameter17code > 0 BEGIN
                                                                                                          DECLARE parameter17_cur CURSOR fast_forward FOR
                                                                                                           SELECT value1,value2,dbo.get_gentables_desc(616,itemcategorycode,'long'),
                                                                                                                  dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
                                                                                                             FROM taqprojectscaleparameters
                                                                                                            WHERE taqprojectkey = @i_projectkey
                                                                                                              AND itemcategorycode = @v_parameter17categorycode
                                                                                                              AND itemcode = @v_parameter17code
                                                                                                              
                                                                                                          OPEN parameter17_cur

                                                                                                          FETCH from parameter17_cur INTO @v_parameter17value1,@v_parameter17value2,
                                                                                                                                         @v_parameter17categorydesc,@v_parameter17desc

                                                                                                          WHILE @@fetch_status = 0 BEGIN
                                                                                                            IF (@v_num_parameters > 17) BEGIN
                                                                                                              -- process parameter18
                                                                                                              IF @v_parameter18categorycode > 0 and @v_parameter18code > 0 BEGIN
                                                                                                                DECLARE parameter18_cur CURSOR fast_forward FOR
                                                                                                                 SELECT value1,value2,dbo.get_gentables_desc(616,itemcategorycode,'long'),
                                                                                                                        dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
                                                                                                                   FROM taqprojectscaleparameters
                                                                                                                  WHERE taqprojectkey = @i_projectkey
                                                                                                                    AND itemcategorycode = @v_parameter18categorycode
                                                                                                                    AND itemcode = @v_parameter18code
                                                                                                                    
                                                                                                                OPEN parameter18_cur

                                                                                                                FETCH from parameter18_cur INTO @v_parameter18value1,@v_parameter18value2,
                                                                                                                                               @v_parameter18categorydesc,@v_parameter18desc

                                                                                                                WHILE @@fetch_status = 0 BEGIN
                                                                                                                  IF (@v_num_parameters > 18) BEGIN
                                                                                                                    -- process parameter19
                                                                                                                    IF @v_parameter19categorycode > 0 and @v_parameter19code > 0 BEGIN
                                                                                                                      DECLARE parameter19_cur CURSOR fast_forward FOR
                                                                                                                       SELECT value1,value2,dbo.get_gentables_desc(616,itemcategorycode,'long'),
                                                                                                                              dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
                                                                                                                         FROM taqprojectscaleparameters
                                                                                                                        WHERE taqprojectkey = @i_projectkey
                                                                                                                          AND itemcategorycode = @v_parameter19categorycode
                                                                                                                          AND itemcode = @v_parameter19code
                                                                                                                          
                                                                                                                      OPEN parameter19_cur

                                                                                                                      FETCH from parameter19_cur INTO @v_parameter19value1,@v_parameter19value2,
                                                                                                                                                     @v_parameter19categorydesc,@v_parameter19desc

                                                                                                                      WHILE @@fetch_status = 0 BEGIN
                                                                                                                        IF (@v_num_parameters > 19) BEGIN
                                                                                                                          -- process parameter20
                                                                                                                          IF @v_parameter20categorycode > 0 and @v_parameter20code > 0 BEGIN
                                                                                                                            DECLARE parameter20_cur CURSOR fast_forward FOR
                                                                                                                             SELECT value1,value2,dbo.get_gentables_desc(616,itemcategorycode,'long'),
                                                                                                                                    dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
                                                                                                                               FROM taqprojectscaleparameters
                                                                                                                              WHERE taqprojectkey = @i_projectkey
                                                                                                                                AND itemcategorycode = @v_parameter20categorycode
                                                                                                                                AND itemcode = @v_parameter20code
                                                                                                                                
                                                                                                                            OPEN parameter20_cur

                                                                                                                            FETCH from parameter20_cur INTO @v_parameter20value1,@v_parameter20value2,
                                                                                                                                                           @v_parameter20categorydesc,@v_parameter20desc

                                                                                                                            WHILE @@fetch_status = 0 BEGIN
                                                                                                                              -- insert
                                                                                                                              INSERT INTO corescaleparameters
                                                                                                                                (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
                                                                                                                                 orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
                                                                                                                                 parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
                                                                                                                                 parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
                                                                                                                                 parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
                                                                                                                                 parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
                                                                                                                                 parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
                                                                                                                                 parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
                                                                                                                                 parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
                                                                                                                                 parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
                                                                                                                                 parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
                                                                                                                                 parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
                                                                                                                                 parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
                                                                                                                                 parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
                                                                                                                                 parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
                                                                                                                                 parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
                                                                                                                                 parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
                                                                                                                                 parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
                                                                                                                                 parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
                                                                                                                                 parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
                                                                                                                                 parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
                                                                                                                                 parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
                                                                                                                              VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
                                                                                                                                @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
                                                                                                                                @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
                                                                                                                                @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
                                                                                                                                @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
                                                                                                                                @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
                                                                                                                                @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
                                                                                                                                @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
                                                                                                                                @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
                                                                                                                                @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
                                                                                                                                @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
                                                                                                                                @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
                                                                                                                                @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
                                                                                                                                @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
                                                                                                                                @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
                                                                                                                                @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
                                                                                                                                @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
                                                                                                                                @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
                                                                                                                                @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
                                                                                                                                @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
                                                                                                                                @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
                                                                                                                                @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
                                                                                                                            
                                                                                                                              FETCH NEXT from parameter20_cur INTO @v_parameter20value1,@v_parameter20value2,
                                                                                                                                                                  @v_parameter20categorydesc,@v_parameter20desc
                                                                                                                            END
                                                                                                                            CLOSE parameter20_cur
                                                                                                                            DEALLOCATE parameter20_cur
                                                                                                                          END 
                                                                                                                        END -- parameter20
                                                                                                                        ELSE BEGIN
                                                                                                                          -- insert
                                                                                                                          INSERT INTO corescaleparameters
                                                                                                                            (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
                                                                                                                             orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
                                                                                                                             parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
                                                                                                                             parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
                                                                                                                             parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
                                                                                                                             parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
                                                                                                                             parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
                                                                                                                             parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
                                                                                                                             parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
                                                                                                                             parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
                                                                                                                             parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
                                                                                                                             parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
                                                                                                                             parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
                                                                                                                             parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
                                                                                                                             parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
                                                                                                                             parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
                                                                                                                             parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
                                                                                                                             parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
                                                                                                                             parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
                                                                                                                             parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
                                                                                                                             parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
                                                                                                                             parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
                                                                                                                          VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
                                                                                                                            @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
                                                                                                                            @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
                                                                                                                            @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
                                                                                                                            @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
                                                                                                                            @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
                                                                                                                            @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
                                                                                                                            @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
                                                                                                                            @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
                                                                                                                            @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
                                                                                                                            @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
                                                                                                                            @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
                                                                                                                            @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
                                                                                                                            @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
                                                                                                                            @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
                                                                                                                            @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
                                                                                                                            @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
                                                                                                                            @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
                                                                                                                            @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
                                                                                                                            @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
                                                                                                                            @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
                                                                                                                            @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
                                                                                                                        END
                                                                                                                        
                                                                                                                        FETCH NEXT from parameter19_cur INTO @v_parameter19value1,@v_parameter19value2,
                                                                                                                                                            @v_parameter19categorydesc,@v_parameter19desc
                                                                                                                      END
                                                                                                                      CLOSE parameter19_cur
                                                                                                                      DEALLOCATE parameter19_cur
                                                                                                                    END 
                                                                                                                  END -- parameter19
                                                                                                                  ELSE BEGIN
                                                                                                                    -- insert
                                                                                                                    INSERT INTO corescaleparameters
                                                                                                                      (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
                                                                                                                       orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
                                                                                                                       parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
                                                                                                                       parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
                                                                                                                       parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
                                                                                                                       parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
                                                                                                                       parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
                                                                                                                       parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
                                                                                                                       parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
                                                                                                                       parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
                                                                                                                       parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
                                                                                                                       parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
                                                                                                                       parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
                                                                                                                       parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
                                                                                                                       parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
                                                                                                                       parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
                                                                                                                       parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
                                                                                                                       parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
                                                                                                                       parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
                                                                                                                       parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
                                                                                                                       parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
                                                                                                                       parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
                                                                                                                    VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
                                                                                                                      @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
                                                                                                                      @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
                                                                                                                      @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
                                                                                                                      @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
                                                                                                                      @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
                                                                                                                      @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
                                                                                                                      @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
                                                                                                                      @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
                                                                                                                      @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
                                                                                                                      @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
                                                                                                                      @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
                                                                                                                      @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
                                                                                                                      @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
                                                                                                                      @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
                                                                                                                      @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
                                                                                                                      @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
                                                                                                                      @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
                                                                                                                      @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
                                                                                                                      @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
                                                                                                                      @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
                                                                                                                      @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
                                                                                                                  END
                                                                                                          
                                                                                                                  FETCH NEXT from parameter18_cur INTO @v_parameter18value1,@v_parameter18value2,
                                                                                                                                                      @v_parameter18categorydesc,@v_parameter18desc
                                                                                                                END
                                                                                                                CLOSE parameter18_cur
                                                                                                                DEALLOCATE parameter18_cur
                                                                                                              END 
                                                                                                            END -- parameter18
                                                                                                            ELSE BEGIN
                                                                                                              -- insert
                                                                                                              INSERT INTO corescaleparameters
                                                                                                                (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
                                                                                                                 orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
                                                                                                                 parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
                                                                                                                 parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
                                                                                                                 parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
                                                                                                                 parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
                                                                                                                 parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
                                                                                                                 parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
                                                                                                                 parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
                                                                                                                 parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
                                                                                                                 parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
                                                                                                                 parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
                                                                                                                 parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
                                                                                                                 parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
                                                                                                                 parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
                                                                                                                 parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
                                                                                                                 parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
                                                                                                                 parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
                                                                                                                 parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
                                                                                                                 parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
                                                                                                                 parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
                                                                                                                 parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
                                                                                                              VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
                                                                                                                @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
                                                                                                                @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
                                                                                                                @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
                                                                                                                @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
                                                                                                                @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
                                                                                                                @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
                                                                                                                @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
                                                                                                                @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
                                                                                                                @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
                                                                                                                @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
                                                                                                                @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
                                                                                                                @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
                                                                                                                @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
                                                                                                                @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
                                                                                                                @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
                                                                                                                @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
                                                                                                                @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
                                                                                                                @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
                                                                                                                @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
                                                                                                                @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
                                                                                                                @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
                                                                                                            END
                                                                                                          
                                                                                                            FETCH NEXT from parameter17_cur INTO @v_parameter17value1,@v_parameter17value2,
                                                                                                                                                @v_parameter17categorydesc,@v_parameter17desc
                                                                                                          END
                                                                                                          CLOSE parameter17_cur
                                                                                                          DEALLOCATE parameter17_cur
                                                                                                        END 
                                                                                                      END -- parameter17
                                                                                                      ELSE BEGIN
                                                                                                        -- insert
                                                                                                        INSERT INTO corescaleparameters
                                                                                                          (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
                                                                                                           orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
                                                                                                           parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
                                                                                                           parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
                                                                                                           parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
                                                                                                           parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
                                                                                                           parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
                                                                                                           parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
                                                                                                           parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
                                                                                                           parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
                                                                                                           parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
                                                                                                           parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
                                                                                                           parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
                                                                                                           parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
                                                                                                           parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
                                                                                                           parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
                                                                                                           parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
                                                                                                           parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
                                                                                                           parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
                                                                                                           parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
                                                                                                           parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
                                                                                                           parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
                                                                                                        VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
                                                                                                          @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
                                                                                                          @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
                                                                                                          @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
                                                                                                          @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
                                                                                                          @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
                                                                                                          @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
                                                                                                          @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
                                                                                                          @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
                                                                                                          @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
                                                                                                          @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
                                                                                                          @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
                                                                                                          @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
                                                                                                          @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
                                                                                                          @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
                                                                                                          @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
                                                                                                          @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
                                                                                                          @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
                                                                                                          @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
                                                                                                          @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
                                                                                                          @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
                                                                                                          @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
                                                                                                      END
                                                                                                    
                                                                                                      FETCH NEXT from parameter16_cur INTO @v_parameter16value1,@v_parameter16value2,
                                                                                                                                          @v_parameter16categorydesc,@v_parameter16desc
                                                                                                    END
                                                                                                    CLOSE parameter16_cur
                                                                                                    DEALLOCATE parameter16_cur
                                                                                                  END 
                                                                                                END -- parameter16
                                                                                                ELSE BEGIN
                                                                                                  -- insert
                                                                                                  INSERT INTO corescaleparameters
                                                                                                    (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
                                                                                                     orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
                                                                                                     parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
                                                                                                     parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
                                                                                                     parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
                                                                                                     parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
                                                                                                     parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
                                                                                                     parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
                                                                                                     parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
                                                                                                     parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
                                                                                                     parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
                                                                                                     parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
                                                                                                     parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
                                                                                                     parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
                                                                                                     parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
                                                                                                     parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
                                                                                                     parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
                                                                                                     parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
                                                                                                     parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
                                                                                                     parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
                                                                                                     parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
                                                                                                     parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
                                                                                                  VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
                                                                                                    @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
                                                                                                    @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
                                                                                                    @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
                                                                                                    @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
                                                                                                    @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
                                                                                                    @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
                                                                                                    @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
                                                                                                    @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
                                                                                                    @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
                                                                                                    @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
                                                                                                    @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
                                                                                                    @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
                                                                                                    @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
                                                                                                    @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
                                                                                                    @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
                                                                                                    @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
                                                                                                    @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
                                                                                                    @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
                                                                                                    @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
                                                                                                    @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
                                                                                                    @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
                                                                                                END
                                                                                        
                                                                                                FETCH NEXT from parameter15_cur INTO @v_parameter15value1,@v_parameter15value2,
                                                                                                                                    @v_parameter15categorydesc,@v_parameter15desc
                                                                                              END
                                                                                              CLOSE parameter15_cur
                                                                                              DEALLOCATE parameter15_cur
                                                                                            END 
                                                                                          END -- parameter15
                                                                                          ELSE BEGIN
                                                                                            -- insert
                                                                                            INSERT INTO corescaleparameters
                                                                                              (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
                                                                                               orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
                                                                                               parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
                                                                                               parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
                                                                                               parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
                                                                                               parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
                                                                                               parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
                                                                                               parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
                                                                                               parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
                                                                                               parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
                                                                                               parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
                                                                                               parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
                                                                                               parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
                                                                                               parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
                                                                                               parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
                                                                                               parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
                                                                                               parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
                                                                                               parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
                                                                                               parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
                                                                                               parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
                                                                                               parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
                                                                                               parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
                                                                                            VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
                                                                                              @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
                                                                                              @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
                                                                                              @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
                                                                                              @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
                                                                                              @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
                                                                                              @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
                                                                                              @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
                                                                                              @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
                                                                                              @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
                                                                                              @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
                                                                                              @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
                                                                                              @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
                                                                                              @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
                                                                                              @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
                                                                                              @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
                                                                                              @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
                                                                                              @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
                                                                                              @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
                                                                                              @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
                                                                                              @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
                                                                                              @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
                                                                                          END
                                                                                        
                                                                                          FETCH NEXT from parameter14_cur INTO @v_parameter14value1,@v_parameter14value2,
                                                                                                                              @v_parameter14categorydesc,@v_parameter14desc
                                                                                        END
                                                                                        CLOSE parameter14_cur
                                                                                        DEALLOCATE parameter14_cur
                                                                                      END 
                                                                                    END -- parameter14
                                                                                    ELSE BEGIN
                                                                                      -- insert
                                                                                      INSERT INTO corescaleparameters
                                                                                        (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
                                                                                         orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
                                                                                         parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
                                                                                         parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
                                                                                         parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
                                                                                         parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
                                                                                         parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
                                                                                         parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
                                                                                         parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
                                                                                         parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
                                                                                         parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
                                                                                         parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
                                                                                         parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
                                                                                         parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
                                                                                         parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
                                                                                         parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
                                                                                         parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
                                                                                         parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
                                                                                         parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
                                                                                         parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
                                                                                         parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
                                                                                         parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
                                                                                      VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
                                                                                        @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
                                                                                        @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
                                                                                        @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
                                                                                        @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
                                                                                        @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
                                                                                        @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
                                                                                        @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
                                                                                        @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
                                                                                        @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
                                                                                        @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
                                                                                        @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
                                                                                        @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
                                                                                        @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
                                                                                        @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
                                                                                        @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
                                                                                        @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
                                                                                        @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
                                                                                        @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
                                                                                        @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
                                                                                        @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
                                                                                        @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
                                                                                    END
                                                                                  
                                                                                    FETCH NEXT from parameter13_cur INTO @v_parameter13value1,@v_parameter13value2,
                                                                                                                        @v_parameter13categorydesc,@v_parameter13desc
                                                                                  END
                                                                                  CLOSE parameter13_cur
                                                                                  DEALLOCATE parameter13_cur
                                                                                END 
                                                                              END -- parameter13 
                                                                              ELSE BEGIN
                                                                                -- insert
                                                                                INSERT INTO corescaleparameters
                                                                                  (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
                                                                                   orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
                                                                                   parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
                                                                                   parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
                                                                                   parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
                                                                                   parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
                                                                                   parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
                                                                                   parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
                                                                                   parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
                                                                                   parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
                                                                                   parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
                                                                                   parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
                                                                                   parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
                                                                                   parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
                                                                                   parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
                                                                                   parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
                                                                                   parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
                                                                                   parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
                                                                                   parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
                                                                                   parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
                                                                                   parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
                                                                                   parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
                                                                                VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
                                                                                  @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
                                                                                  @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
                                                                                  @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
                                                                                  @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
                                                                                  @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
                                                                                  @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
                                                                                  @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
                                                                                  @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
                                                                                  @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
                                                                                  @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
                                                                                  @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
                                                                                  @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
                                                                                  @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
                                                                                  @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
                                                                                  @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
                                                                                  @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
                                                                                  @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
                                                                                  @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
                                                                                  @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
                                                                                  @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
                                                                                  @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
                                                                              END
                                                                                                                                                         
                                                                              FETCH NEXT from parameter12_cur INTO @v_parameter12value1,@v_parameter12value2,
                                                                                                                  @v_parameter12categorydesc,@v_parameter12desc
                                                                            END
                                                                            CLOSE parameter12_cur
                                                                            DEALLOCATE parameter12_cur
                                                                          END 
                                                                        END -- parameter12
                                                                        ELSE BEGIN
                                                                          -- insert
                                                                          INSERT INTO corescaleparameters
                                                                            (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
                                                                             orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
                                                                             parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
                                                                             parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
                                                                             parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
                                                                             parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
                                                                             parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
                                                                             parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
                                                                             parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
                                                                             parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
                                                                             parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
                                                                             parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
                                                                             parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
                                                                             parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
                                                                             parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
                                                                             parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
                                                                             parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
                                                                             parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
                                                                             parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
                                                                             parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
                                                                             parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
                                                                             parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
                                                                          VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
                                                                            @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
                                                                            @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
                                                                            @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
                                                                            @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
                                                                            @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
                                                                            @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
                                                                            @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
                                                                            @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
                                                                            @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
                                                                            @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
                                                                            @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
                                                                            @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
                                                                            @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
                                                                            @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
                                                                            @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
                                                                            @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
                                                                            @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
                                                                            @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
                                                                            @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
                                                                            @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
                                                                            @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
                                                                        END
                                                                      
                                                                        FETCH NEXT from parameter11_cur INTO @v_parameter11value1,@v_parameter11value2,
                                                                                                            @v_parameter11categorydesc,@v_parameter11desc
                                                                      END
                                                                      CLOSE parameter11_cur
                                                                      DEALLOCATE parameter11_cur
                                                                    END 
                                                                  END -- parameter11
                                                                  ELSE BEGIN
                                                                    -- insert
                                                                    INSERT INTO corescaleparameters
                                                                      (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
                                                                       orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
                                                                       parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
                                                                       parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
                                                                       parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
                                                                       parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
                                                                       parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
                                                                       parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
                                                                       parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
                                                                       parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
                                                                       parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
                                                                       parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
                                                                       parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
                                                                       parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
                                                                       parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
                                                                       parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
                                                                       parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
                                                                       parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
                                                                       parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
                                                                       parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
                                                                       parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
                                                                       parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
                                                                    VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
                                                                      @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
                                                                      @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
                                                                      @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
                                                                      @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
                                                                      @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
                                                                      @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
                                                                      @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
                                                                      @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
                                                                      @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
                                                                      @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
                                                                      @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
                                                                      @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
                                                                      @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
                                                                      @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
                                                                      @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
                                                                      @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
                                                                      @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
                                                                      @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
                                                                      @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
                                                                      @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
                                                                      @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
                                                                  END
                                                                                                                                
                                                                  FETCH NEXT from parameter10_cur INTO @v_parameter10value1,@v_parameter10value2,
                                                                                                      @v_parameter10categorydesc,@v_parameter10desc
                                                                END
                                                                CLOSE parameter10_cur
                                                                DEALLOCATE parameter10_cur
                                                              END 
                                                            END -- parameter10                                                         
                                                            ELSE BEGIN
                                                              -- insert
                                                              INSERT INTO corescaleparameters
                                                                (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
                                                                 orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
                                                                 parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
                                                                 parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
                                                                 parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
                                                                 parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
                                                                 parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
                                                                 parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
                                                                 parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
                                                                 parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
                                                                 parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
                                                                 parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
                                                                 parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
                                                                 parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
                                                                 parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
                                                                 parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
                                                                 parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
                                                                 parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
                                                                 parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
                                                                 parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
                                                                 parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
                                                                 parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
                                                              VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
                                                                @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
                                                                @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
                                                                @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
                                                                @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
                                                                @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
                                                                @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
                                                                @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
                                                                @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
                                                                @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
                                                                @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
                                                                @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
                                                                @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
                                                                @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
                                                                @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
                                                                @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
                                                                @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
                                                                @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
                                                                @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
                                                                @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
                                                                @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
                                                                @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
                                                            END
                                                          
                                                            FETCH NEXT from parameter9_cur INTO @v_parameter9value1,@v_parameter9value2,
                                                                                                @v_parameter9categorydesc,@v_parameter9desc
                                                          END
                                                          CLOSE parameter9_cur
                                                          DEALLOCATE parameter9_cur
                                                        END 
                                                      END -- parameter9
                                                      ELSE BEGIN
                                                        -- insert
                                                        INSERT INTO corescaleparameters
                                                          (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
                                                           orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
                                                           parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
                                                           parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
                                                           parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
                                                           parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
                                                           parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
                                                           parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
                                                           parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
                                                           parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
                                                           parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
                                                           parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
                                                           parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
                                                           parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
                                                           parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
                                                           parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
                                                           parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
                                                           parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
                                                           parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
                                                           parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
                                                           parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
                                                           parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
                                                        VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
                                                          @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
                                                          @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
                                                          @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
                                                          @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
                                                          @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
                                                          @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
                                                          @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
                                                          @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
                                                          @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
                                                          @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
                                                          @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
                                                          @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
                                                          @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
                                                          @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
                                                          @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
                                                          @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
                                                          @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
                                                          @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
                                                          @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
                                                          @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
                                                          @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
                                                      END

                                                      FETCH NEXT from parameter8_cur INTO @v_parameter8value1,@v_parameter8value2,
                                                                                          @v_parameter8categorydesc,@v_parameter8desc
                                                    END
                                                    CLOSE parameter8_cur
                                                    DEALLOCATE parameter8_cur
                                                  END 
                                                END -- parameter8
                                                ELSE BEGIN
                                                  -- insert
                                                  INSERT INTO corescaleparameters
                                                    (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
                                                     orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
                                                     parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
                                                     parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
                                                     parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
                                                     parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
                                                     parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
                                                     parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
                                                     parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
                                                     parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
                                                     parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
                                                     parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
                                                     parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
                                                     parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
                                                     parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
                                                     parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
                                                     parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
                                                     parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
                                                     parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
                                                     parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
                                                     parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
                                                     parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
                                                  VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
                                                    @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
                                                    @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
                                                    @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
                                                    @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
                                                    @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
                                                    @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
                                                    @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
                                                    @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
                                                    @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
                                                    @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
                                                    @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
                                                    @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
                                                    @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
                                                    @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
                                                    @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
                                                    @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
                                                    @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
                                                    @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
                                                    @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
                                                    @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
                                                    @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
                                                END
                                                                                          
                                                FETCH NEXT from parameter7_cur INTO @v_parameter7value1,@v_parameter7value2,
                                                                                    @v_parameter7categorydesc,@v_parameter7desc
                                              END
                                              CLOSE parameter7_cur
                                              DEALLOCATE parameter7_cur
                                            END 
                                          END -- parameter7
                                          ELSE BEGIN
                                            -- insert
                                            INSERT INTO corescaleparameters
                                              (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
                                               orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
                                               parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
                                               parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
                                               parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
                                               parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
                                               parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
                                               parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
                                               parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
                                               parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
                                               parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
                                               parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
                                               parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
                                               parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
                                               parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
                                               parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
                                               parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
                                               parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
                                               parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
                                               parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
                                               parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
                                               parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
                                            VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
                                              @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
                                              @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
                                              @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
                                              @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
                                              @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
                                              @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
                                              @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
                                              @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
                                              @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
                                              @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
                                              @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
                                              @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
                                              @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
                                              @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
                                              @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
                                              @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
                                              @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
                                              @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
                                              @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
                                              @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
                                              @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
                                          END
                                        
                                          FETCH NEXT from parameter6_cur INTO @v_parameter6value1,@v_parameter6value2,
                                                                              @v_parameter6categorydesc,@v_parameter6desc
                                        END
                                        CLOSE parameter6_cur
                                        DEALLOCATE parameter6_cur
                                      END 
                                    END -- parameter6
                                    ELSE BEGIN
                                      -- insert
                                      INSERT INTO corescaleparameters
                                        (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
                                         orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
                                         parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
                                         parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
                                         parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
                                         parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
                                         parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
                                         parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
                                         parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
                                         parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
                                         parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
                                         parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
                                         parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
                                         parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
                                         parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
                                         parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
                                         parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
                                         parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
                                         parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
                                         parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
                                         parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
                                         parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
                                      VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
                                        @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
                                        @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
                                        @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
                                        @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
                                        @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
                                        @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
                                        @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
                                        @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
                                        @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
                                        @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
                                        @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
                                        @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
                                        @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
                                        @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
                                        @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
                                        @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
                                        @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
                                        @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
                                        @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
                                        @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
                                        @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
                                    END
                                                                                                              
                                    FETCH NEXT from parameter5_cur INTO @v_parameter5value1,@v_parameter5value2,
                                                                        @v_parameter5categorydesc,@v_parameter5desc
                                  END
                                  CLOSE parameter5_cur
                                  DEALLOCATE parameter5_cur
                                END 
                              END -- parameter5
                              ELSE BEGIN
                                -- insert
                                INSERT INTO corescaleparameters
                                  (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
                                   orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
                                   parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
                                   parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
                                   parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
                                   parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
                                   parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
                                   parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
                                   parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
                                   parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
                                   parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
                                   parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
                                   parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
                                   parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
                                   parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
                                   parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
                                   parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
                                   parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
                                   parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
                                   parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
                                   parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
                                   parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
                                VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
                                  @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
                                  @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
                                  @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
                                  @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
                                  @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
                                  @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
                                  @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
                                  @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
                                  @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
                                  @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
                                  @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
                                  @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
                                  @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
                                  @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
                                  @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
                                  @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
                                  @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
                                  @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
                                  @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
                                  @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
                                  @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
                              END
                                                       
                              FETCH NEXT from parameter4_cur INTO @v_parameter4value1,@v_parameter4value2,
                                                                  @v_parameter4categorydesc,@v_parameter4desc
                            END
                            CLOSE parameter4_cur
                            DEALLOCATE parameter4_cur
                          END 
                        END -- parameter4
                        ELSE BEGIN
                          -- insert
                          INSERT INTO corescaleparameters
                            (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
                             orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
                             parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
                             parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
                             parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
                             parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
                             parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
                             parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
                             parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
                             parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
                             parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
                             parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
                             parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
                             parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
                             parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
                             parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
                             parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
                             parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
                             parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
                             parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
                             parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
                             parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
                          VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
                            @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
                            @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
                            @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
                            @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
                            @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
                            @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
                            @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
                            @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
                            @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
                            @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
                            @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
                            @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
                            @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
                            @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
                            @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
                            @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
                            @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
                            @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
                            @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
                            @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
                            @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
                        END
                                                                      
                        FETCH NEXT from parameter3_cur INTO @v_parameter3value1,@v_parameter3value2,
                                                            @v_parameter3categorydesc,@v_parameter3desc
                      END
                      CLOSE parameter3_cur
                      DEALLOCATE parameter3_cur
                    END 
                  END -- parameter3
                  ELSE BEGIN
                    --print 'insert3'                          
                    -- insert
                    INSERT INTO corescaleparameters
                      (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
                       orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
                       parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
                       parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
                       parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
                       parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
                       parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
                       parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
                       parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
                       parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
                       parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
                       parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
                       parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
                       parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
                       parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
                       parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
                       parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
                       parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
                       parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
                       parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
                       parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
                       parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
                    VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
                      @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
                      @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
                      @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
                      @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
                      @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
                      @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
                      @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
                      @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
                      @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
                      @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
                      @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
                      @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
                      @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
                      @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
                      @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
                      @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
                      @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
                      @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
                      @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
                      @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
                      @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
                  END
                                
                  FETCH NEXT from parameter2_cur INTO @v_parameter2value1,@v_parameter2value2,
                                                      @v_parameter2categorydesc,@v_parameter2desc
                END
                CLOSE parameter2_cur
                DEALLOCATE parameter2_cur
              END 
            END -- parameter2
            ELSE BEGIN
              -- insert
              --print 'insert2'                          
              INSERT INTO corescaleparameters
                (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
                 orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
                 parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
                 parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
                 parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
                 parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
                 parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
                 parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
                 parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
                 parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
                 parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
                 parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
                 parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
                 parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
                 parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
                 parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
                 parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
                 parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
                 parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
                 parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
                 parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
                 parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
              VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
                @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
                @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
                @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
                @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
                @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
                @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
                @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
                @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
                @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
                @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
                @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
                @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
                @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
                @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
                @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
                @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
                @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
                @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
                @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
                @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
                @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
            END

            FETCH NEXT from parameter1_cur INTO @v_parameter1value1,@v_parameter1value2,
                                                @v_parameter1categorydesc,@v_parameter1desc   
          END                
          CLOSE parameter1_cur
          DEALLOCATE parameter1_cur
        END         
      END -- parameter1
      ELSE BEGIN
        --print 'insert1'                          
        -- insert
        INSERT INTO corescaleparameters
          (taqprojectkey,scalename,scaletype,scaletypedesc,scalestatuscode,scalestatusdesc,
           orgentrykey,vendorkey,effectivedate,expirationdate,lastuserid,lastmaintdate,
           parameter1categorycode,parameter1categorydesc,parameter1code,parameter1desc,parameter1value1,parameter1value2,
           parameter2categorycode,parameter2categorydesc,parameter2code,parameter2desc,parameter2value1,parameter2value2,
           parameter3categorycode,parameter3categorydesc,parameter3code,parameter3desc,parameter3value1,parameter3value2,
           parameter4categorycode,parameter4categorydesc,parameter4code,parameter4desc,parameter4value1,parameter4value2,
           parameter5categorycode,parameter5categorydesc,parameter5code,parameter5desc,parameter5value1,parameter5value2,
           parameter6categorycode,parameter6categorydesc,parameter6code,parameter6desc,parameter6value1,parameter6value2,
           parameter7categorycode,parameter7categorydesc,parameter7code,parameter7desc,parameter7value1,parameter7value2,
           parameter8categorycode,parameter8categorydesc,parameter8code,parameter8desc,parameter8value1,parameter8value2,
           parameter9categorycode,parameter9categorydesc,parameter9code,parameter9desc,parameter9value1,parameter9value2,
           parameter10categorycode,parameter10categorydesc,parameter10code,parameter10desc,parameter10value1,parameter10value2,
           parameter11categorycode,parameter11categorydesc,parameter11code,parameter11desc,parameter11value1,parameter11value2,
           parameter12categorycode,parameter12categorydesc,parameter12code,parameter12desc,parameter12value1,parameter12value2,
           parameter13categorycode,parameter13categorydesc,parameter13code,parameter13desc,parameter13value1,parameter13value2,
           parameter14categorycode,parameter14categorydesc,parameter14code,parameter14desc,parameter14value1,parameter14value2,
           parameter15categorycode,parameter15categorydesc,parameter15code,parameter15desc,parameter15value1,parameter15value2,
           parameter16categorycode,parameter16categorydesc,parameter16code,parameter16desc,parameter16value1,parameter16value2,
           parameter17categorycode,parameter17categorydesc,parameter17code,parameter17desc,parameter17value1,parameter17value2,
           parameter18categorycode,parameter18categorydesc,parameter18code,parameter18desc,parameter18value1,parameter18value2,
           parameter19categorycode,parameter19categorydesc,parameter19code,parameter19desc,parameter19value1,parameter19value2,
           parameter20categorycode,parameter20categorydesc,parameter20code,parameter20desc,parameter20value1,parameter20value2)   
        VALUES (@i_projectkey,@v_scalename,@v_scaletype,@v_scaletypedesc,@v_statuscode,@v_statusdesc,
          @v_orgentrykey,@v_vendorkey,@v_effectivedate,@v_expirationdate,@i_userid,getdate(),
          @v_parameter1categorycode,@v_parameter1categorydesc,@v_parameter1code,@v_parameter1desc,@v_parameter1value1,@v_parameter1value2,
          @v_parameter2categorycode,@v_parameter2categorydesc,@v_parameter2code,@v_parameter2desc,@v_parameter2value1,@v_parameter2value2,
          @v_parameter3categorycode,@v_parameter3categorydesc,@v_parameter3code,@v_parameter3desc,@v_parameter3value1,@v_parameter3value2,
          @v_parameter4categorycode,@v_parameter4categorydesc,@v_parameter4code,@v_parameter4desc,@v_parameter4value1,@v_parameter4value2,
          @v_parameter5categorycode,@v_parameter5categorydesc,@v_parameter5code,@v_parameter5desc,@v_parameter5value1,@v_parameter5value2,
          @v_parameter6categorycode,@v_parameter6categorydesc,@v_parameter6code,@v_parameter6desc,@v_parameter6value1,@v_parameter6value2,
          @v_parameter7categorycode,@v_parameter7categorydesc,@v_parameter7code,@v_parameter7desc,@v_parameter7value1,@v_parameter7value2,
          @v_parameter8categorycode,@v_parameter8categorydesc,@v_parameter8code,@v_parameter8desc,@v_parameter8value1,@v_parameter8value2,
          @v_parameter9categorycode,@v_parameter9categorydesc,@v_parameter9code,@v_parameter9desc,@v_parameter9value1,@v_parameter9value2,
          @v_parameter10categorycode,@v_parameter10categorydesc,@v_parameter10code,@v_parameter10desc,@v_parameter10value1,@v_parameter10value2,
          @v_parameter11categorycode,@v_parameter11categorydesc,@v_parameter11code,@v_parameter11desc,@v_parameter11value1,@v_parameter11value2,
          @v_parameter12categorycode,@v_parameter12categorydesc,@v_parameter12code,@v_parameter12desc,@v_parameter12value1,@v_parameter12value2,
          @v_parameter13categorycode,@v_parameter13categorydesc,@v_parameter13code,@v_parameter13desc,@v_parameter13value1,@v_parameter13value2,
          @v_parameter14categorycode,@v_parameter14categorydesc,@v_parameter14code,@v_parameter14desc,@v_parameter14value1,@v_parameter14value2,
          @v_parameter15categorycode,@v_parameter15categorydesc,@v_parameter15code,@v_parameter15desc,@v_parameter15value1,@v_parameter15value2,
          @v_parameter16categorycode,@v_parameter16categorydesc,@v_parameter16code,@v_parameter16desc,@v_parameter16value1,@v_parameter16value2,
          @v_parameter17categorycode,@v_parameter17categorydesc,@v_parameter17code,@v_parameter17desc,@v_parameter17value1,@v_parameter17value2,
          @v_parameter18categorycode,@v_parameter18categorydesc,@v_parameter18code,@v_parameter18desc,@v_parameter18value1,@v_parameter18value2,
          @v_parameter19categorycode,@v_parameter19categorydesc,@v_parameter19code,@v_parameter19desc,@v_parameter19value1,@v_parameter19value2,
          @v_parameter20categorycode,@v_parameter20categorydesc,@v_parameter20code,@v_parameter20desc,@v_parameter20value1,@v_parameter20value2)                                                                                                                                  
      END    
               
      FETCH NEXT from vendorkey_cur INTO @v_vendorkey
    END

    CLOSE vendorkey_cur
    DEALLOCATE vendorkey_cur

    FETCH NEXT from orgentry_cur INTO @v_orgentrykey
  END

  CLOSE orgentry_cur
  DEALLOCATE orgentry_cur     
END

GO
GRANT EXEC ON qscale_maintain_corescaleparameters TO PUBLIC
GO


