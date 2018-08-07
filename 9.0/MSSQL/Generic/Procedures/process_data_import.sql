if exists (select * from dbo.sysobjects where id = Object_id('dbo.process_data_import') and (type = 'P' or type = 'RF'))
begin
   drop proc dbo.process_data_import
end

GO

CREATE PROCEDURE  dbo.process_data_import
   @batchkey int, @importkey int, @startkey int, 
   @endkey int, @desttype int, @userid varchar(30)
AS

DECLARE @importstatus INT 

SELECT @importstatus = 99

IF @desttype = 1 BEGIN
   EXEC process_contact_import @batchkey, @importkey, @startkey, @endkey, @userid, @importstatus 
END


RETURN @importstatus


GO

GRANT EXECUTE ON dbo.process_data_import TO PUBLIC

GO