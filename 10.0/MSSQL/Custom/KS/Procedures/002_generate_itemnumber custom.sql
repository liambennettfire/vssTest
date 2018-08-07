/****** Object:  StoredProcedure [dbo].[generate_itemnumber]    Script Date: 03/26/2009 09:31:48 ******/਍ഀ
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[generate_itemnumber]') AND type in (N'P', N'PC'))਍ഀ
DROP PROCEDURE [dbo].[generate_itemnumber]਍ഀ
਍ഀ
਍ഀ
/****** Object:  StoredProcedure [dbo].[generate_itemnumber]    Script Date: 03/26/2009 09:31:40 ******/਍ഀ
SET ANSI_NULLS ON਍ഀ
GO਍ഀ
SET QUOTED_IDENTIFIER ON਍ഀ
GO਍ഀ
਍ഀ
CREATE PROCEDURE [dbo].[generate_itemnumber]਍ഀ
	@i_projectkey			INT,਍ഀ
	@i_elementkey			INT,਍ഀ
	@i_related_journalkey	INT,਍ഀ
	@i_productidcode		int output,਍ഀ
	@o_result             VARCHAR(50) OUTPUT,਍ഀ
	@o_error_code         INT OUTPUT,਍ഀ
	@o_error_desc         VARCHAR(2000) OUTPUT਍ഀ
AS਍ഀ
਍ഀ
/*********************************************************************************************਍ഀ
******************************************************************************************/਍ഀ
਍ഀ
-- DOIT_AGAIN Label:਍ഀ
-- When the generated itemnumber already exists (was entered manually elsewhere), ਍ഀ
-- this procedure will get executed again to try to generate new itemnumber.਍ഀ
਍ഀ
IF @i_projectkey = 0਍ഀ
	RETURN਍ഀ
਍ഀ
DOIT_AGAIN:਍ഀ
਍ഀ
DECLARE਍ഀ
	@v_count  INT,਍ഀ
	@v_error  INT,਍ഀ
	@v_itemnumber_sequence INT,਍ഀ
	@v_generate_new INT,  ਍ഀ
	@v_new_itemnumber VARCHAR(20),਍ഀ
	@v_rowcount INT,਍ഀ
	@char5	char(10),਍ഀ
	@prefix	char(2)਍ഀ
਍ഀ
BEGIN਍ഀ
 ਍ഀ
  SET @o_result = NULL਍ഀ
  SET @o_error_code = 0਍ഀ
  SET @o_error_desc = ''਍ഀ
 ਍ഀ
  ਍ഀ
    /* Get the last itemnumber sequence used */਍ഀ
    SELECT @v_itemnumber_sequence = itemnumberseq ਍ഀ
    FROM defaults;਍ഀ
਍ഀ
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT਍ഀ
    IF @v_error <> 0਍ഀ
    BEGIN਍ഀ
      SET @o_error_code = -1 ਍ഀ
      SET @o_error_desc = 'Could not access defaults table to get last itemnumber sequence.'਍ഀ
      RETURN਍ഀ
    END਍ഀ
    ਍ഀ
    IF @v_rowcount = 0਍ഀ
    BEGIN਍ഀ
      SET @o_error_code = -1 ਍ഀ
      SET @o_error_desc = 'Record missing on defaults table.' ਍ഀ
      RETURN਍ഀ
    END਍ഀ
    ਍ഀ
    IF @v_itemnumber_sequence IS NULL਍ഀ
      SET @v_itemnumber_sequence = 0਍ഀ
      ਍ഀ
    /* Generate new itemnumber */਍ഀ
    SET @v_itemnumber_sequence = @v_itemnumber_sequence + 1਍ഀ
    SET @v_new_itemnumber = CONVERT(VARCHAR, @v_itemnumber_sequence)਍ഀ
        ਍ഀ
	set @char5 = substring(@v_new_itemnumber,len(@v_new_itemnumber)-4,5)਍ഀ
਍ഀ
	set @char5 = case when len(@char5) = 4 then '0' + @char5਍ഀ
		when len(@char5) = 3 then '00' + @char5਍ഀ
		when len(@char5) = 2 then '000' + @char5਍ഀ
		when len(@char5) = 1 then '0000' + @char5਍ഀ
		else @char5਍ഀ
	end਍ഀ
਍ഀ
	select @prefix = isnull(substring(alternatedesc1,1,2),'')਍ഀ
	from taqproject t਍ഀ
	join gentables g਍ഀ
	on t.taqprojecttype = g.datacode਍ഀ
	and g.tableid = 521	਍ഀ
	where taqprojectkey = @i_projectkey਍ഀ
਍ഀ
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT਍ഀ
਍ഀ
    IF @v_rowcount = 0 or @prefix = ''਍ഀ
    BEGIN਍ഀ
		SET @o_result = null    ਍ഀ
--      SET @o_error_code = -1 ਍ഀ
--      SET @o_error_desc = 'Project type prefix (altdesc1) not defined in user tables.' ਍ഀ
		RETURN਍ഀ
    END਍ഀ
਍ഀ
	set @v_new_itemnumber = @prefix+@char5਍ഀ
਍ഀ
    /* Check if this itemnumber already exists */਍ഀ
    SELECT @v_count = COUNT(*)਍ഀ
    FROM taqproductnumbers਍ഀ
    WHERE productidcode = 14਍ഀ
	and UPPER(LTRIM(RTRIM(productnumber))) = UPPER(LTRIM(RTRIM(@v_new_itemnumber)))਍ഀ
    ਍ഀ
    SELECT @v_error = @@ERROR਍ഀ
    IF @v_error <> 0਍ഀ
    BEGIN਍ഀ
      SET @o_error_code = -1 ਍ഀ
      SET @o_error_desc = 'Could not access isbn table to verify uniqueness of itemnumber.'਍ഀ
      RETURN਍ഀ
    END਍ഀ
    ਍ഀ
  -- Update this sequence number on defaults table - before DOIT_AGAIN next select਍ഀ
  EXEC qean_after_itemnumber_update @v_new_itemnumber, ਍ഀ
    @o_error_code OUTPUT, @o_error_desc OUTPUT਍ഀ
਍ഀ
    IF @v_count > 0  --this itemnumber already exists਍ഀ
    BEGIN਍ഀ
      ਍ഀ
      -- Call itself again to generate another itemnumber਍ഀ
      GOTO DOIT_AGAIN਍ഀ
    END਍ഀ
          ਍ഀ
    SET @o_result = @v_new_itemnumber    ਍ഀ
    ਍ഀ
  ਍ഀ
END਍ഀ
