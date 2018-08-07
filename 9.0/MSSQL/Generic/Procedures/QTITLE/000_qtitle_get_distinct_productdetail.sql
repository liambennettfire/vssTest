if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_distinct_productdetail') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_distinct_productdetail
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_distinct_productdetail
 (@i_bookkey     integer,
  @i_itemtypecode   integer,
  @i_usageclasscode integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_distinct_productdetail
**  Desc: This stored procedure returns a list of distinct subjects
**        from gentables. 
**
**  Auth: Uday Khisty
**  Date: 13 May 2013
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:     Description:
**  -------   ---------   ----------------------------------------------------
*******************************************************************************/

  DECLARE 
    @error_var    INT,
    @rowcount_var INT,
    @itemtypecode_var INT

	SET @o_error_code = 0
	SET @o_error_desc = ''
  
    SELECT DISTINCT g.tableid,
	  CASE
		WHEN gentext1label IS NOT NULL OR subgentext1label IS NOT NULL OR sub2gentext1label IS NOT NULL 
		THEN
		  CASE
			WHEN LTRIM(RTRIM(LOWER(g.sub2gentext1label))) = 'detail description' 
			THEN ('sub2gentables_ext')  

			WHEN LTRIM(RTRIM(LOWER(g.subgentext1label))) = 'detail description' 
			THEN ('subgentables_ext')

			WHEN LTRIM(RTRIM(LOWER(g.gentext1label))) = 'detail description' 
			THEN ('gentables_ext')				
		  ELSE ''	
		  END
	    ELSE ''
	    END AS detaildescriptioncolumn,
	  CASE
		WHEN g.gentext2label IS NOT NULL OR g.subgentext2label IS NOT NULL OR g.sub2gentext2label IS NOT NULL 
		THEN
		  CASE
			WHEN LTRIM(RTRIM(LOWER(g.sub2gentext2label))) = 'usage notes' 
			THEN ('sub2gentables_ext')  

			WHEN LTRIM(RTRIM(LOWER(g.subgentext2label))) = 'usage notes' 
			THEN ('subgentables_ext')

			WHEN LTRIM(RTRIM(LOWER(g.gentext2label))) = 'usage notes' 
			THEN ('gentables_ext')				
		  ELSE ''	
		  END
	    ELSE ''
	    END AS usagenotescolumn,      
      g.tabledesclong,  
      dbo.qtitle_get_productdetail_count(@i_bookkey, g.tableid) productdetailexist
  FROM gentablesdesc g 
  WHERE g.activeind = 1 AND
      g.productdetailind = 1

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: bookproductdetail on gentablesdesc.'   
  END 

GO

GRANT EXEC ON qtitle_get_distinct_productdetail TO PUBLIC
GO

