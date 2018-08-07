IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_minprintingkey') )
DROP FUNCTION dbo.qproject_get_minprintingkey
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE FUNCTION [dbo].[qproject_get_minprintingkey]
(
  @i_projectkey as integer
) 
RETURNS INT


/*******************************************************************************************************************************************************
**  Name: [qproject_get_minprintingkey]
**  Desc: This function returns the minimum printingkey based on the minimum printing number for the input project (Work, Purchase Order , Printing).
**
**  Auth: Uday A. Khisty
**  Date: March 6, 2015
*******************************************************************************************************************************************************
**    Change History
*******************************************************************************************************************************************************
**    Date:        Author:     Description:
**    --------    --------    -------------------------------------------------------------------------------------------------------------------------
**    02/09/2017   UK		   Case 43088
*******************************************************************************************************************************************************/

BEGIN 
  DECLARE
    @v_error    INT,
    @v_rowcount INT,
    @v_itemtype INT,
    @v_usageclass INT,
    @v_project_qsicode INT,
    @v_bookkey INT,
    @v_min_printingnum INT,
    @v_min_printingkey INT,
	@v_IsProductionOnTheWeb INT
   
  IF @i_projectkey IS NULL OR @i_projectkey <= 0 BEGIN
	RETURN -1 
  END
  
  SELECT @v_IsProductionOnTheWeb = COALESCE(optionvalue, 0) 
  FROM clientoptions 
  WHERE optionid = 117

  SELECT @v_itemtype = searchitemcode, @v_usageclass = usageclasscode 
  FROM coreprojectinfo  
  WHERE projectkey = @i_projectkey
 
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
	RETURN -1
  END    
  
  SELECT @v_project_qsicode = COALESCE(qsicode, 0)
  FROM subgentables  
  WHERE tableid = 550 AND datacode = @v_itemtype AND datasubcode = @v_usageclass
 
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
	RETURN -1
  END    
  
  IF @v_project_qsicode = 28 BEGIN  -- Works
	SELECT @v_bookkey = workkey FROM taqproject WHERE taqprojectkey = @i_projectkey
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
	  RETURN -1
    END            		
  END
  ELSE IF @v_project_qsicode = 40 BEGIN  -- Printing  
	SELECT @v_bookkey = bookkey FROM taqprojectprinting_view WHERE taqprojectkey = @i_projectkey
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
	  RETURN -1
    END  	
  END
  ELSE IF @v_project_qsicode = 41 OR @v_project_qsicode = 51 BEGIN -- Purchase Orders
	SELECT @v_bookkey = bookkey FROM purchaseorderstitlesview WHERE poprojectkey = @i_projectkey
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
	  RETURN -1
    END 
  END
  ELSE BEGIN
	RETURN -1
  END
  
  IF @v_IsProductionOnTheWeb > 0 BEGIN
	SELECT @v_min_printingnum = MIN(printingnum) FROM taqprojectprinting_view WHERE bookkey = @v_bookkey 
  END
  ELSE BEGIN
	SELECT @v_min_printingnum = MIN(printingnum) FROM printing WHERE bookkey = @v_bookkey 
  END
   
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
	RETURN -1
  END  
  
  IF @v_IsProductionOnTheWeb > 0 BEGIN
	SELECT @v_min_printingkey = printingkey FROM taqprojectprinting_view WHERE bookkey = @v_bookkey AND printingnum = @v_min_printingnum
  END
  ELSE BEGIN
	SELECT @v_min_printingkey = printingkey FROM printing WHERE bookkey = @v_bookkey AND printingnum = @v_min_printingnum
  END

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
	RETURN -1
  END    
  
  RETURN @v_min_printingkey
  
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXEC ON qproject_get_minprintingkey TO PUBLIC
go
