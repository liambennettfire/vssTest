IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_project_publication_season') )
DROP FUNCTION dbo.rpt_get_project_publication_season
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[rpt_get_project_publication_season]
    ( @i_taqprojectkey	INT ,@i_desctype as varchar) 

RETURNS varchar(255)

/******************************************************************************
**  File: 
**  Name: rpt_get_gentables_desc
**  Desc: This function returns the datadesc or datadescshort depending on
**        i_desctype. 
**
**        i_desctype = 'long' or empty --> return datadesc
**        i_desctype = 'short' --> return datadescshort
**
**    Auth: Alan Katzen
**    Date: 25 August 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @i_desc       VARCHAR(255)
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @v_seasoncode INT
  DECLARE @v_count      INT

  SET @i_desc = ''

  IF @i_taqprojectkey is null OR @i_taqprojectkey <= 0 BEGIN
     RETURN ''
  END

  SELECT @v_count = COUNT(*)
    FROM taqprojecttitle
   WHERE taqprojectkey =  @i_taqprojectkey
     AND primaryformatind = 1 

  IF @v_count = 0 BEGIN
    RETURN ''
  END

  SELECT @v_seasoncode = seasoncode
    FROM taqprojecttitle
   WHERE taqprojectkey =  @i_taqprojectkey
     AND primaryformatind = 1 

  IF lower(rtrim(ltrim(@i_desctype))) = 'short' BEGIN
    -- get datadescshort
    SELECT @i_desc = seasonshortdesc
      FROM season
     WHERE seasonkey = @v_seasoncode 
  END
  ELSE BEGIN
    -- get datadesc
    SELECT @i_desc = seasondesc
      FROM season
     WHERE seasonkey = @v_seasoncode 
  END

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @i_desc = 'error'
  END 

  RETURN @i_desc
END
go
grant all on rpt_get_project_publication_season to public
go