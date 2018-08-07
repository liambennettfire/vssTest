SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Is_BBD_Locked]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Is_BBD_Locked]
GO


CREATE  proc dbo.Is_BBD_Locked 
@p_bookkey int, @p_printingkey int,
@p_datetypecode int, @p_userid  varchar, @b_boolean int OUTPUT 

AS 

DECLARE @v_orglevelkey		int
DECLARE @v_orgentrykey		int
DECLARE @v_count		int
DECLARE @v_userkey		int
DECLARE @v_printingnum		int
DECLARE @v_standardind		varchar(1)
DECLARE @v_updateind		varchar(1)
DECLARE @v_firstprinting	varchar(1)
DECLARE @i_status_count int
DECLARE @i_status_user int
DECLARE @i_status_org int
/*boolean was true false now 1 or 0 */

	DECLARE cur_count INSENSITIVE CURSOR
	FOR
		SELECT count(*)
		FROM bookorgentry
		WHERE bookkey =  @p_bookkey AND
				orglevelkey =  @v_orglevelkey
	FOR READ ONLY
	DECLARE cur_userkey INSENSITIVE CURSOR
	FOR
		SELECT userkey
		FROM qsiusers
		WHERE UPPER(userid) = UPPER(@p_userid)
	FOR READ ONLY
	DECLARE cur_userorgentry INSENSITIVE CURSOR 
	FOR
		SELECT u.orgentrykey
		FROM userprimaryorgentry u, orgentry o
		WHERE u.orgentrykey = o.orgentrykey AND
				u.userkey = @v_userkey AND
				o.orglevelkey = @v_orglevelkey
	FOR READ ONLY

	/* First, get the orglevelkey for Field Security - filterkey 13 */
	SELECT @v_orglevelkey = filterorglevelkey
	FROM filterorglevel
	WHERE filterkey = 13 

	/* Check if orglevel info is entered for this title */
	OPEN cur_count 
	FETCH NEXT FROM cur_count INTO @v_count
	
	select @i_status_count = @@FETCH_STATUS
	IF @i_status_count != 0 /*not found*/
	 begin
		/* First, get the userkey for the lastuserid on bookdates - must get primary orgentry for this user */
		OPEN cur_userkey 
		FETCH NEXT FROM cur_userkey INTO @v_userkey 				
		select @i_status_user = @@FETCH_STATUS
		IF @i_status_user != 0
		 begin
			/* if for any reason there is no record of this user name on the users table, use QSIADMIN */
			select v_userkey = 0
		  END
		close cur_userkey
		
		/* Get the primary orgentry for this user */
		OPEN cur_userorgentry
		FETCH NEXT FROM cur_userorgentry INTO @v_orgentrykey 
		close cur_userorgentry		

		/* Get the template indicator for this book */
		SELECT @v_standardind = standardind
		FROM book
		WHERE bookkey = @p_bookkey
	  end
	ELSE
	  begin
		/* If orglevel info exists for this title, get the title's orgentry for the given orglevel */
		SELECT @v_orgentrykey = orgentrykey, @v_standardind = standardind 
		FROM book, bookorgentry
		WHERE book.bookkey = bookorgentry.bookkey AND
				book.bookkey = @p_bookkey AND
				orglevelkey = @v_orglevelkey				
	END
	close cur_count
	deallocate  cur_count 
	deallocate cur_userkey
	deallocate cur_userorgentry

	/* Get the printing number for this title */
	SELECT @v_printingnum = printingnum
	FROM printing
	WHERE bookkey = @p_bookkey AND
			printingkey = @p_printingkey 

	/* Check field security for Bound Book Date */
	SELECT @v_updateind = updateind, @v_firstprinting = firstprtgonlyind
	FROM fieldsecurity
	WHERE orgentrykey = @v_orgentrykey AND
			LOWER(fieldname) = 'bound book date' 

	IF @v_printingnum > 1 
	  begin
		IF @v_firstprinting = 'Y' 
		  begin
			select @b_boolean = 0
			RETURN @b_boolean 
		  end
		IF @v_firstprinting = 'N' AND @v_updateind = 'N' 
		  begin
			select @b_boolean = 1
			RETURN @b_boolean 
		  end
		IF @v_firstprinting = 'N' AND @v_updateind = 'Y' 
		  begin
			select @b_boolean = 0
			RETURN @b_boolean
		END 
	END
	IF @v_printingnum = 1 
	  begin
		IF @v_updateind = 'N' 
		  begin
			select @b_boolean = 1
			RETURN @b_boolean 
		  end
		IF @v_updateind = 'Y' 
		  begin
			select @b_boolean = 0
			RETURN @b_boolean 
		END
	END

select @b_boolean = 1
RETURN @b_boolean  


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

