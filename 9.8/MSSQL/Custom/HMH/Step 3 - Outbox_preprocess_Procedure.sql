
GO

/****** Object:  StoredProcedure [dbo].[outbox_preprocess_procedure]    Script Date: 07/22/2013 10:11:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[outbox_preprocess_procedure]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[outbox_preprocess_procedure]
GO


GO

/****** Object:  StoredProcedure [dbo].[outbox_preprocess_procedure]    Script Date: 07/22/2013 10:11:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE Procedure [dbo].[outbox_preprocess_procedure]
( @o_error_code                 int         output
)
AS
set @o_error_code = 1;
--sets up verification table and title sent to hachette record
exec dbo.HMH_Elo_PreVerification_Missing_New_Failed_Passed

--runs the verification
Declare @bookkey int
DECLARE @i_titlefetchstatus1 int
DECLARE c_category CURSOR LOCAL
            FOR
-- Only run this if it was never sent to hachette.        
Select b.bookkey from book b
join bookedistatus d on d.bookkey=b.bookkey where not exists
(Select bookkey from bookmisc where misckey=131 and longvalue=1 and bookkey=b.bookkey)
and standardind ='N' and usageclasscode=1 and sendtoeloind=1
and edistatuscode in (0,1,2,3)
union
select bookkey from bookmisc m 
where misckey=131 and longvalue = 1 and 
not exists(Select 1 from fileprocesscatalog where bookkey = m.bookkey)
and m.bookkey in (Select bookkey from bookedistatus where bookkey in (0,1,2,3))

--0 just in case it gets defaulted to 0
--1 Not Sent
--2 Send Original
--3 Resend


		FOR READ ONLY
            OPEN c_category 
 
            FETCH NEXT FROM c_category 	
				INTO @bookkey
                  select  @i_titlefetchstatus1  = @@FETCH_STATUS
 
                              while (@i_titlefetchstatus1 >-1 )
                                    begin
                                          IF (@i_titlefetchstatus1 <>-2) 
                                          begin
                                          			EXEC [dbo].[HMH_Verify_OnixPreverification] @bookkey, 1, 5, 'HMH_onix_verify'
                                          			--if excluded or failed, update bookedistatus(outbox)
                                          			if exists(Select 1 from bookverification b where bookkey=@bookkey and b.titleverifystatuscode in (8,9) and verificationtypecode=5)
                                          			begin
                                          				update bookedistatus
                                          				set edistatuscode = 7,lastuserid = 'Outbox-Preprocess' --Do Not Send
                                          				where bookkey = @bookkey
                                          			end
                                          			
										  end
                                          FETCH NEXT FROM c_category
                                                INTO @bookkey
                                                      select  @i_titlefetchstatus1  = @@FETCH_STATUS
								     end
                        
 
      close c_category
      deallocate c_category

--
update bookmisc
set sendtoeloquenceind= 1from bookmisc m join fileprocesscatalog f on f.bookkey=m.bookkey
where misckey =131 and longvalue=1 and sendtoeloquenceind=0





GO


