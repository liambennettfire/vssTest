if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_scaleparametervalues') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_scaleparametervalues
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_get_scaleparametervalues
 (@i_taqprojectkey				integer,
	@i_datacode							integer,
	@i_datasubcode					integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qscale_get_scaleparametervalues
**  Desc: This procedure returns the multiple value desc for the scale parameter control if it exists
**
**	Auth: Dustin Miller
**	Date: February 21 2012
*******************************************************************************/

  DECLARE @v_tableid	INT,
					@v_error		INT,
          @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
       
  SET @v_tableid = NULL
  
  SELECT @v_tableid=numericdesc1 
  FROM subgentables 
  WHERE tableid=616 
		AND datacode=@i_datacode 
		AND datasubcode=@i_datasubcode
	
	IF @v_tableid IS NULL
	BEGIN
		SELECT datadesc, datasub2code AS value, coalesce(deletestatus, 'N') AS deletestatus
		FROM sub2gentables 
		WHERE tableid=616 
			AND datacode=@i_datacode
			AND datasubcode=@i_datasubcode
	END
	ELSE BEGIN
		SELECT datadesc, datacode AS value, coalesce(deletestatus, 'N') AS deletestatus
		FROM gentables 
		WHERE tableid=@v_tableid
	END

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning scale parameter value information (taqprojectkey=' + cast(@i_taqprojectkey as varchar) + ')'
    RETURN  
  END 
  
GO

GRANT EXEC ON qscale_get_scaleparametervalues TO PUBLIC
GO