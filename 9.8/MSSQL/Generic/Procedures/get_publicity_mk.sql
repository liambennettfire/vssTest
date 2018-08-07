if exists (select * from dbo.sysobjects where id = Object_id('dbo.get_publicity_mk') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.get_publicity_mk
end

GO

CREATE PROCEDURE dbo.get_publicity_mk 
  (@marketdesc VARCHAR(50), @bucode INT, @importsrckey INT, @categorycode INT OUTPUT) 
AS

BEGIN

   SELECT @categorycode = NULL

   IF (@marketdesc IS NULL) OR (@marketdesc = '')
      BEGIN
         SELECT @categorycode = datacode
           FROM importgentablemap
          WHERE importsrckey = @importsrckey AND
                tableid = 257 AND
                (importsrcvalue IS NULL OR
                importsrcvalue = '')
      END
   ELSE
      BEGIN
         SELECT @categorycode = datacode
           FROM importgentablemap
          WHERE importsrckey = @importsrckey AND
                tableid = 257 AND
                UPPER(importsrcvalue) = UPPER(@marketdesc)
      END

   IF @categorycode IS NULL
      BEGIN
         SELECT @categorycode = datacode
           FROM sectiontables, gentables  
          WHERE (sectiontables.sectioncode = 4) AND
                (sectiontables.categorycode = gentables.datacode) AND
                (gentables.tableid = 257) AND
                (UPPER(gentables.datadesc) = @marketdesc) AND
                (sectiontables.bucode = @bucode)
      END
END
    
GO

GRANT EXECUTE ON dbo.get_publicity_mk TO PUBLIC

GO