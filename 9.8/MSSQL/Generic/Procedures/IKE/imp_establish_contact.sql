/******************************************************************************
**  Name: imp_establish_contact
**  Desc: IKE find the most appropriate author for the title
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_establish_contact]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_establish_contact]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE imp_establish_contact
  @i_batchkey int,
  @i_row_id int,
  @i_elementseq varchar(20),
  @i_default_orgkeyset varchar(8000),
  @i_userid varchar(50),
  @o_contactorgkeyset varchar(500) output,
  @o_newcontactind int output,
  @o_errcode int output,
  @o_errmsg varchar(500) output
AS
DECLARE 
  @v_productnumber varchar(50),
  @v_orglevenumber int,
  @v_orglevelkey int,
  @v_orglevel int,
  @v_filterorglevel int,
  @v_orgentrykey int,
  @v_orgleveldesc varchar(50),
  @v_elementkey bigint,
  @v_originalvalue varchar(500),
  @v_default_orgkey int,
  @v_default_diff int,
  @v_default_use int,
  @v_count int,
  @v_multi_match_ind int,
  @v_lastname varchar(80),
  @v_firstname varchar(80),
  @v_middlename varchar(80),
  @v_bookkey int,
  @v_contactkey int,
  @v_contactkey_1st int,
  @DEBUG int
BEGIN
  --initialize
  set @v_productnumber = ''
  set @v_orglevenumber = 0
  set @v_orglevelkey = 0
  set @v_orgentrykey = 0
  set @v_orgleveldesc = ''
  set @v_elementkey = 0
  set @v_originalvalue = ''
  set @v_default_orgkey = 0
  set @v_default_diff = 0
  set @v_default_use = 0
  set @o_errcode = 0
  set @o_errmsg = ''
  set @v_contactkey = null
  set @o_contactorgkeyset = ''
  set @o_newcontactind = 0
  set @DEBUG=0
  --try to retrieve an orgkeyset
  
  if @DEBUG<>0 print '[dbo].[imp_establish_contact]'
  
  declare org_cur cursor for 
    select orglevelnumber,orglevelkey,orgleveldesc
      from orglevel
      order by orglevelnumber
  open org_cur 
  fetch org_cur into @v_orglevenumber,@v_orglevelkey,@v_orgleveldesc
  
--orglevelnumber	orglevelkey	orgleveldesc
--1					1			Company
--2					2			Publisher
--3					3			Imprint
  
  while @@fetch_status = 0
    begin
	  SET @v_elementkey=CAST('10001101'+CAST(@v_orglevelkey as varchar(max)) as BIGINT)
    
      set @v_originalvalue = null
      set @v_orgentrykey = null
      set @v_default_orgkey = dbo.resolve_keyset(@i_default_orgkeyset,@v_orglevenumber)
      
      if @DEBUG<>0 print ''
      if @DEBUG<>0 print '@i_default_orgkeyset = ' + coalesce(cast(@i_default_orgkeyset as varchar(max)),'*NULL*')
      if @DEBUG<>0 print '@v_orglevenumber = ' + coalesce(cast(@v_orglevenumber as varchar(max)),'*NULL*')
      if @DEBUG<>0 print '@v_default_orgkey = ' + coalesce(cast(@v_default_orgkey as varchar(max)),'*NULL*')
      
      if @DEBUG<>0 print '@v_orglevenumber = ' + coalesce(cast(@v_orglevenumber as varchar(max)),'*NULL*')
      if @DEBUG<>0 print '@v_orglevelkey = ' + coalesce(cast(@v_orglevelkey as varchar(max)),'*NULL*')
      if @DEBUG<>0 print '@v_orgleveldesc = ' + coalesce(cast(@v_orgleveldesc as varchar(max)),'*NULL*')
      
      if @DEBUG<>0 print '@i_batchkey = ' + coalesce(cast(@i_batchkey as varchar(max)),'*NULL*')
      if @DEBUG<>0 print '@i_row_id = ' + coalesce(cast(@i_row_id as varchar(max)),'*NULL*')
      if @DEBUG<>0 print '@i_elementseq = ' + coalesce(cast(@i_elementseq  as varchar(max)),'*NULL*')
      if @DEBUG<>0 print '@v_elementkey = ' + coalesce(cast(@v_elementkey  as varchar(max)),'*NULL*')
      
      select @v_originalvalue = bd.originalvalue
        from imp_batch_detail bd
        where bd.elementkey=@v_elementkey
          and bd.batchkey=@i_batchkey
          and bd.row_id = @i_row_id
      if @v_originalvalue is not null
        begin
			if @DEBUG<>0 print ''
			if @DEBUG<>0 print '@v_originalvalue is not null'
			if @DEBUG<>0 print '@v_originalvalue = ' + coalesce(cast(@v_originalvalue as varchar(max)),'*NULL*')
			
          select @v_orgentrykey = orgentrykey
            from orgentry
            where CASE  WHEN left(orgentrydesc,36)=left(altdesc1,36) and len(altdesc1)>40 and exists(select * from customer where customerkey=1 and customershortname='DAB') THEN altdesc1 ELSE orgentrydesc END=@v_originalvalue
              and orglevelkey=@v_orglevelkey
              
        end
      if @v_orgentrykey is not null
        begin
			if @DEBUG<>0 print ''
			if @DEBUG<>0 print '@v_orgentrykey is not null'
			if @DEBUG<>0 print '@v_orgentrykey = ' + coalesce(cast(@v_orgentrykey as varchar(max)),'*NULL*')
          if @o_contactorgkeyset = ''
            begin
              set @o_contactorgkeyset = cast(@v_orgentrykey as varchar(20))
            end
          else
            begin
              set @o_contactorgkeyset = @o_contactorgkeyset+','+cast(@v_orgentrykey as varchar(20))
            end
          if @v_orgentrykey <> @v_default_orgkey
            begin
              set @v_default_diff = 1
            end
            
            if @DEBUG<>0 print '@o_contactorgkeyset = ' + coalesce(cast(@o_contactorgkeyset as varchar(max)),'*NULL*')
        end
      else
        begin
			if @DEBUG<>0 print ''
			if @DEBUG<>0 print '@v_orgentrykey IS null'
          if @o_contactorgkeyset = ''
            begin
				if @DEBUG<>0 print ''
				if @DEBUG<>0 print '@o_contactorgkeyset = '''''
              set @o_contactorgkeyset = cast(@v_default_orgkey as varchar(20))
            end
          else
            begin
				if @DEBUG<>0 print ''
				if @DEBUG<>0 print '@o_contactorgkeyset != '''''
              set @o_contactorgkeyset = @o_contactorgkeyset+','+cast(@v_default_orgkey as varchar(20))
            end
          set @v_default_use = 1
        end
      fetch org_cur into @v_orglevenumber,@v_orglevelkey,@v_orgleveldesc
    end
  close org_cur 
  deallocate org_cur 
  if (@v_default_diff = 1 and @v_default_use = 1) 
    begin
		if @DEBUG<>0 print ''
		if @DEBUG<>0 print '(@v_default_diff = 1 and @v_default_use = 1) '
      if dbo.valid_orgkeyset (@o_contactorgkeyset) = 0
        begin
          set @o_errcode = -1
          set @o_errmsg = 'could not determine contact organization levels for row '+cast(@i_row_id as varchar)
          exec imp_write_feedback @i_batchkey,@i_row_id,null,null,null,@o_errmsg,3,3
        end
    end
  if @o_contactorgkeyset is null
    begin
		if @DEBUG<>0 print ''
		if @DEBUG<>0 print 'if @o_contactorgkeyset is null'
      set @o_errcode = -1
      set @o_errmsg = 'No organization levels for row '+cast(@i_row_id as varchar)
      exec imp_write_feedback @i_batchkey,@i_row_id,null,null,null,@o_errmsg,1,3
    end
    
    if @DEBUG<>0 print ''
    if @DEBUG<>0 print '203'
    
  --try to retrieve a contactkey
  select @v_orglevel=max(orglevelnumber)
    from orglevel
  select @v_filterorglevel=o.orglevelnumber
    from filterorglevel f, orglevel o
    where f.filterkey=7
      and f.filterorglevelkey=o.orglevelkey
  -- get contact search values
  select @v_lastname = bd.originalvalue
    from imp_batch_detail bd
    where bd.batchkey=@i_batchkey
      and bd.row_id = @i_row_id
      and bd.elementkey= 100026000
      and bd.elementseq=@i_elementseq
  if @v_lastname is null
    begin
      select @v_lastname = bd.originalvalue
        from imp_batch_detail bd
        where bd.batchkey=@i_batchkey
          and bd.row_id = @i_row_id
          and bd.elementkey=100023011
          and bd.elementseq=@i_elementseq
    end
  select @v_firstname = bd.originalvalue
    from imp_batch_detail bd
    where bd.batchkey=@i_batchkey
      and bd.row_id = @i_row_id
      and bd.elementkey=100026001
      and bd.elementseq=@i_elementseq
  if @v_firstname is null
    begin
      select @v_firstname = bd.originalvalue
        from imp_batch_detail bd
        where bd.batchkey=@i_batchkey
          and bd.row_id = @i_row_id
          and bd.elementkey=100023010
          and bd.elementseq=@i_elementseq
    end
  select @v_middlename = bd.originalvalue
    from imp_batch_detail bd 
    where bd.batchkey=@i_batchkey
      and bd.row_id = @i_row_id
      and bd.elementkey=100026002
      and bd.elementseq=@i_elementseq
  if @v_middlename is null
    begin
      select @v_middlename = bd.originalvalue
        from imp_batch_detail bd 
        where bd.batchkey=@i_batchkey
          and bd.row_id = @i_row_id
          and bd.elementkey=10023012
          and bd.elementseq=@i_elementseq
    end

  --try to locate unique contactkey
  -- look at title first - if dup name this may get the right one
  set @v_bookkey=dbo.imp_get_bookkey_from_row(@i_batchkey,@i_row_id)
  
  if @DEBUG<>0 print '@v_bookkey = ' + coalesce(cast(@v_bookkey as varchar(max)),'*NULL*')
  if @DEBUG<>0 print '@v_firstname = ' + coalesce(cast(@v_firstname as varchar(max)),'*NULL*')
  if @DEBUG<>0 print '@v_lastname = ' + coalesce(cast(@v_lastname as varchar(max)),'*NULL*')
  if @DEBUG<>0 print '@v_middlename = ' + coalesce(cast(@v_middlename as varchar(max)),'*NULL*')
    
  if @v_firstname is not null and
     @v_lastname is not null and
     @v_middlename is not null
    begin
    if @DEBUG<>0 print '**********************************************************'
    if @DEBUG<>0 print '@v_firstname is not null and
     @v_lastname is not null and
     @v_middlename is not null'
     
      select @v_count = count(*)
        from globalcontact gc, bookauthor ba
        where gc.firstname = @v_firstname 
          and gc.lastname = @v_lastname
          and gc.middlename = @v_middlename
          and gc.globalcontactkey = ba.authorkey
          and ba.bookkey=@v_bookkey
      if @v_count = 1
        begin
          select @v_contactkey = gc.globalcontactkey
            from globalcontact gc, bookauthor ba
              where gc.firstname = @v_firstname 
                and gc.lastname = @v_lastname
                and gc.middlename = @v_middlename
                and gc.globalcontactkey = ba.authorkey
                and ba.bookkey=@v_bookkey
        end
    end
  if @v_firstname is not null and
      @v_lastname is not null and
      @v_middlename is null and
      @v_contactkey is null
    begin
    if @DEBUG<>0 print ''
    if @DEBUG<>0 print '@v_firstname is not null and
      @v_lastname is not null and
      @v_middlename is null and
      @v_contactkey is null'
      
      select @v_count = count(*)
        from globalcontact gc, bookauthor ba
        where gc.firstname = @v_firstname 
          and gc.lastname = @v_lastname
		  and gc.middlename is null 
          and gc.globalcontactkey = ba.authorkey
          and ba.bookkey=@v_bookkey
      if @v_count = 1
        begin
          select @v_contactkey = gc.globalcontactkey
            from globalcontact gc, bookauthor ba
              where gc.firstname = @v_firstname 
                and gc.lastname = @v_lastname
			    and gc.middlename is null 
                and gc.globalcontactkey = ba.authorkey
                and ba.bookkey=@v_bookkey
        end
    end
  if @v_firstname is null and
     @v_lastname is not null and
     @v_middlename is null and
     @v_contactkey is null
    begin
    if @DEBUG<>0 print ''
    if @DEBUG<>0 print '@v_firstname is null and
     @v_lastname is not null and
     @v_middlename is null and
     @v_contactkey is null'
      select @v_count = count(*)
        from globalcontact gc, bookauthor ba
        where gc.lastname = @v_lastname
          and gc.globalcontactkey = ba.authorkey
		  and gc.middlename is null 
		  and gc.firstname is null           
          and ba.bookkey=@v_bookkey
      if @v_count = 1
        begin
          select @v_contactkey = gc.globalcontactkey
            from globalcontact gc, bookauthor ba
              where gc.lastname = @v_lastname
			    and gc.middlename is null 
			    and gc.firstname is null               
                and gc.globalcontactkey = ba.authorkey
                and ba.bookkey=@v_bookkey
        end
    end

  -- look at the rest 
  if @DEBUG<>0 print ''
  if @DEBUG<>0 print '-- look at the rest '

    if @DEBUG<>0 print 'while @v_orglevel >= @v_filterorglevel and @v_contactkey is null'
    if @DEBUG<>0 print '@v_orglevel = ' + coalesce(cast(@v_orglevel as varchar(max)),'*NULL*')
    if @DEBUG<>0 print '@v_filterorglevel = ' + coalesce(cast(@v_filterorglevel as varchar(max)),'*NULL*')
    if @DEBUG<>0 print '@v_contactkey = ' + coalesce(cast(@v_contactkey as varchar(max)),'*NULL*')

  set @v_multi_match_ind = 0
  while @v_orglevel >= @v_filterorglevel and @v_contactkey is null
    begin

    if @DEBUG<>0 print '------------ inside loop ------------ '
    if @DEBUG<>0 print 'while @v_orglevel >= @v_filterorglevel and @v_contactkey is null'
    if @DEBUG<>0 print '@v_orglevel = ' + coalesce(cast(@v_orglevel as varchar(max)),'*NULL*')
    if @DEBUG<>0 print '@v_filterorglevel = ' + coalesce(cast(@v_filterorglevel as varchar(max)),'*NULL*')
    if @DEBUG<>0 print '@v_contactkey = ' + coalesce(cast(@v_contactkey as varchar(max)),'*NULL*')
        
      set @v_orgentrykey=dbo.resolve_keyset (@o_contactorgkeyset,@v_orglevel)
     
      if @DEBUG<>0 print '@v_orgentrykey = ' + coalesce(cast(@v_orgentrykey as varchar(max)),'*NULL*')
     
      if @v_contactkey is null
        and @v_lastname is not null
        and @v_firstname is not null
        and @v_middlename is not null
        begin
        if @DEBUG<>0 print ''
        if @DEBUG<>0 print '@v_contactkey is null
        and @v_lastname is not null
        and @v_firstname is not null
        and @v_middlename is not null'
          select @v_count = count(*)
            from globalcontact gc, globalcontactorgentry gco
            where gc.firstname = @v_firstname 
              and gc.lastname = @v_lastname
              and gc.middlename = @v_middlename
              and gc.globalcontactkey = gco.globalcontactkey
              and gco.orgentrykey=@v_orgentrykey
          if @v_count = 1
            begin
              select @v_contactkey = gc.globalcontactkey
                from globalcontact gc, globalcontactorgentry gco
                where gc.firstname = @v_firstname 
                  and gc.lastname = @v_lastname
                  and gc.middlename = @v_middlename
                  and gc.globalcontactkey = gco.globalcontactkey
                  and gco.orgentrykey=@v_orgentrykey
            end
          if @v_count > 1
            begin
              set @v_multi_match_ind = 1
              select top 1 @v_contactkey_1st = gc.globalcontactkey
                from globalcontact gc, globalcontactorgentry gco
                where gc.firstname = @v_firstname 
                  and gc.lastname = @v_lastname
                  and gc.middlename = @v_middlename
                  and gc.globalcontactkey = gco.globalcontactkey
                  and gco.orgentrykey=@v_orgentrykey
                order by gc.lastmaintdate desc
            end
        end
      if @v_contactkey is null
        and @v_lastname is not null
        and @v_firstname is not null
        and @v_middlename is null
        begin
        
        if @DEBUG<>0 print '@v_contactkey is null
        and @v_lastname is not null
        and @v_firstname is not null
        and @v_middlename is null'
        
          select @v_count = count(*)
            from globalcontact gc, globalcontactorgentry gco
            where gc.firstname = @v_firstname 
              and gc.lastname = @v_lastname
              and gc.middlename is null
              and gc.globalcontactkey = gco.globalcontactkey
              and gco.orgentrykey=@v_orgentrykey
          if @v_count = 1
            begin
              select @v_contactkey = gc.globalcontactkey
                from globalcontact gc, globalcontactorgentry gco
                where gc.firstname = @v_firstname 
                  and gc.lastname = @v_lastname
                  and gc.middlename is null
                  and gc.globalcontactkey = gco.globalcontactkey
                  and gco.orgentrykey=@v_orgentrykey
            end
          if @v_count > 1
            begin
              set @v_multi_match_ind = 1
              select top 1 @v_contactkey_1st = gc.globalcontactkey
                from globalcontact gc, globalcontactorgentry gco
                where gc.firstname = @v_firstname 
                  and gc.lastname = @v_lastname
                  and gc.middlename is null
                  and gc.globalcontactkey = gco.globalcontactkey
                  and gco.orgentrykey=@v_orgentrykey
                order by gc.lastmaintdate desc
            end
        end
      if @v_contactkey is null
        and @v_lastname is not null
        and @v_firstname is null
        and @v_middlename is null
        begin
        
		if @DEBUG<>0 print '@v_contactkey is null
        and @v_lastname is not null
        and @v_firstname is null
        and @v_middlename is null'
        
        if @DEBUG<>0 print ''
        if @DEBUG<>0 print '@v_lastname = ' + @v_lastname
        if @DEBUG<>0 print '@v_orgentrykey = ' + cast (@v_orgentrykey as varchar(max))
        
          select @v_count = count(*)
            from globalcontact gc, globalcontactorgentry gco
            where gc.lastname = @v_lastname
			  and gc.middlename is null 
			  and gc.firstname is null 
              and gc.globalcontactkey = gco.globalcontactkey
              and gco.orgentrykey=@v_orgentrykey
          if @v_count = 1
            begin
              select @v_contactkey = gc.globalcontactkey
                from globalcontact gc, globalcontactorgentry gco
                where gc.lastname = @v_lastname
				  and gc.middlename is null 
				  and gc.firstname is null 
                  and gc.globalcontactkey = gco.globalcontactkey
                  and gco.orgentrykey=@v_orgentrykey
            end
          if @v_count > 1
            begin
              set @v_multi_match_ind = 1
              select top 1 @v_contactkey_1st = gc.globalcontactkey
                from globalcontact gc, globalcontactorgentry gco
                where gc.lastname = @v_lastname
				  and gc.middlename is null 
				  and gc.firstname is null                 
                  and gc.globalcontactkey = gco.globalcontactkey
                  and gco.orgentrykey=@v_orgentrykey
                order by gc.lastmaintdate desc
            end
        end
      set @v_orglevel=@v_orglevel-1
    end
  if @v_multi_match_ind = 1 and @v_contactkey is null
    begin
		if @DEBUG<>0 print ''
		if @DEBUG<>0 print '@v_multi_match_ind = 1 and @v_contactkey is null'
      set @v_contactkey = @v_contactkey_1st
      if @DEBUG<>0 print '@v_contactkey = ' + coalesce(cast(@v_contactkey as varchar(max)),'*NULL*')
      exec imp_write_feedback @i_batchkey,@i_row_id,null,@i_elementseq,null,'multiple contacts available, selected oldest',1,3
    end
  --fill in blanks
  set @o_newcontactind = 0
  if @v_contactkey is null and @o_errcode <> -1  
    begin
		if @DEBUG<>0 print ''
		if @DEBUG<>0 print '@v_contactkey is null and @o_errcode <> -1'
      update keys 
        set generickey=generickey+1
      select @v_contactkey = generickey
        from keys
      exec create_author_minimum @v_contactkey,@o_contactorgkeyset,@i_userid,@o_errcode output,@o_errmsg output
      if @DEBUG<>0 print 'exec create_author_minimum @v_contactkey,@o_contactorgkeyset,@i_userid,@o_errcode output,@o_errmsg output'
      if @DEBUG<>0 print '@v_contactkey = ' + coalesce(cast(@v_contactkey as varchar(max)),'*NULL*')
      set @o_newcontactind = 1
    end 
  set @o_contactorgkeyset = cast(@v_contactkey as varchar(20))+','+ @o_contactorgkeyset
if @DEBUG<>0 print ''
if @DEBUG<>0 print '@o_contactorgkeyset = ' + @o_contactorgkeyset 
END

