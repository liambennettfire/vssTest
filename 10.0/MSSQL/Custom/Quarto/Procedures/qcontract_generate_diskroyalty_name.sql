
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_generate_diskroyalty_name') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure qcontract_generate_diskroyalty_name
GO

CREATE PROCEDURE [dbo].[qcontract_generate_diskroyalty_name]
 (@i_taqprojectkey           integer,
  @o_contractname             varchar(255)  output,
  @o_error_code              integer       output,
  @o_error_desc              varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_generate_diskroyalty_name
**  Desc: This procedure will generate the Disk and Royalty Contract project title
**
**    Auth: Susan Burke
**    Date: June 15 2017
*******************************************************************************/

  DECLARE 
    @error_var             INT,
    @rowcount_var          INT,
    @v_count               INT,
    @v_bookkey             INT,
    @v_contractprojectkey  INT,
    @v_book_title          VARCHAR(255),
    @v_printingnum         INT,
    @v_customername        VARCHAR(255),
    @v_printingnum_str     VARCHAR(50)

  SET @v_count = 0
  SET @v_customername = ''
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_contractname = ''
  
  SET @v_bookkey = 0
  SET @v_contractprojectkey = COALESCE(@i_taqprojectkey,0) 
  SET @v_printingnum = 0


  SELECT @v_customername = displayname
    FROM globalcontact gc
	INNER JOIN taqprojectcontact tc ON tc.globalcontactkey = gc.globalcontactkey
	INNER JOIN taqprojectcontactrole tcr on tc.taqprojectcontactkey = tcr.taqprojectcontactkey
   WHERE EXISTS(SELECT 1 FROM gentables g
			 WHERE tcr.rolecode  = g.datacode AND tableid = 285 AND g.qsiCode = 28)
	AND tc.taqprojectkey = @v_contractprojectkey

  SELECT @v_count = COUNT(*) 
    FROM projectrelationshipview prv
	INNER JOIN gentables g on prv.relationshipcode  = g.datacode AND tableid = 582 AND g.qsiCode = 42
	WHERE prv.relatedprojectkey = @v_contractprojectkey
	PRINT @v_count

  IF @v_count > 1
   BEGIN
    SET @v_book_title  = 'Multiple Title'
	SET @v_printingnum_str = ' / ' + (SELECT FORMAT (getdate(), 'MMM yyyy') )
  END
  ELSE BEGIN
    SELECT @v_book_title = ISNULL(prv.projectname, ' ')
      FROM projectrelationshipview prv 
     WHERE EXISTS(SELECT 1 FROM gentables g
			WHERE prv.relationshipcode  = g.datacode AND tableid = 582 AND g.qsiCode = 42)
	 AND prv.relatedprojectkey = @v_contractprojectkey
	SELECT @v_printingnum = ISNULL(printingnum, ' ')
	   FROM taqprojectprinting_view tpv
	   INNER JOIN taqprojectrights tpr ON tpr.taqprojectkey = @v_contractprojectkey
      WHERE tpv.taqprojectkey = tpr.taqprojectprintingkey
	SET @v_printingnum_str = ' #' + cast(@v_printingnum as varchar)
  END  
  

  IF @v_book_title IS NULL AND @v_printingnum_str IS NULL AND @v_customername IS NULL BEGIN
      SET @o_contractname = 'No Customer or Title Chosen'
      RETURN
    END
    
  SET @o_contractname =   ISNULL(@v_book_title,'Title Not Defined') + ' / '+ ISNULL (@v_customername,'Cust not Defined') + ISNULL(@v_printingnum_str,' ')
 
  PRINT @o_contractname

  RETURN
  

GO


GRANT EXEC ON qcontract_generate_diskroyalty_name TO PUBLIC
GO

