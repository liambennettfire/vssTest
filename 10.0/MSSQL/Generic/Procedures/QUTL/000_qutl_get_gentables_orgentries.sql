if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_gentables_orgentries') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qutl_get_gentables_orgentries
GO

CREATE PROCEDURE qutl_get_gentables_orgentries (  
  @i_tableid integer,
  @i_gentablelevel integer, --1=gentablesdesc, 2=gentables, 3=subgentables, 4=sub2gentables
  @i_orglevelkey integer,
  @i_datacode integer,
  @i_datasubcode integer,
  @i_datasub2code integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************************
**  Name: qutl_get_gentables_orgentries
**  Desc: This stored procedure returns valid orgentry records based on the supplied gentable info
**
**  Auth: Dustin Miller
**  Date: June 25 2018
*******************************************************************************************/

BEGIN

  DECLARE @v_error  INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  IF @i_gentablelevel = 2
  BEGIN
	SELECT oe.orgentrykey, oe.orgentrydesc, ISNUMERIC(gol.orgentrykey) AS genexists
	FROM orgentry oe
	LEFT JOIN gentablesorglevel gol
	ON (oe.orgentrykey = gol.orgentrykey AND gol.tableid = @i_tableid
	  AND gol.datacode = @i_datacode)
	WHERE oe.orglevelkey = @i_orglevelkey
  END
  ELSE IF @i_gentablelevel = 3
  BEGIN
	SELECT oe.orgentrykey, oe.orgentrydesc, ISNUMERIC(gol.orgentrykey) AS genexists
	FROM orgentry oe
	LEFT JOIN subgentablesorglevel gol
	ON (oe.orgentrykey = gol.orgentrykey AND gol.tableid = @i_tableid
	  AND gol.datacode = @i_datacode AND gol.datasubcode = @i_datasubcode)
	WHERE oe.orglevelkey = @i_orglevelkey
  END
  ELSE IF @i_gentablelevel = 4
  BEGIN
	SELECT oe.orgentrykey, oe.orgentrydesc, ISNUMERIC(gol.orgentrykey) AS genexists
	FROM orgentry oe
	LEFT JOIN sub2gentablesorglevel gol
	ON (oe.orgentrykey = gol.orgentrykey AND gol.tableid = @i_tableid
	  AND gol.datacode = @i_datacode AND gol.datasubcode = @i_datasubcode AND gol.datasub2code = @i_datasub2code)
	WHERE oe.orglevelkey = @i_orglevelkey
  END

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: tableid=' + cast(@i_tableid AS VARCHAR)
  END 

END
GO

GRANT EXEC ON qutl_get_gentables_orgentries TO PUBLIC
GO
