/****** Object:  StoredProcedure [dbo].[qproject_get_relationships_gen_project]    Script Date: 04/02/2009 13:42:32 ******/
/*    The following lines drop the OLD version of this procedure from any databases it may still reside on               */
/*    The name was too long for some older version of MSSQLServer  */

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_get_relationships_for_generic_project_tab]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_get_relationships_for_generic_project_tab]
GO

/****** Object:  StoredProcedure [dbo].[qproject_get_relationships_gen_project]    Script Date: 04/02/2009 13:42:32 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_get_relationships_gen_project]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qproject_get_relationships_gen_project]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
DECLARE @err int,
@dsc varchar
exec qproject_get_relationships_gen_project 15, @err, @dsc
*/

CREATE PROCEDURE [dbo].[qproject_get_relationships_gen_project]
 (@i_relationshiptabcode  integer,  -- datacode column of gentable 583
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_relationships_gen_project
**  Desc: This stored procedure returns gentable values for project relationships
**        by relationship tab.
**
**  Auth: Alan Katzen
**  Date: March 4 2008
**
**  04/02/09 - LJC - cloned this from qproject_get_relationships_for_tab
**                   and modified it for my use on the generic project tab
**                   It is associated with the page control 'ProjectRelationshipsGrid'
**                   configured in gentable 583, column alternatedesc2
**
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @v_gentablesrelationshipkey INT

  SELECT @v_gentablesrelationshipkey = COALESCE(gentablesrelationshipkey,0)
    FROM gentablesrelationships
   WHERE gentable1id = 582
     and gentable2id = 583

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error acessing gentablesrelationships: gentable1id = 582 / gentable2id = 583'
    RETURN  
  END 

  IF @v_gentablesrelationshipkey <= 0 BEGIN
    RETURN
  END

  SELECT *, COALESCE(alternatedesc1, datadesc) bestdesc from gentables
   WHERE tableid = 582
       AND upper(COALESCE(deletestatus,'N')) = 'N'
       AND (datacode in (SELECT distinct code1 FROM gentablesrelationshipdetail
                          WHERE gentablesrelationshipkey = @v_gentablesrelationshipkey
                            AND code2 = @i_relationshiptabcode))


  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'could not get gentables based on gentable relationship mapping: ' + 
	CONVERT(varchar, @v_gentablesrelationshipkey) 
  END 
