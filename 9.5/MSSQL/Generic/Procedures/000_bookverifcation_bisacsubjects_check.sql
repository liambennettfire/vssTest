IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.bookverification_bisacsubjects_check') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.bookverification_bisacsubjects_check
END
GO

CREATE  PROCEDURE dbo.bookverification_bisacsubjects_check @i_bookkey INT, @i_check_for_juv INT,
				             @i_count  int output
AS
BEGIN
DECLARE
@v_count	INT

--- this procedure checks to see if there are any bookbisaccategory rows for Juvenile Fiction ('JUV') or Juvenile Non-Fiction ('JNF')
--- or if rows exist for other eloquencefieldtags other than 'JUV', 'JNF'
IF @i_check_for_juv = 1
BEGIN
	select @v_count = count (*)
	  from bookbisaccategory, gentables
	 where bookkey =  @i_bookkey 
      and tableid = 339
      and bookbisaccategory.bisaccategorycode = gentables.datacode
		and eloquencefieldtag in ('JUV','JNF')
	--print '@v_count'
	--print @v_count
	select @i_count = @v_count
END
IF @i_check_for_juv = 0
BEGIN
	select @v_count = count (*)
	  from bookbisaccategory, gentables
	 where bookkey =  @i_bookkey 
      and tableid = 339
      and bookbisaccategory.bisaccategorycode = gentables.datacode 
		and eloquencefieldtag NOT in ('JUV','JNF')
	--print '@v_count'
	--print @v_count
	select @i_count = @v_count
END

END

