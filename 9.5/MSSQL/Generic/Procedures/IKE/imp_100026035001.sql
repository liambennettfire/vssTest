/******************************************************************************
**  Name: imp_100026035001
**  Desc: IKE Parse Author name
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100026035001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100026035001]
GO

CREATE PROCEDURE dbo.imp_100026035001 
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

/* Parse Author name */

BEGIN 

DECLARE  
  @v_name_value varchar(4000),
  @v_corp_ind int,
  @v_firstname varchar(80),
  @v_middlename varchar(80),
  @v_lastname varchar(80),
  @v_title varchar(80),
  @v_degree varchar(80),
  @v_suffix varchar(80),
  @v_addl_parms varchar(80),
  @v_calc_middlename int,
  @v_calc_title int,
  @v_calc_suffix int,
  @v_calc_degree int,
  @v_count INT,
  @v_errcode INT,
  @v_errlevel INT,
  @v_msg VARCHAR(4000)

BEGIN
  set @v_errcode = 0
  set @v_errlevel = 0
  set @v_msg = 'Parse author name'

  select @v_name_value = originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
    and row_id=@i_row
    and elementseq=@i_elementseq
    and elementkey=100026035

  select @v_count=count(*) 
    from author
    where lastname=@v_name_value
      and corporatecontributorind=1
  if @v_count>0
    begin
      set @v_corp_ind=1
      set @v_lastname=@v_name_value
    end

  if @v_corp_ind is null
    begin
      select @v_addl_parms=addlqualifier
        from imp_template_detail
        where templatekey=@i_templatekey
          and elementkey=100026035
      if @v_addl_parms is null
        begin
          exec parse_author_name @v_name_value,@v_firstname output,@v_middlename output,@v_lastname output,@v_title output,@v_suffix output,@v_degree output
        end
      else
        begin  
          set @v_calc_middlename=dbo.resolve_keyset(@v_addl_parms,1)
          set @v_calc_title=dbo.resolve_keyset(@v_addl_parms,2)
          set @v_calc_suffix=dbo.resolve_keyset(@v_addl_parms,3)
          set @v_calc_degree=dbo.resolve_keyset(@v_addl_parms,4)
          exec parse_author_name @v_name_value,@v_firstname output,@v_middlename output,@v_lastname output,@v_title output,@v_suffix output,@v_degree output,@v_calc_middlename,@v_calc_title,@v_calc_suffix,@v_calc_degree
        end
    end

  
  insert into imp_batch_detail
    (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
    values
    (@i_batchkey,@i_row,100026005,@i_elementseq,@v_name_value,@i_userid,getdate())

  if @v_firstname is not null
    insert into imp_batch_detail
      (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
      values
      (@i_batchkey,@i_row,100026001,@i_elementseq,@v_firstname,@i_userid,getdate())
  if @v_middlename is not null
    insert into imp_batch_detail
      (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
      values
      (@i_batchkey,@i_row,100026002,@i_elementseq,@v_middlename,@i_userid,getdate())
  if @v_lastname is not null
    insert into imp_batch_detail
      (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
      values
      (@i_batchkey,@i_row,100026000,@i_elementseq,@v_lastname,@i_userid,getdate())
  if @v_corp_ind is not null
    insert into imp_batch_detail
      (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
      values
      (@i_batchkey,@i_row,100026004,@i_elementseq,@v_corp_ind,@i_userid,getdate())
  if @v_suffix is not null
    insert into imp_batch_detail
      (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
      values
      (@i_batchkey,@i_row,100026016,@i_elementseq,@v_suffix,@i_userid,getdate())
  if @v_degree is not null
    insert into imp_batch_detail
      (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
      values
      (@i_batchkey,@i_row,100026006,@i_elementseq,@v_degree,@i_userid,getdate())
  if @v_title is not null
    insert into imp_batch_detail
      (batchkey,row_id,elementkey,elementseq,originalvalue,lastuserid,lastmaintdate)
      values
      (@i_batchkey,@i_row,100026017,@i_elementseq,@v_title,@i_userid,getdate())

  EXECUTE imp_write_feedback @i_batchkey, @i_row, null, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 1
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100026035001] to PUBLIC 
GO
