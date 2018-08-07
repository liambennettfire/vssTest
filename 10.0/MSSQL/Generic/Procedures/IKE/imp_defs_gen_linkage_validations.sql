set nocount on
go

/******************************************************************************
**  Name: imp_defs_gen_linkage_validations
**  Desc: IKE generic element linkage of validation rules
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  5/20/16      Kusum       Case 37311 - Validation for SubjectCategory
**  5/24/2016    Kusum       Case 36771 BICSubjectCategories (tableid = 668)
*******************************************************************************/

delete from imp_element_rules
  where elementkey >= 100000000
    and elementkey <= 100099999
go

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010001,200000000000,1,1,'qsi_xt',GETDATE())
go

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010001,200000000001,1,1,'qsi_xt',GETDATE())
go

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010000,200010000001,2,1,'qsi_xt',GETDATE())
go

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010001,200010001001,2,1,'qsi_xt',GETDATE())
go

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010001,200010001002,3,1,'qsi_xt',GETDATE())
go

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100012070,200000000004,4,1,'qsi_xt',GETDATE())
go

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010001,200010001003,4,1,'qsi_xt',GETDATE())
go

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010000,200010001003,4,1,'qsi_xt',GETDATE())
go

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100000001,200010001004,5,1,'qsi_xt',GETDATE())
go
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010001,200010001004,5,1,'qsi_xt',GETDATE())
go
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010002,200010001004,5,1,'qsi_xt',GETDATE())
go
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010003,200010001004,5,1,'qsi_xt',GETDATE())
go

--mk20120823> imp_200010002001 doesn't exist so I'm commenting this out
--INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
--  VALUES(100010002,200010002001,2,1,'qsi_xt',GETDATE())
--go

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010002,200010002002,2,1,'qsi_xt',GETDATE())
go

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010003,200010002002,2,1,'qsi_xt',GETDATE())
go

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010011,200010011001,5,1,'qsi_xt',GETDATE())
go

/*validation - check for addlqualifier values*/
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010026,200010026001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010027,200010026001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010028,200010026001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010029,200010026001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010031,200010026001,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010041,200010041001,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010046,200010046001,1,1,'qsi_xt',GETDATE())
GO


INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100012003,200012003001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100012004,200000000002,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100012007,200000000007,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100012013,200000000012,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100012018,200012018001,1,1,'qsi_xt',GETDATE())
GO

--INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
--  VALUES(100012018,200012018002,1,1,'qsi_xt',GETDATE())
--GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010019,200010019001,1,1,'qsi_xt',GETDATE())
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010019,200010019002,2,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
VALUES (100012021,200012021001,1,21,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
VALUES (100012022,200012022001,1,21,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
VALUES(100012027,200000000001,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
VALUES(100012029,200000000001,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100012027,200000000008,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100012029,200000000008,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules (elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate) 
	VALUES(100011011,200011011001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules (elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate) 
	VALUES(100011012,200011011001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules (elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate) 
	VALUES(100011013,200011011001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules (elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate) 
	VALUES(100011014,200011011001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules (elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate) 
	VALUES(100011015,200011011001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules (elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate) 
	VALUES(100011016,200011011001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules (elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate) 
	VALUES(100011017,200011011001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules (elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate) 
	VALUES(100011018,200011011001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules (elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate) 
	VALUES(100011019,200011011001,1,1,'qsi_xt',GETDATE())
GO

-- Case 37311 5/20/16 KB
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018001,200018001002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018002,200018001002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018003,200018001002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018004,200018001002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018005,200018001002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018006,200018001002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018007,200018001002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018008,200018001002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018009,200018001002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018010,200018001002,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018011,200018001002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018012,200018001002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018013,200018001002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018014,200018001002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018015,200018001002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018016,200018001002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018017,200018001002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018018,200018001002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018019,200018001002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018020,200018001002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100018101,200018001002,1,1,'qsi_xt',GETDATE())
GO
-- Case 37311 5/20/16 KB

-- Case 36771 BICSubjectCategories
insert into imp_element_rules (elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate) values
(100018021,200018001002,1,1,'fb_imp',getdate())
go
insert into imp_element_rules (elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate) values
(100018022,200018001002,1,1,'fb_imp',getdate())
go

-- Case 36771 BICSubjectCategories

INSERT INTO imp_element_rules (elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate) 
	VALUES(100011020,200011020001,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100012029,200012029001,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100010013,200010013001,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100012037,200000000002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100012041,200000000002,1,1,'qsi_xt',GETDATE())
GO


INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100012050,200012050001,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100012053,200012053001,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100012076,200000000012,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100012058,200000000012,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100012059,200000000012,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100012060,200000000012,1,1,'qsi_xt',GETDATE())
GO

--INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
--  VALUES(100013009,200000000002,1,1,'qsi_xt',GETDATE())
--GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100013024,200013024001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100013026,200013026001,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100014046,200000000012,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100014049,200000000002,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100014050,200014050001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
 VALUES(100014051,200014051001,1,1,'qsi_xt',GETDATE())
go
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100014052,200014052001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100014053,200000000012,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100014054,200014054001,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100014055,200014055001,1,1,'qsi_xt',GETDATE())
GO


INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100014056,200014056001,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100014057,200014057001,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100014058,200014058001,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100014059,200000000013,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100014067,200000000012,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100014070,200014070001,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100014071,200014071001,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100014081,200000000012,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100016001,200016001001,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100016101,200000000012,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100017000,200017001001,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100017001,200017001001,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020001,200000000005,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020002,200000000005,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020003,200000000005,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020004,200000000005,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020005,200000000005,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020006,200000000005,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020007,200000000005,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020008,200000000005,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020009,200000000005,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020010,200000000005,1,1,'qsi_xt',GETDATE())
GO


INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020101,200020101001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020102,200020101001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020103,200020101001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020104,200020101001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020105,200020101001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020106,200020101001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020107,200020101001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020108,200020101001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020109,200020101001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020110,200020101001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020111,200020101001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020112,200020101001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020113,200020101001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020114,200020101001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020115,200020101001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100020116,200020101001,1,1,'qsi_xt',GETDATE())
GO



INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100021041,200000000002,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100026003,200026003001,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100021051,200021000001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100021052,200021000001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100021053,200021000001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100021054,200021000001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100021055,200021000001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100021056,200021000001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100021057,200021000001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100021058,200021000001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100021059,200021000001,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100021060,200021000001,1,1,'qsi_xt',GETDATE())
GO
	
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100026044,200000000012,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100026046,200000000012,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100026050,200000000012,1,1,'qsi_xt',GETDATE())
GO
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100027022,200000000002,1,1,'qsi_xt',GETDATE())
GO

INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100014091,200014091001,1,1,'firebrand',GETDATE())
go
INSERT INTO imp_element_rules(elementkey,rulekey,ruleseq,processorder,lastuserid,lastmaintdate)
  VALUES(100014092,200014092001,1,1,'firebrand',GETDATE())
go

/*****************************************/
/** Validation (Colection) rule linkage **/
/*****************************************/
delete from imp_collection_master
  where collectionkey >= 200000000000
    and collectionkey <= 200099999999
delete from imp_collection_elements
  where collectionkey >= 200000000000
    and collectionkey <= 200099999999
go

INSERT INTO imp_collection_master(collectionkey,collectiondesc,processorder,lastuserid,lastmaintdate)
  VALUES(200012043001,'validate barcode type and position',30,'qsi_xt',GETDATE())
INSERT INTO imp_collection_elements(collectionkey,elementkey,lastuserid,lastmaintdate)
  VALUES(200012043001,100012043,'qsi_xt',GETDATE())
INSERT INTO imp_collection_elements(collectionkey,elementkey,lastuserid,lastmaintdate)
  VALUES(200012043001,100012044,'qsi_xt',GETDATE())

INSERT INTO imp_collection_master(collectionkey,collectiondesc,processorder,lastuserid,lastmaintdate)
  VALUES(200013000001,'validation book pricing',30,'qsi_xt',GETDATE())
INSERT INTO imp_collection_elements(collectionkey,elementkey,lastuserid,lastmaintdate)
  VALUES(200013000001,100013021,'qsi_xt',GETDATE())
INSERT INTO imp_collection_elements(collectionkey,elementkey,lastuserid,lastmaintdate)
  VALUES(200013000001,100013022,'qsi_xt',GETDATE())
INSERT INTO imp_collection_elements(collectionkey,elementkey,lastuserid,lastmaintdate)
  VALUES(200013000001,100013023,'qsi_xt',GETDATE())
INSERT INTO imp_collection_elements(collectionkey,elementkey,lastuserid,lastmaintdate)
  VALUES(200013000001,100013024,'qsi_xt',GETDATE())
INSERT INTO imp_collection_elements(collectionkey,elementkey,lastuserid,lastmaintdate)
  VALUES(200013000001,100013025,'qsi_xt',GETDATE())
INSERT INTO imp_collection_elements(collectionkey,elementkey,lastuserid,lastmaintdate)
  VALUES(200013000001,100013026,'qsi_xt',GETDATE())
INSERT INTO imp_collection_elements(collectionkey,elementkey,lastuserid,lastmaintdate)
  VALUES(200013000001,100013027,'qsi_xt',GETDATE())
GO



