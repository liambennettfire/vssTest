if exists (select * from dbo.sysobjects where id = object_id(N'dbo.parse_string_xml') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.parse_string_xml
GO

CREATE FUNCTION dbo.parse_string_xml (@StringList NVARCHAR(MAX),@Delimiter CHAR(1))
RETURNS @TableList TABLE(ID int identity(1,1) PRIMARY KEY,eloquencefieldtag VARCHAR(2))
BEGIN
      IF @StringList = '' RETURN
      DECLARE @XML xml
      SET @XML = '<root><csv>'+replace(@StringList,@Delimiter,'</csv><csv>')+
                 '</csv></root>'
      INSERT @TableList
      SELECT rtrim(ltrim(replace(Word.value('.','nvarchar(max)'),char(10),'')))
             AS ListMember
      FROM @XML.nodes('/root/csv') AS WordList(Word)
RETURN
END 
GO

