  if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_copy_participant_from_project_by_role') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_copy_participant_from_project_by_role
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_copy_participant_from_project_by_role
 (@i_fromprojectkey  integer,
  @i_tobookkey integer,
  @i_rolecode integer,
	@i_userid VARCHAR(30),
	@i_copytoprint TINYINT,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_copy_participant_from_project_by_role
**  Desc: This stored procedure copies the participant of the given role from
**				the specified project to the specified book (and optionally, printings
					associated with the specified book)
**  Auth: Dustin Miller
**  Date: 9 June 2017
**
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:         Author:        Description:
**    ----------    --------       -------------------------------------------
**    13 June 2017  Dustin M			 optional copying participant to printings
*******************************************************************************/
	
  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
	DECLARE @v_taqprojectcontactkey INT
	DECLARE @v_newbookcontactkey INT
	DECLARE @v_newtaqprojectcontactkey INT
	DECLARE @v_newtaqprojectcontactrolekey INT
	DECLARE @v_printprojkey INT
	DECLARE @v_printitemtype INT
	DECLARE @v_printusageclass INT

	SET @v_taqprojectcontactkey = NULL
	SELECT TOP 1 @v_taqprojectcontactkey = cr.taqprojectcontactkey
	FROM taqprojectcontactrole cr
	JOIN taqprojectcontact c
	ON cr.taqprojectcontactkey = c.taqprojectcontactkey
	WHERE cr.rolecode = @i_rolecode
	  AND c.taqprojectkey = @i_fromprojectkey

	IF COALESCE(@v_taqprojectcontactkey, 0) > 0
	BEGIN
		DECLARE @DeleteBookContactKeys TABLE
		(
			bookcontactkey INT
		)

		INSERT INTO @DeleteBookContactKeys
		SELECT cr.bookcontactkey
		FROM bookcontactrole cr
		JOIN bookcontact c
		ON cr.bookcontactkey = c.bookcontactkey
		WHERE cr.rolecode = @i_rolecode
			AND c.bookkey = @i_tobookkey

		DELETE FROM bookcontactrole
		WHERE bookcontactkey IN (SELECT bookcontactkey FROM @DeleteBookContactKeys)

		DELETE FROM bookcontact
		WHERE bookcontactkey IN (SELECT bookcontactkey FROM @DeleteBookContactKeys)

		EXEC get_next_key @i_userid, @v_newbookcontactkey OUTPUT

		INSERT INTO bookcontact
		(bookcontactkey, bookkey, printingkey, globalcontactkey, participantnote, keyind, sortorder, lastuserid, lastmaintdate)
		SELECT @v_newbookcontactkey, @i_tobookkey, 1, globalcontactkey, participantnote, keyind, sortorder, @i_userid, GETDATE()
		FROM taqprojectcontact
		WHERE taqprojectcontactkey = @v_taqprojectcontactkey

		INSERT INTO bookcontactrole
		(bookcontactkey, rolecode, activeind, workrate, ratetypecode, departmentcode, lastuserid, lastmaintdate)
		SELECT @v_newbookcontactkey, rolecode, activeind, workrate, ratetypecode, NULL, lastuserid, GETDATE()
		FROM taqprojectcontactrole
		WHERE taqprojectcontactkey = @v_taqprojectcontactkey
		  AND rolecode = @i_rolecode

		IF @i_copytoprint = 1
		BEGIN
			SELECT @v_printitemtype = datacode,
						 @v_printusageclass = datasubcode
			FROM subgentables
			WHERE tableid = 550
			  AND qsicode = 40

			IF EXISTS(SELECT * FROM gentablesitemtype WHERE tableid = 285 AND datacode = @i_rolecode
				AND itemtypecode = @v_printitemtype AND itemtypesubcode = @v_printusageclass)
			BEGIN
				DECLARE print_cur CURSOR FOR
				SELECT taqprojectkey
				FROM taqprojectprinting_view
				WHERE bookkey = @i_tobookkey
        
				OPEN print_cur

				FETCH NEXT FROM print_cur INTO @v_printprojkey
  
				WHILE (@@FETCH_STATUS = 0) 
				BEGIN
					EXEC get_next_key @i_userid, @v_newtaqprojectcontactkey OUTPUT

					INSERT INTO taqprojectcontact
					(taqprojectcontactkey, taqprojectkey, globalcontactkey, participantnote, keyind, sortorder, lastuserid, lastmaintdate)
					SELECT @v_newtaqprojectcontactkey, @v_printprojkey, globalcontactkey, participantnote, keyind, sortorder, @i_userid, GETDATE()
					FROM taqprojectcontact
					WHERE taqprojectcontactkey = @v_taqprojectcontactkey

					EXEC get_next_key @i_userid, @v_newtaqprojectcontactrolekey OUTPUT

					INSERT INTO taqprojectcontactrole
					(taqprojectcontactrolekey, taqprojectcontactkey, taqprojectkey, rolecode, activeind, authortypecode, primaryind, lastuserid, lastmaintdate, 
						workrate, ratetypecode, quantity, shippingmethodcode, indicator)
					SELECT @v_newtaqprojectcontactrolekey, @v_newtaqprojectcontactkey, @v_printprojkey, rolecode, activeind, authortypecode, primaryind, lastuserid, GETDATE(),
						workrate, ratetypecode, quantity, shippingmethodcode, indicator
					FROM taqprojectcontactrole
					WHERE taqprojectcontactkey = @v_taqprojectcontactkey
						AND rolecode = @i_rolecode

					FETCH NEXT FROM print_cur INTO @v_printprojkey
				END

				CLOSE print_cur
				DEALLOCATE print_cur
			END
		END
	END
GO

GRANT EXEC ON qtitle_copy_participant_from_project_by_role TO PUBLIC
GO