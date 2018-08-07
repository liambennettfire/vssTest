/******************************************************************************
**  Name: imp_row_productnum
**  Desc: IKE 
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.imp_row_productnum') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.imp_row_productnum
GO

create FUNCTION imp_row_productnum
    ( @i_batchkey as int,
      @i_row_id as int ) 

RETURNS varchar(80)

BEGIN 

  DECLARE 
    @o_string varchar(80),
    @v_string varchar(80)
  
  select @v_string=originalvalue
    from imp_batch_detail bd, imp_element_defs ed
    where row_id=@i_row_id
      and batchkey=@i_batchkey
      and bd.elementkey=ed.elementkey
      and ed.leadkeyname='bookkey'
    order by ed.elementkey desc
  
  set @o_string = coalesce(@v_string,'n/a')

  RETURN @o_string
END 
