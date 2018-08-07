
GO

/****** Object:  StoredProcedure [dbo].[HMH_Elo_PreVerification_Missing_New_Failed_Passed]    Script Date: 07/22/2013 10:15:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HMH_Elo_PreVerification_Missing_New_Failed_Passed]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[HMH_Elo_PreVerification_Missing_New_Failed_Passed]
GO


GO

/****** Object:  StoredProcedure [dbo].[HMH_Elo_PreVerification_Missing_New_Failed_Passed]    Script Date: 07/22/2013 10:15:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create proc [dbo].[HMH_Elo_PreVerification_Missing_New_Failed_Passed]
as begin

--First check to see if any bookkey is missing verification 

Print 'Running missing verification cursor'

DECLARE @bookkey int
Declare @count_i int 
DECLARE @i_titlefetchstatus1 int


DECLARE c_verification_missing CURSOR LOCAL
		FOR

		Select bv.bookkey, COUNT(*) 
		from bookverification bv
		JOIN book b
		ON bv.bookkey = b.bookkey 
		WHERE b.creationdate > '01-01-2012'
		GROUP BY bv.bookkey 
		HAVING COUNT(*) < 4

		


		FOR READ ONLY
				
		OPEN c_verification_missing 

		FETCH NEXT FROM c_verification_missing 
			INTO  @bookkey, @count_i
			select  @i_titlefetchstatus1  = @@FETCH_STATUS

					 while (@i_titlefetchstatus1 >-1 )
						begin
							IF (@i_titlefetchstatus1 <>-2) 
							begin
									if not exists(select 1 FROM bookverification where bookkey = @bookkey and verificationtypecode = 1)
										begin
											insert into bookverification
											Select @bookkey, 1, 5, 'qsiadmin', getdate()
										end

									if not exists(select 1 FROM bookverification where bookkey = @bookkey and verificationtypecode = 2)
										begin
																					insert into bookverification
											Select @bookkey, 2, 5, 'qsiadmin', getdate()
										end

									if not exists(select 1 FROM bookverification where bookkey = @bookkey and verificationtypecode = 3)
										begin
											insert into bookverification
											Select @bookkey, 3, 5, 'qsiadmin', getdate()
										end

									if not exists(select 1 FROM bookverification where bookkey = @bookkey and verificationtypecode = 4)
										begin
											insert into bookverification
											Select @bookkey, 4, 5, 'qsiadmin', getdate()
										end

									if not exists(select 1 FROM bookverification where bookkey = @bookkey and verificationtypecode = 5)
										begin
											insert into bookverification
											Select @bookkey, 5, 5, 'HMH_onix_verify', getdate()
										end

									


									exec verify_eloquence @bookkey, 1, 2, 'qsiadmin'

									exec verify_eloquence @bookkey, 1, 3, 'qsiadmin'

									exec verify_eloquence @bookkey, 1, 4, 'qsiadmin'

									EXEC [dbo].[HMH_Verify_OnixPreverification] @bookkey, 1, 5, 'HMH_onix_verify'
									

									
									--if exists (Select 1 from bookverification where verificationtypecode=5 and titleverifystatuscode in (8,9) and bookkey=@bookkey)
									--begin
									
									--	if Exists(Select 1 from bookmisc where misckey=135 and bookkey =@bookkey)
									--	begin
									--		update bookmisc
									--		set longvalue=0,lastuserid='HMH_ONIX_Verify', lastmaintdate=getdate()
									--		where bookkey=@bookkey and misckey=135
									--	end
									--	else begin
									--		insert into bookmisc(bookkey,misckey,longvalue, lastuserid,lastmaintdate, sendtoeloquenceind)
									--		Select @bookkey,135,0,'HMH_Onix_Verify',getdate(),0
									--	end
									--end
									
									if exists (Select 1 from bookverification where verificationtypecode=5 and titleverifystatuscode =6 and bookkey=@bookkey)
									begin
										if Exists(Select 1 from bookmisc where misckey=131 and bookkey =@bookkey)
										begin
											update bookmisc
											set longvalue=1,lastuserid='HMH_ONIX_Verify', lastmaintdate=getdate()
											where bookkey=@bookkey and misckey=131
										end
										else begin
											insert into bookmisc(bookkey,misckey,longvalue, lastuserid,lastmaintdate, sendtoeloquenceind)
											Select @bookkey,131,1,'HMH_Onix_Verify',getdate(),0
										end
									end

		    
							end
							FETCH NEXT FROM c_verification_missing
								INTO @bookkey, @count_i
									select  @i_titlefetchstatus1  = @@FETCH_STATUS
						end
				

	close c_verification_missing
	deallocate c_verification_missing
	
	
	
end--


GO


