IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.bookverification_bisacsubjects_juv_jnf_check') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.bookverification_bisacsubjects_juv_jnf_check
END
GO

CREATE  PROCEDURE dbo.bookverification_bisacsubjects_juv_jnf_check @i_bookkey INT, @i_check_for_juv INT,@i_count  int output
AS

/******************************************************************************
**  Name: bookverification_bisacsubjects_juv_jnf_check
**  Desc: This stored procedure returns the number of rows for either 'JUV' or 'JNF'
**        on bookbisaccategory for a given bookkey
**        @i_check_for_juv = 1 Check for rows with the 'JUV' eloquencefieldtag
**        @i_check_for_juv = 0 Check for rows with the 'JNF' eloquencefieldtag
**
**    Auth: Kusum Basra
**    Date: 16 February 2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  
*******************************************************************************/
BEGIN
	DECLARE
	@v_count	INT

	
	IF @i_check_for_juv = 1
	BEGIN
		SELECT @v_count = count (*)
		  FROM bookbisaccategory, gentables
		 WHERE  bookkey =  @i_bookkey 
		   AND tableid = 339
		   AND bookbisaccategory.bisaccategorycode = gentables.datacode
		   AND eloquencefieldtag IN ('JUV')
		   
		 SELECT @i_count = @v_count
	END
	IF @i_check_for_juv = 0
	BEGIN
		SELECT @v_count = count (*)
		  FROM bookbisaccategory, gentables
		 WHERE  bookkey =  @i_bookkey 
		   AND tableid = 339
		   AND bookbisaccategory.bisaccategorycode = gentables.datacode
		   AND eloquencefieldtag IN ('JNF')
		   
		SELECT @i_count = @v_count
	END
END
GO
GRANT EXECUTE ON bookverification_bisacsubjects_juv_jnf_check TO PUBLIC
GO

