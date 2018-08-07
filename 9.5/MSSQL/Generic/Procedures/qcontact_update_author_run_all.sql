
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcontact_update_author_run_all')
  BEGIN
   DROP  procedure qcontact_update_author_run_all
  END
GO
CREATE procedure [dbo].qcontact_update_author_run_all as
/******************************************************************************
**  File: 
**  Name: qcontact_update_author_run_all
**  Desc: Uses the proc qcontact_update_author to copy contact info, addresses, contact methods and author bio from the global contact tables
**        Runs for all authors with matching globalcontactkeys
**        It also maintains the globalcontactauthor table that links the data from author to globalcontacts
**
**    Parameters:
**    Input              
**    ----------         
**    none
**    
**    Output
**    -----------
**    Print statements for error reporting
**
**    Auth: Bill Bennett
**    Date: 5/25/2011
*******************************************************************************
**    Change History
*******************************************************************************
**  none
*******************************************************************************/
declare
  @v_count int,
  @v_masterkey int,
  @v_detailkey int,
  @v_scopetag varchar(20),
  @v_address1 varchar(200),
  @v_address2 varchar(200),
  @v_address3 varchar(200),
  @v_city varchar(200),
  @v_zipcode varchar(20),
  @v_statecode int,
  @v_countrycode int,
  @o_error_code int,
  @o_error_desc varchar(500)

declare authors cursor fast_forward for
  select authorkey
    from author a, globalcontact gc
    where a.authorkey=gc.globalcontactkey


open authors
fetch authors into @v_masterkey
while @@fetch_status=0
  begin
--print '..................'
--print @v_masterkey
    -- check for contact row
    set @o_error_code = null
    set @o_error_desc = null
    exec qcontact_update_author @v_masterkey,@v_masterkey,'firebrand','globalcontact',@o_error_code output,@o_error_desc output
    if @o_error_code<>0
      begin
        print 'Error (masterkey='+cast(@v_masterkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
      end

    -- check for addr1-3 
    declare addresses cursor fast_forward for
      select globalcontactaddresskey
        from globalcontactaddress
        where globalcontactkey=@v_masterkey
    open addresses
    -- addressline 1
    fetch addresses into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontactaddress',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    -- addressline 1
    fetch addresses into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontactaddress',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    -- addressline 1
    fetch addresses into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontactaddress',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    close addresses
    deallocate addresses


    -- check for phone 1-3
    declare methods cursor fast_forward for
      select globalcontactmethodkey
        from globalcontactmethod
        where globalcontactkey=@v_masterkey
          and contactmethodcode=1
    open methods
    -- phone 1
    fetch methods into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontmethod',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    -- phone 2
    fetch methods into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontmethod',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    -- phone 3
    fetch methods into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontmethod',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    close methods
    deallocate methods

    -- check for fax 1-3
    declare methods cursor fast_forward for
      select globalcontactmethodkey
        from globalcontactmethod
        where globalcontactkey=@v_masterkey
          and contactmethodcode=2
    open methods
    -- fax 1
    fetch methods into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontmethod',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    -- fax 2
    fetch methods into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontmethod',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    -- fax 3
    fetch methods into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontmethod',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    close methods
    deallocate methods

    -- check for email 1-3
    declare methods cursor fast_forward for
      select globalcontactmethodkey
        from globalcontactmethod
        where globalcontactkey=@v_masterkey
          and contactmethodcode=3
    open methods
    -- email 1
    fetch methods into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontmethod',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    -- email 2
    fetch methods into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontmethod',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    -- email 3
    fetch methods into @v_detailkey
    if @@fetch_status=0
      begin
        set @o_error_code = null
        set @o_error_desc = null
        exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontmethod',@o_error_code output,@o_error_desc output
        if @o_error_code<>0
          begin
            print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
          end
      end
    close methods
    deallocate methods

    -- check for URL row
    select @v_detailkey=globalcontactmethodkey
      from globalcontactmethod
      where globalcontactkey=@v_masterkey
        and contactmethodcode=4
    set @o_error_code = null
    set @o_error_desc = null
    exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','globalcontmethod',@o_error_code output,@o_error_desc output
    if @o_error_code<>0
      begin
        print 'Error (masterkey='+cast(@v_masterkey as varchar)+', detailkey='+cast(@v_detailkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
      end

    -- check for biogr row
    select @v_detailkey=datacode
      from gentables
      where tableid=528
        and qsicode=2
    set @o_error_code = null
    set @o_error_desc = null
    exec qcontact_update_author @v_masterkey,@v_detailkey,'firebrand','qsicomments',@o_error_code output,@o_error_desc output
    if @o_error_code<>0
      begin
        print 'Error (masterkey='+cast(@v_masterkey as varchar)+') '+cast(coalesce(@o_error_code,0) as varchar)+' '+coalesce(@o_error_desc,'n/a')
      end

    fetch authors into @v_masterkey
  end
close authors
deallocate authors
