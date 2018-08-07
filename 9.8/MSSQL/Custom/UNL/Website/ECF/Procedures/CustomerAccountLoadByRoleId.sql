USE [UNL_ECFDEV]
GO
/****** Object:  StoredProcedure [dbo].[CustomerAccountLoadByRoleId]    Script Date: 10/16/2007 14:22:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[CustomerAccountLoadByRoleId]
(
	@RoleId int
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Err int
	SELECT
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
		([RoleId] = @RoleId)
	SET @Err = @@Error
	RETURN @Err
END