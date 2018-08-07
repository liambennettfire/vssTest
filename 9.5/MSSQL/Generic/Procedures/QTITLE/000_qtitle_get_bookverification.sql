if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_bookverification') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_bookverification
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_bookverification
 (@i_bookkey         integer,
  @o_error_code      integer output,
  @o_error_desc      varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qtitle_get_bookverification
**  Desc: This stored procedure returns info from the bookverification 
**        table. 
**          
**        NOTE: 0 bookkey will return all verification types from gentables
**   
**    Auth: Alan Katzen
**    Date: 28 November 2007
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    -------- --------        -------------------------------------------
**    10/06/15  Kusum		   Return all active rows (Case 34519)
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT,
          @v_initial_status INT

  IF @i_bookkey > 0 BEGIN
    SELECT g.alternatedesc1 storedprocname, 
           dbo.qtitle_get_verificationicon(v.verificationtypecode,v.titleverifystatuscode) imagename,  
           COALESCE(g.gen1ind, 0) updatestatusind, v.titleverifystatuscode origtitleverifystatuscode, 
           CASE 
             WHEN g.alternatedesc1 IS NULL OR LTRIM(RTRIM(g.alternatedesc1)) = '' THEN 0
             ELSE 1
           END AS storedprocnameexists,
           v.*
      FROM bookverification v, gentables g
     WHERE v.verificationtypecode = g.datacode and
           v.bookkey = @i_bookkey and
           g.tableid = 556 and
           LOWER(g.deletestatus) = 'n'
     ORDER BY COALESCE(g.sortorder, 999)
  END
  ELSE BEGIN
    SELECT @v_initial_status = COALESCE(datacode,0)
      FROM gentables
     WHERE tableid = 513 and
           qsicode = 1

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 or @rowcount_var = 0 BEGIN
      SET @v_initial_status = 0
    END 

    SELECT g.alternatedesc1 storedprocname,  
           dbo.qtitle_get_verificationicon(datacode,@v_initial_status) imagename,  
           COALESCE(g.gen1ind, 0) updatestatusind, @v_initial_status origtitleverifystatuscode, 
           CASE 
             WHEN g.alternatedesc1 IS NULL OR LTRIM(RTRIM(g.alternatedesc1)) = '' THEN 0
             ELSE 1
           END AS storedprocnameexists,
           @v_initial_status titleverifystatuscode, datacode verificationtypecode, 0 bookkey,
           null lastmaintdate
      FROM gentables g
     WHERE g.tableid = 556 
       AND LOWER(g.deletestatus) = 'n'
  END

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: bookkey = ' + cast(@i_bookkey AS VARCHAR) 
  END 

GO
GRANT EXEC ON qtitle_get_bookverification TO PUBLIC
GO


