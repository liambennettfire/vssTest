
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: imp_personel 
**  Desc: IKE update globalcontact tables
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_personel]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_personel]
GO

CREATE PROCEDURE imp_personel (
  @i_batchkey int,
  @i_row_id int,
  @i_elementseq int,
  @i_titlekeyset varchar(500),
  @i_userid varchar(50)
  )
AS

DECLARE
  @v_errcode int,
  @v_errmsg varchar(500),
  @v_count int,
  @v_displayname varchar(100) ,
  @v_firstname varchar(100) ,
  @v_middlename varchar(100) ,
  @v_lastname varchar(100) ,
  @v_dept varchar(100),
  @v_deptcode int,
  @v_deptcode_org int,
  @v_role varchar(100),
  @v_rolecode int,
  @v_rolecode_org int,
  @v_bookkey int,
  @v_printingkey int,
  @v_bookcontactkey int,
  @v_globalcontactkey int,
  @v_contributorkey int,
  @v_sortorder int
begin

  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
  SET @v_printingkey = dbo.resolve_keyset(@i_titlekeyset,2)
  select @v_firstname=originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row_id
      and elementseq=@i_elementseq
      and elementkey=100024011
  select @v_middlename=originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row_id
      and elementseq=@i_elementseq
      and elementkey=100024012
  select @v_lastname=originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row_id
      and elementseq=@i_elementseq
      and elementkey=100024013
  select @v_displayname=originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row_id
      and elementseq=@i_elementseq
      and elementkey=100024014
  select @v_dept=originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row_id
      and elementseq=@i_elementseq
      and elementkey=100024016
  select @v_role=originalvalue
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row_id
      and elementseq=@i_elementseq
      and elementkey=100024015

  --find contributor
  select top 1 @v_globalcontactkey=globalcontactkey
    from globalcontact
    where coalesce(firstname,'')=coalesce(@v_firstname,'')
      and coalesce(middlename,'')=coalesce(@v_middlename,'')
      and coalesce(lastname,'')=coalesce(@v_lastname,'')
      and personnelind=1
  
  if @v_globalcontactkey is null
    begin
      update keys set generickey=generickey+1
      select @v_globalcontactkey=generickey from keys
      insert globalcontact
        (globalcontactkey,firstname,middlename,lastname,displayname,personnelind,individualind,privateind,searchname,activeind,deceasedind,lastuserid,lastmaintdate)
        values
        (@v_globalcontactkey,@v_firstname,@v_middlename,@v_lastname,@v_displayname,1,1,0,upper(@v_lastname),1,0,@i_userid,getdate())
    end

  set @v_bookcontactkey=null
  select @v_bookcontactkey=bookcontactkey
    from bookcontact
    where bookkey=@v_bookkey
      and printingkey=@v_printingkey
      and globalcontactkey=@v_globalcontactkey
  if @v_bookcontactkey is null
    begin
      update keys set generickey=generickey+1
      select @v_bookcontactkey=generickey from keys
      select @v_sortorder=sortorder
        from bookcontact
        where bookkey=@v_bookkey
          and printingkey=@v_printingkey
      set @v_sortorder=coalesce(@v_sortorder,0)+1
      insert into bookcontact
        (bookcontactkey,bookkey,printingkey,globalcontactkey,sortorder,lastuserid,lastmaintdate)
        values
        (@v_bookcontactkey,@v_bookkey,@v_printingkey,@v_globalcontactkey,@v_sortorder,@i_userid,getdate())
      EXECUTE imp_write_feedback @i_batchkey, @i_row_id, null, @i_elementseq ,300024013001 , 'bookcontact added', @v_errcode, 3
      exec qtitle_update_titlehistory 
        'bookcontact','globalcontactkey',@v_bookkey,@v_printingkey,null,
        @v_globalcontactkey,'insert',@i_userid,null,null,
        @v_errcode output, @v_errmsg output
    end

  select @v_count=count(*)
    from bookcontactrole
    where bookcontactkey=@v_bookcontactkey
  if @v_count = 0
    begin
      insert into bookcontactrole
        (bookcontactkey,rolecode,lastuserid,lastmaintdate)
        values
        (@v_bookcontactkey,7,@i_userid,getdate())
    end

  if @v_dept is not null
    begin
      select @v_deptcode=datacode
        from gentables
        where tableid=286
          and datadesc=rtrim(ltrim(@v_dept))
    end
  if @v_deptcode is not null
    begin
      select @v_deptcode_org=departmentcode
        from bookcontactrole
        where bookcontactkey=@v_bookcontactkey          
      if coalesce(@v_deptcode_org,0)<>coalesce(@v_deptcode,0)
        begin
          update bookcontactrole
            set departmentcode=@v_deptcode
            where bookcontactkey=@v_bookcontactkey
        end
    end

  if @v_role is not null
    begin
      select @v_rolecode=datacode
        from gentables
        where tableid=285
          and datadesc=@v_role
    end
  if @v_rolecode is not null
    begin
      select @v_rolecode_org=rolecode
        from bookcontactrole
        where bookcontactkey=@v_bookcontactkey
      if coalesce(@v_rolecode_org,0)<>coalesce(@v_rolecode,0)
        begin
          update bookcontactrole
            set rolecode=@v_rolecode
            where bookcontactkey=@v_bookcontactkey
        end
    end

end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

