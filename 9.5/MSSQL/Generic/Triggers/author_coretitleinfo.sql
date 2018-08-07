IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_author') AND type = 'TR')
	DROP TRIGGER dbo.core_author
GO

/******************************************************************************
**  Name: core_author
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  02/10/2016   UK		     Case 36206
*******************************************************************************/

CREATE TRIGGER core_author ON author
FOR INSERT, UPDATE AS
IF UPDATE (firstname) OR 
	UPDATE (lastname) OR 
	UPDATE (middlename) OR 
	UPDATE (authorsuffix) OR 
	UPDATE (authordegree) OR 
	UPDATE (corporatecontributorind)

BEGIN
	DECLARE @v_bookkey 			INT,
		@v_printingkey			INT,
		@v_authorkey 			INT, 
		@v_authorname			VARCHAR(150),
		@v_illustratorname		VARCHAR(150),
		@v_autodisplayind		TINYINT,
		@v_displayname			VARCHAR(150),
		@v_globalcontactkey		INT,
		@v_searchfield			VARCHAR(2000)
	
	SELECT @v_authorkey=i.authorkey
	FROM inserted i

	SELECT 	@v_globalcontactkey = masterkey FROM globalcontactauthor WHERE detailkey = @v_authorkey AND scopetag = 'contact'
	
	IF @v_globalcontactkey > 0 BEGIN
		SELECT @v_autodisplayind = COALESCE(autodisplayind, 0), @v_displayname = LEFT(displayname, 150) FROM globalcontact WHERE globalcontactkey = @v_globalcontactkey
	END
	
	/*** Must update author/illustrator info for ALL books that they are involved with ***/
	/*** Fill in AUTHOR NAME ***/
	DECLARE bookkey_cur CURSOR FOR
	SELECT ba.bookkey
	  FROM bookauthor ba
	 WHERE ba.authorkey = @v_authorkey 
	ORDER BY ba.sortorder 

	OPEN bookkey_cur

	FETCH NEXT FROM bookkey_cur 
	INTO @v_bookkey

	WHILE (@@FETCH_STATUS= 0)  /*LOOP*/
	  BEGIN
		/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
		EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1

		/*** Get author and illustrator names ***/
		EXEC CoreTitleInfo_get_author_illus_name @v_bookkey,@v_authorname OUTPUT,@v_illustratorname OUTPUT

		/* Get searchfield data*/
		exec [qtitle_get_coretitleinfo_searchfield] @v_bookkey, @v_searchfield OUTPUT

		/*** update coretitleinfo ***/
		UPDATE coretitleinfo
		SET authorname=@v_authorname,
    	    illustratorname=@v_illustratorname,
			searchfield=@v_searchfield
		WHERE bookkey = @v_bookkey

		/*** get next bookkey ***/
		FETCH NEXT FROM bookkey_cur 
		INTO @v_bookkey
	  END

	CLOSE bookkey_cur 
	DEALLOCATE bookkey_cur 
END
GO