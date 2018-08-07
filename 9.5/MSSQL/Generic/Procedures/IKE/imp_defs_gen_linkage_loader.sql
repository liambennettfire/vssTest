set nocount on
go

/******************************************************************************
**  Name: imp_defs_gen_linkage_loader
**  Desc: IKE generic element linkage of loader rules
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

delete from imp_load_master
  where loadkey >= 100000000000
    and loadkey <= 100099999999
delete from imp_load_elements
  where loadkey >= 100000000000
    and loadkey <= 1000999999990
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100000001001,100000001001,'remove non-numeric characters',13,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100000001001,100013021,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100000001001,100013023,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100000001002,100013023,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100000001003,100013023,'qsi_xt',getdate())
go

--INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
--  VALUES(100000010001,100000010001,'Insert ISBN Prefixes',9999,'qsi_xt',getdate())
--INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
--  VALUES(100000010001,100000010,'qsi_xt',getdate())
--go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100050013001,100050013001,'Insert ISBN Prefixes',9999,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100050013001,100050013,'qsi_xt',getdate())
go


--INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
--  VALUES(100010014001,100010014001,'remove isbn',999,'qsi_xt',getdate())
INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100010015001,100010015001,'onix productkeys',999,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100010015001,100010014,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100010025001,100010025001,'remove isbn',999,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100010025001,100010025,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100010035001,100010035001,'workkey (onix)',30,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100010035001,100010035,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100010035001,100010036,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100010151001,100010151001,'remove isbn',1999,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100010151001,100010151,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100011025001,100011025001,'Orgs from base',999,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100011025001,100011025,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100011026001,100011026001,'Orgs from base altdesc1',1,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100011026001,100011026,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100012033001,100012033001,'ONIX Title info',30,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100012033001,100012033,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100012034001,100012034,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100012035001,100012035,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100012036001,100012036,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100012045001,100012045001,'ONIX measurement translation',30,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100012045001,100012045,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100012045001,100012046,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100012055001,100012055001,'ONIX format concatination',30,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100012055001,100012055,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100012057001,100012057001,'Remove Media element',45,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100012057001,100012057,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100012067001,100012067001,'AudienceRangeQualifier adjust',35,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100012067001,100012067,'qsi_xt',getdate())
go
INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100012067002,100012067002,'AudienceRange -> Age or Grade',95,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100012067002,100012067,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100012167002,100012167002,'XML_Explicit_AudienceRange -> Age or Grade',95,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100012167002,100012167,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100012075001,100012075001,'title break out',30,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100012075001,100012075,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100013009001,100013009001,'UK Retail Final Price break out',30,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100013009001,100013009,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100013010001,100013010001,'US Retail Budget Price break out',30,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100013010001,100013010,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100013012001,100013012001,'UK Retail Final Price break out',30,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100013012001,100013012,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100013013001,100013013001,'UK Retail Budget Price break out',30,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100013013001,100013013,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100013015001,100013015001,'Canadian Retail Final Price break out',30,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100013015001,100013015,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100013016001,100013016001,'Canadian Retail Budget Price break out',30,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100013016001,100013016,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100013018001,100013018001,'Australian Retail Budget Price break out',30,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100013018001,100013018,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100013035001,100013035001,'Euro Retail Final Price break out',30,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100013035001,100013035,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100013041001,100013041001,'US Retail Final Price break out using pricetype from filterpricetype',30,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100013041001,100013041,'qsi_xt',getdate())
go
INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100013042001,100013042001,'Canadian Retail Final Price break out using pricetype from filterpricetype',30,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100013042001,100013042,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100014091001,100014091001,'Territory List',99,'firebrand',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100014091001,100014091,'firebrand',getdate())
go
insert into imp_load_master (loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate) values
		(100014096001,100014096001,'Territories_EXCLUSIVE',99,'fb_imp',getdate())
insert into imp_load_elements (elementkey,loadkey,lastuserid,lastmaintdate) values
		(100014096,100014096001,'fb_imp',getdate())

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100014092001,100014092001,'Territory Template',99,'firebrand',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100014092001,100014092,'firebrand',getdate())
go
INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100026030001,100026030001,'changes corp name to authorlast, adds corp ind',30,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100026030001,100026030,'qsi_xt',getdate())
go

/*does not apply in generic ???*/
INSERT INTO  imp_load_elements(elementkey,loadkey,lastuserid,lastmaintdate)
 VALUES (100012050,100012050001,'qsi_xt',getdate())
INSERT INTO  imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
 VALUES (100012050001,100012050001,'Map Media Description from  Format Descriptions',9999,'qsi_xt',getdate())
go

INSERT INTO  imp_load_elements(elementkey,loadkey,lastuserid,lastmaintdate)
 VALUES (100012016,100012016001,'qsi_xt',getdate())
INSERT INTO  imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
 VALUES (100012016001,100012016001,'Generate Pub Month and Year from Pub Date(best)',1,'qsi_xt',getdate())
go

INSERT INTO  imp_load_elements(elementkey,loadkey,lastuserid,lastmaintdate)
 VALUES (100012027,100012027001,'qsi_xt',getdate())
INSERT INTO  imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
 VALUES (100012027001,100012027001,'Map Media Description from  Format Descriptions',1,'qsi_xt',getdate())
go

INSERT INTO  imp_load_elements(elementkey,loadkey,lastuserid,lastmaintdate)
 VALUES (100012029,100012029001,'qsi_xt',getdate())
INSERT INTO  imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
 VALUES (100012029001,100012029001,'Marcus Loader Rule Test 1',1,'qsi_xt',getdate())
go

INSERT INTO  imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
 VALUES (100040010001,100040010001,'Product Numbers from ProductIdentifier',1,'qsi_xt',getdate())
INSERT INTO  imp_load_elements(elementkey,loadkey,lastuserid,lastmaintdate)
 VALUES (100040010,100040010001,'qsi_xt',getdate())
INSERT INTO  imp_load_elements(elementkey,loadkey,lastuserid,lastmaintdate)
 VALUES (100040011,100040011001,'qsi_xt',getdate())
go

INSERT INTO  imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
 VALUES (100040020001,100040020001,'Discountcode from DiscountCodeType',1,'qsi_xt',getdate())
INSERT INTO  imp_load_elements(elementkey,loadkey,lastuserid,lastmaintdate)
 VALUES (100040020,100040020001,'qsi_xt',getdate())
INSERT INTO  imp_load_elements(elementkey,loadkey,lastuserid,lastmaintdate)
 VALUES (100040021,100040021001,'qsi_xt',getdate())
go

INSERT INTO  imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
 VALUES (100040030001,100040030001,'Bookcomments from OtherText',1,'qsi_xt',getdate())
INSERT INTO  imp_load_elements(elementkey,loadkey,lastuserid,lastmaintdate)
 VALUES (100040030,100040030001,'qsi_xt',getdate())
INSERT INTO  imp_load_elements(elementkey,loadkey,lastuserid,lastmaintdate)
 VALUES (100040031,100040031001,'qsi_xt',getdate())
go

INSERT INTO  imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
 VALUES (100022601001,100022601001,'OtherText comment break out',1,'qsi_xt',getdate())
INSERT INTO  imp_load_elements(elementkey,loadkey,lastuserid,lastmaintdate)
 VALUES (100022601,100022601001,'qsi_xt',getdate())
go

INSERT INTO  imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
 VALUES (100026035001,100026035001,'Parse Author name',1,'qsi_xt',getdate())
INSERT INTO  imp_load_elements(elementkey,loadkey,lastuserid,lastmaintdate)
 VALUES (100026035,100026035001,'qsi_xt',getdate())
go

INSERT INTO  imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
 VALUES (100017011001,100017011001,'Book/BISAC breakout',1,'qsi_xt',getdate())
INSERT INTO  imp_load_elements(elementkey,loadkey,lastuserid,lastmaintdate)
 VALUES (100017011,100017011001,'qsi_xt',getdate())
INSERT INTO  imp_load_elements(elementkey,loadkey,lastuserid,lastmaintdate)
 VALUES (100017012,100017011001,'qsi_xt',getdate())
INSERT INTO  imp_load_elements(elementkey,loadkey,lastuserid,lastmaintdate)
 VALUES (100017013,100017011001,'qsi_xt',getdate())
INSERT INTO  imp_load_elements(elementkey,loadkey,lastuserid,lastmaintdate)
 VALUES (100017014,100017011001,'qsi_xt',getdate())
go

INSERT INTO  imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
 VALUES (100017201001,100017201001,'BIC/BISAC breakout',1,'qsi_xt',getdate())
INSERT INTO  imp_load_elements(elementkey,loadkey,lastuserid,lastmaintdate)
 VALUES (100017201,100017201001,'qsi_xt',getdate())
INSERT INTO  imp_load_elements(elementkey,loadkey,lastuserid,lastmaintdate)
 VALUES (100017202,100017201001,'qsi_xt',getdate())
go 


INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100022751001,100022751001,'concatenate element',99,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100022751001,100022751,'qsi_xt',getdate())


 INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100022300001,100022300001,'Onix bookcomment assignment',30,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100022300001,100022902,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100022300001,100022903,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100022300001,100022904,'qsi_xt',getdate())
go

INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100022310001,100022310001,'Onix bookcomment assignment - type remapped',30,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100022310001,100022911,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100022310001,100022912,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100022310001,100022913,'qsi_xt',getdate())
go

--mk>2012.06.26 Case: 19661 Source of quotes not showing in TMS (IPS)
INSERT INTO imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
  VALUES(100022914001,100022914001,'Onix bookcomment assignment - type remapped',30,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100022914001,100022914,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100022914001,100022916,'qsi_xt',getdate())
INSERT INTO imp_load_elements(loadkey,elementkey,lastuserid,lastmaintdate)
  VALUES(100022914001,100022917,'qsi_xt',getdate())
go

INSERT INTO  imp_load_master(loadkey,rulekey,loaddesc,processorder,lastuserid,lastmaintdate)
 VALUES (100022915001,100022915001,'ONIX text type code breakout',1,'qsi_xt',getdate())
INSERT INTO  imp_load_elements(elementkey,loadkey,lastuserid,lastmaintdate)
 VALUES (100022915,100022915001,'qsi_xt',getdate())
go