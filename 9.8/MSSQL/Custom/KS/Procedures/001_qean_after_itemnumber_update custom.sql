/****** Object:  StoredProcedure [dbo].[qean_after_itemnumber_update]    Script Date: 03/25/2009 18:00:45 ******/਍ഀ
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qean_after_itemnumber_update]') AND type in (N'P', N'PC'))਍ഀ
DROP PROCEDURE [dbo].[qean_after_itemnumber_update]਍ഀ
਍ഀ
SET ANSI_NULLS ON਍ഀ
GO਍ഀ
SET QUOTED_IDENTIFIER ON਍ഀ
GO਍ഀ
਍ഀ
CREATE PROCEDURE [dbo].[qean_after_itemnumber_update]਍ഀ
  @i_itemnumber   VARCHAR(20),਍ഀ
  @o_error_code   INT OUTPUT,਍ഀ
  @o_error_desc   VARCHAR(2000) OUTPUT਍ഀ
AS਍ഀ
਍ഀ
/*********************************************************************************************਍ഀ
**  Name: qean_after_itemnumber_update਍ഀ
**  Desc: Updates itemnumber sequence on defaults table after the passed itemnumber ਍ഀ
**        has been assigned to a title/project.਍ഀ
**਍ഀ
**  Auth: Kate J. Wiewiora਍ഀ
**  Date: 15 January 2007਍ഀ
**  Auth: Jennifer Hurd਍ഀ
**  Date: 25 March 2009਍ഀ
**  Customized for Kamehameha Publishing਍ഀ
******************************************************************************************/਍ഀ
਍ഀ
DECLARE਍ഀ
  @v_itemnumber_sequence  INT,਍ഀ
  @v_error  INT਍ഀ
  ਍ഀ
BEGIN਍ഀ
 ਍ഀ
  SET @v_itemnumber_sequence = CONVERT(INT, substring(@i_itemnumber,3,5))਍ഀ
       ਍ഀ
  UPDATE defaults਍ഀ
  SET itemnumberseq = @v_itemnumber_sequence਍ഀ
    ਍ഀ
  SELECT @v_error = @@ERROR਍ഀ
  IF @v_error <> 0਍ഀ
  BEGIN਍ഀ
    SET @o_error_code = -1 ਍ഀ
    SET @o_error_desc = 'Could not update itemnumber sequence on defaults table.'਍ഀ
    RETURN਍ഀ
  END਍ഀ
  ਍ഀ
END਍ഀ
