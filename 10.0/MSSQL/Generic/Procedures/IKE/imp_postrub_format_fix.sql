SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: imp_postrun_format_fix
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_postrun_format_fix]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_postrun_format_fix]
GO


CREATE PROCEDURE dbo.imp_postrun_format_fix
  @i_batchkey int,
  @i_mapkey int
  
AS

DECLARE 
  @v_count int,
  @v_row_id int,
  @v_bookkey int,
  @v_mediatypecode int,
  @v_mediatypesubcode int,
  @v_format varchar(100),
  @v_format_replace varchar(100)
  
BEGIN

  --initialize
  set @v_count = 0

  --
  declare c_rows cursor for 
    select distinct row_id
      from imp_batch_detail
      where batchkey=@i_batchkey
  open c_rows
  fetch c_rows into @v_row_id
  while @@FETCH_STATUS=0
    begin
      set @v_bookkey=dbo.imp_get_bookkey_from_row(@i_batchkey,@v_row_id)
      set @v_mediatypesubcode=null
      select
          @v_mediatypecode=mediatypecode,
          @v_mediatypesubcode=mediatypesubcode
        from bookdetail
        where bookkey=@v_bookkey
      if @v_mediatypesubcode is null and @v_mediatypecode is not null
        begin
          select @v_format=originalvalue
            from imp_batch_detail
            where batchkey=@i_batchkey
              and row_id=@v_row_id
              and elementkey=100012050
          if @v_format is not null
            begin
              if @i_mapkey is not null
                begin
                  select @v_format_replace=to_value
                    from imp_mapping
                    where mapkey=@i_mapkey
                      and from_value=@v_format
                  if @v_format_replace is not null
                    begin
                      set @v_format=@v_format_replace
                    end
                end
              select @v_mediatypesubcode=datasubcode
                from subgentables
                where datacode=@v_mediatypecode
                  and datadesc=@v_format
              update bookdetail
                set mediatypesubcode=@v_mediatypesubcode
                where bookkey=@v_bookkey
            end 
        end  
      fetch c_rows into @v_row_id
    end
  
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.imp_postrun_format_fix to PUBLIC 
GO

--exec imp_postrun_format_fix 10,914710151
--exec imp_postrun_format_fix 11,914710151
--exec imp_postrun_format_fix 12,914710151
--exec imp_postrun_format_fix 13,914710151
--exec imp_postrun_format_fix 14,914710151
