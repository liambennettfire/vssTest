/******************************************************************************
**  Name: imp_gentables_filter
**  Desc: IKE update gentableorgs
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_gentables_filter]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_gentables_filter]
GO

CREATE PROCEDURE [dbo].[imp_gentables_filter](
				@i_tableid	INT,
				@i_datacode	INT,
				@i_orgentrykey	INT,
				@v_userid	VARCHAR(30))
AS

DECLARE @i_count	INT

SET @i_count = 0

IF @i_tableid > 0 AND @i_datacode > 0 AND @i_orgentrykey > 0
	BEGIN
		SELECT @i_count = COUNT(*) 
		FROM gentablesorglevel
		WHERE tableid = @i_tableid
				AND datacode = @i_datacode 
				AND orgentrykey = @i_orgentrykey

		IF @i_count = 0
			BEGIN
				INSERT INTO gentablesorglevel (tableid,datacode,orgentrykey,lastuserid,lastmaintdate)
				VALUES(@i_tableid,@i_datacode,@i_orgentrykey,@v_userid,GETDATE())
			END
	END
go


