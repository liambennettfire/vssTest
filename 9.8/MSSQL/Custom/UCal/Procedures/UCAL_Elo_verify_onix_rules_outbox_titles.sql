/****** Object:  StoredProcedure [dbo].[UCAL_Elo_verify_onix_rules_outbox_titles]    Script Date: 08/06/2014 09:48:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER  PROCEDURE [dbo].[UCAL_Elo_verify_onix_rules_outbox_titles]

AS
BEGIN

/*
Select * FROM bookedistatus
ORDER BY lastmaintdate DESC
*/

DECLARE @bookkey int
DECLARE @i_misckey int
DECLARE @i_titlefetchstatus1 int
DECLARE @c_bnumber varchar(500)


DECLARE c_onix_check CURSOR LOCAL
		FOR

		Select bookkey FROM bookedistatus
		where edistatuscode in (0, 1, 2, 3) --Ask Catherine, only selecting Not Sent, Send Original and Resend. Added 0 on 01-26-12
		

		FOR READ ONLY
				
		OPEN c_onix_check 

		FETCH NEXT FROM c_onix_check 
			INTO  @bookkey
			select  @i_titlefetchstatus1  = @@FETCH_STATUS

					 while (@i_titlefetchstatus1 >-1 )
						begin
							IF (@i_titlefetchstatus1 <>-2) 
							begin
								
									DECLARE @out int
									EXEC dbo.UCAL_Elo_verify_title_in_outbox @bookkey, 6, 'ucal_verify_onix', @out output
									IF @out = 0
										BEGIN
											PRINT 'ISBN ' + dbo.rpt_get_isbn(@bookkey, 17) + ' has been removed from the Outbox' 
										END
									ELSE
										BEGIN
											--get BNnumber
											select @c_bnumber = ISNULL(dbo.UCAL_Get_BNumber_from_bookkey(bookkey),'') FROM book WHERE bookkey = @bookkey
											--get misckey
											select @i_misckey = misckey from bookmiscitems bm join gentables g on bm.eloquencefieldidcode=g.datacode where g.tableid=560 and eloquencefieldtag='DPIDXBIZCWORKKEY'
											
											IF @c_bnumber <> ''
												BEGIN
													IF EXISTS(select * from bookmisc where bookkey=@bookkey and misckey=@i_misckey)
														update bookmisc
														set textvalue =@c_bnumber,lastuserid='Outbox_Preprocess',lastmaintdate=GETDATE(),sendtoeloquenceind=1
														where bookkey=@bookkey and misckey=@i_misckey
													ELSE
														BEGIN
															insert into bookmisc (bookkey,misckey,textvalue,lastuserid,lastmaintdate,sendtoeloquenceind)
															VALUES (@bookkey,@i_misckey,@c_bnumber,'Outbox_Preprocess',GETDATE(),1)
														END
												END
												
											ELSE--If @c_bnumber is blank at this point, then a feed or process may have started to run during the preprocess procedure, and affected the data.
												BEGIN
													PRINT 'BNumber removed during processing. Please check feed processing logs.'
												END
										END
										
							end
							FETCH NEXT FROM c_onix_check
								INTO @bookkey
									select  @i_titlefetchstatus1  = @@FETCH_STATUS
						end
				

	close c_onix_check
	deallocate c_onix_check




END