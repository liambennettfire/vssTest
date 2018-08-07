GO
/****** Object:  StoredProcedure [dbo].[UCAL_Elo_verify_title_in_outbox]    Script Date: 08/08/2014 16:31:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[UCAL_Elo_verify_title_in_outbox]
(
	 @i_bookkey int,
	 @i_verificationtypecode int,
	 @i_username varchar(15),
	 @Response int OUT --1 for success and 0 for failure
	
)
AS
BEGIN

-- =============================================
-- Author:		Tolga Tuncer 
-- Create date: 04/05/2013
-- Updated 	
-- Description:	<Returns 1 for success and 0 for failure>
-- =============================================

-- THis should not be needed but adding it just in case:
-- Skip if "Never Send"

IF EXISTS (SElect 1 FROM bookedistatus where bookkey = @i_bookkey and edistatuscode = 8)
	BEGIN
		SET @Response = 0 
		RETURN @Response
	END

/*
TEST: 

DECLARE @out int

EXEC dbo.PGI_Is_Onix_Ready 17540104, @out output
Print Cast(@out as char(1))

Select * FROM bookedistatus where edistatuscode in (1,2,3)

Select * FROM book
where bookkey = 17540104

Select * FROM bookedistatus 
WHERE bookkey = 17540104

update bookedistatus
SET edistatuscode = 4
WHERE bookkey = 17540104

Select * FROM bookmisc
where bookkey = 17540104 and misckey = 278

Select * FROM Isbn 
where bookkey = 17540104

Select * FROM titlehistory
where bookkey = 17540104



*/

DECLARE @Failed char(1)
SET @Failed = 'N'


DECLARE @exclude_from_onix char(1)
SET @exclude_from_onix = 'N'

-- run the verification first
EXEC dbo.UCAL_Elo_verify_ONIX @i_bookkey, 1, @i_verificationtypecode, @i_username


-- CHECK THESE HARDCODED verificiation status codes while using this procedure for another client!!!! *****************************
if exists (Select 1 from bookverification where bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode and titleverifystatuscode in (8,9))
	SET @Failed = 'Y'

-- exclude from ONIX 	
if exists (Select 1 from bookverification where bookkey = @i_bookkey and verificationtypecode = @i_verificationtypecode and titleverifystatuscode = 9)
	SET @exclude_from_onix = 'Y'




IF @Failed = 'Y'
		BEGIN

			--If excluded from ONIX, remove the title from outbox by setting the edistatuscode to 7 and also set sendtoeloind to 0 so the red e doesn't appear fo this title in the application
			

			If @exclude_from_onix = 'Y'
				BEGIN	

					Update book
					SET sendtoeloind = 0
					WHERE bookkey = @i_bookkey
		
		
					If exists (Select 1 from bookedistatus where bookkey = @i_bookkey)
						begin
							Update bookedistatus
							SET previousedistatuscode = edistatuscode, edistatuscode = 7, lastuserid = @i_username, lastmaintdate = getdate()
							WHERE bookkey = @i_bookkey
						end
					else
						begin
							insert into bookedistatus 
							select 1, @i_bookkey, 1, 7, @i_username, GETDATE(), 0 
						end
					
					If exists( Select 1 from bookedipartner where bookkey = @i_bookkey)
						begin
							--this will remove from outbox in powerbuilder
							Update bookedipartner
							SET sendtoeloquenceind = 0, lastuserid = @i_username, lastmaintdate = getdate()
							WHERE bookkey = @i_bookkey
						end
					else
						begin
							insert into bookedipartner 
							Select 1, @i_bookkey, 1, @i_username, GETDATE(), 0 
						end

					

				END
			ELSE
				BEGIN
					/* Catherine Toolan: mark the title as edistatuscode=4 and write the appropriate messages to indicate that why it was not sent. 
					By marking it with this edistatuscode you will leave it as an eloquence enabled title (so changes will trigger it to go to the outbox again) but it will not actually get sent until 
					it passes your verification. Every time a change is made to eloquence related data this title will get resent to the outbox. 
					When you run your process this title will  continue to be removed until the missing data is supplied
					*/
					Update bookedistatus
					SET previousedistatuscode = edistatuscode, edistatuscode = 4, lastuserid = @i_username, lastmaintdate = getdate()
					WHERE bookkey = @i_bookkey

					
				END		


			

			--Write a titlehistory record

--NO NEED!!! UPDATING Bookedistatus to 7 writes a history record via triggers
/*
			Insert into titlehistory (bookkey, printingkey, columnkey, lastmaintdate, stringvalue, lastuserid, currentstringvalue, fielddesc)
			Values (@i_bookkey, 1, 104, getdate(), '(Not Present)', 'pgi_onix_verify', '1', 'Title Deactivated From Eloquence')
*/

		END


IF @Failed = 'Y'
	SET @Response = 0
ELSE
	SET @Response = 1


RETURN @Response
END



GRANT ALL ON dbo.UCAL_Elo_verify_title_in_outbox TO PUBLIC 
