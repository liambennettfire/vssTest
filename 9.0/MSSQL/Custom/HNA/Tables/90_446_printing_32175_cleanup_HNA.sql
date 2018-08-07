DECLARE 
	@v_projectrole INT,
	@v_titlerole INT

	SELECT @v_projectrole = datacode FROM gentables WHERE tableid = 604 and qsicode = 3
    SELECT @v_titlerole = datacode FROM gentables WHERE tableid = 605 and qsicode = 7
    

	DELETE p
	FROM printing p INNER JOIN 
	(select bookkey, printingkey from printing
	except
	select bookkey, printingkey  from taqprojecttitle  where projectrolecode = @v_projectrole and titlerolecode = @v_titlerole) temp
	ON p.printingkey = temp.printingkey AND p.bookkey = temp.bookkey    
	
	DELETE c
	FROM coretitleinfo c INNER JOIN 
	(select bookkey, printingkey from coretitleinfo
	except
	select bookkey, printingkey  from taqprojecttitle  where projectrolecode = @v_projectrole and titlerolecode = @v_titlerole) temp
	ON c.bookkey = temp.bookkey AND c.printingkey = temp.printingkey 	
	
GO