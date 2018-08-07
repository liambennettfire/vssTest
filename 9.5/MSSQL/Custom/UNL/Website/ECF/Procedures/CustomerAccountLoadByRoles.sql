USE [UNL_ECFDEV]
GO
/****** Object:  StoredProcedure [dbo].[CustomerAccountLoadByRoles]    Script Date: 10/16/2007 14:22:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CustomerAccountLoadByRoles]
(
	@Roles nvarchar(255)
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Err int
    exec('SELECT DISTINCT
		A.[CustomerId],
		[UserName],
		[Email],
		[PasswordHash],
		[PasswordFormat],
		[PasswordSalt],
		[PasswordQuestion],
		[PasswordAnswer],
		[CreatedDate],
		[LastEditDate],
		[Disabled],
		[ShippingAddressId],
		[BillingAddressId],
		[Contact],
		[UniqueId]
	FROM [CustomerAccount] A
	INNER JOIN CustomerRole R on A.CustomerId = R.CustomerId
	WHERE
		([RoleId] in ('+@Roles+'))')

	SET @Err = @@Error
	RETURN @Err
END
