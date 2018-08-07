/****** Object:  StoredProcedure [dbo].[lw_batch_assign_product_numbers]    Script Date: 11/17/2015 1:45:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER proc [dbo].[lw_batch_assign_product_numbers] @errordesc varchar(255) OUTPUT
as BEGIN -- stored procedure creation
 
declare @bkey int
declare @debug bit
declare @hasItemNo int
declare @hasUPC int
declare @hasISBN int

create table #assign_item_no ( id int identity, bkey int, itemno varchar(20), done bit, parent bit)
create table #assign_upc ( id int identity, bkey int, upc varchar(50),done bit)
create table #assign_isbn ( id int identity, bkey int, isbn varchar(50),done bit)

select @debug = 0
-- exec lw_batch_assign_product_numbers

/* ****************************************************************************
        Process Item Numbers marked Ready To Assign
**************************************************************************** */
-- find which bookkeys are marked 'Ready to Assign' (415) and Lifeway Item Number (412)
insert into #assign_item_no (bkey)
select bookkey
from bookmisc 
where misckey = 415 and longvalue in (1,2)
    and bookkey in (select bookkey from bookmisc where misckey=412 and longvalue=1)
    and bookkey in (select bookkey from isbn where ISNULL(itemnumber,'') = '')


/* working area    
    select * from bookmiscitems order by misckey desc
    select * from subgentables where tableid = 525 and datacode = 147
    
24031715
24032628
24045726
24046182
24050316
24052160
24054073
24054679

24032628 - parent
24033529 - child
*/

-- find which books already have an ItemNumber assigned
update #assign_item_no 
set itemno=i.itemnumber 
from isbn i where i.bookkey= bkey

-- find which books have children
update #assign_item_no
set parent=1
from associatedtitles where bookkey=bkey and associationtypecode=11

-- assign Item Numbers where the bookkey doesnt have one already 
-- ASSIGN PARENTS FIRST
declare ParentNeedsItemNo CURSOR
    local static forward_only read_only
        for select bkey from #assign_item_no where isnull(itemno,'') = '' and parent=1
open ParentNeedsItemNo
Fetch Next from ParentNeedsItemNo into @bkey
While @@fetch_status <> -1 /* end of cursor */ begin
    if @@fetch_status <> -2 /* row missing */ begin
        exec @hasItemNo = lw_xr_assign_itemnumber @bkey     
        update #assign_item_no set itemno=@hasItemNo where bkey=@bkey
    end -- if @@fetch_status <> -2
    Fetch Next from ParentNeedsItemNo into @bkey
end -- While @@fetch_status <> -1
close ParentNeedsItemNo;
Deallocate ParentNeedsItemNo;

-- assign Item Numbers where the bookkey doesnt have one already 
-- ASSIGN NON-PARENTS LAST
declare NeedsItemNo CURSOR
    local static forward_only read_only
        for select bkey from #assign_item_no where isnull(itemno,'') = '' and isNull(parent,0)=0
open NeedsItemNo
Fetch Next from NeedsItemNo into @bkey
While @@fetch_status <> -1 /* end of cursor */ begin
    if @@fetch_status <> -2 /* row missing */ begin
        exec @hasItemNo = lw_xr_assign_itemnumber @bkey     
        update #assign_item_no set itemno=@hasItemNo where bkey=@bkey
    end -- if @@fetch_status <> -2
    Fetch Next from NeedsItemNo into @bkey
end -- While @@fetch_status <> -1
close NeedsItemNo;
Deallocate NeedsItemNo;

/* ****************************************************************************
        Process UPCs marked Ready To Assign
**************************************************************************** */

insert into #assign_upc (bkey)
select bookkey 
from bookmisc 
where misckey = 415 and longvalue in (1,2)
    and bookkey in (select bookkey from bookmisc where misckey=411 and longvalue=1)    
    and bookkey in (select bookkey from isbn where isnull(upc,'') = '') --added by Ben Todd 2015-11-17 in cases where record does not exist on isbn table - prevent run away assignment of UPC numbers


-- find which books already have an UPC assigned
update #assign_upc 
set upc=i.upc 
from isbn i where i.bookkey= bkey

-- assign UPCs where the bookkey doesnt have one already 
declare NeedUPC CURSOR
    local static forward_only read_only
        for select bkey from #assign_UPC where isnull(upc,'') = ''
open NeedUPC
Fetch Next from NeedUPC into @bkey
While @@fetch_status <> -1 /* end of cursor */ begin
    if @@fetch_status <> -2 /* row missing */ begin
        exec @hasUPC = lw_xr_assign_upc @bkey     
        update #assign_UPC set UPC=convert(varchar(2),@hasUPC) where bkey=@bkey
    end -- if @@fetch_status <> -2
    Fetch Next from NeedUPC into @bkey
end -- While @@fetch_status <> -1

if @debug=1 begin
    select * from #assign_item_no
    --select * from bookmisc where misckey=412 and bookkey in (select bkey from #assign_item_no)
    select * from #assign_upc
    --select * from bookmisc where misckey=411 and bookkey in (select bkey from #assign_upc)
end

/* ****************************************************************************
        Process ISBNs marked Ready To Assign
**************************************************************************** */

insert into #assign_isbn (bkey)
select bookkey 
from bookmisc 
where misckey = 415 and longvalue in (1,2)
    and bookkey in (select bookkey from bookmisc where misckey=410 and longvalue=1)    
    and bookkey in (select bookkey from isbn where isnull(ean13,'') = '') --added by Ben Todd 2015-11-17 in cases where record does not exist on isbn table - prevent run away assignment of EAN numbers



-- find which books already have an UPC assigned
update #assign_isbn 
set isbn=i.isbn 
from isbn i where i.bookkey= bkey

-- assign ISBNs where the bookkey doesnt have one already 
declare NeedISBN CURSOR
    local static forward_only read_only
        for select bkey from #assign_ISBN where isnull(isbn,'') = ''
open NeedISBN
Fetch Next from NeedISBN into @bkey
While @@fetch_status <> -1 /* end of cursor */ begin
    if @@fetch_status <> -2 /* row missing */ begin
        exec @hasISBN = lw_xr_assign_isbn @bkey     
        update #assign_ISBN set ISBN=convert(varchar(2),@hasISBN) where bkey=@bkey
    end -- if @@fetch_status <> -2
    Fetch Next from NeedISBN into @bkey
end -- While @@fetch_status <> -1

if @debug=1 begin
    select * from #assign_item_no
    --select * from bookmisc where misckey=412 and bookkey in (select bkey from #assign_item_no)
    select * from #assign_upc
    --select * from bookmisc where misckey=411 and bookkey in (select bkey from #assign_upc)
    select * from #assign_isbn
    --select * from bookmisc where misckey=410 and bookkey in (select bkey from #assign_upc)
end

/* ****************************************************************************
        Clean Up Status/Flags
**************************************************************************** */

--determine if Ready to Assign flag should be cleared
-- when assignment procs are written for each of the NOT IN clauses below, remove them from this statement
update #assign_item_no set done=1
from bookmisc 
where bkey=bookkey
    and bookkey in (select bookkey from bookmisc where  misckey = 415 and longvalue=1) -- Ready To assign = 1
    --and bookkey not in (select bookkey from bookmisc where  misckey = 410 and longvalue=1) -- ISBN/EAN?
    --and bookkey not in (select bookkey from bookmisc where  misckey = 413 and longvalue=1) -- ISRC?
    --and bookkey not in (select bookkey from bookmisc where  misckey = 414 and longvalue=1) -- ISSN?
    --and bookkey not in (select bookkey from bookmisc where  misckey = 421 and longvalue=1) -- ISRC Video?
    and bookkey  in (select bkey from #assign_item_no where isNull(itemno,'0') <>'0')

    
--determine if Ready to Assign flag should be cleared
-- when assignment procs are written for each of the NOT IN clauses below, remove them from this statement
update #assign_upc set done=1
from bookmisc 
where bkey=bookkey
    and bookkey in (select bookkey from bookmisc where  misckey = 415 and longvalue=1) -- Ready To assign = 1
    --and bookkey not in (select bookkey from bookmisc where  misckey = 410 and longvalue=1) -- ISBN/EAN?
    --and bookkey not in (select bookkey from bookmisc where  misckey = 413 and longvalue=1) -- ISRC?
    --and bookkey not in (select bookkey from bookmisc where  misckey = 414 and longvalue=1) -- ISSN?
    --and bookkey not in (select bookkey from bookmisc where  misckey = 421 and longvalue=1) -- ISRC Video?
    and bookkey  in (select bkey from #assign_upc where isNull(upc,'0')<>'0')

    
update #assign_isbn set done=1
from bookmisc 
where bkey=bookkey
    and bookkey in (select bookkey from bookmisc where  misckey = 415 and longvalue=1) -- Ready To assign = 1
    --and bookkey not in (select bookkey from bookmisc where  misckey = 410 and longvalue=1) -- ISBN/EAN?
    --and bookkey not in (select bookkey from bookmisc where  misckey = 413 and longvalue=1) -- ISRC?
    --and bookkey not in (select bookkey from bookmisc where  misckey = 414 and longvalue=1) -- ISSN?
    --and bookkey not in (select bookkey from bookmisc where  misckey = 421 and longvalue=1) -- ISRC Video?
    and bookkey  in (select bkey from #assign_isbn where isNull(isbn,'0')<>'0')


---- clean up ItemNumber flag if the bookkey has an itemnumber
--update bookmisc set longvalue = null
--from #assign_item_no a
--where misckey=412 and longvalue=1 and bookkey=a.bkey and isNull(a.itemno,'') <>''
---- clean up UPC flag if the bookkey has a upc
--update bookmisc set longvalue = null
--from #assign_upc a
--where misckey=411 and longvalue=1 and bookkey=a.bkey and isNull(a.upc,'') <>''

-- clear "Ready to Assign" flag as that bookkey has had all items processed that it was ready for if marked done    
update bookmisc set longvalue=2 
from #assign_item_no a
where misckey=415 and longvalue=1 and bookkey=a.bkey and a.done=1

update bookmisc set longvalue=2 
from #assign_upc a
where misckey=415 and longvalue=1 and bookkey=a.bkey and a.done=1

if @debug=1 begin
    select * from #assign_item_no
    --select * from bookmisc where misckey=412 and bookkey in (select bkey from #assign_item_no)
    select * from #assign_upc
    --select * from bookmisc where misckey=411 and bookkey in (select bkey from #assign_upc)
    select * from #assign_isbn
    --select * from bookmisc where misckey=410 and bookkey in (select bkey from #assign_upc)
end

drop table #assign_item_no
drop table #assign_upc
drop table #assign_isbn

set @errordesc = ''

end -- begin stored procedure creation