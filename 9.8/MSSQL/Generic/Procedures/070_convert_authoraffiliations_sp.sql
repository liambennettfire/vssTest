SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[convertauthoraffiliations]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[convertauthoraffiliations]
GO


create proc dbo.convertauthoraffiliations
AS

	DECLARE @v_authorkey								int
	DECLARE @v_affkey 								int
	DECLARE @v_affname  	   						varchar(75)
	DECLARE @v_afftypecode							int
	DECLARE @v_afftitle								varchar(75)
	DECLARE @v_maxid 									int
   DECLARE @i_authorkey		                  int

BEGIN 

	
	DECLARE c_count INSENSITIVE CURSOR
	FOR

		SELECT authorkey, affkey, affname, afftypecode, afftitle
		FROM authoraffiliations  
		FOR READ ONLY

		OPEN c_count 

	
	/* << loop_outer >> */

		FETCH NEXT FROM c_count INTO @v_authorkey, @v_affkey, @v_affname, @v_afftypecode, @v_afftitle 

		SELECT @v_maxid = MAX(globalcontactrelationshipkey) from globalcontactrelationship

		IF @v_maxid IS NULL SET @v_maxid = 0  
		
		select @i_authorkey  = @@FETCH_STATUS

		 while (@i_authorkey>-1 )
			begin
			IF (@i_authorkey<>-2)
				begin

					SELECT @v_maxid = @v_maxid  + 1

					insert into globalcontactrelationship
					(globalcontactrelationshipkey,globalcontactkey1,globalcontactkey2,
                globalcontactname2,contactrelationshipcode1,contactrelationshipcode2,
					 contactrelationshipaddtldesc,keyind, lastuserid,lastmaintdate)
					values (@v_maxid,@v_authorkey,NULL,
                       @v_affname, @v_afftypecode,NULL,
                       @v_afftitle,NULL,'QSIDBA',getdate())
				end
			
			
 			FETCH NEXT FROM c_count INTO @v_authorkey, @v_affkey, @v_affname, @v_afftypecode, @v_afftitle 
	
	    	select @i_authorkey  = @@FETCH_STATUS
	
    	end /*authorkey status status 1*/

  

		close c_count
		deallocate c_count
END
GO

/* Execute the stored procedure */
 exec convertauthoraffiliations 
/*drop proc dbo.convertauthoraffiliations
*/


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

