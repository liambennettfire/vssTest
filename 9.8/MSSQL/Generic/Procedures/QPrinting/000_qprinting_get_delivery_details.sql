if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qprinting_get_delivery_details') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qprinting_get_delivery_details
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qprinting_get_delivery_details
 (@i_projectkey     integer,
  @o_error_code     integer       output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qprinting_get_delivery_details
**  Desc: This gets the delivery detail information needed for the Printing Summary
**
**    Auth: Uday A. Khisty
**    Date: 08 December 2016
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT deliverydetailskey, taqprojectkey, quantity, vesselname, etdport
  FROM taqprojectdeliverydetails
  WHERE taqprojectkey = @i_projectkey 
  ORDER BY etdport DESC, vesselname ASC

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: taqprojectkey = ' + cast(@i_projectkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qprinting_get_delivery_details TO PUBLIC
GO


