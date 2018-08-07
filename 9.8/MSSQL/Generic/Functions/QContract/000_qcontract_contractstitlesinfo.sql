if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qcontract_contractstitlesinfo') and xtype in (N'FN', N'IF', N'TF'))
	drop function [dbo].qcontract_contractstitlesinfo
GO

CREATE FUNCTION dbo.qcontract_contractstitlesinfo (@i_taqprojectkey int)

RETURNS @contractstitlestable TABLE(
    contractprojectkey int,
    workprojectkey int,
    bookkey int, 
    printingkey int,
    contractdisplayname varchar(255), 
    contractparticipants varchar(255),
    contracttypedesc varchar(80), 
    contractstatusdesc varchar(80), 
    projectowner varchar(80), 
    searchitemcode int, 
    usageclasscode int, 
    templateind tinyint, 
    keyind tinyint, 
    titlerolecode int, 
    titleroledesc varchar(255), 
    title varchar(255), 
    productnumberx varchar(50), 
    altproductnumberx varchar(50), 
    authorname varchar(255), 
    seasondesc varchar(255), 
    formatname varchar(120), 
    mediatypecode int, 
    mediatypesubcode int,
    mediaformatkey varchar(50), 
    bisacstatusdesc varchar(255),
    productnumber varchar(50), 
    primaryformatind tinyint
	)
AS

/*********************************************************************************************************************
**  Name: qcontract_contractstitlesinfo
**  Desc: This functional table returns contract and title info based on the Contracts projectkey
**
**  Auth: Alan Katzen
**  Date: April 23 2018
**
***********************************************************************************************************************
**	Change History
***********************************************************************************************************************
**	Date      Author  Description
**	--------  ------  -----------
**********************************************************************************************************************/
BEGIN
  DECLARE 
    @v_taqprojectkey	INT,
    @v_work_itemtype INT,
    @v_work_usageclass INT,
    @v_masterwork_usageclass INT,
    @v_contract_itemtype INT
    
    IF coalesce(@i_taqprojectkey,0) = 0 BEGIN
      return
    END

    DECLARE @relatedprojectsinfo TABLE (
      taqprojectkey int null,
      relatedprojectkey int null,
      projectsearchitemcode int null,
      relatedprojectsearchitemcode int null,
      relatedprojectusageclasscode int null) 

    INSERT INTO @relatedprojectsinfo
    SELECT taqprojectkey, relatedprojectkey, projectsearchitemcode, relatedprojectsearchitemcode, relatedprojectusageclasscode
      FROM dbo.projectrelationshipview
     WHERE taqprojectkey = @i_taqprojectkey

    SELECT @v_contract_itemtype = gen.dataCode	FROM gentables gen WHERE gen.tableid = 550 AND gen.qsicode = 10
    SELECT @v_work_itemtype = gen.dataCode	FROM gentables gen WHERE gen.tableid = 550 AND gen.qsicode = 9
    SELECT @v_work_usageclass = sub.dataSubCode FROM subgentables sub WHERE sub.tableid = 550 AND sub.qsiCode = 28
    SELECT @v_masterwork_usageclass = sub.dataSubCode FROM subgentables sub WHERE sub.tableid = 550 AND sub.qsiCode = 53

    INSERT INTO @contractstitlestable
    SELECT DISTINCT pv.taqprojectkey contractprojectkey,pv.relatedprojectkey workprojectkey,
	    ct.bookkey,ct.printingkey,cp.projecttitle contractdisplayname, cp.projectparticipants contractparticipants,
	    cp.projecttypedesc contracttypedesc, cp.projectstatusdesc contractstatusdesc, 
	    cp.projectowner, cp.searchitemcode, cp.usageclasscode, COALESCE(cp.templateind,0) templateind, 
	    tpt.keyind, tpt.titlerolecode, dbo.get_gentables_desc(605,tpt.titlerolecode,'long') titleroledesc, 
	    ct.title, ct.productnumberx, ct.altproductnumberx, ct.authorname, ct.seasondesc, 
	    ct.formatname, ct.mediatypecode, ct.mediatypesubcode,
	    CONVERT(VARCHAR, ct.mediatypecode) + '|' + CONVERT(VARCHAR,ct.mediatypesubcode) mediaformatkey, 
	    dbo.get_gentables_desc(314,ct.bisacstatuscode,'long') bisacstatusdesc,
	    ct.productnumber, tpt.primaryformatind
    FROM taqproject tp
        LEFT OUTER JOIN @relatedprojectsinfo pv ON tp.taqprojectkey = pv.taqprojectkey
        LEFT OUTER JOIN titlemasterworkview tmw ON tmw.workprojectkey = pv.relatedprojectkey 
        JOIN coretitleinfo ct ON ct.bookkey = tmw.bookkey AND ct.printingkey = 1
        LEFT OUTER JOIN coreprojectinfo cp ON cp.projectkey = pv.taqprojectkey
        LEFT OUTER JOIN taqprojecttitle tpt ON tpt.taqprojectkey = pv.relatedprojectkey and tpt.bookkey = ct.bookkey
    WHERE pv.projectsearchitemcode = @v_contract_itemtype -- Contract
	    AND pv.relatedprojectsearchitemcode = @v_work_itemtype -- Work
	    AND tmw.titleworksearchitemcode = @v_work_itemtype -- Work
	    AND tmw.titleworkusageclasscode = @v_work_usageclass -- Works
	    AND COALESCE(tmw.masterworkprojectkey,0) > 0
	    AND tmw.masterworksearchitemcode = @v_work_itemtype  --  Work
	    AND tmw.masterworkusageclasscode = @v_masterwork_usageclass  -- Master Work
	    AND tp.taqprojectkey = @i_taqprojectkey


    INSERT INTO @contractstitlestable
    SELECT DISTINCT pv.taqprojectkey contractprojectkey,pv.relatedprojectkey workprojectkey,
	    ct.bookkey,ct.printingkey,cp.projecttitle contractdisplayname, cp.projectparticipants contractparticipants,
	    cp.projecttypedesc contracttypedesc, cp.projectstatusdesc contractstatusdesc, 
	    cp.projectowner, cp.searchitemcode, cp.usageclasscode, COALESCE(cp.templateind,0) templateind, 
	    tpt.keyind, tpt.titlerolecode, dbo.get_gentables_desc(605,tpt.titlerolecode,'long') titleroledesc, 
	    ct.title, ct.productnumberx, ct.altproductnumberx, ct.authorname, ct.seasondesc, 
	    ct.formatname, ct.mediatypecode, ct.mediatypesubcode,
	    CONVERT(VARCHAR, ct.mediatypecode) + '|' + CONVERT(VARCHAR,ct.mediatypesubcode) mediaformatkey, 
	    dbo.get_gentables_desc(314,ct.bisacstatuscode,'long') bisacstatusdesc,
	    ct.productnumber, tpt.primaryformatind
    FROM taqproject tp
        LEFT OUTER JOIN @relatedprojectsinfo pv ON tp.taqprojectkey = pv.taqprojectkey
        LEFT OUTER JOIN titlemasterworkview tmw ON tmw.workprojectkey = pv.relatedprojectkey 
        JOIN coretitleinfo ct ON ct.bookkey = tmw.bookkey AND ct.printingkey = 1
        LEFT OUTER JOIN coreprojectinfo cp ON cp.projectkey = pv.taqprojectkey
        LEFT OUTER JOIN taqprojecttitle tpt ON tpt.taqprojectkey = pv.relatedprojectkey and tpt.bookkey = ct.bookkey
    WHERE pv.projectsearchitemcode = @v_contract_itemtype -- Contract
	    AND pv.relatedprojectsearchitemcode = @v_work_itemtype -- Work
	    AND tmw.titleworksearchitemcode = @v_work_itemtype -- Work
	    AND tmw.titleworkusageclasscode = @v_work_usageclass -- Works
	    AND COALESCE(tmw.masterworkprojectkey,0) = 0
	    AND tp.taqprojectkey = @i_taqprojectkey


    INSERT INTO @contractstitlestable
    SELECT DISTINCT tp.taqprojectkey contractprojectkey, tmw.workprojectkey workprojectkey,
        ct.bookkey, ct.printingkey, tp.taqprojecttitle contractdisplayname, cp.projectparticipants contractparticipants,
        cp.projecttypedesc contracttypedesc, cp.projectstatusdesc AS contractstatusdesc,
        cp.projectowner, cp.searchitemcode, cp.usageclasscode, COALESCE(cp.templateind,0) templateind,
        tpt.keyind, tpt.titlerolecode, dbo.get_gentables_desc(605,tpt.titlerolecode,'long') titleroledesc,
        ct.title, ct.productnumberx, ct.altproductnumberx, ct.authorname, ct.seasondesc,
        ct.formatname, ct.mediatypecode, ct.mediatypesubcode,
        CONVERT(VARCHAR,ct.mediatypecode) + '|' + CONVERT(VARCHAR,ct.mediatypesubcode) mediaformatkey,
        dbo.get_gentables_desc(314,ct.bisacstatuscode,'long') bisacstatusdesc,
        ct.productnumber, tpt.primaryformatind
    FROM taqproject tp --Contract
        JOIN @relatedprojectsinfo pv ON tp.taqprojectkey = pv.taqprojectkey
        JOIN titlemasterworkview tmw ON pv.relatedprojectkey = tmw.Masterworkprojectkey
        LEFT OUTER JOIN taqprojecttitle tpt ON tpt.taqprojectkey = pv.relatedprojectkey
        JOIN coretitleinfo ct ON tmw.bookkey = ct.bookkey
        JOIN coreprojectinfo cp on tp.taqprojectkey = cp.projectkey
    WHERE pv.projectsearchitemcode = @v_contract_itemtype -- Contract
	    AND pv.relatedprojectsearchitemcode = @v_work_itemtype -- Master Work
	    AND pv.relatedprojectusageclasscode = @v_masterwork_usageclass -- Master Work
	    AND tmw.titleworksearchitemcode = @v_work_itemtype -- Work
	    AND tmw.titleworkusageclasscode = @v_work_usageclass -- Works
	    AND COALESCE(tmw.masterworkprojectkey,0) <> 0
	    AND tp.taqprojectkey = @i_taqprojectkey

    RETURN
END
GO

GRANT SELECT ON dbo.qcontract_contractstitlesinfo TO PUBLIC
GO