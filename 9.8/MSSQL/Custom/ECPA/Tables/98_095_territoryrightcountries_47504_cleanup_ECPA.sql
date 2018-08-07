DECLARE @v_countrycode_invalid INT,
        @v_countrycode_valid INT,
		@v_count INT



BEGIN
	SELECT @v_countrycode_invalid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Argentia'
	SELECT @v_countrycode_valid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Argentina'
	SELECT @v_count = COUNT(*) FROM territoryrightcountries t WHERE countrycode = @v_countrycode_invalid

	IF @v_count > 0 BEGIN
		IF @v_countrycode_valid > 0 BEGIN
			
			DELETE FROM territoryrightcountries 
				WHERE countrycode = @v_countrycode_invalid
				  AND bookkey in (select bookkey from territoryrightcountries where countrycode = @v_countrycode_valid)

			UPDATE territoryrightcountries 
			   SET countrycode = @v_countrycode_valid,
				   lastuserid = 'FB_47504_CLEANUP',
				   lastmaintdate = getdate()
			 WHERE countrycode = @v_countrycode_invalid
		END
	END
END
go


DECLARE @v_countrycode_invalid INT,
        @v_countrycode_valid INT,
		@v_count INT
BEGIN
	SELECT @v_countrycode_invalid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Chila'
	SELECT @v_countrycode_valid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Chile'
	SELECT @v_count = COUNT(*) FROM territoryrightcountries t WHERE countrycode = @v_countrycode_invalid

	IF @v_count > 0 BEGIN
		IF @v_countrycode_valid > 0 BEGIN
			DELETE FROM territoryrightcountries 
				WHERE countrycode = @v_countrycode_invalid
				  AND bookkey in (select bookkey from territoryrightcountries where countrycode = @v_countrycode_valid)

			UPDATE territoryrightcountries 
			   SET countrycode = @v_countrycode_valid,
				   lastuserid = 'FB_47504_CLEANUP',
				   lastmaintdate = getdate()
			 WHERE countrycode = @v_countrycode_invalid
		END
	END
END
go

DECLARE @v_countrycode_invalid INT,
        @v_countrycode_valid INT,
		@v_count INT
BEGIN
	SELECT @v_countrycode_invalid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Czek Republic'
	SELECT @v_countrycode_valid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Czech Republic'
	SELECT @v_count = COUNT(*) FROM territoryrightcountries t WHERE countrycode = @v_countrycode_invalid

	IF @v_count > 0 BEGIN
		IF @v_countrycode_valid > 0 BEGIN
			DELETE FROM territoryrightcountries 
				WHERE countrycode = @v_countrycode_invalid
				  AND bookkey in (select bookkey from territoryrightcountries where countrycode = @v_countrycode_valid)

			UPDATE territoryrightcountries 
			   SET countrycode = @v_countrycode_valid,
				   lastuserid = 'FB_47504_CLEANUP',
				   lastmaintdate = getdate()
			 WHERE countrycode = @v_countrycode_invalid
		END
	END
END
go

DECLARE @v_countrycode_invalid INT,
        @v_countrycode_valid INT,
		@v_count INT
BEGIN
	SELECT @v_countrycode_invalid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Japann'
	SELECT @v_countrycode_valid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Japan'
	SELECT @v_count = COUNT(*) FROM territoryrightcountries t WHERE countrycode = @v_countrycode_invalid

	IF @v_count > 0 BEGIN
		IF @v_countrycode_valid > 0 BEGIN
			DELETE FROM territoryrightcountries 
				WHERE countrycode = @v_countrycode_invalid
				  AND bookkey in (select bookkey from territoryrightcountries where countrycode = @v_countrycode_valid)

			UPDATE territoryrightcountries 
			   SET countrycode = @v_countrycode_valid,
				   lastuserid = 'FB_47504_CLEANUP',
				   lastmaintdate = getdate()
			 WHERE countrycode = @v_countrycode_invalid
		END
	END
END
go

DECLARE @v_countrycode_invalid INT,
        @v_countrycode_valid INT,
		@v_count INT
BEGIN
	SELECT @v_countrycode_invalid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Korea'
	SELECT @v_countrycode_valid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Korea, Democratic'
	SELECT @v_count = COUNT(*) FROM territoryrightcountries t WHERE countrycode = @v_countrycode_invalid

	IF @v_count > 0 BEGIN
		IF @v_countrycode_valid > 0 BEGIN
			DELETE FROM territoryrightcountries 
				WHERE countrycode = @v_countrycode_invalid
				  AND bookkey in (select bookkey from territoryrightcountries where countrycode = @v_countrycode_valid)

			UPDATE territoryrightcountries 
			   SET countrycode = @v_countrycode_valid,
				   lastuserid = 'FB_47504_CLEANUP',
				   lastmaintdate = getdate()
			 WHERE countrycode = @v_countrycode_invalid
		END
	END
END
go

DECLARE @v_countrycode_invalid INT,
        @v_countrycode_valid INT,
		@v_count INT
BEGIN
	SELECT @v_countrycode_invalid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'zzz-Kuwait'
	SELECT @v_countrycode_valid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Kuwait'
	SELECT @v_count = COUNT(*) FROM territoryrightcountries t WHERE countrycode = @v_countrycode_invalid

	IF @v_count > 0 BEGIN
		IF @v_countrycode_valid > 0 BEGIN
			
			DELETE FROM territoryrightcountries 
				WHERE countrycode = @v_countrycode_invalid
				  AND bookkey in (select bookkey from territoryrightcountries where countrycode = @v_countrycode_valid)

			UPDATE territoryrightcountries 
			   SET countrycode = @v_countrycode_valid,
				   lastuserid = 'FB_47504_CLEANUP',
				   lastmaintdate = getdate()
			 WHERE countrycode = @v_countrycode_invalid
		END
	END
END
go

DECLARE @v_countrycode_invalid INT,
        @v_countrycode_valid INT,
		@v_count INT
BEGIN
	SELECT @v_countrycode_invalid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Macau'
	SELECT @v_countrycode_valid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Macao'
	SELECT @v_count = COUNT(*) FROM territoryrightcountries t WHERE countrycode = @v_countrycode_invalid

	IF @v_count > 0 BEGIN
		IF @v_countrycode_valid > 0 BEGIN
			DELETE FROM territoryrightcountries 
				WHERE countrycode = @v_countrycode_invalid
				  AND bookkey in (select bookkey from territoryrightcountries where countrycode = @v_countrycode_valid)

		    UPDATE territoryrightcountries 
			   SET countrycode = @v_countrycode_valid,
				   lastuserid = 'FB_47504_CLEANUP',
				   lastmaintdate = getdate()
			 WHERE countrycode = @v_countrycode_invalid
		END
	END
END
go

DECLARE @v_countrycode_invalid INT,
        @v_countrycode_valid INT,
		@v_count INT
BEGIN
	SELECT @v_countrycode_invalid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'zzz-Paraguay'
	SELECT @v_countrycode_valid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Paraguay'
	SELECT @v_count = COUNT(*) FROM territoryrightcountries t WHERE countrycode = @v_countrycode_invalid

	IF @v_count > 0 BEGIN
		IF @v_countrycode_valid > 0 BEGIN
			DELETE FROM territoryrightcountries 
				WHERE countrycode = @v_countrycode_invalid
				  AND bookkey in (select bookkey from territoryrightcountries where countrycode = @v_countrycode_valid)

			UPDATE territoryrightcountries 
			   SET countrycode = @v_countrycode_valid,
				   lastuserid = 'FB_47504_CLEANUP',
				   lastmaintdate = getdate()
			 WHERE countrycode = @v_countrycode_invalid
		END
	END
END
go

DECLARE @v_countrycode_invalid INT,
        @v_countrycode_valid INT,
		@v_count INT
BEGIN
	SELECT @v_countrycode_invalid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Russia'
	SELECT @v_countrycode_valid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Russian Federation'
	SELECT @v_count = COUNT(*) FROM territoryrightcountries t WHERE countrycode = @v_countrycode_invalid

	IF @v_count > 0 BEGIN
		IF @v_countrycode_valid > 0 BEGIN
			DELETE FROM territoryrightcountries 
				WHERE countrycode = @v_countrycode_invalid
				  AND bookkey in (select bookkey from territoryrightcountries where countrycode = @v_countrycode_valid)

			UPDATE territoryrightcountries 
			   SET countrycode = @v_countrycode_valid,
				   lastuserid = 'FB_47504_CLEANUP',
				   lastmaintdate = getdate()
			 WHERE countrycode = @v_countrycode_invalid
		END
	END
END
go

DECLARE @v_countrycode_invalid INT,
        @v_countrycode_valid INT,
		@v_count INT
BEGIN
	SELECT @v_countrycode_invalid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Slovak Republic'
	SELECT @v_countrycode_valid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Slovakia'
	SELECT @v_count = COUNT(*) FROM territoryrightcountries t WHERE countrycode = @v_countrycode_invalid

	IF @v_count > 0 BEGIN
		IF @v_countrycode_valid > 0 BEGIN
			DELETE FROM territoryrightcountries 
				WHERE countrycode = @v_countrycode_invalid
				  AND bookkey in (select bookkey from territoryrightcountries where countrycode = @v_countrycode_valid)

			UPDATE territoryrightcountries 
			   SET countrycode = @v_countrycode_valid,
				   lastuserid = 'FB_47504_CLEANUP',
				   lastmaintdate = getdate()
			 WHERE countrycode = @v_countrycode_invalid
		END
	END
END
go

DECLARE @v_countrycode_invalid INT,
        @v_countrycode_valid INT,
		@v_count INT
BEGIN
	SELECT @v_countrycode_invalid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'United States of Ame'
	SELECT @v_countrycode_valid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'United States'
	SELECT @v_count = COUNT(*) FROM territoryrightcountries t WHERE countrycode = @v_countrycode_invalid

	IF @v_count > 0 BEGIN
		IF @v_countrycode_valid > 0 BEGIN
			DELETE FROM territoryrightcountries 
				WHERE countrycode = @v_countrycode_invalid
				  AND bookkey in (select bookkey from territoryrightcountries where countrycode = @v_countrycode_valid)

			UPDATE territoryrightcountries 
			   SET countrycode = @v_countrycode_valid,
				   lastuserid = 'FB_47504_CLEANUP',
				   lastmaintdate = getdate()
			 WHERE countrycode = @v_countrycode_invalid
		END
	END
END
go

DECLARE @v_countrycode_invalid INT,
        @v_countrycode_valid INT,
		@v_count INT
BEGIN
	SELECT @v_countrycode_invalid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'United States of Ame'
	SELECT @v_countrycode_valid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'United States'
	SELECT @v_count = COUNT(*) FROM territoryrightcountries t WHERE countrycode = @v_countrycode_invalid

	IF @v_count > 0 BEGIN
		IF @v_countrycode_valid > 0 BEGIN
			DELETE FROM territoryrightcountries 
				WHERE countrycode = @v_countrycode_invalid
				  AND bookkey in (select bookkey from territoryrightcountries where countrycode = @v_countrycode_valid)


			UPDATE territoryrightcountries 
			   SET countrycode = @v_countrycode_valid,
				   lastuserid = 'FB_47504_CLEANUP',
				   lastmaintdate = getdate()
			 WHERE countrycode = @v_countrycode_invalid
		END
	END
END
go

DECLARE @v_countrycode_invalid INT,
        @v_countrycode_valid INT,
		@v_count INT
BEGIN
	SELECT @v_countrycode_invalid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Netherland Antilles'
	SELECT @v_countrycode_valid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Netherlands'
	SELECT @v_count = COUNT(*) FROM territoryrightcountries t WHERE countrycode = @v_countrycode_invalid

	IF @v_count > 0 BEGIN
		IF @v_countrycode_valid > 0 BEGIN
			DELETE FROM territoryrightcountries 
				WHERE countrycode = @v_countrycode_invalid
				  AND bookkey in (select bookkey from territoryrightcountries where countrycode = @v_countrycode_valid)

			UPDATE territoryrightcountries 
			   SET countrycode = @v_countrycode_valid,
				   lastuserid = 'FB_47504_CLEANUP',
				   lastmaintdate = getdate()
			 WHERE countrycode = @v_countrycode_invalid
		END
	END
END
go

DECLARE @v_countrycode_invalid INT,
        @v_countrycode_valid INT,
		@v_count INT
BEGIN
	SELECT @v_countrycode_invalid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'zzz-Paraguay'
	SELECT @v_countrycode_valid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Paraguay'
	SELECT @v_count = COUNT(*) FROM territoryrightcountries t WHERE countrycode = @v_countrycode_invalid

	IF @v_count > 0 BEGIN
		IF @v_countrycode_valid > 0 BEGIN
			DELETE FROM territoryrightcountries 
				WHERE countrycode = @v_countrycode_invalid
				  AND bookkey in (select bookkey from territoryrightcountries where countrycode = @v_countrycode_valid)

			UPDATE territoryrightcountries 
			   SET countrycode = @v_countrycode_valid,
				   lastuserid = 'FB_47504_CLEANUP',
				   lastmaintdate = getdate()
			 WHERE countrycode = @v_countrycode_invalid
		END
	END
END
go

DECLARE @v_countrycode_invalid INT,
        @v_countrycode_valid INT,
		@v_count INT
BEGIN
	SELECT @v_countrycode_invalid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Serbia & Montenegro'
	SELECT @v_countrycode_valid = datacode from gentables where tableid = 114 and rtrim(ltrim(datadescshort)) = 'Serbia'
	SELECT @v_count = COUNT(*) FROM territoryrightcountries t WHERE countrycode = @v_countrycode_invalid

	IF @v_count > 0 BEGIN
		IF @v_countrycode_valid > 0 BEGIN

			DELETE FROM territoryrightcountries 
				WHERE countrycode = @v_countrycode_invalid
				  AND bookkey in (select bookkey from territoryrightcountries where countrycode = @v_countrycode_valid)
			UPDATE territoryrightcountries 
			   SET countrycode = @v_countrycode_valid,
				   lastuserid = 'FB_47504_CLEANUP',
				   lastmaintdate = getdate()
			 WHERE countrycode = @v_countrycode_invalid
		END
	END
END
go




