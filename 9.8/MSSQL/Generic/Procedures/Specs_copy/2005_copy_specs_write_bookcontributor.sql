IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.Specs_Copy_write_bookcontributor') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.Specs_Copy_write_bookcontributor
END
GO

CREATE PROCEDURE Specs_Copy_write_bookcontributor	(
  @i_from_bookkey     INT,
  @i_from_printingkey INT,
  @i_to_bookkey       INT,
  @i_to_printingkey   INT,
  @i_specind          INT,
  @i_userid           VARCHAR(30),
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT)

AS

DECLARE

	@v_contributorkey    	INT,
	@v_roletypecode		   INT,
	@v_depttypecode         INT,
   @v_resourcedesc         VARCHAR(255),
   @v_sortorder				INT,
   @v_filterroletype_poperson INT,
   @v_filterroletype_prodmod2 INT,
	@v_filterroletype_prodmod3 INT,
   @v_count							INT,
   @v_count2 						INT,
   @v_count3						INT,
   @v_bookcontactkey          INT

	DECLARE bookcontributor_cur CURSOR FOR
		 SELECT contributorkey, roletypecode, depttypecode, resourcedesc, sortorder FROM bookcontributor
		  WHERE (bookkey=@i_from_bookkey) AND
              (printingkey=@i_from_printingkey)

   SELECT @v_filterroletype_poperson = 1
   SELECT @v_filterroletype_prodmod2 = 2
   SELECT @v_filterroletype_prodmod3 = 3
BEGIN
	IF @i_specind = 1
   BEGIN
	
		OPEN bookcontributor_cur
	
		FETCH NEXT FROM bookcontributor_cur INTO @v_contributorkey, @v_roletypecode, @v_depttypecode, @v_resourcedesc, @v_sortorder
	
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN

			UPDATE keys SET generickey = generickey+1,lastuserid = 'QSIADMIN',lastmaintdate = getdate()

	      SELECT @v_bookcontactkey = generickey from keys

			INSERT INTO bookcontact  (bookcontactkey,bookkey,printingkey,globalcontactkey,participantnote,keyind,sortorder,lastuserid,lastmaintdate )  
			 VALUES (@v_bookcontactkey,@i_to_bookkey,@i_to_printingkey,@v_contributorkey, @v_resourcedesc, 1,@v_sortorder,@i_userid,getdate()) 
	
			INSERT INTO bookcontactrole  (bookcontactkey,rolecode,activeind,workrate,ratetypecode,departmentcode,lastuserid,lastmaintdate )  
			 VALUES (@v_bookcontactkey, @v_roletypecode,1,NULL,NULL, @v_depttypecode, @i_userid,getdate())   
				
			FETCH NEXT FROM bookcontributor_cur INTO @v_contributorkey, @v_roletypecode, @v_depttypecode, @v_resourcedesc, @v_sortorder
				 
		END --bookcontributor_cur LOOP
				
		CLOSE bookcontributor_cur
--		DEALLOCATE bookcontributor_cur
   END

	DEALLOCATE bookcontributor_cur

   IF @i_specind = 0
   -- bookcontributor rows may already exist for title being copied to from TMM or conversion and these rows need to be kept
   -- the only roles that need to be checked from title being copied from are on the filterroletype for Production so loop through the 
   -- 3 specified roles, if dont exist on title being copied to and exist on title being copied from then insert for title being copied to
   BEGIN
		SELECT @v_count = count(*)
        FROM bookcontributor,filterroletype
       WHERE ( bookcontributor.roletypecode = filterroletype.roletypecode ) and  
				 ( ( bookcontributor.bookkey = @i_to_bookkey ) AND  
				 ( bookcontributor.printingkey = @i_to_printingkey ) AND  
				 ( filterroletype.filterkey = @v_filterroletype_poperson ) )  

       IF @v_count = 0   -- only insert values from title being copied from if no row exists already for title being copied to for roletype of filterkey = 1
       BEGIN
			SELECT @v_count2 = count(*)
           FROM bookcontributor
          WHERE bookcontributor.bookkey = @i_to_bookkey AND  
				    bookcontributor.printingkey = @i_to_printingkey

	
			IF @v_count2 > 0 
 			BEGIN
				SELECT @v_sortorder = max(sortorder)
				  FROM bookcontributor
				 WHERE bookcontributor.bookkey = @i_to_bookkey AND  
						 bookcontributor.printingkey = @i_to_printingkey

  				IF @v_sortorder = 0 OR @v_sortorder is null
            BEGIN
 					SELECT @v_sortorder = 1
				END
            ELSE
            BEGIN
               SELECT @v_sortorder = @v_sortorder + 1
            END
			END
         ELSE
         BEGIN
				SELECT @v_sortorder = 1
         END

         SELECT @v_count3 = count(*)
           FROM bookcontributor,filterroletype
  			 WHERE ( bookcontributor.roletypecode = filterroletype.roletypecode ) and  
				 ( ( bookcontributor.bookkey = @i_from_bookkey ) AND  
				 ( bookcontributor.printingkey = @i_from_printingkey ) AND  
				 ( filterroletype.filterkey = @v_filterroletype_poperson ) )

         IF @v_count3 > 0
         BEGIN
				SELECT @v_contributorkey=contributorkey,@v_roletypecode=bookcontributor.roletypecode,@v_depttypecode=depttypecode,@v_resourcedesc=resourcedesc
				  FROM bookcontributor,filterroletype
				 WHERE ( bookcontributor.roletypecode = filterroletype.roletypecode ) and  
					 ( ( bookcontributor.bookkey = @i_from_bookkey ) AND  
					 ( bookcontributor.printingkey = @i_from_printingkey ) AND  
					 ( filterroletype.filterkey = @v_filterroletype_poperson ) )
	
				UPDATE keys SET generickey = generickey+1,lastuserid = 'QSIADMIN',lastmaintdate = getdate()

	            SELECT @v_bookcontactkey = generickey from keys

	
				INSERT INTO bookcontact  (bookcontactkey,bookkey,printingkey,globalcontactkey,participantnote,keyind,sortorder,lastuserid,lastmaintdate )  
				 VALUES (@v_bookcontactkey,@i_to_bookkey,@i_to_printingkey,@v_contributorkey, @v_resourcedesc, 1,@v_sortorder,@i_userid,getdate()) 
		
				INSERT INTO bookcontactrole  (bookcontactkey,rolecode,activeind,workrate,ratetypecode,departmentcode,lastuserid,lastmaintdate )  
				 VALUES (@v_bookcontactkey, @v_roletypecode,1,NULL,NULL, @v_depttypecode, @i_userid,getdate()) 
			END
   	END

         SELECT @v_count = 0
			SELECT @v_count2 = 0
 			SELECT @v_count3 = 0
 			SELECT @v_sortorder = 0

			SELECT @v_count = count(*)
			  FROM bookcontributor,filterroletype
			 WHERE ( bookcontributor.roletypecode = filterroletype.roletypecode ) and  
					 ( ( bookcontributor.bookkey = @i_to_bookkey ) AND  
					 ( bookcontributor.printingkey = @i_to_printingkey ) AND  
					 ( filterroletype.filterkey = @v_filterroletype_prodmod2 ) )  
	
			 IF @v_count = 0
			 BEGIN
				SELECT @v_count2 = count(*)
				  FROM bookcontributor
				 WHERE bookcontributor.bookkey = @i_to_bookkey AND  
						 bookcontributor.printingkey = @i_to_printingkey
	
		
				IF @v_count2 > 0 
				BEGIN
					SELECT @v_sortorder = max(sortorder)
					  FROM bookcontributor
					 WHERE bookcontributor.bookkey = @i_to_bookkey AND  
							 bookcontributor.printingkey = @i_to_printingkey
	
					IF @v_sortorder = 0 OR @v_sortorder is null
					BEGIN
						SELECT @v_sortorder = 1
					END
					ELSE
					BEGIN
						SELECT @v_sortorder = @v_sortorder + 1
					END
				END
				ELSE
				BEGIN
					SELECT @v_sortorder = 1
				END
	

				SELECT @v_count3 = count(*)
				  FROM bookcontributor,filterroletype
				 WHERE ( bookcontributor.roletypecode = filterroletype.roletypecode ) and  
					 ( ( bookcontributor.bookkey = @i_from_bookkey ) AND  
					 ( bookcontributor.printingkey = @i_from_printingkey ) AND  
					 ( filterroletype.filterkey = @v_filterroletype_prodmod2 ) )
	
				IF @v_count3 > 0
				BEGIN
					SELECT @v_contributorkey=contributorkey,@v_roletypecode=bookcontributor.roletypecode,@v_depttypecode=depttypecode,@v_resourcedesc=resourcedesc
				  	  FROM bookcontributor,filterroletype
					 WHERE ( bookcontributor.roletypecode = filterroletype.roletypecode ) and  
						 ( ( bookcontributor.bookkey = @i_from_bookkey ) AND  
						 ( bookcontributor.printingkey = @i_from_printingkey ) AND  
						 ( filterroletype.filterkey = @v_filterroletype_prodmod2) )
		
					UPDATE keys SET generickey = generickey+1,lastuserid = 'QSIADMIN',lastmaintdate = getdate()

	                SELECT @v_bookcontactkey = generickey from keys

		
					INSERT INTO bookcontact  (bookcontactkey,bookkey,printingkey,globalcontactkey,participantnote,keyind,sortorder,lastuserid,lastmaintdate )  
					 VALUES (@v_bookcontactkey,@i_to_bookkey,@i_to_printingkey,@v_contributorkey, @v_resourcedesc, 1,@v_sortorder,@i_userid,getdate()) 
			
					INSERT INTO bookcontactrole  (bookcontactkey,rolecode,activeind,workrate,ratetypecode,departmentcode,lastuserid,lastmaintdate )  
					 VALUES (@v_bookcontactkey, @v_roletypecode,1,NULL,NULL, @v_depttypecode, @i_userid,getdate()) 
				END
        END

				SELECT @v_count = 0
				SELECT @v_count2 = 0
				SELECT @v_count3 = 0
				SELECT @v_sortorder = 0

				SELECT @v_count = count(*)
				  FROM bookcontributor,filterroletype
				 WHERE ( bookcontributor.roletypecode = filterroletype.roletypecode ) and  
						 ( ( bookcontributor.bookkey = @i_to_bookkey ) AND  
						 ( bookcontributor.printingkey = @i_to_printingkey ) AND  
						 ( filterroletype.filterkey = @v_filterroletype_prodmod3 ) )  
		
				 IF @v_count = 0
				 BEGIN
					SELECT @v_count2 = count(*)
					  FROM bookcontributor
					 WHERE bookcontributor.bookkey = @i_to_bookkey AND  
							 bookcontributor.printingkey = @i_to_printingkey
	
		
				IF @v_count2 > 0 
				BEGIN
					SELECT @v_sortorder = max(sortorder)
					  FROM bookcontributor
					 WHERE bookcontributor.bookkey = @i_to_bookkey AND  
							 bookcontributor.printingkey = @i_to_printingkey
	
					IF @v_sortorder = 0 OR @v_sortorder is null
					BEGIN
						SELECT @v_sortorder = 1
					END
					ELSE
					BEGIN
						SELECT @v_sortorder = @v_sortorder + 1
					END
				END
				ELSE
				BEGIN
					SELECT @v_sortorder = 1
				END
	
				SELECT @v_count3 = count(*)
				  FROM bookcontributor,filterroletype
				 WHERE ( bookcontributor.roletypecode = filterroletype.roletypecode ) and  
					 ( ( bookcontributor.bookkey = @i_from_bookkey ) AND  
					 ( bookcontributor.printingkey = @i_from_printingkey ) AND  
					 ( filterroletype.filterkey = @v_filterroletype_prodmod3 ) )
	
				IF @v_count3 > 0
				BEGIN
					SELECT @v_contributorkey=contributorkey,@v_roletypecode=bookcontributor.roletypecode,@v_depttypecode=depttypecode,@v_resourcedesc=resourcedesc
				     FROM bookcontributor,filterroletype
					 WHERE ( bookcontributor.roletypecode = filterroletype.roletypecode ) and  
						 ( ( bookcontributor.bookkey = @i_from_bookkey ) AND  
						 ( bookcontributor.printingkey = @i_from_printingkey ) AND  
						 ( filterroletype.filterkey = @v_filterroletype_prodmod3 ) )
		
					UPDATE keys SET generickey = generickey+1,lastuserid = 'QSIADMIN',lastmaintdate = getdate()

	                SELECT @v_bookcontactkey = generickey from keys

		
					INSERT INTO bookcontact  (bookcontactkey,bookkey,printingkey,globalcontactkey,participantnote,keyind,sortorder,lastuserid,lastmaintdate )  
					 VALUES (@v_bookcontactkey,@i_to_bookkey,@i_to_printingkey,@v_contributorkey, @v_resourcedesc, 1,@v_sortorder,@i_userid,getdate()) 
			
					INSERT INTO bookcontactrole  (bookcontactkey,rolecode,activeind,workrate,ratetypecode,departmentcode,lastuserid,lastmaintdate )  
					 VALUES (@v_bookcontactkey, @v_roletypecode,1,NULL,NULL, @v_depttypecode, @i_userid,getdate()) 
				END
		END
	END

END
go