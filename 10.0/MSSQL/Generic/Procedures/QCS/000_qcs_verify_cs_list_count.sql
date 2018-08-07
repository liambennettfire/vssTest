IF EXISTS (SELECT *
			   FROM dbo.sysobjects
			   WHERE id = object_id(N'dbo.qcs_verify_cs_list_count')
				   AND objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE dbo.qcs_verify_cs_list_count
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE qcs_verify_cs_list_count
(
    @i_listkey INTEGER,
    @i_all_ISBNs_for_work INTEGER,
    @o_error_code INTEGER OUTPUT,
    @o_error_desc VARCHAR(2000) OUTPUT
)
AS

	/*************************************************************************************************************
**  Name: qcs_verify_cs_list_count
**  Desc: This stored procedure determines if a list of titles exceeds the clientDefaults max value.
**        o_error_code values:  0 - OK                         
**                             -1 - Error occurred
** 
**  Auth: Jonathan Hess	
**  Date: 30 August 2012
*************************************************************************************************************/

	DECLARE
            @v_count                        INT,
            @v_error                        INT,
            @v_rowcount                     INT,
            @v_CSMaxNumberTitlesPerDistSend INT

	BEGIN
		SET @o_error_code = 0
		SET @o_error_desc = ''

		SET @v_CSMaxNumberTitlesPerDistSend = (SELECT clientdefaultvalue
												   FROM clientdefaults c
												   WHERE clientdefaultid = 68)

		IF (isnull(@i_listkey, 0) = 0)
			BEGIN
				SET @o_error_code = -1
				SET @o_error_desc =
				'Error verifying Content Services approval for distribution - invalid listkey.'
				RETURN
			END

		IF @i_listkey > 0
			BEGIN
				SELECT @v_count = count(*)
					FROM qse_searchresults r, bookdetail b
					WHERE r.key1 = b.bookkey
						AND
						r.listkey = @i_listkey
						AND
						([dbo].qcs_get_csapproved(b.bookkey) = 1)

				SELECT @v_error = @@ERROR,
					   @v_rowcount = @@ROWCOUNT
				IF @v_error <> 0
					BEGIN
						SET @o_error_code = -1
						SET @o_error_desc =
						'Error accessing bookdetail table for Content Services approval verification: listkey='
						+ cast(isnull(@i_listkey, 0) AS VARCHAR)
						RETURN
					END
			END

		IF @v_count > @v_CSMaxNumberTitlesPerDistSend
			BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'The number of approved titles (' + cast(isnull(
						@v_count, 0) AS VARCHAR) + ') exceeds the limit of (' + cast(isnull(
						@v_CSMaxNumberTitlesPerDistSend, 0) AS VARCHAR) + ')'
				RETURN
			END


	--ELSE BEGIN
	--  IF @i_all_ISBNs_for_work = 1 BEGIN
	--    SELECT @v_count = COUNT(*) 
	--    FROM bookdetail bd, book b
	--    WHERE b.bookkey = bd.bookkey
	--      AND b.workkey in (select workkey from book where bookkey = @i_bookkey)   
	--      AND COALESCE(bd.csApprovalCode, 0) <> 1
	--  END
	--  ELSE BEGIN
	--    SELECT @v_count = COUNT(*) 
	--    FROM bookdetail bd
	--    WHERE bd.bookkey = @i_bookkey   
	--      AND COALESCE(bd.csApprovalCode, 0) <> 1
	--  END

	--  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	--  IF @v_error <> 0 BEGIN
	--    SET @o_error_code = -1
	--    SET @o_error_desc = 'Error accessing bookdetail table for Content Services approval verification: bookkey=' + cast(isnull(@i_bookkey,0) AS VARCHAR)
	--    RETURN 
	--  END 
	--END

	--IF @v_count > 0
	--  SET @o_error_code = @v_count

	END
GO

GRANT EXEC ON qcs_verify_cs_list_count TO PUBLIC
GO