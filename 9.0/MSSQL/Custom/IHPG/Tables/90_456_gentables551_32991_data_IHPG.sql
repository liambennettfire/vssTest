DECLARE
  @v_clientoption_autogen TINYINT,
  @v_clientoption_allowdups TINYINT
  
BEGIN

  SELECT @v_clientoption_autogen = optionvalue
  FROM clientoptions
  WHERE optionid = 60	--Item # auto generation
  
  IF @v_clientoption_autogen IS NULL
    SET @v_clientoption_autogen = 0
  
  SELECT @v_clientoption_allowdups = optionvalue
  FROM clientoptions
  WHERE optionid = 116	--Allow duplicate Item #
  
  IF @v_clientoption_allowdups IS NULL
    SET @v_clientoption_allowdups = 0
    
    
  UPDATE gentables
  SET gen1ind = @v_clientoption_autogen, gen2ind = @v_clientoption_allowdups, alternatedesc2 = 'EXEC qean_generate_itemnumber @orgentrykey, @result OUTPUT, @errorcode OUTPUT, @errordesc OUTPUT'
  WHERE tableid = 551 AND qsicode = 6
    
END
go 