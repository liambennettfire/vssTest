if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_payment_tab_sectionconfig') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontract_get_payment_tab_sectionconfig
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_payment_tab_sectionconfig
 (@i_tabcode				integer,
	@i_tabsubcode			integer,
	@o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/************************************************************************************
**  Name: qcontract_get_payment_tab_sectionconfig
**  Desc: This stored procedure returns the section configuration details for payment tabs
**
**  Auth: Dustin Miller
**  Date: 7/17/12
*************************************************************************************/

BEGIN

  DECLARE
		@v_gentable1	INT,
		@v_gentable2	INT,
    @v_error  INT,
    @v_rowcount INT

	SET @v_gentable1 = NULL
	SET @v_gentable2 = NULL
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SELECT @v_gentable1 = Gentable1id, @v_gentable2 = Gentable2id
  FROM gentablesrelationships
  WHERE gentablesrelationshipkey = 24
  
	IF @v_gentable1 IS NOT NULL AND @v_gentable2 IS NOT NULL
	BEGIN
		SELECT s.datacode, s.datasubcode, s.datadesc, d.sortorder
		FROM subgentables s
		INNER JOIN gentablesrelationshipdetail d
			ON (d.gentablesrelationshipkey = 24 
					AND d.code1 = @i_tabcode
					AND d.subcode1 = @i_tabsubcode
					AND s.datacode = d.code2
					AND s.datasubcode = d.subcode2)
		WHERE s.tableid = @v_gentable2
	END

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not get web tab/section config from gentablesrelationshipdetail.'
  END
  
END
GO

GRANT EXEC ON qcontract_get_payment_tab_sectionconfig TO PUBLIC
GO
