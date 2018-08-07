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
		 tablemnemonic, externalcode,datadescshort,eloquencefieldtag)
	values (@feedin_tableid, @feedin_datacode, ('Undefined for ' + 
		@feedin_gent_insert), 'N',@feedin_datacode, @feedin_tablemon, 
		@feedin_gent_insert,@feedin_gent_insert,'N/A')

	insert into feederror 										
		(batchnumber,processdate,errordesc)
	values ('3',getdate(),('Gentable row inserted for tableid ' + convert(char,10, @feedin_tableid ) +
	' and datacode ' +  convert(char,@feedin_datacode)  + ' and description ' +  @feedin_gent_insert ))

GO