if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_productdetail_by_tableid') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_productdetail_by_tableid
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_productdetail_by_tableid
 (@i_bookkey        integer,
  @i_tableid        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_productdetail_by_tableid
**  Desc: This stored procedure returns product detail information
**        from the bookproductdetail table for a tableid.
**
**    Auth: Uday Khisty
**    Date: 21 May 2013
*******************************************************************************/

  DECLARE @error_var    INT,
		  @rowcount_var INT,
		  @v_gentext1label VARCHAR(30),
		  @v_gentext2label VARCHAR(30),
		  @v_subgentext1label VARCHAR(30),
		  @v_subgentext2label VARCHAR(30),
		  @v_sub2gentext1label VARCHAR(30),
		  @v_sub2gentext2label VARCHAR(30),
		  @v_text1label INT,
		  @v_text2label INT		

  SET @o_error_code = 0
  SET @o_error_desc = ''
    
  SELECT @v_gentext1label = gentext1label, @v_gentext2label = gentext2label, 
		 @v_subgentext1label= subgentext1label, @v_subgentext2label = subgentext2label,
		 @v_sub2gentext1label = sub2gentext1label, @v_sub2gentext2label = sub2gentext2label
  FROM gentablesdesc 
  WHERE tableid = @i_tableid
  
    
  SELECT b.*,
	  CASE
		WHEN @v_gentext1label IS NOT NULL OR @v_subgentext1label IS NOT NULL OR @v_sub2gentext1label IS NOT NULL 
		THEN
		  CASE
			WHEN LTRIM(RTRIM(LOWER(@v_sub2gentext1label))) = 'detail description' AND b.datasub2code IS NOT NULL
			THEN (SELECT s2.gentext1 FROM sub2gentables_ext AS s2 WHERE s2.tableid = @i_tableid AND s2.datacode = b.datacode AND s2.datasubcode = b.datasubcode AND s2.datasub2code = b.datasub2code)  

			WHEN LTRIM(RTRIM(LOWER(@v_subgentext1label))) = 'detail description' AND b.datasubcode IS NOT NULL
			THEN (SELECT s.gentext1 FROM subgentables_ext AS s WHERE s.tableid = @i_tableid AND s.datacode = b.datacode AND s.datasubcode = b.datasubcode)

			WHEN LTRIM(RTRIM(LOWER(@v_gentext1label))) = 'detail description' AND b.datacode IS NOT NULL
			THEN (SELECT g.gentext1 FROM gentables_ext AS g WHERE g.tableid = @i_tableid AND g.datacode = b.datacode)				
		  ELSE ''	
		  END
	    ELSE ''
	    END AS detaildescription,
	  CASE
		WHEN @v_gentext2label IS NOT NULL OR @v_subgentext2label IS NOT NULL OR @v_sub2gentext2label IS NOT NULL 
		THEN
		  CASE
			WHEN LTRIM(RTRIM(LOWER(@v_sub2gentext2label))) = 'usage notes' AND b.datasub2code IS NOT NULL
			THEN (SELECT s2.gentext2 FROM sub2gentables_ext AS s2 WHERE s2.tableid = @i_tableid AND s2.datacode = b.datacode AND s2.datasubcode = b.datasubcode AND s2.datasub2code = b.datasub2code)  

			WHEN LTRIM(RTRIM(LOWER(@v_subgentext2label))) = 'usage notes' AND b.datasubcode IS NOT NULL
			THEN (SELECT s.gentext2 FROM subgentables_ext AS s WHERE s.tableid = @i_tableid AND s.datacode = b.datacode AND s.datasubcode = b.datasubcode)

			WHEN LTRIM(RTRIM(LOWER(@v_gentext2label))) = 'usage notes' AND b.datacode IS NOT NULL
			THEN (SELECT g.gentext2 FROM gentables_ext AS g WHERE g.tableid = @i_tableid AND g.datacode = b.datacode)				
		  ELSE ''	
		  END
	    ELSE ''
	    END AS usagenotes		       
  FROM bookproductdetail b    
  WHERE b.tableid = @i_tableid and
	    b.bookkey = @i_bookkey 
  ORDER BY b.sortorder

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' / tableid = ' + cast(@i_tableid AS VARCHAR)
  END 

GO
GRANT EXEC ON qtitle_get_productdetail_by_tableid TO PUBLIC
GO


