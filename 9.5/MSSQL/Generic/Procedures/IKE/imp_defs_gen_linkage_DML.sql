set nocount on
go

/******************************************************************************
**  Name: imp_defs_gen_linkage_DML
**  Desc: IKE generic element linkage of DML rules
**  Auth: Bennett
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  5/24/2016    Kusum       Case 36771 BICSubjectCategories (tableid = 668)
*******************************************************************************/

/*****************************************/
/** DML rule linkage                    **/
/*****************************************/
delete from imp_dml_master
  where DMLkey >= 300000000000
    and DMLkey <= 300099999999
delete from imp_dml_elements
  where DMLkey >= 300000000000
    and DMLkey <= 300099999999
go

/* isbn etc  */
insert into imp_dml_master (DMLkey,rulekey,tablename,processorder,lastuserid,lastmaintdate)
  values (300010000001,300010001001,'isbn',30,'init setup',getdate())
insert into imp_dml_elements (DMLkey,elementkey,lastuserid,lastmaintdate)
  values (300010000001,100010001,'init setup',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300010000001,100010000,'xt',getdate())
GO

--  verify rule and use
--INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
--  VALUES (300010001001,'isbn',300010000001,1,'qsi_xt',getdate())
--INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
--  VALUES (300010001001,100010001,'qsi_xt',getdate())
--GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
   VALUES(300010002001,'isbn',300010002001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
   VALUES(300010002001,100010002,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
   VALUES(300010002001,100010003,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
   VALUES(300010007001,'isbn',300010007001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
   VALUES(300010007001,100010007,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
   VALUES(300010004001,'isbn',300010004001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
   VALUES(300010004001,100010004,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300010006001 ,'isbn',300010006001 ,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300010006001 ,100010006,'qsi_xt',getdate())
go

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
   VALUES(300010008001,'isbn',300010001001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
   VALUES(300010008001,100010008,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
   VALUES(300010009001,'isbn',300010002001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
   VALUES(300010009001,100010009,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
   VALUES(300010010001,'isbn',300010002001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
   VALUES(300010010001,100010010,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
   VALUES(300010019001,'Related Products',300010019001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
   VALUES(300010019001,100010019,'qsi_xt',getdate())
GO

-- dup???
--INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
--   VALUES(300010010001,'isbn',300010002001,30,'qsi_xt',getdate())
--INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
--   VALUES(300010010001,100010021,'qsi_xt',getdate())
--GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
   VALUES(300010021001,'isbn',300010021001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
   VALUES(300010021001,100010021,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
   VALUES(300010022001,'isbn',300010022001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
   VALUES(300010022001,100010022,'qsi_xt',getdate())
GO

/*DML - Generic associated title removal*/
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300010024001, 'associatedtitles', 300010024001,921,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300010024001,  100010024,'qsi_xt',getdate())
GO

/*DML - Generic associated title*/
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300010026001, 'associatedtitles', 300010026001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300010026001,  100010026,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300010027001, 'associatedtitles', 300010026001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300010027001,  100010027,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300010028001, 'associatedtitles', 300010026001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300010028001,  100010028,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300010029001, 'associatedtitles', 300010026001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300010029001,  100010029,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300010031001, 'associatedtitles', 300010026001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300010031001,  100010031,'qsi_xt',getdate())
GO

/*DML - Generic associated title pubdate*/
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300010126001, 'associatedtitles', 300010126001,121,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300010126001,  100010126,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300010127001, 'associatedtitles', 300010126001,121,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300010127001,  100010127,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300010128001, 'associatedtitles', 300010126001,121,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300010128001,  100010128,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300010129001, 'associatedtitles', 300010126001,121,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300010129001,  100010129,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300010131001, 'associatedtitles', 300010126001,121,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300010131001,  100010131,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
   VALUES(300010030001,'book',300010030001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
   VALUES(300010030001,100010030,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
   VALUES(300010033001,'book',300010033001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
   VALUES(300010033001,100010032,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
   VALUES(300010033001,100010033,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
   VALUES(300010041001,'book',300010041001,-1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
   VALUES(300010041001,100010041,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
   VALUES(300010046001,'book',300010046001,-2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
   VALUES(300010046001,100010046,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master (DMLkey, tablename, rulekey, processorder, lastuserid, lastmaintdate)
VALUES (300011021001, 'bookorgentry', 300011021001, 30, 'qsi_xt', getdate())
GO
INSERT INTO imp_dml_elements (DMLkey, elementkey, lastuserid, lastmaintdate)
VALUES (300011021001, 100011021, 'qsi_xt', getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
   VALUES(300011135001,'isbn',300011135001,999,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
   VALUES(300011135001,100011135,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
   VALUES (300012000001,'multiples',300012000001,0,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
   VALUES(300012000001,100012000,'qsi_xt',getdate())
GO


INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012001001,'printing',300012001001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012001001,100012001,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012003001,'bookdetail',300012003001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012003001,100012003,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012004001,'bindingspecs',300012004001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012004001,100012004,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012006001,'bookdetail',300012006001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012006001,100012006,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012007001,'bookdetail',300012007001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012007001,100012007,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012008001,'printing',300012008001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012008001,100012008,'qsi_xt',getdate())
GO


INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012019001,'printing',300012020001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012019001,100012019,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012020001,'printing',300012020001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012020001,100012020,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012021001,'printing',300012021001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012021001,100012021,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012008002,'printing',300012008001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012008002,100012009,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012013001,100012013,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012013001,'printing',300012013001,1,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012017001,100012017,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012017001,'printing',300012017001,1,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012018001,100012018,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012018001,'printing',300012018001,1,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012016001,'printing',300012016001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012016001,100020005,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012018003,100020006,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012022001,'printing',300012022001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012022001,100012022,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012023001,'multiple',300012023001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012023001,100012023,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012024001,'book',300012024001,12024,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012024001,100012024,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012025001,'printing',300012025001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012025001,100012025,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012026001,'book',300012026001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012026001,100012026,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012027001,'book',300012027001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012027001,100012027,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012029001,'book',300012029001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012029001,100012029,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012028001,'book',300012028001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012028001,100012028,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012030001,'printing',300012030001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012030001,100012030,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012032001,'printing',300012032001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012032001,100012032,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012037001,'printing',300012037001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012037001,100012037,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012041001,'pagecount est',300012041001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012041001,100012041,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012038001,'printing',300012037001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012038001,100012038,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012043001,'printing',300012043001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012043001,100012043,'qsi_xt',getdate())
GO

--INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
--  VALUES (300012044001,'printing',300012044001,1,'qsi_xt',getdate())
--INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
--  VALUES(300012044001,100012044,'qsi_xt',getdate())
--GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012048001,'printing',300012048001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012048001,100012048,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012049001,'printing',300012049001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012049001,100012049,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012050001,100012050,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012050001,'bookdetail',300012050001,1,'qsi_xt',getdate())
GO

delete from imp_dml_elements where DMLkey=310012050001
delete from imp_dml_master where DMLkey=310012050001
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(310012050001,110012050,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (310012050001,'bookdetail',310012050001,1,'qsi_xt',getdate())
GO


INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012052001,'printing',300012001001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012052001,100012052,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012053001,100012053,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012053001,'booksimon',300012053001,30,'qsi_xt',getdate())
GO


INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012058001,'printing',300012058001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012058001,100012058,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012059001,'printing',300012059001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012059001,100012059,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012060001,'printing',300012060001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012060001,100012060,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012061001,'booksimon',300012061001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012061001,100012061,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012062001,'booksimon',300012062001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012062001,100012062,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012063001,'bookdetail',300012063001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012063001,100012063,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012064001,'bookdetail',300012064001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012064001,100012064,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012065001,'bookdetail',300012065001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012065001,100012065,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012066001,'bookdetail',300012066001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012066001,100012066,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012077001,'bookdetail',300012077001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012077001,100012077,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012070001,'bookdetail',300012070001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012070001,100012070,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012071001,'bookdetail',300012071001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012071001,100012071,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012072001,'bookdetail',300012072001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012072001,100012072,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012073001,'bookdetail',300012073001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012073001,100012073,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012074001,'bookdetail',300012074001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012074001,100012074,'qsi_xt',getdate())
GO


INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012075001,'bookdetail',300012075001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012075001,100012070,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012076001,'bookdetail',300012076001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012076001,100012076,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012080001,'casespecs',300012080001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012080001,100012080,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012085001,'printing',300012085001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012085001,100012085,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012090001,'printing',300012090001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300012090001,100012090,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300012091001,'printing',300012091001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012091001,100012091,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300012091001,100012092,'qsi_xt',getdate())
GO

/*  PRICES	*/

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300013023001,'bookprice',300013023001,13001,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300013023001,100013021,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300013023001,100013022,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300013023001,100013023,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300013023001,100013024,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300013023001,100013025,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300013023001,100013026,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300013023001,100013027,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300013023001,100013028,'qsi_xt',getdate())
/*
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300013000001,'bookprice',300013000001,13001,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300013000001,100013022,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300013000001,100013023,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300013000001,100013024,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300013000001,100013026,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300013000001,100013028,'qsi_xt',getdate())
*/
--INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
--  VALUES (300013011001,'bookprice',300013011001,13011,'qsi_xt',getdate())
--INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
--  VALUES (300013011001,100013011,'qsi_xt',getdate())





INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300013051001,'bookprice',300013051001,1000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013051001,100013051,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300013051002,'bookprice',300013051001,1000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013051002,100013052,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300013051003,'bookprice',300013051001,1000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013051003,100013053,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300013051004,'bookprice',300013051001,1000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013051004,100013054,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300013051005,'bookprice',300013051001,1000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013051005,100013055,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300013051006,'bookprice',300013051001,1000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013051006,100013056,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300013051007,'bookprice',300013051001,1000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013051007,100013057,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300013051008,'bookprice',300013051001,1000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013051008,100013058,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300013051009,'bookprice',300013051001,1000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013051009,100013059,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300013051010,'bookprice',300013051001,1000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013051010,100013060,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300013051011,'bookprice',300013051001,1000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013051011,100013061,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300013051012,'bookprice',300013051001,1000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013051012,100013062,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300013051013,'bookprice',300013051001,1000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013051013,100013063,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300013051014,'bookprice',300013051001,1000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013051014,100013064,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300013051015,'bookprice',300013051001,1000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013051015,100013065,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300013051016,'bookprice',300013051001,1000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013051016,100013066,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300013051017,'bookprice',300013051001,1000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013051017,100013067,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300013051018,'bookprice',300013051001,1000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013051018,100013068,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300013051019,'bookprice',300013051001,1000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013051019,100013069,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300013051020,'bookprice',300013051001,1000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013051020,100013070,'qsi_xt',getdate())
go






INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014041001,'audiocassettespecs',300014041001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014041001,100014041,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014042001,'audiocassettespecs',300014042001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014042001,100014042,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014046001,'book',300014046001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014046001,100014046,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014049001,'bookdetail',300014049001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014049001,100014049,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014050002,'bookdetail',300014050002,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014050002,100014050,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014051002,'bookdetail',300014051002,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014051002,100014051,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014052001,'bookdetail',300014052001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300014052001,100014052,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014053001,'bookdetail',300014053001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300014053001,100014053,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014054001,'bookdetail',300014054001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300014054001,100014054,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014055001,'bookdetail',300014055001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014055001,100014055,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014056002,'bookdetail',300014056002,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014056002,100014056,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014057002,'bookdetail',300014057002,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014057002,100014057,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014058002,'book',300014058002,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014058002,100014058,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014059001,'book',300014059001,70,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014059001,100014059,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014061001,'bookdetail',300000000002,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014061001,100014061,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014061002,'bookdetail',300014051002,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014061002,100014061,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014062001,'bookdetail',300000000002,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014062001,100014062,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014062002,'bookdetail',300014052001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014062002,100014062,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014065001,'bookdetail',300000000002,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014065001,100014065,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014065002,'bookdetail',300014055001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014065002,100014065,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014066001,'bookdetail',300014066001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014066001,100014066,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014067001,'bookdetail',300014067001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014067001,100014067,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014067002,'bookdetail',300014067002,9999,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014067002,100014055,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014067002,100014065,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014067002,100014066,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300014067002,100014067,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014070001,'bookdetail',300014070001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300014070001,100014070,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014071001,'bookdetail',300014071001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300014071001,100014071,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014072001,'book',300014072001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300014072001,100014072,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014073001,'bookdetail',300014073001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300014073001,100014073,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300014081001,'bookverification',300014081001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300014081001,100014081,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
   VALUES(300014082001,'INSERTVerificationStatusDML',300014082001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
   VALUES(300014082001,100014082,'qsi_xt',getdate())
GO

insert into imp_dml_master (DMLkey,rulekey,tablename,processorder,lastuserid,lastmaintdate)
  values (300014091001,300014091001,'isbn',30,'init setup',getdate())
delete imp_dml_elements where DMLkey=300014091001
insert into imp_dml_elements (DMLkey,elementkey,lastuserid,lastmaintdate)
  values (300014091001,100014091,'init setup',getdate())
insert into imp_dml_elements (DMLkey,elementkey,lastuserid,lastmaintdate)
  values (300014091001,100014092,'init setup',getdate())
GO
insert into imp_DML_master (dmlkey,rulekey,tablename,processorder,lastuserid,lastmaintdate) values
		(300014096001,300014096001,'territoryrights',30,'fb_imp',getdate())
insert into imp_DML_elements (dmlkey,elementkey,lastuserid,lastmaintdate) values
		(300014096001,100014096,'fb_imp',getdate())


INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300016001001,'bookaudience',300016001001,16000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300016001001,100016001,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300016002001,'bookaudience (remove)',300016002001,190,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300016002001,100016002,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300016101001,'bookaudience',300016101001,50,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300016101001,100016101,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300017001001,'bookbisacsubject',300017001001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300017001001,100017001,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300017000001,'bookbisacsubject',300017000001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300017000001,100017000,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001003,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001004,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001005,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001006,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001007,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001008,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001009,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001010,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001011,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001012,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001013,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001014,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001015,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001016,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001017,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001018,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001019,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001020,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001021,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001022,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001023,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES (300018001024,'booksubjectcategory',300018001002,30,'qsi_xt',getdate())

INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300018001003,100018001,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300018001004,100018002,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300018001005,100018003,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300018001006,100018004,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300018001007,100018005,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300018001008,100018006,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300018001009,100018007,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300018001010,100018008,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300018001011,100018009,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300018001012,100018010,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300018001013,100018011,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300018001014,100018012,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300018001015,100018013,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300018001016,100018014,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300018001017,100018015,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300018001018,100018016,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300018001019,100018017,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300018001020,100018018,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300018001021,100018019,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300018001022,100018020,'qsi_xt',getdate())
go

-- Case 36771 BICSubjectCategories
INSERT INTO imp_DML_elements (DMLkey,elementkey,lastuserid,lastmaintdate)VALUES(300018001023,100018021,'qsi_xt',getdate())
INSERT INTO imp_DML_elements (DMLkey,elementkey,lastuserid,lastmaintdate)VALUES(300018001024,100018022,'qsi_xt',getdate())
go

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300018101001,'booksubjectcategory',300018101001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300018101001,100018101,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020001001,'bookdates',300020001001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020001001,100020001,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020001002,'bookdates',300020001001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020001002,100020002,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020001003,'bookdates',300020001001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020001003,100020003,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020001004,'bookdates',300020001001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020001004,100020004,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020001005,'bookdates',300020001001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020001005,100020005,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020001006,'bookdates',300020001001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020001006,100020006,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020001007,'bookdates',300020001001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020001007,100020007,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020001008,'bookdates',300020001001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020001008,100020008,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020001009,'bookdates',300020001001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020001009,100020009,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020001010,'bookdates',300020001001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020001010,100020010,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020001011,'bookdates',300020001001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020001011,100020011,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020001012,'bookdates',300020001001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020001012,100020012,'qsi_xt',getdate())


INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020001013,'bookdates',300020001001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020001013,100020013,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020001014,'bookdates',300020001001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020001014,100020014,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020001015,'bookdates',300020001001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020001015,100020015,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020001016,'bookdates',300020001001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020001016,100020016,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020001017,'bookdates',300020001001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020001017,100020017,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020001018,'bookdates',300020001001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020001018,100020018,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020001019,'bookdates',300020001001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020001019,100020019,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020101001,'bookdates',300020101001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020101001,100020101,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020102001,'bookdates',300020101001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020102001,100020102,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020103001,'bookdates',300020101001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020103001,100020103,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020104001,'bookdates',300020101001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020104001,100020104,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020105001,'bookdates',300020101001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020105001,100020105,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020106001,'bookdates',300020101001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020106001,100020106,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020107001,'bookdates',300020101001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020107001,100020107,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020108001,'bookdates',300020101001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020108001,100020108,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020109001,'bookdates',300020101001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020109001,100020109,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020110001,'bookdates',300020101001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020110001,100020110,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020111001,'bookdates',300020101001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020111001,100020111,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020112001,'bookdates',300020101001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020112001,100020112,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020113001,'bookdates',300020101001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020113001,100020113,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020114001,'bookdates',300020101001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020114001,100020114,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020115001,'bookdates',300020101001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020115001,100020115,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020116001,'bookdates',300020101001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020116001,100020116,'qsi_xt',getdate())
go

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300020201001,'bookdates',300020201001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020201001,100020201,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020201001,100020202,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020201001,100020203,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020201001,100020204,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300020201001,100020205,'qsi_xt',getdate())
go

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300022013001 ,'bookcomments', 300022000001 ,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300022013001 ,100022013,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300013004002,'bookprice',300013004002,62,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300013004002,100013004,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021002002,'bookcustom',300021002002,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300021002002,100021004,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021021001,'bookcustom',300021021001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300021021001,100021021,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021022001,'bookcustom',300021022001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300021022001,100021022,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021023001,'bookcustom',300021023001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300021023001,100021023,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021024001,'bookcustom',300021024001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300021024001,100021024,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021025001,'bookcustom',300021025001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300021025001,100021025,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021026001,'bookcustom',300021026001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300021026001,100021026,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021027001,'bookcustom',300021027001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300021027001,100021027,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021028001,'bookcustom',300021028001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300021028001,100021028,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021031001,'bookcustom',300021031001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300021031001,100021031,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021032001,'bookcustom',300021032001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300021032001,100021032,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021033001,'bookcustom',300021033001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300021033001,100021033,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300021034001,100021034,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021034001,'bookcustom',300021034001,2,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021035001,'bookcustom',300021035001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300021035001,100021035,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021036001,'bookcustom',300021036001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300021036001,100021036,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021037001,'bookcustom',300021037001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300021037001,100021037,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021041001,'bookcustom',300021041001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300021041001,100021041,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021042001,'bookcustom',300021042001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300021042001,100021042,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021043001,'bookcustom',300021043001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300021043001,100021043,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021044001,'bookcustom',300021044001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300021044001,100021044,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021045001,'bookcustom',300021045001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300021045001,100021045,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021046001,'bookcustom',300021046001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300021046001,100021046,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300021047001,'bookcustom',300021047001,2,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300021047001,100021047,'qsi_xt',getdate())
GO

/*  BC 100022001 100022009  */
--Author Bio Comments
insert into imp_dml_master  (DMLkey,rulekey,tablename,processorder,lastuserid,lastmaintdate)
  values  (300022001001,300022000001,'bookcomments',30,'init setup',getdate())
insert into imp_dml_elements  (DMLkey,elementkey,lastuserid,lastmaintdate)
  values  (300022001001,100022001,'init setup',getdate())
GO

--Brief Description
insert into imp_dml_master (DMLkey,rulekey,tablename,processorder,lastuserid,lastmaintdate)
  values (300022002001,300022000001,'bookcomments',30,'init setup',getdate())
insert into imp_dml_elements (DMLkey,elementkey,lastuserid,lastmaintdate)
  values (300022002001,100022002,'init setup',getdate())
GO

--Catalog Body Copy
insert into imp_dml_master (DMLkey,rulekey,tablename,processorder,lastuserid,lastmaintdate)
  values (300022003001,300022000001,'bookcomments',30,'init setup',getdate())
insert into imp_dml_elements (DMLkey,elementkey,lastuserid,lastmaintdate)
  values (300022003001,100022003,'init setup',getdate())
GO

--Catalog Bullets
insert into imp_dml_master (DMLkey,rulekey,tablename,processorder,lastuserid,lastmaintdate)
  values (300022004001,300022000001,'bookcomments',30,'init setup',getdate())
insert into imp_dml_elements (DMLkey,elementkey,lastuserid,lastmaintdate)
  values (300022004001,100022004,'init setup',getdate())
GO

--Catalog Quotes
insert into imp_dml_master (DMLkey,rulekey,tablename,processorder,lastuserid,lastmaintdate)
  values (300022005001,300022000001,'bookcomments',30,'init setup',getdate())
insert into imp_dml_elements (DMLkey,elementkey,lastuserid,lastmaintdate)
  values (300022005001,100022005,'init setup',getdate())
GO

--Book Description
insert into imp_dml_master (DMLkey,rulekey,tablename,processorder,lastuserid,lastmaintdate)
  values (300022006001,300022000001,'bookcomments',30,'init setup',getdate())
insert into imp_dml_elements (DMLkey,elementkey,lastuserid,lastmaintdate)
  values (300022006001,100022006,'init setup',getdate())
GO

--Excerpt
insert into imp_dml_master (DMLkey,rulekey,tablename,processorder,lastuserid,lastmaintdate)
  values (300022007001,300022000001,'bookcomments',30,'init setup',getdate())
insert into imp_dml_elements (DMLkey,elementkey,lastuserid,lastmaintdate)
  values (300022007001,100022007,'init setup',getdate())
GO

--Sales Handle
insert into imp_dml_master (DMLkey,rulekey,tablename,processorder,lastuserid,lastmaintdate)
  values (300022008001,300022000001,'bookcomments',30,'init setup',getdate())
insert into imp_dml_elements (DMLkey,elementkey,lastuserid,lastmaintdate)
  values (300022008001,100022008,'init setup',getdate())
GO

--Table of Contents
insert into imp_dml_master (DMLkey,rulekey,tablename,processorder,lastuserid,lastmaintdate)
  values (300022009001,300022000001,'bookcomments',30,'init setup',getdate())
insert into imp_dml_elements (DMLkey,elementkey,lastuserid,lastmaintdate)
  values (300022009001,100022009,'init setup',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022011001 ,'bookcomments', 300022000001 ,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022011001 ,100022011,'qsi_xt',getdate())
--- dups?^
GO

INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300022012001 ,100022012,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300022012001 ,'bookcomments', 300022000001 ,22000,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300022014001 ,100022014,'qsi_xt',getdate())
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300022014001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022015001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022015001 ,100022015,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022016001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022016001 ,100022016,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022017001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022017001 ,100022017,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022018001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022018001 ,100022018,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022019001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022019001 ,100022019,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022020001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022020001 ,100022020,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022021001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022021001 ,100022021,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022022001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022022001 ,100022022,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022023001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022023001 ,100022023,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300022024001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES (300022024001 ,100022024,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022025001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022025001 ,100022025,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022026001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022026001 ,100022026,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022027001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022027001 ,100022027,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022028001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022028001 ,100022028,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022029001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022029001 ,100022029,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022030001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022030001 ,100022030,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022031001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022031001 ,100022031,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022032001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022032001 ,100022032,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022033001 ,'bookcomments',300023000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022033001 ,100022033,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022034001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022034001 ,100022034,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022035001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022035001 ,100022035,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022100001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022100001 ,100022100,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022101001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022101001 ,100022101,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022102001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022102001 ,100022102,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES ( 300022103001 ,'bookcomments',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022103001 ,100022103,'qsi_xt',getdate())
GO

-- generated bookcomment linkage

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022104001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022104001,100022104,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022105001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022105001,100022105,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022106001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022106001,100022106,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022107001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022107001,100022107,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022108001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022108001,100022108,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022109001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022109001,100022109,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022110001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022110001,100022110,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022111001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022111001,100022111,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022112001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022112001,100022112,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022113001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022113001,100022113,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022114001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022114001,100022114,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022115001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022115001,100022115,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022116001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022116001,100022116,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022117001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022117001,100022117,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022118001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022118001,100022118,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022119001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022119001,100022119,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022120001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022120001,100022120,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022121001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022121001,100022121,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022122001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022122001,100022122,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022123001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022123001,100022123,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022124001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022124001,100022124,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022125001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022125001,100022125,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022126001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022126001,100022126,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022127001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022127001,100022127,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022128001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022128001,100022128,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022129001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022129001,100022129,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022130001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022130001,100022130,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022131001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022131001,100022131,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022132001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022132001,100022132,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022133001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022133001,100022133,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022134001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022134001,100022134,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022135001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022135001,100022135,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022136001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022136001,100022136,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022137001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022137001,100022137,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022138001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022138001,100022138,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022139001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022139001,100022139,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022140001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022140001,100022140,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022141001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022141001,100022141,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022142001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022142001,100022142,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022143001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022143001,100022143,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022144001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022144001,100022144,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022145001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022145001,100022145,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022146001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022146001,100022146,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022147001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022147001,100022147,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022148001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022148001,100022148,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022149001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022149001,100022149,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022150001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022150001,100022150,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022151001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022151001,100022151,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022152001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022152001,100022152,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022153001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022153001,100022153,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022154001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022154001,100022154,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022155001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022155001,100022155,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022156001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022156001,100022156,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022157001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022157001,100022157,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022158001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022158001,100022158,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022159001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022159001,100022159,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022160001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022160001,100022160,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022161001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022161001,100022161,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022162001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022162001,100022162,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022163001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022163001,100022163,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022164001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022164001,100022164,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022165001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022165001,100022165,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022166001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022166001,100022166,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022167001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022167001,100022167,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022168001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022168001,100022168,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022169001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022169001,100022169,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022170001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022170001,100022170,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022171001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022171001,100022171,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022172001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022172001,100022172,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022173001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022173001,100022173,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022174001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022174001,100022174,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022175001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022175001,100022175,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022176001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022176001,100022176,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022177001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022177001,100022177,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022178001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022178001,100022178,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022179001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022179001,100022179,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022180001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022180001,100022180,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022181001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022181001,100022181,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022182001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022182001,100022182,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022183001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022183001,100022183,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022184001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022184001,100022184,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022185001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022185001,100022185,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022186001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022186001,100022186,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022187001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022187001,100022187,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022188001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022188001,100022188,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022189001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022189001,100022189,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022190001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022190001,100022190,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022191001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022191001,100022191,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022192001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022192001,100022192,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022193001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022193001,100022193,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022194001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022194001,100022194,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022195001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022195001,100022195,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022196001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022196001,100022196,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022197001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022197001,100022197,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022198001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022198001,100022198,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022199001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022199001,100022199,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022200001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022200001,100022200,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022201001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022201001,100022201,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022202001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022202001,100022202,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022203001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022203001,100022203,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022204001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022204001,100022204,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022205001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022205001,100022205,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022206001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022206001,100022206,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022207001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022207001,100022207,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022208001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022208001,100022208,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022209001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022209001,100022209,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022210001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022210001,100022210,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022211001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022211001,100022211,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022212001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022212001,100022212,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022213001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022213001,100022213,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022214001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022214001,100022214,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022215001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022215001,100022215,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022216001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022216001,100022216,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022217001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022217001,100022217,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022218001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022218001,100022218,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022219001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022219001,100022219,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022220001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022220001,100022220,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022221001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022221001,100022221,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022222001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022222001,100022222,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022223001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022223001,100022223,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022224001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022224001,100022224,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022225001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022225001,100022225,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022226001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022226001,100022226,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022227001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022227001,100022227,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022228001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022228001,100022228,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022229001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022229001,100022229,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022230001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022230001,100022230,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022231001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022231001,100022231,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022232001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022232001,100022232,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022233001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022233001,100022233,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022234001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022234001,100022234,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022235001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022235001,100022235,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022236001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022236001,100022236,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022237001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022237001,100022237,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022238001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022238001,100022238,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022239001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022239001,100022239,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022240001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022240001,100022240,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022241001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022241001,100022241,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022242001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022242001,100022242,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022243001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022243001,100022243,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022244001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022244001,100022244,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022245001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022245001,100022245,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022246001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022246001,100022246,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022247001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022247001,100022247,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022248001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022248001,100022248,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022249001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022249001,100022249,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022250001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022250001,100022250,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022251001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022251001,100022251,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022252001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022252001,100022252,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022253001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022253001,100022253,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022254001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022254001,100022254,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022255001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022255001,100022255,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022256001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022256001,100022256,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022257001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022257001,100022257,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022258001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022258001,100022258,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022259001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022259001,100022259,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022260001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022260001,100022260,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022261001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022261001,100022261,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022262001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022262001,100022262,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022263001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022263001,100022263,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022264001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022264001,100022264,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022265001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022265001,100022265,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022266001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022266001,100022266,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022267001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022267001,100022267,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022268001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022268001,100022268,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022269001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022269001,100022269,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022270001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022270001,100022270,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022271001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022271001,100022271,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022272001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022272001,100022272,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022273001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022273001,100022273,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022274001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022274001,100022274,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022275001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022275001,100022275,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022276001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022276001,100022276,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022277001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022277001,100022277,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022278001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022278001,100022278,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022279001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022279001,100022279,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022280001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022280001,100022280,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022281001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022281001,100022281,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022282001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022282001,100022282,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022283001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022283001,100022283,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022284001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022284001,100022284,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022285001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022285001,100022285,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022286001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022286001,100022286,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022287001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022287001,100022287,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022288001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022288001,100022288,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022289001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022289001,100022289,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022290001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022290001,100022290,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022291001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022291001,100022291,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022292001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022292001,100022292,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022293001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022293001,100022293,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022294001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022294001,100022294,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022295001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022295001,100022295,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022296001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022296001,100022296,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022297001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022297001,100022297,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022298001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022298001,100022298,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022299001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022299001,100022299,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022300001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022300001,100022300,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022301001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022301001,100022301,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022302001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022302001,100022302,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022303001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022303001,100022303,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022304001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022304001,100022304,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022305001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022305001,100022305,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022306001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022306001,100022306,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022307001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022307001,100022307,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022308001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022308001,100022308,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022309001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022309001,100022309,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022310001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022310001,100022310,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022311001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022311001,100022311,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022312001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022312001,100022312,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022313001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022313001,100022313,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022314001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022314001,100022314,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022315001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022315001,100022315,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022316001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022316001,100022316,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022317001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022317001,100022317,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022318001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022318001,100022318,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022319001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022319001,100022319,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022320001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022320001,100022320,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022321001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022321001,100022321,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022322001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022322001,100022322,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022323001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022323001,100022323,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022324001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022324001,100022324,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022325001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022325001,100022325,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022326001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022326001,100022326,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022327001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022327001,100022327,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022328001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022328001,100022328,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022329001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022329001,100022329,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022330001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022330001,100022330,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022331001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022331001,100022331,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022332001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022332001,100022332,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022333001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022333001,100022333,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022334001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022334001,100022334,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022335001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022335001,100022335,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022336001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022336001,100022336,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022337001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022337001,100022337,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022338001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022338001,100022338,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022339001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022339001,100022339,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022340001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022340001,100022340,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022341001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022341001,100022341,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022342001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022342001,100022342,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022343001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022343001,100022343,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022344001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022344001,100022344,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022345001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022345001,100022345,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022346001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022346001,100022346,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022347001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022347001,100022347,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022348001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022348001,100022348,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022349001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022349001,100022349,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022350001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022350001,100022350,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022351001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022351001,100022351,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022352001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022352001,100022352,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022353001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022353001,100022353,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022354001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022354001,100022354,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022355001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022355001,100022355,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022356001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022356001,100022356,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022357001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022357001,100022357,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022358001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022358001,100022358,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022359001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022359001,100022359,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022360001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022360001,100022360,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022361001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022361001,100022361,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022362001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022362001,100022362,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022363001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022363001,100022363,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022364001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022364001,100022364,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022365001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022365001,100022365,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022366001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022366001,100022366,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022367001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022367001,100022367,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022368001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022368001,100022368,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022369001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022369001,100022369,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022370001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022370001,100022370,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022371001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022371001,100022371,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022372001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022372001,100022372,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022373001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022373001,100022373,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022374001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022374001,100022374,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022375001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022375001,100022375,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022376001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022376001,100022376,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022377001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022377001,100022377,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022378001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022378001,100022378,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022379001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022379001,100022379,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022380001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022380001,100022380,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022381001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022381001,100022381,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022382001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022382001,100022382,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022383001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022383001,100022383,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022384001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022384001,100022384,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022385001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022385001,100022385,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022386001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022386001,100022386,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022387001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022387001,100022387,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022388001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022388001,100022388,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022389001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022389001,100022389,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022390001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022390001,100022390,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022391001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022391001,100022391,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022392001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022392001,100022392,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022393001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022393001,100022393,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022394001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022394001,100022394,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022395001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022395001,100022395,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022396001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022396001,100022396,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022397001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022397001,100022397,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022398001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022398001,100022398,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022399001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022399001,100022399,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022400001,'bookcomment',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022400001,100022400,'qsi_xt',getdate())
go

-- end generated bookcomment linkage

--mk08292013>GenericComments
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES(300022401001,'GenericComment1',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300022401001,100022401,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES(300022401002,'GenericComment1',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300022402001,100022402,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES(300022403001,'GenericComment1',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300022403001,100022403,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES(300022404001,'GenericComment1',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300022404001,100022404,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES(300022405001,'GenericComment1',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300022405001,100022405,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES(300022406001,'GenericComment1',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300022406001,100022406,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES(300022407001,'GenericComment1',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300022407001,100022407,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES(300022408001,'GenericComment1',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300022408001,100022408,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES(300022409001,'GenericComment1',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300022409001,100022409,'qsi_xt',getdate())

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate) VALUES(300022410001,'GenericComment1',300022000001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate) VALUES(300022410001,100022410,'qsi_xt',getdate())
GO


INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022500001,'bookcomment',300022001001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022500001,100022500,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022500001,100022501,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022500001,100022502,'qsi_xt',getdate())
go

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022505001,'bookcomment',300022005001,22000,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022505001,100022505,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022505001,100022506,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022505001,100022507,'qsi_xt',getdate())
go



-- citation delete
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022611001,'bookcomment',300022611001,60,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022611001,100022611,'qsi_xt',getdate())
go

-- book citation comments
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022701001,'bookcomment',300022701001,60,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022701001,100022701,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022701001,100022702,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022701001,100022703,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022701001,100022704,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022701001,100022705,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022701001,100022706,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022701001,100022707,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022701001,100022708,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022701001,100022709,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022701001,100022710,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022701001,100022711,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022701001,100022712,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022701001,100022713,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022701001,100022714,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022701001,100022715,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022701001,100022716,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022701001,100022717,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022701001,100022718,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022701001,100022719,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022701001,100022720,'qsi_xt',getdate())
go


INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES(300022801001,'authorbio qsicomments',300022801001,60,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
  VALUES(300022801001,100022801,'qsi_xt',getdate())


-------------------------------------------------------------
/*  GLOBAL CONTACT ELEMENT SET*/
-------------------------------------------------------------

--INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
--  VALUES (300024011001, 'GLOBALCONTACT', 300024011001,1,'qsi_xt',getdate())
--INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
-- VALUES(300024011001, 100024011,'qsi_xt',getdate())
--GO
--INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
--  VALUES (300024012001, 'GLOBALCONTACT', 300024012001,1,'qsi_xt',getdate())
--INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
-- VALUES(300024012001, 100024012,'qsi_xt',getdate())
--GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300024013001, 'personel', 300024013001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES(300024013001, 100024013,'qsi_xt',getdate())
GO
--INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
--  VALUES (300024014001, 'GLOBALCONTACT', 300024014001,1,'qsi_xt',getdate())
--INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
-- VALUES(300024014001, 100024014,'qsi_xt',getdate())
--GO
--INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
--  VALUES (300024015001, 'GLOBALCONTACT', 300024015001,1,'qsi_xt',getdate())
--INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
-- VALUES(300024015001, 100024015,'qsi_xt',getdate())
--GO
--INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
--  VALUES (300024016001, 'GLOBALCONTACT', 300024016001,1,'qsi_xt',getdate())
--INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
-- VALUES(300024016001, 100024016,'qsi_xt',getdate())
--GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300024020001, 'GLOBALCONTACT', 300024020001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES(300024020001, 100024020,'qsi_xt',getdate())
GO

/*   AUTHOR INFO	*/
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
  VALUES (300026000001, 'author', 300026000001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES(300026000001, 100026000,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026000002, 'bookauthor', 300026000002,99,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES(300026000002, 100026000,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026000003, 'bookauthor', 300026000003,88,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES(300026000003, 100026000,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026001001, 'author', 300026001001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026001001,  100026001,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026002001, 'author', 300026002001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026002001,  100026002,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026004001, 'author', 300026004001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026004001,  100026004,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026005001, 'author', 300026005001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026005001,  100026005,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026006001, 'author', 300026006001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026006001,  100026006,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026007001, 'author', 300026007001,1,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026007001,  100026007,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026008001, 'author', 300026008001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026008001,  100026008,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026009001, 'author', 300026009001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026009001,  100026009,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026013001, 'author', 300026013001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026013001,  100026013,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026016001, 'author', 300026016001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026016001,  100026016,'qsi_xt',getdate())
 GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026017001, 'author', 300026017001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026017001,  100026017,'qsi_xt',getdate())
 GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026018001, 'author', 300026018001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026018001,  100026018,'qsi_xt',getdate())
 GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026040001, 'author', 300026040001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026040001,  100026040,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026041001, 'author', 300026041001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026041001,  100026041,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026042001, 'author', 300026042001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026042001,  100026042,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026043001, 'author', 300026043001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026043001,  100026043,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026044001, 'author', 300026044001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026044001,  100026044,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026045001, 'author', 300026045001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026045001,  100026045,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026046001, 'author', 300026046001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026046001,  100026046,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026047001, 'author', 300026047001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026047001,  100026047,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026049001, 'author', 300026049001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026049001,  100026049,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026050001, 'author', 300026050001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026050001,  100026050,'qsi_xt',getdate())
GO
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026051001, 'author', 300026051001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026051001,  100026051,'qsi_xt',getdate())
GO



INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300026147001, 'author', 300026147001,30,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300026147001,  100026147,'qsi_xt',getdate())
GO


/*  CUSTOM FIELDS */

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300021051001, 'bookcustom', 300021051001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300021051001,  100021051,'qsi_xt',getdate())
 GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300021052001, 'bookcustom', 300021052001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300021052001,  100021052,'qsi_xt',getdate())
 GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300021053001, 'bookcustom', 300021053001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300021053001,  100021053,'qsi_xt',getdate())
 GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300021054001, 'bookcustom', 300021054001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300021054001,  100021054,'qsi_xt',getdate())
 GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300021055001, 'bookcustom', 300021055001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300021055001,  100021055,'qsi_xt',getdate())
 GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300021056001, 'bookcustom', 300021056001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300021056001,  100021056,'qsi_xt',getdate())
 GO


INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300021057001, 'bookcustom', 300021057001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300021057001,  100021057,'qsi_xt',getdate())
 GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300021058001, 'bookcustom', 300021058001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300021058001,  100021058,'qsi_xt',getdate())
 GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300021059001, 'bookcustom', 3000210591001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300021059001,  100021059,'qsi_xt',getdate())
 GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300021060001, 'bookcustom', 300021060001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300021060001,  100021060,'qsi_xt',getdate())
 GO


INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300027011001, 'taqplsales_actual', 300027011001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300027011001,  100027011,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300027011001,  100027012,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300027011001,  100027013,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300027011001,  100027014,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300027011001,  100027015,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300027011001,  100027016,'qsi_xt',getdate())
GO

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300027021001, 'taqplcosts_actual', 300027021001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300027021001,  100027021,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300027021001,  100027022,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300027021001,  100027023,'qsi_xt',getdate())
go

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300027031001, 'taqplproduction_actual', 300027031001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300027031001,  100027031,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300027031001,  100027032,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300027031001,  100027033,'qsi_xt',getdate())
go

-- long misc type
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028101001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028101001,  100028101,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028102001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028102001,  100028102,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028103001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028103001,  100028103,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028104001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028104001,  100028104,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028105001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028105001,  100028105,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028106001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028106001,  100028106,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028107001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028107001,  100028107,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028108001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028108001,  100028108,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028109001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028109001,  100028109,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028110001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028110001,  100028110,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028111001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028111001,  100028111,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028112001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028112001,  100028112,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028113001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028113001,  100028113,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028114001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028114001,  100028114,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028115001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028115001,  100028115,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028116001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028116001,  100028116,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028117001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028117001,  100028117,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028118001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028118001,  100028118,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028119001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028119001,  100028119,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028120001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028120001,  100028120,'qsi_xt',getdate())
go

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028121001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028121001,  100028121,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028122001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028122001,  100028122,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028123001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028123001,  100028123,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028124001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028124001,  100028124,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028125001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028125001,  100028125,'qsi_xt',getdate())
go--
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028126001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028126001,  100028126,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028127001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028127001,  100028127,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028128001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028128001,  100028128,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028129001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028129001,  100028129,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028130001, 'misc longvalue', 300028100001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028130001,  100028130,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028131001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028131001,  100028131,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028132001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028132001,  100028132,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028133001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028133001,  100028133,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028134001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028134001,  100028134,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028135001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028135001,  100028135,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028136001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028136001,  100028136,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028137001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028137001,  100028137,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028138001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028138001,  100028138,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028139001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028139001,  100028139,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028140001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028140001,  100028140,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028141001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028141001,  100028141,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028142001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028142001,  100028142,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028143001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028143001,  100028143,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028144001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028144001,  100028144,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028145001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028145001,  100028145,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028146001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028146001,  100028146,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028147001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028147001,  100028147,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028148001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028148001,  100028148,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028149001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028149001,  100028149,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028150001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028150001,  100028150,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028151001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028151001,  100028151,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028152001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028152001,  100028152,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028153001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028153001,  100028153,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028154001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028154001,  100028154,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028155001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028155001,  100028155,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028156001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028156001,  100028156,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028157001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028157001,  100028157,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028158001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028158001,  100028158,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028159001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028159001,  100028159,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028160001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028160001,  100028160,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028161001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028161001,  100028161,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028162001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028162001,  100028162,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028163001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028163001,  100028163,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028164001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028164001,  100028164,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028165001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028165001,  100028165,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028166001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028166001,  100028166,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028167001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028167001,  100028167,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028168001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028168001,  100028168,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028169001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028169001,  100028169,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028170001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028170001,  100028170,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028171001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028171001,  100028171,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028172001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028172001,  100028172,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028173001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028173001,  100028173,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028174001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028174001,  100028174,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028175001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028175001,  100028175,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028176001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028176001,  100028176,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028177001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028177001,  100028177,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028178001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028178001,  100028178,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028179001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028179001,  100028179,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028180001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028180001,  100028180,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028181001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028181001,  100028181,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028182001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028182001,  100028182,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028183001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028183001,  100028183,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028184001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028184001,  100028184,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028185001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028185001,  100028185,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028186001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028186001,  100028186,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028187001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028187001,  100028187,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028188001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028188001,  100028188,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028189001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028189001,  100028189,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028190001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028190001,  100028190,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028191001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028191001,  100028191,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028192001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028192001,  100028192,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028193001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028193001,  100028193,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028194001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028194001,  100028194,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028195001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028195001,  100028195,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028196001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028196001,  100028196,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028197001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028197001,  100028197,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028198001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028198001,  100028198,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028199001, 'misc longvalue', 300028100001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028199001,  100028199,'firebrand',getdate());





-- float misc type
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028201001, 'misc floatvalue', 300028200001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028201001,  100028201,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028202001, 'misc floatvalue', 300028200001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028202001,  100028202,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028203001, 'misc floatvalue', 300028200001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028203001,  100028203,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028204001, 'misc floatvalue', 300028200001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028204001,  100028204,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028205001, 'misc floatvalue', 300028200001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028205001,  100028205,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028206001, 'misc floatvalue', 300028200001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028206001,  100028206,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028207001, 'misc floatvalue', 300028200001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028207001,  100028207,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028208001, 'misc floatvalue', 300028200001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028208001,  100028208,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028209001, 'misc floatvalue', 300028200001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028209001,  100028209,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028210001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028210001,  100028210,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028211001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028211001,  100028211,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028212001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028212001,  100028212,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028213001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028213001,  100028213,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028214001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028214001,  100028214,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028215001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028215001,  100028215,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028216001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028216001,  100028216,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028217001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028217001,  100028217,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028218001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028218001,  100028218,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028219001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028219001,  100028219,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028220001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028220001,  100028220,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028221001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028221001,  100028221,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028222001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028222001,  100028222,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028223001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028223001,  100028223,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028224001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028224001,  100028224,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028225001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028225001,  100028225,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028226001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028226001,  100028226,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028227001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028227001,  100028227,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028228001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028228001,  100028228,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028229001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028229001,  100028229,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028230001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028230001,  100028230,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028231001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028231001,  100028231,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028232001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028232001,  100028232,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028233001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028233001,  100028233,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028234001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028234001,  100028234,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028235001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028235001,  100028235,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028236001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028236001,  100028236,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028237001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028237001,  100028237,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028238001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028238001,  100028238,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028239001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028239001,  100028239,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028240001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028240001,  100028240,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028241001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028241001,  100028241,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028242001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028242001,  100028242,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028243001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028243001,  100028243,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028244001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028244001,  100028244,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028245001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028245001,  100028245,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028246001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028246001,  100028246,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028247001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028247001,  100028247,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028248001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028248001,  100028248,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028249001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028249001,  100028249,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028250001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028250001,  100028250,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028251001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028251001,  100028251,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028252001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028252001,  100028252,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028253001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028253001,  100028253,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028254001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028254001,  100028254,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028255001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028255001,  100028255,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028256001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028256001,  100028256,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028257001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028257001,  100028257,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028258001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028258001,  100028258,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028259001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028259001,  100028259,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028260001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028260001,  100028260,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028261001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028261001,  100028261,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028262001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028262001,  100028262,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028263001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028263001,  100028263,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028264001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028264001,  100028264,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028265001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028265001,  100028265,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028266001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028266001,  100028266,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028267001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028267001,  100028267,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028268001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028268001,  100028268,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028269001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028269001,  100028269,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028270001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028270001,  100028270,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028271001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028271001,  100028271,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028272001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028272001,  100028272,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028273001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028273001,  100028273,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028274001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028274001,  100028274,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028275001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028275001,  100028275,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028276001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028276001,  100028276,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028277001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028277001,  100028277,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028278001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028278001,  100028278,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028279001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028279001,  100028279,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028280001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028280001,  100028280,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028281001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028281001,  100028281,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028282001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028282001,  100028282,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028283001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028283001,  100028283,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028284001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028284001,  100028284,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028285001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028285001,  100028285,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028286001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028286001,  100028286,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028287001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028287001,  100028287,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028288001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028288001,  100028288,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028289001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028289001,  100028289,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028290001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028290001,  100028290,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028291001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028291001,  100028291,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028292001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028292001,  100028292,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028293001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028293001,  100028293,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028294001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028294001,  100028294,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028295001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028295001,  100028295,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028296001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028296001,  100028296,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028297001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028297001,  100028297,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028298001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028298001,  100028298,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028299001, 'misc floatvalue', 300028200001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028299001,  100028299,'firebrand',getdate());
go


-- test misc type
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028301001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028301001,  100028301,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028302001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028302001,  100028302,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028303001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028303001,  100028303,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028304001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028304001,  100028304,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028305001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028305001,  100028305,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028306001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028306001,  100028306,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028307001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028307001,  100028307,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028308001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028308001,  100028308,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028309001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028309001,  100028309,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028310001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028310001,  100028310,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028311001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028311001,  100028311,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028312001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028312001,  100028312,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028313001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028313001,  100028313,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028314001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028314001,  100028314,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028315001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028315001,  100028315,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028316001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028316001,  100028316,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028317001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028317001,  100028317,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028318001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028318001,  100028318,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028319001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028319001,  100028319,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028320001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028320001,  100028320,'qsi_xt',getdate())
go--
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028321001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028321001,  100028321,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028322001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028322001,  100028322,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028323001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028323001,  100028323,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028324001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028324001,  100028324,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028325001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028325001,  100028325,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028326001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028326001,  100028326,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028327001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028327001,  100028327,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028328001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028328001,  100028328,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028329001, 'misc textvalue', 300028300001,21,'qsi_xt',getdate())
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028329001,  100028329,'qsi_xt',getdate())
go
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028330001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028330001,  100028330,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028331001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028331001,  100028331,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028332001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028332001,  100028332,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028333001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028333001,  100028333,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028334001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028334001,  100028334,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028335001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028335001,  100028335,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028336001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028336001,  100028336,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028337001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028337001,  100028337,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028338001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028338001,  100028338,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028339001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028339001,  100028339,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028340001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028340001,  100028340,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028341001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028341001,  100028341,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028342001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028342001,  100028342,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028343001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028343001,  100028343,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028344001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028344001,  100028344,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028345001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028345001,  100028345,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028346001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028346001,  100028346,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028347001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028347001,  100028347,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028348001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028348001,  100028348,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028349001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028349001,  100028349,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028350001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028350001,  100028350,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028351001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028351001,  100028351,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028352001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028352001,  100028352,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028353001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028353001,  100028353,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028354001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028354001,  100028354,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028355001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028355001,  100028355,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028356001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028356001,  100028356,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028357001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028357001,  100028357,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028358001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028358001,  100028358,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028359001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028359001,  100028359,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028360001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028360001,  100028360,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028361001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028361001,  100028361,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028362001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028362001,  100028362,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028363001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028363001,  100028363,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028364001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028364001,  100028364,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028365001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028365001,  100028365,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028366001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028366001,  100028366,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028367001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028367001,  100028367,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028368001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028368001,  100028368,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028369001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028369001,  100028369,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028370001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028370001,  100028370,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028371001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028371001,  100028371,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028372001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028372001,  100028372,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028373001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028373001,  100028373,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028374001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028374001,  100028374,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028375001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028375001,  100028375,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028376001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028376001,  100028376,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028377001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028377001,  100028377,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028378001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028378001,  100028378,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028379001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028379001,  100028379,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028380001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028380001,  100028380,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028381001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028381001,  100028381,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028382001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028382001,  100028382,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028383001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028383001,  100028383,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028384001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028384001,  100028384,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028385001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028385001,  100028385,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028386001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028386001,  100028386,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028387001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028387001,  100028387,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028388001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028388001,  100028388,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028389001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028389001,  100028389,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028390001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028390001,  100028390,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028391001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028391001,  100028391,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028392001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028392001,  100028392,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028393001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028393001,  100028393,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028394001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028394001,  100028394,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028395001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028395001,  100028395,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028396001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028396001,  100028396,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028397001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028397001,  100028397,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028398001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028398001,  100028398,'firebrand',getdate());
INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300028399001, 'misc textvalue', 300028300001,21,'firbreand',getdate());
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300028399001,  100028399,'firebrand',getdate());
go

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300050000001, 'DELETE FROM TABLE', 300050000001,-3,'qsi_xt',getdate())
go
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300050000001,  100050000,'qsi_xt',getdate())
go
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300050000001,  100050001,'qsi_xt',getdate())
go
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300050000001,  100050002,'qsi_xt',getdate())
go
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300050000001,  100050003,'qsi_xt',getdate())
go
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300050000001,  100050004,'qsi_xt',getdate())
go

INSERT INTO imp_dml_master(DMLkey,tablename,rulekey,processorder,lastuserid,lastmaintdate)
 VALUES (300014160001, 'DELETE FROM TABLE', 300014160001,-3,'qsi_xt',getdate())
go
INSERT INTO imp_dml_elements(DMLkey,elementkey,lastuserid,lastmaintdate)
 VALUES (300014160001,  100014160,'qsi_xt',getdate())
go
