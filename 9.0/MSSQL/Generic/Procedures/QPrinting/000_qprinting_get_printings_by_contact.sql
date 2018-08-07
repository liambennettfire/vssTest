
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qprinting_get_printings_by_contact') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qprinting_get_printings_by_contact
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qprinting_get_printings_by_contact
 (@i_contactkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qprinting_get_printings_by_contact
**  Desc: This stored procedure gets all of the printings that have been written
**        by the specified contact. 
**
**              
**
**    Auth: Uday A. Khisty
**    Date: 11 July 2014
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
      
  SELECT distinct c.projectkey, pr.bookkey, pr.printingkey, c.projecttitle, pr.printingnum, c.projectstatus as taqprojectstatuscode,
		ct.productnumber,
		dbo.get_gentables_desc(312,pr.mediatypecode,'long') mediadesc,
		dbo.get_subgentables_desc(312,pr.mediatypecode,pr.mediatypesubcode,'long') formatname,
		ct.authorname, c.projectheaderorg1desc as imprintname, ct.itemnumber
  FROM taqprojectprinting_view pr
		INNER JOIN coreprojectinfo c ON c.projectkey = pr.taqprojectkey
		INNER JOIN coretitleinfo ct ON ct.bookkey = pr.bookkey and ct.printingkey = pr.printingkey
  WHERE pr.taqprojectkey IN (SELECT distinct taqprojectkey FROM taqprojectcontact WHERE globalcontactkey = @i_contactkey)
  ORDER BY c.projecttitle asc  

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: contactkey  = ' + cast(@i_contactkey AS VARCHAR)  
  END 

GO
GRANT EXEC ON qprinting_get_printings_by_contact TO PUBLIC
GO


