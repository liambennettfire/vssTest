if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_add_taqprojectelement') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_add_taqprojectelement
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_add_taqprojectelement
  (@i_projectkey  integer,
  @i_taqelementtypecode integer,
  @i_taqelementtypesubcode  integer,
  @i_elementdesc  varchar(255),
  @i_userid   varchar(30),
  @o_taqelementkey  integer output,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_add_taqprojectelement
**  Desc: This stored procedure adds a new row to taqprojectelement table.
**
**    Auth: Kate
**    Date: 9/28/04
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**	  03/07/2016  Uday A. Khisty  Case 36706
*******************************************************************************/

  DECLARE
    @v_taqelementkey  INT,
    @v_taqelementnumber INT,
    @v_taqelementdesc VARCHAR(255),
    @v_error  INT,
    @v_rowcount INT
  
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_taqelementkey = 0
  
  /* Generate new taqelementkey for taqprojectelement table */
  EXEC get_next_key @i_userid, @v_taqelementkey OUTPUT
  
  IF @v_taqelementkey IS NOT NULL
   BEGIN
   
    /* Get the maximum element number currently on taqprojectelement table */
    EXEC qproject_get_max_element_number @i_projectkey, 0, @i_taqelementtypecode,
      @i_taqelementtypesubcode, @v_taqelementnumber OUTPUT,
      @o_error_code OUTPUT, @o_error_desc OUTPUT
      
    IF @v_taqelementnumber IS NOT NULL
      SET @v_taqelementnumber = @v_taqelementnumber + 1
    ELSE
      SET @v_taqelementnumber = 1
      
    IF @i_elementdesc IS NULL OR LTRIM(RTRIM(@i_elementdesc)) = ''
     BEGIN
      /* Get the element description - from gentables or subgentables */
      /* based on whether taqelementtypesubcode detail was passed on not */
      IF @i_taqelementtypesubcode > 0
        BEGIN
          SELECT @v_taqelementdesc = datadesc
          FROM subgentables
          WHERE tableid = 287 AND datacode = @i_taqelementtypecode AND
              datasubcode = @i_taqelementtypesubcode
        END
      ELSE
        BEGIN
          SELECT @v_taqelementdesc = datadesc
          FROM gentables
          WHERE tableid = 287 AND datacode = @i_taqelementtypecode
        END
     END
    ELSE
     BEGIN
      SET @v_taqelementdesc = @i_elementdesc
     END
      
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'Could not get element description'
      RETURN
    END      
    
    /***** ADD new row to TAQPROJECTELEMENT table ****/
    INSERT INTO taqprojectelement
      (taqelementkey,
      taqprojectkey,
      taqelementtypecode,
      taqelementtypesubcode,
      taqelementnumber,
      taqelementdesc,
      sortorder,
      lastuserid,
      lastmaintdate)
    VALUES
      (@v_taqelementkey,
      @i_projectkey,
      @i_taqelementtypecode,
      @i_taqelementtypesubcode,
      @v_taqelementnumber,
      @v_taqelementdesc + ' #' + CAST(@v_taqelementnumber AS VARCHAR),
      @v_taqelementnumber,
      @i_userid,
      getdate())
      
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'Error inserting to taqprojectelement table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) +
            ', taqelementkey=' + CAST(@v_taqelementkey AS VARCHAR)
    END  

    SET @o_taqelementkey = @v_taqelementkey
   END
   
  ELSE  --@v_taqelementkey not generated (NULL)
   BEGIN
      SET @o_error_code = 1
      SET @o_error_desc = 'Could not generate new taqelementkey (taqprojectelement table)'
   END
GO

GRANT EXEC ON qproject_add_taqprojectelement TO PUBLIC
GO
