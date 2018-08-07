if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_set_distribution_resend') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_set_distribution_resend
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_set_distribution_resend
 (@i_bookkey        integer,
  @i_partnerkey		integer,
  @i_assetkey		integer,
  @i_resendind		tinyint,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_set_distribution_resend
**  Desc: This stored procedure sets the resend ind for distribution(s).
**		  All parameters (@i_bookkey, @i_partnerkey, @i_assetkey, @i_resendind)
**		  are optional, meaning they won't be taken into consideration in the
**        updates if they get left out (no bookkey means all books, etc)
**
**  Auth: Dustin Miller
**  Date: February 25, 2016
*******************************************************************************/
  DECLARE @v_error  INT
  DECLARE @ResendBooks TABLE
  (
	bookkey int
  )

  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_resendind IS NULL
  BEGIN
	SET @i_resendind = 0
  END

  IF @i_bookkey IS NULL BEGIN
    INSERT INTO @ResendBooks
	SELECT DISTINCT bookkey
	FROM taqprojectelementpartner
	WHERE (@i_partnerkey IS NULL OR partnercontactkey = @i_partnerkey)
	  AND (@i_assetkey IS NULL OR assetkey = @i_assetkey)
  END 

  UPDATE taqprojectelementpartner
  SET resendind = @i_resendind
  WHERE (@i_bookkey IS NULL OR bookkey = @i_bookkey)
	AND (@i_partnerkey IS NULL OR partnercontactkey = @i_partnerkey)
	AND (@i_assetkey IS NULL OR assetkey = @i_assetkey)

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error updating resendind on taqprojectelementpartner table: bookkey = ' + cast(COALESCE(@i_bookkey, 0) AS VARCHAR)
	RETURN
  END 

  IF @i_bookkey IS NOT NULL
  BEGIN
	EXEC qtitle_set_cspartnerstatuses_on_title @i_bookkey, 'QSIDBA', @o_error_code OUTPUT, @o_error_desc OUTPUT
  END
  ELSE BEGIN
	DECLARE @v_resendbookkey INT

	DECLARE resendcursor CURSOR FOR
	SELECT bookkey
	FROM @ResendBooks

	OPEN resendcursor
	FETCH NEXT FROM resendcursor INTO @v_resendbookkey

	WHILE @@FETCH_STATUS = 0
	BEGIN
	  EXEC qtitle_set_cspartnerstatuses_on_title @v_resendbookkey, 'QSIDBA', @o_error_code OUTPUT, @o_error_desc OUTPUT
	  IF @o_error_code IS NOT NULL AND @o_error_code <> 0
	  BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Error updating resendind on taqprojectelementpartner table: bookkey = ' + cast(COALESCE(@v_resendbookkey, 0) AS VARCHAR)
		RETURN
	  END

	  FETCH NEXT FROM resendcursor INTO @v_resendbookkey
	END

	CLOSE resendcursor
	DEALLOCATE resendcursor
  END
GO

GRANT EXEC ON qtitle_set_distribution_resend TO PUBLIC
GO
