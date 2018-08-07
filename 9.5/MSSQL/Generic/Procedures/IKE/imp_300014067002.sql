/******************************************************************************
**  Name: imp_300014067002
**  Desc: IKE Replace Edition description
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300014067002]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300014067002]
GO

CREATE PROCEDURE dbo.imp_300014067002 
  
  @i_batch int, 
  @i_row int , 
  @i_dmlkey bigint, 
  @i_titlekeyset varchar(500),
  @i_contactkeyset varchar(500),
  @i_templatekey int,
  @i_elementseq int,
  @i_level int,
  @i_userid varchar(50),
  @i_newtitleind int,
  @i_newcontactind int,
  @o_writehistoryind int output
AS

/* Replace Edition description */

BEGIN 

DECLARE
  @v_desc     VARCHAR(400),
  @v_desc1     VARCHAR(400),
  @v_desc2     VARCHAR(400),
  @v_desc3     VARCHAR(400),
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_bookkey     INT
    
BEGIN
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Edition description '
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)

--bookdetail.editionnumber - alternatedesc1 from gentables tableid = 557
  select @v_desc1=alternatedesc1
    from bookdetail b, gentables g
    where b.bookkey=@v_bookkey
      and b.editionnumber=g.datacode
      and g.tableid=557
      
--bookdetail.editioncode - resolved through gentables tableid = 200
  select @v_desc2=datadesc
    from bookdetail b, gentables g
    where b.bookkey=@v_bookkey
      and b.editioncode=g.datacode
      and g.tableid=200

--bookdetail.additionaleditinfo
  select @v_desc3=additionaleditinfo
    from bookdetail b
    where b.bookkey=@v_bookkey

  set @v_desc=@v_desc1
  if @v_desc is not null and @v_desc2 is not null
    begin
      set @v_desc=@v_desc+','+@v_desc2
    end
  if @v_desc is null and @v_desc2 is not null
    begin
      set @v_desc=@v_desc2
    end
  if @v_desc is not null and @v_desc3 is not null
    begin
      set @v_desc=@v_desc+','+@v_desc3
    end
  if @v_desc is null and @v_desc3 is not null
    begin
      set @v_desc=@v_desc3
    end

  update bookdetail
    set editiondescription=@v_desc
    where bookkey=@v_bookkey
  
      --EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , 'ed num desc', @i_level, 3 

END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300014067002] to PUBLIC 
GO
