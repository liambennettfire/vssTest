
GO

IF EXISTS (SELECT *
			   FROM dbo.sysobjects
			   WHERE id = object_id(N'dbo.[qweb_ProductDelete_APH]')
				   AND objectproperty(id, N'IsProcedure') = 1)
	DROP PROCEDURE dbo.[qweb_ProductDelete_APH]
PRINT 'dropped dbo.[qweb_ProductDelete_APH]'
PRINT 'created dbo.[qweb_ProductDelete_APH]'

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*********************************************************************************************/
/*  Name: [qweb_ProductDelete_APH]															 */
/*  DESC: This stored PROCEDURE deletes all associated data for a given productID			 */
/*																							 */
/*																							 */
/*    Auth: Jonathan Hess																	 */
/*    Date: 10/9/2012																		 */
/*********************************************************************************************/


CREATE PROCEDURE [dbo].[qweb_ProductDelete_APH]
(
    @i_ProductId INT,
    @i_error_desc_detail SMALLINT,
    @o_error_code INT OUTPUT,
    @o_error_desc VARCHAR(2000) OUTPUT
)
AS
	BEGIN
		SET NOCOUNT ON
		DECLARE @Err                                 INT,
                @skuID                               INT,
                @product_type AS                     INT,
                @error_var                           INT,
                @rowcount_var                        INT

		SET @product_type = 1

		--SELECT * FROM product WHERE ProductId = 30000
		--SELECT * FROM ProductEx_Titles pet WHERE ObjectId = 30000
		--SELECT * FROM SkuEx_Title_By_Format setbf WHERE ObjectId IN ( SELECT skuid FROM SKU S WHERE productid = 30000 )
		--SELECT * FROM SKU S WHERE productid = 30000
		--SELECT * FROM Categorization c WHERE c.ObjectId = 30000

		DELETE
			FROM ShoppingCartItem

		DELETE
			FROM [Product]
			WHERE
				[ProductId] = @i_ProductId

		IF @rowcount_var >= 0 AND @i_error_desc_detail = 1
			BEGIN
				SET @o_error_code = @@ERROR
				SET @o_error_desc = @o_error_desc + '-( ' + cast(@rowcount_var
				AS
				VARCHAR)
				+ ' ) rows Deleted, table: [Product] ' + char(13) + char(10)
			END

		EXEC dbo.[mdpsp_avto_ProductEx_Titles_Delete] @i_ProductId


		DELETE
			FROM ObjectLanguage
			WHERE ObjectId = @i_ProductId AND
				ObjectTypeId = @product_type

		DECLARE mycursor CURSOR FORWARD_ONLY
		FOR
		SELECT skuid
			FROM SKU S
			WHERE S.productid = @i_ProductId
		OPEN mycursor

		WHILE (1 = 1)
			BEGIN
				FETCH NEXT FROM mycursor INTO @skuID
				IF @@fetch_status <> 0
					BREAK;

				--EXEC dbo.ShoppingCartItemDelete @skuID
				EXEC dbo.[SKUDelete] @skuID
				EXEC dbo.[mdpsp_avto_SkuEx_Title_By_Format_Delete] @skuID

			END
		CLOSE mycursor
		DEALLOCATE mycursor

		DELETE
			FROM [Categorization]
			WHERE
				ObjectId = @i_ProductId

		SET @Err = @@Error
		RETURN @Err
	END

	SET @o_error_desc = @o_error_desc +
	'/********************ECF Delete Successfull*****************/' + char(13) + char(10)


	SELECT @o_error_code,
		   @o_error_desc

GO

GRANT EXECUTE TO public