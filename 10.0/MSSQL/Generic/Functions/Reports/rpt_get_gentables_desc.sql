IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_gentables_desc') )
DROP FUNCTION dbo.rpt_get_gentables_desc
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_gentables_desc]    Script Date: 04/27/2009 14:19:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[rpt_get_gentables_desc]
    ( @i_tableid as integer,@i_datacode as integer,@i_desctype as varchar) 

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

  SET @i_desc = ''

  IF @i_tableid is null OR @i_tableid <= 0 OR
     @i_datacode is null OR @i_datacode <= 0 BEGIN
     RETURN ''
  END

  IF lower(rtrim(ltrim(@i_desctype))) = 'short' BEGIN
    -- get datadescshort
    SELECT @i_desc = datadescshort
      FROM gentables
     WHERE tableid = @i_tableid and
           datacode = @i_datacode
  END
  ELSE BEGIN
    -- get datadesc
    SELECT @i_desc = datadesc
      FROM gentables
     WHERE tableid = @i_tableid and
           datacode = @i_datacode
  END

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @i_desc = 'error'
    --SET @o_error_desc = 'no data found: subjectcategories on gentablesdesc.'   
  END 

  RETURN @i_desc
END
go
grant execute on rpt_get_gentables_desc to public
go