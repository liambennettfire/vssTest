/******************************************************************************************
**  Executes the qutl_insert_gentable_value  procedure
*******************************************************************************************/

BEGIN

  DECLARE
  @v_itemtype     INT,
  @v_usageclass   INT,
  @v_datacode INT,
  @v_datasubcode INT,
  @v_pubcampaignclass INT,
  @v_classcode INT,
  @v_error_code   INT ,
  @v_error_desc   VARCHAR(2000)

  exec qutl_insert_gentable_value 598,'CopyProjectDataGroups',26,'Relate/Create New Related Projects',NULL,0, @v_datacode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datadesc = ' + 'Relate/Create New Related Projects' +', error message =' + @v_error_desc	UPDATE gentables SET datadescshort = 'NULL', alternatedesc1 = '', alternatedesc2 = '' WHERE tableid = 598  and datacode = @v_datacode	SET @V_datasubcode = 0			SELECT @v_classcode = datasubcode , @v_itemtype = datacode from subgentables where tableid = 550 and qsicode = 54	IF @v_classcode<> 0  BEGIN exec qutl_insert_gentablesitemtype 598, @v_datacode,  @v_datasubcode, 0,@v_itemtype, @v_classcode,@v_error_code OUTPUT, @v_error_desc OUTPUT END	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc	IF @v_error_code = 0 BEGIN update gentablesitemtype set sortorder = 11 where tableid = 598 AND datacode = @v_datacode AND datasubcode = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_classcode END
  exec qutl_insert_gentable_value 598,'CopyProjectDataGroups',27,'New Related Projects use Update Wizard',NULL,0, @v_datacode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datadesc = ' + 'New Related Projects use Update Wizard' +', error message =' + @v_error_desc	UPDATE gentables SET datadescshort = 'Related Projects', alternatedesc1 = '', alternatedesc2 = '' WHERE tableid = 598  and datacode = @v_datacode	SET @V_datasubcode = 0			SELECT @v_classcode = datasubcode , @v_itemtype = datacode from subgentables where tableid = 550 and qsicode = 54	IF @v_classcode<> 0  BEGIN exec qutl_insert_gentablesitemtype 598, @v_datacode,  @v_datasubcode, 0,@v_itemtype, @v_classcode,@v_error_code OUTPUT, @v_error_desc OUTPUT END	IF @v_error_code <> 0  print 'datacode = ' + CAST(@v_datacode AS varchar)+ ', datasubcode = ' + CAST(@v_datasubcode AS varchar) +', error message =' + @v_error_desc	IF @v_error_code = 0 BEGIN update gentablesitemtype set sortorder = 11 where tableid = 598 AND datacode = @v_datacode AND datasubcode = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_classcode END

  set @v_pubcampaignclass = 0
  select @v_pubcampaignclass = ISNULL(datasubcode,0) from subgentables where tableid = 550 and datacode = 3 and qsicode = 54

  if @v_pubcampaignclass > 0
  begin
    update gentablesitemtype
    set text1 = 'For related Publicity Projects, create new projects and relate these; For all other related projects, copy the relationship'
    where tableid = 598 and datacode = 27 and itemtypecode = 3 and itemtypesubcode = @v_pubcampaignclass


    update gentablesitemtype
    set text1 = 'For related Publicity Projects, create new projects and relate these; For all other related projects, copy the relationship'
    where tableid = 598 and datacode = 26 and itemtypecode = 3 and itemtypesubcode = @v_pubcampaignclass

    -- Set flag that causes Publicity Projects to be created rather than related when related to a Publicity Campaign
    update gentablesitemtype
    set indicator1 = 1
    where tableid = 582 
      and datacode = 22 -- 'Publicity Project' relationship
      and itemtypecode = 3 and itemtypesubcode = @v_pubcampaignclass
  end
END
GO

