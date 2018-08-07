if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_UpdateRequestId') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_UpdateRequestId
GO
CREATE PROCEDURE dbo.WK_UpdateRequestId
@bookkey int,
@RequestId varchar(75),
@type smallint = NULL
AS
BEGIN
/*
If type is null, blank or 1 then update ADV/SLX, misckey = 29
If type = 2 then update PPT, misckey = 47
*/
	IF @type is NULL or @type = '' or @type = 1
		BEGIN
			If EXISTS (Select * FROM bookmisc where bookkey = @bookkey and misckey = 29)
				BEGIN
					UPDATE bookmisc

					SET textvalue = @RequestId, lastmaintdate = getdate()
					WHERE bookkey = @bookkey and misckey = 29
				END
			ELSE
				BEGIN
					INSERT INTO bookmisc
					Select @bookkey, 29, NULL, NULL, @RequestId, 'qsiadmin', getdate(), 0
				END
		END

	IF @type = 2
		BEGIN
			If EXISTS (Select * FROM bookmisc where bookkey = @bookkey and misckey = 47)
				BEGIN
					UPDATE bookmisc
					SET textvalue = @RequestId, lastmaintdate = getdate()
					WHERE bookkey = @bookkey and misckey = 47
				END
			ELSE
				BEGIN
					INSERT INTO bookmisc
					Select @bookkey, 47, NULL, NULL, @RequestId, 'qsiadmin', getdate(), 0
				END
		END


END