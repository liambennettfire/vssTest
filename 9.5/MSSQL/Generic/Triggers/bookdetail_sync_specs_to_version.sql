/****** Object:  Trigger [bookdetail_sync_specs_to_version]    Script Date: 01/09/2015 11:43:38 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[bookdetail_sync_specs_to_version]'))
DROP TRIGGER [dbo].[bookdetail_sync_specs_to_version]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE TRIGGER [dbo].[bookdetail_sync_specs_to_version] ON [dbo].[bookdetail]
FOR INSERT, UPDATE AS

BEGIN
  DECLARE
    @v_bookkey  INT,
    @v_printingkey  INT,
    @v_userid VARCHAR(30),
    @i_islocked int

  SELECT @v_bookkey = i.bookkey, @v_userid = lastuserid  --first printings only
  FROM inserted i
  
  set @v_printingkey = 1
  
  --check to make sure the book isn't locked, could be the sync is running so we don't want to get into a loop
  set @i_islocked = 0
  select @i_islocked = count(*) from booklock where bookkey =@v_bookkey and printingkey = @v_printingkey and userid='FBTSYNC' 
  
  IF coalesce(@i_islocked,0)=0
	 -- Call the sync printing to version stored procedure
	begin 
		EXEC qpl_sync_tables2specitems @v_bookkey, @v_printingkey, 'bookdetail', @v_userid
	end
END
go
