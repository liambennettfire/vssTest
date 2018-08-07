if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_scale_for_speccategory') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_scale_for_speccategory
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_get_scale_for_speccategory
 (@i_speccategorykey          integer,
  @i_projectkey               integer,
  @i_taqversionformatyearkey  integer,
  @i_processtype							integer,
  @o_scaleprojectkey          integer output,
  @o_error_code               integer output,
  @o_error_desc               varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qscale_get_scale_for_speccategory
**  Desc: This stored procedure will fiind the scale projectkey for the 
**        spec category being processed 
**
**    Auth: Alan Katzen
**    Date: 21 March 2012
*******************************************************************************/

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_scaleprojectkey = 0
  
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_count INT,
          @v_messagetype_error INT,
          @v_message varchar(2000),
          @v_scaleprojectkey INT,
          @v_corescaleparameterkey INT,
          @v_scaleprojectttype INT,
          @v_scaleprojecttypedesc VARCHAR(50),
          @v_max_date datetime,
          @v_min_date datetime,         
          @v_orgentrykey INT,
          @v_orgentrydesc VARCHAR(50),
          @v_statuscode_active INT,
          @v_vendorkey INT,
          @v_vendorname VARCHAR(255),
          @v_num_parameters INT,          
          @v_parameter1categorycode int,
          @v_parameter1categorydesc varchar(50),
          @v_parameter1code int,
          @v_parameter1desc varchar(50),
          @v_parameter1value int,
          --@v_parameter1value2 int,
          @v_parameter2categorycode int,
          @v_parameter2categorydesc varchar(50),
          @v_parameter2code int,
          @v_parameter2desc varchar(50),
          @v_parameter2value int,
          --@v_parameter2value2 int,
          @v_parameter3categorycode int,
          @v_parameter3categorydesc varchar(50),
          @v_parameter3code int,
          @v_parameter3desc varchar(50),
          @v_parameter3value int,
          --@v_parameter3value2 int,
          @v_parameter4categorycode int,
          @v_parameter4categorydesc varchar(50),
          @v_parameter4code int,
          @v_parameter4desc varchar(50),
          @v_parameter4value int,
          --@v_parameter4value2 int,
          @v_parameter5categorycode int,
          @v_parameter5categorydesc varchar(50),
          @v_parameter5code int,
          @v_parameter5desc varchar(50),
          @v_parameter5value int,
          --@v_parameter5value2 int,
          @v_parameter6categorycode int,
          @v_parameter6categorydesc varchar(50),
          @v_parameter6code int,
          @v_parameter6desc varchar(50),
          @v_parameter6value int,
          --@v_parameter6value2 int,
          @v_parameter7categorycode int,
          @v_parameter7categorydesc varchar(50),
          @v_parameter7code int,
          @v_parameter7desc varchar(50),
          @v_parameter7value int,
          --@v_parameter7value2 int,
          @v_parameter8categorycode int,
          @v_parameter8categorydesc varchar(50),
          @v_parameter8code int,
          @v_parameter8desc varchar(50),
          @v_parameter8value int,
          --@v_parameter8value2 int,
          @v_parameter9categorycode int,
          @v_parameter9categorydesc varchar(50),
          @v_parameter9code int,
          @v_parameter9desc varchar(50),
          @v_parameter9value int,
          --@v_parameter9value2 int,
          @v_parameter10categorycode int,
          @v_parameter10categorydesc varchar(50),
          @v_parameter10code int,
          @v_parameter10desc varchar(50),
          @v_parameter10value int,
          --@v_parameter10value2 int,
          @v_parameter11categorycode int,
          @v_parameter11categorydesc varchar(50),
          @v_parameter11code int,
          @v_parameter11desc varchar(50),
          @v_parameter11value int,
          --@v_parameter11value2 int,
          @v_parameter12categorycode int,
          @v_parameter12categorydesc varchar(50),
          @v_parameter12code int,
          @v_parameter12desc varchar(50),
          @v_parameter12value int,
          --@v_parameter12value2 int,
          @v_parameter13categorycode int,
          @v_parameter13categorydesc varchar(50),
          @v_parameter13code int,
          @v_parameter13desc varchar(50),
          @v_parameter13value int,
          --@v_parameter13value2 int,
          @v_parameter14categorycode int,
          @v_parameter14categorydesc varchar(50),
          @v_parameter14code int,
          @v_parameter14desc varchar(50),
          @v_parameter14value int,
          --@v_parameter14value2 int,
          @v_parameter15categorycode int,
          @v_parameter15categorydesc varchar(50),
          @v_parameter15code int,
          @v_parameter15desc varchar(50),
          @v_parameter15value int,
          --@v_parameter15value2 int,
          @v_parameter16categorycode int,
          @v_parameter16categorydesc varchar(50),
          @v_parameter16code int,
          @v_parameter16desc varchar(50),
          @v_parameter16value int,
          --@v_parameter16value2 int,
          @v_parameter17categorycode int,
          @v_parameter17categorydesc varchar(50),
          @v_parameter17code int,
          @v_parameter17desc varchar(50),
          @v_parameter17value int,
          --@v_parameter17value2 int,
          @v_parameter18categorycode int,
          @v_parameter18categorydesc varchar(50),
          @v_parameter18code int,
          @v_parameter18desc varchar(50),
          @v_parameter18value int,
          --@v_parameter18value2 int,
          @v_parameter19categorycode int,
          @v_parameter19categorydesc varchar(50),
          @v_parameter19code int,
          @v_parameter19desc varchar(50),
          @v_parameter19value int,
          --@v_parameter19value2 int,
          @v_parameter20categorycode int,
          @v_parameter20categorydesc varchar(50),
          @v_parameter20code int,
          @v_parameter20desc varchar(50),
          @v_parameter20value int
          --@v_parameter20value2 int         

  IF COALESCE(@i_speccategorykey,0) = 0 BEGIN
    return
  END
  IF COALESCE(@i_projectkey,0) = 0 BEGIN
    return
  END
  IF COALESCE(@i_taqversionformatyearkey,0) = 0 BEGIN
    return
  END

  SET @v_scaleprojectkey = 0

  SET @v_max_date = CONVERT(DATETIME, '99991231 23:59:59:997', 101)
  SET @v_min_date = CONVERT(DATETIME, '17530101', 101)

  SELECT @v_messagetype_error = datacode
    FROM gentables
   WHERE tableid = 539
     AND qsicode = 2

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to access gentables (message type - tableid 539).'
    RETURN
  END 

  SELECT @v_statuscode_active = datacode
    FROM gentables
   WHERE tableid = 522
     AND qsicode = 3

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to access gentables (projectstatus - tableid 522).'
    RETURN
  END 
     
  -- get the orgentry at the scale orglevel
  SELECT @v_orgentrykey = tpo.orgentrykey,
         @v_orgentrydesc = (select orgentrydesc from orgentry where orgentrykey = tpo.orgentrykey)
    FROM taqprojectorgentry tpo
   WHERE tpo.orglevelkey in (SELECT filterorglevelkey FROM filterorglevel WHERE filterkey = 11)

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to access taqprojectorgentry table.'
    RETURN
  END 

  IF COALESCE(@v_orgentrykey,0) = 0 BEGIN
    -- no orgentry found at scale org level
    SET @o_error_code = -1
    SET @o_error_desc = 'No orgentry found at scale org level.'
    return
  END

  SELECT @v_scaleprojectttype = scaleprojecttype,
         @v_scaleprojecttypedesc = dbo.get_gentables_desc(521,scaleprojecttype,'long'),
         @v_vendorkey = vendorcontactkey,
         @v_vendorname = dbo.qcontact_get_displayname(vendorcontactkey)
    FROM taqversionspeccategory
   WHERE taqversionspecategorykey = @i_speccategorykey
   
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to access taqversionspeccategory table.'
    RETURN
  END 
     
  IF COALESCE(@v_scaleprojectttype,0) = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'scaleprojecttype is empty on taqversionspeccategory(speccategorykey = ' + cast(@i_speccategorykey as varchar) + ').'
    RETURN
  END
     
  -- initialize parameter values
  SET @v_parameter1value = null
  SET @v_parameter2value = null
  SET @v_parameter3value = null
  SET @v_parameter4value = null
  SET @v_parameter5value = null
  SET @v_parameter6value = null
  SET @v_parameter7value = null
  SET @v_parameter8value = null
  SET @v_parameter9value = null
  SET @v_parameter10value = null
  SET @v_parameter11value = null
  SET @v_parameter12value = null
  SET @v_parameter13value = null
  SET @v_parameter14value = null
  SET @v_parameter15value = null
  SET @v_parameter16value = null
  SET @v_parameter17value = null
  SET @v_parameter18value = null
  SET @v_parameter19value = null
  SET @v_parameter20value = null
     
  -- determine the number of specitems defined for this scale type
  SELECT @v_num_parameters = count(*) 
    FROM (SELECT distinct itemcategorycode,itemcode
            FROM taqscaleadminspecitem
           WHERE scaletypecode = @v_scaleprojectttype
             AND parametertypecode = 1) t
   
  --print '@v_num_parameters: ' + cast(@v_num_parameters as varchar)
  
  -- get all the different specitems defined for this scale type
  DECLARE get_specitems_cur CURSOR fast_forward FOR
   SELECT si.itemcategorycode,si.itemcode,
          dbo.qscale_find_specification_value(@i_taqversionformatyearkey,si.itemcategorycode,si.itemcode),
          dbo.get_gentables_desc(616,itemcategorycode,'long'),
          dbo.get_subgentables_desc(616,itemcategorycode,itemcode,'long')
     FROM taqscaleadminspecitem si
    WHERE si.scaletypecode = @v_scaleprojectttype
      AND si.parametertypecode = 1  -- scale parameter
 ORDER BY si.itemcategorycode, si.itemcode
 
  OPEN get_specitems_cur

  IF @v_num_parameters > 0 BEGIN
    -- process parameter1
    FETCH from get_specitems_cur INTO @v_parameter1categorycode,@v_parameter1code,@v_parameter1value,@v_parameter1categorydesc,@v_parameter1desc
  END
  IF @@fetch_status = 0 and @v_num_parameters > 1 BEGIN
    FETCH NEXT from get_specitems_cur INTO @v_parameter2categorycode,@v_parameter2code,@v_parameter2value,@v_parameter2categorydesc,@v_parameter2desc
  END
  IF @@fetch_status = 0 and @v_num_parameters > 2 BEGIN
    FETCH NEXT from get_specitems_cur INTO @v_parameter3categorycode,@v_parameter3code,@v_parameter3value,@v_parameter3categorydesc,@v_parameter3desc
  END
  IF @@fetch_status = 0 and @v_num_parameters > 3 BEGIN
    FETCH NEXT from get_specitems_cur INTO @v_parameter4categorycode,@v_parameter4code,@v_parameter4value,@v_parameter4categorydesc,@v_parameter4desc
  END
  IF @@fetch_status = 0 and @v_num_parameters > 4 BEGIN
    FETCH NEXT from get_specitems_cur INTO @v_parameter5categorycode,@v_parameter5code,@v_parameter5value,@v_parameter5categorydesc,@v_parameter5desc
  END
  IF @@fetch_status = 0 and @v_num_parameters > 5 BEGIN
    FETCH NEXT from get_specitems_cur INTO @v_parameter6categorycode,@v_parameter6code,@v_parameter6value,@v_parameter6categorydesc,@v_parameter6desc
  END
  IF @@fetch_status = 0 and @v_num_parameters > 6 BEGIN
    FETCH NEXT from get_specitems_cur INTO @v_parameter7categorycode,@v_parameter7code,@v_parameter7value,@v_parameter7categorydesc,@v_parameter7desc
  END
  IF @@fetch_status = 0 and @v_num_parameters > 7 BEGIN
    FETCH NEXT from get_specitems_cur INTO @v_parameter8categorycode,@v_parameter8code,@v_parameter8value,@v_parameter8categorydesc,@v_parameter8desc
  END
  IF @@fetch_status = 0 and @v_num_parameters > 8 BEGIN
    FETCH NEXT from get_specitems_cur INTO @v_parameter9categorycode,@v_parameter9code,@v_parameter9value,@v_parameter9categorydesc,@v_parameter9desc
  END
  IF @@fetch_status = 0 and @v_num_parameters > 9 BEGIN
    FETCH NEXT from get_specitems_cur INTO @v_parameter10categorycode,@v_parameter10code,@v_parameter10value,@v_parameter10categorydesc,@v_parameter10desc
  END
  IF @@fetch_status = 0 and @v_num_parameters > 10 BEGIN
    FETCH NEXT from get_specitems_cur INTO @v_parameter11categorycode,@v_parameter11code,@v_parameter11value,@v_parameter11categorydesc,@v_parameter11desc
  END
  IF @@fetch_status = 0 and @v_num_parameters > 11 BEGIN
    FETCH NEXT from get_specitems_cur INTO @v_parameter12categorycode,@v_parameter12code,@v_parameter12value,@v_parameter12categorydesc,@v_parameter12desc
  END
  IF @@fetch_status = 0 and @v_num_parameters > 12 BEGIN
    FETCH NEXT from get_specitems_cur INTO @v_parameter13categorycode,@v_parameter13code,@v_parameter13value,@v_parameter13categorydesc,@v_parameter13desc
  END
  IF @@fetch_status = 0 and @v_num_parameters > 13 BEGIN
    FETCH NEXT from get_specitems_cur INTO @v_parameter14categorycode,@v_parameter14code,@v_parameter14value,@v_parameter14categorydesc,@v_parameter14desc
  END
  IF @@fetch_status = 0 and @v_num_parameters > 14 BEGIN
    FETCH NEXT from get_specitems_cur INTO @v_parameter15categorycode,@v_parameter15code,@v_parameter15value,@v_parameter15categorydesc,@v_parameter15desc
  END
  IF @@fetch_status = 0 and @v_num_parameters > 15 BEGIN
    FETCH NEXT from get_specitems_cur INTO @v_parameter16categorycode,@v_parameter16code,@v_parameter16value,@v_parameter16categorydesc,@v_parameter16desc
  END
  IF @@fetch_status = 0 and @v_num_parameters > 16 BEGIN
    FETCH NEXT from get_specitems_cur INTO @v_parameter17categorycode,@v_parameter17code,@v_parameter17value,@v_parameter17categorydesc,@v_parameter17desc
  END
  IF @@fetch_status = 0 and @v_num_parameters > 17 BEGIN
    FETCH NEXT from get_specitems_cur INTO @v_parameter18categorycode,@v_parameter18code,@v_parameter18value,@v_parameter18categorydesc,@v_parameter18desc
  END
  IF @@fetch_status = 0 and @v_num_parameters > 18 BEGIN
    FETCH NEXT from get_specitems_cur INTO @v_parameter19categorycode,@v_parameter19code,@v_parameter19value,@v_parameter19categorydesc,@v_parameter19desc
  END
  IF @@fetch_status = 0 and @v_num_parameters > 19 BEGIN
    FETCH NEXT from get_specitems_cur INTO @v_parameter20categorycode,@v_parameter20code,@v_parameter20value,@v_parameter20categorydesc,@v_parameter20desc
  END

  CLOSE get_specitems_cur
  DEALLOCATE get_specitems_cur
  
  if @v_parameter1categorydesc is not null and @v_parameter1desc is not null begin
    print @v_parameter1categorydesc + ' ' + @v_parameter1desc
    print '@v_parameter1value: ' +  cast(@v_parameter1value as varchar)
  end
  if @v_parameter2categorydesc is not null and @v_parameter2desc is not null begin
    print @v_parameter2categorydesc + ' ' + @v_parameter2desc
    print '@v_parameter2value: ' +  cast(@v_parameter2value as varchar)
  end
  if @v_parameter3categorydesc is not null and @v_parameter3desc is not null begin
    print @v_parameter3categorydesc + ' ' + @v_parameter3desc
    print '@v_parameter3value: ' +  cast(@v_parameter3value as varchar) 
  end
  if @v_parameter4categorydesc is not null and @v_parameter4desc is not null begin
    print @v_parameter4categorydesc + ' ' + @v_parameter4desc
    print '@v_parameter4value: ' +  cast(@v_parameter4value as varchar) 
  end
  if @v_parameter5categorydesc is not null and @v_parameter5desc is not null begin
    print @v_parameter5categorydesc + ' ' + @v_parameter5desc
    print '@v_parameter5value: ' +  cast(@v_parameter5value as varchar) 
  end
  if @v_parameter6categorydesc is not null and @v_parameter6desc is not null begin
    print @v_parameter6categorydesc + ' ' + @v_parameter6desc
    print '@v_parameter6value: ' +  cast(@v_parameter6value as varchar) 
  end
  if @v_parameter7categorydesc is not null and @v_parameter7desc is not null begin
    print @v_parameter7categorydesc + ' ' + @v_parameter7desc
    print '@v_parameter7value: ' +  cast(@v_parameter7value as varchar) 
  end
  if @v_parameter8categorydesc is not null and @v_parameter8desc is not null begin
    print @v_parameter8categorydesc + ' ' + @v_parameter8desc
    print '@v_parameter8value: ' +  cast(@v_parameter8value as varchar) 
  end
  if @v_parameter9categorydesc is not null and @v_parameter9desc is not null begin
    print @v_parameter9categorydesc + ' ' + @v_parameter9desc
    print '@v_parameter9value: ' +  cast(@v_parameter9value as varchar) 
  end
  if @v_parameter10categorydesc is not null and @v_parameter10desc is not null begin
    print @v_parameter10categorydesc + ' ' + @v_parameter10desc
    print '@v_parameter10value: ' +  cast(@v_parameter10value as varchar) 
  end
  if @v_parameter11categorydesc is not null and @v_parameter11desc is not null begin
    print @v_parameter11categorydesc + ' ' + @v_parameter11desc
    print '@v_parameter11value: ' +  cast(@v_parameter11value as varchar) 
  end
  if @v_parameter12categorydesc is not null and @v_parameter12desc is not null begin
    print @v_parameter12categorydesc + ' ' + @v_parameter12desc
    print '@v_parameter12value: ' +  cast(@v_parameter12value as varchar) 
  end
  if @v_parameter13categorydesc is not null and @v_parameter13desc is not null begin
    print @v_parameter13categorydesc + ' ' + @v_parameter13desc
    print '@v_parameter13value: ' +  cast(@v_parameter13value as varchar) 
  end
  if @v_parameter14categorydesc is not null and @v_parameter14desc is not null begin
    print @v_parameter14categorydesc + ' ' + @v_parameter14desc
    print '@v_parameter14value: ' +  cast(@v_parameter14value as varchar) 
  end
  if @v_parameter15categorydesc is not null and @v_parameter15desc is not null begin
    print @v_parameter15categorydesc + ' ' + @v_parameter15desc
    print '@v_parameter15value: ' +  cast(@v_parameter15value as varchar) 
  end
  if @v_parameter16categorydesc is not null and @v_parameter16desc is not null begin
    print @v_parameter16categorydesc + ' ' + @v_parameter16desc
    print '@v_parameter16value: ' +  cast(@v_parameter16value as varchar) 
  end
  if @v_parameter17categorydesc is not null and @v_parameter17desc is not null begin
    print @v_parameter17categorydesc + ' ' + @v_parameter17desc
    print '@v_parameter17value: ' +  cast(@v_parameter17value as varchar) 
  end
  if @v_parameter18categorydesc is not null and @v_parameter18desc is not null begin
    print @v_parameter18categorydesc + ' ' + @v_parameter18desc
    print '@v_parameter18value: ' +  cast(@v_parameter18value as varchar) 
  end
  if @v_parameter19categorydesc is not null and @v_parameter19desc is not null begin
    print @v_parameter19categorydesc + ' ' + @v_parameter19desc
    print '@v_parameter19value: ' +  cast(@v_parameter19value as varchar) 
  end
  if @v_parameter20categorydesc is not null and @v_parameter20desc is not null begin
    print @v_parameter20categorydesc + ' ' + @v_parameter20desc
    print '@v_parameter20value: ' +  cast(@v_parameter20value as varchar) 
  end
    
  -- try to find a matching scale
  SELECT @v_count = count(*)
    FROM corescaleparameters p, taqproject tp
   WHERE p.taqprojectkey = tp.taqprojectkey
     AND COALESCE(tp.templateind,0) <> 1 
     AND p.scaletype = @v_scaleprojectttype
     AND p.vendorkey = @v_vendorkey
     AND p.scalestatuscode = @v_statuscode_active --active
     --AND ((p.effectivedate is null and p.expirationdate is null) OR (getdate() between COALESCE(p.effectivedate,@v_min_date) and COALESCE(p.expirationdate,@v_max_date)))
     AND (getdate() between COALESCE(p.effectivedate,@v_min_date) and COALESCE(p.expirationdate,@v_max_date))
     AND (p.orgentrykey = 0 OR p.orgentrykey = @v_orgentrykey)
     AND (@v_parameter1value is null OR p.parameter1value1 = @v_parameter1value OR (@v_parameter1value >= p.parameter1value1 AND @v_parameter1value <= p.parameter1value2))
     AND (@v_parameter2value is null OR p.parameter2value1 = @v_parameter2value OR (@v_parameter2value >= p.parameter2value1 AND @v_parameter2value <= p.parameter2value2))
     AND (@v_parameter3value is null OR p.parameter3value1 = @v_parameter3value OR (@v_parameter3value >= p.parameter3value1 AND @v_parameter3value <= p.parameter3value2))
     AND (@v_parameter4value is null OR p.parameter4value1 = @v_parameter4value OR (@v_parameter4value >= p.parameter4value1 AND @v_parameter4value <= p.parameter4value2))
     AND (@v_parameter5value is null OR p.parameter5value1 = @v_parameter5value OR (@v_parameter5value >= p.parameter5value1 AND @v_parameter5value <= p.parameter5value2))
     AND (@v_parameter6value is null OR p.parameter6value1 = @v_parameter6value OR (@v_parameter6value >= p.parameter6value1 AND @v_parameter6value <= p.parameter6value2))
     AND (@v_parameter7value is null OR p.parameter7value1 = @v_parameter7value OR (@v_parameter7value >= p.parameter7value1 AND @v_parameter7value <= p.parameter7value2))
     AND (@v_parameter8value is null OR p.parameter8value1 = @v_parameter8value OR (@v_parameter8value >= p.parameter8value1 AND @v_parameter8value <= p.parameter8value2))
     AND (@v_parameter9value is null OR p.parameter9value1 = @v_parameter9value OR (@v_parameter9value >= p.parameter9value1 AND @v_parameter9value <= p.parameter9value2))
     AND (@v_parameter10value is null OR p.parameter10value1 = @v_parameter10value OR (@v_parameter10value >= p.parameter10value1 AND @v_parameter10value <= p.parameter10value2))
     AND (@v_parameter11value is null OR p.parameter11value1 = @v_parameter11value OR (@v_parameter11value >= p.parameter11value1 AND @v_parameter11value <= p.parameter11value2))
     AND (@v_parameter12value is null OR p.parameter12value1 = @v_parameter12value OR (@v_parameter12value >= p.parameter12value1 AND @v_parameter12value <= p.parameter12value2))
     AND (@v_parameter13value is null OR p.parameter13value1 = @v_parameter13value OR (@v_parameter13value >= p.parameter13value1 AND @v_parameter13value <= p.parameter13value2))
     AND (@v_parameter14value is null OR p.parameter14value1 = @v_parameter14value OR (@v_parameter14value >= p.parameter14value1 AND @v_parameter14value <= p.parameter14value2))
     AND (@v_parameter15value is null OR p.parameter15value1 = @v_parameter15value OR (@v_parameter15value >= p.parameter15value1 AND @v_parameter15value <= p.parameter15value2))
     AND (@v_parameter16value is null OR p.parameter16value1 = @v_parameter16value OR (@v_parameter16value >= p.parameter16value1 AND @v_parameter16value <= p.parameter16value2))
     AND (@v_parameter17value is null OR p.parameter17value1 = @v_parameter17value OR (@v_parameter17value >= p.parameter17value1 AND @v_parameter17value <= p.parameter17value2))
     AND (@v_parameter18value is null OR p.parameter18value1 = @v_parameter18value OR (@v_parameter18value >= p.parameter18value1 AND @v_parameter18value <= p.parameter18value2))
     AND (@v_parameter19value is null OR p.parameter19value1 = @v_parameter19value OR (@v_parameter19value >= p.parameter19value1 AND @v_parameter19value <= p.parameter19value2))
     AND (@v_parameter20value is null OR p.parameter20value1 = @v_parameter20value OR (@v_parameter20value >= p.parameter20value1 AND @v_parameter20value <= p.parameter20value2))
  
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to access corescaleparameters table (count).'
    RETURN
  END 
  
  IF @v_count <= 0 BEGIN
    -- no scale exists
    SET @v_message = 'No active scale exists for'                  
    goto finish_error                 
  END
  ELSE IF @v_count > 1 BEGIN
    -- more than one scale exists
    SET @v_message = 'Multiple active scales exist for' 
    goto finish_error                 
  END
  ELSE BEGIN
    -- found 1 scale
    SET @v_message = null

    -- get scale projectkey
    SELECT @v_scaleprojectkey = p.taqprojectkey, @v_corescaleparameterkey = p.corescaleparameterkey
      FROM corescaleparameters p, taqproject tp
     WHERE p.taqprojectkey = tp.taqprojectkey
       AND COALESCE(tp.templateind,0) <> 1 
       AND p.scaletype = @v_scaleprojectttype
       AND p.vendorkey = @v_vendorkey
       AND p.scalestatuscode = @v_statuscode_active --active
       --AND ((p.effectivedate is null and p.expirationdate is null) OR (getdate() between COALESCE(p.effectivedate,@v_min_date) and COALESCE(p.expirationdate,@v_max_date)))
       AND (getdate() between COALESCE(p.effectivedate,@v_min_date) and COALESCE(p.expirationdate,@v_max_date))
       AND (p.orgentrykey = 0 OR p.orgentrykey = @v_orgentrykey)
       AND (@v_parameter1value is null OR p.parameter1value1 = @v_parameter1value OR (@v_parameter1value >= p.parameter1value1 AND @v_parameter1value <= p.parameter1value2))
       AND (@v_parameter2value is null OR p.parameter2value1 = @v_parameter2value OR (@v_parameter2value >= p.parameter2value1 AND @v_parameter2value <= p.parameter2value2))
       AND (@v_parameter3value is null OR p.parameter3value1 = @v_parameter3value OR (@v_parameter3value >= p.parameter3value1 AND @v_parameter3value <= p.parameter3value2))
       AND (@v_parameter4value is null OR p.parameter4value1 = @v_parameter4value OR (@v_parameter4value >= p.parameter4value1 AND @v_parameter4value <= p.parameter4value2))
       AND (@v_parameter5value is null OR p.parameter5value1 = @v_parameter5value OR (@v_parameter5value >= p.parameter5value1 AND @v_parameter5value <= p.parameter5value2))
       AND (@v_parameter6value is null OR p.parameter6value1 = @v_parameter6value OR (@v_parameter6value >= p.parameter6value1 AND @v_parameter6value <= p.parameter6value2))
       AND (@v_parameter7value is null OR p.parameter7value1 = @v_parameter7value OR (@v_parameter7value >= p.parameter7value1 AND @v_parameter7value <= p.parameter7value2))
       AND (@v_parameter8value is null OR p.parameter8value1 = @v_parameter8value OR (@v_parameter8value >= p.parameter8value1 AND @v_parameter8value <= p.parameter8value2))
       AND (@v_parameter9value is null OR p.parameter9value1 = @v_parameter9value OR (@v_parameter9value >= p.parameter9value1 AND @v_parameter9value <= p.parameter9value2))
       AND (@v_parameter10value is null OR p.parameter10value1 = @v_parameter10value OR (@v_parameter10value >= p.parameter10value1 AND @v_parameter10value <= p.parameter10value2))
       AND (@v_parameter11value is null OR p.parameter11value1 = @v_parameter11value OR (@v_parameter11value >= p.parameter11value1 AND @v_parameter11value <= p.parameter11value2))
       AND (@v_parameter12value is null OR p.parameter12value1 = @v_parameter12value OR (@v_parameter12value >= p.parameter12value1 AND @v_parameter12value <= p.parameter12value2))
       AND (@v_parameter13value is null OR p.parameter13value1 = @v_parameter13value OR (@v_parameter13value >= p.parameter13value1 AND @v_parameter13value <= p.parameter13value2))
       AND (@v_parameter14value is null OR p.parameter14value1 = @v_parameter14value OR (@v_parameter14value >= p.parameter14value1 AND @v_parameter14value <= p.parameter14value2))
       AND (@v_parameter15value is null OR p.parameter15value1 = @v_parameter15value OR (@v_parameter15value >= p.parameter15value1 AND @v_parameter15value <= p.parameter15value2))
       AND (@v_parameter16value is null OR p.parameter16value1 = @v_parameter16value OR (@v_parameter16value >= p.parameter16value1 AND @v_parameter16value <= p.parameter16value2))
       AND (@v_parameter17value is null OR p.parameter17value1 = @v_parameter17value OR (@v_parameter17value >= p.parameter17value1 AND @v_parameter17value <= p.parameter17value2))
       AND (@v_parameter18value is null OR p.parameter18value1 = @v_parameter18value OR (@v_parameter18value >= p.parameter18value1 AND @v_parameter18value <= p.parameter18value2))
       AND (@v_parameter19value is null OR p.parameter19value1 = @v_parameter19value OR (@v_parameter19value >= p.parameter19value1 AND @v_parameter19value <= p.parameter19value2))
       AND (@v_parameter20value is null OR p.parameter20value1 = @v_parameter20value OR (@v_parameter20value >= p.parameter20value1 AND @v_parameter20value <= p.parameter20value2))
    
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to access corescaleparameters table.'
      RETURN
    END 
    
    -- make sure parameters are in the same order
    SELECT @v_count = count(*)
      FROM corescaleparameters p
     WHERE corescaleparameterkey = @v_corescaleparameterkey
       AND COALESCE(p.parameter1categorycode,0) = COALESCE(@v_parameter1categorycode,0)
       AND COALESCE(p.parameter1code,0) = COALESCE(@v_parameter1code,0)
       AND COALESCE(p.parameter2categorycode,0) = COALESCE(@v_parameter2categorycode,0)
       AND COALESCE(p.parameter2code,0) = COALESCE(@v_parameter2code,0)
       AND COALESCE(p.parameter3categorycode,0) = COALESCE(@v_parameter3categorycode,0)
       AND COALESCE(p.parameter3code,0) = COALESCE(@v_parameter3code,0)
       AND COALESCE(p.parameter4categorycode,0) = COALESCE(@v_parameter4categorycode,0)
       AND COALESCE(p.parameter4code,0) = COALESCE(@v_parameter4code,0)
       AND COALESCE(p.parameter5categorycode,0) = COALESCE(@v_parameter5categorycode,0)
       AND COALESCE(p.parameter5code,0) = COALESCE(@v_parameter5code,0)
       AND COALESCE(p.parameter6categorycode,0) = COALESCE(@v_parameter6categorycode,0)
       AND COALESCE(p.parameter6code,0) = COALESCE(@v_parameter6code,0)
       AND COALESCE(p.parameter7categorycode,0) = COALESCE(@v_parameter7categorycode,0)
       AND COALESCE(p.parameter7code,0) = COALESCE(@v_parameter7code,0)
       AND COALESCE(p.parameter8categorycode,0) = COALESCE(@v_parameter8categorycode,0)
       AND COALESCE(p.parameter8code,0) = COALESCE(@v_parameter8code,0)
       AND COALESCE(p.parameter9categorycode,0) = COALESCE(@v_parameter9categorycode,0)
       AND COALESCE(p.parameter9code,0) = COALESCE(@v_parameter9code,0)
       AND COALESCE(p.parameter10categorycode,0) = COALESCE(@v_parameter10categorycode,0)
       AND COALESCE(p.parameter10code,0) = COALESCE(@v_parameter10code,0)
       AND COALESCE(p.parameter11categorycode,0) = COALESCE(@v_parameter11categorycode,0)
       AND COALESCE(p.parameter11code,0) = COALESCE(@v_parameter11code,0)
       AND COALESCE(p.parameter12categorycode,0) = COALESCE(@v_parameter12categorycode,0)
       AND COALESCE(p.parameter12code,0) = COALESCE(@v_parameter12code,0)
       AND COALESCE(p.parameter13categorycode,0) = COALESCE(@v_parameter13categorycode,0)
       AND COALESCE(p.parameter13code,0) = COALESCE(@v_parameter13code,0)
       AND COALESCE(p.parameter14categorycode,0) = COALESCE(@v_parameter14categorycode,0)
       AND COALESCE(p.parameter14code,0) = COALESCE(@v_parameter14code,0)
       AND COALESCE(p.parameter15categorycode,0) = COALESCE(@v_parameter15categorycode,0)
       AND COALESCE(p.parameter15code,0) = COALESCE(@v_parameter15code,0)
       AND COALESCE(p.parameter16categorycode,0) = COALESCE(@v_parameter16categorycode,0)
       AND COALESCE(p.parameter16code,0) = COALESCE(@v_parameter16code,0)
       AND COALESCE(p.parameter17categorycode,0) = COALESCE(@v_parameter17categorycode,0)
       AND COALESCE(p.parameter17code,0) = COALESCE(@v_parameter17code,0)
       AND COALESCE(p.parameter18categorycode,0) = COALESCE(@v_parameter18categorycode,0)
       AND COALESCE(p.parameter18code,0) = COALESCE(@v_parameter18code,0)
       AND COALESCE(p.parameter19categorycode,0) = COALESCE(@v_parameter19categorycode,0)
       AND COALESCE(p.parameter19code,0) = COALESCE(@v_parameter19code,0)
       AND COALESCE(p.parameter20categorycode,0) = COALESCE(@v_parameter20categorycode,0)
       AND COALESCE(p.parameter20code,0) = COALESCE(@v_parameter20code,0)
       
    IF @v_count = 1 BEGIN
      -- found 1 scale with parameters in the correct order
      SET @o_scaleprojectkey = @v_scaleprojectkey
      RETURN
    END
    ELSE BEGIN
      -- parameters are in a different order on corescaleparameters
      SET @v_message = 'Order of parameter codes does not match to corescaleparameters for' 
      goto finish_error                 
    END
  END
   
  finish_error:
      
  IF @v_message is not null BEGIN
    SET @v_message = @v_message + ' scale type: ' + COALESCE(@v_scaleprojecttypedesc,' ') + ' / vendor: ' + COALESCE(@v_vendorname,' ') + 
                     ' / org: ' + COALESCE(@v_orgentrydesc,' ') + ' / parameters:' 
    IF @v_num_parameters > 0 AND @v_parameter1desc is not null BEGIN
      SET @v_message = @v_message + ' ' + @v_parameter1desc + ':' + COALESCE(dbo.qscale_find_specification_desc(@i_taqversionformatyearkey,@v_parameter1categorycode,@v_parameter1code),' ')     
    END
    IF @v_num_parameters > 1 BEGIN
      SET @v_message = @v_message + ' ' + @v_parameter2desc + ':' + COALESCE(dbo.qscale_find_specification_desc(@i_taqversionformatyearkey,@v_parameter2categorycode,@v_parameter2code),' ')      
    END
    IF @v_num_parameters > 2 BEGIN
      SET @v_message = @v_message + ' ' + @v_parameter3desc + ':' + COALESCE(dbo.qscale_find_specification_desc(@i_taqversionformatyearkey,@v_parameter3categorycode,@v_parameter3code),' ')      
    END
    IF @v_num_parameters > 3 BEGIN
      SET @v_message = @v_message + ' ' + @v_parameter4desc + ':' + COALESCE(dbo.qscale_find_specification_desc(@i_taqversionformatyearkey,@v_parameter4categorycode,@v_parameter4code),' ')     
    END
    IF @v_num_parameters > 4 BEGIN
      SET @v_message = @v_message + ' ' + @v_parameter5desc + ':' + COALESCE(dbo.qscale_find_specification_desc(@i_taqversionformatyearkey,@v_parameter5categorycode,@v_parameter5code),' ')      
    END
    IF @v_num_parameters > 5 BEGIN
      SET @v_message = @v_message + ' ' + @v_parameter6desc + ':' + COALESCE(dbo.qscale_find_specification_desc(@i_taqversionformatyearkey,@v_parameter6categorycode,@v_parameter6code),' ')     
    END
    IF @v_num_parameters > 6 BEGIN
      SET @v_message = @v_message + ' ' + @v_parameter7desc + ':' + COALESCE(dbo.qscale_find_specification_desc(@i_taqversionformatyearkey,@v_parameter7categorycode,@v_parameter7code),' ')      
    END
    IF @v_num_parameters > 7 BEGIN
      SET @v_message = @v_message + ' ' + @v_parameter8desc + ':' + COALESCE(dbo.qscale_find_specification_desc(@i_taqversionformatyearkey,@v_parameter8categorycode,@v_parameter8code),' ')      
    END
    IF @v_num_parameters > 8 BEGIN
      SET @v_message = @v_message + ' ' + @v_parameter9desc + ':' + COALESCE(dbo.qscale_find_specification_desc(@i_taqversionformatyearkey,@v_parameter9categorycode,@v_parameter9code),' ')      
    END
    IF @v_num_parameters > 9 BEGIN
      SET @v_message = @v_message + ' ' + @v_parameter10desc + ':' + COALESCE(dbo.qscale_find_specification_desc(@i_taqversionformatyearkey,@v_parameter10categorycode,@v_parameter10code),' ')     
    END
    IF @v_num_parameters > 10 BEGIN
      SET @v_message = @v_message + ' ' + @v_parameter11desc + ':' + COALESCE(dbo.qscale_find_specification_desc(@i_taqversionformatyearkey,@v_parameter11categorycode,@v_parameter11code),' ')      
    END
    IF @v_num_parameters > 11 BEGIN
      SET @v_message = @v_message + ' ' + @v_parameter12desc + ':' + COALESCE(dbo.qscale_find_specification_desc(@i_taqversionformatyearkey,@v_parameter12categorycode,@v_parameter12code),' ')      
    END
    IF @v_num_parameters > 12 BEGIN
      SET @v_message = @v_message + ' ' + @v_parameter13desc + ':' + COALESCE(dbo.qscale_find_specification_desc(@i_taqversionformatyearkey,@v_parameter13categorycode,@v_parameter13code),' ')      
    END
    IF @v_num_parameters > 13 BEGIN
      SET @v_message = @v_message + ' ' + @v_parameter14desc + ':' + COALESCE(dbo.qscale_find_specification_desc(@i_taqversionformatyearkey,@v_parameter14categorycode,@v_parameter14code),' ')      
    END
    IF @v_num_parameters > 14 BEGIN
      SET @v_message = @v_message + ' ' + @v_parameter15desc + ':' + COALESCE(dbo.qscale_find_specification_desc(@i_taqversionformatyearkey,@v_parameter15categorycode,@v_parameter15code),' ')      
    END
    IF @v_num_parameters > 15 BEGIN
      SET @v_message = @v_message + ' ' + @v_parameter16desc + ':' + COALESCE(dbo.qscale_find_specification_desc(@i_taqversionformatyearkey,@v_parameter16categorycode,@v_parameter16code),' ')      
    END
    IF @v_num_parameters > 16 BEGIN
      SET @v_message = @v_message + ' ' + @v_parameter17desc + ':' + COALESCE(dbo.qscale_find_specification_desc(@i_taqversionformatyearkey,@v_parameter17categorycode,@v_parameter17code),' ')      
    END
    IF @v_num_parameters > 17 BEGIN
      SET @v_message = @v_message + ' ' + @v_parameter18desc + ':' + COALESCE(dbo.qscale_find_specification_desc(@i_taqversionformatyearkey,@v_parameter18categorycode,@v_parameter18code),' ')      
    END
    IF @v_num_parameters > 18 BEGIN
      SET @v_message = @v_message + ' ' + @v_parameter19desc + ':' + COALESCE(dbo.qscale_find_specification_desc(@i_taqversionformatyearkey,@v_parameter19categorycode,@v_parameter19code),' ')     
    END
    IF @v_num_parameters > 19 BEGIN
      SET @v_message = @v_message + ' ' + @v_parameter20desc + ':' + COALESCE(dbo.qscale_find_specification_desc(@i_taqversionformatyearkey,@v_parameter20categorycode,@v_parameter20code),' ')    
    END

    INSERT INTO taqversioncostmessages 
      (taqversionformatyearkey, [message], messagetypecode, acctgcode, cost, lastmaintdate, lastmaintuser, processtype)
    VALUES
      (@i_taqversionformatyearkey, @v_message, @v_messagetype_error, NULL, NULL, getdate(), 'COSTGEN', @i_processtype)
  END    
END

GO
GRANT EXEC ON qscale_get_scale_for_speccategory TO PUBLIC
GO


