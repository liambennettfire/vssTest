PRINT 'STORED procedure: dbo.feed_insert_gentables'
GO


if exists (select * from dbo.sysobjects where id = Object_id('dbo.feed_insert_gentables') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.feed_insert_gentables
end

GO

CREATE  proc dbo.feed_insert_gentables 
@feedin_tableid int, 
@feedin_gent_insert varchar(100) ,
@lastuserid varchar(40),
@feedin_datacode INT OUTPUT

AS 

DECLARE @feedin_tablemon varchar(30)

	select @feedin_datacode = max(datacode)
			from gentables 
				where tableid= @feedin_tableid
		
	select @feedin_datacode = @feedin_datacode + 1
	
	select @feedin_tablemon  =  tablemnemonic
			from gentables 
				where tableid= @feedin_tableid
					group by tablemnemonic

	insert into gentables 
		(tableid,datacode,datadesc,deletestatus,sortorder,
		 tablemnemonic, externalcode,datadescshort,eloquencefieldtag,lastmaintdate,lastuserid)
	values (@feedin_tableid, @feedin_datacode,substring(@feedin_gent_insert,1,40), 'N',@feedin_datacode, @feedin_tablemon, 
		substring(@feedin_gent_insert,1,30), substring(@feedin_gent_insert,1,20),'N/A',getdate(),@lastuserid)

	insert into feederror 										
		(batchnumber,processdate,errordesc)
	values ('3',getdate(),('Gentable row inserted for tableid ' + convert(varchar(10), @feedin_tableid ) +
	' and datacode ' +  convert(varchar (10),@feedin_datacode)  + ' and description ' +  substring(@feedin_gent_insert,1,40) ))


return @feedin_datacode

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO