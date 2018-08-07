if exists (select * from dbo.sysobjects where id = object_id(N'dbo.maintainOnSaleDateType_PubDate') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop Trigger dbomaintainOnSaleDateType_PubDate
GO

CREATE TRIGGER dbo.maintainOnSaleDateType_PubDate ON [dbo].[taqprojecttask] FOR INSERT, UPDATE
AS 
IF UPDATE (datetypecode) OR 	UPDATE (actualind) OR 	UPDATE (activedate) 
BEGIN

--check if updates are not coming from bookdates trigger
if object_id( 'tempdb..#dont_fire_bookdates' ) is not null begin
	return
end

/********************************************************************************************************
**  Name: MaintainOnSaleDateType_PubDate
**  Desc: Insert OnSale Date + 10 days from Pub Date when Pub Date is added if title is Not Yet Published
**
**  Auth: Josh Blanchette
**  Date: 5/30/18
**  Case: 51179
*********************************************************************************************************/

DECLARE	@v_count INT
DECLARE @v_count2 INT
DECLARE	@v_bookkey INT
DECLARE	@v_printingkey INT
DECLARE	@v_datetypecode	INT 
DECLARE @v_activedate datetime
DECLARE @v_originaldate datetime
DECLARE @v_original_Pub_Date datetime
DECLARE @v_original_OnSale_Date datetime
DECLARE @v_actualind INT
DECLARE	@err_msg VARCHAR(100)
DECLARE @v_new_key INT

	
SELECT 
	@v_bookkey = i.bookkey,
	@v_printingkey = i.printingkey,
	@v_datetypecode = i.datetypecode,
    @v_activedate = i.activedate, 
    @v_originaldate = i.originaldate,
    @v_actualind = i.actualind
FROM inserted i full outer join 
	deleted d on i.bookkey=d.bookkey
	and i.printingkey=d.printingkey
	

if (@v_bookkey is null OR @v_printingkey is null OR @v_datetypecode is null) begin
	return
end
   
	--  Continue only if it's Pub date
IF @v_datetypecode = 8
	BEGIN

		SELECT @v_original_Pub_Date = activedate  --always want latest Pub date
		FROM taqprojecttask
		WHERE bookkey = @v_bookkey
		  AND printingkey = @v_printingkey
		  AND datetypecode = 8
		--  Check if OnSale date should be updated - Bisac Title Status needs to be Not Yet Published
		SELECT @v_count = 0
		SELECT @v_count = count(*)
		FROM bookdetail bd JOIN gentables g ON bd.bisacstatuscode = g.datacode 
		WHERE bookkey = @v_bookkey 
		  AND g.tableid = 314
		  AND g.datacode = 4

		IF @v_count = 1
			BEGIN

				-- check if  there is a row for OnSale Date 
				SELECT @v_count2 = count(*)	
				FROM taqprojecttask
				WHERE bookkey = @v_bookkey
				  AND printingkey = @v_printingkey
				  AND datetypecode = 20003

				-- if @v_count2 = 0 (does not exist), do insert
				IF  @v_count2 = 0
					BEGIN
						-- **inserting into bookdates was not updating titlehistory**
						--INSERT INTO bookdates (bookkey, printingkey, datetypecode, activedate, actualind, lastuserid, lastmaintdate)
						--SELECT @v_bookkey, @v_printingkey, 20003, DATEADD(day, 10, @v_original_Pub_Date),0, 'FBT_OnSaleDate_Trig', getdate()
						
						exec get_next_key 'FBT_OnSaleDateTrig', @v_new_key output
						INSERT INTO taqprojecttask (taqtaskkey, bookkey, datetypecode, activedate, actualind, keyind, originaldate, lastuserid, lastmaintdate, printingkey)
						SELECT @v_new_key, @v_bookkey, 20003, DATEADD(day, 10, @v_original_Pub_Date), 0, 1, @v_original_Pub_Date, 'FBT_OnSale_Trig', getdate(), @v_printingkey

				END  --v_count2 = 0

				--  If @v_count2 = 1 (already exists), do update
				IF @v_count2 = 1
					BEGIN

						UPDATE taqprojecttask
							SET activedate = (select DATEADD(day, 10, @v_original_Pub_Date)),
								actualind = 0,
								lastuserid = 'FBT_OnSaleDate_Trig',
								lastmaintdate = getdate()
							WHERE bookkey = @v_bookkey 
							  AND printingkey = @v_printingkey
							  AND datetypecode = 20003
				END  --v_count2 = 1

				IF @@error != 0
					BEGIN
						  ROLLBACK TRANSACTION
						  select @err_msg = 'Could not update OnSale Date on taqprojecttask table (MaintainOnSaleDateType_PubDate trigger).'
						  print @err_msg
                END
		END  -- @v_count = 1

END  -- datetypecode = 8
END  -- Trigger Creation