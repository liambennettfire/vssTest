if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qelement_get_taskgroups') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qelement_get_taskgroups
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qelement_get_taskgroups
 (@i_elementtype          integer,
  @i_elementsubtype       integer,
  @i_userid               varchar(30),
  @i_projitemtype         integer,
  @i_projusageclass       integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS
/******************************************************************************
**  File: qelement_get_taskgroups
**  Name: qelement_get_taskgroups
**  Desc: This procedure returns all taskgroups for an element type/subtype.  
**
**    Auth: Alan Katzen
**    Date: 13 June 2008
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_userkey    INT
   
  SET @error_var = 0
  SET @rowcount_var = 0
      
  /** Get userkey for the given userid passed **/
  SELECT @v_userkey = COALESCE(userkey, -1)
  FROM qsiusers
  WHERE UPPER(userid) = UPPER(@i_userid)

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @v_userkey = -1
  END  
       
  SELECT * 
    FROM taskview 
   WHERE elementtypecode = @i_elementtype
     AND taskgroupind = 1
     AND COALESCE(userkey, -1) in (@v_userkey, -1)
     AND COALESCE(itemtypecode, -1) in (@i_projitemtype, 0, -1)
     AND COALESCE(usageclasscode, -1) in (@i_projusageclass, 0, -1) 
     AND ISNULL(initialtaskautoind,0) != 1    
  ORDER BY taskviewdesc

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error returning task group information (elementtypecode = ' + cast(@i_elementtype as varchar) + 
                        'and elementtypesubcode = ' + cast(COALESCE(@i_elementsubtype,0) as varchar) +')'
    RETURN  
  END 
  
ExitHandler:

GO
GRANT EXEC ON qelement_get_taskgroups TO PUBLIC
GO


