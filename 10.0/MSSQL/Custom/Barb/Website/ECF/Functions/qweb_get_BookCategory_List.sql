SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_BookCategory_List]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_BookCategory_List]
GO




CREATE FUNCTION dbo.qweb_get_BookCategory_List
		(@i_bookkey	INT,
		@i_tableid INT,
		@v_column	VARCHAR(1))

RETURNS VARCHAR(512)

/*	The purpose of the qweb_get_BookCategory_List function is to return a specific description column from gentables for a BisacStatus

	Parameter Options
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(512)
	DECLARE @v_desc			VARCHAR(512)
	DECLARE @v_CategoryDesc			VARCHAR(512)
	DECLARE @i_CategoryCode	INT
	DECLARE @i_CategorySubCode	INT
	DECLARE @i_fetchstatus	INT
	
  DECLARE c_bookcategory CURSOR fast_forward FOR

	select categorycode, categorysubcode 
	from booksubjectcategory
	where bookkey = @i_bookkey
	  and categorytableid = @i_tableid
	  and categorysubcode > 0
			
	OPEN c_bookcategory 

	FETCH NEXT FROM c_bookcategory 
		INTO @i_CategoryCode, @i_CategorySubCode

	 select  @i_fetchstatus  = @@FETCH_STATUS

	 while (@i_fetchstatus >-1 ) begin
		IF (@i_fetchstatus <>-2) begin		 
	    IF @v_column = 'D'
		    BEGIN
			    SELECT @v_desc = LTRIM(RTRIM(datadesc))
			    FROM	subgentables  
			    WHERE  tableid = @i_tableid
					    AND datacode = @i_CategoryCode
					    AND datasubcode = @i_CategorySubCode
				END

	    ELSE IF @v_column = 'E'
		    BEGIN
			    SELECT @v_desc = LTRIM(RTRIM(externalcode))
			    FROM	subgentables  
			    WHERE  tableid = @i_tableid
					    AND datacode = @i_CategoryCode
					    AND datasubcode = @i_CategorySubCode
		    END

	    ELSE IF @v_column = 'S'
		    BEGIN
			    SELECT @v_desc = LTRIM(RTRIM(datadescshort))
			    FROM	subgentables  
			    WHERE  tableid = @i_tableid
					    AND datacode = @i_CategoryCode
					    AND datasubcode = @i_CategorySubCode    		
		    END

	    ELSE IF @v_column = 'B'
		    BEGIN
			    SELECT @v_desc = LTRIM(RTRIM(bisacdatacode))
			    FROM	subgentables  
			    WHERE  tableid = @i_tableid
					    AND datacode = @i_CategoryCode
					    AND datasubcode = @i_CategorySubCode
		    END

	    ELSE IF @v_column = '1'
		    BEGIN
			    SELECT @v_desc = LTRIM(RTRIM(alternatedesc1))
			    FROM	subgentables  
			    WHERE  tableid = @i_tableid
					    AND datacode = @i_CategoryCode
					    AND datasubcode = @i_CategorySubCode
		    END

	    ELSE IF @v_column = '2'
		    BEGIN
			    SELECT @v_desc = LTRIM(RTRIM(datadesc))
			    FROM	subgentables  
			    WHERE  tableid = @i_tableid
					    AND datacode = @i_CategoryCode
					    AND datasubcode = @i_CategorySubCode
		    END
      
      if @v_CategoryDesc is null OR ltrim(rtrim(@v_CategoryDesc)) = '' begin
        SET @v_CategoryDesc = @v_desc
      end
      else begin
        SET @v_CategoryDesc = @v_CategoryDesc + ',' + @v_desc
      end
    END
      
  	FETCH NEXT FROM c_bookcategory 
	    INTO @i_CategoryCode, @i_CategorySubCode

    select  @i_fetchstatus  = @@FETCH_STATUS
  end

	close c_bookcategory
	deallocate c_bookcategory



	IF LEN(@v_CategoryDesc) > 0
		BEGIN
			SELECT @RETURN = @v_CategoryDesc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

