IF EXISTS (SELECT * FROM sysobjects WHERE type = 'TR' AND name = 'taqproductnumbers_history')
	BEGIN
		DROP  Trigger dbo.taqproductnumbers_history
	END
GO

CREATE TRIGGER [dbo].taqproductnumbers_history ON [dbo].taqproductnumbers
FOR INSERT, UPDATE, DELETE AS

BEGIN

DECLARE 
  @v_TriggerActionID varchar(20),
  @v_TriggerID INT,
  @v_TableID INT,
  @v_TableName VARCHAR(80),
  @v_insert_row_count int,
  @v_delete_row_count int,
  @v_tranacation_row_total int,
  @v_tranacation_row_pointer int

  -- get table name
  SET @v_TriggerID = @@PROCID
  SELECT @v_TableID = parent_id FROM sys.triggers  WHERE object_id = @v_TriggerID
  SELECT @v_TableName = OBJECT_NAME(@v_TableID)

  select @v_insert_row_count=count(*) from inserted
  select @v_delete_row_count=count(*) from deleted
 
  -- get trigger action type
  if @v_insert_row_count <> 0 and
     @v_delete_row_count = 0 --insert
    begin
      set @v_TriggerActionID='insert'
      set @v_tranacation_row_total=@v_insert_row_count
    end
  if @v_insert_row_count <> 0 and
     @v_delete_row_count <> 0 --update
    begin
      set @v_TriggerActionID='update'
      set @v_tranacation_row_total=@v_insert_row_count
    end
  if @v_insert_row_count = 0 and
     @v_delete_row_count <> 0 --delete
    begin
      set @v_TriggerActionID='delete'
      set @v_tranacation_row_total=@v_delete_row_count
    end 

  set @v_tranacation_row_pointer=1
  -- loop deals with multi row updates
  -- only one row at a time is handed to the stored procedure
  while @v_tranacation_row_total>=@v_tranacation_row_pointer
    begin
      -- get after value for the given table/column to temp table
      SELECT * into #inserted FROM  
        (SELECT Row_Number() OVER (ORDER BY productnumberkey) as transaction_rowid,*  
        FROM inserted) as a  
        where transaction_rowid = @v_tranacation_row_pointer 
    
      -- get before value for the given table/column to temp table
      SELECT * into #deleted FROM  
        (SELECT Row_Number() OVER (ORDER BY productnumberkey) as transaction_rowid,*  
        FROM deleted) as a  
        where transaction_rowid = @v_tranacation_row_pointer 
      
      -- call main history logic
      exec history_sp @v_TableName,@v_TriggerActionID

      drop table #inserted
      drop table #deleted

      set @v_tranacation_row_pointer=@v_tranacation_row_pointer+1 

    end

END
