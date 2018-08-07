if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_plsummaryitemdefinition') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_plsummaryitemdefinition
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpl_get_plsummaryitemdefinition
 (@i_plsummaryitemkey integer,
  @i_summarylevelcode integer,
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qpl_get_plsummaryitemdefinition
**  Desc: This stored procedure returns P&L Summary Item(s) from plsummaryitemdefinition table.
**        If i_plsummaryitemkey is passed, single row data will be returned - for that item.
**        Otherwise, either all rows will be returned (i_summarylevelcode=0) or rows for the
**        passed summarylevelcode (i_summarylevelcode>0).
**
**  Auth: Kate
**  Date: 9 August 2007
************************************************************************************************/

  DECLARE
    @v_error  INT,
    @v_rowcount INT  

  SET @o_error_code = 0
  SET @o_error_desc = ''  
  
  IF @i_plsummaryitemkey > 0
  BEGIN
    SELECT *
    FROM plsummaryitemdefinition
    WHERE plsummaryitemkey = @i_plsummaryitemkey 
    
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not access plsummaryitemdefinition table (plsummaryitemkey=' + CAST(@i_plsummaryitemkey AS VARCHAR) + ').'
    END
  END
  
  ELSE IF @i_summarylevelcode > 0
  BEGIN
    SELECT plsummaryitemkey, itemname, summarylevelcode, summaryheadingcode, itemtype, activeind, 0 newind
    FROM plsummaryitemdefinition
    WHERE summarylevelcode = @i_summarylevelcode
    
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not access plsummaryitemdefinition table (summarylevelcode=' + CAST(@i_summarylevelcode AS VARCHAR) + ').'
    END    
  END
  
  ELSE
  BEGIN
    SELECT plsummaryitemkey, itemname, summarylevelcode, summaryheadingcode, itemtype, activeind, 0 newind
    FROM plsummaryitemdefinition
   
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not access plsummaryitemdefinition table.'
    END   
  END
  
GO

GRANT EXEC ON qpl_get_plsummaryitemdefinition TO PUBLIC
GO
