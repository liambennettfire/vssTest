if exists (select * from dbo.sysobjects where id = object_id(N'dbo.LR_Verification_for_Delivery_Master') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.LR_Verification_for_Delivery_Master
GO

/******************************************************************************
**  Name: LR_Verification_for_Delivery_Master
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  02/16/2016   Colman      Case 36373
**  02/25/2016   UK          Case 36664
*******************************************************************************/

CREATE PROCEDURE [dbo].[LR_Verification_for_Delivery_Master](
	@i_bookkey INT
	,@i_printingkey INT
	,@i_verificationtypecode INT
	,@i_username VARCHAR(15)
	)
AS
BEGIN
SET NOCOUNT ON;
	--declare @i_bookkey int,@i_printingkey INT
	--	,@i_verificationtypecode INT
	--	,@i_username VARCHAR(15)
	--		set @i_bookkey=8484258
	--		set @i_printingkey=1
	--		set @i_verificationtypecode=7
	--		set @i_username=''
	DECLARE @i_Lifeway_check INT

	DECLARE @nextkey INT,
	@creationdate DATETIME,
	@creationdatecompare DATETIME,
	@taskkey INT,
	@creationdatecompare2 DATETIME

--set @i_bookkey=7641846
SELECT @creationdate = creationdate
FROM book
WHERE bookkey = @i_bookkey

SET @i_printingkey = 1

				--CREATE creation date task if not exists, UPDATE IF wrong
				IF not exists (select 1 from taqprojecttask where datetypecode=512 and bookkey=@i_bookkey)
				BEGIN
					EXEC dbo.get_next_key 'lr_verification',
						@nextkey OUTPUT

					
					

					--DateAdd(Day, Datediff(Day, 0, GetDate()), 0)
					INSERT INTO taqprojecttask (
						taqtaskkey,
						bookkey,
						scheduleind,
						datetypecode,
						activedate,
						actualind,
						keyind,
						originaldate,
						lastuserid,
						lastmaintdate,
						printingkey,
						reviseddate
						)
					SELECT @nextkey,
						@i_bookkey,
						0,
						512,
						@creationdate,
						1,
						1,
						@creationdate,
						'lr_verification',
						GETDATE(),
						@i_printingkey,
						@creationdate
				END
				ELSE
				BEGIN
					SELECT @taskkey = taqtaskkey
					FROM taqprojecttask
					WHERE datetypecode = 512
						AND bookkey = @i_bookkey

					SELECT @creationdatecompare = originaldate
					FROM taqprojecttask
					WHERE taqtaskkey = @taskkey
					
					select @creationdatecompare2= activedate from taqprojecttask where taqtaskkey=@taskkey

					IF @creationdatecompare <> @creationdate
					or @creationdatecompare2<>@creationdate
						OR EXISTS (
							SELECT 1
							FROM taqprojecttask
							WHERE actualind <> 1
								AND taqtaskkey = @taskkey
							)
						OR EXISTS (
							SELECT 1
							FROM taqprojecttask
							WHERE keyind <> 1
								AND taqtaskkey = @taskkey
							)
					BEGIN
						UPDATE taqprojecttask
						SET activedate = @creationdate,
							keyind = 1,
							actualind = 1,
							lastuserid = 'lr_verification',
							lastmaintdate = GETDATE()
						WHERE taqtaskkey = @taskkey
					END
				END

 

	SELECT @i_Lifeway_check = orgentrykey
	FROM bookorgentry
	WHERE orglevelkey = 2 AND bookkey = @i_bookkey
	
	
DECLARE  @b_unit int

select @b_unit= isnull(longvalue,0) from bookmisc where misckey=267 and bookkey=@i_bookkey

IF @b_unit IS NULL SET @b_unit=0

	IF @i_Lifeway_check not in ( 4028289,4028339,4028341) or @b_unit=1
	BEGIN
		DECLARE @newtitle_creationdate DATETIME

		SET @newtitle_creationdate = '07-26-2000'

		DECLARE @v_Error INT
		DECLARE @v_Warning INT
		DECLARE @v_Information INT
		DECLARE @v_Aborted INT
		DECLARE @v_Completed INT
		DECLARE @v_failed INT
		DECLARE @v_varnings INT
		DECLARE @i_write_msg INT
		DECLARE @v_nextkey INT
		DECLARE @v_Datacode INT
		DECLARE @v_excluded_from_onix INT
		DECLARE @mediatypecode INT, @mediatypesubcode INT
			,@mediatypedesc VARCHAR(10)
		--variables for new procedure
		DECLARE @v_vertypecode_oracle INT
		DECLARE @v_vertypecode_dev INT
		DECLARE @v_vertypecode_prod INT
		DECLARE @v_failed_oracle INT
		DECLARE @v_failed_dev INT
		DECLARE @v_failed_prod INT
		DECLARE @v_varnings_oracle INT
		DECLARE @v_varnings_dev INT
		DECLARE @v_varnings_prod INT
		DECLARE @PRICELIST INT
		DECLARE @CURRTYPE INT
		DECLARE @maxlastmaintdate DATETIME

		--Declare @d_creationdate datetime
		--Declare @d_sendtooraclestatusdate datetime
		----declare @i_bookkey int
		----set @i_bookkey = 8040545
		--select @d_creationdate = creationdate from book where bookkey = @i_bookkey 
		--select @d_sendtooraclestatusdate = lastmaintdate from bookmisc where bookkey = @i_bookkey and misckey = 59
		--set @d_creationdate = DATEADD(minute,1,@d_creationdate)
		----select @d_creationdate, @d_sendtooraclestatusdate
		--if @d_creationdate > @d_sendtooraclestatusdate
		--BEGIN
		--	update bookmisc set longvalue = null where bookkey = @i_bookkey and misckey = 59
		--END
		--select * from bookmisc where misckey = 59 and bookkey = 8040545
		--select * from book where title = 'test'
		SET @v_Error = 2
		SET @v_Warning = 3
		SET @v_Information = 4
		SET @v_Aborted = 5
		SET @v_Completed = 6
		
		--set the verification type datacodes
		SET @v_vertypecode_oracle = 7
		SET @v_vertypecode_dev = 8
		SET @v_vertypecode_prod = 9
		
		
		SET @v_failed_oracle = 0
		SET @v_failed_dev = 0
		SET @v_failed_prod = 0
		SET @v_failed = 0
		
		
		SET @v_varnings_oracle = 0
		SET @v_varnings_dev = 0
		SET @v_varnings_prod = 0
		SET @v_varnings = 0

		--clean bookverificationmessage for passed bookkey
		delete bookverificationmessage
		where bookkey = @i_bookkey
		and verificationtypecode IN (7, 8, 9, 10)

		IF @i_verificationtypecode IN (7, 8, 9, 10)
		BEGIN
			SET @i_verificationtypecode = 10
		END

		SELECT @mediatypecode = mediatypecode,@mediatypesubcode=mediatypesubcode
		FROM bookdetail
		WHERE bookkey = @i_bookkey
		
		

		SELECT @mediatypedesc = convert(varchar(10),LEFT(gentext1,3))
		FROM subgentables_ext
		WHERE tableid = 312 AND datacode = @mediatypecode and datasubcode=@mediatypesubcode
		--clean bookverificationmessage for passed bookkey
		DELETE bookverificationmessage
		WHERE bookkey = @i_bookkey AND verificationtypecode IN (@v_vertypecode_dev, @v_vertypecode_oracle, @v_vertypecode_prod, @i_verificationtypecode)


		
		IF NOT EXISTS (select 1 from bookmisc where misckey=59 and bookkey=@i_bookkey)
		BEGIN
		insert into bookmisc (bookkey,misckey,longvalue,lastuserid,lastmaintdate,sendtoeloquenceind)
		values (@i_bookkey,59,3,'LW_Verification',GETDATE(),0)
		END
		
--add columns inserts here
		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Price_exp_future'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Price_exp_future'
				,1
				,'qsidba'
				,GETDATE()
		END
		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Price_eff_future'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Price_eff_future'
				,1
				,'qsidba'
				,GETDATE()
		END
		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Units_Of_Measure'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Units_Of_Measure'
				,1
				,'qsidba'
				,GETDATE()
		END
		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Series'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Series'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Title_Prefix'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Title_Prefix'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Title'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Title'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Subtitle'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Subtitle'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_System_Title'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_System_Title'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Publisher_link'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Publisher_link'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Imprint'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Imprint'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Edition_Type'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Edition_Type'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_#'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_#'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Addtl_Edition_Info'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Addtl_Edition_Info'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Vol_______of______'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Vol_______of______'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_EAN/ISBN13'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_EAN/ISBN13'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Item_#_view_only'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Item_#_view_only'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Pub_Month'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Pub_Month'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Year'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Year'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Season'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Season'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Season_Actual'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Season_Actual'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Actual'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Actual'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Actual'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Actual'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Author'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Author'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_part_Key'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_part_Key'
				,1
				,'qsidba'
				,GETDATE()
		END
		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_part_NO_key'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_part_NO_key'
				,1
				,'qsidba'
				,GETDATE()
		END
		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Business_Unit'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Business_Unit'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Ministry_Area'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Ministry_Area'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Sales_Class_Code'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Sales_Class_Code'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Product_Group_Segment'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Product_Group_Segment'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Master_Brand'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Master_Brand'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Category'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Category'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Subcategory'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Subcategory'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Solution_Family'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Solution_Family'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Solution_Target'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Solution_Target'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Product_Line'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Product_Line'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Product_Type'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Product_Type'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Product_Use'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Product_Use'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Copies_of_Proforma_Available'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Copies_of_Proforma_Available'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_QR_Code_Needed'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_QR_Code_Needed'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Content_Issue'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Content_Issue'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Curriculum_Quarter'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Curriculum_Quarter'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Bulletin_Type'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Bulletin_Type'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Primary_Cross_Reference'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Primary_Cross_Reference'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'Primary_Cross_Reference'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'Primary_Cross_Reference'
				,1
				,'qsidba'
				,GETDATE()
		END
		
		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Royalty_Item'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Royalty_Item'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Interior_Spread'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Interior_Spread'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Sample_Chapters_Needed'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Sample_Chapters_Needed'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Budget'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Budget'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Final'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Final'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Active'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Active'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Sort'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Sort'
				,1
				,'qsidba'
				,GETDATE()
		END

		--IF NOT EXISTS (
		--		SELECT 1
		--		FROM dbo.bookverificationcolumns
		--		WHERE columnname = 'LW_Send_to_Oracle_Status'
		--		)
		--BEGIN
		--	INSERT INTO dbo.bookverificationcolumns (
		--		columnname
		--		,activeind
		--		,lastmaintuserid
		--		,lastmaintdate
		--		)
		--	SELECT 'LW_Send_to_Oracle_Status'
		--		,1
		--		,'qsidba'
		--		,GETDATE()
		--END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Item_Type'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Item_Type'
				,1
				,'qsidba'
				,GETDATE()
		END


		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Responsibilty_Center'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Responsibilty_Center'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Sales_Class_Code'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Sales_Class_Code'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Product_Group_Segment'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Product_Group_Segment'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Title_Type'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Title_Type'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_System_Title__Long'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_System_Title__Long'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Inventory_Organization_Code'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Inventory_Organization_Code'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_LWX_Tax_Override_Category'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_LWX_Tax_Override_Category'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_COGS_Account'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_COGS_Account'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Sales_Account'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Sales_Account'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Harmonization_Code'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Harmonization_Code'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Medium'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Medium'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Media_Type'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Media_Type'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Media_Type_2'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Media_Type_2'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Web_Enabled_Indicator'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Web_Enabled_Indicator'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Demand_Print_Indicator'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Demand_Print_Indicator'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Multiple_Order_Quantity'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Multiple_Order_Quantity'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_PO_Major'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_PO_Major'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_PO_Minor'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_PO_Minor'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Pub_Date'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Pub_Date'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Product_Form'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Product_Form'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Product_Form_Detail'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Product_Form_Detail'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Number_of_Sessions'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Number_of_Sessions'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Session_Number'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Session_Number'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Product_Packaging_Type'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Product_Packaging_Type'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Package_Quantity'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Package_Quantity'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_New_Typesetting_Needed'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_New_Typesetting_Needed'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Trim_Size_for_specs'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Trim_Size_for_specs'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Country_of_Origin'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Country_of_Origin'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Digital_Indicator'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Digital_Indicator'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Product_Dimension_Descriptive'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Product_Dimension_Descriptive'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Sample_Chapters_/_Samplers_Available'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Sample_Chapters_/_Samplers_Available'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Cover_Approved_for_Distribution'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Cover_Approved_for_Distribution'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Cover_Available_in_Covers_Database'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Cover_Available_in_Covers_Database'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Final_Financial_Approval'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Final_Financial_Approval'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Final_Financial_Approval_Date'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Final_Financial_Approval_Date'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Title_Final'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Title_Final'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Subtitle_Final'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Subtitle_Final'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Full_Description_AE/Author_Approved'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Full_Description_AE/Author_Approved'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Endorsements'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Endorsements'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_12_Month_Proforma_Forecast_Net_Units'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_12_Month_Proforma_Forecast_Net_Units'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Accounting_Rule_ID'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Accounting_Rule_ID'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Invoicing_Rule_ID'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Invoicing_Rule_ID'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Send_to_Oracle_Override'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Send_to_Oracle_Override'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_BISAC_Status'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_BISAC_Status'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Product_Availability'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Product_Availability'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Internal_Status'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Internal_Status'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Expected_Ship_Date'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Expected_Ship_Date'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Release_Quantity'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Release_Quantity'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Release_Quantity_Actual'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Release_Quantity_Actual'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Announced_1st_Prtg'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Announced_1st_Prtg'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Announced_1st_Prtg_Actual'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Announced_1st_Prtg_Actual'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Carton_Quantity'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Carton_Quantity'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Media'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Media'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_#_of_Audio_Units'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_#_of_Audio_Units'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Total_Run_Time'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Total_Run_Time'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Page_Count'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Page_Count'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Page_Count_Actual'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Page_Count_Actual'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Insert_/_Illus.'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Insert_/_Illus.'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Insert_/_Illus._Actual'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Insert_/_Illus._Actual'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Format'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Format'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Other_Format'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Other_Format'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Trim_w_x_l'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Trim_w_x_l'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Product_Size_Actual'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Product_Size_Actual'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Spine_Size'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Spine_Size'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Weight'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Weight'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Barcode_multiple_entry'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Barcode_multiple_entry'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Advance_Copy_Code'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Advance_Copy_Code'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Return_Status'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Return_Status'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Return_Flag'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Return_Flag'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Auto_Release'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Auto_Release'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Minimum_Order_Quantity'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Minimum_Order_Quantity'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Number_of_Backorder_Days'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Number_of_Backorder_Days'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Obsolescence_Date'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Obsolescence_Date'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_ISRC'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_ISRC'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_LWW_Version_#'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_LWW_Version_#'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Duration'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Duration'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Voicing'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Voicing'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Genre'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Genre'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Time_Signature'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Time_Signature'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Tempo'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Tempo'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Keys'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Keys'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_#_of_Selections/Songs'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_#_of_Selections/Songs'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Music_Series'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Music_Series'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Difficulty_Level'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Difficulty_Level'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Credits'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Credits'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Song_Copyright'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Song_Copyright'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Scripture_Tags'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Scripture_Tags'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Thematic_Tags'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Thematic_Tags'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Audience_Role'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Audience_Role'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Brief_Description_Final_/_Approved'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Brief_Description_Final_/_Approved'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Marketing_Plan_Available'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Marketing_Plan_Available'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Promo_Videos_Available'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Promo_Videos_Available'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Send_to_Eloquence'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Send_to_Eloquence'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Never_Send_to_Eloquence'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Never_Send_to_Eloquence'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Customer'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Customer'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_CHO_Age_Group'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_CHO_Age_Group'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_CHO_Product_Family'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_CHO_Product_Family'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_CHO_Format'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_CHO_Format'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_CHO_Bundled_By'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_CHO_Bundled_By'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_CHO_Translation'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_CHO_Translation'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_CHO_Variant_Translation'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_CHO_Variant_Translation'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_CHO_Language'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_CHO_Language'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Order_Form_ID'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Order_Form_ID'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Order_Form_Ref_ID'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Order_Form_Ref_ID'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Order_Form_Discount_Indicator'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Order_Form_Discount_Indicator'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_CHO_Category_Sort_ID'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_CHO_Category_Sort_ID'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_CHO_Item_Sort_ID'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_CHO_Item_Sort_ID'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_ETB_Age_Group'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_ETB_Age_Group'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_BSFL_Age_Group'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_BSFL_Age_Group'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_TGP_Age_Group'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_TGP_Age_Group'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Setting'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Setting'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Renewal_Frequency'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Renewal_Frequency'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Contract_Term_Frequency'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Contract_Term_Frequency'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Auto_Renew'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Auto_Renew'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Payment_Frequency'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Payment_Frequency'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Maximum_License_Seats'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Maximum_License_Seats'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Minimum_License_Seats'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Minimum_License_Seats'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Release_to_Trade_Partners'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Release_to_Trade_Partners'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Release_to_Trade_Website'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Release_to_Trade_Website'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Returnable_from_Trade'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Returnable_from_Trade'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Trade_Discount'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Trade_Discount'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Full_Trade_Title'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Full_Trade_Title'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Trade_Description'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Trade_Description'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_ASIN'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_ASIN'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Title_Territory'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Title_Territory'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Exclusivity'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Exclusivity'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Supply_to_Region'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Supply_to_Region'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Discount'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Discount'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Restrictions'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Restrictions'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Copyright_Year'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Copyright_Year'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Type'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Type'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Returns'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Returns'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Derive_from_Contract'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Derive_from_Contract'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Publish_to_Web'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Publish_to_Web'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Age_Range'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Age_Range'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Grade_Range_______to________'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Grade_Range_______to________'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Language'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Language'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Legacy_Territory'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Legacy_Territory'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Origin'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Origin'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Audience'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Audience'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Apple_Release_Type'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Apple_Release_Type'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Apple_ID'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Apple_ID'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_License_Assignment_Type'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_License_Assignment_Type'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_License_Type'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_License_Type'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_License_Expire_Days'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_License_Expire_Days'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_BISAC_Subjects'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_BISAC_Subjects'
				,1
				,'qsidba'
				,GETDATE()
		END

		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_MK_FINAL_Online_Copy_Description_Long'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_MK_FINAL_Online_Copy_Description_Long'
				,1
				,'qsidba'
				,GETDATE()
		END
		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Price_exp'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Price_exp'
				,1
				,'qsidba'
				,GETDATE()
		END
		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Price_msrp'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Price_msrp'
				,1
				,'qsidba'
				,GETDATE()
				
		END
		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_UOM_Freq'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_UOM_Freq'
				,1
				,'qsidba'
				,GETDATE()
				
		END
		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Price_Date_gap'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Price_Date_gap'
				,1
				,'qsidba'
				,GETDATE()
				
		END
		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Price_Date_backwards'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Price_Date_backwards'
				,1
				,'qsidba'
				,GETDATE()
				
		END
		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_PrimaryUOM_Itemtype_Submast'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_PrimaryUOM_Itemtype_Submast'
				,1
				,'qsidba'
				,GETDATE()
				
		END
		IF NOT EXISTS (
				SELECT 1
				FROM dbo.bookverificationcolumns
				WHERE columnname = 'LW_Price_eff_mustexist'
				)
		BEGIN
			INSERT INTO dbo.bookverificationcolumns (
				columnname
				,activeind
				,lastmaintuserid
				,lastmaintdate
				)
			SELECT 'LW_Price_eff_mustexist'
				,1
				,'qsidba'
				,GETDATE()
				
		END

		--insert check statments here
		
	
  --When final price is not null, then effective date must exist
		exec bookverification_check 'LW_Price_eff_mustexist', @i_write_msg output
		if @i_write_msg = 1 
		begin
			if @i_verificationtypecode = 10 
				begin
					IF	Exists (select 1 from bookprice where isnull(effectivedate,'')='' and isnull(cast(finalprice as varchar(250)),'')<>'' and bookkey=@i_bookkey)
									
				 
					begin
									EXEC get_next_key @i_username,
						@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@i_verificationtypecode,
						@v_Error,
'When a final price is declared, an effective date must also be defined. Please add an effective date.',						
						@i_username,
						getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@v_vertypecode_dev,
						@v_Error,
'When a final price is declared, an effective date must also be defined. Please add an effective date.',						@i_username,
						getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@v_vertypecode_prod,
						@v_Error,
'When a final price is declared, an effective date must also be defined. Please add an effective date.',						@i_username,
						getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@v_vertypecode_oracle,
						@v_Error,
'When a final price is declared, an effective date must also be defined. Please add an effective date.',						@i_username,
						getdate()
						)

					SET @v_failed_oracle = 1
					end 
				end
		end	
	
 --Itemtype, Freq, Primary Unit of Measure
		EXEC bookverification_check 'LW_PrimaryUOM_Itemtype_Submast',
	@i_write_msg OUTPUT

	IF @i_write_msg = 1
	BEGIN
		IF @i_verificationtypecode = 10
				begin
					IF
					
				 dbo.rpt_get_misc_value (@i_bookkey,427,'external')<>'EA' -- Primary Unit of Measure
				 AND (
				 dbo.rpt_get_misc_value (@i_bookkey,407,'external')<>'Y'  -- Subscription Master Type
				OR
				 dbo.rpt_get_misc_value(@i_bookkey,56,'external') not in ('LWDATESUB','LWSUBMAST','LWCLUB')
				 )  --Item Type
					begin
						EXEC get_next_key @i_username,
						@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@i_verificationtypecode,
						@v_Error,
'When Item Type not in ( LW SUBSCRIPTION MASTER , LW DATED SUB or LW CLUB ) or Subscription Master is not ''Y'' , then Primary Unit of Measure must be equal to ''Each (EA)''',						@i_username,
						getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@v_vertypecode_dev,
						@v_Error,
'When Item Type not in ( LW SUBSCRIPTION MASTER , LW DATED SUB or LW CLUB ) or Subscription Master is not ''Y'' , then Primary Unit of Measure must be equal to ''Each (EA)''',						@i_username,
						getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@v_vertypecode_prod,
						@v_Error,
'When Item Type not in ( LW SUBSCRIPTION MASTER , LW DATED SUB or LW CLUB ) or Subscription Master is not ''Y'' , then Primary Unit of Measure must be equal to ''Each (EA)''',						@i_username,
						getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@v_vertypecode_oracle,
						@v_Error,
'When Item Type not in ( LW SUBSCRIPTION MASTER , LW DATED SUB or LW CLUB ) or Subscription Master is not ''Y'' , then Primary Unit of Measure must be equal to ''Each (EA)''',						@i_username,
						getdate()
						)

					SET @v_failed_oracle = 1
					end 
				end
		end	
		
		
		
	--			EXEC bookverification_check 'LW_Price_exp_future',
	--@i_write_msg OUTPUT

	--IF @i_write_msg = 1
	--BEGIN
	--	IF @i_verificationtypecode = 10
	--	BEGIN

							
	--			IF exists (select 1 from bookprice 
	--			where expirationdate<DateAdd(Day, Datediff(Day, 0, lastmaintdate), 0) 
	--			and bookkey=@i_bookkey 
	--			AND lastuserid NOT LIKE '%Price_Import%' and lastmaintdate > DateAdd(Day, Datediff(Day, 0, GETDATE()), 0) - 1 --this will be the hard code for EDH golive date
	--			)
	--		BEGIN
			
	--				EXEC get_next_key @i_username,
	--					@v_nextkey OUT /*Delivery*/

	--				INSERT INTO bookverificationmessage
	--				VALUES (
	--					@v_nextkey,
	--					@i_bookkey,
	--					@i_verificationtypecode,
	--					@v_Error,
	--				'Price expiration date needs to either be today or in the future.',
	--					@i_username,
	--					getdate()
	--					)

	--				SET @v_failed = 1

	--				EXEC get_next_key @i_username,
	--					@v_nextkey OUT /*Development*/

	--				INSERT INTO bookverificationmessage
	--				VALUES (
	--					@v_nextkey,
	--					@i_bookkey,
	--					@v_vertypecode_dev,
	--					@v_Error,
	--				'Price expiration date needs to either be today or in the future.',
	--					@i_username,
	--					getdate()
	--					)

	--				SET @v_failed_dev = 1

	--				EXEC get_next_key @i_username,
	--					@v_nextkey OUT /*Production*/

	--				INSERT INTO bookverificationmessage
	--				VALUES (
	--					@v_nextkey,
	--					@i_bookkey,
	--					@v_vertypecode_prod,
	--					@v_Error,
	--				'Price expiration date needs to either be today or in the future.',
	--					@i_username,
	--					getdate()
	--					)

	--				SET @v_failed_prod = 1

	--				EXEC get_next_key @i_username,
	--					@v_nextkey OUT /*Oracle*/

	--				INSERT INTO bookverificationmessage
	--				VALUES (
	--					@v_nextkey,
	--					@i_bookkey,
	--					@v_vertypecode_oracle,
	--					@v_Error,
	--				'Price expiration date needs to either be today or in the future.',
	--					@i_username,
	--					getdate()
	--					)

	--				SET @v_failed_oracle = 1
				
	--		END
	--	END
	--END
		
		
		
		
	--			EXEC bookverification_check 'LW_Price_eff_future',
	--@i_write_msg OUTPUT

	--IF @i_write_msg = 1
	--BEGIN
	--	IF @i_verificationtypecode = 10
	--	BEGIN
			
	--		DECLARE @pricect INT
	--		SELECT @pricect = count(pricekey) from bookprice where bookkey = @i_bookkey group by pricetypecode, currencytypecode
	--		IF @pricect > 1
			
	--		BEGIN
							
	--			IF exists (select 1 from bookprice 
	--			where effectivedate<DateAdd(Day, Datediff(Day, 0, lastmaintdate), 0) +1
	--			and bookkey=@i_bookkey 
	--			AND lastuserid NOT LIKE '%Price_Import%' and lastmaintdate > DateAdd(Day, Datediff(Day, 0, GETDATE()), 0) - 1 --this will be the hard code for EDH golive date
	--			)
	--		BEGIN
			
	--				EXEC get_next_key @i_username,
	--					@v_nextkey OUT /*Delivery*/

	--				INSERT INTO bookverificationmessage
	--				VALUES (
	--					@v_nextkey,
	--					@i_bookkey,
	--					@i_verificationtypecode,
	--					@v_Error,
	--				'Price effective date needs to be in the future.',
	--					@i_username,
	--					getdate()
	--					)

	--				SET @v_failed = 1

	--				EXEC get_next_key @i_username,
	--					@v_nextkey OUT /*Development*/

	--				INSERT INTO bookverificationmessage
	--				VALUES (
	--					@v_nextkey,
	--					@i_bookkey,
	--					@v_vertypecode_dev,
	--					@v_Error,
	--				'Price effective date needs to be in the future.',
	--					@i_username,
	--					getdate()
	--					)

	--				SET @v_failed_dev = 1

	--				EXEC get_next_key @i_username,
	--					@v_nextkey OUT /*Production*/

	--				INSERT INTO bookverificationmessage
	--				VALUES (
	--					@v_nextkey,
	--					@i_bookkey,
	--					@v_vertypecode_prod,
	--					@v_Error,
	--				'Price effective date needs to be in the future.',
	--					@i_username,
	--					getdate()
	--					)

	--				SET @v_failed_prod = 1

	--				EXEC get_next_key @i_username,
	--					@v_nextkey OUT /*Oracle*/

	--				INSERT INTO bookverificationmessage
	--				VALUES (
	--					@v_nextkey,
	--					@i_bookkey,
	--					@v_vertypecode_oracle,
	--					@v_Error,
	--				'Price effective date needs to be in the future.',
	--					@i_username,
	--					getdate()
	--					)

	--				SET @v_failed_oracle = 1
				
	--		END
	--		END
		
		
	--	IF @pricect = 1
	--	BEGIN
		
	--			IF exists (select 1 from bookprice 
	--			where effectivedate<DateAdd(Day, Datediff(Day, 0, lastmaintdate), 0)
	--			and bookkey=@i_bookkey 
	--			AND lastuserid NOT LIKE '%Price_Import%' and lastmaintdate > DateAdd(Day, Datediff(Day, 0, GETDATE()), 0) - 1 --this will be the hard code for EDH golive date
	--			)
	--			BEGIN
			
	--				EXEC get_next_key @i_username,
	--					@v_nextkey OUT /*Delivery*/

	--				INSERT INTO bookverificationmessage
	--				VALUES (
	--					@v_nextkey,
	--					@i_bookkey,
	--					@i_verificationtypecode,
	--					@v_Error,
	--				'Price effective date needs to be today or in the future.',
	--					@i_username,
	--					getdate()
	--					)

	--				SET @v_failed = 1

	--				EXEC get_next_key @i_username,
	--					@v_nextkey OUT /*Development*/

	--				INSERT INTO bookverificationmessage
	--				VALUES (
	--					@v_nextkey,
	--					@i_bookkey,
	--					@v_vertypecode_dev,
	--					@v_Error,
	--				'Price effective date needs to be today or in the future.',
	--					@i_username,
	--					getdate()
	--					)

	--				SET @v_failed_dev = 1

	--				EXEC get_next_key @i_username,
	--					@v_nextkey OUT /*Production*/

	--				INSERT INTO bookverificationmessage
	--				VALUES (
	--					@v_nextkey,
	--					@i_bookkey,
	--					@v_vertypecode_prod,
	--					@v_Error,
	--				'Price effective date needs to be today or in the future.',
	--					@i_username,
	--					getdate()
	--					)

	--				SET @v_failed_prod = 1

	--				EXEC get_next_key @i_username,
	--					@v_nextkey OUT /*Oracle*/

	--				INSERT INTO bookverificationmessage
	--				VALUES (
	--					@v_nextkey,
	--					@i_bookkey,
	--					@v_vertypecode_oracle,
	--					@v_Error,
	--				'Price effective date needs to be today or in the future.',
	--					@i_username,
	--					getdate()
	--					)

	--				SET @v_failed_oracle = 1
		
	--			END
	--	END
	--END
	--END
		
		
		
		
		
		
		
		
	--Find prices that have effective dates before there expiration dates
		
				EXEC bookverification_check 'LW_Price_Date_backwards',
	@i_write_msg OUTPUT

	IF @i_write_msg = 1
	BEGIN
		IF @i_verificationtypecode = 10
		BEGIN

							
				IF EXISTS (select 1 from bookprice where effectivedate>expirationdate and bookkey=@i_bookkey)
			BEGIN
			
					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@i_verificationtypecode,
						@v_Error,
					'Price Effective Date and Expiration Date Error. Effective date on a price occurs before the expiration date.',
						@i_username,
						getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@v_vertypecode_dev,
						@v_Error,
					'Price Effective Date and Expiration Date Error. Effective date on a price occurs before the expiration date.',
						@i_username,
						getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@v_vertypecode_prod,
						@v_Error,
					'Price Effective Date and Expiration Date Error. Effective date on a price occurs before the expiration date.',
						@i_username,
						getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@v_vertypecode_oracle,
						@v_Error,
					'Price Effective Date and Expiration Date Error. Effective date on a price occurs before the expiration date.',
						@i_username,
						getdate()
						)

					SET @v_failed_oracle = 1
				
			END
		END
	END
		
		
--				 --Detect gaps in price start and end dates
		
--				EXEC bookverification_check 'LW_Price_Date_gap',
--	@i_write_msg OUTPUT

--	IF @i_write_msg = 1
--	BEGIN
--		IF @i_verificationtypecode = 10
--		BEGIN

							
--				IF EXISTS (
--									SELECT  bookkey,
--									pricetypecode,
--									currencytypecode,
--									expirationdate,
--									NextDate,
--									DATEDIFF("D", expirationdate, NextDate) as datedifference
							        
							        
--							FROM    (   SELECT  bookkey, 
--												pricetypecode,
--												currencytypecode,
--												expirationdate,
--												(   SELECT  MIN(effectivedate) 
--													FROM    bookprice T2
--													WHERE   T2.bookkey=T1.bookkey 
--													AND		T2.pricetypecode = T1.pricetypecode
--													AND		T2.currencytypecode= T1.currencytypecode
--													AND     T2.effectivedate > T1.expirationdate
--													AND  T1.effectivedate<> T2.effectivedate
--												) AS NextDate
--										FROM    bookprice T1
--									) AS T
--									where NextDate is not null 
--								  and t.bookkey=@i_bookkey  
--									and DATEDIFF("D", expirationdate, NextDate) >1
--									)
--			BEGIN
			
--					EXEC get_next_key @i_username,
--						@v_nextkey OUT /*Delivery*/

--					INSERT INTO bookverificationmessage
--					VALUES (
--						@v_nextkey,
--						@i_bookkey,
--						@i_verificationtypecode,
--						@v_Error,
--'Price Date Gap Detected. There is more than 1 day in between a price''s expiration date and next effective date. Please update price effective and expiration dates so dates are within 1 day of each other.',						@i_username,
--						getdate()
--						)

--					SET @v_failed = 1

--					EXEC get_next_key @i_username,
--						@v_nextkey OUT /*Development*/

--					INSERT INTO bookverificationmessage
--					VALUES (
--						@v_nextkey,
--						@i_bookkey,
--						@v_vertypecode_dev,
--						@v_Error,
--'Price Date Gap Detected. There is more than 1 day in between a price''s expiration date and next effective date. Please update price effective and expiration dates so dates are within 1 day of each other.',						@i_username,
--						getdate()
--						)

--					SET @v_failed_dev = 1

--					EXEC get_next_key @i_username,
--						@v_nextkey OUT /*Production*/

--					INSERT INTO bookverificationmessage
--					VALUES (
--						@v_nextkey,
--						@i_bookkey,
--						@v_vertypecode_prod,
--						@v_Error,
--'Price Date Gap Detected. There is more than 1 day in between a price''s expiration date and next effective date. Please update price effective and expiration dates so dates are within 1 day of each other.',						@i_username,
--						getdate()
--						)

--					SET @v_failed_prod = 1

--					EXEC get_next_key @i_username,
--						@v_nextkey OUT /*Oracle*/

--					INSERT INTO bookverificationmessage
--					VALUES (
--						@v_nextkey,
--						@i_bookkey,
--						@v_vertypecode_oracle,
--						@v_Error,
--'Price Date Gap Detected. There is more than 1 day in between a price''s expiration date and next effective date. Please update price effective and expiration dates so dates are within 1 day of each other.',						@i_username,
--						getdate()
--						)

--					SET @v_failed_oracle = 1
				
--			END
--		END
--	END
			
		
		
		
		
--CHECK item type, primary unit of measure, and publication freq
				EXEC bookverification_check 'LW_UOM_Freq',
	@i_write_msg OUTPUT

	IF @i_write_msg = 1
	BEGIN
		IF @i_verificationtypecode = 10
		BEGIN

							
				IF
				dbo.rpt_get_misc_value (@i_bookkey,427,'external')<>'EA'
				and dbo.rpt_get_misc_value(@i_bookkey,56,'external')='LWSUBMAST'
				and dbo.rpt_get_misc_value(@i_bookkey,399,'short')<> dbo.rpt_get_misc_value(@i_bookkey,427,'short')
			BEGIN
			
					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@i_verificationtypecode,
						@v_Error,
					'When item type = LW SUBSCRIPTION MASTER and Primary Unit of Measure is not equal to Each (EA), then Primary Unit of Measure must equal Publication Frequency',
						@i_username,
						getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@v_vertypecode_dev,
						@v_Error,
					'When item type = LW SUBSCRIPTION MASTER and Primary Unit of Measure is not equal to Each (EA), then Primary Unit of Measure must equal Publication Frequency',
						@i_username,
						getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@v_vertypecode_prod,
						@v_Error,
					'When item type = LW SUBSCRIPTION MASTER and Primary Unit of Measure is not equal to Each (EA), then Primary Unit of Measure must equal Publication Frequency',
						@i_username,
						getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@v_vertypecode_oracle,
						@v_Error,
					'When item type = LW SUBSCRIPTION MASTER and Primary Unit of Measure is not equal to Each (EA), then Primary Unit of Measure must equal Publication Frequency',
						@i_username,
						getdate()
						)

					SET @v_failed_oracle = 1
				
			END
		END
	END
		
		
		
		EXEC bookverification_check 'LW_Price_msrp',
	@i_write_msg OUTPUT

	IF @i_write_msg = 1
	BEGIN
		IF @i_verificationtypecode = 10
		BEGIN
			DECLARE @i_msrp_ct INT

			IF dbo.rpt_get_misc_value(@i_bookkey, 56, 'external') IN (
					'LWDATESUB',
					'LWSUBMAST'
					)
			BEGIN
				SELECT @i_msrp_ct = count(pricekey)
				FROM bookprice
				WHERE bookkey = @i_bookkey
					AND pricetypecode = 8

				IF @i_msrp_ct > 0
				BEGIN
					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@i_verificationtypecode,
						@v_Error,
						'MSRP Found on product with item type in (LW SUBSCRIPTION MASTER , LW DATED SUB). MSRP Not allowed on these item types',
						@i_username,
						getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@v_vertypecode_dev,
						@v_Error,
						'MSRP Found on product with item type in (LW SUBSCRIPTION MASTER , LW DATED SUB). MSRP Not allowed on these item types',
						@i_username,
						getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@v_vertypecode_prod,
						@v_Error,
						'MSRP Found on product with item type in (LW SUBSCRIPTION MASTER , LW DATED SUB). MSRP Not allowed on these item types',
						@i_username,
						getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@v_vertypecode_oracle,
						@v_Error,
						'MSRP Found on product with item type in (LW SUBSCRIPTION MASTER , LW DATED SUB). MSRP Not allowed on these item types',
						@i_username,
						getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END
	END

		
		--PRICE VERIFIATION CAN BE BYPASSED WITH misc CHECK BOX QSICODE 22
	/*			
		EXEC bookverification_check 'LW_Price_exp',
	@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				

				IF NOT EXISTS (
						SELECT 1
						FROM bookmisc
						WHERE misckey = (
								SELECT misckey
								FROM bookmiscitems
								WHERE qsicode = 22
								)
							AND bookkey = @i_bookkey
							AND longvalue = 1
						)
				BEGIN
					IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL
						DROP TABLE #TEMP

					SELECT pricetypecode,
						currencytypecode,
						count(1) AS counter
					INTO #TEMP
					FROM bookprice
					WHERE bookkey = @i_bookkey
						AND lastmaintdate > DateAdd(Day, Datediff(Day, 0, GETDATE()), 0) - 1 --this will be the hard code for EDH golive date
					GROUP BY pricetypecode,
						currencytypecode

					SELECT TOP 1 @PRICELIST = pricetypecode,
						@CURRTYPE = currencytypecode
					FROM #TEMP
					ORDER BY pricetypecode DESC

					WHILE EXISTS (
							SELECT 1
							FROM #TEMP
							)
					BEGIN
						IF (
								SELECT counter
								FROM #TEMP
								WHERE pricetypecode = @PRICELIST
									AND currencytypecode = @CURRTYPE
								) = 1
						BEGIN
							IF EXISTS (
									SELECT 1
									FROM bookprice
									WHERE bookkey = @i_bookkey
										AND pricetypecode = @PRICELIST
										AND currencytypecode = @CURRTYPE
										AND expirationdate IS NULL
										AND effectivedate < DateAdd(Day, Datediff(Day, 0, lastmaintdate), 0)
										AND lastuserid NOT LIKE '%Price_Import%'
									)
							BEGIN
								EXEC get_next_key @i_username,
									@v_nextkey OUT /*Delivery*/

								INSERT INTO bookverificationmessage
                (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
								VALUES (
									@v_nextkey,
									@i_bookkey,
									@i_verificationtypecode,
									@v_Error,
									'Price has an effective date in the past. Set an expiration date of today or greater and add a new price line with effective date of tomorrow or greater.',
									@i_username,
									getdate()
									)

								SET @v_failed = 1

								EXEC get_next_key @i_username,
									@v_nextkey OUT /*Development*/

								INSERT INTO bookverificationmessage
                (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
								VALUES (
									@v_nextkey,
									@i_bookkey,
									@v_vertypecode_dev,
									@v_Error,
									'Price has an effective date in the past. Set an expiration date of today or greater and add a new price line with effective date of tomorrow or greater.',
									@i_username,
									getdate()
									)

								SET @v_failed_dev = 1

								EXEC get_next_key @i_username,
									@v_nextkey OUT /*Production*/

								INSERT INTO bookverificationmessage
                (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
								VALUES (
									@v_nextkey,
									@i_bookkey,
									@v_vertypecode_prod,
									@v_Error,
									'A price has an effective date, no experation date, and a last maintenance date after the effective date. Please add an experation date.',
									@i_username,
									getdate()
									)

								SET @v_failed_prod = 1

								EXEC get_next_key @i_username,
									@v_nextkey OUT /*Oracle*/

								INSERT INTO bookverificationmessage
                (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
								VALUES (
									@v_nextkey,
									@i_bookkey,
									@v_vertypecode_oracle,
									@v_Error,
									'Price has an effective date in the past. Set an expiration date of today or greater and add a new price line with effective date of tomorrow or greater.',
									@i_username,
									getdate()
									)

								SET @v_failed_oracle = 1

								GOTO DONE
							END
						END
						ELSE IF (
								SELECT counter
								FROM #TEMP
								WHERE pricetypecode = @PRICELIST
									AND currencytypecode = @CURRTYPE
								) > 1
						BEGIN
							SELECT @maxlastmaintdate = max(lastmaintdate)
							FROM bookprice
							WHERE bookkey = @i_bookkey
								AND pricetypecode = @PRICELIST
								AND currencytypecode = @CURRTYPE

							IF EXISTS (
									SELECT 1
									FROM bookprice
									WHERE bookkey = @i_bookkey
										AND pricetypecode = @PRICELIST
										AND currencytypecode = @CURRTYPE
										AND effectivedate < DateAdd(Day, Datediff(Day, 0, @maxlastmaintdate), 0)
										AND expirationdate IS NULL
										AND lastuserid NOT LIKE '%Price_Import%'
									)
							BEGIN
								EXEC get_next_key @i_username,
									@v_nextkey OUT /*Delivery*/

								INSERT INTO bookverificationmessage
                (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
								VALUES (
									@v_nextkey,
									@i_bookkey,
									@i_verificationtypecode,
									@v_Error,
									'All prices in a list, that fall before the most recent update date of that price type, must have an expiration date or effective date greater than today.',
									@i_username,
									getdate()
									)

								SET @v_failed = 1

								EXEC get_next_key @i_username,
									@v_nextkey OUT /*Development*/

								INSERT INTO bookverificationmessage
                (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
								VALUES (
									@v_nextkey,
									@i_bookkey,
									@v_vertypecode_dev,
									@v_Error,
									'All prices in a list, that fall before the most recent update date of that price type, must have an expiration date or effective date greater than today.',
									@i_username,
									getdate()
									)

								SET @v_failed_dev = 1

								EXEC get_next_key @i_username,
									@v_nextkey OUT /*Production*/

								INSERT INTO bookverificationmessage
                (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
								VALUES (
									@v_nextkey,
									@i_bookkey,
									@v_vertypecode_prod,
									@v_Error,
									'All prices in a list, that fall before the most recent update date of that price type, must have an expiration date or effective date greater than today.',
									@i_username,
									getdate()
									)

								SET @v_failed_prod = 1

								EXEC get_next_key @i_username,
									@v_nextkey OUT /*Oracle*/

								INSERT INTO bookverificationmessage
                (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
								VALUES (
									@v_nextkey,
									@i_bookkey,
									@v_vertypecode_oracle,
									@v_Error,
									'All prices in a list, that fall before the most recent update date of that price type, must have an expiration date or effective date greater than today.',
									@i_username,
									getdate()
									)

								SET @v_failed_oracle = 1

								GOTO DONE
							END
						END

						DELETE
						FROM #TEMP
						WHERE pricetypecode = @PRICELIST
							AND currencytypecode = @CURRTYPE

						SELECT TOP 1 @PRICELIST = pricetypecode,
							@CURRTYPE = currencytypecode
						FROM #TEMP
						ORDER BY pricetypecode DESC
					END

					DONE:
				END

			END
		END
		*/
		
		EXEC bookverification_check 'LW_Units_Of_Measure',
	@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (
						(
							SELECT trimsizeunitofmeasure
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							) IS NOT NULL AND (
							SELECT spinesizeunitofmeasure
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							) IS NOT NULL
						) AND NOT EXISTS (
						SELECT 1
						FROM printing
						WHERE spinesizeunitofmeasure = trimsizeunitofmeasure AND bookkey = @i_bookkey and printingkey= @i_printingkey
						)
				BEGIN
					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@i_verificationtypecode,
						@v_Error,
						'Unit Of measure for Trim Size and Spine Size must be the same',
						@i_username,
						getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@v_vertypecode_dev,
						@v_Error,
						'Unit Of measure for Trim Size and Spine Size must be the same',
						@i_username,
						getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@v_vertypecode_prod,
						@v_Error,
						'Unit Of measure for Trim Size and Spine Size must be the same',
						@i_username,
						getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username,
						@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey,
						@i_bookkey,
						@v_vertypecode_oracle,
						@v_Error, 
						'Unit Of measure for Trim Size and Spine Size must be the same',
						@i_username,
						getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END
		
		
		EXEC bookverification_check 'LW_Series'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.get_Series(@i_bookkey, 'X'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Series Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Series Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Series Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Title_Prefix'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.get_TitlePrefix(@i_bookkey), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Title Prefix Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Title Prefix Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Title Prefix Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Title'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.get_Title(@i_bookkey, 'T'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Title Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Error
						,'Title Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Title Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'Title Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Subtitle'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.get_SubTitle(@i_bookkey), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Subtitle Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'Subtitle Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Subtitle Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_System_Title'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF NULLIF((
							SELECT shorttitle
							FROM book
							WHERE bookkey = @i_bookkey
							), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'System Title Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Error
						,'System Title Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'System Title Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'System Title Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Publisher_link'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.get_GroupLevel2(@i_bookkey, 'F'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Publisher Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Error
						,'Publisher Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Publisher Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'Publisher Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Imprint'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.get_GroupLevel3(@i_bookkey, 'F'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Imprint Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Error
						,'Imprint Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Imprint Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'Imprint Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Edition_Type'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (
						(
							SELECT editioncode
							FROM bookdetail
							WHERE bookkey = @i_bookkey
							) = 160 AND nullif(dbo.LW_bookdetail_info_check(@i_bookkey, 'en'), '') IS NOT NULL
						) OR (
						NULLIF((
								SELECT editioncode
								FROM bookdetail
								WHERE bookkey = @i_bookkey
								), '') IS NULL AND nullif(dbo.LW_bookdetail_info_check(@i_bookkey, 'en'), '') IS NULL
						)
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Edition Type and Edition number mismatch.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Edition Type and Edition number mismatch.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Edition Type and Edition number mismatch.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		--	EXEC bookverification_check 'LW_#'
		--	,@i_write_msg OUTPUT
		--IF @i_write_msg = 1
		--BEGIN
		--	IF @i_verificationtypecode = 10
		--	BEGIN
		--		IF nullif(dbo.LW_bookdetail_info_check(@i_bookkey, 'en'), '') IS NULL AND ISNULL(NULLIF((
		--						SELECT editioncode
		--						FROM bookdetail
		--						WHERE bookkey = @i_bookkey
		--						), ''), 160) <> 160
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'Edition Number Missing. Error because edtion type exists.'
		--				,@i_username
		--				,getdate()
		--				)
		--			SET @v_failed = 1
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Information
		--				,'Edition Number Missing.'
		--				,@i_username
		--				,getdate()
		--				)
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Warning
		--				,'Edition Number Missing.'
		--				,@i_username
		--				,getdate()
		--				)
		--			SET @v_varnings_prod = 1
		--		END
		--		ELSE IF nullif(dbo.LW_bookdetail_info_check(@i_bookkey, 'en'), '') IS NULL
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Warning
		--				,'Edition Number Missing.'
		--				,@i_username
		--				,getdate()
		--				)
		--			SET @v_varnings = 1
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Information
		--				,'Edition Number Missing.'
		--				,@i_username
		--				,getdate()
		--				)
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Warning
		--				,'Edition Number Missing.'
		--				,@i_username
		--				,getdate()
		--				)
		--			SET @v_varnings_prod = 1
		--		END
		--	END
		--END
		EXEC bookverification_check 'LW_Addtl_Edition_Info'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.LW_bookdetail_info_check(@i_bookkey, 'aei'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Addt''l Edition Info Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Addt''l Edition Info Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Addt''l Edition Info Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		--EXEC bookverification_check 'LW_Vol_______of______'
		--	,@i_write_msg OUTPUT

		--IF @i_write_msg = 1
		--BEGIN
		--	IF @i_verificationtypecode = 10
		--	BEGIN
		--		IF nullif((
		--					SELECT volumenumber
		--					FROM bookdetail
		--					WHERE bookkey = @i_bookkey
		--					), 0) IS NULL
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Warning
		--				,'Volume Information Missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Information
		--				,'Volume Information Missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Warning
		--				,'Volume Information Missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings_prod = 1
		--		END
		--	END
		--END

		EXEC bookverification_check 'LW_EAN/ISBN13'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF NULLIF((
							SELECT ean13
							FROM isbn
							WHERE bookkey = @i_bookkey
							), '') IS NULL AND (
						SELECT count(*)
						FROM bookmisc
						WHERE misckey = 103 AND longvalue = 1 AND bookkey = @i_bookkey
						) = 1
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'EAN/ISBN-13 Missing. Error because Primary Cross Reference = ISBN (13) / EAN'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
				ELSE IF NULLIF((
							SELECT ean13
							FROM isbn
							WHERE bookkey = @i_bookkey
							), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'EAN/ISBN-13 Missing'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Item_#_view_only'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF NULLIF((
							SELECT itemnumber
							FROM isbn
							WHERE bookkey = @i_bookkey
							), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Item # Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Error
						,'Item # Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Item # Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
					
						EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'Item # Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
					
				END
			END
		END

		EXEC bookverification_check 'LW_Pub_Month'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.get_PubMonth(@i_bookkey, 1, 'M'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Publication Month Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Error
						,'Publication Month Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Publication Month Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'Publication Month Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Year'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.get_PubMonth(@i_bookkey, 1, 'Y'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Publication Year Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Error
						,'Publication Year Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Publication Year Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'Publication Year Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END

		--EXEC bookverification_check 'LW_Season'
		--	,@i_write_msg OUTPUT

		--IF @i_write_msg = 1
		--BEGIN
		--	IF @i_verificationtypecode = 10
		--	BEGIN
		--		IF nullif(dbo.rpt_get_best_season(@i_bookkey, 1, 'D'), '') IS NULL
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'Season Missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Error
		--				,'Season Missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed_dev = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Error
		--				,'Season Missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed_prod = 1
		--		END
		--		ELSE IF nullif(dbo.rpt_get_best_season(@i_bookkey, 1, 'D'), '') IS NULL
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'Season Missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Warning
		--				,'Season Missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings_dev = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Error
		--				,'Season Missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed_prod = 1
		--		END
		--	END
		--END

		--EXEC bookverification_check 'LW_Season_Actual'
		--	,@i_write_msg OUTPUT

		--IF @i_write_msg = 1
		--BEGIN
		--	IF @i_verificationtypecode = 10
		--	BEGIN
		--		IF EXISTS (
		--				SELECT seasonkey
		--				FROM printing
		--				WHERE bookkey = @i_bookkey AND (seasonkey IS NULL OR seasonkey = 0) and printingkey= @i_printingkey
		--				)
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Warning
		--				,'Season Actual Box Unchecked.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Warning
		--				,'Season Actual Box Unchecked.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings_dev = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Warning
		--				,'Season Actual Box Unchecked.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings_prod = 1
		--		END
		--	END
		--END

		EXEC bookverification_check 'LW_Actual'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_trim_size(@i_bookkey, 1, 'A'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Trim Size Actual Box Unchecked.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Trim Size Actual Box Unchecked.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Trim Size Actual Box Unchecked.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Actual'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_page_count(@i_bookkey, 1, 'A'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Page Count Actual Box Unchecked.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Page Count Actual Box Unchecked.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Page Count Actual Box Unchecked.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Author'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (
						SELECT count(*)
						FROM bookedistatus
						WHERE bookkey = @i_bookkey AND edistatuscode = 8
						) = 0 AND (
						SELECT count(*)
						FROM bookauthor
						WHERE bookkey = @i_bookkey
						) < 1
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Author Missing on send to eloquence title. Add AUTHOR or choose NEVER SEND TO ELEOQUENCE'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Author Missing on send to eloquence title. Add AUTHOR or choose NEVER SEND TO ELEOQUENCE'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END
		
				
		--BASIC check for project manager and buyer. does not look for key value.

		EXEC bookverification_check 'LW_part_NO_key',
			@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF @mediatypedesc = 'NON'
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM bookcontact bc
							JOIN bookcontactrole br ON bc.bookcontactkey = br.bookcontactkey
							WHERE bookkey = @i_bookkey
								AND rolecode = 44
							)
						OR NOT EXISTS (
							SELECT 1
							FROM bookcontact bc
							JOIN bookcontactrole br ON bc.bookcontactkey = br.bookcontactkey
							WHERE bookkey = @i_bookkey
								AND rolecode = 40
							)
					BEGIN
					
								EXEC get_next_key @i_username
								,@v_nextkey OUT /*Delivery*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@i_verificationtypecode
								,@v_Error
								,'Both Project Manager and Buyer 1 must exists on products that have a NON digital format'
								,@i_username
								,getdate()
								)

							SET @v_failed = 1

							EXEC get_next_key @i_username
								,@v_nextkey OUT /*Development*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_dev
								,@v_Error
								,'Both Project Manager and Buyer 1 must exists on products that have a NON digital format'
								,@i_username
								,getdate()
								)

							SET @v_failed_dev = 1

							EXEC get_next_key @i_username
								,@v_nextkey OUT /*Production*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_prod
								,@v_Error
								,'Both Project Manager and Buyer 1 must exists on products that have a NON digital format'
								,@i_username
								,getdate()
								)

							SET @v_failed_prod = 1

							EXEC get_next_key @i_username
								,@v_nextkey OUT /*Oracle*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_oracle
								,@v_Error
								,'Both Project Manager and Buyer 1 must exists on products that have a NON digital format'
								,@i_username
								,getdate()
								)

							SET @v_failed_oracle = 1
						 
					END
				END
				ELSE
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM bookcontact bc
							JOIN bookcontactrole br ON bc.bookcontactkey = br.bookcontactkey
							WHERE bookkey = @i_bookkey
								AND rolecode = 44
							)
					BEGIN
											EXEC get_next_key @i_username
								,@v_nextkey OUT /*Delivery*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@i_verificationtypecode
								,@v_Error
								,'A Project Manager must exists on products that have a Digital format'
								,@i_username
								,getdate()
								)

							SET @v_failed = 1

							EXEC get_next_key @i_username
								,@v_nextkey OUT /*Development*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_dev
								,@v_Error
								,'A Project Manager must exists on products that have a Digital format'
								,@i_username
								,getdate()
								)

							SET @v_failed_dev = 1

							EXEC get_next_key @i_username
								,@v_nextkey OUT /*Production*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_prod
								,@v_Error
								,'A Project Manager must exists on products that have a Digital format'
								,@i_username
								,getdate()
								)

							SET @v_failed_prod = 1

							EXEC get_next_key @i_username
								,@v_nextkey OUT /*Oracle*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_oracle
								,@v_Error
								,'A Project Manager must exists on products that have a Digital format'
								,@i_username
								,getdate()
								)

							SET @v_failed_oracle = 1
						 
					END
				END
			END
		END
	--KEY part
		--EXEC bookverification_check 'LW_part_Key'
		--	,@i_write_msg OUTPUT

		--IF @i_write_msg = 1
		--BEGIN
		--	IF @i_verificationtypecode = 10
		--	BEGIN
		--		IF (
		--				SELECT count(*)
		--				FROM bookcontact
		--				WHERE bookkey = @i_bookkey AND keyind = 1
		--				) < 1
		--		BEGIN
		--			IF  @mediatypedesc = 'NON' 
		--			BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/
					
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'No Key Participant Identified. Buyer and Project Manager must be marked as Key when media type 2 = NON'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Error
		--				,'No Key Participant Identified. Buyer and Project Manager must be marked as Key when media type 2 = NON'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed_dev = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Error
		--				,'No Key Participant Identified. Buyer and Project Manager must be marked as Key when media type 2 = NON'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed_prod = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Oracle*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_oracle
		--				,@v_Error
		--				,'No Key Participant Identified. Buyer and Project Manager must be marked as Key when media type 2 = NON'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed_oracle = 1
		--			END
		--			ELSE 
		--			BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/
					
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'No Key Participant Identified. Project Manager must be marked as Key'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Error
		--				,'No Key Participant Identified. Project Manager must be marked as Key'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed_dev = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Error
		--				,'No Key Participant Identified. Project Manager must be marked as Key'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed_prod = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Oracle*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_oracle
		--				,@v_Error
		--				,'No Key Participant Identified. Project Manager must be marked as Key'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed_oracle = 1
		--			END
		--		END
		--		ELSE IF (
		--				SELECT count(*)
		--				FROM bookcontact bc
		--				JOIN bookcontactrole br ON bc.bookcontactkey = br.bookcontactkey
		--				WHERE bookkey = @i_bookkey AND keyind = 1 AND rolecode = 44
		--				) < 1 OR (
		--				SELECT count(*)
		--				FROM bookcontact bc
		--				JOIN bookcontactrole br ON bc.bookcontactkey = br.bookcontactkey
		--				WHERE bookkey = @i_bookkey AND keyind = 1 AND rolecode = 40
		--				) < 1
		--		BEGIN
		--			IF (	--LOOK FOR PROJECT MANAGER
		--					SELECT count(*)
		--					FROM bookcontact bc
		--					JOIN bookcontactrole br ON bc.bookcontactkey = br.bookcontactkey
		--					WHERE bookkey = @i_bookkey AND keyind = 1 AND rolecode = 44
		--					) < 1
		--			BEGIN
					
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/
					
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'Key Participant Not Identified. Error because project manager not marked as Key Participant.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed = 1
					
		--				EXEC get_next_key @i_username
		--					,@v_nextkey OUT /*Development*/

		--				INSERT INTO bookverificationmessage
		--				VALUES (
		--					@v_nextkey
		--					,@i_bookkey
		--					,@v_vertypecode_dev
		--					,@v_Error
		--					,'Key Participant Not Identified. Error because project manager not marked as Key Participant.'
		--					,@i_username
		--					,getdate()
		--					)

		--				SET @v_failed_dev = 1
					
		--				EXEC get_next_key @i_username
		--					,@v_nextkey OUT /*Production*/

		--				INSERT INTO bookverificationmessage
		--				VALUES (
		--					@v_nextkey
		--					,@i_bookkey
		--					,@v_vertypecode_prod
		--					,@v_Error
		--					,'Key Participant Not Identified. Error because project manager not marked as Key Participant.'
		--					,@i_username
		--					,getdate()
		--					)

		--				SET @v_failed_prod = 1
						
						
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Oracle*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_oracle
		--				,@v_Error
		--				,'Key Participant Not Identified. Error because project manager not marked as Key Participant.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed_oracle = 1
		--			END
					
		--			IF @mediatypedesc = 'NON' and (SELECT count(*)
		--				FROM bookcontact bc
		--				JOIN bookcontactrole br ON bc.bookcontactkey = br.bookcontactkey
		--				WHERE bookkey = @i_bookkey AND keyind = 1 AND rolecode = 40
		--				) < 1
		--			BEGIN
						
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'Buyer Not identified as Key Participant. Buyer must be marked as KEY Participant when media type 2 = NON.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Error
		--				,'Buyer Not identified as Key Participant. Buyer must be marked as KEY Participant when media type 2 = NON.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed_dev = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Error
		--				,'Buyer Not identified as Key Participant. Buyer must be marked as KEY Participant when media type 2 = NON.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed_prod = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Oracle*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_oracle
		--				,@v_Error
		--				,'Buyer Not identified as Key Participant. Buyer must be marked as KEY Participant when media type 2 = NON.'
		--				,@i_username
		--				,getdate()
		--				)
						

		--			SET @v_failed_oracle = 1
						
		--			END
						
					
					
		--		END
		--	END
		--END

		EXEC bookverification_check 'LW_Business_Unit'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 267, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Business Unit Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Error
						,'Business Unit Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Business Unit Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'Business Unit Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Ministry_Area'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 268, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Ministry Area Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Error
						,'Ministry Area Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Ministry Area Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'Ministry Area Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Sales_Class_Code'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 379, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Sales Class Code Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Error
						,'Sales Class Code Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Sales Class Code Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'Sales Class Code Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END

		--removed because value is based on a calculated field
		--EXEC bookverification_check 'LW_Product_Group_Segment'
		--	,@i_write_msg OUTPUT
		--IF @i_write_msg = 1
		--BEGIN
		--	IF @i_verificationtypecode = 10
		--	BEGIN
		--		IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 270, 'text'), '') IS NULL
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'Product Group Segment Missing.'
		--				,@i_username
		--				,getdate()
		--				)
		--			SET @v_failed = 1
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Error
		--				,'Product Group Segment Missing.'
		--				,@i_username
		--				,getdate()
		--				)
		--			SET @v_failed_dev = 1
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Error
		--				,'Product Group Segment Missing.'
		--				,@i_username
		--				,getdate()
		--				)
		--			SET @v_failed_prod = 1
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Oracle*/
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_oracle
		--				,@v_Error
		--				,'Product Group Segment Missing.'
		--				,@i_username
		--				,getdate()
		--				)
		--			SET @v_failed_oracle = 1
		--		END
		--	END
		--END
		EXEC bookverification_check 'LW_Master_Brand'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 271, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Master Brand Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Master Brand Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Master Brand Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Category'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 272, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Category Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'Category Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Category Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Subcategory'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 273, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Subcategory Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'Subcategory Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Subcategory Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Solution_Family'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 274, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Solution Family Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'Solution Family Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Solution Family Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Solution_Target'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 275, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Solution Target Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'Solution Target Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Solution Target Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Product_Line'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 276, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Product Line Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'Product Line Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Product Line Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Product_Type'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 45, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Product Type Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'Product Type Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Product Type Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Product_Use'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 278, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Product Use Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'Product Use Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Product Use Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'Product Use missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Copies_of_Proforma_Available'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 76, 'long') = 'No'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Proforma Copies Not Available.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'Proforma Copies Not Available.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Proforma Copies Not Available.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_QR_Code_Needed'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 69, 'long') = 'No'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'QR Code Needed Unchecked.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'QR Code Needed Unchecked.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'QR Code Needed Unchecked.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Content_Issue'
	,@i_write_msg OUTPUT

IF @i_write_msg = 1
BEGIN
	IF @i_verificationtypecode = 10
	BEGIN
		IF dbo.rpt_get_misc_value(@i_bookkey, 278, 'long') = 'Ongoing' AND NULLIF(dbo.rpt_get_misc_value(@i_bookkey, 279, 'long'), '') IS NULL AND 
 dbo.rpt_get_misc_value (@i_bookkey,56,'external')<>'LWSUBMAST'
		BEGIN
			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Delivery*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@i_verificationtypecode
				,@v_Error
				,'Content Issue Missing. Error because Product Use = Ongoing.'
				,@i_username
				,getdate()
				)

			SET @v_failed = 1

			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Development*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@v_vertypecode_dev
				,@v_Error
				,'Content Issue Missing. Error because Product Use = Ongoing.'
				,@i_username
				,getdate()
				)

			SET @v_failed_dev = 1

			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Production*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@v_vertypecode_prod
				,@v_Error
				,'Content Issue Missing. Error because Product Use = Ongoing.'
				,@i_username
				,getdate()
				)

			SET @v_failed_prod = 1

			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Oracle*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@v_vertypecode_oracle
				,@v_Error
				,'Content Issue Missing. Error because Product Use = Ongoing.'
				,@i_username
				,getdate()
				)

			SET @v_failed_oracle = 1
		END
		ELSE IF NULLIF(dbo.rpt_get_misc_value(@i_bookkey, 279, 'long'), '') IS NULL
		BEGIN
			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Delivery*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@i_verificationtypecode
				,@v_Information
				,'Content Issue Missing.'
				,@i_username
				,getdate()
				)

			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Development*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@v_vertypecode_dev
				,@v_Information
				,'Content Issue Missing.'
				,@i_username
				,getdate()
				)

			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Production*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@v_vertypecode_prod
				,@v_Information
				,'Content Issue Missing.'
				,@i_username
				,getdate()
				)

			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Oracle*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@v_vertypecode_oracle
				,@v_Information
				,'Content Issue Missing.'
				,@i_username
				,getdate()
				)
		END
	END
END

EXEC bookverification_check 'LW_Curriculum_Quarter'
	,@i_write_msg OUTPUT

IF @i_write_msg = 1
BEGIN
	IF @i_verificationtypecode = 10
	BEGIN
		IF dbo.rpt_get_misc_value(@i_bookkey, 278, 'long') = 'Ongoing' AND NULLIF(dbo.rpt_get_misc_value(@i_bookkey, 280, 'long'), '') IS NULL AND 
 dbo.rpt_get_misc_value (@i_bookkey,56,'external')<>'LWSUBMAST'
		BEGIN
			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Delivery*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@i_verificationtypecode
				,@v_Error
				,'Curriculum Quarter Missing. Error because Product Use = Ongoing.'
				,@i_username
				,getdate()
				)

			SET @v_failed = 1

			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Development*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@v_vertypecode_dev
				,@v_Error
				,'Curriculum Quarter Missing. Error because Product Use = Ongoing.'
				,@i_username
				,getdate()
				)

			SET @v_failed_dev = 1

			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Production*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@v_vertypecode_prod
				,@v_Error
				,'Curriculum Quarter Missing. Error because Product Use = Ongoing.'
				,@i_username
				,getdate()
				)

			SET @v_failed_prod = 1

			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Oracle*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@v_vertypecode_oracle
				,@v_Error
				,'Curriculum Quarter Missing. Error because Product Use = Ongoing.'
				,@i_username
				,getdate()
				)

			SET @v_failed_oracle = 1
		END
		ELSE IF NULLIF(dbo.rpt_get_misc_value(@i_bookkey, 280, 'long'), '') IS NULL
		BEGIN
			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Delivery*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@i_verificationtypecode
				,@v_Information
				,'Curriculum Quarter Missing.'
				,@i_username
				,getdate()
				)

			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Development*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@v_vertypecode_dev
				,@v_Information
				,'Curriculum Quarter Missing.'
				,@i_username
				,getdate()
				)

			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Production*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@v_vertypecode_prod
				,@v_Information
				,'Curriculum Quarter Missing.'
				,@i_username
				,getdate()
				)

			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Oracle*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@v_vertypecode_oracle
				,@v_Information
				,'Curriculum Quarter Missing.'
				,@i_username
				,getdate()
				)
		END
	END
END


		EXEC bookverification_check 'LW_Bulletin_Type'
	,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF NULLIF(dbo.rpt_get_misc_value(@i_bookkey, 281, 'long'), '') IS NULL AND (dbo.rpt_get_misc_value_gentable(@i_bookkey, 45, 24, 'external')) = 351
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Bulletin Type Missing. Warning because product type = Bulletins - Dated'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Bulletin Type Missing. Warning because product type = Bulletins - Dated'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Bulletin Type Missing. Warning because product type = Bulletins - Dated'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

EXEC bookverification_check 'Primary_Cross_Reference'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
			
			
				--1	ISBN (13) / EAN
				--2	UPC
				--3	LifeWay/Oracle #
				--4	ASIN
				--5	Apple ID
				--6	ISBN (10)
				--7	MFN
				--9	EPPS
				--10	Vendor Part #
				declare @longvalue int

				SELECT  @longvalue=longvalue from bookmisc where bookkey=@i_bookkey and misckey=103


				IF @longvalue =1
				BEGIN
					IF isnull((SELECT ean from isbn where bookkey=@i_bookkey),'')=''
					BEGIN
						EXEC get_next_key @i_username,@v_nextkey OUT
									insert into bookverificationmessage
                  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									values (@v_nextkey, 
									@i_bookkey, 
									@i_verificationtypecode, 
									@v_Error, 
									'Primary Cross Reference marked as ISBN (13) / EAN. ISBN (13) / EAN is missing.',
									@i_username, getdate() )
									set @v_failed = 1
									
										EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_dev
								,@v_Error
								,'Primary Cross Reference marked as ISBN (13) / EAN. ISBN (13) / EAN is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_dev = 1

							EXEC get_next_key @i_username
								,@v_nextkey OUT /*Production*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_prod
								,@v_Error
								,'Primary Cross Reference marked as ISBN (13) / EAN. ISBN (13) / EAN is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_prod = 1

							EXEC get_next_key @i_username
								,@v_nextkey OUT /*Oracle*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_oracle
								,@v_Error
								,'Primary Cross Reference marked as ISBN (13) / EAN. ISBN (13) / EAN is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_oracle = 1
					END
				END
				ELSE
				IF @longvalue =2
				BEGIN
					IF isnull((SELECT upc from isbn where bookkey=@i_bookkey),'')=''
					BEGIN
						EXEC get_next_key @i_username,@v_nextkey OUT
									insert into bookverificationmessage
                  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									values (@v_nextkey, 
									@i_bookkey, 
									@i_verificationtypecode, 
									@v_Error, 
									'Primary Cross Reference marked as UPC. UPC is missing.',
									@i_username, 
									getdate() )
									set @v_failed = 1
									
										EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_dev
								,@v_Error
								,'Primary Cross Reference marked as UPC. UPC is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_dev = 1

							EXEC get_next_key @i_username
								,@v_nextkey OUT /*Production*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_prod
								,@v_Error
								,'Primary Cross Reference marked as UPC. UPC is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_prod = 1

							EXEC get_next_key @i_username
								,@v_nextkey OUT /*Oracle*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_oracle
								,@v_Error
								,'Primary Cross Reference marked as UPC. UPC is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_oracle = 1
					END
				END
				ELSE
				IF @longvalue =3
				BEGIN
					IF isnull((SELECT itemnumber from isbn where bookkey=@i_bookkey),'')=''
					BEGIN
						EXEC get_next_key @i_username,@v_nextkey OUT
									insert into bookverificationmessage
                  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									values (@v_nextkey, 
									@i_bookkey, 
									@i_verificationtypecode, 
									@v_Error, 
									'Primary Cross Reference marked as LifeWay/Oracle #. LifeWay/Oracle # is missing.',
									@i_username, 
									getdate() )
									set @v_failed = 1
									
										EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_dev
								,@v_Error
								,'Primary Cross Reference marked as LifeWay/Oracle #. LifeWay/Oracle # is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_dev = 1

							EXEC get_next_key @i_username
								,@v_nextkey OUT /*Production*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_prod
								,@v_Error
								,'Primary Cross Reference marked as LifeWay/Oracle #. LifeWay/Oracle # is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_prod = 1

							EXEC get_next_key @i_username
								,@v_nextkey OUT /*Oracle*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_oracle
								,@v_Error
								,'Primary Cross Reference marked as LifeWay/Oracle #. LifeWay/Oracle # is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_oracle = 1
						
					END
				END
				ELSE
				IF @longvalue =4
				BEGIN
					IF NOT EXISTS(SELECT TEXTVALUE from bookmisc where bookkey=@i_bookkey and misckey=359) OR ISNULL((SELECT TEXTVALUE from bookmisc where bookkey=@i_bookkey and misckey=359),'')=''
						BEGIN
							EXEC get_next_key @i_username,@v_nextkey OUT
									insert into bookverificationmessage
                  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									values (@v_nextkey, 
									@i_bookkey, 
									@i_verificationtypecode, 
									@v_Error, 
									'Primary Cross Reference marked as ASIN. ASIN is missing.',
									@i_username, 
									getdate() )
									set @v_failed = 1
									
										EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_dev
								,@v_Error
								,'Primary Cross Reference marked as ASIN. ASIN is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_dev = 1

							EXEC get_next_key @i_username
								,@v_nextkey OUT /*Production*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_prod
								,@v_Error
								,'Primary Cross Reference marked as ASIN. ASIN is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_prod = 1

							EXEC get_next_key @i_username
								,@v_nextkey OUT /*Oracle*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_oracle
								,@v_Error
								,'Primary Cross Reference marked as ASIN. ASIN is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_oracle = 1
						END
					
				END
				ELSE
				IF @longvalue =5
				BEGIN
					IF NOT EXISTS(SELECT TEXTVALUE from bookmisc where bookkey=@i_bookkey and misckey=360) OR ISNULL((SELECT TEXTVALUE from bookmisc where bookkey=@i_bookkey and misckey=360),'')=''
						BEGIN
							EXEC get_next_key @i_username,@v_nextkey OUT
									insert into bookverificationmessage
                  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									values (@v_nextkey, 
									@i_bookkey, 
									@i_verificationtypecode, 
									@v_Error, 
									'Primary Cross Reference marked as Apple ID. Apple ID is missing.',
									@i_username, 
									getdate() )
									set @v_failed = 1
									
										EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_dev
								,@v_Error
								,'Primary Cross Reference marked as Apple ID. Apple ID is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_dev = 1

							EXEC get_next_key @i_username
								,@v_nextkey OUT /*Production*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_prod
								,@v_Error
								,'Primary Cross Reference marked as Apple ID. Apple ID is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_prod = 1

							EXEC get_next_key @i_username
								,@v_nextkey OUT /*Oracle*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_oracle
								,@v_Error
								,'Primary Cross Reference marked as Apple ID. Apple ID is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_oracle = 1
						END

				END
				ELSE
				IF @longvalue =6
				BEGIN
					IF isnull((SELECT isbn10 from isbn where bookkey=@i_bookkey),'')=''
					BEGIN
						EXEC get_next_key @i_username,@v_nextkey OUT
									insert into bookverificationmessage
                  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									values (@v_nextkey, 
									@i_bookkey, 
									@i_verificationtypecode, 
									@v_Error, 
									'Primary Cross Reference marked as isbn10. isbn10 is missing.',
									@i_username, 
									getdate() )
									set @v_failed = 1
									
										EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_dev
								,@v_Error
								,'Primary Cross Reference marked as isbn10. isbn10 is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_dev = 1

							EXEC get_next_key @i_username
								,@v_nextkey OUT /*Production*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_prod
								,@v_Error
								,'Primary Cross Reference marked as isbn10. isbn10 is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_prod = 1

							EXEC get_next_key @i_username
								,@v_nextkey OUT /*Oracle*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_oracle
								,@v_Error
								,'Primary Cross Reference marked as isbn10. isbn10 is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_oracle = 1
					END
				END
				ELSE
				IF @longvalue =7
				BEGIN
					IF NOT EXISTS(SELECT TEXTVALUE from bookmisc 
					where bookkey=@i_bookkey and misckey=376) OR ISNULL((SELECT TEXTVALUE from bookmisc where bookkey=@i_bookkey and misckey=376),'')=''
						BEGIN
							EXEC get_next_key @i_username,@v_nextkey OUT
									insert into bookverificationmessage
                  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									values (@v_nextkey, 
									@i_bookkey, 
									@i_verificationtypecode, 
									@v_Error, 
									'Primary Cross Reference marked as MFN. MFN is missing.',
									@i_username, 
									getdate() )
									
									set @v_failed = 1
										
										EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_dev
								,@v_Error
								,'Primary Cross Reference marked as MFN. MFN is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_dev = 1

							EXEC get_next_key @i_username
								,@v_nextkey OUT /*Production*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_prod
								,@v_Error
								,'Primary Cross Reference marked as MFN. MFN is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_prod = 1

							EXEC get_next_key @i_username
								,@v_nextkey OUT /*Oracle*/

							INSERT INTO bookverificationmessage
              (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
							VALUES (
								@v_nextkey
								,@i_bookkey
								,@v_vertypecode_oracle
								,@v_Error
								,'Primary Cross Reference marked as MFN. MFN is missing.'
								,@i_username
								,getdate()
								)

							SET @v_failed_oracle = 1
						END
				END		
				ELSE IF @longvalue NOT IN (1,2,3,4,5,6,7)
				BEGIN
					EXEC get_next_key @i_username,@v_nextkey OUT
									insert into bookverificationmessage
                  (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
									values (@v_nextkey, @i_bookkey, @i_verificationtypecode, @v_Error, 'Primary Cross Reference INVALID. Please select a different primary cross reference.',@i_username, getdate() )
									set @v_failed = 1
				END
			
			
			
			END
		END


		EXEC bookverification_check 'LW_Primary_Cross_Reference'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 103, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Primary Cross Reference Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Error
						,'Primary Cross Reference Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Primary Cross Reference Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'Primary Cross Reference Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Royalty_Item'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 51, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Royalty Item Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'Royalty Item Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Royalty Item Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'Royalty Item Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Interior_Spread'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 93, 'long') = 'No'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Interior Spread Unchecked.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Interior Spread Unchecked.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Interior Spread Unchecked.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Sample_Chapters_Needed'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 94, 'long') = 'No'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Sample Chapters Needed Unchecked.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Sample Chapters Needed Unchecked.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Sample Chapters Needed Unchecked.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Budget'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.LW_price_ind(@i_bookkey, 'B'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Budget Price Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Budget Price Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Budget Price Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Final'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.LW_price_ind(@i_bookkey, 'F'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Final Price Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Final Price Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Final Price Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Active'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.LW_price_ind(@i_bookkey, 'A'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Price Not Active.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'Price Not Active.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Price Not Active.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		--EXEC bookverification_check 'LW_Send_to_Oracle_Status'
		--	,@i_write_msg OUTPUT

		--IF @i_write_msg = 1
		--BEGIN
		--	IF @i_verificationtypecode = 10
		--	BEGIN
		--		IF (dbo.rpt_get_misc_value(@i_bookkey, 59, 'long')) IN ('Pending Oracle Review', 'Approved for Oracle Load')
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'Send to Oracle Status Incorrect.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Error
		--				,'Send to Oracle Status Incorrect.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed_dev = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Error
		--				,'Send to Oracle Status Incorrect.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed_prod = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Oracle*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_oracle
		--				,@v_Error
		--				,'Send to Oracle Status Incorrect.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed_oracle = 1
		--		END
		--	END
		--END

		EXEC bookverification_check 'LW_Item_Type'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 56, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Item Type Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Error
						,'Item Type Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Item Type Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'Item Type Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END

		


		EXEC bookverification_check 'LW_Responsibilty_Center'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 289, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Responsibilty Center Missing'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Error
						,'Responsibilty Center'
						,@i_username
						,getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Responsibilty Center'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'Responsibilty Center'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Title_Type'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 286, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Title Type Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Title Type'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Title Type'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_System_Title__Long'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 287, 'text'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'System Title - Long Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Inventory_Organization_Code'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 288, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Inventory Organization Code Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Error
						,'Inventory Organization Code'
						,@i_username
						,getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Inventory Organization Code'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'Inventory Organization Code Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END

		EXEC bookverification_check 'LW_LWX_Tax_Override_Category'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 47, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'LWX Tax Override Category Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'LWX Tax Override Category'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'LWX Tax Override Category'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_COGS_Account'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_lr_get_cogs_acct(@i_bookkey), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'COGS Account Missing'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Sales_Account'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_lr_get_sales_acct(@i_bookkey), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'Sales Account Missing'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Harmonization_Code'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF @mediatypedesc = 'NON' AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 49, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Harmonization Code missing. Error because physical product'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Harmonization Code missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Harmonization Code missing. Error because physical product'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
				ELSE IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 49, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Harmonization Code missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Harmonization Code missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Harmonization Code missing'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Medium'
	,@i_write_msg OUTPUT

	IF @i_write_msg = 1
	BEGIN
		IF @i_verificationtypecode = 10
		BEGIN
			IF (
					SELECT count(datadesc)
					FROM subgentables
						,book
					WHERE tableid = 525 AND datacode = 83 AND externalcode = dbo.rpt_lr_get_medium_mediatype2_codes(bookkey, 1) AND bookkey = @i_bookkey
					) = 0
			BEGIN
				EXEC get_next_key @i_username
					,@v_nextkey OUT /*Delivery*/

				INSERT INTO bookverificationmessage
        (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
				VALUES (
					@v_nextkey
					,@i_bookkey
					,@i_verificationtypecode
					,@v_Error
					,'Medium Missing. "Please contact ADMIN"'
					,@i_username
					,getdate()
					)

				SET @v_failed = 1

				EXEC get_next_key @i_username
					,@v_nextkey OUT /*Development*/

				INSERT INTO bookverificationmessage
        (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
				VALUES (
					@v_nextkey
					,@i_bookkey
					,@v_vertypecode_dev
					,@v_Warning
					,'Medium Missing. "Please contact ADMIN"'
					,@i_username
					,getdate()
					)

				SET @v_varnings_dev = 1

				EXEC get_next_key @i_username
					,@v_nextkey OUT /*Production*/

				INSERT INTO bookverificationmessage
        (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
				VALUES (
					@v_nextkey
					,@i_bookkey
					,@v_vertypecode_prod
					,@v_Error
					,'Medium Missing. "Please contact ADMIN"'
					,@i_username
					,getdate()
					)

				SET @v_failed_prod = 1
			END
		END
	END

		EXEC bookverification_check 'LW_Media_Type'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 293, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Media Type Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Media Type Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Media Type Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		--calculated for now
		--EXEC bookverification_check 'LW_Media_Type_2'
		--	,@i_write_msg OUTPUT
		--IF @i_write_msg = 1
		--BEGIN
		--	IF @i_verificationtypecode = 10
		--	BEGIN
		--		IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 294, 'long'), '') IS NULL
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'Media Type 2 Missing.'
		--				,@i_username
		--				,getdate()
		--				)
		--			SET @v_failed = 1
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Warning
		--				,'Media Type 2 Missing.'
		--				,@i_username
		--				,getdate()
		--				)
		--			SET @v_varnings_dev = 1
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Error
		--				,'Media Type 2 Missing.'
		--				,@i_username
		--				,getdate()
		--				)
		--			SET @v_failed_prod = 1
		--		END
		--	END
		--END
		EXEC bookverification_check 'LW_Web_Enabled_Indicator'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 54, 'long') = 'No'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Web Enabled Indicator Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'Web Enabled Indicator Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Web Enabled Indicator Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
				ELSE
				IF  dbo.rpt_get_misc_value(@i_bookkey,401,'external') = 'PRE'
				BEGIN

				EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'Web Enabled Indicator checked while Oracle Item Status = (PRE). Uncheck Web Enabled Indicator.'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
				END
				
			END
		END

		EXEC bookverification_check 'LW_Demand_Print_Indicator'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (
						SELECT bisacstatuscode
						FROM bookdetail
						WHERE bookkey = @i_bookkey
						) = 5 AND (nullif(dbo.rpt_get_misc_value(@i_bookkey, 55, 'long'), '') IS NULL OR nullif(dbo.rpt_get_misc_value(@i_bookkey, 55, 'long'), '') = 'NO')
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Demand Print Indicator Missing. Error because BISAC Status = On Demand.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'Demand Print Indicator Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Demand Print Indicator Missing. Error because BISAC Status = On Demand.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
				ELSE IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 55, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Demand Print Indicator Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Demand Print Indicator Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'Demand Print Indicator Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Multiple_Order_Quantity'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 292, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Multiple Order Quantity Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'Multiple Order Quantity Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Multiple Order Quantity Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_PO_Major'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 284, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'PO Major Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'PO Major'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'PO Major'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_PO_Minor'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 285, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'PO Minor Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'PO Minor'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'PO Minor'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Pub_Date'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF NOT EXISTS (
						SELECT bestdate
						FROM bookdates
						WHERE bookkey = @i_bookkey AND datetypecode = 8
						)
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Pub date missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Error
						,'Pub date missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Pub date missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Error
						,'Pub Date Missing'
						,@i_username
						,getdate()
						)

					SET @v_failed_oracle = 1
				END
			END
		END

EXEC bookverification_check 'LW_Product_Form'
	,@i_write_msg OUTPUT

IF @i_write_msg = 1
BEGIN
	IF @i_verificationtypecode = 10
	BEGIN
		IF NULLIF((
					SELECT dbo.rpt_bhp_get_product_form_and_detail_codes(bookkey, 1)
					FROM book
					WHERE bookkey = @i_bookkey
					), '') IS NULL
		BEGIN
			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Delivery*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@i_verificationtypecode
				,@v_Error
				,'Product Form Missing. "Please contact ADMIN"'
				,@i_username
				,getdate()
				)

			SET @v_failed = 1

			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Development*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@v_vertypecode_dev
				,@v_Warning
				,'Product Form Missing. "Please contact ADMIN"'
				,@i_username
				,getdate()
				)

			SET @v_varnings_dev = 1

			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Production*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@v_vertypecode_prod
				,@v_Error
				,'Product Form Missing. "Please contact ADMIN"'
				,@i_username
				,getdate()
				)

			SET @v_failed_prod = 1
		END
	END
END

EXEC bookverification_check 'LW_Product_Form_Detail'
	,@i_write_msg OUTPUT

IF @i_write_msg = 1
BEGIN
	IF @i_verificationtypecode = 10
	BEGIN
		IF NULLIF((
					SELECT dbo.rpt_bhp_get_product_form_and_detail_codes(bookkey, 'F')
					FROM book
					WHERE bookkey = @i_bookkey
					), '') IS NULL
		BEGIN
			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Delivery*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@i_verificationtypecode
				,@v_Warning
				,'Product Form Detail Missing. "Please contact ADMIN"'
				,@i_username
				,getdate()
				)

			SET @v_varnings = 1

			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Development*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@v_vertypecode_dev
				,@v_Warning
				,'Product Form Detail Missing. "Please contact ADMIN"'
				,@i_username
				,getdate()
				)

			SET @v_varnings_dev = 1

			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Production*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@v_vertypecode_prod
				,@v_Warning
				,'Product Form Detail Missing. "Please contact ADMIN"'
				,@i_username
				,getdate()
				)

			SET @v_varnings_prod = 1
		END
	END
END


		EXEC bookverification_check 'LW_Number_of_Sessions'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 297, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Number of Sessions Missing'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Number of Sessions Missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Number of Sessions Missing'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Session_Number'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 298, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Session Number Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Session Number Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Session Number Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		
		EXEC bookverification_check 'LW_Product_Packaging_Type'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 17, 'long'), '') IS NULL  AND @mediatypedesc = 'NON'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Packaging Type Missing'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Packaging Type Missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Packaging Type Missing'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Package_Quantity'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 21, 'text'), '') IS NULL  AND @mediatypedesc = 'NON'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Packaging Quantity Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Packaging Quantity Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Packaging Quantity Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_New_Typesetting_Needed'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 80, 'long') = 'No'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'New Typesetting Needed Missing,'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'New Typesetting Needed Missing,'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'New Typesetting Needed Missing,'
						,@i_username
						,getdate()
						)
				END
			END
		END
		
		EXEC bookverification_check 'LW_Trim_Size_for_specs'
			,@i_write_msg OUTPUT
	
IF @i_write_msg = 1
BEGIN
	IF @i_verificationtypecode = 10
	BEGIN
		IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 217, 'text'), '') IS NULL AND @mediatypedesc = 'NON'
		BEGIN
			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Delivery*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@i_verificationtypecode
				,@v_Warning
				,'Trim Size (for specs) Missing.'
				,@i_username
				,getdate()
				)

			SET @v_varnings = 1

			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Development*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@v_vertypecode_dev
				,@v_Information
				,'Trim Size (for specs) Missing.'
				,@i_username
				,getdate()
				)

			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Production*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@v_vertypecode_prod
				,@v_Error
				,'Trim Size (for specs) Missing.'
				,@i_username
				,getdate()
				)

			SET @v_failed_prod = 1
		END
	END
END


		EXEC bookverification_check 'LW_Country_of_Origin'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 9, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Country of Origin Missing'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Country of Origin Missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Country of Origin Missing'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Digital_Indicator'
	,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF NULLIF((
							SELECT dbo.rpt_lr_get_medium_mediatype2_codes(bookkey, 3)
							FROM book
							WHERE bookkey = @i_bookkey
							), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Digital Indicator Missing. "Please contact ADMIN"'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'Digital Indicator Missing. "Please contact ADMIN"'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Digital Indicator Missing. "Please contact ADMIN"'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Product_Dimension_Descriptive'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF @mediatypedesc = 'NON' AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 377, 'text'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Missing Product Dimension'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'Missing Product Dimension'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Missing Product Dimension'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Sample_Chapters_/_Samplers_Available'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 60, 'long') = 'No'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Sample Chapters / Samplers Available Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Sample Chapters / Samplers Available Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Sample Chapters / Samplers Available Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Cover_Approved_for_Distribution'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 64, 'long') = 'No'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Cover Approved for Distribution Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Cover Approved for Distribution Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Cover Approved for Distribution Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Final_Financial_Approval'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 303, 'long') = 'No'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Final Financial Approval Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Final Financial Approval Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Final Financial Approval Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Final_Financial_Approval_Date'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 304, 'text'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Final Financial Approval Date Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Final Financial Approval Date Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Final Financial Approval Date Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Title_Final'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 61, 'long') = 'No'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Title Final Approval Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Title Final Approval Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Title Final Approval Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Subtitle_Final'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (dbo.rpt_get_misc_value(@i_bookkey, 62, 'long') = 'No') AND (
						SELECT NULLIF(subtitle, '')
						FROM book
						WHERE bookkey = @i_bookkey
						) IS NOT NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Subtitle Final Approval Missing. Error because Subtitle not blank.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Subtitle Final Approval Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Subtitle Final Approval Missing. Error because Subtitle not blank.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
				ELSE IF dbo.rpt_get_misc_value(@i_bookkey, 62, 'long') = 'No'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Subtitle Final Approval Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Subtitle Final Approval Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Subtitle Final Approval Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		--EXEC bookverification_check 'LW_Full_Description_AE/Author_Approved'
		--	,@i_write_msg OUTPUT

		--IF @i_write_msg = 1
		--BEGIN
		--	IF @i_verificationtypecode = 10
		--	BEGIN
		--		IF dbo.rpt_get_misc_value(@i_bookkey, 67, 'long') = 'No'
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'Full Description (AE/Author Approved) Missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Information
		--				,'Full Description (AE/Author Approved) Missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Warning
		--				,'Full Description (AE/Author Approved) Missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings_prod = 1
		--		END
		--	END
		--END

		EXEC bookverification_check 'LW_Endorsements'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 68, 'long') = 'No'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Endorsements Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Endorsements Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Endorsements Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_12_Month_Proforma_Forecast_Net_Units'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 77, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'12 Month Proforma Forecast (Net Units) Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'12 Month Proforma Forecast (Net Units) Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'12 Month Proforma Forecast (Net Units) Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Accounting_Rule_ID'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 305, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Accounting Rule ID Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Accounting Rule ID Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Accounting Rule ID Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Invoicing_Rule_ID'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 305, 'long'), '') IS NOT NULL AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 306, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Invoicing Rule ID Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Error
						,'Invoicing Rule ID Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Invoicing Rule ID Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Send_to_Oracle_Override'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 99, 'long') = 'No'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Send to Oracle Override Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Send to Oracle Override Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Send to Oracle Override Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_BISAC_Status'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.get_BisacStatus(@i_bookkey, 'B'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'BISAC Status missing or incorrect.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Error
						,'BISAC Status missing or incorrect.'
						,@i_username
						,getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'BISAC Status missing or incorrect.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Product_Availability'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_product_availability(@i_bookkey, 'B'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Product Availability missing or incorrect.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Product Availability missing or incorrect.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Product Availability missing or incorrect.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		--EXEC bookverification_check 'LW_Internal_Status'
		--	,@i_write_msg OUTPUT
		--IF @i_write_msg = 1
		--BEGIN
		--	IF @i_verificationtypecode = 10
		--	BEGIN
		--		IF nullif(dbo.get_internal_status_code(@i_bookkey, 'I'), '') IS NULL
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'Internal Status missing or incorrect.'
		--				,@i_username
		--				,getdate()
		--				)
		--			SET @v_failed = 1
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Error
		--				,'Internal Status missing or incorrect.'
		--				,@i_username
		--				,getdate()
		--				)
		--			SET @v_failed_dev = 1
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Error
		--				,'Internal Status missing or incorrect.'
		--				,@i_username
		--				,getdate()
		--				)
		--			SET @v_failed_prod = 1
		--		END
		--	END
		--END
		--EXEC bookverification_check 'LW_Expected_Ship_Date'
		--	,@i_write_msg OUTPUT

		--IF @i_write_msg = 1
		--BEGIN
		--	IF @i_verificationtypecode = 10
		--	BEGIN
		--		IF @mediatypedesc = 'NON' AND (
		--				SELECT count(*)
		--				FROM bookdates
		--				WHERE datetypecode = 396 AND bookkey = @i_bookkey
		--				) > 1
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'Expected Ship date missing. Error because product type = Physical.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Information
		--				,'Expected Ship date missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Error
		--				,'Expected Ship date missing. Error because product type = Physical.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed_prod = 1
		--		END
		--		ELSE IF @mediatypedesc = 'DIG' AND (
		--				SELECT count(*)
		--				FROM bookdates
		--				WHERE datetypecode = 396 AND bookkey = @i_bookkey
		--				) > 1
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Warning
		--				,'Expected Ship date missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Warning
		--				,'Expected Ship date missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings_prod = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Information
		--				,'Expected Ship date missing.'
		--				,@i_username
		--				,getdate()
		--				)
		--		END
		--	END
		--END

		EXEC bookverification_check 'LW_Release_Quantity'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF EXISTS (
						SELECT tentativeqty
						FROM printing
						WHERE bookkey = @i_bookkey AND tentativeqty IS NULL AND firstprintingqty IS NULL and printingkey= @i_printingkey
						)
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Estimated Release Quantity not defined'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Estimated Release Quantity not defined'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Estimated Release Quantity not defined'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Release_Quantity_Actual'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF EXISTS (
						SELECT firstprintingqty
						FROM printing
						WHERE bookkey = @i_bookkey AND firstprintingqty IS NULL and printingkey= @i_printingkey
						)
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Actual Release Quantity not found'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Actual Release Quantity not found'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Actual Release Quantity not found'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Announced_1st_Prtg'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (SELECT estannouncedfirstprint FROM printing WHERE bookkey =@i_bookkey and printingkey= @i_printingkey) IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Estimated Announced 1st Prtg not defined'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Estimated Announced 1st Prtg not defined'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Estimated Announced 1st Prtg not defined'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Announced_1st_Prtg_Actual'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (SELECT announcedfirstprint FROM printing WHERE bookkey =@i_bookkey and printingkey= @i_printingkey) IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Actual Announced 1st Prtg not found'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Actual Announced 1st Prtg not found'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Actual Announced 1st Prtg not found'
						,@i_username
						,getdate()
						)
				END
			END
		END

	EXEC bookverification_check 'LW_Carton_Quantity'
	,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF @mediatypedesc <> 'DIG' AND (NOT EXISTS (
						SELECT 1
						FROM bindingspecs
						WHERE bookkey = @i_bookkey
						) OR EXISTS (
						SELECT cartonqty1
						FROM bindingspecs
						WHERE bookkey = @i_bookkey AND cartonqty1 IS NULL
						) OR (
						EXISTS (
							SELECT cartonqty1
							FROM bindingspecs
							WHERE bookkey = @i_bookkey AND cartonqty1 = 0
							) AND @mediatypedesc = 'NON'
						)) and not exists (select 1 FROM bookedistatus
						WHERE bookkey = @i_bookkey AND
						edistatuscode = 8)
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Carton Quantity Missing. Add Carton Quantity or check Never Send to Eloquence'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Carton Quantity Missing. Add Carton Quantity or check Never Send to Eloquence'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Carton Quantity Missing. Add Carton Quantity or check Never Send to Eloquence'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END




		EXEC bookverification_check 'LW_Media'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF NULLIF((
							SELECT mediatypecode
							FROM bookdetail
							WHERE bookkey = @i_bookkey
							), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Media Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Media Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Media Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_#_of_Audio_Units'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF NULLIF((
							SELECT numcassettes
							FROM audiocassettespecs
							WHERE bookkey = @i_bookkey
							), '') IS NULL AND (
						SELECT mediatypecode
						FROM bookdetail
						WHERE bookkey = @i_bookkey
						) = 1
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,' # of Audio Units Missing. Error because Media Type = Audio.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,' # of Audio Units Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,' # of Audio Units Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Total_Run_Time'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF NULLIF((
							SELECT totalruntime
							FROM audiocassettespecs
							WHERE bookkey = @i_bookkey
							), '') IS NULL AND (
						SELECT mediatypecode
						FROM bookdetail
						WHERE bookkey = @i_bookkey
						) = 1
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Total Run Time Missing. Error because Media Type = Audio.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Total Run Time Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Total Run Time Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Page_Count'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF NULLIF((
							SELECT mediatypecode
							FROM bookdetail
							WHERE bookkey = @i_bookkey
							), '') = 2 AND NULLIF((
							SELECT pagecount
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), '') IS NULL AND NULLIF((
							SELECT tentativepagecount
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Page Count Missing. Error because media type = BOOK.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Page Count Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Page Count Missing. Error because media type = BOOK.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
				ELSE IF NULLIF((
							SELECT pagecount
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), '') IS NULL AND NULLIF((
							SELECT tentativepagecount
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Page Count Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Page Count Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Page Count Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Page_Count_Actual'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF NULLIF((
							SELECT mediatypecode
							FROM bookdetail
							WHERE bookkey = @i_bookkey
							), '') = 2 AND NULLIF((
							SELECT pagecount
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), '') IS NULL AND NULLIF((
							SELECT tentativepagecount
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), '') IS NOT NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Actual Page Count Unchecked.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Actual Page Count Unchecked.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Actual Page Count Unchecked.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Insert_/_Illus.'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF NULLIF((
							SELECT actualinsertillus
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), '') IS NULL AND NULLIF((
							SELECT estimatedinsertillus
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Insert / Illus. Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Insert / Illus. Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Insert / Illus. Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Insert_/_Illus._Actual'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF NULLIF((
							SELECT actualinsertillus
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Insert / Illus. Actual Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Insert / Illus. Actual Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Insert / Illus. Actual Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Format'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif((
							SELECT mediatypesubcode
							FROM bookdetail
							WHERE bookkey = @i_bookkey
							), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Format Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Format Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Format Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Other_Format'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif((
							SELECT formatchildcode
							FROM booksimon
							WHERE bookkey = @i_bookkey
							), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Other Format Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Other Format Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Other Format Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Trim_w_x_l'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF @mediatypedesc = 'NON' AND NULLIF((
							SELECT trimsizewidth
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), '') IS NULL AND NULLIF((
							SELECT esttrimsizewidth
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Trim Size Missing. Error Because product type = Physical.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Trim Size Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Trim Size Missing.'
						,@i_username
						,getdate()
						)
				END
				ELSE IF @mediatypedesc = 'DIG' AND NULLIF((
							SELECT trimsizewidth
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), '') IS NULL AND NULLIF((
							SELECT esttrimsizewidth
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Trim Size Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Trim Size Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Trim Size Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Product_Size_Actual'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF @mediatypedesc = 'NON' AND NULLIF((
							SELECT trimsizewidth
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), '') IS NULL AND NULLIF((
							SELECT esttrimsizewidth
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), '') IS NOT NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Product Size Actual Unchecked.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Product Size Actual Unchecked.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Product Size Actual Unchecked.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Spine_Size'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF @mediatypedesc = 'NON' AND NULLIF((
							SELECT spinesize
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Spine Size missing. Error because product type = Physical.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Spine Size missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Spine Size missing. Error because product type = Physical.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
				ELSE IF @mediatypedesc = 'DIG' AND NULLIF((
							SELECT spinesize
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Spine Size missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Spine Size missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Spine Size missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Weight'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF @mediatypedesc = 'NON' AND NULLIF((
							SELECT bookweight
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Weight missing. Error because product type = Physical.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Weight missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Weight missing.'
						,@i_username
						,getdate()
						)
				END
				ELSE IF @mediatypedesc = 'DIG' AND NULLIF((
							SELECT bookweight
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Weight missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Weight missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Weight missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Barcode_multiple_entry'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF @mediatypedesc = 'NON' AND NULLIF((
							SELECT barcodeid1
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), 0) IS NULL AND NULLIF((
							SELECT barcodeid2
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), 0) IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Barcode missing. Error because product type = Physical.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Barcode missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Barcode missing. Error because product type = Physical.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
				ELSE IF @mediatypedesc = 'DIG' AND NULLIF((
							SELECT barcodeid1
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), 0) IS NULL AND NULLIF((
							SELECT barcodeid2
							FROM printing
							WHERE bookkey = @i_bookkey and printingkey= @i_printingkey
							), 0) IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Barcode missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Barcode missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Barcode missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Advance_Copy_Code'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 307, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Advance Copy Code Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Advance Copy Code Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Advance Copy Code Missing'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Return_Status'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 50, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Return Status Missing'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'Return Status Missing'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Return Status Missing'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Return_Flag'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 309, 'long') = 'No'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Return Flag Unchecked.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Return Flag Unchecked.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Return Flag Unchecked.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Auto_Release'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 52, 'long') = 'No'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Auto Release Unchecked.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Auto Release Unchecked.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Auto Release Unchecked.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Minimum_Order_Quantity'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 58, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Minimum Order Quantity Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Minimum Order Quantity Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Minimum Order Quantity Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Number_of_Backorder_Days'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 310, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Number of Backorder Days Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Error
						,'Number of Backorder Days Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Number of Backorder Days Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Obsolescence_Date'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF NULLIF((
							SELECT activedate
							FROM taqprojecttask
							WHERE datetypecode = 471 AND bookkey = @i_bookkey
							), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Obsolescence Date active date missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Obsolescence Date active date missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Obsolescence Date active date missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_ISRC'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (dbo.rpt_get_misc_value_gentable(@i_bookkey, 45, 24, 'external')) = 599 AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 312, 'text'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'ISRC missing. Error because Product Type=MP3 Digital Music.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'ISRC missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'ISRC missing. Error because Product Type=MP3 Digital Music.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
				ELSE IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 312, 'text'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'ISRC missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'ISRC missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'ISRC missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

				EXEC bookverification_check 'LW_LWW_Version_#'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (dbo.rpt_get_misc_value_gentable(@i_bookkey, 379, 34, 'external')) = 52 AND (
						SELECT dbo.rpt_get_misc_value_gentable(@i_bookkey, 289, 93, 'external')
						) = '10352' AND nullif(dbo.rpt_get_misc_value_gentable(@i_bookkey, 274, 95, 'external'), '') = '15485' AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 313, 'text'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'LWW Version # missing. Error because (Sales Class = 52 and RC = 10352 and Solution Family = WORSHIP PROJECT).'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'LWW Version # Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'LWW Version # Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
				ELSE IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 313, 'text'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'LWW Version # Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'LWW Version # Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'LWW Version # Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END


		EXEC bookverification_check 'LW_Duration'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (dbo.rpt_get_misc_value_gentable(@i_bookkey, 45, 24, 'external') IN (510, 560)) AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 370, 'text'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Duration missing. Error because (Product Type = Choral Scores or Product Type = Anthems).'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Duration missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Duration Missing.'
						,@i_username
						,getdate()
						)
				END
				ELSE IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 370, 'text'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Duration missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Duration missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Duration Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Voicing'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (dbo.rpt_get_misc_value_gentable(@i_bookkey, 45, 24, 'external') IN (510, 560)) AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 320, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Voicing missing. Error because (Product Type = Choral Scores or Product Type = Anthems) .'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Voicing missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Voicing missing.'
						,@i_username
						,getdate()
						)
				END
				ELSE IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 320, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Voicing missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Voicing missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Voicing missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Genre'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (dbo.rpt_get_misc_value_gentable(@i_bookkey, 45, 24, 'external') IN (510, 560)) AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 326, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Genre missing. Error because (Product Type = Choral Scores or Product Type = Anthems) .'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Genre missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Genre missing.'
						,@i_username
						,getdate()
						)
				END
				ELSE IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 326, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Genre missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Genre missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Genre missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Time_Signature'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (dbo.rpt_get_misc_value_gentable(@i_bookkey, 45, 24, 'external') IN (510, 560)) AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 373, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Time Signature missing. Error because product type in (Choral Scores, Anthems)'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Time Signature missing'
						,@i_username
						,getdate()
						)
				END
				ELSE IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 373, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Time Signature missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Time Signature missing'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Tempo'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (dbo.rpt_get_misc_value_gentable(@i_bookkey, 45, 24, 'external') IN (510, 560)) AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 374, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Tempo missing. Error because product type in (Choral Scores, Anthems)'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Tempo missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Tempo missing'
						,@i_username
						,getdate()
						)
				END
				ELSE IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 374, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Tempo missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Tempo missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Tempo missing'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Keys'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (dbo.rpt_get_misc_value_gentable(@i_bookkey, 45, 24, 'external') = 560) AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 318, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Keys Missing. Error because Product Type = Anthems'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Keys Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Keys Missing.'
						,@i_username
						,getdate()
						)
				END
				ELSE IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 318, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Keys Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Keys Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Keys Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_#_of_Selections/Songs'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (dbo.rpt_get_misc_value_gentable(@i_bookkey, 45, 24, 'external') IN (510, 560, 570, 593, 525)) AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 371, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'# of Songs Missing. Error because  Product Type in (Choral Scores, Anthems, Organ Music, Piano Music, Vocal Solo Collections) '
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'# of Songs Missing. '
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'# of Songs Missing. '
						,@i_username
						,getdate()
						)
				END
				ELSE IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 371, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'# of Songs Missing. '
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'# of Songs Missing. '
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'# of Songs Missing. '
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Music_Series'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (dbo.rpt_get_misc_value_gentable(@i_bookkey, 45, 24, 'external') = 573 OR (dbo.rpt_get_misc_value_gentable(@i_bookkey, 379, 34, 'external')) = 20 AND dbo.rpt_get_misc_value_gentable(@i_bookkey, 45, 24, 'external') = 145) AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 316, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Music Series Missing. Error because (Product Type = Orchestration (non-accomp)) or (Sales Class = 20 and Product Type = Magazines)'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Music Series Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Music Series Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
				ELSE IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 316, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Music Series Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Music Series Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Music Series Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Difficulty_Level'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (dbo.rpt_get_misc_value_gentable(@i_bookkey, 45, 24, 'external') IN (510, 560, 573)) AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 317, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Difficulty Level Missing. Error because  (Product Type = Anthems or Product Type = Choral Scores or Product Type = Orchestration (non-accomp))'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Difficulty Level Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Difficulty Level Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
				ELSE IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 317, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Difficulty Level Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Difficulty Level Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Difficulty Level Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		--EXEC bookverification_check 'LW_Credits'
		--	,@i_write_msg OUTPUT

		--IF @i_write_msg = 1
		--BEGIN
		--	IF @i_verificationtypecode = 10
		--	BEGIN
		--		IF (dbo.rpt_get_misc_value_gentable(@i_bookkey, 45, 24, 'external') IN (510, 588, 585) AND (dbo.rpt_get_misc_value_gentable(@i_bookkey, 379, 34, 'external')) = 30) AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 322, 'long'), '') IS NULL
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'Product Copyright Missing. Error because ((Sales Class = 30 and (Product Type = Choral Scores or Product Type = Listening CD or Product Type = Performance CD))'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Information
		--				,'Product Copyright Missing'
		--				,@i_username
		--				,getdate()
		--				)

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Warning
		--				,'Product Copyright Missing'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings_prod = 1
		--		END
		--		ELSE IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 322, 'text'), '') IS NULL
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Information
		--				,'Product Copyright Missing'
		--				,@i_username
		--				,getdate()
		--				)

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Information
		--				,'Product Copyright Missing'
		--				,@i_username
		--				,getdate()
		--				)

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Warning
		--				,'Product Copyright Missing'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings_prod = 1
		--		END
		--	END
		--END
	
EXEC bookverification_check 'LW_Song_Copyright'
	,@i_write_msg OUTPUT
	--select *  FROM bookcomments
IF @i_write_msg = 1
BEGIN
	IF @i_verificationtypecode = 10
	BEGIN
		IF dbo.rpt_get_misc_value_gentable(@i_bookkey, 51, 30, 'external') IN ('YMI', 'YBI') AND (
				SELECT count(1)
				FROM bookcomments
				WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey AND commenttypecode = 3 AND commenttypesubcode = 93
				) = 0
		BEGIN
			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Delivery*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@i_verificationtypecode
				,@v_Error
				,'LW Song Copyright (FINAL) COMMENT Missing. Error because Royalty Item IN (YMI,YBI).'
				,@i_username
				,getdate()
				)

			SET @v_failed = 1

			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Development*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@v_vertypecode_dev
				,@v_Warning
				,'LW Song Copyright (FINAL) COMMENT Missing. Warning because Royalty Item IN (YMI,YBI).'
				,@i_username
				,getdate()
				)

			SET @v_varnings_dev = 1

			EXEC get_next_key @i_username
				,@v_nextkey OUT /*Production*/

			INSERT INTO bookverificationmessage
      (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
			VALUES (
				@v_nextkey
				,@i_bookkey
				,@v_vertypecode_prod
				,@v_Error
				,'LW Song Copyright (FINAL) COMMENT Missing. Error because Royalty Item IN (YMI,YBI).'
				,@i_username
				,getdate()
				)

			SET @v_failed_prod = 1
		END
	END
END


		EXEC bookverification_check 'LW_Scripture_Tags'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value_gentable(@i_bookkey, 45, 24, 'external') = 560 AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 375, 'text'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Scripture Tags Missing. Error because Product Type = Anthems.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Scripture Tags Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Scripture Tags Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
				ELSE IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 375, 'text'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Scripture Tags Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Scripture Tags Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Scripture Tags Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Thematic_Tags'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value_gentable(@i_bookkey, 45, 24, 'external') = 560 AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 324, 'text'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Thematic Tags Missing. Error because Product Type = Anthems'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Thematic Tags Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Thematic Tags Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
				ELSE IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 324, 'text'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Thematic Tags Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Thematic Tags Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Thematic Tags Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Audience_Role'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 329, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Ministry Role Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Ministry Role Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Ministry Role Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		--EXEC bookverification_check 'LW_Brief_Description_Final_/_Approved'
		--	,@i_write_msg OUTPUT

		--IF @i_write_msg = 1
		--BEGIN
		--	IF @i_verificationtypecode = 10
		--	BEGIN
		--		IF dbo.rpt_get_misc_value(@i_bookkey, 86, 'long') = 'No'
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'Brief Description Final/Approved Missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Information
		--				,'Brief Description Final/Approved Missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Warning
		--				,'Brief Description Final/Approved Missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings_prod = 1
		--		END
		--	END
		--END

		EXEC bookverification_check 'LW_Marketing_Plan_Available'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 90, 'long') = 'No'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Marketing Plan Available missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Marketing Plan Available missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Marketing Plan Available missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Promo_Videos_Available'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 91, 'long') = 'No'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Promo Videos Available missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Promo Videos Available missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Promo Videos Available missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Send_to_Eloquence'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF EXISTS (
						SELECT sendtoeloind
						FROM book
						WHERE bookkey = @i_bookkey AND sendtoeloind = 0
						)
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Send to Eloquence not checked'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Send to Eloquence not checked'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Send to Eloquence not checked'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Never_Send_to_Eloquence'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (
						SELECT count(*)
						FROM bookedistatus
						WHERE bookkey = @i_bookkey AND edistatuscode = 8
						) = 0
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Never Send to Eloquence not checked'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Never Send to Eloquence not checked'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Never Send to Eloquence not checked'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Customer'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (
						SELECT count(*)
						FROM book
						WHERE bookkey = @i_bookkey AND elocustomerkey IS NULL
						) > 0
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Elo Customer Not Found.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Elo Customer Not Found.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Elo Customer Not Found.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_CHO_Age_Group'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 330, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'CHO Age Group Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'CHO Age Group Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'CHO Age Group Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_CHO_Product_Family'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 331, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'CHO Product Family Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'CHO Product Family Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'CHO Product Family Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_CHO_Format'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 332, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'CHO Format Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'CHO Format Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'CHO Format Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_CHO_Bundled_By'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 333, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'CHO Bundled By Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'CHO Bundled By Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'CHO Bundled By Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_CHO_Translation'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 334, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'CHO Translation Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'CHO Translation Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'CHO Translation Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_CHO_Variant_Translation'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 335, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'CHO Variant Translation Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'CHO Variant Translation Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'CHO Variant Translation Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_CHO_Language'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 336, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'CHO Language Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'CHO Language Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'CHO Language Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Order_Form_ID'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 337, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Order Form ID Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Order Form ID Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Order Form ID Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Order_Form_Ref_ID'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 338, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Order Form Ref ID Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Order Form Ref ID Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Order Form Ref ID Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Order_Form_Discount_Indicator'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 339, 'long') = 'No'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Order Form Discount Indicator Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Order Form Discount Indicator Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Order Form Discount Indicator Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_CHO_Category_Sort_ID'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 340, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'CHO Category Sort ID Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'CHO Category Sort ID Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'CHO Category Sort ID Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_CHO_Item_Sort_ID'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 341, 'text'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'CHO Item Sort ID Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'CHO Item Sort ID Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'CHO Item Sort ID Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_ETB_Age_Group'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value_gentable(@i_bookkey, 271, 63, 'external') = 'ETB' AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 342, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'ETB Age Group Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'ETB Age Group Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'ETB Age Group Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_BSFL_Age_Group'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value_gentable(@i_bookkey, 271, 63, 'external') = 'BSFL' AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 343, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'BSFL Age Group Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'BSFL Age Group Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'BSFL Age Group Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_TGP_Age_Group'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value_gentable(@i_bookkey, 271, 63, 'external') = 'TGP' AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 344, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'TGP Age Group Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'TGP Age Group Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'TGP Age Group Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Setting'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 321, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Setting Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Setting Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Setting Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Renewal_Frequency'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 346, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Renewal Frequency Missing'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Renewal Frequency Missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Renewal Frequency Missing'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Contract_Term_Frequency'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 347, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Contract Term Frequency Missing'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Contract Term Frequency Missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Contract Term Frequency Missing'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Auto_Renew'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 348, 'long') = 'No'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Auto Renew Missing'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Auto Renew Missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Auto Renew Missing'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Payment_Frequency'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 349, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Payment Frequency Missing'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Payment Frequency Missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Payment Frequency Missing'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Maximum_License_Seats'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 350, 'text'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Maximum License Seats Missing'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Maximum License Seats Missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Maximum License Seats Missing'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Minimum_License_Seats'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 351, 'text'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Minimum License Seats Missing'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Minimum License Seats Missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Minimum License Seats Missing'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Release_to_Trade_Partners'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 352, 'long') = 'No'
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Release to Trade Partners Unchecked.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Release to Trade Partners Unchecked.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Release to Trade Partners Unchecked.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Release_to_Trade_Website'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 353, 'long') = 'No'
				AND  EXISTS(select 1 from bookmisc where bookkey=@i_bookkey and misckey=352 and longvalue is not null)
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Release to Trade Website Unchecked.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Release to Trade Website Unchecked.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Release to Trade Website Unchecked.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Returnable_from_Trade'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF dbo.rpt_get_misc_value(@i_bookkey, 354, 'long') = 'No'
				AND  EXISTS(select 1 from bookmisc where bookkey=@i_bookkey and misckey=352 and longvalue is not null)
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Returnable from Trade Unchecked.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Returnable from Trade Unchecked.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Returnable from Trade Unchecked.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		--EXEC bookverification_check 'LW_Trade_Discount'
		--	,@i_write_msg OUTPUT

		--IF @i_write_msg = 1
		--BEGIN
		--	IF @i_verificationtypecode = 10
		--	BEGIN
		--		IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 356, 'float'), '') IS NULL
		--		AND  EXISTS(select 1 from bookmisc where bookkey=@i_bookkey and misckey=352 and longvalue is not null)
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'Trade Discount Missing'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Information
		--				,'Trade Discount Missing'
		--				,@i_username
		--				,getdate()
		--				)

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Warning
		--				,'Trade Discount Missing'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings_prod = 1
		--		END
		--	END
		--END

		EXEC bookverification_check 'LW_Full_Trade_Title'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 357, 'text'), '') IS NULL
				AND  EXISTS(select 1 from bookmisc where bookkey=@i_bookkey and misckey=352 and longvalue is not null)
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Full Trade Title Missing'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Full Trade Title Missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Full Trade Title Missing'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		--EXEC bookverification_check 'LW_Trade_Description'
		--	,@i_write_msg OUTPUT

		--IF @i_write_msg = 1
		--BEGIN
		--	IF @i_verificationtypecode = 10
		--	BEGIN
		--		IF NOT EXISTS(select 1 from bookcomments where bookkey=@i_bookkey and commenttypecode=1 and commenttypesubcode=81)
		--		AND EXISTS(select 1 from bookmisc where bookkey=@i_bookkey and misckey=352 and longvalue is not null)
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'Trade Description Missing'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Information
		--				,'Trade Description Missing'
		--				,@i_username
		--				,getdate()
		--				)

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Warning
		--				,'Trade Description Missing'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings_prod = 1
		--		END
		--	END
		--END

		--EXEC bookverification_check 'LW_ASIN'
		--	,@i_write_msg OUTPUT

		--IF @i_write_msg = 1
		--BEGIN
		--	IF @i_verificationtypecode = 10
		--	BEGIN
		--		IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 359, 'text'), '') IS NULL
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Warning
		--				,'ASIN Missing'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Information
		--				,'ASIN Missing'
		--				,@i_username
		--				,getdate()
		--				)

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Warning
		--				,'ASIN Missing'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings_prod = 1
		--		END
		--	END
		--END

		--EXEC bookverification_check 'LW_Title_Territory'
		--	,@i_write_msg OUTPUT

		--IF @i_write_msg = 1
		--BEGIN
		--	IF @i_verificationtypecode = 10
		--	BEGIN
		--		IF nullif((
		--					SELECT currentterritorycode
		--					FROM territoryrights
		--					WHERE bookkey = @i_bookkey AND currentterritorycode <> 0
		--					), '') IS NULL
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'Title Territory missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Information
		--				,'Title Territory missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Warning
		--				,'Title Territory missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings_prod = 1
		--		END
		--	END
		--END

		EXEC bookverification_check 'LW_Exclusivity'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif((
							SELECT top 1 exclusivecode
							FROM territoryrights
							WHERE bookkey = @i_bookkey AND exclusivecode <> 0 order by lastmaintdate desc
							), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Exclusivity missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Exclusivity missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Exclusivity missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		--EXEC bookverification_check 'LW_Supply_to_Region'
		--	,@i_write_msg OUTPUT
		--IF @i_write_msg = 1
		--BEGIN
		--	IF @i_verificationtypecode = 10
		--	BEGIN
		--		IF nullif(dbo.LW_bookdetail_info_check(@i_bookkey, 'crc'), '') IS NULL
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'Supply to Region missing.'
		--				,@i_username
		--				,getdate()
		--				)
		--			SET @v_failed = 1
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Information
		--				,'Supply to Region missing.'
		--				,@i_username
		--				,getdate()
		--				)
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/
		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Warning
		--				,'Supply to Region missing.'
		--				,@i_username
		--				,getdate()
		--				)
		--			SET @v_varnings_prod = 1
		--		END
		--	END
		--END
		EXEC bookverification_check 'LW_Discount'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.LW_bookdetail_info_check(@i_bookkey, 'dc'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Discount missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Discount missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Discount missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Restrictions'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.LW_bookdetail_info_check(@i_bookkey, 'rsc'), '') IS NULL and not exists (select 1 FROM bookedistatus
						WHERE bookkey = @i_bookkey AND
						edistatuscode = 8)
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Restrictions missing. Add restriction or check Never Send to Eloquence'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Restrictions missing. Add restriction or check Never Send to Eloquence'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Restrictions missing. Add restriction or check Never Send to Eloquence'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Copyright_Year'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.LW_bookdetail_info_check(@i_bookkey, 'cry'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Copyright Year missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Copyright Year missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Copyright Year missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Type'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF NOT EXISTS (
						SELECT titletypecode
						FROM book
						WHERE bookkey = @i_bookkey AND titletypecode IS NOT NULL
						)
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Type missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Type missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Type missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Returns'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.LW_bookdetail_info_check(@i_bookkey, 'rc'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Returns missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Returns missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Returns missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Derive_from_Contract'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.LW_bookdetail_info_check(@i_bookkey, 'tdfc'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Derive from Contract missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Derive from Contract missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Derive from Contract missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Publish_to_Web'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (
						SELECT nullif(publishtowebind, 0)
						FROM bookdetail
						WHERE bookkey = @i_bookkey
						) IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Publish to Web Unchecked'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Age_Range'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (
						SELECT count(*)
						FROM bookdetail
						WHERE bookkey = @i_bookkey AND ((((nullif(agehigh, '') IS NOT NULL) OR (nullif(agehighupind, '') IS NOT NULL AND agehighupind <> 0)) AND ((nullif(agelow, '') IS NOT NULL) OR (nullif(agelowupind, '') IS NOT NULL AND agelowupind <> 0))) OR (allagesind <> 0 AND nullif(allagesind, '') IS NOT NULL))
						) < 1
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Age range not correctly defined.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Age range not correctly defined.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Age range not correctly defined.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Grade_Range_______to________'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (
						SELECT count(*)
						FROM bookdetail
						WHERE bookkey = @i_bookkey AND (((nullif(gradehigh, '') IS NOT NULL) OR (nullif(gradehighupind, '') IS NOT NULL AND gradehighupind <> 0)) AND ((nullif(gradelow, '') IS NOT NULL) OR (nullif(gradelowupind, '') IS NOT NULL AND gradelowupind <> 0)))
						) < 1
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Grade range not correctly defined.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Grade range not correctly defined.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Grade range not correctly defined.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Language'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.LW_bookdetail_info_check(@i_bookkey, 'lc'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Language Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Language Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'Language Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Oracle*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_oracle
						,@v_Warning
						,'Language Missing'
						,@i_username
						,getdate()
						)

					SET @v_varnings_oracle = 1
				END
			END
		END

		EXEC bookverification_check 'LW_Legacy_Territory'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif((
							SELECT territoriescode
							FROM book
							WHERE bookkey = @i_bookkey
							), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Information
						,'Legacy Territory missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Legacy Territory missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Legacy Territory missing'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Origin'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.LW_bookdetail_info_check(@i_bookkey, 'o'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'Origin Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Origin Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Information
						,'Origin Missing.'
						,@i_username
						,getdate()
						)
				END
			END
		END

		EXEC bookverification_check 'LW_Audience'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_audience(@i_bookkey, 'B', 1), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'Audience Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'Audience Missing.'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'Audience Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		--EXEC bookverification_check 'LW_Apple_Release_Type'
		--	,@i_write_msg OUTPUT

		--IF @i_write_msg = 1
		--BEGIN
		--	IF @i_verificationtypecode = 10
		--	BEGIN
		--		IF @mediatypedesc = 'DIG' AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 34, 'long'), '') IS NULL
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'Apple Release Type Missing. Error because Digital.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Information
		--				,'Apple Release Type Missing. '
		--				,@i_username
		--				,getdate()
		--				)

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Error
		--				,'Apple Release Type Missing. Error because Digital.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed_prod = 1
		--		END
		--		ELSE IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 34, 'long'), '') IS NULL
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Warning
		--				,'Apple Release Type Missing. '
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Warning
		--				,'Apple Release Type Missing. '
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings_prod = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Information
		--				,'Apple Release Type Missing. '
		--				,@i_username
		--				,getdate()
		--				)
		--		END
		--	END
		--END

		--EXEC bookverification_check 'LW_Apple_ID'
		--	,@i_write_msg OUTPUT

		--IF @i_write_msg = 1
		--BEGIN
		--	IF @i_verificationtypecode = 10
		--	BEGIN
		--		IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 34, 'long'), '') IS NOT NULL AND nullif(dbo.rpt_get_misc_value(@i_bookkey, 360, 'text'), '') IS NULL
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Error
		--				,'Apple ID Missing. Error because Apple Release type is filled in.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_failed = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Information
		--				,'Apple ID Missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Warning
		--				,'Apple ID Missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings_prod = 1
		--		END
		--		ELSE IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 360, 'text'), '') IS NULL
		--		BEGIN
		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Delivery*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@i_verificationtypecode
		--				,@v_Warning
		--				,'Apple ID Missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings = 1

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Development*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_dev
		--				,@v_Information
		--				,'Apple ID Missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			EXEC get_next_key @i_username
		--				,@v_nextkey OUT /*Production*/

		--			INSERT INTO bookverificationmessage
		--			VALUES (
		--				@v_nextkey
		--				,@i_bookkey
		--				,@v_vertypecode_prod
		--				,@v_Warning
		--				,'Apple ID Missing.'
		--				,@i_username
		--				,getdate()
		--				)

		--			SET @v_varnings_prod = 1
		--		END
		--	END
		--END

		EXEC bookverification_check 'LW_License_Assignment_Type'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 363, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'License Assignment Type Missing'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'License Assignment Type Missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'License Assignment Type Missing'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_License_Type'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 364, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'License Type Missing'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'License Type Missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'License Type Missing'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_License_Expire_Days'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_misc_value(@i_bookkey, 365, 'long'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'License Expire Days Missing'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Information
						,'License Expire Days Missing'
						,@i_username
						,getdate()
						)

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Warning
						,'License Expire Days Missing'
						,@i_username
						,getdate()
						)

					SET @v_varnings_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_BISAC_Subjects'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF nullif(dbo.rpt_get_bisac_subject(@i_bookkey, 1, 'B'), '') IS NULL
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Error
						,'BISAC Subject Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Development*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_dev
						,@v_Warning
						,'BISAC Subject Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings_dev = 1

					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Production*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@v_vertypecode_prod
						,@v_Error
						,'BISAC Subject Missing.'
						,@i_username
						,getdate()
						)

					SET @v_failed_prod = 1
				END
			END
		END

		EXEC bookverification_check 'LW_MK_FINAL_Online_Copy_Description_Long'
			,@i_write_msg OUTPUT

		IF @i_write_msg = 1
		BEGIN
			IF @i_verificationtypecode = 10
			BEGIN
				IF (
						SELECT count(*)
						FROM bookcomments
						WHERE commenttypecode = 1 AND commenttypesubcode = 77 AND bookkey = @i_bookkey
						) < 1
				BEGIN
					EXEC get_next_key @i_username
						,@v_nextkey OUT /*Delivery*/

					INSERT INTO bookverificationmessage
          (messagekey, bookkey, verificationtypecode, messagetypecode, message, lastmaintuser, lastmaintdate)
					VALUES (
						@v_nextkey
						,@i_bookkey
						,@i_verificationtypecode
						,@v_Warning
						,'MK FINAL Online Copy Description (Long) Missing.'
						,@i_username
						,getdate()
						)

					SET @v_varnings = 1
				END
			END
		END

		--END OF CHECKS
		--set datacode for failed status
		SELECT @v_datacode = datacode
		FROM gentables
		WHERE tableid = 513 AND qsicode = 2

		--failed for delivery
		IF @v_failed = 1
		BEGIN
			IF NOT EXISTS (
					SELECT *
					FROM bookverification
					WHERE bookkey = @i_bookkey AND verificationtypecode = @i_verificationtypecode
					)
			BEGIN
				INSERT INTO bookverification
				SELECT @i_bookkey
					,@i_verificationtypecode
					,@v_datacode
					,@i_username
					,getdate()
			END
			ELSE
			BEGIN
				UPDATE bookverification
				SET titleverifystatuscode = @v_datacode
					,lastmaintdate = getdate()
					,lastuserid = @i_username
				WHERE bookkey = @i_bookkey AND verificationtypecode = @i_verificationtypecode
			END
		END

		--failed for development
		IF @v_failed_dev = 1
		BEGIN
			IF NOT EXISTS (
					SELECT *
					FROM bookverification
					WHERE bookkey = @i_bookkey AND verificationtypecode = @v_vertypecode_dev
					)
			BEGIN
				INSERT INTO bookverification
				SELECT @i_bookkey
					,@v_vertypecode_dev
					,@v_datacode
					,@i_username
					,getdate()
			END
			ELSE
			BEGIN
				UPDATE bookverification
				SET titleverifystatuscode = @v_datacode
					,lastmaintdate = getdate()
					,lastuserid = @i_username
				WHERE bookkey = @i_bookkey AND verificationtypecode = @v_vertypecode_dev
			END
		END

		--failed for Production
		IF @v_failed_prod = 1
		BEGIN
			IF NOT EXISTS (
					SELECT *
					FROM bookverification
					WHERE bookkey = @i_bookkey AND verificationtypecode = @v_vertypecode_prod
					)
			BEGIN
				INSERT INTO bookverification
				SELECT @i_bookkey
					,@v_vertypecode_prod
					,@v_datacode
					,@i_username
					,getdate()
			END
			ELSE
			BEGIN
				UPDATE bookverification
				SET titleverifystatuscode = @v_datacode
					,lastmaintdate = getdate()
					,lastuserid = @i_username
				WHERE bookkey = @i_bookkey AND verificationtypecode = @v_vertypecode_prod
			END
		END

		--failed for Oracle
		IF @v_failed_oracle = 1
		BEGIN
			IF NOT EXISTS (
					SELECT *
					FROM bookverification
					WHERE bookkey = @i_bookkey AND verificationtypecode = @v_vertypecode_oracle
					)
			BEGIN
				INSERT INTO bookverification
				SELECT @i_bookkey
					,@v_vertypecode_oracle
					,@v_datacode
					,@i_username
					,getdate()
			END
			ELSE
			BEGIN
				UPDATE bookverification
				SET titleverifystatuscode = @v_datacode
					,lastmaintdate = getdate()
					,lastuserid = @i_username
				WHERE bookkey = @i_bookkey AND verificationtypecode = @v_vertypecode_oracle
			END

				IF NOT EXISTS (
						SELECT *
						FROM bookmisc
						WHERE bookkey = @i_bookkey AND misckey = 59
						)
				BEGIN
					INSERT INTO bookmisc (
						bookkey
						,misckey
						,longvalue
						,lastuserid
						,lastmaintdate
						,sendtoeloquenceind
						)
					SELECT @i_bookkey
						,59
						,3
						,'fbt_oracle_verif'
						,GETDATE()
						,0
				END
				ELSE
				BEGIN
					UPDATE bookmisc
					SET longvalue = 3
						,lastuserid = 'fbt_oracle_verif'
						,lastmaintdate = GETDATE()
					WHERE bookkey = @i_bookkey AND misckey = 59
				END

			IF @v_failed_dev = 1
			BEGIN
				UPDATE book
				SET titlestatuscode = NULL
				WHERE bookkey = @i_bookkey
			END
		END

		--passed with warnings
		SELECT @v_datacode = datacode
		FROM gentables
		WHERE tableid = 513 AND qsicode = 4

		--Passed with Warnings for delivery
		IF @v_failed = 0 AND @v_varnings = 1
		BEGIN
			IF NOT EXISTS (
					SELECT *
					FROM bookverification
					WHERE bookkey = @i_bookkey AND verificationtypecode = @i_verificationtypecode
					)
			BEGIN
				INSERT INTO bookverification
				SELECT @i_bookkey
					,@i_verificationtypecode
					,@v_datacode
					,@i_username
					,getdate()
			END
			ELSE
			BEGIN
				UPDATE bookverification
				SET titleverifystatuscode = @v_datacode
					,lastmaintdate = getdate()
					,lastuserid = @i_username
				WHERE bookkey = @i_bookkey AND verificationtypecode = @i_verificationtypecode
			END

			IF (
					SELECT titlestatuscode
					FROM book
					WHERE bookkey = @i_bookkey
					) NOT IN (21, 16)
			BEGIN
				UPDATE book
				SET titlestatuscode = 15
				WHERE bookkey = @i_bookkey
			END
		END

		--Passed with Warnings for development
		IF @v_failed_dev = 0 AND @v_varnings_dev = 1
		BEGIN
			IF NOT EXISTS (
					SELECT *
					FROM bookverification
					WHERE bookkey = @i_bookkey AND verificationtypecode = @v_vertypecode_dev
					)
			BEGIN
				INSERT INTO bookverification
				SELECT @i_bookkey
					,@v_vertypecode_dev
					,@v_datacode
					,@i_username
					,getdate()
			END
			ELSE
			BEGIN
				UPDATE bookverification
				SET titleverifystatuscode = @v_datacode
					,lastmaintdate = getdate()
					,lastuserid = @i_username
				WHERE bookkey = @i_bookkey AND verificationtypecode = @v_vertypecode_dev
			END

			IF @v_failed_prod = 1
			BEGIN
				UPDATE book
				SET titlestatuscode = 13
				WHERE bookkey = @i_bookkey
			END
		END

		--Passed with Warnings for Production
		IF @v_failed_prod = 0 AND @v_varnings_prod = 1
		BEGIN
			IF NOT EXISTS (
					SELECT *
					FROM bookverification
					WHERE bookkey = @i_bookkey AND verificationtypecode = @v_vertypecode_prod
					)
			BEGIN
				INSERT INTO bookverification
				SELECT @i_bookkey
					,@v_vertypecode_prod
					,@v_datacode
					,@i_username
					,getdate()
			END
			ELSE
			BEGIN
				UPDATE bookverification
				SET titleverifystatuscode = @v_datacode
					,lastmaintdate = getdate()
					,lastuserid = @i_username
				WHERE bookkey = @i_bookkey AND verificationtypecode = @v_vertypecode_prod
			END

			IF @v_failed = 1
			BEGIN
				UPDATE book
				SET titlestatuscode = 14
				WHERE bookkey = @i_bookkey
			END
		END

		--Passed with Warnings for Oracle
		IF @v_failed_oracle = 0 AND @v_varnings_oracle = 1
		BEGIN
			IF NOT EXISTS (
					SELECT *
					FROM bookverification
					WHERE bookkey = @i_bookkey AND verificationtypecode = @v_vertypecode_oracle
					)
			BEGIN
				INSERT INTO bookverification
				SELECT @i_bookkey
					,@v_vertypecode_oracle
					,@v_datacode
					,@i_username
					,getdate()
			END
			ELSE
			BEGIN
				UPDATE bookverification
				SET titleverifystatuscode = @v_datacode
					,lastmaintdate = getdate()
					,lastuserid = @i_username
				WHERE bookkey = @i_bookkey AND verificationtypecode = @v_vertypecode_oracle
			END
			
			IF NOT EXISTS (
						SELECT *
						FROM bookmisc
						WHERE bookkey = @i_bookkey AND misckey = 59
						)
				BEGIN
					INSERT INTO bookmisc (
						bookkey
						,misckey
						,longvalue
						,lastuserid
						,lastmaintdate
						,sendtoeloquenceind
						)
					SELECT @i_bookkey
						,59
						,1
						,'fbt_oracle_verif'
						,GETDATE()
						,0
				END
				ELSE
				BEGIN
					UPDATE bookmisc
					SET longvalue = 1
						,lastuserid = 'fbt_oracle_verif'
						,lastmaintdate = GETDATE()
					WHERE bookkey = @i_bookkey AND misckey = 59
				END

			IF @v_failed_dev = 1
			BEGIN
				UPDATE book
				SET titlestatuscode = NULL
				WHERE bookkey = @i_bookkey
			END
		END

		--passed
		SELECT @v_datacode = datacode
		FROM gentables
		WHERE tableid = 513 AND qsicode = 3

		--Passed for delivery
		IF @v_failed = 0 AND @v_varnings = 0
		BEGIN
			IF NOT EXISTS (
					SELECT *
					FROM bookverification
					WHERE bookkey = @i_bookkey AND verificationtypecode = @i_verificationtypecode
					)
			BEGIN
				INSERT INTO bookverification
				SELECT @i_bookkey
					,@i_verificationtypecode
					,@v_datacode
					,@i_username
					,getdate()
			END
			ELSE
			BEGIN
				UPDATE bookverification
				SET titleverifystatuscode = @v_datacode
					,lastmaintdate = getdate()
					,lastuserid = @i_username
				WHERE bookkey = @i_bookkey AND verificationtypecode = @i_verificationtypecode
			END

			IF (
					SELECT titlestatuscode
					FROM book
					WHERE bookkey = @i_bookkey
					) NOT IN (21, 16)
			BEGIN
				UPDATE book
				SET titlestatuscode = 15
				WHERE bookkey = @i_bookkey
			END
		END

		--Passed for development
		IF @v_failed_dev = 0 AND @v_varnings_dev = 0
		BEGIN
			IF NOT EXISTS (
					SELECT *
					FROM bookverification
					WHERE bookkey = @i_bookkey AND verificationtypecode = @v_vertypecode_dev
					)
			BEGIN
				INSERT INTO bookverification
				SELECT @i_bookkey
					,@v_vertypecode_dev
					,@v_datacode
					,@i_username
					,getdate()
			END
			ELSE
			BEGIN
				UPDATE bookverification
				SET titleverifystatuscode = @v_datacode
					,lastmaintdate = getdate()
					,lastuserid = @i_username
				WHERE bookkey = @i_bookkey AND verificationtypecode = @v_vertypecode_dev
			END

			IF @v_failed_prod = 1
			BEGIN
				UPDATE book
				SET titlestatuscode = 13
				WHERE bookkey = @i_bookkey
			END
		END

		--Passed for Production
		IF @v_failed_prod = 0 AND @v_varnings_prod = 0
		BEGIN
			IF NOT EXISTS (
					SELECT *
					FROM bookverification
					WHERE bookkey = @i_bookkey AND verificationtypecode = @v_vertypecode_prod
					)
			BEGIN
				INSERT INTO bookverification
				SELECT @i_bookkey
					,@v_vertypecode_prod
					,@v_datacode
					,@i_username
					,getdate()
			END
			ELSE
			BEGIN
				UPDATE bookverification
				SET titleverifystatuscode = @v_datacode
					,lastmaintdate = getdate()
					,lastuserid = @i_username
				WHERE bookkey = @i_bookkey AND verificationtypecode = @v_vertypecode_prod
			END

			IF @v_failed = 1
			BEGIN
				UPDATE book
				SET titlestatuscode = 14
				WHERE bookkey = @i_bookkey
			END
		END

		--Passed for Oracle
		IF @v_failed_oracle = 0 AND @v_varnings_oracle = 0
		BEGIN
			IF NOT EXISTS (
					SELECT *
					FROM bookverification
					WHERE bookkey = @i_bookkey AND verificationtypecode = @v_vertypecode_oracle
					)
			BEGIN
				INSERT INTO bookverification
				SELECT @i_bookkey
					,@v_vertypecode_oracle
					,@v_datacode
					,@i_username
					,getdate()
			END
			ELSE
			BEGIN
				UPDATE bookverification
				SET titleverifystatuscode = @v_datacode
					,lastmaintdate = getdate()
					,lastuserid = @i_username
				WHERE bookkey = @i_bookkey AND verificationtypecode = @v_vertypecode_oracle
			END

			
				IF NOT EXISTS (
						SELECT *
						FROM bookmisc
						WHERE bookkey = @i_bookkey AND misckey = 59
						)
				BEGIN
					INSERT INTO bookmisc (
						bookkey
						,misckey
						,longvalue
						,lastuserid
						,lastmaintdate
						,sendtoeloquenceind
						)
					SELECT @i_bookkey
						,59
						,1
						,'fbt_oracle_verif'
						,GETDATE()
						,0
				END
				ELSE
				BEGIN
					UPDATE bookmisc
					SET longvalue = 1
						,lastuserid = 'fbt_oracle_verif'
						,lastmaintdate = GETDATE()
					WHERE bookkey = @i_bookkey AND misckey = 59
				END
				
				--select * from bookmiscitems where misckey=59
				--select * from subgentables where tableid=525 and datacode=33

				IF @v_failed_dev = 1
				BEGIN
					UPDATE book
					SET titlestatuscode = NULL
					WHERE bookkey = @i_bookkey
				END
			
		END
	END
	ELSE
		--Set verification status for B&H products to Not Applicable
	BEGIN
		DELETE bookverificationmessage
		WHERE bookkey = @i_bookkey AND verificationtypecode IN (7, 8, 9, 10)

		IF NOT EXISTS (
				SELECT *
				FROM bookverification
				WHERE bookkey = @i_bookkey AND verificationtypecode = 7
				)
		BEGIN
			INSERT INTO bookverification
			SELECT @i_bookkey
				,7
				,8
				,@i_username
				,getdate()
		END

		IF NOT EXISTS (
				SELECT *
				FROM bookverification
				WHERE bookkey = @i_bookkey AND verificationtypecode = 9
				)
		BEGIN
			INSERT INTO bookverification
			SELECT @i_bookkey
				,9
				,8
				,@i_username
				,getdate()
		END

		IF NOT EXISTS (
				SELECT *
				FROM bookverification
				WHERE bookkey = @i_bookkey AND verificationtypecode = 10
				)
		BEGIN
			INSERT INTO bookverification
			SELECT @i_bookkey
				,10
				,8
				,@i_username
				,getdate()
		END

		IF NOT EXISTS (
				SELECT *
				FROM bookverification
				WHERE bookkey = @i_bookkey AND verificationtypecode = 8
				)
		BEGIN
			INSERT INTO bookverification
			SELECT @i_bookkey
				,8
				,8
				,@i_username
				,getdate()
		END
		ELSE
		BEGIN
			UPDATE bookverification
			SET titleverifystatuscode = 8
				,lastmaintdate = getdate()
				,lastuserid = @i_username
			WHERE bookkey = @i_bookkey AND verificationtypecode IN (7, 8, 9, 10)
		END
	END
END

GO
GRANT EXEC on [dbo].[LR_Verification_for_Delivery_Master] to public
go

