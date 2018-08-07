/******************************************************************************
**  Name: imp_100011025001
**  Desc: IKE Base level Org Entry
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100011025001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100011025001]
GO

CREATE PROCEDURE dbo.imp_100011025001 
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

/* Base level Org Entry */

BEGIN 

DECLARE  
  @v_errcode int,
  @v_new_value varchar(4000),
  @v_errlevel int,
  @v_msg varchar(500),
  @v_orgentrydesc  varchar(100),
  @v_orgentrykey int,
  @v_orgentryparentkey int,
  @v_orglevelnumber int,
  @v_elementkey int,
  @v_count int
BEGIN
  set @v_errlevel=1
  set @v_msg='Org Entry levels projected from Base'
  --
  select @v_count=count(*)
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row
      and elementkey=100011025
      and elementseq=@i_elementseq
  if @v_count=1 
    begin
      select @v_orgentrydesc=originalvalue
        from imp_batch_detail
        where batchkey=@i_batchkey
          and row_id=@i_row
          and elementkey=100011025
          and elementseq=@i_elementseq
    end
  select @v_count=count(*)
    from orgentry e, orglevel l
    where e.orgentrydesc=@v_orgentrydesc
      and e.orglevelkey=l.orglevelkey
      and l.orglevelnumber=(select max(orglevelnumber) from orglevel)
      and e.deletestatus = 'N'
  if @v_count=1 
    begin
      select @v_orgentrykey=e.orgentrykey,@v_orgentryparentkey=e.orgentryparentkey,@v_orglevelnumber=l.ORGLEVELNUMBER
        from orgentry e, orglevel l
        where e.orgentrydesc=@v_orgentrydesc
          and e.orglevelkey=l.orglevelkey
          and l.orglevelnumber=(select max(orglevelnumber) from orglevel)
          and e.deletestatus = 'N'
    end
  --
  while @v_orglevelnumber<1 or @v_orglevelnumber is not null 
    begin
      select @v_count=count(*)
        from imp_element_defs
        where elementmnemonic='OrgGroup'+cast(@v_orglevelnumber as varchar)
      if @v_count=1 
        begin
          select @v_elementkey=elementkey
            from imp_element_defs
            where elementmnemonic='OrgGroup'+cast(@v_orglevelnumber as varchar)
        end
        insert into imp_batch_detail
          (batchkey,row_id,elementseq,elementkey,originalvalue,lastuserid,lastmaintdate)
           values
          (@i_batchkey,@i_row,@i_elementseq,@v_elementkey,@v_orgentrydesc,@i_userid,getdate()) 

        select @v_count=count(*)
          from orgentry e, orglevel l 
          where e.orgentrykey=@v_orgentryparentkey
            and e.orglevelkey=l.orglevelkey
            and e.deletestatus = 'N'
        if @v_count=1 
          begin
            select @v_orgentrykey=orgentrykey,@v_orgentryparentkey=orgentryparentkey,@v_orglevelnumber=ORGLEVELNUMBER,@v_orgentrydesc=e.orgentrydesc
              from orgentry e, orglevel l 
              where e.orgentrykey=@v_orgentryparentkey
                and e.orglevelkey=l.orglevelkey
                and e.deletestatus = 'N'
          end
      else
        begin
          set @v_orglevelnumber=null
        end
  end
  --
  IF @v_errlevel >= @i_level
    begin
      exec imp_write_feedback @i_batchkey,@i_row,@v_elementkey,@i_elementseq,@i_rulekey,@v_msg,@v_errlevel,1
    END
  --
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100011025001] to PUBLIC 
GO

