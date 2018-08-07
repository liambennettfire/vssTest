if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_participants_by_role') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_participants_by_role
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qtitle_get_participants_by_role
 (@i_userkey     integer,
  @i_bookkey     integer,
  @i_printingkey integer,
  @i_itemtype    integer,
  @i_usageclass  integer,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS

/******************************************************************************
**  Name: qtitle_get_participants_by_role
**  Desc: This stored procedure gets all the particpants for the title and
**        which participant section they should display in
**
**  Auth: Alan Katzen
**  Date: 28 June 2017
**
********************************************************************************
**  Change History
********************************************************************************
**  Date:      Author:   Description:
**  --------   ------    -------------------------------------------
**  5/3/18	   Dustin	 TM-375 - Tasks for Participant By Role section
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE @v_error_var    INT,
		  @v_rowcount_var INT,
		  @v_datetypecode INT,
		  @v_relateddatacode INT,
		  @v_sortorder SMALLINT
		  
		  
  CREATE TABLE #participantcontactroleinfo (
    bookkey int null,
    printingkey int null,
    indicator1 tinyint null,    
	indicator2 int null, 
    bookcontactkey int null,
    relateddatacode int null,
    datacode int null,
    keyind tinyint null,
    sortorder smallint null,
    globalcontactkey int null,
    addresskey int NULL ,
    participantnote varchar(2000) NULL ,
    displayname varchar(255) NULL ,
    email varchar(100) NULL ,
    phone varchar(100) NULL ,
    contactkey int NULL ,
    rolecode smallint NULL ,
    globalcontactrelationshipkey int NULL ,
    taqversionformatkey int null,
    quantity int NULL ,
    shippingmethodcode INT NULL,
    contactactiveind INT NULL,
    indicator tinyint NULL,
    newsortorder smallint NULL,
	generictext VARCHAR(50) NULL,
    datetypecode int null,
	taqtaskkey INT NULL)  
		  
  -- exec qutl_trace 'qtitle_get_participants_by_role', '@i_projectkey', @i_projectkey, NULL,
  --                  '@i_datacode', @i_datacode, NULL, '@i_itemtype', @i_itemtype, NULL, '@i_usageclass', @i_usageclass
  	 	   
  --SELECT @v_datetypecode = (SELECT top(1) relateddatacode 
		--									FROM gentablesitemtype 
		--									WHERE tableid = 636 
		--										AND datacode = @i_datacode 
		--										AND datasubcode = 11 
		--										AND itemtypecode = @i_itemtype 
		--										AND itemtypesubcode IN (0, @i_usageclass) ORDER BY itemtypesubcode desc)
  

  SET @v_error_var = 0
  SET @v_rowcount_var = 0
  
  --get Participant by Role information for the Section
  INSERT INTO  #participantcontactroleinfo
  SELECT *, dbo.qutl_get_related_taqtaskkey(q.datetypecode, NULL, globalcontactkey, rolecode, NULL, @i_bookkey, @i_printingkey) as taqtaskkey
  FROM
  (
  SELECT bc.bookkey, bc.printingkey, COALESCE (i.indicator1, 0) as indicator1, COALESCE (i.indicator2, 0) as indicator2, bc.bookcontactkey, i.relateddatacode, g.datacode, bc.keyind, bc.sortorder, 
   		 bc.globalcontactkey, bc.addresskey, bc.participantnote, COALESCE(c.displayname, '') as displayname, c.email, c.phone, c.contactkey, 
	     r.rolecode, r.globalcontactrelationshipkey, 0 taqversionformatkey, r.quantity, 0 shippingmethodcode, COALESCE(gc.activeind, 0) as contactactiveind,
       COALESCE (r.indicator, 0) as indicator, bc.sortorder as newsortorder, r.generictext,
       (SELECT top(1) relateddatacode 
											FROM gentablesitemtype 
											WHERE tableid = 636 
												AND datacode = COALESCE((select numericdesc1 from gentables where tableid = 663 and datacode = i.relateddatacode), 16) 
												AND datasubcode = 11 
												AND itemtypecode = @i_itemtype 
												AND itemtypesubcode IN (0, @i_usageclass) ORDER BY itemtypesubcode desc) as datetypecode
	FROM  gentablesitemtype AS i INNER JOIN
		  gentables AS g ON i.tableid = g.tableid AND i.datacode = g.datacode LEFT OUTER JOIN
		  bookcontact AS bc LEFT OUTER JOIN
		  corecontactinfo AS c ON bc.globalcontactkey = c.contactkey LEFT OUTER JOIN
		  globalcontact AS gc ON bc.globalcontactkey = gc.globalcontactkey INNER JOIN
		  bookcontactrole AS r ON bc.bookcontactkey = r.bookcontactkey ON g.datacode = r.rolecode
	WHERE (g.tableid = 285) AND (i.itemtypecode = @i_itemtype) AND (i.itemtypesubcode IN (0, @i_usageclass))
		   --AND (COALESCE (i.relateddatacode , 0) = @v_relateddatacode)
       AND (bc.bookkey = @i_bookkey AND bc.printingkey = @i_printingkey)
  ) q
  ORDER BY newsortorder, displayname
  	
  DELETE FROM #participantcontactroleinfo WHERE COALESCE(globalcontactkey, 0) = 0 AND indicator1 = 0
  SELECT @v_sortorder = MAX(COALESCE(newsortorder, 0)) FROM #participantcontactroleinfo
  
  UPDATE #participantcontactroleinfo
  SET @v_sortorder = newsortorder = @v_sortorder + 1     
  WHERE newsortorder IS  NULL AND COALESCE(globalcontactkey, 0) = 0
    
	SELECT 
	 t.bookkey,
   t.printingkey,
	 t.bookcontactkey, 
   COALESCE((select numericdesc1 from gentables where tableid = 663 and datacode = t.relateddatacode),16) sectiondatacode, 
 	 t.displayname,
	 t.indicator1,
	 t.indicator2,
	 t.datacode as rolecode, 
   t.keyind, 		 
	 COALESCE (t.newsortorder, 0) AS sortorder, 
	 t.globalcontactkey, 
	 t.addresskey, 
	 t.globalcontactrelationshipkey,
   0 taqversionformatkey,
   '' taqversionformatdesc,
	 t.quantity, 
	 t.email, 
	 t.phone, 
	 COALESCE (t.indicator, 0) AS indicator,
	 t.generictext,
	 t.datetypecode,
	 0 shippingmethodcode,
   t.contactactiveind,	
		(SELECT TOP 1 activedate 
		 FROM taqprojecttask 
		 WHERE taqtaskkey = t.taqtaskkey) AS activedate,
	 t.taqtaskkey,	 
	 t.participantnote, 
	 Case WHEN COALESCE(t.globalcontactrelationshipkey, 0) > 0 THEN
	      (SELECT top(1) v.relatedcontactkey 
											FROM globalcontactrelationshipview v
											WHERE v.globalcontactrelationshipkey = t.globalcontactrelationshipkey AND
												  v.globalcontactkey = t.globalcontactkey)
 		  ELSE 0 
 		  END as relatedcontactkey,		
	 Case WHEN COALESCE(t.globalcontactrelationshipkey, 0) >= 0 THEN
	      (SELECT top(1) COALESCE(v.relatedcontactname, '') 
					FROM globalcontactrelationshipview v
					WHERE v.globalcontactrelationshipkey = t.globalcontactrelationshipkey AND
						  v.globalcontactkey = t.globalcontactkey)
 		  ELSE '' 
 		  END as relateddisplayname,
	dbo.qcontact_is_contact_private(t.contactkey, @i_userkey) AS isprivate		  
	FROM  #participantcontactroleinfo t
	ORDER BY t.newsortorder, t.displayname
    
  -- Save the @@v_eRROR and @@v_rOWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @v_error_var = @@ERROR, @v_rowcount_var = @@ROWCOUNT
  IF @v_error_var <> 0 or @v_rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing taqprojectcontact: bookkey = ' + cast(@i_bookkey AS VARCHAR) + '/printingkey = ' + cast(@i_printingkey AS VARCHAR)
  END 
  
  DROP TABLE #participantcontactroleinfo

GO

GRANT EXEC ON qtitle_get_participants_by_role TO PUBLIC
GO


