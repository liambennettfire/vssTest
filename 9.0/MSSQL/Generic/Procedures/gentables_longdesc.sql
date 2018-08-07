PRINT 'STORED PROCEDURE : dbo.gentables_longdesc'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.gentables_longdesc') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.gentables_longdesc
end

GO

CREATE PROCEDURE  gentables_longdesc
@ware_tableid int, @ware_datacode int, @ware_datadesc varchar(40) OUTPUT

AS

DECLARE @ware_count int

	select @ware_count = count(*)
		from gentables
		where tableid = @ware_tableid
			and datacode = @ware_datacode

	if @ware_count > 0 
	  begin
		select @ware_datadesc = datadesc
			from gentables
			  where tableid = @ware_tableid
				and datacode = @ware_datacode

		if @ware_datadesc is null
		  begin
			select @ware_datadesc = ''
			RETURN
 		  end
	  end
	else
	  begin
		select @ware_datadesc = ''
		RETURN
	 end

GO