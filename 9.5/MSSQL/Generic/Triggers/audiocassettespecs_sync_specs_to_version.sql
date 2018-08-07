SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[audiocassettespecs_sync_specs_to_version]'))
DROP TRIGGER [dbo].[audiocassettespecs_sync_specs_to_version] 
GO

/************************************************************************************************************
**  Name: audiocassettespecs_sync_specs_to_version
**  Desc: Sync the audiocassettespecs to its specification items as well as for the related titles 
**  Auth: Uday A. Khisty
**  Date: 06/30/2016
*************************************************************************************************************
**  Change History
*************************************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    --------------------------------------------------------------------------------
** 
*************************************************************************************************************/


CREATE TRIGGER [dbo].[audiocassettespecs_sync_specs_to_version] ON [dbo].[audiocassettespecs]
AFTER INSERT, UPDATE AS
BEGIN
  DECLARE
    @v_bookkey  INT,
    @v_printingkey  INT,
    @v_userid VARCHAR(30),
    @i_islocked int,
    @v_bookkey_to INT,
    @v_printingkey_to INT,
    @v_tablename       varchar(100),
    @v_columnname      varchar(100),
    @error_var    INT,
    @v_error_code      integer,
    @v_error_desc      varchar,
    @rowcount_var INT

  SELECT @v_bookkey = i.bookkey, @v_printingkey = i.printingkey, @v_userid = lastuserid
  FROM inserted i
  
  --check to make sure the book isn't locked, could be the sync is running so we don't want to get into a loop
  set @i_islocked = 0
  select @i_islocked = count(*) from booklock where bookkey =@v_bookkey and printingkey = @v_printingkey and userid='FBTSYNC' 
  
  IF coalesce(@i_islocked,0)=0 BEGIN
	 -- Call the sync printing to version stored procedure
	EXEC qpl_sync_tables2specitems @v_bookkey, @v_printingkey, 'audiocassettespecs', @v_userid		
	
   END 		
   
	-- need to find all related bookkeys
	DECLARE audiocassettespecs_trigger_cur CURSOR FOR
	 SELECT b.bookkey, c.printingkey 
	 FROM book b INNER JOIN coretitleinfo c ON b.bookkey = c.bookkey and  c.printingkey = 1
     WHERE propagatefrombookkey = @v_bookkey
	  
	OPEN audiocassettespecs_trigger_cur
	FETCH NEXT FROM audiocassettespecs_trigger_cur INTO @v_bookkey_to, @v_printingkey_to
	WHILE (@@FETCH_STATUS <> -1) BEGIN

	  EXEC qpl_sync_tables2specitems @v_bookkey_to, @v_printingkey_to, 'audiocassettespecs', @v_userid

	  FETCH NEXT FROM audiocassettespecs_trigger_cur INTO @v_bookkey_to, @v_printingkey_to
	END

	finished:
	CLOSE audiocassettespecs_trigger_cur
	DEALLOCATE audiocassettespecs_trigger_cur  
	    
END
