if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_get_scaleparametermultiples') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_get_scaleparametermultiples
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_get_scaleparametermultiples
 (@i_taqprojectkey				integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qscale_get_scaleparametermultiples
**  Desc: This procedure returns the multiple value desc for the scale parameter control if it exists
**
**	Auth: Dustin Miller
**	Date: February 21 2012
*******************************************************************************/

  DECLARE @v_error	INT,
          @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
       
  SELECT taqprojectkey,itemcategorycode,itemcode, dbo.qscale_get_parameter_desc(taqprojectkey,itemcategorycode,itemcode) paramdesc
  FROM taqprojectscaleparameters
	WHERE taqprojectkey=@i_taqprojectkey
	--AND itemcategorycode=@i_itemcategorycode
 -- AND itemcode=@i_itemcode
	GROUP BY taqprojectkey,itemcategorycode,itemcode,dbo.qscale_get_parameter_desc(taqprojectkey,itemcategorycode,itemcode)

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning scale parameter value information (taqprojectkey=' + cast(@i_taqprojectkey as varchar) + ')'
    RETURN  
  END 
  
GO

GRANT EXEC ON qscale_get_scaleparametermultiples TO PUBLIC
GO