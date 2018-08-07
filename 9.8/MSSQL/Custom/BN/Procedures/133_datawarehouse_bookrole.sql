PRINT 'STORED PROCEDURE : dbo.datawarehouse_bookrole'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_bookrole') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_bookrole
end

GO
CREATE  proc dbo.datawarehouse_bookrole
@ware_bookkey int, @ware_logkey int, @ware_warehousekey int,
@ware_system_date datetime

AS 

DECLARE @ware_count int
DECLARE @ware_roleline int

DECLARE @ware_displayname  varchar(60) 
DECLARE @ware_firstname  varchar(12) 
DECLARE @ware_lastname varchar(20)  
DECLARE @ware_resourcedesc varchar(255) 
DECLARE @ware_middlename varchar(80) 
DECLARE @ware_shortname varchar(10) 

DECLARE @ware_displayname1  varchar(80)  
DECLARE @ware_firstname1  varchar(80)  
DECLARE @ware_lastname1 varchar(80)  
DECLARE @ware_displayname2  varchar(80)  
DECLARE @ware_firstname2  varchar(80)  
DECLARE @ware_lastname2 varchar(80)  
DECLARE @ware_displayname3  varchar(80)  
DECLARE @ware_firstname3  varchar(80)  
DECLARE @ware_lastname3 varchar(80)  
DECLARE @ware_displayname4  varchar(80)  
DECLARE @ware_firstname4  varchar(80)  
DECLARE @ware_lastname4 varchar(80)  
DECLARE @ware_displayname5  varchar(80)  
DECLARE @ware_firstname5  varchar(80)  
DECLARE @ware_lastname5 varchar(80)  
DECLARE @ware_displayname6  varchar(80)  
DECLARE @ware_firstname6  varchar(80)  
DECLARE @ware_lastname6 varchar(80)  
DECLARE @ware_displayname7  varchar(80)  
DECLARE @ware_firstname7  varchar(80)  
DECLARE @ware_lastname7 varchar(80)  
DECLARE @ware_displayname8  varchar(80)  
DECLARE @ware_firstname8  varchar(80)  
DECLARE @ware_lastname8 varchar(80)  
DECLARE @ware_displayname9  varchar(80)  
DECLARE @ware_firstname9  varchar(80)  
DECLARE @ware_lastname9 varchar(80)  
DECLARE @ware_displayname10  varchar(80)  
DECLARE @ware_firstname10  varchar(80)  
DECLARE @ware_lastname10 varchar(80)  
DECLARE @ware_displayname11  varchar(80)  
DECLARE @ware_firstname11  varchar(80)  
DECLARE @ware_lastname11 varchar(80)  
DECLARE @ware_displayname12  varchar(80)  
DECLARE @ware_firstname12  varchar(80)  
DECLARE @ware_lastname12 varchar(80)  
DECLARE @ware_displayname13  varchar(80)  
DECLARE @ware_firstname13  varchar(80)  
DECLARE @ware_lastname13 varchar(80)  
DECLARE @ware_displayname14  varchar(80)  
DECLARE @ware_firstname14  varchar(80)  
DECLARE @ware_lastname14 varchar(80)  
DECLARE @ware_displayname15  varchar(80)  
DECLARE @ware_firstname15  varchar(80)  
DECLARE @ware_lastname15 varchar(80)  
DECLARE @ware_resourcedesc1 varchar(255) 
DECLARE @ware_middlename1 varchar(80) 
DECLARE @ware_shortname1 varchar(80) 
DECLARE @ware_resourcedesc2 varchar(255) 
DECLARE @ware_middlename2 varchar(80) 
DECLARE @ware_shortname2 varchar(80) 
DECLARE @ware_resourcedesc3 varchar(255) 
DECLARE @ware_middlename3 varchar(80) 
DECLARE @ware_shortname3 varchar(80) 
DECLARE @ware_resourcedesc4 varchar(255) 
DECLARE @ware_middlename4 varchar(80) 
DECLARE @ware_shortname4 varchar(80) 
DECLARE @ware_resourcedesc5 varchar(255) 
DECLARE @ware_middlename5 varchar(80) 
DECLARE @ware_shortname5 varchar(80) 
DECLARE @ware_resourcedesc6 varchar(255) 
DECLARE @ware_middlename6 varchar(80) 
DECLARE @ware_shortname6 varchar(80) 
DECLARE @ware_resourcedesc7 varchar(255) 
DECLARE @ware_middlename7 varchar(80) 
DECLARE @ware_shortname7 varchar(80) 
DECLARE @ware_resourcedesc8 varchar(255) 
DECLARE @ware_middlename8 varchar(80) 
DECLARE @ware_shortname8 varchar(80) 
DECLARE @ware_resourcedesc9 varchar(255) 
DECLARE @ware_middlename9 varchar(80) 
DECLARE @ware_shortname9 varchar(80) 
DECLARE @ware_resourcedesc10 varchar(255) 
DECLARE @ware_middlename10 varchar(80) 
DECLARE @ware_shortname10 varchar(80) 
DECLARE @ware_resourcedesc11 varchar(255) 
DECLARE @ware_middlename11 varchar(80) 
DECLARE @ware_shortname11 varchar(80) 
DECLARE @ware_resourcedesc12 varchar(255) 
DECLARE @ware_middlename12 varchar(80) 
DECLARE @ware_shortname12 varchar(80) 
DECLARE @ware_resourcedesc13 varchar(255) 
DECLARE @ware_middlename13 varchar(80) 
DECLARE @ware_shortname13 varchar(80) 
DECLARE @ware_resourcedesc14 varchar(255) 
DECLARE @ware_middlename14 varchar(80) 
DECLARE @ware_shortname14 varchar(80) 
DECLARE @ware_resourcedesc15 varchar(255) 
DECLARE @ware_middlename15 varchar(80) 
DECLARE @ware_shortname15 varchar(80) 

DECLARE @i_printingkey int
DECLARE @i_roletypecode int
DECLARE @i_depttypecode int
DECLARE @c_resourcedesc varchar(255)
DECLARE @c_displayname varchar(80)
DECLARE @c_firstname varchar(80)
DECLARE @c_lastname varchar(80)
DECLARE @c_middlename varchar(80)
DECLARE @c_shortname varchar(80)

DECLARE @i_rolestatus int

/*7-15-04 CRM 01563 increase columns to 40*/

DECLARE @ware_displayname16  varchar(80)  
DECLARE @ware_firstname16  varchar(80)  
DECLARE @ware_lastname16 varchar(80)  
DECLARE @ware_resourcedesc16 varchar(255) 
DECLARE @ware_middlename16 varchar(80) 
DECLARE @ware_shortname16 varchar(80) 
DECLARE @ware_displayname17  varchar(80)  
DECLARE @ware_firstname17  varchar(80)  
DECLARE @ware_lastname17 varchar(80)  
DECLARE @ware_resourcedesc17 varchar(255) 
DECLARE @ware_middlename17 varchar(80) 
DECLARE @ware_shortname17 varchar(80) 
DECLARE @ware_displayname18  varchar(80)  
DECLARE @ware_firstname18  varchar(80)  
DECLARE @ware_lastname18 varchar(80)  
DECLARE @ware_resourcedesc18 varchar(255) 
DECLARE @ware_middlename18 varchar(80) 
DECLARE @ware_shortname18 varchar(80) 
DECLARE @ware_displayname19  varchar(80)  
DECLARE @ware_firstname19  varchar(80)  
DECLARE @ware_lastname19 varchar(80)  
DECLARE @ware_resourcedesc19 varchar(255) 
DECLARE @ware_middlename19 varchar(80) 
DECLARE @ware_shortname19 varchar(80) 
DECLARE @ware_displayname20  varchar(80)  
DECLARE @ware_firstname20  varchar(80)  
DECLARE @ware_lastname20 varchar(80)  
DECLARE @ware_resourcedesc20 varchar(255) 
DECLARE @ware_middlename20 varchar(80) 
DECLARE @ware_shortname20 varchar(80) 
DECLARE @ware_displayname21  varchar(80)  
DECLARE @ware_firstname21  varchar(80)  
DECLARE @ware_lastname21 varchar(80)  
DECLARE @ware_resourcedesc21 varchar(255) 
DECLARE @ware_middlename21 varchar(80) 
DECLARE @ware_shortname21 varchar(80) 
DECLARE @ware_displayname22  varchar(80)  
DECLARE @ware_firstname22  varchar(80)  
DECLARE @ware_lastname22 varchar(80)  
DECLARE @ware_resourcedesc22 varchar(255) 
DECLARE @ware_middlename22 varchar(80) 
DECLARE @ware_shortname22 varchar(80) 
DECLARE @ware_displayname23  varchar(80)  
DECLARE @ware_firstname23  varchar(80)  
DECLARE @ware_lastname23 varchar(80)  
DECLARE @ware_resourcedesc23 varchar(255) 
DECLARE @ware_middlename23 varchar(80) 
DECLARE @ware_shortname23 varchar(80) 
DECLARE @ware_displayname24  varchar(80)  
DECLARE @ware_firstname24  varchar(80)  
DECLARE @ware_lastname24 varchar(80)  
DECLARE @ware_resourcedesc24 varchar(255) 
DECLARE @ware_middlename24 varchar(80) 
DECLARE @ware_shortname24 varchar(80) 
DECLARE @ware_displayname25  varchar(80)  
DECLARE @ware_firstname25  varchar(80)  
DECLARE @ware_lastname25 varchar(80)  
DECLARE @ware_resourcedesc25 varchar(255) 
DECLARE @ware_middlename25 varchar(80) 
DECLARE @ware_shortname25 varchar(80) 
DECLARE @ware_displayname26  varchar(80)  
DECLARE @ware_firstname26  varchar(80)  
DECLARE @ware_lastname26 varchar(80)  
DECLARE @ware_resourcedesc26 varchar(255) 
DECLARE @ware_middlename26 varchar(80) 
DECLARE @ware_shortname26 varchar(80) 
DECLARE @ware_displayname27  varchar(80)  
DECLARE @ware_firstname27  varchar(80)  
DECLARE @ware_lastname27 varchar(80)  
DECLARE @ware_resourcedesc27 varchar(255) 
DECLARE @ware_middlename27 varchar(80) 
DECLARE @ware_shortname27 varchar(80) 
DECLARE @ware_displayname28  varchar(80)  
DECLARE @ware_firstname28  varchar(80)  
DECLARE @ware_lastname28 varchar(80)  
DECLARE @ware_resourcedesc28 varchar(255) 
DECLARE @ware_middlename28 varchar(80) 
DECLARE @ware_shortname28 varchar(80) 
DECLARE @ware_displayname29  varchar(80)  
DECLARE @ware_firstname29  varchar(80)  
DECLARE @ware_lastname29 varchar(80)  
DECLARE @ware_resourcedesc29 varchar(255) 
DECLARE @ware_middlename29 varchar(80) 
DECLARE @ware_shortname29 varchar(80) 
DECLARE @ware_displayname30  varchar(80)  
DECLARE @ware_firstname30  varchar(80)  
DECLARE @ware_lastname30 varchar(80)  
DECLARE @ware_resourcedesc30 varchar(255) 
DECLARE @ware_middlename30 varchar(80) 
DECLARE @ware_shortname30 varchar(80) 
DECLARE @ware_displayname31  varchar(80)  
DECLARE @ware_firstname31  varchar(80)  
DECLARE @ware_lastname31 varchar(80)  
DECLARE @ware_resourcedesc31 varchar(255) 
DECLARE @ware_middlename31 varchar(80) 
DECLARE @ware_shortname31 varchar(80) 
DECLARE @ware_displayname32  varchar(80)  
DECLARE @ware_firstname32  varchar(80)  
DECLARE @ware_lastname32 varchar(80)  
DECLARE @ware_resourcedesc32 varchar(255) 
DECLARE @ware_middlename32 varchar(80) 
DECLARE @ware_shortname32 varchar(80) 
DECLARE @ware_displayname33  varchar(80)  
DECLARE @ware_firstname33  varchar(80)  
DECLARE @ware_lastname33 varchar(80)  
DECLARE @ware_resourcedesc33 varchar(255) 
DECLARE @ware_middlename33 varchar(80) 
DECLARE @ware_shortname33 varchar(80) 
DECLARE @ware_displayname34  varchar(80)  
DECLARE @ware_firstname34  varchar(80)  
DECLARE @ware_lastname34 varchar(80)  
DECLARE @ware_resourcedesc34 varchar(255) 
DECLARE @ware_middlename34 varchar(80) 
DECLARE @ware_shortname34 varchar(80) 
DECLARE @ware_displayname35  varchar(80)  
DECLARE @ware_firstname35  varchar(80)  
DECLARE @ware_lastname35 varchar(80)  
DECLARE @ware_resourcedesc35 varchar(255) 
DECLARE @ware_middlename35 varchar(80) 
DECLARE @ware_shortname35 varchar(80) 
DECLARE @ware_displayname36  varchar(80)  
DECLARE @ware_firstname36  varchar(80)  
DECLARE @ware_lastname36 varchar(80)  
DECLARE @ware_resourcedesc36 varchar(255) 
DECLARE @ware_middlename36 varchar(80) 
DECLARE @ware_shortname36 varchar(80) 
DECLARE @ware_displayname37  varchar(80)  
DECLARE @ware_firstname37  varchar(80)  
DECLARE @ware_lastname37 varchar(80)  
DECLARE @ware_resourcedesc37 varchar(255) 
DECLARE @ware_middlename37 varchar(80) 
DECLARE @ware_shortname37 varchar(80) 
DECLARE @ware_displayname38  varchar(80)  
DECLARE @ware_firstname38  varchar(80)  
DECLARE @ware_lastname38 varchar(80)  
DECLARE @ware_resourcedesc38 varchar(255) 
DECLARE @ware_middlename38 varchar(80) 
DECLARE @ware_shortname38 varchar(80) 
DECLARE @ware_displayname39  varchar(80)  
DECLARE @ware_firstname39  varchar(80)  
DECLARE @ware_lastname39 varchar(80)  
DECLARE @ware_resourcedesc39 varchar(255) 
DECLARE @ware_middlename39 varchar(80) 
DECLARE @ware_shortname39 varchar(80) 
DECLARE @ware_displayname40  varchar(80)  
DECLARE @ware_firstname40  varchar(80)  
DECLARE @ware_lastname40 varchar(80)  
DECLARE @ware_resourcedesc40 varchar(255) 
DECLARE @ware_middlename40 varchar(80) 
DECLARE @ware_shortname40 varchar(80) 
DECLARE @ware_printingkey int

DECLARE warehouseroleprinting INSENSITIVE CURSOR FOR
  SELECT distinct b.printingkey
    FROM bookcontributor b, person p
    WHERE  b.contributorkey= p.contributorkey
      AND b.bookkey = @ware_bookkey
    order by b.printingkey
    FOR READ ONLY

select @ware_count = 1
OPEN warehouseroleprinting

FETCH NEXT FROM warehouseroleprinting
  into @ware_printingkey

while (@@FETCH_STATUS = 0) 
  begin

select @ware_displayname1 = NULL
select @ware_firstname1 = NULL
select @ware_lastname1 = NULL
select @ware_displayname2 = NULL
select @ware_firstname2 = NULL
select @ware_lastname2 = NULL
select @ware_displayname3 = NULL
select @ware_firstname3 = NULL
select @ware_lastname3 = NULL
select @ware_displayname4 = NULL
select @ware_firstname4 = NULL
select @ware_lastname4 = NULL
select @ware_displayname5 = NULL
select @ware_firstname5 = NULL
select @ware_lastname5 = NULL
select @ware_displayname6 = NULL
select @ware_firstname6 = NULL
select @ware_lastname6 = NULL
select @ware_displayname7 = NULL
select @ware_firstname7 = NULL
select @ware_lastname7 = NULL
select @ware_displayname8 = NULL
select @ware_firstname8 = NULL
select @ware_lastname8 = NULL
select @ware_displayname9 = NULL
select @ware_firstname9 = NULL
select @ware_lastname9 = NULL
select @ware_displayname10 = NULL
select @ware_firstname10 = NULL
select @ware_lastname10 = NULL
select @ware_displayname11 = NULL
select @ware_firstname11 = NULL
select @ware_lastname11 = NULL
select @ware_displayname12 = NULL
select @ware_firstname12 = NULL
select @ware_lastname12 = NULL
select @ware_displayname13 = NULL
select @ware_firstname13 = NULL
select @ware_lastname13 = NULL
select @ware_displayname14 = NULL
select @ware_firstname14 = NULL
select @ware_lastname14 = NULL
select @ware_displayname15 = NULL
select @ware_firstname15 = NULL
select @ware_lastname15 = NULL
select @ware_resourcedesc1 = NULL
select @ware_middlename1 = NULL
select @ware_shortname1 = NULL
select @ware_resourcedesc2 = NULL
select @ware_middlename2 = NULL
select @ware_shortname2 = NULL
select @ware_resourcedesc3 = NULL
select @ware_middlename3 = NULL
select @ware_shortname3 = NULL
select @ware_resourcedesc4 = NULL
select @ware_middlename4 = NULL
select @ware_shortname4 = NULL
select @ware_resourcedesc5 = NULL
select @ware_middlename5 = NULL
select @ware_shortname5 = NULL
select @ware_resourcedesc6 = NULL
select @ware_middlename6 = NULL
select @ware_shortname6 = NULL
select @ware_resourcedesc7 = NULL
select @ware_middlename7 = NULL
select @ware_shortname7 = NULL
select @ware_resourcedesc8 = NULL
select @ware_middlename8 = NULL
select @ware_shortname8 = NULL
select @ware_resourcedesc9 = NULL
select @ware_middlename9 = NULL
select @ware_shortname9 = NULL
select @ware_resourcedesc10 = NULL
select @ware_middlename10 = NULL
select @ware_shortname10 = NULL
select @ware_resourcedesc11 = NULL
select @ware_middlename11 = NULL
select @ware_shortname11 = NULL
select @ware_resourcedesc12 = NULL
select @ware_middlename12 = NULL
select @ware_shortname12 = NULL
select @ware_resourcedesc13 = NULL
select @ware_middlename13 = NULL
select @ware_shortname13 = NULL
select @ware_resourcedesc14 = NULL
select @ware_middlename14 = NULL
select @ware_shortname14 = NULL
select @ware_resourcedesc15 = NULL
select @ware_middlename15 = NULL
select @ware_shortname15 = NULL
select @ware_displayname16 = NULL
select @ware_firstname16 = NULL
select @ware_lastname16 = NULL
select @ware_resourcedesc16 = NULL
select @ware_middlename16 = NULL
select @ware_shortname16 = NULL
select @ware_displayname17 = NULL
select @ware_firstname17 = NULL
select @ware_lastname17 = NULL
select @ware_resourcedesc17 = NULL
select @ware_middlename17 = NULL
select @ware_shortname17 = NULL
select @ware_displayname18 = NULL
select @ware_firstname18 = NULL
select @ware_lastname18 = NULL
select @ware_resourcedesc18 = NULL
select @ware_middlename18 = NULL
select @ware_shortname18 = NULL
select @ware_displayname19 = NULL
select @ware_firstname19 = NULL
select @ware_lastname19 = NULL
select @ware_resourcedesc19 = NULL
select @ware_middlename19 = NULL
select @ware_shortname19 = NULL
select @ware_displayname20 = NULL
select @ware_firstname20 = NULL
select @ware_lastname20 = NULL
select @ware_resourcedesc20 = NULL
select @ware_middlename20 = NULL
select @ware_shortname20 = NULL
select @ware_displayname21 = NULL
select @ware_firstname21 = NULL
select @ware_lastname21 = NULL
select @ware_resourcedesc21 = NULL
select @ware_middlename21 = NULL
select @ware_shortname21 = NULL
select @ware_displayname22 = NULL
select @ware_firstname22 = NULL
select @ware_lastname22 = NULL
select @ware_resourcedesc22 = NULL
select @ware_middlename22 = NULL
select @ware_shortname22 = NULL
select @ware_displayname23 = NULL
select @ware_firstname23 = NULL
select @ware_lastname23 = NULL
select @ware_resourcedesc23 = NULL
select @ware_middlename23 = NULL
select @ware_shortname23 = NULL
select @ware_displayname24 = NULL
select @ware_firstname24 = NULL
select @ware_lastname24 = NULL
select @ware_resourcedesc24 = NULL
select @ware_middlename24 = NULL
select @ware_shortname24 = NULL
select @ware_displayname25 = NULL
select @ware_firstname25 = NULL
select @ware_lastname25 = NULL
select @ware_resourcedesc25 = NULL
select @ware_middlename25 = NULL
select @ware_shortname25 = NULL
select @ware_displayname26 = NULL
select @ware_firstname26 = NULL
select @ware_lastname26 = NULL
select @ware_resourcedesc26 = NULL
select @ware_middlename26 = NULL
select @ware_shortname26 = NULL
select @ware_displayname27 = NULL
select @ware_firstname27 = NULL
select @ware_lastname27 = NULL
select @ware_resourcedesc27 = NULL
select @ware_middlename27 = NULL
select @ware_shortname27 = NULL
select @ware_displayname28 = NULL
select @ware_firstname28 = NULL
select @ware_lastname28 = NULL
select @ware_resourcedesc28 = NULL
select @ware_middlename28 = NULL
select @ware_shortname28 = NULL
select @ware_displayname29 = NULL
select @ware_firstname29 = NULL
select @ware_lastname29 = NULL
select @ware_resourcedesc29 = NULL
select @ware_middlename29 = NULL
select @ware_shortname29 = NULL
select @ware_displayname30 = NULL
select @ware_firstname30 = NULL
select @ware_lastname30 = NULL
select @ware_resourcedesc30 = NULL
select @ware_middlename30 = NULL
select @ware_shortname30 = NULL
select @ware_displayname31 = NULL
select @ware_firstname31 = NULL
select @ware_lastname31 = NULL
select @ware_resourcedesc31 = NULL
select @ware_middlename31 = NULL
select @ware_shortname31 = NULL
select @ware_displayname32 = NULL
select @ware_firstname32 = NULL
select @ware_lastname32 = NULL
select @ware_resourcedesc32 = NULL
select @ware_middlename32 = NULL
select @ware_shortname32 = NULL
select @ware_displayname33 = NULL
select @ware_firstname33 = NULL
select @ware_lastname33 = NULL
select @ware_resourcedesc33 = NULL
select @ware_middlename33 = NULL
select @ware_shortname33 = NULL
select @ware_displayname34 = NULL
select @ware_firstname34 = NULL
select @ware_lastname34 = NULL
select @ware_resourcedesc34 = NULL
select @ware_middlename34 = NULL
select @ware_shortname34 = NULL
select @ware_displayname35 = NULL
select @ware_firstname35 = NULL
select @ware_lastname35 = NULL
select @ware_resourcedesc35 = NULL
select @ware_middlename35 = NULL
select @ware_shortname35 = NULL
select @ware_displayname36 = NULL
select @ware_firstname36 = NULL
select @ware_lastname36 = NULL
select @ware_resourcedesc36 = NULL
select @ware_middlename36 = NULL
select @ware_shortname36 = NULL
select @ware_displayname37 = NULL
select @ware_firstname37 = NULL
select @ware_lastname37 = NULL
select @ware_resourcedesc37 = NULL
select @ware_middlename37 = NULL
select @ware_shortname37 = NULL
select @ware_displayname38 = NULL
select @ware_firstname38 = NULL
select @ware_lastname38 = NULL
select @ware_resourcedesc38 = NULL
select @ware_middlename38 = NULL
select @ware_shortname38 = NULL
select @ware_displayname39 = NULL
select @ware_firstname39 = NULL
select @ware_lastname39 = NULL
select @ware_resourcedesc39 = NULL
select @ware_middlename39 = NULL
select @ware_shortname39 = NULL
select @ware_displayname40 = NULL
select @ware_firstname40 = NULL
select @ware_lastname40 = NULL
select @ware_resourcedesc40 = NULL
select @ware_middlename40 = NULL
select @ware_shortname40 = NULL
          
    DECLARE warehouserole INSENSITIVE CURSOR FOR
      SELECT b.roletypecode,b.depttypecode,resourcedesc,displayname,firstname,lastname, middlename,shortname
        FROM bookcontributor b, person p
        WHERE  b.contributorkey= p.contributorkey
          AND b.bookkey = @ware_bookkey
          AND b.printingkey = @ware_printingkey
        FOR READ ONLY
    OPEN warehouserole
    FETCH NEXT FROM warehouserole
      INTO @i_roletypecode,@i_depttypecode,@c_resourcedesc,@c_displayname,@c_firstname,@c_lastname,@c_middlename,@c_shortname

    select @i_rolestatus = @@FETCH_STATUS
    while (@i_rolestatus<>-1 )
      begin
                       
        IF (@i_rolestatus<>-2)
          begin
            select @ware_count = 0
            select @ware_count = count(*)
              from whcroletype
              where roletypecode = @i_roletypecode
                              
            if @ware_count > 0 
              begin
                select @ware_roleline = linenumber
                  from whcroletype
                  where roletypecode = @i_roletypecode
                            
                if @ware_roleline > 0 
                  begin
                    select @ware_displayname = substring(rtrim(@c_displayname),1,60)
                    select @ware_firstname = substring(rtrim(@c_firstname),1,12)
                    select @ware_lastname = substring(rtrim(@c_lastname),1,20)
                    select @ware_middlename = @c_middlename
                    select @ware_resourcedesc = @c_resourcedesc
                    select @ware_shortname = @c_shortname
                    if @ware_roleline = 1 
                      begin
                        select @ware_displayname1 = @ware_displayname
                        select @ware_firstname1  = @ware_firstname
                        select @ware_lastname1 = @ware_lastname
                        select @ware_middlename1 = @ware_middlename
                        select @ware_resourcedesc1 = @ware_resourcedesc
                        select @ware_shortname1 = @ware_shortname
                      end
                    if @ware_roleline = 2 
                      begin
                        select @ware_displayname2 = @ware_displayname
                        select @ware_firstname2  = @ware_firstname
                        select @ware_lastname2 = @ware_lastname
                        select @ware_middlename2 = @ware_middlename
                        select @ware_resourcedesc2 = @ware_resourcedesc
                        select @ware_shortname2 = @ware_shortname
                      end
                    if @ware_roleline = 3 
                      begin
                        select @ware_displayname3 = @ware_displayname  
                        select @ware_firstname3  = @ware_firstname
                        select @ware_lastname3 = @ware_lastname
                        select @ware_middlename3 = @ware_middlename
                        select @ware_resourcedesc3 = @ware_resourcedesc
                        select @ware_shortname3 = @ware_shortname
                      end
                    if @ware_roleline = 4 
                      begin
                        select @ware_displayname4 = @ware_displayname
                        select @ware_firstname4  = @ware_firstname
                        select @ware_lastname4 = @ware_lastname
                        select @ware_middlename4 = @ware_middlename
                        select @ware_resourcedesc4 = @ware_resourcedesc
                        select @ware_shortname4 = @ware_shortname
                      end
                    if @ware_roleline = 5
                      begin
                        select @ware_displayname5 = @ware_displayname
                        select @ware_firstname5  = @ware_firstname
                        select @ware_lastname5 = @ware_lastname
                        select @ware_middlename5 = @ware_middlename
                        select @ware_resourcedesc5 = @ware_resourcedesc
                        select @ware_shortname5 = @ware_shortname
                      end
                    if @ware_roleline = 6 
                      begin
                        select @ware_displayname6 = @ware_displayname
                        select @ware_firstname6  = @ware_firstname
                        select @ware_lastname6 = @ware_lastname
                        select @ware_middlename6 = @ware_middlename
                        select @ware_resourcedesc6 = @ware_resourcedesc
                        select @ware_shortname6 = @ware_shortname
                      end
                    if @ware_roleline = 7 
                      begin
                        select @ware_displayname7 = @ware_displayname
                        select @ware_firstname7  = @ware_firstname
                        select @ware_lastname7 = @ware_lastname
                        select @ware_middlename7 = @ware_middlename
                        select @ware_resourcedesc7 = @ware_resourcedesc
                        select  @ware_shortname7 = @ware_shortname
                      end
                    if @ware_roleline = 8 
                      begin    
                        select @ware_displayname8 = @ware_displayname
                        select @ware_firstname8  = @ware_firstname
                        select @ware_lastname8 = @ware_lastname
                        select @ware_middlename8 = @ware_middlename
                        select @ware_resourcedesc8 = @ware_resourcedesc
                        select @ware_shortname8 = @ware_shortname
                      end
                    if @ware_roleline = 9 
                      begin
                        select @ware_displayname9 = @ware_displayname
                        select @ware_firstname9  = @ware_firstname
                        select @ware_lastname9 = @ware_lastname
                        select @ware_middlename9 = @ware_middlename
                        select @ware_resourcedesc9 = @ware_resourcedesc
                        select @ware_shortname9 = @ware_shortname
                      end
                    if @ware_roleline = 10 
                      begin
                        select @ware_displayname10 = @ware_displayname
                        select @ware_firstname10  = @ware_firstname
                        select @ware_lastname10 = @ware_lastname
                        select @ware_middlename10 = @ware_middlename
                        select @ware_resourcedesc10 = @ware_resourcedesc
                        select @ware_shortname10 = @ware_shortname
                      end
                    if @ware_roleline = 11 
                      begin
                        select @ware_displayname11 = @ware_displayname
                        select @ware_firstname11  = @ware_firstname
                        select @ware_lastname11 = @ware_lastname
                        select @ware_middlename11 = @ware_middlename
                        select @ware_resourcedesc11 = @ware_resourcedesc
                        select @ware_shortname11 = @ware_shortname
                      end
                    if @ware_roleline = 12   
                      begin
                        select @ware_displayname12 = @ware_displayname
                        select @ware_firstname12  = @ware_firstname
                        select @ware_lastname12 = @ware_lastname
                        select @ware_middlename12 = @ware_middlename
                        select @ware_resourcedesc12 = @ware_resourcedesc
                        select @ware_shortname12 = @ware_shortname
                      end
                    if @ware_roleline = 13 
                      begin
                        select @ware_displayname13 = @ware_displayname
                        select @ware_firstname13  = @ware_firstname
                        select @ware_lastname13 = @ware_lastname
                        select @ware_middlename13 = @ware_middlename
                        select @ware_resourcedesc13 = @ware_resourcedesc
                        select @ware_shortname13 = @ware_shortname
                      end
                    if @ware_roleline = 14   
                      begin
                        select @ware_displayname14 = @ware_displayname
                        select @ware_firstname14  = @ware_firstname
                        select @ware_lastname14 = @ware_lastname
                        select @ware_middlename14 = @ware_middlename
                        select @ware_resourcedesc14 = @ware_resourcedesc
                        select @ware_shortname14 = @ware_shortname
                      end
                    if @ware_roleline = 15 
                      begin
                        select @ware_displayname15 = @ware_displayname
                        select @ware_firstname15  = @ware_firstname
                        select @ware_lastname15 = @ware_lastname
                        select @ware_middlename15 = @ware_middlename
                        select @ware_resourcedesc15 = @ware_resourcedesc
                        select @ware_shortname15 = @ware_shortname
                      end
                    if @ware_roleline = 16
                      begin
                        select @ware_displayname16 = @ware_displayname
                        select @ware_firstname16  = @ware_firstname
                        select @ware_lastname16 = @ware_lastname
                        select @ware_middlename16 = @ware_middlename
                        select @ware_resourcedesc16 = @ware_resourcedesc
                        select @ware_shortname16 = @ware_shortname
                      end
                    if @ware_roleline = 17   
                      begin
                        select @ware_displayname17 = @ware_displayname
                        select @ware_firstname17  = @ware_firstname
                        select @ware_lastname17 = @ware_lastname
                        select @ware_middlename17 = @ware_middlename
                        select @ware_resourcedesc17 = @ware_resourcedesc
                        select @ware_shortname17 = @ware_shortname
                      end
                    if @ware_roleline = 18 
                      begin
                        select @ware_displayname18 = @ware_displayname
                        select @ware_firstname18  = @ware_firstname
                        select @ware_lastname18 = @ware_lastname
                        select @ware_middlename18 = @ware_middlename
                        select @ware_resourcedesc18 = @ware_resourcedesc
                        select @ware_shortname18 = @ware_shortname
                      end
                    if @ware_roleline = 19   
                      begin
                        select @ware_displayname19 = @ware_displayname
                        select @ware_firstname19  = @ware_firstname
                        select @ware_lastname19 = @ware_lastname
                        select @ware_middlename19 = @ware_middlename
                        select @ware_resourcedesc19 = @ware_resourcedesc
                        select @ware_shortname19 = @ware_shortname
                      end
                    if @ware_roleline = 20 
                      begin
                        select @ware_displayname20 = @ware_displayname
                        select @ware_firstname20  = @ware_firstname
                        select @ware_lastname20 = @ware_lastname
                        select @ware_middlename20 = @ware_middlename
                        select @ware_resourcedesc20 = @ware_resourcedesc
                        select @ware_shortname20 = @ware_shortname
                      end
                    if @ware_roleline = 21 
                      begin
                        select @ware_displayname21 = @ware_displayname
                        select @ware_firstname21  = @ware_firstname
                        select @ware_lastname21 = @ware_lastname
                        select @ware_middlename21 = @ware_middlename
                        select @ware_resourcedesc21 = @ware_resourcedesc
                        select @ware_shortname21 = @ware_shortname
                      end
                    if @ware_roleline = 22 
                      begin
                        select @ware_displayname22 = @ware_displayname
                        select @ware_firstname22  = @ware_firstname
                        select @ware_lastname22 = @ware_lastname
                        select @ware_middlename22 = @ware_middlename
                        select @ware_resourcedesc22 = @ware_resourcedesc
                        select @ware_shortname22 = @ware_shortname
                      end
                    if @ware_roleline = 23 
                      begin
                        select @ware_displayname23 = @ware_displayname  
                        select @ware_firstname23  = @ware_firstname
                        select @ware_lastname23 = @ware_lastname
                        select @ware_middlename23 = @ware_middlename
                        select @ware_resourcedesc23 = @ware_resourcedesc
                        select @ware_shortname23 = @ware_shortname
                      end
                    if @ware_roleline = 24 
                      begin
                        select @ware_displayname24 = @ware_displayname
                        select @ware_firstname24  = @ware_firstname
                        select @ware_lastname24 = @ware_lastname
                        select @ware_middlename24 = @ware_middlename
                        select @ware_resourcedesc24 = @ware_resourcedesc
                        select @ware_shortname24 = @ware_shortname
                      end
                    if @ware_roleline = 25
                       begin
                       select @ware_displayname25 = @ware_displayname
                        select @ware_firstname25  = @ware_firstname
                        select @ware_lastname25 = @ware_lastname
                        select @ware_middlename25 = @ware_middlename
                        select @ware_resourcedesc25 = @ware_resourcedesc
                        select @ware_shortname25 = @ware_shortname
                      end
                    if @ware_roleline = 26 
                      begin
                        select @ware_displayname26 = @ware_displayname
                        select @ware_firstname26  = @ware_firstname
                        select @ware_lastname26 = @ware_lastname
                        select @ware_middlename26 = @ware_middlename
                        select @ware_resourcedesc26 = @ware_resourcedesc
                        select @ware_shortname26 = @ware_shortname
                      end
                    if @ware_roleline = 27 
                      begin
                        select @ware_displayname27 = @ware_displayname
                        select @ware_firstname27  = @ware_firstname
                        select @ware_lastname27 = @ware_lastname
                        select @ware_middlename27 = @ware_middlename
                        select @ware_resourcedesc27 = @ware_resourcedesc
                        select  @ware_shortname27 = @ware_shortname
                      end
                    if @ware_roleline = 28 
                      begin    
                        select @ware_displayname28 = @ware_displayname
                        select @ware_firstname28  = @ware_firstname
                        select @ware_lastname28 = @ware_lastname
                        select @ware_middlename28 = @ware_middlename
                        select @ware_resourcedesc28 = @ware_resourcedesc
                        select @ware_shortname28 = @ware_shortname
                      end
                    if @ware_roleline = 29 
                      begin
                        select @ware_displayname29 = @ware_displayname
                        select @ware_firstname29  = @ware_firstname
                        select @ware_lastname29 = @ware_lastname
                        select @ware_middlename29 = @ware_middlename
                        select @ware_resourcedesc29 = @ware_resourcedesc
                        select @ware_shortname29 = @ware_shortname
                      end
                    if @ware_roleline = 30 
                      begin
                        select @ware_displayname30 = @ware_displayname
                        select @ware_firstname30  = @ware_firstname
                        select @ware_lastname30 = @ware_lastname
                        select @ware_middlename30 = @ware_middlename
                        select @ware_resourcedesc30 = @ware_resourcedesc
                        select @ware_shortname30 = @ware_shortname
                      end
                    if @ware_roleline = 31 
                      begin
                        select @ware_displayname31 = @ware_displayname
                        select @ware_firstname31  = @ware_firstname
                        select @ware_lastname31 = @ware_lastname
                        select @ware_middlename31 = @ware_middlename
                        select @ware_resourcedesc31 = @ware_resourcedesc
                        select @ware_shortname31 = @ware_shortname
                      end
                    if @ware_roleline = 32   
                      begin
                        select @ware_displayname32 = @ware_displayname
                        select @ware_firstname32  = @ware_firstname
                        select @ware_lastname32 = @ware_lastname
                        select @ware_middlename32 = @ware_middlename
                        select @ware_resourcedesc32 = @ware_resourcedesc
                        select @ware_shortname32 = @ware_shortname
                      end
                    if @ware_roleline = 33 
                      begin
                        select @ware_displayname33 = @ware_displayname
                        select @ware_firstname33  = @ware_firstname
                        select @ware_lastname33 = @ware_lastname
                        select @ware_middlename33 = @ware_middlename
                        select @ware_resourcedesc33 = @ware_resourcedesc
                        select @ware_shortname33 = @ware_shortname
                      end
                    if @ware_roleline = 34   
                      begin
                        select @ware_displayname34 = @ware_displayname
                        select @ware_firstname34  = @ware_firstname
                        select @ware_lastname34 = @ware_lastname
                        select @ware_middlename34 = @ware_middlename
                        select @ware_resourcedesc34 = @ware_resourcedesc
                        select @ware_shortname34 = @ware_shortname
                      end
                    if @ware_roleline = 35 
                      begin
                        select @ware_displayname35 = @ware_displayname
                        select @ware_firstname35  = @ware_firstname
                        select @ware_lastname35 = @ware_lastname
                        select @ware_middlename35 = @ware_middlename
                        select @ware_resourcedesc35 = @ware_resourcedesc
                        select @ware_shortname35 = @ware_shortname
                      end
                    if @ware_roleline = 36
                      begin
                        select @ware_displayname36 = @ware_displayname
                        select @ware_firstname36  = @ware_firstname
                        select @ware_lastname36 = @ware_lastname
                        select @ware_middlename36 = @ware_middlename
                        select @ware_resourcedesc36 = @ware_resourcedesc
                        select @ware_shortname36 = @ware_shortname
                      end
                    if @ware_roleline = 37   
                      begin
                        select @ware_displayname37 = @ware_displayname
                        select @ware_firstname37  = @ware_firstname
                        select @ware_lastname37 = @ware_lastname
                        select @ware_middlename37 = @ware_middlename
                        select @ware_resourcedesc37 = @ware_resourcedesc
                        select @ware_shortname37 = @ware_shortname
                      end
                    if @ware_roleline = 38 
                      begin
                        select @ware_displayname38 = @ware_displayname
                        select @ware_firstname38  = @ware_firstname
                        select @ware_lastname38 = @ware_lastname
                        select @ware_middlename38 = @ware_middlename
                        select @ware_resourcedesc38 = @ware_resourcedesc
                        select @ware_shortname38 = @ware_shortname
                      end
                    if @ware_roleline = 39   
                      begin
                        select @ware_displayname39 = @ware_displayname
                        select @ware_firstname39  = @ware_firstname
                        select @ware_lastname39 = @ware_lastname
                        select @ware_middlename39 = @ware_middlename
                        select @ware_resourcedesc39 = @ware_resourcedesc
                        select @ware_shortname39 = @ware_shortname
                      end
                    if @ware_roleline = 40 
                      begin
                        select @ware_displayname40 = @ware_displayname
                        select @ware_firstname40  = @ware_firstname
                        select @ware_lastname40 = @ware_lastname
                        select @ware_middlename40 = @ware_middlename
                        select @ware_resourcedesc40 = @ware_resourcedesc
                        select @ware_shortname40 = @ware_shortname
                      end
                  end   /*@ware_roleline > 0*/
              end  /*@ware_count > 0 */       
          end /*@i_rolestatus<>-2*/
                               
          FETCH NEXT FROM warehouserole 
            INTO @i_roletypecode,@i_depttypecode,@c_resourcedesc,@c_displayname,@c_firstname,@c_lastname,@c_middlename,@c_shortname
                    
          select @i_rolestatus = @@FETCH_STATUS
                 
      end  /*@i_rolestatus<>-1*/
                     
    close warehouserole
    deallocate warehouserole
                 
    BEGIN tran
                      
    INSERT INTO  whprintingpersonnel
      (bookkey,printingkey,
      displayname1,firstname1,lastname1,displayname2,firstname2,
      lastname2,displayname3,firstname3,lastname3 ,displayname4,
      firstname4,lastname4,displayname5,firstname5,lastname5,displayname6,
      firstname6,lastname6,displayname7,firstname7,lastname7 ,displayname8,
      firstname8,lastname8,displayname9,firstname9,lastname9,displayname10,
      firstname10,lastname10,displayname11,firstname11,lastname11,displayname12,
      firstname12,lastname12,displayname13,firstname13,lastname13,displayname14,
      firstname14,lastname14,displayname15,firstname15,lastname15,
      resourcedesc1,middlename1,shortname1,resourcedesc2,middlename2,shortname2,
      resourcedesc3,middlename3,shortname3,resourcedesc4,
      middlename4,shortname4,resourcedesc5,middlename5,shortname5,resourcedesc6,
      middlename6,shortname6,resourcedesc7,middlename7,shortname7,resourcedesc8,
      middlename8,shortname8,resourcedesc9,middlename9,shortname9,resourcedesc10,
      middlename10,shortname10,resourcedesc11,middlename11,shortname11,resourcedesc12,
      middlename12,shortname12,resourcedesc13,middlename13,shortname13,resourcedesc14,
      middlename14,shortname14,resourcedesc15,middlename15,shortname15,
      lastuserid,lastmaintdate,displayname16,firstname16,lastname16,resourcedesc16,
      middlename16,shortname16,displayname17,firstname17,lastname17,resourcedesc17,
      middlename17,shortname17,displayname18,firstname18,lastname18,resourcedesc18,
      middlename18,shortname18,displayname19,firstname19,lastname19,resourcedesc19,
      middlename19,shortname19,displayname20,firstname20,lastname20,resourcedesc20,
      middlename20,shortname20,displayname21,firstname21,lastname21,resourcedesc21,
      middlename21,shortname21,displayname22,firstname22,lastname22,resourcedesc22,
      middlename22,shortname22,displayname23,firstname23,lastname23,resourcedesc23,
      middlename23,shortname23,displayname24,firstname24,lastname24,resourcedesc24,
      middlename24,shortname24,displayname25,firstname25,lastname25,resourcedesc25,
      middlename25,shortname25,displayname26,firstname26,lastname26,resourcedesc26,
      middlename26,shortname26,displayname27,firstname27,lastname27,resourcedesc27,
      middlename27,shortname27,displayname28,firstname28,lastname28,resourcedesc28,
      middlename28,shortname28,displayname29,firstname29,lastname29,resourcedesc29,
      middlename29,shortname29,displayname30,firstname30,lastname30,resourcedesc30,
      middlename30,shortname30,displayname31,firstname31,lastname31,resourcedesc31,
      middlename31,shortname31,displayname32,firstname32,lastname32,resourcedesc32,
      middlename32,shortname32,displayname33,firstname33,lastname33,resourcedesc33,
      middlename33,shortname33,displayname34,firstname34,lastname34,resourcedesc34,
      middlename34,shortname34,displayname35,firstname35,lastname35,resourcedesc35,
      middlename35,shortname35,displayname36,firstname36,lastname36,resourcedesc36,
      middlename36,shortname36,displayname37,firstname37,lastname37,resourcedesc37,
      middlename37,shortname37,displayname38,firstname38,lastname38,resourcedesc38,
      middlename38,shortname38,displayname39,firstname39,lastname39,resourcedesc39,
      middlename39,shortname39,displayname40,firstname40,lastname40,resourcedesc40,
      middlename40,shortname40)
    VALUES 
       (@ware_bookkey,@ware_printingkey,
        @ware_displayname1,@ware_firstname1,@ware_lastname1,
        @ware_displayname2,@ware_firstname2,@ware_lastname2,@ware_displayname3,
        @ware_firstname3,@ware_lastname3 ,@ware_displayname4,@ware_firstname4,
        @ware_lastname4,@ware_displayname5,@ware_firstname5,@ware_lastname5,
        @ware_displayname6,@ware_firstname6,@ware_lastname6,@ware_displayname7,
        @ware_firstname7,@ware_lastname7 ,@ware_displayname8,@ware_firstname8,
        @ware_lastname8,@ware_displayname9,@ware_firstname9,@ware_lastname9,
        @ware_displayname10,@ware_firstname10,@ware_lastname10,@ware_displayname11,
        @ware_firstname11,@ware_lastname11,@ware_displayname12,@ware_firstname12,
        @ware_lastname12,@ware_displayname13,@ware_firstname13,@ware_lastname13,
        @ware_displayname14,@ware_firstname14,@ware_lastname14,@ware_displayname15,
        @ware_firstname15,@ware_lastname15,
        @ware_resourcedesc1,@ware_middlename1,@ware_shortname1,
        @ware_resourcedesc2,@ware_middlename2,@ware_shortname2,@ware_resourcedesc3,
        @ware_middlename3,@ware_shortname3,@ware_resourcedesc4,@ware_middlename4,
        @ware_shortname4,@ware_resourcedesc5,@ware_middlename5,@ware_shortname5,
        @ware_resourcedesc6,@ware_middlename6,@ware_shortname6,@ware_resourcedesc7,
        @ware_middlename7,@ware_shortname7,@ware_resourcedesc8,@ware_middlename8,
        @ware_shortname8,@ware_resourcedesc9,@ware_middlename9,@ware_shortname9,
        @ware_resourcedesc10,@ware_middlename10,@ware_shortname10,@ware_resourcedesc11,
        @ware_middlename11,@ware_shortname11,@ware_resourcedesc12,@ware_middlename12,
        @ware_shortname12,@ware_resourcedesc13,@ware_middlename13,@ware_shortname13,
        @ware_resourcedesc14,@ware_middlename14,@ware_shortname14,@ware_resourcedesc15,
        @ware_middlename15,@ware_shortname15,'WARE_STORED_PROC',@ware_system_date,
        @ware_displayname16,@ware_firstname16,@ware_lastname16,@ware_resourcedesc16,
        @ware_middlename16,@ware_shortname16,@ware_displayname17,@ware_firstname17,
        @ware_lastname17,@ware_resourcedesc17,@ware_middlename17,@ware_shortname17,
        @ware_displayname18,@ware_firstname18,@ware_lastname18,@ware_resourcedesc18,
        @ware_middlename18,@ware_shortname18,@ware_displayname19,@ware_firstname19,
        @ware_lastname19,@ware_resourcedesc19,@ware_middlename19,@ware_shortname19,
        @ware_displayname20,@ware_firstname20,@ware_lastname20,@ware_resourcedesc20,
        @ware_middlename20,@ware_shortname20,@ware_displayname21,@ware_firstname21,
        @ware_lastname21,@ware_resourcedesc21,@ware_middlename21,@ware_shortname21,
        @ware_displayname22,@ware_firstname22,@ware_lastname22,@ware_resourcedesc22,
        @ware_middlename22,@ware_shortname22,@ware_displayname23,@ware_firstname23,
        @ware_lastname23,@ware_resourcedesc23,@ware_middlename23,@ware_shortname23,
        @ware_displayname24,@ware_firstname24,@ware_lastname24,@ware_resourcedesc24,
        @ware_middlename24,@ware_shortname24,@ware_displayname25,@ware_firstname25,
        @ware_lastname25,@ware_resourcedesc25,@ware_middlename25,@ware_shortname25,
        @ware_displayname26,@ware_firstname26,@ware_lastname26,@ware_resourcedesc26,
        @ware_middlename26,@ware_shortname26,@ware_displayname27,@ware_firstname27,
        @ware_lastname27,@ware_resourcedesc27,@ware_middlename27,@ware_shortname27,
        @ware_displayname28,@ware_firstname28,@ware_lastname28,@ware_resourcedesc28,
        @ware_middlename28,@ware_shortname28,@ware_displayname29,@ware_firstname29,
        @ware_lastname29,@ware_resourcedesc29,@ware_middlename29,@ware_shortname29,
        @ware_displayname30,@ware_firstname30,@ware_lastname30,@ware_resourcedesc30,
        @ware_middlename30,@ware_shortname30,@ware_displayname31,@ware_firstname31,
        @ware_lastname31,@ware_resourcedesc31,@ware_middlename31,@ware_shortname31,
        @ware_displayname32,@ware_firstname32,@ware_lastname32,@ware_resourcedesc32,
        @ware_middlename32,@ware_shortname32,@ware_displayname33,@ware_firstname33,
        @ware_lastname33,@ware_resourcedesc33,@ware_middlename33,@ware_shortname33,
        @ware_displayname34,@ware_firstname34,@ware_lastname34,@ware_resourcedesc34,
        @ware_middlename34,@ware_shortname34,@ware_displayname35,@ware_firstname35,
        @ware_lastname35,@ware_resourcedesc35,@ware_middlename35,@ware_shortname35,
        @ware_displayname36,@ware_firstname36,@ware_lastname36,@ware_resourcedesc36,
        @ware_middlename36,@ware_shortname36,@ware_displayname37,@ware_firstname37,
        @ware_lastname37,@ware_resourcedesc37,@ware_middlename37,@ware_shortname37,
        @ware_displayname38,@ware_firstname38,@ware_lastname38,@ware_resourcedesc38,
        @ware_middlename38,@ware_shortname38,@ware_displayname39,@ware_firstname39,
        @ware_lastname39,@ware_resourcedesc39,@ware_middlename39,@ware_shortname39,
        @ware_displayname40,@ware_firstname40,@ware_lastname40,@ware_resourcedesc40,
        @ware_middlename40,@ware_shortname40)
                    
    if @ware_printingkey = 1
      begin
        INSERT INTO  whtitlepersonnel
          (bookkey,
          displayname1,firstname1,lastname1,displayname2,firstname2,
          lastname2,displayname3,firstname3,lastname3 ,displayname4,
          firstname4,lastname4,displayname5,firstname5,lastname5,displayname6,
          firstname6,lastname6,displayname7,firstname7,lastname7 ,displayname8,
          firstname8,lastname8,displayname9,firstname9,lastname9,displayname10,
          firstname10,lastname10,displayname11,firstname11,lastname11,displayname12,
          firstname12,lastname12,displayname13,firstname13,lastname13,displayname14,
          firstname14,lastname14,displayname15,firstname15,lastname15,
          resourcedesc1,middlename1,shortname1,resourcedesc2,middlename2,shortname2,
          resourcedesc3,middlename3,shortname3,resourcedesc4,
          middlename4,shortname4,resourcedesc5,middlename5,shortname5,resourcedesc6,
          middlename6,shortname6,resourcedesc7,middlename7,shortname7,resourcedesc8,
          middlename8,shortname8,resourcedesc9,middlename9,shortname9,resourcedesc10,
          middlename10,shortname10,resourcedesc11,middlename11,shortname11,resourcedesc12,
          middlename12,shortname12,resourcedesc13,middlename13,shortname13,resourcedesc14,
          middlename14,shortname14,resourcedesc15,middlename15,shortname15,
          lastuserid,lastmaintdate,displayname16,firstname16,lastname16,resourcedesc16,
          middlename16,shortname16,displayname17,firstname17,lastname17,resourcedesc17,
          middlename17,shortname17,displayname18,firstname18,lastname18,resourcedesc18,
          middlename18,shortname18,displayname19,firstname19,lastname19,resourcedesc19,
          middlename19,shortname19,displayname20,firstname20,lastname20,resourcedesc20,
          middlename20,shortname20,displayname21,firstname21,lastname21,resourcedesc21,
          middlename21,shortname21,displayname22,firstname22,lastname22,resourcedesc22,
          middlename22,shortname22,displayname23,firstname23,lastname23,resourcedesc23,
          middlename23,shortname23,displayname24,firstname24,lastname24,resourcedesc24,
          middlename24,shortname24,displayname25,firstname25,lastname25,resourcedesc25,
          middlename25,shortname25,displayname26,firstname26,lastname26,resourcedesc26,
          middlename26,shortname26,displayname27,firstname27,lastname27,resourcedesc27,
          middlename27,shortname27,displayname28,firstname28,lastname28,resourcedesc28,
          middlename28,shortname28,displayname29,firstname29,lastname29,resourcedesc29,
          middlename29,shortname29,displayname30,firstname30,lastname30,resourcedesc30,
          middlename30,shortname30,displayname31,firstname31,lastname31,resourcedesc31,
          middlename31,shortname31,displayname32,firstname32,lastname32,resourcedesc32,
          middlename32,shortname32,displayname33,firstname33,lastname33,resourcedesc33,
          middlename33,shortname33,displayname34,firstname34,lastname34,resourcedesc34,
          middlename34,shortname34,displayname35,firstname35,lastname35,resourcedesc35,
          middlename35,shortname35,displayname36,firstname36,lastname36,resourcedesc36,
          middlename36,shortname36,displayname37,firstname37,lastname37,resourcedesc37,
          middlename37,shortname37,displayname38,firstname38,lastname38,resourcedesc38,
          middlename38,shortname38,displayname39,firstname39,lastname39,resourcedesc39,
          middlename39,shortname39,displayname40,firstname40,lastname40,resourcedesc40,
          middlename40,shortname40)
        VALUES 
           (@ware_bookkey,
            @ware_displayname1,@ware_firstname1,@ware_lastname1,
            @ware_displayname2,@ware_firstname2,@ware_lastname2,@ware_displayname3,
            @ware_firstname3,@ware_lastname3 ,@ware_displayname4,@ware_firstname4,
            @ware_lastname4,@ware_displayname5,@ware_firstname5,@ware_lastname5,
            @ware_displayname6,@ware_firstname6,@ware_lastname6,@ware_displayname7,
            @ware_firstname7,@ware_lastname7 ,@ware_displayname8,@ware_firstname8,
            @ware_lastname8,@ware_displayname9,@ware_firstname9,@ware_lastname9,
            @ware_displayname10,@ware_firstname10,@ware_lastname10,@ware_displayname11,
            @ware_firstname11,@ware_lastname11,@ware_displayname12,@ware_firstname12,
            @ware_lastname12,@ware_displayname13,@ware_firstname13,@ware_lastname13,
            @ware_displayname14,@ware_firstname14,@ware_lastname14,@ware_displayname15,
            @ware_firstname15,@ware_lastname15,
            @ware_resourcedesc1,@ware_middlename1,@ware_shortname1,
            @ware_resourcedesc2,@ware_middlename2,@ware_shortname2,@ware_resourcedesc3,
            @ware_middlename3,@ware_shortname3,@ware_resourcedesc4,@ware_middlename4,
            @ware_shortname4,@ware_resourcedesc5,@ware_middlename5,@ware_shortname5,
            @ware_resourcedesc6,@ware_middlename6,@ware_shortname6,@ware_resourcedesc7,
            @ware_middlename7,@ware_shortname7,@ware_resourcedesc8,@ware_middlename8,
            @ware_shortname8,@ware_resourcedesc9,@ware_middlename9,@ware_shortname9,
            @ware_resourcedesc10,@ware_middlename10,@ware_shortname10,@ware_resourcedesc11,
            @ware_middlename11,@ware_shortname11,@ware_resourcedesc12,@ware_middlename12,
            @ware_shortname12,@ware_resourcedesc13,@ware_middlename13,@ware_shortname13,
            @ware_resourcedesc14,@ware_middlename14,@ware_shortname14,@ware_resourcedesc15,
            @ware_middlename15,@ware_shortname15,'WARE_STORED_PROC',@ware_system_date,
            @ware_displayname16,@ware_firstname16,@ware_lastname16,@ware_resourcedesc16,
            @ware_middlename16,@ware_shortname16,@ware_displayname17,@ware_firstname17,
            @ware_lastname17,@ware_resourcedesc17,@ware_middlename17,@ware_shortname17,
            @ware_displayname18,@ware_firstname18,@ware_lastname18,@ware_resourcedesc18,
            @ware_middlename18,@ware_shortname18,@ware_displayname19,@ware_firstname19,
            @ware_lastname19,@ware_resourcedesc19,@ware_middlename19,@ware_shortname19,
            @ware_displayname20,@ware_firstname20,@ware_lastname20,@ware_resourcedesc20,
            @ware_middlename20,@ware_shortname20,@ware_displayname21,@ware_firstname21,
            @ware_lastname21,@ware_resourcedesc21,@ware_middlename21,@ware_shortname21,
            @ware_displayname22,@ware_firstname22,@ware_lastname22,@ware_resourcedesc22,
            @ware_middlename22,@ware_shortname22,@ware_displayname23,@ware_firstname23,
            @ware_lastname23,@ware_resourcedesc23,@ware_middlename23,@ware_shortname23,
            @ware_displayname24,@ware_firstname24,@ware_lastname24,@ware_resourcedesc24,
            @ware_middlename24,@ware_shortname24,@ware_displayname25,@ware_firstname25,
            @ware_lastname25,@ware_resourcedesc25,@ware_middlename25,@ware_shortname25,
            @ware_displayname26,@ware_firstname26,@ware_lastname26,@ware_resourcedesc26,
            @ware_middlename26,@ware_shortname26,@ware_displayname27,@ware_firstname27,
            @ware_lastname27,@ware_resourcedesc27,@ware_middlename27,@ware_shortname27,
            @ware_displayname28,@ware_firstname28,@ware_lastname28,@ware_resourcedesc28,
            @ware_middlename28,@ware_shortname28,@ware_displayname29,@ware_firstname29,
            @ware_lastname29,@ware_resourcedesc29,@ware_middlename29,@ware_shortname29,
            @ware_displayname30,@ware_firstname30,@ware_lastname30,@ware_resourcedesc30,
            @ware_middlename30,@ware_shortname30,@ware_displayname31,@ware_firstname31,
            @ware_lastname31,@ware_resourcedesc31,@ware_middlename31,@ware_shortname31,
            @ware_displayname32,@ware_firstname32,@ware_lastname32,@ware_resourcedesc32,
            @ware_middlename32,@ware_shortname32,@ware_displayname33,@ware_firstname33,
            @ware_lastname33,@ware_resourcedesc33,@ware_middlename33,@ware_shortname33,
            @ware_displayname34,@ware_firstname34,@ware_lastname34,@ware_resourcedesc34,
            @ware_middlename34,@ware_shortname34,@ware_displayname35,@ware_firstname35,
            @ware_lastname35,@ware_resourcedesc35,@ware_middlename35,@ware_shortname35,
            @ware_displayname36,@ware_firstname36,@ware_lastname36,@ware_resourcedesc36,
            @ware_middlename36,@ware_shortname36,@ware_displayname37,@ware_firstname37,
            @ware_lastname37,@ware_resourcedesc37,@ware_middlename37,@ware_shortname37,
            @ware_displayname38,@ware_firstname38,@ware_lastname38,@ware_resourcedesc38,
            @ware_middlename38,@ware_shortname38,@ware_displayname39,@ware_firstname39,
            @ware_lastname39,@ware_resourcedesc39,@ware_middlename39,@ware_shortname39,
            @ware_displayname40,@ware_firstname40,@ware_lastname40,@ware_resourcedesc40,
            @ware_middlename40,@ware_shortname40)
      end

    if @@ERROR <> 0
      begin
        INSERT INTO wherrorlog (logkey, warehousekey,errordesc,errorseverity, errorfunction,lastuserid, lastmaintdate)
        VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_warehousekey),
          'Unable to insert whtitlepersonnel table - for book contributor',
          ('Warning/data error bookkey ' + convert(varchar,@ware_bookkey)),  
          'Stored procedure datawarehouse_role','WARE_STORED_PROC', @ware_system_date)
      end
                  
    commit tran
    
    FETCH  FROM warehouseroleprinting into @ware_printingkey
               
  end  /* printings loop*/
            
close warehouseroleprinting
deallocate warehouseroleprinting

GO