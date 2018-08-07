IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'core_bookorgentry_filter')
  BEGIN
	PRINT 'Dropping Procedure core_bookorgentry_filter'
	DROP  Procedure  core_bookorgentry_filter
  END
GO

CREATE PROCEDURE core_bookorgentry_filter
AS

DECLARE @v_bookkey INT,
	@v_orglevelkey INT,
	@v_orgentrykey INT,
	@v_counter INT,
	@v_orgentryfilter VARCHAR(40)

/*** Set orgentryfilter ***/

DECLARE bookorgentry_cur CURSOR FOR
	SELECT DISTINCT bo.bookkey
	FROM bookorgentry bo, coretitleinfo co
	WHERE (bo.bookkey = co.bookkey) AND co.orgentryfilter like '(_)'

OPEN bookorgentry_cur

FETCH bookorgentry_cur INTO @v_bookkey
	
WHILE (@@FETCH_STATUS = 0)
  BEGIN
	DECLARE bookorgentry_filter_cur CURSOR FOR
		SELECT bo.orglevelkey, bo.orgentrykey
		FROM bookorgentry bo
		WHERE bo.bookkey = @v_bookkey
	
	OPEN bookorgentry_filter_cur
	
	FETCH bookorgentry_filter_cur INTO @v_orglevelkey, @v_orgentrykey
	
	SET @v_counter = 1
	
	WHILE (@@FETCH_STATUS = 0)
	  BEGIN
		IF @v_counter = 1 
			SET @v_orgentryfilter = '(' + LTRIM(STR(@v_orgentrykey))
	  	ELSE		
			SET @v_orgentryfilter = @v_orgentryfilter + ',' + LTRIM(STR(@v_orgentrykey))
		
		FETCH bookorgentry_filter_cur INTO @v_orglevelkey, @v_orgentrykey
	
		SET @v_counter = @v_counter + 1
	  END
	
	IF @v_orgentryfilter IS NOT NULL
	  BEGIN
		SET @v_orgentryfilter = @v_orgentryfilter + ')'
	
		UPDATE coretitleinfo
		SET orgentryfilter = @v_orgentryfilter
		WHERE bookkey = @v_bookkey
	  END
	
	CLOSE bookorgentry_filter_cur
	DEALLOCATE bookorgentry_filter_cur

	FETCH bookorgentry_cur INTO @v_bookkey
  END

CLOSE bookorgentry_cur
DEALLOCATE bookorgentry_cur

GO