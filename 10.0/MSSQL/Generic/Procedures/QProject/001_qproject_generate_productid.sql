if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_generate_productid') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_generate_productid
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_generate_productid
  (@i_projectkey    integer,
  @i_elementkey     integer,
  @i_rel_journalkey integer,
  @i_productidcode  integer,
  @i_prefixcode     integer,
  @i_sortorder      integer,
  @i_procname       varchar(255),
  @i_userid         varchar(30),
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/***********************************************************************************
**  Name: qproject_generate_productid
**  Desc: This stored procedure generates and saves the new product ID for the given
**        project/element by running the passed generation stored procedure set up
**        for this product id type.
**
**  Auth: Kate
**  Date: October 1 2008
***********************************************************************************/

DECLARE
  @v_count  INT,
  @v_errorcode	INT,
  @v_errordesc	VARCHAR(2000),
  @v_newkey INT,
  @v_productnumber  VARCHAR(50),
  @v_productnumber2 CHAR(7),
  @v_sqlstring  NVARCHAR(4000)

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  IF @i_procname = 'qprinting_get_next_jobnumber_alpha' BEGIN
	SET @v_sqlstring = N'EXEC ' + @i_procname 
	--+ ' '  
	SET @v_sqlstring = @v_sqlstring + ' @result OUTPUT, @errorcode OUTPUT, @errordesc OUTPUT'
	  
	EXEC qutl_execute_prodidsql3 @v_sqlstring, @v_productnumber OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
	--print @v_productnumber
  END
  ELSE BEGIN
  
	  SET @v_sqlstring = N'EXEC ' + @i_procname + ' ' + CONVERT(VARCHAR, @i_projectkey) + 
		', ' + CONVERT(VARCHAR, @i_elementkey) + ', ' + CONVERT(VARCHAR, @i_rel_journalkey) +
		', ' + CONVERT(VARCHAR, @i_productidcode)
		
	  IF @i_prefixcode > 0
		SET @v_sqlstring = @v_sqlstring + ', ' + CONVERT(VARCHAR, @i_prefixcode)
	  ELSE
		SET @i_prefixcode = NULL
		
	  SET @v_sqlstring = @v_sqlstring + ', @result OUTPUT, @errorcode OUTPUT, @errordesc OUTPUT'
      
	  EXEC qutl_execute_prodidsql @v_sqlstring, @v_productnumber OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
		
  END
  
  --IF @i_prefixcode > 0
  --  SET @v_sqlstring = @v_sqlstring + ', ' + CONVERT(VARCHAR, @i_prefixcode)
  --ELSE
  --  SET @i_prefixcode = NULL
    
  --SET @v_sqlstring = @v_sqlstring + ', @result OUTPUT, @errorcode OUTPUT, @errordesc OUTPUT'
      
  --EXEC qutl_execute_prodidsql @v_sqlstring, @v_productnumber OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

  IF @o_error_code = -2 --warning returned - product could not be generated
    SET @v_productnumber = NULL
  ELSE IF @o_error_code <> 0
    RETURN
    
  IF @i_projectkey > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM taqproductnumbers
    WHERE taqprojectkey = @i_projectkey AND 
        productidcode = @i_productidcode

    IF @v_count > 0 
      UPDATE taqproductnumbers
      SET productnumber = @v_productnumber
      WHERE taqprojectkey = @i_projectkey AND
        productidcode = @i_productidcode
    ELSE
      BEGIN
        EXEC next_generic_key NULL, @v_newkey OUTPUT, @v_errorcode OUTPUT, @v_errordesc OUTPUT

        INSERT INTO taqproductnumbers
          (productnumberkey,
          taqprojectkey,
          productidcode,
          prefixcode,
          productnumber,
          sortorder,
          lastuserid,
          lastmaintdate)
        VALUES
          (@v_newkey,
          @i_projectkey,
          @i_productidcode,
          @i_prefixcode,
          @v_productnumber,
          @i_sortorder,
          @i_userid,
          getdate())
      END  
  END  --@i_projectkey > 0
  
  IF @i_elementkey > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM taqproductnumbers
    WHERE elementkey = @i_elementkey AND 
        productidcode = @i_productidcode

    IF @v_count > 0 
      UPDATE taqproductnumbers
      SET productnumber = @v_productnumber
      WHERE elementkey = @i_elementkey AND
        productidcode = @i_productidcode
    ELSE
      BEGIN
        EXEC next_generic_key NULL, @v_newkey OUTPUT, @v_errorcode OUTPUT, @v_errordesc OUTPUT

        INSERT INTO taqproductnumbers
          (productnumberkey,
          elementkey,
          productidcode,
          prefixcode,
          productnumber,
          sortorder,
          lastuserid,
          lastmaintdate)
        VALUES
          (@v_newkey,
          @i_elementkey,
          @i_productidcode,
          @i_prefixcode,
          @v_productnumber,
          @i_sortorder,
          @i_userid,
          getdate())
      END  
  END  --@i_elementkey > 0  

PRINT '@o_error_code: ' + CONVERT(VARCHAR, @o_error_code)
      
END  
GO

GRANT EXEC ON qproject_generate_productid TO PUBLIC
GO
