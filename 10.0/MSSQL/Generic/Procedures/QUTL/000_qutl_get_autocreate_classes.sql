if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_autocreate_classes') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_autocreate_classes
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qutl_get_autocreate_classes
 (@i_mediatypecode      integer,
  @i_mediatypesubcode   integer,
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_autocreate_classes
**  Desc: This procedure returns all project classes eligible to be autocreated
**        for the passed format.
**
**	Auth: Colman
**	Date: July 27, 2016
**
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:   Case:  Description:
**  --------  --------  ------ ------------------------------------------------
**  08/09/17  Colman    46218  Default the Create Related Project checkbox using indicator on gentablesrelationships
*******************************************************************************/

  DECLARE @v_error			INT,
          @v_rowcount		INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
	
  SELECT code2 as itemtypecode, subcode2 as usageclasscode, ISNULL(indicator1, 0) as defaultind, s.datadesc
  FROM gentablesrelationshipdetail
  JOIN subgentables s ON s.tableid = 550 
    AND s.datacode = code2
    AND s.datasubcode = subcode2
  WHERE gentablesrelationshipkey = 34
		AND code1 = @i_mediatypecode
		AND subcode1 = @i_mediatypesubcode
		
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning auto-create class data.'
    RETURN  
  END   
GO

GRANT EXEC ON qutl_get_autocreate_classes TO PUBLIC
GO