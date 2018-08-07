SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_subgentables_desc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_subgentables_desc]
GO


CREATE FUNCTION qweb_get_subgentables_desc
    (@i_tableid as integer,@i_datacode as integer,@i_datasubcode as integer,@i_desctype as varchar) 

RETURNS varchar(255)

/******************************************************************************
**  File: 
**  Name: qweb_get_subgentables_desc
**  Desc: This function returns the datadesc or datadescshort depending on
**        i_desctype. 
**
**        i_desctype = 'long' or empty --> return datadesc
**        i_desctype = 'short' --> return datadescshort
**
**    Auth: Alan Katzen
**    Date: 1 March 2006
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @i_desc       VARCHAR(255)
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @i_desc = ''

  IF @i_tableid is null OR @i_tableid <= 0 OR
     @i_datacode is null OR @i_datacode <= 0  OR
     @i_datasubcode is null OR @i_datasubcode <= 0 BEGIN
     RETURN ''
  END

  IF lower(rtrim(ltrim(@i_desctype))) = 'short' BEGIN
    -- get datadescshort
    SELECT @i_desc = datadescshort
      FROM subgentables
     WHERE tableid = @i_tableid and
           datacode = @i_datacode and
           datasubcode = @i_datasubcode
  END
  ELSE BEGIN
    -- get datadesc
    SELECT @i_desc = datadesc
      FROM subgentables
     WHERE tableid = @i_tableid and
           datacode = @i_datacode and
           datasubcode = @i_datasubcode
  END

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @i_desc = 'error'
    --SET @o_error_desc = 'no data found: datadesc on subgentables.'   
  END 

  RETURN @i_desc
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

