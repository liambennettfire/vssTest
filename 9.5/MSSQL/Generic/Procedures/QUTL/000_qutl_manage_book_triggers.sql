IF EXISTS (SELECT
		*
	FROM dbo.sysobjects
	WHERE id = OBJECT_ID(N'[dbo].[qutl_manage_book_triggers]')
	AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[qutl_manage_book_triggers]
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qutl_manage_book_triggers] (@i_bookkey INTEGER,
@i_last_maint_date DATETIME,
@i_lastUserId VARCHAR(30))
AS

	/******************************************************************************
	**  File: 000_qutl_manage_book_triggers.sql
	**  Name: qutl_manage_book_triggers
	**  Desc: BookTracker table will maintain all bookkey lastmaintdates for 
	**		  use by any outside process looking for recent updates. This SP
	**		  will be called by triggers placed on key tables.
	**
	**	Triggered tables as of initial creation:
	**		--TitleHistory
	**		--AssociatedTitles
	**		--Book
	**		--BookDetail
	**		--BookSubjectCategory
	**		--Printing
	**		--BookAuthor
	**		--BookPrice
	**		--BookDates
	**		--BookComments
	**		--FileLocation
	**		--TourEvents
	**
	**    Auth: Jon Hess
	**    Date: 
	*******************************************************************************
	**    Change History
	*******************************************************************************
	**    Date:			Author:					Description:
	**    --------		--------				-----------------------------------
	**    7/13/2015		Jon Hess				Case: 33098 Initial Creation
	**    9/25/2015		Jon Hess				Case: 33098 Removed passed row 
	**											 dependency on lastmaintdate and am 
	**											 just filling with getdate() instead
	*******************************************************************************/

	DECLARE @v_existingTrackerId UNIQUEIDENTIFIER

	IF @i_bookkey IS NULL
		OR @i_last_maint_date IS NULL
		OR @i_lastUserId IS NULL
	BEGIN
		SELECT
			'Error: Input parameters incomplete!'
		RETURN
	END
	SELECT
		@v_existingTrackerId = BT.id
	FROM dbo.booktracker BT
	WHERE BT.bookkey = @i_bookkey

	IF @v_existingTrackerId IS NOT NULL
	BEGIN
		--PRINT 'Existing Tracker Row Found'
		UPDATE booktracker
		SET	lastmaintdate = GETDATE(),
			lastuserid = @i_lastUserId
		WHERE id = @v_existingTrackerId
	END
	ELSE
	BEGIN
		--PRINT 'No Previous Tracker Row Found.'
		INSERT INTO booktracker (id,
		bookkey,
		created,
		lastmaintdate,
		lastuserid)
			VALUES (NEWID(), @i_bookkey, GETDATE(), GETDATE(), @i_lastUserId);
	END
GO

GRANT EXECUTE ON [qutl_manage_book_triggers] TO public
GO