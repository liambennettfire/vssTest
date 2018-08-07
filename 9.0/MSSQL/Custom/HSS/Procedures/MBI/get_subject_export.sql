SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_subject_export]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[get_subject_export]
GO


CREATE PROCEDURE get_subject_export(@bookkey	INT,
				@o_errorcode	INT OUT,
				@o_errormsg	VARCHAR(1000) OUT)
AS

DECLARE @isbn10				VARCHAR(20)
DECLARE @cstatus			INT
DECLARE @sortorder			INT
DECLARE @bisacsubject			VARCHAR(25)
DECLARE	@bisaccategorycode		INT
DECLARE @bisaccategorysubcode		INT
DECLARE @subjectcode			VARCHAR(40)
DECLARE @subjectdesc			VARCHAR(520)
DECLARE @categorytableid		INT
DECLARE @categorycode			INT
DECLARE @categorydesc			VARCHAR(40)
DECLARE @categorydescshort		VARCHAR(40)
DECLARE @categorysubcode		INT
DECLARE @categorysubdesc		VARCHAR(40)
DECLARE @categorysubdescshort		VARCHAR(40)
DECLARE @categorysub2code		INT
DECLARE @categorysub2desc		VARCHAR(40)
DECLARE @categorysub2descshort		VARCHAR(40)
DECLARE @tabledesc			VARCHAR(40)


SET @bisaccategorycode = 0
SET @bisaccategorysubcode =0
SET @subjectcode =''
SET @subjectdesc =''
SET @sortorder = 0

SELECT @isbn10 = isbn10
FROM isbn
WHERE bookkey = @bookkey

DECLARE c_bisac INSENSITIVE CURSOR FOR
	SELECT	bisaccategorycode,bisaccategorysubcode,sortorder
	FROM 	bookbisaccategory 
	WHERE 	bookkey = @bookkey 
	ORDER BY sortorder
FOR READ ONLY

OPEN c_bisac

FETCH NEXT FROM c_bisac
INTO @bisaccategorycode,@bisaccategorysubcode,@sortorder

SELECT @cstatus = @@FETCH_STATUS

WHILE @cstatus <>-1
	BEGIN
		IF @cstatus <>-2
			BEGIN
				SET @subjectdesc = ''
				SET @subjectcode = ''

				SELECT @subjectdesc = dbo.proper_case(LTRIM(RTRIM(datadesc)))
				FROM gentables
				WHERE tableid = 339
						AND datacode = @bisaccategorycode

				SELECT @subjectcode = bisacdatacode,
					@subjectdesc = @subjectdesc+'/'+LTRIM(RTRIM(datadesc))
				FROM subgentables
				WHERE tableid = 339
						AND datacode = @bisaccategorycode
						AND datasubcode = @bisaccategorysubcode

/* INSERT BISAC Subject Codes	*/
				INSERT INTO export_subject(bookkey,isbn10,subjecttype,subjectcode,subjectdesc,sortorder)
				VALUES (@bookkey,@isbn10,'BISAC Subject',@subjectcode,@subjectdesc,@sortorder)

				SET @subjectcode =''
				SET @subjectdesc =''
				SET @sortorder = 0

			END

		FETCH NEXT FROM c_bisac
		INTO @bisaccategorycode,@bisaccategorysubcode,@sortorder

		SELECT @cstatus = @@FETCH_STATUS

	END

CLOSE c_bisac
DEALLOCATE c_bisac


/*  GET SUBJECT CATEGORIES			*/
DECLARE c_subject INSENSITIVE CURSOR FOR
	SELECT	categorytableid,categorycode,categorysubcode,categorysub2code,sortorder
	FROM 	booksubjectcategory 
	WHERE 	bookkey = @bookkey AND categorytableid in (412,413,414,431)
	ORDER BY sortorder
FOR READ ONLY

OPEN c_subject

FETCH NEXT FROM c_subject
INTO @categorytableid,@categorycode,@categorysubcode,@categorysub2code,@sortorder

SELECT @cstatus = @@FETCH_STATUS

WHILE @cstatus <>-1
	BEGIN
		IF @cstatus <>-2
			BEGIN
				SET @tabledesc = ''
				SET @subjectdesc = ''
				SET @subjectcode = ''
				SET @categorydesc = ''
				SET @categorydescshort = ''
				SET @categorysubdesc = ''
				SET @categorysubdescshort = ''
				SET @categorysub2desc = ''
				SET @categorysub2descshort = ''				

				SELECT @tabledesc = dbo.proper_case(LTRIM(RTRIM(tabledesclong)))
				FROM gentablesdesc
				WHERE tableid = @categorytableid


				SELECT @categorydesc = datadesc,
					@categorydescshort = datadescshort
				FROM gentables
				WHERE tableid = @categorytableid
						AND datacode = @categorycode


				SELECT @categorysubdesc = datadesc,
					@categorysubdescshort = datadescshort
				FROM subgentables
				WHERE tableid = @categorytableid
						AND datacode = @categorycode
						AND datasubcode = @categorysubcode

				SELECT @categorysub2desc = datadesc,
					@categorysub2descshort = datadescshort
				FROM sub2gentables
				WHERE tableid = @categorytableid
						AND datacode = @categorycode
						AND datasubcode = @categorysubcode
						AND datasub2code = @categorysub2code

				SELECT @subjectcode = COALESCE(@categorydescshort,'')+COALESCE(@categorysubdescshort,'')+COALESCE(@categorysub2descshort,'')

				SELECT @subjectdesc = CASE
								WHEN COALESCE(@categorysub2desc,'')<>''	THEN @categorydesc+' / '+@categorysubdesc+' / '+@categorysub2desc
								WHEN COALESCE(@categorysubdesc,'')<>''	THEN @categorydesc+' / '+@categorysubdesc
								WHEN COALESCE(@categorydesc,'')<>''	THEN @categorydesc
							ELSE
								''
							END





/* INSERT Subject Category Codes	*/
				INSERT INTO export_subject(bookkey,isbn10,subjecttype,subjectcode,subjectdesc,sortorder)
				VALUES (@bookkey,@isbn10,@tabledesc,@subjectcode,@subjectdesc,@sortorder)

				SET @sortorder = 0
				

			END

		FETCH NEXT FROM c_subject
		INTO @categorytableid,@categorycode,@categorysubcode,@categorysub2code,@sortorder

		SELECT @cstatus = @@FETCH_STATUS

	END

CLOSE c_subject
DEALLOCATE c_subject

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

