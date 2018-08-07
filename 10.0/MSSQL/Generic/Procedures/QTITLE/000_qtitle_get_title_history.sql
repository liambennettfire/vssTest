if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_title_history') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_title_history
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_title_history
 (@i_bookkey        integer,
  @i_printingkey    integer,
  @i_columnkey      integer,
  @o_error_code     integer       output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_title_history
**  Desc: This gets title history information for the Title.
**
**    Auth: Uday Khisty
**    Date: 3 December 2013
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  IF @i_columnkey > 0 BEGIN
	select t.bookkey, t.printingkey, t.columnkey, tc.columndescription, t.fielddesc,
	  CASE
		WHEN LTRIM(RTRIM(LOWER(tc.datatype))) = 'y'
		THEN
		  CASE
			WHEN LTRIM(RTRIM(t.currentstringvalue))= '1'
			THEN 'Y'

			WHEN LTRIM(RTRIM(t.currentstringvalue))= '0'
			THEN 'N'	
		  ELSE t.currentstringvalue	
		  END
		ELSE t.currentstringvalue
		END AS currentstringvalue,
   COALESCE(t.changecomment, '') as changecomment, t.lastuserid,  t.lastmaintdate
	from titlehistory t
	LEFT OUTER JOIN titlehistorycolumns tc ON t.columnkey = tc.columnkey
	WHERE t.bookkey = @i_bookkey and t.printingkey = @i_printingkey and t.columnkey = @i_columnkey
	order by t.lastmaintdate DESC
  END
  ELSE BEGIN
	select t.bookkey, t.printingkey, t.columnkey, tc.columndescription, t.fielddesc,
	  CASE
		WHEN LTRIM(RTRIM(LOWER(tc.datatype))) = 'y'
		THEN
		  CASE
			WHEN LTRIM(RTRIM(t.currentstringvalue))= '1'
			THEN 'Y'

			WHEN LTRIM(RTRIM(t.currentstringvalue))= '0'
			THEN 'N'	
		  ELSE t.currentstringvalue	
		  END
		ELSE t.currentstringvalue
		END AS currentstringvalue,
   COALESCE(t.changecomment, '') as changecomment, t.lastuserid,  t.lastmaintdate
	from titlehistory t
	LEFT OUTER JOIN titlehistorycolumns tc ON t.columnkey = tc.columnkey 
	WHERE t.bookkey = @i_bookkey and t.printingkey = @i_printingkey
	order by t.lastmaintdate DESC
  END  

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: bookkey = ' + cast(@i_bookkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qtitle_get_title_history TO PUBLIC
GO


