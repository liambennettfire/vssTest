
if exists (select * from dbo.sysobjects where id = Object_id('dbo.gentable_by_desc_import') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.gentable_by_desc_import
end

GO

CREATE PROCEDURE dbo.gentable_by_desc_import (@importsrckey int, @Tableid int, @Datadesc varchar(80), @AddInd char(1), @datacode int output) AS
  declare @Desc_hit int,
          @tablemnemonic varchar(40)

--  checks importgentablemap for datacode based on description if not found then
--  checks Gentables by description and tableid and returns the datacose
--  if @AddInd = Y a row is inserted and the new datacode returned
--  if not found datacode is null to prevent data '0' from entering the system
--  note that blanks or nulls can be mapped to a gentable entry
--  @datadesc should be trimmed before call

BEGIN

  SELECT @datacode = NULL

  IF (@Datadesc IS NULL) OR (@Datadesc = '')
    BEGIN
      SELECT @datacode = datacode
        FROM importgentablemap
       WHERE importsrckey=@importsrckey AND
             tableid=@Tableid AND
             (importsrcvalue IS NULL OR
             importsrcvalue = '')
    END
  ELSE
    BEGIN
      SELECT @datacode = datacode
        FROM importgentablemap
       WHERE importsrckey=@importsrckey AND
             tableid=@Tableid AND
             upper(importsrcvalue)=upper(@Datadesc)
    END

  IF @datacode IS NULL 
    BEGIN
      EXEC gentable_by_desc @Tableid, @Datadesc, @AddInd, @datacode OUTPUT
    END
END
    
GO

GRANT EXECUTE ON dbo.gentable_by_desc_import TO PUBLIC

GO