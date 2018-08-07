if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qsiconfigdetail_set_visibleind') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qsiconfigdetail_set_visibleind
GO

CREATE PROCEDURE qsiconfigdetail_set_visibleind (  
  @i_datadesc   varchar(120),
  @i_datacode   integer,
  @i_activeind  integer,
  @o_error_code integer OUTPUT,
  @o_error_desc varchar(2000) OUTPUT)
AS

/******************************************************************************************
**  Name: qsiconfigdetail_set_visibleind
**  Desc: Change visible ind of qsiconfigdetail rows for Web Tab Group (gentable 680) 
**        if row(s) is/are activated or inactivated.
**
**  Auth: Kusum
**  Date: July 11 2016
*******************************************************************************************/

DECLARE
  @v_count  int,
  @v_gentext1 varchar(255),
  @v_error  INT,
  @v_rowcount INT 
  
BEGIN
	SET @o_error_code = 0
	SET @o_error_desc = ''
	
	SELECT @v_gentext1 = COALESCE(gentext1,'') FROM gentables_ext WHERE tableid = 680 AND datacode = @i_datacode
	
	IF @v_gentext1 <> '' SET @i_datadesc = @v_gentext1
		
	IF @i_activeind = 1 BEGIN  -- Row on Web Tab Group gentable
		SELECT @v_count = COUNT(*)
		  FROM qsiconfigdetail
		 WHERE labeldesc = @i_datadesc
		   AND visibleind = 0
	   
		IF @v_count > 0 BEGIN
			UPDATE qsiconfigdetail SET visibleind = 1 WHERE labeldesc = @i_datadesc AND visibleind = 0
			  
			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			  SET @o_error_code = -1
			  SET @o_error_desc = 'Error updating qsiconfigdetail table'
			END  
        END
	END
	
	IF @i_activeind = 0 BEGIN  -- Row on Web Tab Group gentable
		SELECT @v_count = COUNT(*)
		  FROM qsiconfigdetail
		 WHERE labeldesc = @i_datadesc 
		   AND visibleind = 1
	   
		IF @v_count > 0 BEGIN
			UPDATE qsiconfigdetail SET visibleind = 0 WHERE labeldesc = @i_datadesc AND visibleind = 1
			  
			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			  SET @o_error_code = -1
			  SET @o_error_desc = 'Error updating qsiconfigdetail table'
			END 
		END
	END
END
GO

GRANT EXEC ON qsiconfigdetail_set_visibleind TO PUBLIC
GO