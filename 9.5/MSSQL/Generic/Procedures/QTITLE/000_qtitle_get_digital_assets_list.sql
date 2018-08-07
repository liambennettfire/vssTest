if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_digital_assets_list') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_digital_assets_list
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_digital_assets_list
 (@i_bookkey              integer,
  @i_all_assets_for_work  integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_digital_assets_list
**  Desc: This stored procedure returns all digital assets for a title or work.
**        If @i_all_assets_for_work = 1, return all assets for the work
**        otherwise return all assets for the title
** 
**    Auth: Alan Katzen
**    Date: 13 August 2010
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_workkey    INT
     
  SET @v_workkey = 0
  
  IF @i_all_assets_for_work = 1 BEGIN
    SELECT @v_workkey = workkey
      FROM coretitleinfo
     WHERE bookkey = @i_bookkey
     
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'error getting workkey: bookkey = ' + cast(@i_bookkey AS VARCHAR)  
    END 
  END   
  
  IF @v_workkey > 0 BEGIN
    SELECT tpe.*, c.productnumber, c.formatname formatdesc, 
      dbo.get_gentables_desc(593, tpe.elementstatus,'long') elementstatusdesc,
      dbo.get_gentables_desc(639, tpe.cspartnerstatuscode, 'short') partnerstatusdesc
    FROM taqprojectelement tpe, coretitleinfo c
    WHERE tpe.bookkey = c.bookkey
       AND tpe.printingkey = c.printingkey
       AND tpe.printingkey = 1
       AND c.workkey = @v_workkey
       AND tpe.taqelementtypecode in (select datacode from gentables where tableid = 287 and gen1ind = 1)
  END
  ELSE BEGIN
    SELECT tpe.*, c.productnumber, c.formatname formatdesc,
      dbo.get_gentables_desc(593, tpe.elementstatus,'long') elementstatusdesc,
      dbo.get_gentables_desc(639, tpe.cspartnerstatuscode, 'short') partnerstatusdesc
    FROM taqprojectelement tpe, coretitleinfo c
    WHERE tpe.bookkey = c.bookkey
       AND tpe.printingkey = c.printingkey
       AND tpe.printingkey = 1
       AND tpe.bookkey = @i_bookkey
       AND tpe.taqelementtypecode in (select datacode from gentables where tableid = 287 and gen1ind = 1)
  END
     
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error accessing taqprojectelement: bookkey = ' + cast(@i_bookkey AS VARCHAR)  
  END 

GO
GRANT EXEC ON qtitle_get_digital_assets_list TO PUBLIC
GO



