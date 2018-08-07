SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[feed_out_primac_cost]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[feed_out_primac_cost]
GO


create proc dbo.feed_out_primac_cost
 @feed_estkey int,
 @feed_versionkey int,
 @feed_chargecode int,
 @feed_dollar float OUTPUT 
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/


select  @feed_dollar = unitcost 
	from estcost e
		where estkey = @feed_estkey
		  and versionkey = @feed_versionkey
		and chgcodecode = @feed_chargecode

if @feed_dollar is null 
  begin
	select @feed_dollar = 0
  end

return 


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[feed_out_primac_cost]  TO [public]
GO

