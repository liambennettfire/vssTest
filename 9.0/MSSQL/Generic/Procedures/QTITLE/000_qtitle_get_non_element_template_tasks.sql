if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_non_element_template_tasks') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_non_element_template_tasks
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
DECLARE @err int,
@dsc varchar(2000)
exec qtitle_get_non_element_template_tasks '566820', @err, @dsc
*/

CREATE PROCEDURE qtitle_get_non_element_template_tasks
 (@i_bookkey   integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_non_element_template_tasks
**  Desc: This stored procedure returns only non-element based tasks 
**        for a title.  The key passed in is for the template bookkey
**        being used to create the title.
**
**  Auth: Lisa
**  Date: 12/18/08
**
*******************************************************************************/
   DECLARE @error_var  INT,
         @rowcount_var INT

   SET @o_error_code = 0
   SET @o_error_desc = ''

   -- must have a bookkey
   IF (@i_bookkey <= 0) 
   BEGIN
      return
   END
    
   -- Created this select statement to match the one in qproject_get_project_taskview_dates which
   -- is also called from the Control which calls this stor

   SELECT  CASE  WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel))='' 
              THEN d.description  ELSE d.datelabel END datelabel,
         d.datetypecode,t.taqprojectkey,t.taqtaskkey,t.taqelementkey,
         t.activedate,t.actualind,t.originaldate,
         COALESCE(t.activedate,t.originaldate) bestdate,
         t.decisioncode,t.paymentamt,t.taqtaskqty,t.taqprojectformatkey,
         t.keyind,e.taqelementtypecode,e.taqelementtypesubcode,
         e.taqelementnumber,e.taqelementdesc elementdesc,
         t.globalcontactkey,t.rolecode,t.globalcontactkey2,t.rolecode2,
         dbo.qcontact_get_displayname(t.globalcontactkey) contactname1,
         dbo.qcontact_get_displayname(t.globalcontactkey2) contactname2,
         t.scheduleind,t.stagecode,t.duration,t.lockind,t.bookkey,
         t.printingkey,t.taqtasknote, cp.projecttitle projectname,ct.title, 
         CASE WHEN LEN(t.taqtasknote) > 6 THEN CAST(t.taqtasknote AS VARCHAR(6)) + '...' 
                                  ELSE t.taqtasknote END AS note,
         0 as sortorder 

   FROM taqprojecttask t
   JOIN datetype d on t.datetypecode = d.datetypecode   
   JOIN book b on t.bookkey = b.bookkey
   LEFT OUTER JOIN taqprojectelement e on t.taqelementkey = e.taqelementkey 
   LEFT OUTER JOIN coreprojectinfo cp ON t.taqprojectkey = cp.projectkey 
   LEFT OUTER JOIN coretitleinfo ct ON t.bookkey = ct.bookkey
   WHERE b.bookkey = @i_bookkey and b.tmmwebtemplateind = 1 and isnull(t.taqelementkey,0) = 0
   
   -- Save the @@ERROR and @@ROWCOUNT values in local 
   -- variables before they are cleared.
   SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
   IF @error_var <> 0 or @rowcount_var = 0 BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'no non-element tasks found: bookkey=' + CAST(@i_bookkey AS VARCHAR)
   END 
GO

GRANT EXEC ON qtitle_get_non_element_template_tasks TO PUBLIC
GO

