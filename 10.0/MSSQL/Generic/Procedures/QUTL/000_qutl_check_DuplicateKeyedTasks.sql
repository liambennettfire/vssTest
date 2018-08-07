if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_check_DuplicateKeyedTasks') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_check_DuplicateKeyedTasks
GO

/****** Object:  StoredProcedure [dbo].[qutl_check_DuplicateKeyedTasks]    Script Date: 01/11/2012 10:11:09 ******/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ========================================================================================
-- Author:		mkeyser
-- Create date: 2012.01.11
-- Description:	Adding an Element to a Title may also add a Task Group.  
-- The Task Group can not contain any Keyed Tasks (keyind=1) that already 
-- exist under a Title. This procedure finds such duplicates
-- ========================================================================================

CREATE PROCEDURE [dbo].[qutl_check_DuplicateKeyedTasks] 
	-- Add the parameters for the stored procedure here
	@bookkey int = 0, 
	@taskviewkey int = 0
AS
BEGIN
	SET NOCOUNT ON;

	Select 
		TitleTasks.KEYED
		,TitleTasks.NAME
		,TGTasks.TGName
	From

	(
		SELECT 
			tvdt.keyind as KEYED
			,coalesce(dt.datelabel,dt.description) as NAME
			,tv.taskviewdesc as TGName
		FROM taskview tv
			inner join taskviewdatetype tvdt on tv.taskviewkey=tvdt.taskviewkey
			inner join datetype dt on dt.datetypecode=tvdt.datetypecode
		WHERE tv.taskviewkey=@taskviewkey
	) as TGTasks

	inner join 

	(
		SELECT
			t.keyind as KEYED
			,coalesce(dt.datelabel,dt.description) as NAME
		FROM taqprojecttask t
			inner join book b on t.bookkey=b.bookkey
			inner join datetype dt on dt.datetypecode=t.datetypecode
		WHERE b.bookkey=@bookkey
	) as TitleTasks

	on TitleTasks.NAME=TGTasks.NAME and TitleTasks.KEYED=TGTasks.KEYED and TitleTasks.KEYED=1	
END
GO
GRANT EXEC ON qutl_check_DuplicateKeyedTasks TO PUBLIC
GO
