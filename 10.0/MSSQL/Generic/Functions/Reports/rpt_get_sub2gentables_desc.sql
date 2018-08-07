
/****** Object:  UserDefinedFunction [dbo].[rpt_get_sub2gentables_desc]    Script Date: 03/24/2009 13:17:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_sub2gentables_desc') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_sub2gentables_desc
GO
CREATE FUNCTION [dbo].[rpt_get_sub2gentables_desc]
    (@i_tableid as integer,@i_datacode as integer,@i_datasubcode as integer,@i_datasub2code as integer, @i_desctype as varchar) 

RETURNS varchar(255)

/******************************************************************************
**  File: 
**  Name: rpt_get_sub2gentables_desc
**  Desc: This function returns the datadesc or datadescshort depending on
**        i_desctypec for the tabled and datacodes passed. 
**
**        i_desctype = 'long' or empty --> return datadesc
**        i_desctype = 'short' --> return datadescshort
**
**    Auth: Paul Milana
**    Date: 8 September 2006
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
     @i_datasubcode is null OR @i_datasubcode <= 0 OR
     @i_datasubcode is null OR @i_datasub2code <= 0 BEGIN
     RETURN ''
  END

  IF lower(rtrim(ltrim(@i_desctype))) = 'short' BEGIN
    -- get datadescshort
    SELECT @i_desc = datadescshort
      FROM sub2gentables
     WHERE tableid = @i_tableid and
           datacode = @i_datacode and
           datasubcode = @i_datasubcode and
 	   datasub2code = @i_datasub2code
  END
  ELSE BEGIN
    -- get datadesc
    SELECT @i_desc = datadesc
      FROM sub2gentables
     WHERE tableid = @i_tableid and
           datacode = @i_datacode and
           datasubcode = @i_datasubcode and
 	   datasub2code = @i_datasub2code
  END

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @i_desc = 'error'
    --SET @o_error_desc = 'no data found: datadesc on subgentables.'   
  END 

  RETURN @i_desc
END

go
Grant All on dbo.rpt_get_sub2gentables_desc to Public
go