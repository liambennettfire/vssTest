if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_set_price_validation_group') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_set_price_validation_group
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_set_price_validation_group
 (@i_bookkey     integer,
  @o_error_code               integer       output,
  @o_error_desc               varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_set_price_validation_group
**  Desc: This sets the pricevalidationgroupcode on bookdetail to clientdefaults.clientdefaultvalue
**           where clientdefaultid = 59 (Price Validation Group).
** 
**
**    Auth: Kusum Basra
**    Date: 21 July 2011
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @v_count	INT
  DECLARE @v_pricevalidationgroupcode	INT
  DECLARE @v_clientdefaultvalue 	INT

  IF @i_bookkey > 0 BEGIN
    SELECT @v_count = 0

    SELECT @v_count = count(*)
       FROM bookdetail 
     WHERE bookkey = @i_bookkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to set price validation group on bookdetail: bookkey = ' + cast(@i_bookkey AS VARCHAR)
      return
    END 

    IF @v_count > 0 
    BEGIN

		 SELECT @v_pricevalidationgroupcode = pricevalidationgroupcode
			  FROM bookdetail 
			WHERE bookkey = @i_bookkey
	
		 IF @v_pricevalidationgroupcode IS NULL OR ltrim(rtrim(@v_pricevalidationgroupcode)) = ' ' 
         BEGIN
			SELECT @v_clientdefaultvalue = clientdefaultvalue
                FROM clientdefaults
			 WHERE clientdefaultid = 59

              UPDATE bookdetail
                   SET pricevalidationgroupcode = @v_clientdefaultvalue
               WHERE bookkey = @i_bookkey
	
			 SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			 IF @error_var <> 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Unable to set price validation group on bookdetail: bookkey = ' + cast(@i_bookkey AS VARCHAR)
				return
			 END 
		  END
		END
	END
    ELSE  
    BEGIN
        SET @o_error_code = -1
		SET @o_error_desc = 'Unable to set price validation group on bookdetail: bookkey = ' + cast(@i_bookkey AS VARCHAR)
		return
    END

 GO

GRANT EXEC ON qtitle_set_price_validation_group TO PUBLIC
GO


