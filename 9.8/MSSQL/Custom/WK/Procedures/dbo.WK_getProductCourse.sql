if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getProductCourse') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_getProductCourse
GO

CREATE PROCEDURE dbo.WK_getProductCourse
@bookkey int
AS
DECLARE @idField						varchar(512),
		@nameField						varchar(512),
		@paceCourseField				varchar(512),
		@sequenceField					int
BEGIN

SELECT	@idField as idField,
		@nameField as nameField,
		@paceCourseField as paceCourseField,
		@sequenceField as sequenceField

END