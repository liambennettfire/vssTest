/****** Object:  StoredProcedure [dbo].[generate_volumetitle]    Script Date: 03/23/2009 11:11:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[generate_volumetitle]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[generate_volumetitle]

/****** Object:  StoredProcedure [dbo].[generate_volumetitle]    Script Date: 03/23/2009 11:09:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[generate_volumetitle]
	@i_related_journalkey	INT,
	@o_volume_number      INT OUTPUT,
	@o_result             VARCHAR(50) OUTPUT,
	@o_error_code         INT OUTPUT,
	@o_error_desc         VARCHAR(2000) OUTPUT
AS

BEGIN
  
  SET @o_error_code = 0
  SET @o_error_desc = ''  
  SET @o_result = ''

  -- Get Journal's Acronym
  select @o_result = isnull(orgentrydesc,'')
  from taqprojectorgentry tpo
  join orgentry o on tpo.orgentrykey = o.orgentrykey
  where tpo.orglevelkey = 3
  and tpo.taqprojectkey = @i_related_journalkey

  if @o_result = ''
  BEGIN
    SET @o_error_code = -2 --warning 
    SET @o_error_desc = 'Could not generate Volume title - Acronym not found on the related Journal''s third level organization.'
    RETURN
  END

  -- Get the max Volume Number
  select @o_volume_number = max(convert(int, isnull(tpn.productnumber,0)))
  from taqprojectrelationship r
    join taqproject t1 on r.taqprojectkey1 = t1.taqprojectkey
    join taqproject t2 on r.taqprojectkey2 = t2.taqprojectkey
    left outer join taqproductnumbers tpn	on t2.taqprojectkey = tpn.taqprojectkey	and tpn.productidcode = 16
  where t1.taqprojectkey = @i_related_journalkey
    and relationshipcode1 = 7
    and relationshipcode2 = 6
    and isnumeric(tpn.productnumber) = 1
  group by t1.taqprojectkey

  IF @o_volume_number IS NULL
    SET @o_volume_number = 1
  ELSE
    SET @o_volume_number = @o_volume_number + 1

  SET @o_result = @o_result + ' ' + convert(varchar, @o_volume_number)
	
END
