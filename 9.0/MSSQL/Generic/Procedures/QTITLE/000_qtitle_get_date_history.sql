if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_date_history') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_date_history
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_date_history
 (@i_bookkey        integer,
  @i_printingkey    integer,
  @o_error_code     integer       output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_date_history
**  Desc: This gets date history information for the Title.
**
**    Auth: Uday Khisty
**    Date: 3 December 2013
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT dh.bookkey, dh.printingkey, dh.datetypecode, dh.datekey, 
	COALESCE(dh.datestagecode, -1) as datestagecode, dt.description, dh.datechanged, 
	COALESCE(dh.changecomment, '') as changecomment, dh.lastuserid, dh.lastmaintdate
  FROM datehistory dh 
	LEFT OUTER JOIN datetype dt ON dh.datetypecode = dt.datetypecode 
  WHERE bookkey =  @i_bookkey and printingkey = @i_printingkey
  ORDER BY dh.lastmaintdate DESC
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: bookkey = ' + cast(@i_bookkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qtitle_get_date_history TO PUBLIC
GO


