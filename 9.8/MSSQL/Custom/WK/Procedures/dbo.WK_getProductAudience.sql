if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getProductAudience') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getProductAudience
GO

CREATE PROCEDURE dbo.WK_getProductAudience
@bookkey int
AS
DECLARE @idField						varchar(512),
		@nameField						varchar(512),
		@paceAudienceField				varchar(512),
		@sequenceField					int,
		@typeField						varchar(512)
BEGIN

SELECT	@idField as idField,
		@nameField as nameField,
		@paceAudienceField as paceAudienceIdField,
		@sequenceField as sequenceField,
		@typeField as typeField

END