if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_get_payment_tasks') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_get_payment_tasks
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_get_payment_tasks
 (@i_projectkey    integer,
  @i_paymenttype    integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************************************
**  Name: qcontract_get_payment_tasks
**  Desc: This procedure returns payment tasks used on contract payment tabs.
**        If paymenttype requires link to task (gen1ind=1 on gentable 635), get only advanceind tasks 
**        that exist on either the contract or related title.
**        Otherwise, get all advanceind tasks.
**
**	Auth: Kate
**	Date: July 12 2013
*******************************************************************************************************
**	Change History
*******************************************************************************************************
**	Date      Author    Description
**	--------  ------    -----------
**  04/23/18  Alan      48098 - Switched contracttitlesview to functional table due to speed issues
*******************************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT,
    @v_linkwithtask TINYINT,
    @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
	
  SELECT @v_linkwithtask = COALESCE(gen1ind, 0)
  FROM gentables
  WHERE tableid = 635 AND datacode = @i_paymenttype
  
  IF @v_linkwithtask = 1 BEGIN
    SELECT DISTINCT d.datetypecode , d.description, d.advanceind
    FROM taqprojecttask t, datetype d 
    WHERE t.datetypecode = d.datetypecode AND
      d.advanceind = 1 AND 
      t.bookkey IN (SELECT bookkey FROM dbo.qcontract_contractstitlesinfo(@i_projectkey))
    UNION
    SELECT DISTINCT d.datetypecode , d.description, d.advanceind
    FROM taqprojecttask t, datetype d 
    WHERE t.datetypecode = d.datetypecode AND
      d.advanceind = 1 AND
      t.taqprojectkey = @i_projectkey
  END
  ELSE BEGIN
    SELECT DISTINCT datetypecode, description
    FROM datetype
    WHERE advanceind = 1
  END

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error returning payment tasks (taqprojectkey=' + cast(@i_projectkey as varchar) + ').'
    RETURN  
  END

END   
GO

GRANT EXEC ON qcontract_get_payment_tasks TO PUBLIC
GO