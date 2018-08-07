IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Insert_customer_roles]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Insert_customer_roles]
go

create procedure  [dbo].[qweb_ecf_Insert_customer_roles] (@i_roleid int) as

declare
@i_customerid int,
@i_customerroleid int

DECLARE c_customerid CURSOR FOR 
select customerid 
from customeraccount 
where disabled=1
FOR READ ONLY
BEGIN
open c_customerid
   FETCH NEXT FROM c_customerid into @i_customerid
   WHILE (@@FETCH_STATUS <> -1) BEGIN
     exec CustomerRoleInsert NULL, @i_customerid, @i_roleid
    FETCH NEXT FROM c_customerid into @i_customerid
   END 
close c_customerid
deallocate c_customerid
END



