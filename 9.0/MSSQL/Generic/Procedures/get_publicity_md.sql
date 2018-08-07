
if exists (select * from dbo.sysobjects where id = Object_id('dbo.get_publicity_md') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.get_publicity_md
end

GO

CREATE PROCEDURE dbo.get_publicity_md 
  (@mediadesc VARCHAR(50), @bucode INT , @importsrckey INT, @categorycode INT OUTPUT) 
AS

BEGIN
   SELECT @categorycode = NULL

   IF (@mediadesc IS NULL) OR (@mediadesc = '')
      BEGIN
         SELECT @categorycode = datacode
           FROM importgentablemap
          WHERE importsrckey = @importsrckey AND
                tableid = 258 AND
                (importsrcvalue IS NULL OR
                importsrcvalue = '')
      END
   ELSE
      BEGIN
         SELECT @categorycode = datacode
           FROM importgentablemap
          WHERE importsrckey = @importsrckey AND
                tableid = 258 AND
                UPPER(importsrcvalue) = UPPER(@mediadesc)
      END

   IF @categorycode IS NULL
      BEGIN
         SELECT @categorycode = datacode
           FROM sectiontables, gentables  
          WHERE (sectiontables.sectioncode = 2) AND
                (sectiontables.categorycode = gentables.datacode) AND
                (gentables.tableid = 258) AND
                (UPPER(gentables.datadesc) = @mediadesc) AND
                (sectiontables.bucode = @bucode)
      END
END
    
GO

GRANT EXECUTE ON dbo.get_publicity_md TO PUBLIC

GO





