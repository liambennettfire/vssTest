if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_contact_history') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontact_get_contact_history
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qcontact_get_contact_history
 (@i_globalcontactkey        integer,
  @i_columnkey               integer,
  @o_error_code              integer       output,
  @o_error_desc              varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_get_contact_history
**  Desc: This gets contact history information for the Contact.
**
**    Auth: Colman
**    Date: 24 July 2015
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  IF @i_columnkey > 0 BEGIN
	select h.globalcontactkey, h.columnkey, hc.columndescription,
	  CASE
		WHEN LTRIM(RTRIM(LOWER(hc.datatype))) = 'y'
		THEN
		  CASE
			WHEN LTRIM(RTRIM(h.currentstringvalue))= '1'
			THEN 'Y'

			WHEN LTRIM(RTRIM(h.currentstringvalue))= '0'
			THEN 'N'	
		  ELSE h.currentstringvalue	
		  END
		ELSE h.currentstringvalue
		END AS currentstringvalue,
   COALESCE(h.changecomment, '') as changecomment, h.lastuserid,  h.lastmaintdate
	from globalcontacthistory h
	LEFT OUTER JOIN globalcontacthistorycolumns hc ON h.columnkey = hc.columnkey
	WHERE h.globalcontactkey = @i_globalcontactkey and h.columnkey = @i_columnkey
	order by h.lastmaintdate DESC
  END
  ELSE BEGIN
	select h.globalcontactkey, h.columnkey, hc.columndescription,
	  CASE
		WHEN LTRIM(RTRIM(LOWER(hc.datatype))) = 'y'
		THEN
		  CASE
			WHEN LTRIM(RTRIM(h.currentstringvalue))= '1'
			THEN 'Y'

			WHEN LTRIM(RTRIM(h.currentstringvalue))= '0'
			THEN 'N'	
		  ELSE h.currentstringvalue	
		  END
		ELSE h.currentstringvalue
		END AS currentstringvalue,
   COALESCE(h.changecomment, '') as changecomment, h.lastuserid,  h.lastmaintdate
	from globalcontacthistory h
	LEFT OUTER JOIN globalcontacthistorycolumns hc ON h.columnkey = hc.columnkey 
	WHERE h.globalcontactkey = @i_globalcontactkey 
	order by h.lastmaintdate DESC
  END  

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: globalcontactkey = ' + cast(@i_globalcontactkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qcontact_get_contact_history TO PUBLIC
GO


