if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_update_tab_by_percent') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_update_tab_by_percent
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_update_tab_by_percent
 (@i_scaletabkey        integer,
  @i_fixedpercent				float,
  @i_variablepercent		float,
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/******************************************************************************
**  Name: qscale_update_tab_by_percent
**  Desc: This procedure updates all the fixed and variable values for the tab by the given percent
**
**	Auth: Dustin Miller
**	Date: April 13 2012
*******************************************************************************/

  DECLARE @v_taqdetailscalekey	INT,
					@v_fixedamount	FLOAT,
					@v_amount	FLOAT,
					@v_error	INT,
          @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE tab_cursor CURSOR FOR
	SELECT taqdetailscalekey, fixedamount, amount
	FROM taqprojectscaledetails sd
	INNER JOIN taqscaleadminspecitem si
	ON sd.itemcategorycode = si.itemcategorycode
		AND sd.itemcode = si.itemcode
	WHERE si.scaletabkey = @i_scaletabkey
		AND si.parametertypecode = 3

	OPEN tab_cursor

	FETCH tab_cursor
	INTO @v_taqdetailscalekey, @v_fixedamount, @v_amount

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		IF @v_fixedamount IS NOT NULL AND @v_fixedamount <> 0 AND @v_amount IS NOT NULL AND @v_amount <> 0
		BEGIN
			UPDATE taqprojectscaledetails
			SET fixedamount = @v_fixedamount + (@v_fixedamount * (@i_fixedpercent / 100)),
				  amount = @v_amount + (@v_amount * (@i_variablepercent / 100))
			WHERE taqdetailscalekey = @v_taqdetailscalekey
			
			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Error updating taqprojectscaledetails.'
			END 
		END
		ELSE BEGIN
			IF @v_fixedamount IS NOT NULL AND @v_fixedamount <> 0
			BEGIN
				UPDATE taqprojectscaledetails
				SET fixedamount = @v_fixedamount + (@v_fixedamount * (@i_fixedpercent / 100))
				WHERE taqdetailscalekey = @v_taqdetailscalekey
				
				SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
				IF @v_error <> 0 BEGIN
					SET @o_error_code = -1
					SET @o_error_desc = 'Error updating taqprojectscaledetails.'
				END
			END
			IF @v_amount IS NOT NULL AND @v_amount <> 0
			BEGIN
				UPDATE taqprojectscaledetails
				SET amount = @v_amount + (@v_amount * (@i_variablepercent / 100))
				WHERE taqdetailscalekey = @v_taqdetailscalekey
				
				SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
				IF @v_error <> 0 BEGIN
					SET @o_error_code = -1
					SET @o_error_desc = 'Error updating taqprojectscaledetails.'
				END
			END
		END
	
		FETCH tab_cursor
		INTO @v_taqdetailscalekey, @v_fixedamount, @v_amount
	END
	
	CLOSE tab_cursor
	DEALLOCATE tab_cursor 
  
GO

GRANT EXEC ON qscale_update_tab_by_percent TO PUBLIC
GO