if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qtitle_contractstitleview_by_bookkey') and xtype in (N'FN', N'IF', N'TF'))
  drop function [dbo].qtitle_contractstitleview_by_bookkey
GO

CREATE FUNCTION dbo.qtitle_contractstitleview_by_bookkey(@i_bookkey int)

RETURNS @contractstitleviewtable TABLE(
  contractprojectkey INT,
  workprojectkey INT NULL,  
  bookkey INT NULL,
  printingkey INT NULL,
  contractdisplayname VARCHAR(255) NULL,
  contractparticipants VARCHAR(255) NULL,
  contracttypedesc VARCHAR(80) NULL,
  contractstatusdesc VARCHAR(80) NULL,
  projectowner VARCHAR(80) NULL,
  searchitemcode INT NULL,
  usageclasscode INT NULL,
  templateind TINYINT NULL DEFAULT 0,
  keyind TINYINT NULL DEFAULT 0,
  titlerolecode INT NULL,
  titleroledesc VARCHAR(255) NULL,
  title VARCHAR(255) NULL,
  productnumberx VARCHAR(50) NULL,
  altproductnumberx VARCHAR(50) NULL,
  authorname VARCHAR(150) NULL,
  seasondesc VARCHAR(80) NULL,
  formatname VARCHAR(120) NULL,
  mediatypecode INT NULL,
  mediatypesubcode INT NULL,
  mediaformatkey VARCHAR(255) NULL,
  bisacstatusdesc VARCHAR(255) NULL,
  productnumber VARCHAR(50) NULL,
  primaryformatind TINYINT NULL DEFAULT 0
)
AS

BEGIN
  DECLARE 
    @v_bookkey	INT,
    @v_work_itemtype INT,
    @v_work_usageclass INT,
    @v_masterwork_usageclass INT,
    @v_contract_itemtype INT
    
    IF coalesce(@i_bookkey,0) = 0 BEGIN
      return
    END
  
    DECLARE @titlemasterworkviewinfo TABLE (
      bookkey int null,
      workprojectkey int null,
      masterworkprojectkey int null) 

    INSERT INTO @titlemasterworkviewinfo
    SELECT bookkey, workprojectkey, masterworkprojectkey
      FROM dbo.titlemasterworkview
     WHERE bookkey = @i_bookkey

    SELECT @v_contract_itemtype = gen.dataCode	FROM gentables gen WHERE gen.tableid = 550 AND gen.qsicode = 10
    SELECT @v_work_itemtype = gen.dataCode	FROM gentables gen WHERE gen.tableid = 550 AND gen.qsicode = 9
    SELECT @v_work_usageclass = sub.dataSubCode FROM subgentables sub WHERE sub.tableid = 550 AND sub.qsiCode = 28
    SELECT @v_masterwork_usageclass = sub.dataSubCode FROM subgentables sub WHERE sub.tableid = 550 AND sub.qsiCode = 53

    INSERT INTO @contractstitleviewtable
    SELECT 
	    pv.taqprojectkey contractprojectkey,pv.relatedprojectkey workprojectkey,
	    ct.bookkey,ct.printingkey,cp.projecttitle contractdisplayname, cp.projectparticipants contractparticipants,
	    cp.projecttypedesc contracttypedesc, cp.projectstatusdesc contractstatusdesc, 
	    cp.projectowner, cp.searchitemcode, cp.usageclasscode, COALESCE(cp.templateind,0) templateind, 
	    t.keyind, t.titlerolecode, dbo.get_gentables_desc(605,t.titlerolecode,'long') titleroledesc, 
	    ct.title, ct.productnumberx, ct.altproductnumberx, ct.authorname, ct.seasondesc, 
	    ct.formatname, ct.mediatypecode, ct.mediatypesubcode,
	    CONVERT(VARCHAR, ct.mediatypecode) + '|' + CONVERT(VARCHAR,ct.mediatypesubcode) mediaformatkey, 
	    dbo.get_gentables_desc(314,ct.bisacstatuscode,'long') bisacstatusdesc,
	    ct.productnumber,t.primaryformatind
    FROM 
	    projectrelationshipview pv 
    LEFT JOIN @titlemasterworkviewinfo tmw
	    ON pv.relatedprojectkey =  tmw.workprojectkey 
    LEFT JOIN coretitleinfo ct
	    ON ct.bookkey = tmw.bookkey 
	    AND ct.printingkey = 1
    LEFT JOIN coreprojectinfo cp 
	    ON cp.projectkey = pv.taqprojectkey
    LEFT JOIN taqprojecttitle t	
	    ON t.taqprojectkey = pv.relatedprojectkey 
	    AND t.bookkey = tmw.bookkey
    WHERE pv.relatedprojectusageclasscode = @v_work_usageclass
	    AND pv.projectsearchitemcode = @v_contract_itemtype
	    AND pv.relatedprojectsearchitemcode = @v_work_itemtype
      AND tmw.bookkey = @i_bookkey
    UNION
    SELECT 
	    pv.taqprojectkey contractprojectkey,pv.relatedprojectkey workprojectkey,
	    ct.bookkey,ct.printingkey,cp.projecttitle contractdisplayname, cp.projectparticipants contractparticipants,
	    cp.projecttypedesc contracttypedesc, cp.projectstatusdesc contractstatusdesc, 
	    cp.projectowner, cp.searchitemcode, cp.usageclasscode, COALESCE(cp.templateind,0) templateind, 
	    t.keyind, t.titlerolecode, dbo.get_gentables_desc(605,t.titlerolecode,'long') titleroledesc, 
	    ct.title, ct.productnumberx, ct.altproductnumberx, ct.authorname, ct.seasondesc, 
	    ct.formatname, ct.mediatypecode, ct.mediatypesubcode,
	    CONVERT(VARCHAR, ct.mediatypecode) + '|' + CONVERT(VARCHAR,ct.mediatypesubcode) mediaformatkey, 
	    dbo.get_gentables_desc(314,ct.bisacstatuscode,'long') bisacstatusdesc,
	    ct.productnumber,t.primaryformatind
    FROM 
	     projectrelationshipview pv 
    LEFT JOIN @titlemasterworkviewinfo tmw
	    ON pv.relatedprojectkey = tmw.MasterWorkProjectKey
    LEFT JOIN coretitleinfo ct
	    ON ct.bookkey = tmw.bookkey 
	    AND ct.printingkey = 1
    LEFT JOIN coreprojectinfo cp 
	    ON cp.projectkey = pv.taqprojectkey
    LEFT JOIN taqprojecttitle t	
	    ON t.taqprojectkey = pv.relatedprojectkey 
	    AND t.bookkey = tmw.bookkey
    WHERE pv.relatedprojectusageclasscode = @v_masterwork_usageclass
	    AND pv.projectsearchitemcode = @v_contract_itemtype
	    AND pv.relatedprojectsearchitemcode = @v_work_itemtype
      AND tmw.bookkey = @i_bookkey

  RETURN
END
go

GRANT SELECT ON dbo.qtitle_contractstitleview_by_bookkey TO PUBLIC
GO