IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.process_contact_category') AND (type = 'P' OR type = 'RF'))
  BEGIN
    DROP proc dbo.process_contact_category
  END

GO


CREATE PROCEDURE dbo.process_contact_category
  (@batchkey INT, @importsrckey INT, @importentrykey INT, @contactkey INT, 
   @bucode INT, @userid VARCHAR(30), @importstatus INT OUTPUT)

AS
   DECLARE @category       VARCHAR(50),   
           @impmsg         VARCHAR(255),
           @categorycode   INT,
           @nocategory     INT,
           @categorycount  INT

   DECLARE importcontactcat_cur CURSOR FOR
        SELECT category
          FROM importcontactcategory
         WHERE importsrckey = @importsrckey AND
               importbatchkey = @batchkey AND
               importentrykey =  @importentrykey
      ORDER BY subgroup

   SELECT @importstatus = 0

   OPEN importcontactcat_cur

   FETCH NEXT FROM importcontactcat_cur 
              INTO @category

   WHILE (@@FETCH_STATUS <> -1)
      BEGIN
         SELECT @nocategory = 1
		
		IF (@category IS NOT NULL)
			BEGIN
				-- Get the category code
				SELECT @categorycode = categorycode
				  FROM sectiontables
				 WHERE bucode = @bucode AND
						 UPPER(categorydesc) = UPPER(@category)
	
				-- If I did not get a code and I have a category, reject the record
				IF ((@categorycode IS NULL) OR (@categorycode = 0)) AND ((@category IS NOT NULL) OR (@category <> ''))
				  BEGIN
					 SELECT @impmsg = 'Category "' + @category + '" could not be mapped.'
					 EXEC importmsg @importsrckey, @batchkey, 2, 2, @impmsg, @userid
					 SELECT @importstatus = 130
				  END 
					 
				-- I have a category so lets make sure its not a dup
				IF ((@categorycode IS NOT NULL) AND (@categorycode > 0))
				  BEGIN
					 -- Get a count of this code for this contact in this bu
					 SELECT @categorycount = COUNT(*)
						FROM contactsection
					  WHERE contactkey = @contactkey AND
							  bucode = @bucode AND
							  categorycode = @categorycode
	
					 IF ((@categorycount = 0) OR (@categorycount IS NULL))
						-- The category does not exist for this contact in this bu
						BEGIN
						  SELECT @nocategory = 0
						END
					 ELSE
						-- The category is a dup for this contact in this bu
						BEGIN
						  SELECT @impmsg = 'Duplicate category for contact.'
						  EXEC importmsg @importsrckey, @batchkey, 2, 2, @impmsg, @userid
						  SELECT @importstatus = 131
						END
				  END
	
				If (@importstatus = 0) AND (@nocategory = 0)
				  BEGIN
					  INSERT INTO contactsection (contactkey, bucode, subjectcode, sectioncode, categorycode, categorysubcode, lastuserid, lastmaintdate)
												 VALUES (@contactkey, @bucode, 1, 1, @categorycode, 0, @userid, getdate())
				  END
         		END
         FETCH NEXT FROM importcontactcat_cur 
              INTO @category

      END -- WHILE

   CLOSE importcontactcat_cur 
   DEALLOCATE importcontactcat_cur 

   IF (@importstatus <> 0)
     BEGIN
       DELETE FROM contactsection WHERE contactkey = @contactkey
     END

RETURN

GO

GRANT EXECUTE ON dbo.process_contact_category TO PUBLIC

GO