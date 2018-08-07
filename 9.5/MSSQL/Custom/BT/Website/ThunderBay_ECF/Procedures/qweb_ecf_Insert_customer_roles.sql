USE [BT_TB_ECF]
GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_Insert_customer_roles]    Script Date: 01/27/2010 16:49:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure  [dbo].[qweb_ecf_Insert_customer_roles] (@i_roleid int) as

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





