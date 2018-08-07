PRINT 'STORED PROCEDURE : dbo.subgent_bisac'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.subgent_bisac') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.subgent_bisac
end

GO

CREATE PROCEDURE  subgent_bisac
@ware_tableid int, @ware_datacode int, @ware_datasubcode int,
@ware_bisacdatacode  varchar(20) OUTPUT

AS

DECLARE @ware_count int

	select @ware_count = count(*)
		from subgentables
		where tableid = @ware_tableid
			and datacode = @ware_datacode
			and datasubcode = @ware_datasubcode

	if @ware_count > 0 
	  begin
		select @ware_bisacdatacode = bisacdatacode
			from subgentables
			  where tableid = @ware_tableid
				and datacode = @ware_datacode
				and datasubcode = @ware_datasubcode

		if @ware_bisacdatacode is null
		  begin
			select @ware_bisacdatacode  = ''
			RETURN
 		  end
	  end
	else
	  begin
		select @ware_bisacdatacode = ''
		RETURN
	 end

GO