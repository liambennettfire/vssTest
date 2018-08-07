set nocount on

/******************************************************************************
**  Name: imp_cr8_subgentables
**  Desc: IKE definitions for all elements
**  Auth: Bennett
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
**  5/24/2016    Kusum       Case 37305 Fix rows so titlehistory written
**                           correctly for esttrimsize fields
**  5/24/2016    Kusum       Case 36771 BICSubjectCategories (tableid = 668)
*******************************************************************************/

/* remove all generic elements */
DELETE FROM  imp_element_defs
  WHERE elementkey >= 100000000
    AND elementkey <= 100099999
GO
-- remove rouge element
delete from imp_element_defs where elementkey=1000224010
go


/*  filler element used to ignore imp columns*/
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100000000,'ignore item - do not import','ignore',NULL,NULL,NULL,null,null,NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO

/*  pre-process elements*/
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100000010,'Insert ISBN Prefixes','Insert_ISBN_Prefixes',NULL,NULL,NULL,null,null,NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO

/* Product Numbers */
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010000,'ISBN','ISBN',NULL,NULL,NULL,'isbn','isbn',NULL,NULL,NULL,'bookkey','qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010001,'ISBN10','ISBN10',NULL,NULL,NULL,'isbn','isbn10',NULL,NULL,NULL,'bookkey','qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010002,'EAN','EAN',NULL,NULL,NULL,'isbn','ean',NULL,NULL,NULL,'bookkey','qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010003,'EAN13','EAN13',NULL,NULL,NULL,'isbn','ean13',NULL,NULL,NULL,'bookkey','qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010004,'UPC','UPC',NULL,NULL,NULL,'isbn','UPC',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010006,'LCCN','LCCN',NULL,NULL,NULL,'isbn','LCCN',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO


INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010007,'Item Number','ItemNo',NULL,NULL,NULL,'isbn','itemnumber',NULL,NULL,NULL,'bookkey','qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010008,'non-critical ISBN','ISBN_NC',NULL,NULL,NULL,'isbn','isbn',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010009,'non-critical EAN','EAN_NC',NULL,NULL,NULL,'isbn','EAN',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010010,'non-critical EAN13','EAN13_NC',NULL,NULL,NULL,'isbn','EAN13',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010011,'Title Leadkey present','LEADKEY_VERF',NULL,NULL,NULL,null,null,NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010013,'Title must exist','TitleMustExist',NULL,NULL,NULL,null,null,NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010014,'ProductID type','ProductIDtype',null,NULL,NULL,'isbn',null,NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010015,'ProductID value','ProductIDValue',null,NULL,NULL,'isbn',null,NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010017,'Related Product Code','RelatedProductCode',null,NULL,NULL,'isbn',null,NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010018,'Related ProductID type','RelatedProductIDtype',null,NULL,NULL,'isbn',null,NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010019,'Related ProductID value','RelatedProductIDValue',null,NULL,NULL,'isbn',null,NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010020,'Related Product Release to Eloquence Indicator','RelatedProductRel2EloInd',null,NULL,NULL,NULL,null,NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010021,'Replaced by ISBN','Replaced_by_ISBN',null,NULL,NULL,'associatedtitle','isbn',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010022,'Replaces ISBN','Replaced_ISBN',null,NULL,NULL,'associatedtitles','isbn',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010024,'Remove Assoc Titles not on import','AssocTitle_remove',null,NULL,NULL,'associatedtitles','isbn',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010025,'Remove all ISBNs','Remove_ISBN',null,NULL,NULL,'associatedtitles','isbn',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010041,'Propigate Title','PropigateTitle',null,NULL,NULL,null,null,NULL,NULL,NULL,null,'fire',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010046,'Title from Template','TitleTemplate',null,NULL,NULL,null,null,NULL,NULL,NULL,null,'fire',GETDATE(),null,null,null)
GO


/*element definitions for Generic associated title */
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010026,'Generic associated title (1) - uses addlqualifier in template','AssocTitle_1_Gen',null,NULL,NULL,'associatedtitles','isbn',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010126,'Generic associated title pubdate(1) - uses addlqualifier in template','AssocTitlePubdate_1_Gen',null,NULL,NULL,'associatedtitles','pubdate',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010226,'Generic associated title Title(1) - uses addlqualifier in template','AssocTitle_1_Gen_Title',null,NULL,NULL,'associatedtitles','title',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010326,'Generic associated title Author(1) - uses addlqualifier in template','AssocTitle_1_Gen_Author',null,NULL,NULL,'associatedtitles','authorname',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO


INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010426,'Generic associated title Bisacstatus(1) - uses addlqualifier in template','AssocTitle_1_Gen_Bisacstatus',null,NULL,NULL,'associatedtitles','Bisacstatus',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO--mk2012.11.03> Case 21832 Develop IKE Import Elements for Importing Additional Associate
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010526,'Generic associated title Media(1) - uses addlqualifier in template','AssocTitle_1_Gen_Media',null,NULL,NULL,'associatedtitles','media',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO--mk2012.11.03> Case 21832 Develop IKE Import Elements for Importing Additional Associate
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010626,'Generic associated title Format(1) - uses addlqualifier in template','AssocTitle_1_Gen_Format',null,NULL,NULL,'associatedtitles','format',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO--mk2012.11.03> Case 21832 Develop IKE Import Elements for Importing Additional Associate
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010726,'Generic associated title Price(1) - uses addlqualifier in template','AssocTitle_1_Gen_Price',null,NULL,NULL,'associatedtitles','price',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO--mk2012.11.03> Case 21832 Develop IKE Import Elements for Importing Additional Associate

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010027,'Generic associated title (2) - uses addlqualifier in template','AssocTitle_2_Gen',null,NULL,NULL,'associatedtitles','isbn',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010127,'Generic associated title pubdate(2) - uses addlqualifier in template','AssocTitlePubdate_2_Gen',null,NULL,NULL,'associatedtitles','pubdate',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010227,'Generic associated title Title(2) - uses addlqualifier in template','AssocTitle_2_Gen_Title',null,NULL,NULL,'associatedtitles','title',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010327,'Generic associated title Author(2) - uses addlqualifier in template','AssocTitle_2_Gen_Author',null,NULL,NULL,'associatedtitles','authorname',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010427,'Generic associated title Bisacstatus(2) - uses addlqualifier in template','AssocTitle_2_Gen_Bisacstatus',null,NULL,NULL,'associatedtitles','Bisacstatus',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO--mk2012.11.03> Case 21832 Develop IKE Import Elements for Importing Additional Associate
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010527,'Generic associated title Media(2) - uses addlqualifier in template','AssocTitle_2_Gen_Media',null,NULL,NULL,'associatedtitles','media',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO--mk2012.11.03> Case 21832 Develop IKE Import Elements for Importing Additional Associate
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010627,'Generic associated title Format(2) - uses addlqualifier in template','AssocTitle_2_Gen_Format',null,NULL,NULL,'associatedtitles','format',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO--mk2012.11.03> Case 21832 Develop IKE Import Elements for Importing Additional Associate
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010727,'Generic associated title Price(2) - uses addlqualifier in template','AssocTitle_2_Gen_Price',null,NULL,NULL,'associatedtitles','price',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO--mk2012.11.03> Case 21832 Develop IKE Import Elements for Importing Additional Associate

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010028,'Generic associated title (3) - uses addlqualifier in template','AssocTitle_3_Gen',null,NULL,NULL,'associatedtitles','isbn',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010128,'Generic associated title pubdate(3) - uses addlqualifier in template','AssocTitlePubdate_3_Gen',null,NULL,NULL,'associatedtitles','pubdate',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010228,'Generic associated title Title(3) - uses addlqualifier in template','AssocTitle_3_Gen_Title',null,NULL,NULL,'associatedtitles','title',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010328,'Generic associated title Author(3) - uses addlqualifier in template','AssocTitle_3_Gen_Author',null,NULL,NULL,'associatedtitles','authorname',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010428,'Generic associated title Bisacstatus(3) - uses addlqualifier in template','AssocTitle_3_Gen_Bisacstatus',null,NULL,NULL,'associatedtitles','Bisacstatus',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO--mk2012.11.03> Case 21832 Develop IKE Import Elements for Importing Additional Associate
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010528,'Generic associated title Media(3) - uses addlqualifier in template','AssocTitle_3_Gen_Media',null,NULL,NULL,'associatedtitles','media',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO--mk2012.11.03> Case 21832 Develop IKE Import Elements for Importing Additional Associate
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010628,'Generic associated title Format(3) - uses addlqualifier in template','AssocTitle_3_Gen_Format',null,NULL,NULL,'associatedtitles','format',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO--mk2012.11.03> Case 21832 Develop IKE Import Elements for Importing Additional Associate
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010728,'Generic associated title Price(3) - uses addlqualifier in template','AssocTitle_3_Gen_Price',null,NULL,NULL,'associatedtitles','price',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO--mk2012.11.03> Case 21832 Develop IKE Import Elements for Importing Additional Associate

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010029,'Generic associated title (4) - uses addlqualifier in template','AssocTitle_4_Gen',null,NULL,NULL,'associatedtitles','isbn',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010129,'Generic associated title pubdate(4) - uses addlqualifier in template','AssocTitlePubdate_4_Gen',null,NULL,NULL,'associatedtitles','pubdate',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010229,'Generic associated title Title(4) - uses addlqualifier in template','AssocTitle_4_Gen_Title',null,NULL,NULL,'associatedtitles','title',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010329,'Generic associated title Author(4) - uses addlqualifier in template','AssocTitle_4_Gen_Author',null,NULL,NULL,'associatedtitles','authorname',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010429,'Generic associated title Bisacstatus(4) - uses addlqualifier in template','AssocTitle_4_Gen_Bisacstatus',null,NULL,NULL,'associatedtitles','Bisacstatus',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO--mk2012.11.03> Case 21832 Develop IKE Import Elements for Importing Additional Associate
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010529,'Generic associated title Media(4) - uses addlqualifier in template','AssocTitle_4_Gen_Media',null,NULL,NULL,'associatedtitles','media',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO--mk2012.11.03> Case 21832 Develop IKE Import Elements for Importing Additional Associate
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010629,'Generic associated title Format(4) - uses addlqualifier in template','AssocTitle_4_Gen_Format',null,NULL,NULL,'associatedtitles','format',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO--mk2012.11.03> Case 21832 Develop IKE Import Elements for Importing Additional Associate
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010729,'Generic associated title Price(4) - uses addlqualifier in template','AssocTitle_4_Gen_Price',null,NULL,NULL,'associatedtitles','price',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO--mk2012.11.03> Case 21832 Develop IKE Import Elements for Importing Additional Associate

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010031,'Generic associated title (5) - uses addlqualifier in template','AssocTitle_5_Gen',null,NULL,NULL,'associatedtitles','isbn',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010131,'Generic associated title pubdate(5) - uses addlqualifier in template','AssocTitlePubdate_5_Gen',null,NULL,NULL,'associatedtitles','pubdate',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010231,'Generic associated title Title(5) - uses addlqualifier in template','AssocTitle_5_Gen_Title',null,NULL,NULL,'associatedtitles','title',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010331,'Generic associated title Author(5) - uses addlqualifier in template','AssocTitle_5_Gen_Author',null,NULL,NULL,'associatedtitles','authorname',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010431,'Generic associated title Bisacstatus(5) - uses addlqualifier in template','AssocTitle_5_Gen_Bisacstatus',null,NULL,NULL,'associatedtitles','Bisacstatus',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO--mk2012.11.03> Case 21832 Develop IKE Import Elements for Importing Additional Associate
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010531,'Generic associated title Media(5) - uses addlqualifier in template','AssocTitle_5_Gen_Media',null,NULL,NULL,'associatedtitles','media',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO--mk2012.11.03> Case 21832 Develop IKE Import Elements for Importing Additional Associate
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010631,'Generic associated title Format(5) - uses addlqualifier in template','AssocTitle_5_Gen_Format',null,NULL,NULL,'associatedtitles','format',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO--mk2012.11.03> Case 21832 Develop IKE Import Elements for Importing Additional Associate
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010731,'Generic associated title Price(5) - uses addlqualifier in template','AssocTitle_5_Gen_Price',null,NULL,NULL,'associatedtitles','price',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO--mk2012.11.03> Case 21832 Develop IKE Import Elements for Importing Additional Associate

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010030,'Workkey','WorkkeyFromEAN',null,NULL,NULL,'book','workkey',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO


INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010032,'Associated Title Type SubGentables Ext','AssocTitle_Type_SubGenX',null,NULL,NULL,null,null,NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010033,'Associated Title ISBN SubGentables Ext','AssocTitle_ISBN_SubGenX',null,NULL,NULL,'associatedtitles','isbn',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010035,'Workkey ONIX IDType','Workkey_ONIX_IDType',null,NULL,NULL,null,null,NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010036,'Workkey ONIX IDvalue','Workkey_ONIX_IDvalue',null,NULL,NULL,null,null,NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100010151,'Additional Data Mapping (addlqualifier = elementkey,mapkey)','AddlMapping01',null,NULL,NULL,null,null,NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO


/*  GROUP (ORG) LEVEL Elements*/

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100011011,'Organizational Group Level 1','OrgGroup1',NULL,NULL,NULL,'orgentry','orgentrydesc',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100011012,'Organizational Group Level 2','OrgGroup2',NULL,NULL,NULL,'orgentry','orgentrydesc',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100011013,'Organizational Group Level 3','OrgGroup3',NULL,NULL,NULL,'orgentry','orgentrydesc',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100011014,'Organizational Group Level 4','OrgGroup4',NULL,NULL,NULL,'orgentry','orgentrydesc',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100011015,'Organizational Group Level 5','OrgGroup5',NULL,NULL,NULL,'orgentry','orgentrydesc',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100011016,'Organizational Group Level 6','OrgGroup6',NULL,NULL,NULL,'orgentry','orgentrydesc',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100011017,'Organizational Group Level 7','OrgGroup7',NULL,NULL,NULL,'orgentry','orgentrydesc',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100011018,'Organizational Group Level 8','OrgGroup8',NULL,NULL,NULL,'orgentry','orgentrydesc',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100011019,'Organizational Group Level 9','OrgGroup9',NULL,NULL,NULL,'orgentry','orgentrydesc',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100011020,'OrgGroupValidator','OrgGroupValidator',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs (elementkey, elementdesc, elementmnemonic, tableid, datacode, datasubcode, destinationtable, destinationcolumn, datetypecode, lobind, importnullind, leadkeyname, lastuserid, lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100011021, 'OrgGroupUpdater', 'OrgGroupUpdater', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'qsi_xt', GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100011025,'Bottom Org Level to project All','BaseOrgLevel',NULL,NULL,NULL,'orgentry','orgentrydesc',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100011026,'Bottom Org Level to project All using Altdesc1','BaseOrgLevelAltdesc1',NULL,NULL,NULL,'orgentry','orgentrydesc',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO


INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100011135,'Verify Title for Eloquence feed','ELOFeedVerf',NULL,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'fire',GETDATE(),null,null,null)
GO

/*  TITLE INFO	*/
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012000,'CopyTitleTemplate','Copy Title Template Options',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null,'fire',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100012001,'Announced1stPrintActual' ,'Actual Announced 1st Printing',NULL,NULL,NULL,'printing','announcedfirstprint',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go

--INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES(100012002,'CanadianRestrictionCode' ,'Canadian Restrictions Code',NULL,NULL,NULL,'printing','announcedfirstprint',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100012003,'CanadianRestriction' ,'Canadian Restrictions',NULL,NULL,NULL,'bookdetail','canadianrestrictioncode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012004,'Carton Quantity','CartonQty',NULL,NULL,NULL,'bindingspecs','cartonqty1',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012007,'Full Author Display Name','FullAuthorDisplayName',NULL,NULL,NULL,'bookdetail','fullauthordisplayname',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100012008,'InsertIllusActual' ,'Actual Insert/Illustration',NULL,NULL,NULL,'printing','actualinsertillus',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100012009,'InsertIllusEstimated' ,'Estimated Insert/Illustration',NULL,NULL,NULL,'printing','estimatedinsertillus',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES(100012011,'EpubTypeCode' ,'EpubTypeCode',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES(100012012,'OtherFormatCode' ,'Other Format Code',300,NULL,NULL,'booksimon','formatchildcode',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES(100012013,'OtherFormatDesc' ,'Other Format Description',300,NULL,NULL,'booksimon','formatchildcode',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
go
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100012014,'Actual Page Count','PagesActual',NULL,NULL,NULL,'printing','pagecount',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--GO
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100012015,'Projected Sales','ProjectedSales',NULL,NULL,NULL,'printing',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012016,'Pub Month and Year from Pub Date','PubMonthYear',NULL,NULL,NULL,'printing','multiples',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012017,'Pub Month','PubMonth',NULL,NULL,NULL,'printing','pubmonthcode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012018,'Pub Year','PubYear',NULL,NULL,NULL,'printing','pubmonth',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012019,'Actual Release Quantity','ReleasQtyActual',NULL,NULL,NULL,'printing','firstprintingqty',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012020,'Estimated Release Quantity','ReleasQtyEst',NULL,NULL,NULL,'printing','tentativeqty',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012021,'Actual Season','SeasonActual',329,NULL,NULL,'printing','seasonkey',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012022,'Estimated Season','SeasonEst',329,NULL,NULL,'printing','estseasonkey',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012023,'Send to Eloquence','SendtoElo',NULL,NULL,NULL,'book','sendtoeloind',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012024,'Short Title','ShortTitle',NULL,NULL,NULL,'book','shorttitle',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012025,'Spine Size','SpineSize',NULL,NULL,NULL,'book','shorttitle',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012026,'SubTitle','SubTitle',NULL,NULL,NULL,'book','subtitle',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012027,'Title','Title',NULL,NULL,NULL,'book','title',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012028,'Title Prefix','TitlePrefix',NULL,NULL,NULL,'bookdetail','titleprefix',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100012029,'Actual Trim Length','TrimLengthActual',NULL,NULL,NULL,'book','title',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012030,'Estimated Trim Length','TrimLengthEst',NULL,NULL,NULL,'printing','esttrimsizelength',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100012031,'Actual Trim Width','TimWidthActual',NULL,NULL,NULL,'book','title',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012032,'Estimated Trim Width','TrimWidthEst',NULL,NULL,NULL,'printing','esttrimsizewidth',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012033,'ONIX: TitleType','OnixTitleType',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012034,'ONIX: TitlePrefix','OnixTitlePrefix',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012035,'ONIX: TitleWithoutPrefix','OnixTitleWithoutPrefix',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012036,'ONIX: TitleText','OnixTitleText',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012037,'Page Count (Actual Page Count)','PageCount',NULL,NULL,NULL,'printing','pagecount',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012038,'Pages (Actual Page Count)','Pages',NULL,NULL,NULL,'printing','pagecount',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012041,'Estimated Page Count','PagesEstimated',NULL,NULL,NULL,'printing','tentativepagecount',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012042,'Runtime','Runtime',NULL,NULL,NULL,'booksimon','booksimon',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012043,'Barcode Type','Barcode1Type',552,NULL,NULL,'printing','barcodeid1',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012044,'Barcode Position','Barcode1Position',552,NULL,NULL,'printing','barcodeposition1',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012045,'Onix Measurement type code','MeasureTypeCode',NULL,NULL,NULL,'printing','trimsizewidth',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012046,'Onix Measurement','Measurement',NULL,NULL,NULL,'printing','trimsizewidth',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012047,'Onix Measure Unit Code	','MeasureUnitCode',NULL,NULL,NULL,'printing','trimsizewidth',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012048,'Trim Width (Actual)','Width',NULL,NULL,NULL,'printing','trimsizewidth',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012049,'Trim Length (Actual)','Length',NULL,NULL,NULL,'printing','trimsizelength',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012050,'Format' ,'Fomat',312,NULL,NULL,'bookdetail','mediatypesubcode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012051,'Media' ,'Media',312,NULL,NULL,'bookdetail','mediatypecode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

delete from imp_element_defs where elementkey=110012050
delete from imp_element_defs where elementkey=110012051
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (110012050,'MediaFormatPair_Format' ,'MediaFormatPair_Format',312,NULL,NULL,'bookdetail','mediatypesubcode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (110012051,'MediaFormatPair_Media' ,'MediaFormatPair_Media',312,NULL,NULL,'bookdetail','mediatypecode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO


INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012052,'Announced1stPrintEst' ,'Estimated Announced 1st Printing',NULL,NULL,NULL,'printing','estannouncedfirstprint',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012053,'FormatChildNode' ,'FormatChildNode',NULL,NULL,NULL,'booksimon','formatchildnode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012055,'FormatsConcat' ,'Format names concatenated',312,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012057,'RemoveMedia' ,'Removes Media element based on values in mapping',312,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012058,'TrimUnitMeasure' ,'Trimesize unit of measure',613,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012059,'SpineUnitMeasure' ,'Spinesize unit of measure',613,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012060,'BookWeightUnitMeasure' ,'BookWeightsize unit of measure',613,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100012061,'BookWeightValue','Book Weight Value',NULL,NULL,NULL,'printing','bookweight',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100012062,'BookWeight','Book Weight',NULL,NULL,NULL,'printing','bookweightunitofmeassure',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100012063,'AgeLow','Age Low',NULL,NULL,NULL,'bookdetail','agelow',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100012064,'AgeHigh','Age High',NULL,NULL,NULL,'bookdetail','ageHigh',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100012065,'AgeLowUpind','Age Low and up indicator',NULL,NULL,NULL,'bookdetail','agelowupind',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100012066,'AgeHighUpind','Age High and up indicator',NULL,NULL,NULL,'bookdetail','ageHighupind',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100012077,'AllAgeInd','All Age indicator',NULL,NULL,NULL,'bookdetail','allagesind',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100012067,'AudienceRangeQualifier','ONIX AudienceRangeQualifier: age or grade indicator ',NULL,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100012068,'AudienceRangePrecision','ONIX AudienceRangePrecision: from ,to or exact ',NULL,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100012069,'AudienceRangeValue','ONIX AudienceRange: age or grade ',NULL,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100012167,'XML_Explicit_AudienceRangeQualifier','XML_Explicit_AudienceRangeQualifier: age or grade indicator ',NULL,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100012168,'XML_Explicit_AudienceRangePrecision','XML_Explicit_AudienceRangePrecision: from ,to or exact ',NULL,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100012169,'XML_Explicit_AudienceRangeValue','XML_Explicit_AudienceRange: age or grade ',NULL,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

--mk20130926> adding code so that this sproc imp_100012167002 can work in table as well as xml explicit mode
-- ... the issue is that a table wouldn't have elementOrdinals within a sequence
-- ... the table should have DISTINCT 5 fields in it whereas the XML only has 3 DISTINCT where 2 repeat
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100012170,'XML_Explicit_AudienceRangePrecision2','XML_Explicit_AudienceRangePrecision2: from ,to or exact ',NULL,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100012171,'XML_Explicit_AudienceRangeValue2','XML_Explicit_AudienceRange2: age or grade ',NULL,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100012070,'Copyright','Copy Right Year',NULL,NULL,NULL,'bookdetail','copyrightyear',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100012071,'GradeLow','Grade Low',NULL,NULL,NULL,'bookdetail','gradelow',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100012072,'GradeHigh','Grade High',NULL,NULL,NULL,'bookdetail','gradelow',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100012073,'GradeLowUpind','Grade Low and up indicator',NULL,NULL,NULL,'bookdetail','gradelowupind',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100012074,'GradeHighUpind','Grade High and up indicator',NULL,NULL,NULL,'bookdetail','gradelowupind',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012075,'TitleSplit','Title break out prefix and short ttile',NULL,NULL,NULL,'book','shorttitle',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012076,'Title Status','titlestatus',149,NULL,NULL,'book','titlestatuscode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012080,'boardthickness','board thickness',NULL,NULL,NULL,'casespecs','boardthickness',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012085,'qtyreceived','quantity received',NULL,NULL,NULL,'printing','qtyreceived',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012090,'projectedsales','projected sales',NULL,NULL,NULL,'printing','projectedsales',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012091,'Barcode 2 Type','Barcode2Type',552,NULL,NULL,'printing','barcodeid2',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100012092,'Barcode 2 Position','Barcode2Position',552,NULL,NULL,'printing','barcodeposition2',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
GO
/*  Price */
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013000,'PriceMaintenance','PriceMaintenance',NULL,NULL,NULL,'bookprice',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013009,'USRetailPriceFinal' ,'Final US Retail Price',NULL,8,6,'bookprice','finalprice',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013010,'USRetailPriceBudget' ,'Budget US Retail Price',NULL,8,6,'bookprice','budgetprice',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013011,'USRetailPriceEffDate' ,'US Retail Price Effective Date',NULL,8,6,'bookprice','effectivedate',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013012,'UKRetailPriceFinal' ,'Final UK Retail Price',NULL,8,37,'bookprice','finalprice',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013013,'UKRetailPriceBudget' ,'Budget UK Retail Price',NULL,8,37,'bookprice','budgetprice',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013014,'UKRetailPriceEffDate' ,'UK Retail Price Effective Date',NULL,8,37,'bookprice','effectivedate',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013015,'CanadianRetailPriceFinal' ,'Final Canadian Retail Price',NULL,8,11,'bookprice','finalprice',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013016,'CanadianRetailPriceBudget' ,'Budget Canadian Retail Price',NULL,8,11,'bookprice','budgetprice',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013017,'CanadianRetailPriceEffDate' ,'Canadian Retail Price Effective Date',NULL,8,11,'bookprice','effectivedate',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013018,'AustralianRetailPriceFinal' ,'Final Australian Retail Price',NULL,8,13,'bookprice','finalprice',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013019,'AustralianRetailPriceBudget' ,'Budget Australian Retail Price',NULL,8,13,'bookprice','budgetprice',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013020,'AustralianRetailPriceEffDate' ,'Australian Retail Price Effective Date',NULL,8,13,'bookprice','effectivedate',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013021,'bookprice_all' ,'Book price - budget and final price',NULL,null,null,'bookprice','multiple',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013022,'bookprice_budget' ,'Book price - budget price',NULL,null,null,'bookprice','budgetprice',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013023,'bookprice_final' ,'Book price - final price',NULL,null,null,'bookprice','finalprice',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013024,'bookprice_pricetype' ,'Book price - price type',306,null,null,'bookprice','pricetypecode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013025,'bookprice_pricetypecode' ,'Book price - price type code',306,null,null,'bookprice','pricetypecode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013026,'bookprice_currtype' ,'Book price - currency type',122,null,null,'bookprice','currencytypecode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013027,'bookprice_currtypecode' ,'Book price - currency type',122,null,null,'bookprice','currencytypecode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013028,'bookprice_effdate' ,'Book price - effective date',null,null,null,'bookprice','effectivedate',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013031,'USretailprice_exp' ,'US retail price (expanded)',122,null,null,'bookprice','currencytypecode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013032,'CanadianRetailPrice_exp' ,'Canadian retail price (expanded)',122,null,null,'bookprice','currencytypecode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013033,'GBRetailPrice_exp' ,'Great Briton retail price (expanded)',122,null,null,'bookprice','currencytypecode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013034,'EURetailPrice_exp' ,'EU retail price (expanded)',122,null,null,'bookprice','currencytypecode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013035,'EURetailPriceFinal','Final EU Retail Price',NULL,8,38,'bookprice','finalprice',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),1,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013041,'USRetailFinalFilter' ,'Final US Retail Price w/price type from filter',NULL,8,11,'bookprice','finalprice',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100013042,'CanadianRetailFinalFilter' ,'Final Canadian Retail Price w/price type from filter',NULL,8,11,'bookprice','finalprice',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
go



INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013051,'Generic price 1: addlqualifier (pricetype code, currencytype code, price desc)','price_01_generic',null,NULL,NULL,'bookprice',NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013052,'Generic price 2: addlqualifier (pricetype code, currencytype code, price desc)','price_02_generic',null,NULL,NULL,'bookprice',NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013053,'Generic price 3: addlqualifier (pricetype code, currencytype code, price desc)','price_03_generic',null,NULL,NULL,'bookprice',NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013054,'Generic price 4: addlqualifier (pricetype code, currencytype code, price desc)','price_04_generic',null,NULL,NULL,'bookprice',NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013055,'Generic price 5: addlqualifier (pricetype code, currencytype code, price desc)','price_05_generic',null,NULL,NULL,'bookprice',NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013056,'Generic price 6: addlqualifier (pricetype code, currencytype code, price desc)','price_06_generic',null,NULL,NULL,'bookprice',NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013057,'Generic price 7: addlqualifier (pricetype code, currencytype code, price desc)','price_07_generic',null,NULL,NULL,'bookprice',NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013058,'Generic price 8: addlqualifier (pricetype code, currencytype code, price desc)','price_08_generic',null,NULL,NULL,'bookprice',NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013059,'Generic price 9: addlqualifier (pricetype code, currencytype code, price desc)','price_09_generic',null,NULL,NULL,'bookprice',NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013060,'Generic price 10: addlqualifier (pricetype code, currencytype code, price desc)','price_10_generic',null,NULL,NULL,'bookprice',NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013061,'Generic price 11: addlqualifier (pricetype code, currencytype code, price desc)','price_11_generic',null,NULL,NULL,'bookprice',NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013062,'Generic price 12: addlqualifier (pricetype code, currencytype code, price desc)','price_12_generic',null,NULL,NULL,'bookprice',NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013063,'Generic price 13: addlqualifier (pricetype code, currencytype code, price desc)','price_13_generic',null,NULL,NULL,'bookprice',NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013064,'Generic price 14: addlqualifier (pricetype code, currencytype code, price desc)','price_14_generic',null,NULL,NULL,'bookprice',NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013065,'Generic price 15: addlqualifier (pricetype code, currencytype code, price desc)','price_15_generic',null,NULL,NULL,'bookprice',NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013066,'Generic price 16: addlqualifier (pricetype code, currencytype code, price desc)','price_16_generic',null,NULL,NULL,'bookprice',NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013067,'Generic price 17: addlqualifier (pricetype code, currencytype code, price desc)','price_17_generic',null,NULL,NULL,'bookprice',NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013068,'Generic price 18: addlqualifier (pricetype code, currencytype code, price desc)','price_18_generic',null,NULL,NULL,'bookprice',NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013069,'Generic price 19: addlqualifier (pricetype code, currencytype code, price desc)','price_19_generic',null,NULL,NULL,'bookprice',NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100013070,'Generic price 20: addlqualifier (pricetype code, currencytype code, price desc)','price_20_generic',null,NULL,NULL,'bookprice',NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

/*  Title Class */
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014008,'Discount Code','DiscountCode',359,NULL,NULL,'bookdetail','discountcode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014009,'Discount Description','DiscountDesc',359,NULL,NULL,'bookdetail','discountcode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014041,'NumCassettes','Number of cassettes',NULL,NULL,NULL,'audiocassettespecs','numcassettes',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014042,'totalruntime','Total run time of cassettes',NULL,NULL,NULL,'audiocassettespecs','totalruntime',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014046,'TitleTypeCode','Title Type Code',132,NULL,NULL,'book','titletypecode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100014049,'VolumeNumber' ,'Book Volume Number',NULL,NULL,NULL,'bookdetail','volumenumber',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014050,'Restrictions','Restrictions',320,NULL,NULL,'bookdetail','restrictioncode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014051,'Series Description','SeriesDesc',327,NULL,NULL,'bookdetail','seriescode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014052,'Discount','Discount',459,NULL,NULL,'bookdetail','discountcode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
 VALUES (100014053,'SecondaryLanguage','Secondary Language',318,NULL,NULL,'bookdetail','languagecode2',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
 VALUES (100014054,'Language','Language',318,NULL,NULL,'bookdetail','languagecode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014055,'Edition','Edition',200,NULL,NULL,'bookdetail','editioncode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100014056,'Returns','Returns',319,NULL,NULL,'bookdetail','returncode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014057,'Bisac Status','BisacStatus',314,NULL,NULL,'bookdetail','bisacstatusscode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014058,'Territories','Territories',131,NULL,NULL,'bookdetail','territoriescode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014059,'Product availability using BisacStatus','prodavailability',314,NULL,NULL,'bookdetail','prodavailability',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014061,'SeriesInsert','Series with Inserts into User Tables',327,NULL,NULL,'bookdetail','seriescode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014062,'DiscountInsert','Discount with Inserts into User Tables',459,NULL,NULL,'bookdetail','discountcode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014065,'EditionInsert','Edition with Inserts into User Tables',200,NULL,NULL,'bookdetail','editioncode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014066,'AdditionalEdition','Additional Edition',null,NULL,NULL,'bookdetail','additionaleditinfo',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014067,'EditionNumber','Edition Number',557,NULL,NULL,'bookdetail','Editionnumber',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
 VALUES (100014070,'LanguageExternalCode','Language external code',318,NULL,NULL,'bookdetail','languagecode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014071,'Bisac Status external code','BisacStatusExternalCode',314,NULL,NULL,'bookdetail','bisacstatusscode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014072,'SeriesExternalcode','Series by externalcode',327,NULL,NULL,'bookdetail','seriescode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014073,'OriginExternalcode','Origin by externalcode',315,NULL,NULL,'bookdetail','origincode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014081,'VerificationStatus','VerificationStatus',513,NULL,NULL,'bookverification','verificationtypecode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100014082,'INSERTVerificationStatus','INSERTVerificationStatus',NULL,NULL,NULL,'bookverification','verificationtypecode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go


INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100014091, 'TerritoryList', 'TerritoryList', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'fire',GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100014092, 'TerritoryTemplate', 'TerritoryTemplate', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'fire',GETDATE(),null,null,null)


insert into imp_element_defs (elementkey,elementmnemonic,elementdesc,lastuserid,lastmaintdate,lobind,importnullind) values
		('100014096','Territories_EXCLUSIVE','TerritoriesTable_EXCLUSIVE','fb_imp',getdate(),1,1)
insert into imp_element_defs (elementkey,elementmnemonic,elementdesc,lastuserid,lastmaintdate,lobind) values
		('100014097','Territories_NONEXCLUSIVE','Territories_NONEXCLUSIVE','fb_imp',getdate(),1)
insert into imp_element_defs (elementkey,elementmnemonic,elementdesc,lastuserid,lastmaintdate,lobind) values
		('100014098','Territories_NOTFORSALE','Territories_NOTFORSALE','fb_imp',getdate(),1)
insert into imp_element_defs (elementkey,elementmnemonic,elementdesc,lastuserid,lastmaintdate) values
		('100014103','Territories_DESC','Territories_DESC','fb_imp',getdate())

/*  Title Audiences	*/
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100016001,'Book Audience','Audience',460,NULL,NULL,'bookaudience','audiencecode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100016002,'Book Audience (remove)','AudienceRemove',460,NULL,NULL,'bookaudience','audiencecode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100016101,'Book Category','BookCategory',317,NULL,NULL,'bookcategory','categorycode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100017000,'Bisac Subject Initial','BisacSubjectInitial',339,NULL,NULL,'bookbisaccategory','multiple',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100017001,'Bisac Subject Code','BisacSubjectCode',339,NULL,NULL,'bookbisaccategory','multiple',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
GO
/* mk>2012.04.17 */
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100017002,'mainsubject_ind','mainsubject_ind',null,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100017011,'Book/Bisac Subject split - SubjectSchemeIdentifier','SubjectSchemeIdentifier_split',null,NULL,NULL,'bookbisacCategory','multiple',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100017012,'Book/Bisac Subject split - SubjectSchemeName','SubjectSchemeName_split',null,NULL,NULL,'bookbisacCategory','multiple',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100017013,'Book/Bisac Subject split - SubjectHeadingText','SubjectHeadingText_split',null,NULL,NULL,'bookbisacCategory','multiple',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100017014,'Book/Bisac Subject split - SubjectCode','SubjectCode_split',null,NULL,NULL,'bookbisacCategory','multiple',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100017201,'BIC/Bisac Subject type load','BIC_BISAC_type',null,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100017202,'BIC/Bisac Subject code load','BIC_BISAC_code',null,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go

--------------------------------------------------------------
/*BOOK SUBJECT CATEGORY ELEMENTS*/
-------------------------------------------------------------

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018001,'Subject1Category','Subject Category Type 1',412,NULL,NULL,'booksubjectcategory','externalcode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018002,'Subject2Category','Subject Category Type 2',413,NULL,NULL,'booksubjectcategory','externalcode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018003,'Subject3Category','Subject Category Type 3',414,NULL,NULL,'booksubjectcategory','externalcode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018004,'Subject4Category','Subject Category Type 4',431,NULL,NULL,'booksubjectcategory','externalcode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018005,'Subject5Category','Subject Category Type 5',432,NULL,NULL,'booksubjectcategory','externalcode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018006,'Subject6Category','Subject Category Type 6',433,NULL,NULL,'booksubjectcategory','externalcode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018007,'Subject7Category','Subject Category Type 7',434,NULL,NULL,'booksubjectcategory','externalcode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018008,'Subject8Category','Subject Category Type 8',435,NULL,NULL,'booksubjectcategory','externalcode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018009,'Subject9Category','Subject Category Type 9',436,NULL,NULL,'booksubjectcategory','externalcode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018010,'Subject10Category','Subject Category Type 10',437,NULL,NULL,'booksubjectcategory','externalcode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018011,'Subject1CategoryDesc','Subject Category Type 1 by Desc',412,NULL,NULL,'booksubjectcategory','datadesc',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018012,'Subject2CategoryDesc','Subject Category Type 2 by Desc',413,NULL,NULL,'booksubjectcategory','datadesc',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018013,'Subject3CategoryDesc','Subject Category Type 3 by Desc',414,NULL,NULL,'booksubjectcategory','datadesc',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018014,'Subject4CategoryDesc','Subject Category Type 4 by Desc',431,NULL,NULL,'booksubjectcategory','datadesc',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018015,'Subject5CategoryDesc','Subject Category Type 5 by Desc',432,NULL,NULL,'booksubjectcategory','datadesc',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018016,'Subject6CategoryDesc','Subject Category Type 6 by Desc',433,NULL,NULL,'booksubjectcategory','datadesc',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018017,'Subject7CategoryDesc','Subject Category Type 7 by Desc',434,NULL,NULL,'booksubjectcategory','datadesce',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018018,'Subject8CategoryDesc','Subject Category Type 8 by Desc',435,NULL,NULL,'booksubjectcategory','datadesc',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018019,'Subject9CategoryDesc','Subject Category Type 9 by Desc',436,NULL,NULL,'booksubjectcategory','datadesc',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018020,'Subject10CategoryDesc','Subject Category Type 10 by Desc',437,NULL,NULL,'booksubjectcategory','datadesc',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go




INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018101,'Subject1SubCategoryDesc','Subject Category Type 1 by Desc (subgentables)',558,NULL,NULL,'booksubjectcategory','datadesc',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go


--------------------------------------------------------------
/*BIC SUBJECT CATEGORY ELEMENTS*/
--------------------------------------------------------------
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018021,'BICSubjectsCategoryDesc','BIC Subject Category by Desc',668,NULL,NULL,'booksubjectcategory','datadesc',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100018022,'BICSubjectsCategory','BIC Subject Category',668,NULL,NULL,'booksubjectcategory','externalcode',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go


-------------------------------------------------------------
/*  BOOK DATE ELEMENT SET*/
-------------------------------------------------------------
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020000,'DateTypeInsert', 'Date Type Insert',NULL,NULL,NULL,'bookdates','multiple',NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020001,'BBDateActual', 'Actual Bound Book',NULL,NULL,NULL,'bookdates','activedate',30,NULL,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020002,'BBDateEstimated', 'Estimated Bound Book',NULL,NULL,NULL,'bookdates','estdate',30,NULL,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020003,'OnSaleDateActual', 'Actual On Sale Date',NULL,NULL,NULL,'bookdates','activedate',20003,NULL,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020004,'OnSaleDateEstimated', 'Estimated On Sale Date',NULL,NULL,NULL,'bookdates','estdate',20003,NULL,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020005,'PubDateActual', 'Actual Pub',NULL,NULL,NULL,'bookdates','activedate',8,NULL,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020006,'PubDateEstimated', 'Estimated Pub Date',NULL,NULL,NULL,'bookdates','estdate',8,NULL,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020007,'RelDateActual', 'Actual Release Date',NULL,NULL,NULL,'bookdates','activedate',32,NULL,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020008,'RelDateEstimated', 'Estimated Release Date',NULL,NULL,NULL,'bookdates','estdate',32,NULL,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020009,'WhsDateActual', 'Actual Wareshouse Date',NULL,NULL,NULL,'bookdates','activedate',47,NULL,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020010,'WhsDateEstimated', 'Estimated Warehouse Date',NULL,NULL,NULL,'bookdates','estdate',47,NULL,null,'qsi_xt',GETDATE(),1,null,null)
go

/*
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020011,'StockDueDateActual', 'Actual Stock Due Date',NULL,NULL,NULL,'bookdates',null,447,NULL,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020012,'StockDueDateEstimated', 'Estimated Stock Due Date',NULL,NULL,NULL,'bookdates',null,447,NULL,null,'qsi_xt',GETDATE(),null,null,null)
*/
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020013,'ShipDateActual', 'Actual Ship Date',NULL,NULL,NULL,'bookdates','activedate',309,NULL,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020014,'ShipDateEstimated', 'Estimated Ship Date',NULL,NULL,NULL,'bookdates','estdate',309,NULL,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020015,'EmbargoDataDateActual', 'Actual Embargo Data Date',NULL,NULL,NULL,'bookdates','activedate',429,NULL,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020016,'EmbargoDataSaleActual', 'Actual Embargo Sale Date',NULL,NULL,NULL,'bookdates','activedate',20012,NULL,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020017,'LastDateReturnsActual', 'Actual Last Date Returns',NULL,NULL,NULL,'bookdates','activedate',309,NULL,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020018,'ExpectedReceiptDate', 'Actual Expected ReceiptDate',NULL,NULL,NULL,'bookdates','activedate',431,NULL,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020019,'LastReceiptDateActual', 'Actual Last Receipt Date',NULL,NULL,NULL,'bookdates','activedate',430,NULL,null,'qsi_xt',GETDATE(),1,null,null)
go


INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020101,'GenericDate01', 'Generic date update 1 (uses addlqualifier in template)',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020102,'GenericDate02', 'Generic date update 2 (uses addlqualifier in template)',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020103,'GenericDate03', 'Generic date update 3 (uses addlqualifier in template)',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020104,'GenericDate04', 'Generic date update 4 (uses addlqualifier in template)',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020105,'GenericDate05', 'Generic date update 5 (uses addlqualifier in template)',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020106,'GenericDate06', 'Generic date update 6 (uses addlqualifier in template)',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020107,'GenericDate07', 'Generic date update 7 (uses addlqualifier in template)',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020108,'GenericDate08', 'Generic date update 8 (uses addlqualifier in template)',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020109,'GenericDate09', 'Generic date update 9 (uses addlqualifier in template)',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020110,'GenericDate10', 'Generic date update 10 (uses addlqualifier in template)',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020111,'GenericDate11', 'Generic date update 11 (uses addlqualifier in template)',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020112,'GenericDate12', 'Generic date update 12 (uses addlqualifier in template)',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020113,'GenericDate13', 'Generic date update 13 (uses addlqualifier in template)',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020114,'GenericDate14', 'Generic date update 14 (uses addlqualifier in template)',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020115,'GenericDate15', 'Generic date update 15 (uses addlqualifier in template)',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020116,'GenericDate16', 'Generic date update 16 (uses addlqualifier in template)',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020201,'GenericDate01_newtitle', 'Generic date update 1 (uses addlqualifier in template) new title only',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020202,'GenericDate02_newtitle', 'Generic date update 2 (uses addlqualifier in template) new title only',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020203,'GenericDate03_newtitle', 'Generic date update 3 (uses addlqualifier in template) new title only',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020204,'GenericDate04_newtitle', 'Generic date update 4 (uses addlqualifier in template) new title only',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100020205,'GenericDate05_newtitle', 'Generic date update 5 (uses addlqualifier in template) new title only',NULL,NULL,NULL,'bookdates',null,null,'qsi_xt',GETDATE(),null,null,null)

-------------------------------------------------------------
/*  BOOK COMMENT ELEMENT SET*/
-------------------------------------------------------------

/*  Author Bio Commnet*/
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100022001,'Author Bio Comments','AuthorBioComment',284,3,10,'bookcomments','commenttext',NULL,1,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO

/*  Brief Description*/
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100022002,'Brief Description','BriefDescription',284,3,7,'bookcomments','commenttext',NULL,1,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO

/*  Catalog Body Copy*/
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100022003,'Catalog Body Copy','CatalogBodyCopy',284,3,1,'bookcomments','commenttext',NULL,1,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO

/*  Catalog Bullets*/
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100022004,'Catalog Bullets','CatalogBullets',284,NULL,NULL,'bookcomments','commenttext',NULL,1,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO

/*  Catalog Quotes*/
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100022005,'Catalog Quotes','CatalogQuotes',284,3,28,'bookcomments','commenttext',NULL,1,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO

/*  Description  */
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100022006,'Book Description','BookDescription',284,3,8,'bookcomments','commenttext',NULL,1,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO

/*  Excerpt  */
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100022007,'Excerpt','Excerpt',284,3,16,'bookcomments','commenttext',NULL,1,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO

/*  Sales Handle  */
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100022008,'Sales Handle','SalesHandle',284,1,25,'bookcomments','commenttext',NULL,1,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO

/*  Table of Contents */
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100022009,'Table of Contents','TableofContents',284,3,23,'bookcomments','commenttext',NULL,1,NULL,NULL,'qsi_xt',GETDATE(),1,null,null)
GO

--INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES(100022010,'AudienceForBook','Audience for the Book',284,3,9,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022011,'AuthorComments','Author Comments',284,3,18,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022012,'AuthorResidence','Author Residence',284,3,31,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022013,'BackPanelCopy','Back Panel Copy',284,3,3,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022014,'ComparisonCompetition','Comparison/Competition',284,1,12,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022015,'InsideFlapCopy','Inside Flap Copy',284,3,2,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022016,'KeySellingPoint1','Key Selling Point 1',284,1,9,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022017,'KeySellingPoint2','Key Selling Point 2',284,1,10,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022018,'KeySellingPoint3','Key Selling Point 3',284,1,11,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022019,'KeyNote','Key Note',284,3,24,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022020,'MarketingNotes','Marketing Notes',284,1,4,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022021,'MarketingObjective','Marketing Objective',284,1,5,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022022,'MarketingStrategy','Marketing Strategy',284,1,6,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022023,'PubDateTieIn','Pub Date Tie In',284,1,14,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022024,'Publicity','Publicity',284,1,24,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022025,'PublisherComments','Publisher Comments',284,1,19,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022026,'Quote1','Quote 1',284,3,4,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022027,'Quote2','Quote 2',284,3,5,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022028,'Quote3','Quote 3',284,3,6,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022029,'Quote4','Quote 4',284,3,45,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022030,'Quote5','Quote 5',284,3,46,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022031,'Quote6','Quote 6',284,3,47,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022032,'Quote7','Quote 7',284,3,48,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022033,'Websitecomment','Website comment',284,1,36,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022034,'AudienceRestrictionNote','Audience Restriction Note',284,3,43,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022035,'EditionStatement','Edition Statement',284,3,42,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022100,'BookComment_3_11','BookComment typecode 3, subtypecode 11',284,3,11,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022101,'BookComment_3_5','BookComment typecode 3, subtypecode 5',284,3,5,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022102,'BookComment_3_6','BookComment typecode 3, subtypecode 6',284,3,6,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022103,'BookComment_3_40','BookComment typecode 3, subtypecode 40',284,3,40,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)


INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022104,'BookComment_1_1','BookComment typecode 1, subtypecode 1',284,1,1,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022105,'BookComment_1_2','BookComment typecode 1, subtypecode 2',284,1,2,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022106,'BookComment_1_3','BookComment typecode 1, subtypecode 3',284,1,3,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022107,'BookComment_1_4','BookComment typecode 1, subtypecode 4',284,1,4,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022108,'BookComment_1_5','BookComment typecode 1, subtypecode 5',284,1,5,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022109,'BookComment_1_6','BookComment typecode 1, subtypecode 6',284,1,6,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022110,'BookComment_1_7','BookComment typecode 1, subtypecode 7',284,1,7,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022111,'BookComment_1_8','BookComment typecode 1, subtypecode 8',284,1,8,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022112,'BookComment_1_9','BookComment typecode 1, subtypecode 9',284,1,9,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022113,'BookComment_1_10','BookComment typecode 1, subtypecode 10',284,1,10,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022114,'BookComment_1_11','BookComment typecode 1, subtypecode 11',284,1,11,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022115,'BookComment_1_12','BookComment typecode 1, subtypecode 12',284,1,12,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022116,'BookComment_1_13','BookComment typecode 1, subtypecode 13',284,1,13,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022117,'BookComment_1_14','BookComment typecode 1, subtypecode 14',284,1,14,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022118,'BookComment_1_15','BookComment typecode 1, subtypecode 15',284,1,15,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022119,'BookComment_1_16','BookComment typecode 1, subtypecode 16',284,1,16,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022120,'BookComment_1_17','BookComment typecode 1, subtypecode 17',284,1,17,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022121,'BookComment_1_18','BookComment typecode 1, subtypecode 18',284,1,18,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022122,'BookComment_1_19','BookComment typecode 1, subtypecode 19',284,1,19,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022123,'BookComment_1_20','BookComment typecode 1, subtypecode 20',284,1,20,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022124,'BookComment_1_21','BookComment typecode 1, subtypecode 21',284,1,21,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022125,'BookComment_1_22','BookComment typecode 1, subtypecode 22',284,1,22,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022126,'BookComment_1_23','BookComment typecode 1, subtypecode 23',284,1,23,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022127,'BookComment_1_24','BookComment typecode 1, subtypecode 24',284,1,24,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022128,'BookComment_1_25','BookComment typecode 1, subtypecode 25',284,1,25,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022129,'BookComment_1_26','BookComment typecode 1, subtypecode 26',284,1,26,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022130,'BookComment_1_27','BookComment typecode 1, subtypecode 27',284,1,27,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022131,'BookComment_1_28','BookComment typecode 1, subtypecode 28',284,1,28,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022132,'BookComment_1_29','BookComment typecode 1, subtypecode 29',284,1,29,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022133,'BookComment_1_30','BookComment typecode 1, subtypecode 30',284,1,30,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022134,'BookComment_1_31','BookComment typecode 1, subtypecode 31',284,1,31,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022135,'BookComment_1_32','BookComment typecode 1, subtypecode 32',284,1,32,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022136,'BookComment_1_33','BookComment typecode 1, subtypecode 33',284,1,33,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022137,'BookComment_1_34','BookComment typecode 1, subtypecode 34',284,1,34,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022138,'BookComment_1_35','BookComment typecode 1, subtypecode 35',284,1,35,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022139,'BookComment_1_36','BookComment typecode 1, subtypecode 36',284,1,36,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022140,'BookComment_1_37','BookComment typecode 1, subtypecode 37',284,1,37,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022141,'BookComment_1_38','BookComment typecode 1, subtypecode 38',284,1,38,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022142,'BookComment_1_39','BookComment typecode 1, subtypecode 39',284,1,39,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022143,'BookComment_1_40','BookComment typecode 1, subtypecode 40',284,1,40,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022144,'BookComment_1_41','BookComment typecode 1, subtypecode 41',284,1,41,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022145,'BookComment_1_42','BookComment typecode 1, subtypecode 42',284,1,42,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022146,'BookComment_1_43','BookComment typecode 1, subtypecode 43',284,1,43,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022147,'BookComment_1_44','BookComment typecode 1, subtypecode 44',284,1,44,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022148,'BookComment_1_45','BookComment typecode 1, subtypecode 45',284,1,45,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022149,'BookComment_1_46','BookComment typecode 1, subtypecode 46',284,1,46,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022150,'BookComment_1_47','BookComment typecode 1, subtypecode 47',284,1,47,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022151,'BookComment_1_48','BookComment typecode 1, subtypecode 48',284,1,48,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022152,'BookComment_1_49','BookComment typecode 1, subtypecode 49',284,1,49,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022153,'BookComment_1_50','BookComment typecode 1, subtypecode 50',284,1,50,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022154,'BookComment_1_51','BookComment typecode 1, subtypecode 51',284,1,51,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022155,'BookComment_1_52','BookComment typecode 1, subtypecode 52',284,1,52,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022156,'BookComment_1_53','BookComment typecode 1, subtypecode 53',284,1,53,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022157,'BookComment_1_54','BookComment typecode 1, subtypecode 54',284,1,54,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022158,'BookComment_1_55','BookComment typecode 1, subtypecode 55',284,1,55,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022159,'BookComment_1_56','BookComment typecode 1, subtypecode 56',284,1,56,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022160,'BookComment_1_57','BookComment typecode 1, subtypecode 57',284,1,57,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022161,'BookComment_1_58','BookComment typecode 1, subtypecode 58',284,1,58,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022162,'BookComment_1_59','BookComment typecode 1, subtypecode 59',284,1,59,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022163,'BookComment_1_60','BookComment typecode 1, subtypecode 60',284,1,60,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022164,'BookComment_1_61','BookComment typecode 1, subtypecode 61',284,1,61,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022165,'BookComment_1_62','BookComment typecode 1, subtypecode 62',284,1,62,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022166,'BookComment_1_63','BookComment typecode 1, subtypecode 63',284,1,63,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022167,'BookComment_1_64','BookComment typecode 1, subtypecode 64',284,1,64,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022168,'BookComment_1_65','BookComment typecode 1, subtypecode 65',284,1,65,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022169,'BookComment_1_66','BookComment typecode 1, subtypecode 66',284,1,66,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022170,'BookComment_1_67','BookComment typecode 1, subtypecode 67',284,1,67,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022171,'BookComment_1_68','BookComment typecode 1, subtypecode 68',284,1,68,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022172,'BookComment_1_69','BookComment typecode 1, subtypecode 69',284,1,69,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022173,'BookComment_1_70','BookComment typecode 1, subtypecode 70',284,1,70,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022174,'BookComment_1_71','BookComment typecode 1, subtypecode 71',284,1,71,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022175,'BookComment_1_72','BookComment typecode 1, subtypecode 72',284,1,72,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022176,'BookComment_1_73','BookComment typecode 1, subtypecode 73',284,1,73,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022177,'BookComment_1_74','BookComment typecode 1, subtypecode 74',284,1,74,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022178,'BookComment_1_75','BookComment typecode 1, subtypecode 75',284,1,75,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022179,'BookComment_1_76','BookComment typecode 1, subtypecode 76',284,1,76,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022180,'BookComment_1_77','BookComment typecode 1, subtypecode 77',284,1,77,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022181,'BookComment_1_78','BookComment typecode 1, subtypecode 78',284,1,78,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022182,'BookComment_1_79','BookComment typecode 1, subtypecode 79',284,1,79,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022183,'BookComment_1_80','BookComment typecode 1, subtypecode 80',284,1,80,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022184,'BookComment_1_81','BookComment typecode 1, subtypecode 81',284,1,81,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022185,'BookComment_1_82','BookComment typecode 1, subtypecode 82',284,1,82,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022186,'BookComment_1_83','BookComment typecode 1, subtypecode 83',284,1,83,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022187,'BookComment_1_84','BookComment typecode 1, subtypecode 84',284,1,84,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022188,'BookComment_1_85','BookComment typecode 1, subtypecode 85',284,1,85,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022189,'BookComment_1_86','BookComment typecode 1, subtypecode 86',284,1,86,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022190,'BookComment_1_87','BookComment typecode 1, subtypecode 87',284,1,87,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022191,'BookComment_1_88','BookComment typecode 1, subtypecode 88',284,1,88,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022192,'BookComment_1_89','BookComment typecode 1, subtypecode 89',284,1,89,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022193,'BookComment_1_90','BookComment typecode 1, subtypecode 90',284,1,90,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022194,'BookComment_1_91','BookComment typecode 1, subtypecode 91',284,1,91,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022195,'BookComment_1_92','BookComment typecode 1, subtypecode 92',284,1,92,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022196,'BookComment_1_93','BookComment typecode 1, subtypecode 93',284,1,93,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022197,'BookComment_1_94','BookComment typecode 1, subtypecode 94',284,1,94,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022198,'BookComment_1_95','BookComment typecode 1, subtypecode 95',284,1,95,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022199,'BookComment_1_96','BookComment typecode 1, subtypecode 96',284,1,96,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022200,'BookComment_1_97','BookComment typecode 1, subtypecode 97',284,1,97,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022201,'BookComment_1_98','BookComment typecode 1, subtypecode 98',284,1,98,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022202,'BookComment_1_99','BookComment typecode 1, subtypecode 99',284,1,99,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022203,'BookComment_3_1','BookComment typecode 3, subtypecode 1',284,3,1,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022204,'BookComment_3_2','BookComment typecode 3, subtypecode 2',284,3,2,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022205,'BookComment_3_3','BookComment typecode 3, subtypecode 3',284,3,3,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022206,'BookComment_3_4','BookComment typecode 3, subtypecode 4',284,3,4,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022209,'BookComment_3_7','BookComment typecode 3, subtypecode 7',284,3,7,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022210,'BookComment_3_8','BookComment typecode 3, subtypecode 8',284,3,8,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022211,'BookComment_3_9','BookComment typecode 3, subtypecode 9',284,3,9,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022212,'BookComment_3_10','BookComment typecode 3, subtypecode 10',284,3,10,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022214,'BookComment_3_12','BookComment typecode 3, subtypecode 12',284,3,12,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022215,'BookComment_3_13','BookComment typecode 3, subtypecode 13',284,3,13,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022216,'BookComment_3_14','BookComment typecode 3, subtypecode 14',284,3,14,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022217,'BookComment_3_15','BookComment typecode 3, subtypecode 15',284,3,15,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022218,'BookComment_3_16','BookComment typecode 3, subtypecode 16',284,3,16,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022219,'BookComment_3_17','BookComment typecode 3, subtypecode 17',284,3,17,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022220,'BookComment_3_18','BookComment typecode 3, subtypecode 18',284,3,18,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022221,'BookComment_3_19','BookComment typecode 3, subtypecode 19',284,3,19,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022222,'BookComment_3_20','BookComment typecode 3, subtypecode 20',284,3,20,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022223,'BookComment_3_21','BookComment typecode 3, subtypecode 21',284,3,21,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022224,'BookComment_3_22','BookComment typecode 3, subtypecode 22',284,3,22,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022225,'BookComment_3_23','BookComment typecode 3, subtypecode 23',284,3,23,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022226,'BookComment_3_24','BookComment typecode 3, subtypecode 24',284,3,24,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022227,'BookComment_3_25','BookComment typecode 3, subtypecode 25',284,3,25,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022228,'BookComment_3_26','BookComment typecode 3, subtypecode 26',284,3,26,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022229,'BookComment_3_27','BookComment typecode 3, subtypecode 27',284,3,27,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022230,'BookComment_3_28','BookComment typecode 3, subtypecode 28',284,3,28,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022231,'BookComment_3_29','BookComment typecode 3, subtypecode 29',284,3,29,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022232,'BookComment_3_30','BookComment typecode 3, subtypecode 30',284,3,30,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022233,'BookComment_3_31','BookComment typecode 3, subtypecode 31',284,3,31,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022234,'BookComment_3_32','BookComment typecode 3, subtypecode 32',284,3,32,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022235,'BookComment_3_33','BookComment typecode 3, subtypecode 33',284,3,33,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022236,'BookComment_3_34','BookComment typecode 3, subtypecode 34',284,3,34,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022237,'BookComment_3_35','BookComment typecode 3, subtypecode 35',284,3,35,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022238,'BookComment_3_36','BookComment typecode 3, subtypecode 36',284,3,36,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022239,'BookComment_3_37','BookComment typecode 3, subtypecode 37',284,3,37,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022240,'BookComment_3_38','BookComment typecode 3, subtypecode 38',284,3,38,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022241,'BookComment_3_39','BookComment typecode 3, subtypecode 39',284,3,39,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022243,'BookComment_3_41','BookComment typecode 3, subtypecode 41',284,3,41,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022244,'BookComment_3_42','BookComment typecode 3, subtypecode 42',284,3,42,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022245,'BookComment_3_43','BookComment typecode 3, subtypecode 43',284,3,43,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022246,'BookComment_3_44','BookComment typecode 3, subtypecode 44',284,3,44,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022247,'BookComment_3_45','BookComment typecode 3, subtypecode 45',284,3,45,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022248,'BookComment_3_46','BookComment typecode 3, subtypecode 46',284,3,46,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022249,'BookComment_3_47','BookComment typecode 3, subtypecode 47',284,3,47,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022250,'BookComment_3_48','BookComment typecode 3, subtypecode 48',284,3,48,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022251,'BookComment_3_49','BookComment typecode 3, subtypecode 49',284,3,49,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022252,'BookComment_3_50','BookComment typecode 3, subtypecode 50',284,3,50,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022253,'BookComment_3_51','BookComment typecode 3, subtypecode 51',284,3,51,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022254,'BookComment_3_52','BookComment typecode 3, subtypecode 52',284,3,52,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022255,'BookComment_3_53','BookComment typecode 3, subtypecode 53',284,3,53,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022256,'BookComment_3_54','BookComment typecode 3, subtypecode 54',284,3,54,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022257,'BookComment_3_55','BookComment typecode 3, subtypecode 55',284,3,55,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022258,'BookComment_3_56','BookComment typecode 3, subtypecode 56',284,3,56,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022259,'BookComment_3_57','BookComment typecode 3, subtypecode 57',284,3,57,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022260,'BookComment_3_58','BookComment typecode 3, subtypecode 58',284,3,58,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022261,'BookComment_3_59','BookComment typecode 3, subtypecode 59',284,3,59,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022262,'BookComment_3_60','BookComment typecode 3, subtypecode 60',284,3,60,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022263,'BookComment_3_61','BookComment typecode 3, subtypecode 61',284,3,61,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022264,'BookComment_3_62','BookComment typecode 3, subtypecode 62',284,3,62,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022265,'BookComment_3_63','BookComment typecode 3, subtypecode 63',284,3,63,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022266,'BookComment_3_64','BookComment typecode 3, subtypecode 64',284,3,64,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022267,'BookComment_3_65','BookComment typecode 3, subtypecode 65',284,3,65,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022268,'BookComment_3_66','BookComment typecode 3, subtypecode 66',284,3,66,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022269,'BookComment_3_67','BookComment typecode 3, subtypecode 67',284,3,67,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022270,'BookComment_3_68','BookComment typecode 3, subtypecode 68',284,3,68,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022271,'BookComment_3_69','BookComment typecode 3, subtypecode 69',284,3,69,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022272,'BookComment_3_70','BookComment typecode 3, subtypecode 70',284,3,70,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022273,'BookComment_3_71','BookComment typecode 3, subtypecode 71',284,3,71,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022274,'BookComment_3_72','BookComment typecode 3, subtypecode 72',284,3,72,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022275,'BookComment_3_73','BookComment typecode 3, subtypecode 73',284,3,73,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022276,'BookComment_3_74','BookComment typecode 3, subtypecode 74',284,3,74,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022277,'BookComment_3_75','BookComment typecode 3, subtypecode 75',284,3,75,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022278,'BookComment_3_76','BookComment typecode 3, subtypecode 76',284,3,76,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022279,'BookComment_3_77','BookComment typecode 3, subtypecode 77',284,3,77,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022280,'BookComment_3_78','BookComment typecode 3, subtypecode 78',284,3,78,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022281,'BookComment_3_79','BookComment typecode 3, subtypecode 79',284,3,79,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022282,'BookComment_3_80','BookComment typecode 3, subtypecode 80',284,3,80,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022283,'BookComment_3_81','BookComment typecode 3, subtypecode 81',284,3,81,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022284,'BookComment_3_82','BookComment typecode 3, subtypecode 82',284,3,82,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022285,'BookComment_3_83','BookComment typecode 3, subtypecode 83',284,3,83,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022286,'BookComment_3_84','BookComment typecode 3, subtypecode 84',284,3,84,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022287,'BookComment_3_85','BookComment typecode 3, subtypecode 85',284,3,85,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022288,'BookComment_3_86','BookComment typecode 3, subtypecode 86',284,3,86,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022289,'BookComment_3_87','BookComment typecode 3, subtypecode 87',284,3,87,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022290,'BookComment_3_88','BookComment typecode 3, subtypecode 88',284,3,88,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022291,'BookComment_3_89','BookComment typecode 3, subtypecode 89',284,3,89,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022292,'BookComment_3_90','BookComment typecode 3, subtypecode 90',284,3,90,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022293,'BookComment_3_91','BookComment typecode 3, subtypecode 91',284,3,91,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022294,'BookComment_3_92','BookComment typecode 3, subtypecode 92',284,3,92,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022295,'BookComment_3_93','BookComment typecode 3, subtypecode 93',284,3,93,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022296,'BookComment_3_94','BookComment typecode 3, subtypecode 94',284,3,94,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022297,'BookComment_3_95','BookComment typecode 3, subtypecode 95',284,3,95,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022298,'BookComment_3_96','BookComment typecode 3, subtypecode 96',284,3,96,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022299,'BookComment_3_97','BookComment typecode 3, subtypecode 97',284,3,97,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022300,'BookComment_3_98','BookComment typecode 3, subtypecode 98',284,3,98,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022301,'BookComment_3_99','BookComment typecode 3, subtypecode 99',284,3,99,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022302,'BookComment_4_1','BookComment typecode 4, subtypecode 1',284,4,1,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022303,'BookComment_4_2','BookComment typecode 4, subtypecode 2',284,4,2,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022304,'BookComment_4_3','BookComment typecode 4, subtypecode 3',284,4,3,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022305,'BookComment_4_4','BookComment typecode 4, subtypecode 4',284,4,4,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022306,'BookComment_4_5','BookComment typecode 4, subtypecode 5',284,4,5,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022307,'BookComment_4_6','BookComment typecode 4, subtypecode 6',284,4,6,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022308,'BookComment_4_7','BookComment typecode 4, subtypecode 7',284,4,7,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022309,'BookComment_4_8','BookComment typecode 4, subtypecode 8',284,4,8,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022310,'BookComment_4_9','BookComment typecode 4, subtypecode 9',284,4,9,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022311,'BookComment_4_10','BookComment typecode 4, subtypecode 10',284,4,10,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022312,'BookComment_4_11','BookComment typecode 4, subtypecode 11',284,4,11,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022313,'BookComment_4_12','BookComment typecode 4, subtypecode 12',284,4,12,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022314,'BookComment_4_13','BookComment typecode 4, subtypecode 13',284,4,13,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022315,'BookComment_4_14','BookComment typecode 4, subtypecode 14',284,4,14,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022316,'BookComment_4_15','BookComment typecode 4, subtypecode 15',284,4,15,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022317,'BookComment_4_16','BookComment typecode 4, subtypecode 16',284,4,16,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022318,'BookComment_4_17','BookComment typecode 4, subtypecode 17',284,4,17,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022319,'BookComment_4_18','BookComment typecode 4, subtypecode 18',284,4,18,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022320,'BookComment_4_19','BookComment typecode 4, subtypecode 19',284,4,19,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022321,'BookComment_4_20','BookComment typecode 4, subtypecode 20',284,4,20,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022322,'BookComment_4_21','BookComment typecode 4, subtypecode 21',284,4,21,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022323,'BookComment_4_22','BookComment typecode 4, subtypecode 22',284,4,22,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022324,'BookComment_4_23','BookComment typecode 4, subtypecode 23',284,4,23,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022325,'BookComment_4_24','BookComment typecode 4, subtypecode 24',284,4,24,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022326,'BookComment_4_25','BookComment typecode 4, subtypecode 25',284,4,25,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022327,'BookComment_4_26','BookComment typecode 4, subtypecode 26',284,4,26,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022328,'BookComment_4_27','BookComment typecode 4, subtypecode 27',284,4,27,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022329,'BookComment_4_28','BookComment typecode 4, subtypecode 28',284,4,28,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022330,'BookComment_4_29','BookComment typecode 4, subtypecode 29',284,4,29,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022331,'BookComment_4_30','BookComment typecode 4, subtypecode 30',284,4,30,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022332,'BookComment_4_31','BookComment typecode 4, subtypecode 31',284,4,31,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022333,'BookComment_4_32','BookComment typecode 4, subtypecode 32',284,4,32,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022334,'BookComment_4_33','BookComment typecode 4, subtypecode 33',284,4,33,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022335,'BookComment_4_34','BookComment typecode 4, subtypecode 34',284,4,34,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022336,'BookComment_4_35','BookComment typecode 4, subtypecode 35',284,4,35,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022337,'BookComment_4_36','BookComment typecode 4, subtypecode 36',284,4,36,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022338,'BookComment_4_37','BookComment typecode 4, subtypecode 37',284,4,37,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022339,'BookComment_4_38','BookComment typecode 4, subtypecode 38',284,4,38,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022340,'BookComment_4_39','BookComment typecode 4, subtypecode 39',284,4,39,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022341,'BookComment_4_40','BookComment typecode 4, subtypecode 40',284,4,40,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022342,'BookComment_4_41','BookComment typecode 4, subtypecode 41',284,4,41,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022343,'BookComment_4_42','BookComment typecode 4, subtypecode 42',284,4,42,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022344,'BookComment_4_43','BookComment typecode 4, subtypecode 43',284,4,43,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022345,'BookComment_4_44','BookComment typecode 4, subtypecode 44',284,4,44,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022346,'BookComment_4_45','BookComment typecode 4, subtypecode 45',284,4,45,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022347,'BookComment_4_46','BookComment typecode 4, subtypecode 46',284,4,46,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022348,'BookComment_4_47','BookComment typecode 4, subtypecode 47',284,4,47,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022349,'BookComment_4_48','BookComment typecode 4, subtypecode 48',284,4,48,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022350,'BookComment_4_49','BookComment typecode 4, subtypecode 49',284,4,49,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022351,'BookComment_4_50','BookComment typecode 4, subtypecode 50',284,4,50,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022352,'BookComment_4_51','BookComment typecode 4, subtypecode 51',284,4,51,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022353,'BookComment_4_52','BookComment typecode 4, subtypecode 52',284,4,52,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022354,'BookComment_4_53','BookComment typecode 4, subtypecode 53',284,4,53,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022355,'BookComment_4_54','BookComment typecode 4, subtypecode 54',284,4,54,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022356,'BookComment_4_55','BookComment typecode 4, subtypecode 55',284,4,55,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022357,'BookComment_4_56','BookComment typecode 4, subtypecode 56',284,4,56,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022358,'BookComment_4_57','BookComment typecode 4, subtypecode 57',284,4,57,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022359,'BookComment_4_58','BookComment typecode 4, subtypecode 58',284,4,58,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022360,'BookComment_4_59','BookComment typecode 4, subtypecode 59',284,4,59,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022361,'BookComment_4_60','BookComment typecode 4, subtypecode 60',284,4,60,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022362,'BookComment_4_61','BookComment typecode 4, subtypecode 61',284,4,61,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022363,'BookComment_4_62','BookComment typecode 4, subtypecode 62',284,4,62,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022364,'BookComment_4_63','BookComment typecode 4, subtypecode 63',284,4,63,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022365,'BookComment_4_64','BookComment typecode 4, subtypecode 64',284,4,64,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022366,'BookComment_4_65','BookComment typecode 4, subtypecode 65',284,4,65,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022367,'BookComment_4_66','BookComment typecode 4, subtypecode 66',284,4,66,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022368,'BookComment_4_67','BookComment typecode 4, subtypecode 67',284,4,67,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022369,'BookComment_4_68','BookComment typecode 4, subtypecode 68',284,4,68,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022370,'BookComment_4_69','BookComment typecode 4, subtypecode 69',284,4,69,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022371,'BookComment_4_70','BookComment typecode 4, subtypecode 70',284,4,70,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022372,'BookComment_4_71','BookComment typecode 4, subtypecode 71',284,4,71,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022373,'BookComment_4_72','BookComment typecode 4, subtypecode 72',284,4,72,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022374,'BookComment_4_73','BookComment typecode 4, subtypecode 73',284,4,73,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022375,'BookComment_4_74','BookComment typecode 4, subtypecode 74',284,4,74,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022376,'BookComment_4_75','BookComment typecode 4, subtypecode 75',284,4,75,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022377,'BookComment_4_76','BookComment typecode 4, subtypecode 76',284,4,76,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022378,'BookComment_4_77','BookComment typecode 4, subtypecode 77',284,4,77,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022379,'BookComment_4_78','BookComment typecode 4, subtypecode 78',284,4,78,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022380,'BookComment_4_79','BookComment typecode 4, subtypecode 79',284,4,79,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022381,'BookComment_4_80','BookComment typecode 4, subtypecode 80',284,4,80,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022382,'BookComment_4_81','BookComment typecode 4, subtypecode 81',284,4,81,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022383,'BookComment_4_82','BookComment typecode 4, subtypecode 82',284,4,82,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022384,'BookComment_4_83','BookComment typecode 4, subtypecode 83',284,4,83,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022385,'BookComment_4_84','BookComment typecode 4, subtypecode 84',284,4,84,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022386,'BookComment_4_85','BookComment typecode 4, subtypecode 85',284,4,85,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022387,'BookComment_4_86','BookComment typecode 4, subtypecode 86',284,4,86,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022388,'BookComment_4_87','BookComment typecode 4, subtypecode 87',284,4,87,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022389,'BookComment_4_88','BookComment typecode 4, subtypecode 88',284,4,88,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022390,'BookComment_4_89','BookComment typecode 4, subtypecode 89',284,4,89,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022391,'BookComment_4_90','BookComment typecode 4, subtypecode 90',284,4,90,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022392,'BookComment_4_91','BookComment typecode 4, subtypecode 91',284,4,91,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022393,'BookComment_4_92','BookComment typecode 4, subtypecode 92',284,4,92,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022394,'BookComment_4_93','BookComment typecode 4, subtypecode 93',284,4,93,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022395,'BookComment_4_94','BookComment typecode 4, subtypecode 94',284,4,94,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022396,'BookComment_4_95','BookComment typecode 4, subtypecode 95',284,4,95,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022397,'BookComment_4_96','BookComment typecode 4, subtypecode 96',284,4,96,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022398,'BookComment_4_97','BookComment typecode 4, subtypecode 97',284,4,97,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022399,'BookComment_4_98','BookComment typecode 4, subtypecode 98',284,4,98,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022400,'BookComment_4_99','BookComment typecode 4, subtypecode 99',284,4,99,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),1,null,null)
go

--mk08292013>GenericComments
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022401,'GenericComment1','GenericComment1',null,null,null,null,null,1,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022402,'GenericComment2','GenericComment2',null,null,null,null,null,1,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022403,'GenericComment3','GenericComment3',null,null,null,null,null,1,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022404,'GenericComment4','GenericComment4',null,null,null,null,null,1,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022405,'GenericComment5','GenericComment5',null,null,null,null,null,1,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022406,'GenericComment6','GenericComment6',null,null,null,null,null,1,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022407,'GenericComment7','GenericComment7',null,null,null,null,null,1,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022408,'GenericComment8','GenericComment8',null,null,null,null,null,1,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022409,'GenericComment9','GenericComment9',null,null,null,null,null,1,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022410,'GenericComment10','GenericComment10',null,null,null,null,null,1,null,'qsi_xt',GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022500,'BookCommentByTypeCode','BookComment uses typecode and typesubcode element',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022501,'BookCommentTypeCode','BookComment typecode',284,null,null,'bookcomments','commenttext',null,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022502,'BookCommentTypeSubCode','BookComment typesubcode',284,null,null,'bookcomments','commenttext',null,null,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022505,'BookCommentByTypeDesc','BookComment uses typedesc and typesubdesc element',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022506,'BookCommentTypeDesc','BookComment typecode',284,null,null,'bookcomments','commenttext',null,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022507,'BookCommentTypeSubDesc','BookComment typesubcode',284,null,null,'bookcomments','commenttext',null,null,'qsi_xt',GETDATE(),null,null,null)
go



INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022601,'textypecode_d102','othertext texttype',null,null,null,'bookcomments','commenttext',null,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022602,'textformatcode_d103','othertext textformatcode',null,null,null,'bookcomments','commenttext',null,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022603,'texvalue_d104','othertext textypecode',null,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022604,'textauthor_d107','othertext text author',null,null,null,'bookcomments','commenttext',null,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022605,'textsource_d108','othertext text source',null,null,null,'bookcomments','commenttext',null,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022606,'textpubdate_d019','othertext publication date',null,null,null,'bookcomments','commenttext',null,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022607,'text_releasetoelo_ind','othertext citation release to eloquence',null,null,null,'bookcomments','commenttext',null,null,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022611,'citation_del','delete all citations',null,null,null,'bookcomments','commenttext',null,null,'qsi_xt',GETDATE(),null,null,null)
go



INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022701,'book_cit_comment_01','bookcomment or citation (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022702,'book_cit_comment_02','bookcomment or citation (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022703,'book_cit_comment_03','bookcomment or citation (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022704,'book_cit_comment_04','bookcomment or citation (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022705,'book_cit_comment_05','bookcomment or citation (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022706,'book_cit_comment_06','bookcomment or citation (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022707,'book_cit_comment_07','bookcomment or citation (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022708,'book_cit_comment_08','bookcomment or citation (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022709,'book_cit_comment_09','bookcomment or citation (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022710,'book_cit_comment_10','bookcomment or citation (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022711,'book_cit_comment_11','bookcomment or citation (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022712,'book_cit_comment_12','bookcomment or citation (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022713,'book_cit_comment_13','bookcomment or citation (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022714,'book_cit_comment_14','bookcomment or citation (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022715,'book_cit_comment_15','bookcomment or citation (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022716,'book_cit_comment_16','bookcomment or citation (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022717,'book_cit_comment_17','bookcomment or citation (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022718,'book_cit_comment_18','bookcomment or citation (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022719,'book_cit_comment_19','bookcomment or citation (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022720,'book_cit_comment_20','bookcomment or citation (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100022751,'concatenate elements','concatenate_elements_01',NULL,NULL,NULL,'bookcomments',null,NULL,NULL,NULL,null,'firebrand',GETDATE(),null,null,null)
GO

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022801,'author_bio_qsicomments','author bio in qsicomments (uses addlqualifier in template)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go



INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022902,'D102_onix','Book Comment TextType (ONIX) - old',284,null,null,'bookcomments','commenttext',null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022903,'D103_onix','Book Comment TextFormat (ONIX) -  old',284,null,null,'bookcomments','commenttext',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022904,'D104_onix','Book Comment Text (ONIX) - old',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022911,'TextType_onix','Book Comment TextType - remap value to commenttypecode,commenttypesubcode',284,null,null,'bookcomments','commenttext',null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022912,'TextFormat_onix','Book Comment TextFormat (ONIX)',284,null,null,'bookcomments','commenttext',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022913,'Text_onix','Book Comment Text (ONIX)',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go
--mk>2012.06.26 Case: 19661 Source of quotes not showing in TMS (IPS)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022914,'Comment_OR_Citation_Type_D102','Comment OR Citation Type D102',284,null,null,'bookcomments','commenttext',null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022916,'Comment_OR_Citation_Type_D103','Comment OR Citation Type D103',284,null,null,'bookcomments','commenttext',null,null,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022917,'Comment_OR_Citation_Type_D104','Comment OR Citation Type D104',284,null,null,'bookcomments','commenttext',1,null,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100022915,'Text_onixcode_SubGen_breakout','Text onixcode subgentables breakout',284,null,null,null,null,null,null,'qsi_xt',GETDATE(),null,null,null)
go


-------------------------------------------------------------
/*  GLOBAL CONTACT ELEMENT SET*/
-------------------------------------------------------------

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100024011,'GlobalContactFirstName','Global Contact First Name',null,null,null,'globalcontact','firstname',null,'globalcontactkey','qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100024012,'GlobalContactMiddleName','Global Contact Middle Name',null,null,null,'globalcontact','middlename',null,'globalcontactkey','qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100024013,'GlobalContactLastName','Global Contact Last Name',null,null,null,'globalcontact','lastname',null,'globalcontactkey','qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100024014,'GlobalContactDisplayName','Global Contact Display Name',null,null,null,'globalcontact','displayname',null,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100024015,'GlobalContactRole','Global Contact Roll',285,null,null,'bookcontactrole','rolecode',null,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100024016,'GlobalContactDept','Global Contact role',286,null,null,'bookcontactrole','deppartmentcode',null,null,'qsi_xt',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,lobind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES(100024020,'GlobalContactExternalcode1x','Global Contact externalcode1',null,null,null,'globalcontact','externalcode1',null,null,'qsi_xt',GETDATE(),null,null,null)
go



-------------------------------------------------------------
/*  Author Elements	*/
-------------------------------------------------------------

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100026000,'Author Last Name','AuthorLastName',NULL,NULL,NULL,'author','lastname',NULL,NULL,NULL,'authorkey','qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100026001,'Author First Name','AuthorFirstName',NULL,NULL,NULL,'author','firstname',NULL,NULL,NULL,'authorkey','qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100026002,'Author Middle Name','AuthorMiddleName',NULL,NULL,NULL,'author','middlename',NULL,NULL,NULL,'authorkey','qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100026003,'Author Role','AuthorRole',NULL,NULL,NULL,'bookauthor','authortypecode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100026004,'Corporate Contributor indicator','CorpContribInd',NULL,NULL,NULL,'author','corporatecontributorind',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100026005,'Author Display Name','AuthorDisplayName',NULL,NULL,NULL,'author','displayname',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100026006,'Author Degree','AuthorDegree',NULL,NULL,NULL,'author','authordegree',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100026007,'Remove Book/Author links','DeleteBookAuthor',NULL,NULL,NULL,'bookauthor',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100026008,'Author URL','AuthorURL',NULL,NULL,NULL,'author','authorurl',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100026009,'Author Notes','AuthorNotes',NULL,NULL,NULL,'author','notes',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100026010,'Author Active Indicator','AuthorActiveInd',NULL,NULL,NULL,'author','activeind',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100026011,'Author Report Indicator','AuthorReportInd',NULL,NULL,NULL,'bookauthor','reportind',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100026012,'Author Primary Indicator (book)','Contributor_Primary1',NULL,NULL,NULL,'bookauthor','primaryind',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100026013,'AuthorBio','Author Bio',NULL,NULL,NULL,'author','biography',NULL,1,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100026014,'Author Sort Order','AuthorSortOrder',NULL,NULL,NULL,'author','sortorder',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100026016,'Author Suffix','AuthorSuffix',NULL,NULL,NULL,'author','degree',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100026017,'Author title','AuthorTitle',NULL,NULL,NULL,'author','title',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100026018,'AutoDisplayname','Set Auto generate display name',NULL,NULL,NULL,'globalcontact','autodisplayind',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100026030,'Corporate Author Name','AuthorCorpName',NULL,NULL,NULL,'author','lastname',NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100026035,'Parse Author Name','ParseAuthorName',NULL,NULL,NULL,null,null,NULL,NULL,NULL,null,'qsi_xt',GETDATE(),null,null,null)
go



--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026039,'Author Address default number','AuthorAddrDefNum',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100026040,'Author Address (1st)line 1','AuthorAddr1Line1x',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100026041,'Author Address (1st)line 2','AuthorAddr1Line2x',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100026042,'Author Address (1st)line 3','AuthorAddr1Line3x',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100026043,'Author Address (1st) City','AuthorAddr1City',NULL,NULL,NULL,'AUTHOR','city',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100026044,'Author Address (1st) State','AuthorAddr1State',160,NULL,NULL,'AUTHOR','statecode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100026045,'Author Address (1st) Zip','AuthorAddr1Zip',NULL,NULL,NULL,'AUTHOR','zip',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100026046,'Author Address (1st) Country','AuthorAddr1Country',114,NULL,NULL,'AUTHOR','countrycode',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100026047,'Author (1st) Phone','Author1Phone',NULL,NULL,NULL,'AUTHOR','phone1',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100026048,'Author (1st) Fax','Author1Fax',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100026049,'Author (1st) Email','Author1Email',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100026050,'Author Address (1st) Type','AuthorAddr1Type',207,NULL,NULL,'AUTHOR','addresstypecode1',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100026051,'Author Address (1st) Primary','AuthorAddr1Primary',NULL,NULL,NULL,'AUTHOR','addresstypecode1',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100026147,'Author (2nd) Phone','Author2Phone',NULL,NULL,NULL,'AUTHOR','phone2',NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
go
-- rules not written for the folowing
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026060,'Author Address (2nd)line 1','AuthorAddr2Line1x',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026061,'Author Address (2nd)line 2','AuthorAddr2Line2x',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026062,'Author Address (2nd)line 3','AuthorAddr2Line3x',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026063,'Author Address (2nd) City','AuthorAddr2City',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026064,'Author Address (2nd) State','AuthorAddr2State',160,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026065,'Author Address (2nd) Zip','AuthorAddr2Zip',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026066,'Author Address (2nd) Country','AuthorAddr2Country',114,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026067,'Author (2nd) Phone','Author2Phone',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026068,'Author (2nd) Fax','Author2Fax',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026069,'Author (2nd) Email','Author2Email',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026070,'Author Address (2nd) Type','AuthorAddr2Type',207,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--go


-- rules not written for the folowing
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026080,'Author Address (3rd)line 1','AuthorAddr3Line1x',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026081,'Author Address (3rd)line 2','AuthorAddr3Line2x',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026082,'Author Address (3rd)line 3','AuthorAddr3Line3x',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026083,'Author Address (3rd) City','AuthorAddr3City',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026084,'Author Address (3rd) State','AuthorAddr3State',160,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026085,'Author Address (3rd) Zip','AuthorAddr3Zip',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026086,'Author Address (3rd) Country','AuthorAddr3Country',114,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026087,'Author (3rd) Phone','Author3Phone',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026088,'Author (3rd) Fax','Author3Fax',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026089,'Author (3rd) Email','Author3Email',NULL,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--  VALUES (100026090,'Author Address (3rd) Type','AuthorAddr3Type',207,NULL,NULL,'AUTHOR',null,NULL,NULL,NULL,NULL,'qsi_xt',GETDATE(),null,null,null)
--go

/*  CUSTOM FIELDS	*/
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021021,'CustomFloat01','Custom Float 1',NULL,NULL,NULL,'bookcustom','customfloat01',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021022,'CustomFloat02','Custom Float 2',NULL,NULL,NULL,'bookcustom','customfloat02',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021023,'CustomFloat03','Custom Float 3',NULL,NULL,NULL,'bookcustom','customfloat03',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021024,'CustomFloat04','Custom Float 4',NULL,NULL,NULL,'bookcustom','customfloat04',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021025,'CustomFloat05','Custom Float 5',NULL,NULL,NULL,'bookcustom','customfloat05',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021026,'CustomFloat06','Custom Float 6',NULL,NULL,NULL,'bookcustom','customfloat06',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021027,'CustomFloat07','Custom Float 7',NULL,NULL,NULL,'bookcustom','customfloat07',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021028,'CustomFloat08','Custom Float 8',NULL,NULL,NULL,'bookcustom','customfloat08',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

--INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--VALUES (100021029,'CustomFloat09','Custom Float 9',NULL,NULL,NULL,'bookcustom','customfloat09',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

--INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--VALUES (100021030,'CustomFloat10','Custom Float 10',NULL,NULL,NULL,'bookcustom','customfloat10',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021031,'CustomInd01','Custom Indicator 1',NULL,NULL,NULL,'bookcustom','customind01',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021032,'CustomInd02','Custom Indicator 2',NULL,NULL,NULL,'bookcustom','customind02',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021033,'CustomInd03','Custom Indicator 3',NULL,NULL,NULL,'bookcustom','customind03',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021034,'CustomInd04','Custom Indicator 4',NULL,NULL,NULL,'bookcustom','customind04',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021035,'CustomInd05','Custom Indicator 5',NULL,NULL,NULL,'bookcustom','customind05',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021036,'CustomInd06','Custom Indicator 6',NULL,NULL,NULL,'bookcustom','customind06',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021037,'CustomInd07','Custom Indicator 7',NULL,NULL,NULL,'bookcustom','customind07',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

--INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--VALUES (100021038,'CustomInd08','Custom Indicator 8',NULL,NULL,NULL,'bookcustom','customind08',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

--INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--VALUES (100021039,'CustomInd09','Custom Indicator 9',NULL,NULL,NULL,'bookcustom','customind09',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

--INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--VALUES (100021040,'CustomInd10','Custom Indicator 10',NULL,NULL,NULL,'bookcustom','customind10',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021041,'Customint01','Custom Integer 1',NULL,NULL,NULL,'bookcustom','customint01',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021042,'Customint02','Custom Integer 2',NULL,NULL,NULL,'bookcustom','customint02',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021043,'Customint03','Custom Integer 3',NULL,NULL,NULL,'bookcustom','customint03',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021044,'Customint04','Custom Integer 4',NULL,NULL,NULL,'bookcustom','customint04',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021045,'Customint05','Custom Integer 5',NULL,NULL,NULL,'bookcustom','customint05',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021046,'Customint06','Custom Integer 6',NULL,NULL,NULL,'bookcustom','customint06',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021047,'Customint07','Custom Integer 7',NULL,NULL,NULL,'bookcustom','customint07',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

--INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--VALUES (100021048,'Customint08','Custom Integer 8',NULL,NULL,NULL,'bookcustom','customint08',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

--INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--VALUES (100021049,'Customint09','Custom Integer 9',NULL,NULL,NULL,'bookcustom','customint09',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

--INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
--VALUES (100021050,'Customint10','Custom Integer 10',NULL,NULL,NULL,'bookcustom','customint10',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021051,'Customcode01','Custom Code 1',417,NULL,NULL,'bookcustom','customcode01',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021052,'Customcode02','Custom Code 2',418,NULL,NULL,'bookcustom','customcode02',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021053,'Customcode03','Custom Code 3',419,NULL,NULL,'bookcustom','customcode03',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021054,'Customcode04','Custom Code 4',420,NULL,NULL,'bookcustom','customcode04',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021055,'Customcode05','Custom Code 5',421,NULL,NULL,'bookcustom','customcode05',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021056,'Customcode06','Custom Code 6',422,NULL,NULL,'bookcustom','customcode06',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021057,'Customcode07','Custom Code 7',423,NULL,NULL,'bookcustom','customcode07',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021058,'Customcode08','Custom Code 8',424,NULL,NULL,'bookcustom','customcode08',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021059,'Customcode09','Custom Code 9',425,NULL,NULL,'bookcustom','customcode09',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100021060,'Customcode10','Custom Code 10',426,NULL,NULL,'bookcustom','customcode10',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)


-- Onix Loader values

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100040010,'Onix_ProductIDType','Onix ProductIDType',null,NULL,NULL,'isbn','productnumbers',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100040011,'Onix_IDValue','Onix IDValue',null,NULL,NULL,'isbn','productnumbers',NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100040020,'j378','Onix j378 DiscountCodeTypeName',null,NULL,NULL,'bookprice',null,NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100040021,'j364','Onix j364 DiscountCode',null,NULL,NULL,'bookprice',null,NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100040030,'d102','Onix d102 TextTyptCode',null,NULL,NULL,'bookcomment',null,NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100040031,'d104','Onix d104 Comment Text',null,NULL,NULL,'bookcomment',null,NULL,NULL,NULL,NULL,'qsi_xt', GETDATE(),null,null,null)


/* P&L Elements - 27000s */
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100027000,'pl_action','p&l import action',null,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100027001,'pl_import_usageclass','p&l import usageclass',null,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100027002,'pl_import_accountingmonth','p&l import accountingmonth',null,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100027003,'pl_import_saleschannel','p&l import saleschannel',null,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100027004,'pl_import_subsaleschannel','p&l import  subsaleschannel',null,NULL,NULL,null,null,NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100027011,'pl_grosssalesunits','p&l grosssalesunits',null,NULL,NULL,'taqplsales_actual','grosssalesunits',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100027012,'pl_returnsalesunits','p&l returnsalesunits',null,NULL,NULL,'taqplsales_actual','returnsalesunits',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100027013,'pl_compsalesunits','p&l compsalesunits',null,NULL,NULL,'taqplsales_actual','compslaesunits',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100027014,'pl_grosssalesdollars','p&l grosssalesdollars',null,NULL,NULL,'taqplsales_actual','grosssalesdollars',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100027015,'pl_returnsalesdollars','p&l returnsalesdollars',null,NULL,NULL,'taqplsales_actual','returnsalesdollars',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100027016,'pl_costofgoodssold','p&l costofgoodssold',null,NULL,NULL,'taqplsales_actual','costofgoodssold',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100027021,'pl_cost_amount','p&l actual cost amount',null,NULL,NULL,'taqplcosts_actual','amount',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100027022,'pl_accounting_code','p&l accounting code',null,NULL,NULL,'taqplcosts_actual','amount',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100027023,'pl_accounting_month','p&l accounting month',null,NULL,NULL,'taqplcosts_actual','amount',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100027031,'pl_productiondate','p&l productiondate',null,NULL,NULL,'taqplproduction_actual','productiondate',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100027032,'pl_productionnquanitity','p&l productionnquanitity',null,NULL,NULL,'taqplproduction_actual','productionnquanitiy',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100027033,'pl_printingnumber','p&l printing number',null,NULL,NULL,'taqplproduction_actual','productionnquanitiy',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
go


INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028101,'misc_1_long','misc long 1',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028102,'misc_2_long','misc long 2',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028103,'misc_3_long','misc long 3',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028104,'misc_4_long','misc long 4',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028105,'misc_5_long','misc long 5',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028106,'misc_6_long','misc long 6',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028107,'misc_7_long','misc long 7',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028108,'misc_8_long','misc long 8',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028109,'misc_9_long','misc long 9',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028110,'misc_10_long','misc long 10',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028111,'misc_11_long','misc long 11',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028112,'misc_12_long','misc long 12',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028113,'misc_13_long','misc long 13',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028114,'misc_14_long','misc long 14',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028115,'misc_15_long','misc long 15',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028116,'misc_16_long','misc long 16',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028117,'misc_17_long','misc long 17',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028118,'misc_18_long','misc long 18',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028119,'misc_19_long','misc long 19',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028120,'misc_20_long','misc long 20',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028121,'misc_21_long','misc long 21',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028122,'misc_22_long','misc long 22',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028123,'misc_23_long','misc long 23',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028124,'misc_24_long','misc long 24',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028125,'misc_25_long','misc long 25',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)

insert into imp_element_defs values(100028126,'misc_26_long','misc long 26',NULL,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'ikeFW',GETDATE(),null,null,null)
insert into imp_element_defs values(100028127,'misc_27_long','misc long 27',NULL,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'ikeFW',GETDATE(),null,null,null)
insert into imp_element_defs values(100028128,'misc_28_long','misc long 28',NULL,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'ikeFW',GETDATE(),null,null,null)
insert into imp_element_defs values(100028129,'misc_29_long','misc long 29',NULL,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'ikeFW',GETDATE(),null,null,null)
insert into imp_element_defs values(100028130,'misc_30_long','misc long 30',NULL,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'ikeFW',GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028131,'misc_31_long','misc long 31',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028132,'misc_32_long','misc long 32',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028133,'misc_33_long','misc long 33',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028134,'misc_34_long','misc long 34',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028135,'misc_35_long','misc long 35',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028136,'misc_36_long','misc long 36',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028137,'misc_37_long','misc long 37',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028138,'misc_38_long','misc long 38',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028139,'misc_39_long','misc long 39',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028140,'misc_40_long','misc long 40',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028141,'misc_41_long','misc long 41',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028142,'misc_42_long','misc long 42',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028143,'misc_43_long','misc long 43',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028144,'misc_44_long','misc long 44',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028145,'misc_45_long','misc long 45',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028146,'misc_46_long','misc long 46',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028147,'misc_47_long','misc long 47',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028148,'misc_48_long','misc long 48',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028149,'misc_49_long','misc long 49',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028150,'misc_50_long','misc long 50',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028151,'misc_51_long','misc long 51',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028152,'misc_52_long','misc long 52',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028153,'misc_53_long','misc long 53',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028154,'misc_54_long','misc long 54',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028155,'misc_55_long','misc long 55',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028156,'misc_56_long','misc long 56',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028157,'misc_57_long','misc long 57',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028158,'misc_58_long','misc long 58',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028159,'misc_59_long','misc long 59',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028160,'misc_60_long','misc long 60',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028161,'misc_61_long','misc long 61',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028162,'misc_62_long','misc long 62',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028163,'misc_63_long','misc long 63',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028164,'misc_64_long','misc long 64',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028165,'misc_65_long','misc long 65',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028166,'misc_66_long','misc long 66',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028167,'misc_67_long','misc long 67',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028168,'misc_68_long','misc long 68',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028169,'misc_69_long','misc long 69',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028170,'misc_70_long','misc long 70',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028171,'misc_71_long','misc long 71',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028172,'misc_72_long','misc long 72',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028173,'misc_73_long','misc long 73',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028174,'misc_74_long','misc long 74',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028175,'misc_75_long','misc long 75',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028176,'misc_76_long','misc long 76',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028177,'misc_77_long','misc long 77',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028178,'misc_78_long','misc long 78',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028179,'misc_79_long','misc long 79',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028180,'misc_80_long','misc long 80',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028181,'misc_81_long','misc long 81',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028182,'misc_82_long','misc long 82',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028183,'misc_83_long','misc long 83',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028184,'misc_84_long','misc long 84',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028185,'misc_85_long','misc long 85',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028186,'misc_86_long','misc long 86',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028187,'misc_87_long','misc long 87',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028188,'misc_88_long','misc long 88',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028189,'misc_89_long','misc long 89',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028190,'misc_90_long','misc long 90',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028191,'misc_91_long','misc long 91',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028192,'misc_92_long','misc long 92',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028193,'misc_93_long','misc long 93',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028194,'misc_94_long','misc long 94',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028195,'misc_95_long','misc long 95',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028196,'misc_96_long','misc long 96',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028197,'misc_97_long','misc long 97',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028198,'misc_98_long','misc long 98',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028199,'misc_99_long','misc long 99',null,NULL,NULL,'bookmisc','longvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028201,'misc_1_float','misc float 1',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028202,'misc_2_float','misc float 2',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028203,'misc_3_float','misc float 3',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028204,'misc_4_float','misc float 4',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028205,'misc_5_float','misc float 5',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028206,'misc_6_float','misc float 6',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028207,'misc_7_float','misc float 7',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028208,'misc_8_float','misc float 8',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028209,'misc_9_float','misc float 9',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028210,'misc_10_float','misc float 10',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028211,'misc_11_float','misc float 11',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028212,'misc_12_float','misc float 12',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028213,'misc_13_float','misc float 13',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028214,'misc_14_float','misc float 14',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028215,'misc_15_float','misc float 15',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028216,'misc_16_float','misc float 16',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028217,'misc_17_float','misc float 17',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028218,'misc_18_float','misc float 18',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028219,'misc_19_float','misc float 19',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028220,'misc_20_float','misc float 20',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028221,'misc_21_float','misc float 21',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028222,'misc_22_float','misc float 22',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028223,'misc_23_float','misc float 23',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028224,'misc_24_float','misc float 24',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028225,'misc_25_float','misc float 25',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028226,'misc_26_float','misc float 26',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028227,'misc_27_float','misc float 27',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028228,'misc_28_float','misc float 28',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028229,'misc_29_float','misc float 29',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028230,'misc_30_float','misc float 30',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028231,'misc_31_float','misc float 31',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028232,'misc_32_float','misc float 32',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028233,'misc_33_float','misc float 33',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028234,'misc_34_float','misc float 34',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028235,'misc_35_float','misc float 35',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028236,'misc_36_float','misc float 36',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028237,'misc_37_float','misc float 37',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028238,'misc_38_float','misc float 38',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028239,'misc_39_float','misc float 39',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028240,'misc_40_float','misc float 40',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028241,'misc_41_float','misc float 41',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028242,'misc_42_float','misc float 42',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028243,'misc_43_float','misc float 43',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028244,'misc_44_float','misc float 44',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028245,'misc_45_float','misc float 45',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028246,'misc_46_float','misc float 46',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028247,'misc_47_float','misc float 47',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028248,'misc_48_float','misc float 48',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028249,'misc_49_float','misc float 49',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028250,'misc_50_float','misc float 50',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028251,'misc_51_float','misc float 51',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028252,'misc_52_float','misc float 52',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028253,'misc_53_float','misc float 53',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028254,'misc_54_float','misc float 54',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028255,'misc_55_float','misc float 55',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028256,'misc_56_float','misc float 56',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028257,'misc_57_float','misc float 57',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028258,'misc_58_float','misc float 58',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028259,'misc_59_float','misc float 59',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028260,'misc_60_float','misc float 60',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028261,'misc_61_float','misc float 61',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028262,'misc_62_float','misc float 62',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028263,'misc_63_float','misc float 63',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028264,'misc_64_float','misc float 64',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028265,'misc_65_float','misc float 65',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028266,'misc_66_float','misc float 66',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028267,'misc_67_float','misc float 67',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028268,'misc_68_float','misc float 68',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028269,'misc_69_float','misc float 69',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028270,'misc_70_float','misc float 70',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028271,'misc_71_float','misc float 71',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028272,'misc_72_float','misc float 72',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028273,'misc_73_float','misc float 73',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028274,'misc_74_float','misc float 74',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028275,'misc_75_float','misc float 75',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028276,'misc_76_float','misc float 76',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028277,'misc_77_float','misc float 77',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028278,'misc_78_float','misc float 78',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028279,'misc_79_float','misc float 79',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028280,'misc_80_float','misc float 80',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028281,'misc_81_float','misc float 81',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028282,'misc_82_float','misc float 82',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028283,'misc_83_float','misc float 83',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028284,'misc_84_float','misc float 84',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028285,'misc_85_float','misc float 85',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028286,'misc_86_float','misc float 86',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028287,'misc_87_float','misc float 87',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028288,'misc_88_float','misc float 88',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028289,'misc_89_float','misc float 89',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028290,'misc_90_float','misc float 90',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028291,'misc_91_float','misc float 91',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028292,'misc_92_float','misc float 92',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028293,'misc_93_float','misc float 93',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028294,'misc_94_float','misc float 94',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028295,'misc_95_float','misc float 95',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028296,'misc_96_float','misc float 96',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028297,'misc_97_float','misc float 97',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028298,'misc_98_float','misc float 98',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028299,'misc_99_float','misc float 99',null,NULL,NULL,'bookmisc','floatvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
 go

INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028301,'misc_1_text','misc text 1',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028302,'misc_2_text','misc text 2',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028303,'misc_3_text','misc text 3',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028304,'misc_4_text','misc text 4',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028305,'misc_5_text','misc text 5',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028306,'misc_6_text','misc text 6',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028307,'misc_7_text','misc text 7',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028308,'misc_8_text','misc text 8',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028309,'misc_9_text','misc text 9',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028310,'misc_10_text','misc text 10',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028311,'misc_11_text','misc text 11',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028312,'misc_12_text','misc text 12',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028313,'misc_13_text','misc text 13',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028314,'misc_14_text','misc text 14',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028315,'misc_15_text','misc text 15',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028316,'misc_16_text','misc text 16',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028317,'misc_17_text','misc text 17',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028318,'misc_18_text','misc text 18',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028319,'misc_19_text','misc text 19',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028320,'misc_20_text','misc text 20',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
--\
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028321,'misc_21_text','misc text 21',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028322,'misc_22_text','misc text 22',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028323,'misc_23_text','misc text 23',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028324,'misc_24_text','misc text 24',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028325,'misc_25_text','misc text 25',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028326,'misc_26_text','misc text 26',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028327,'misc_27_text','misc text 27',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028328,'misc_28_text','misc text 28',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028329,'misc_29_text','misc text 29',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null)
go
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028330,'misc_30_text','misc text 30',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028331,'misc_31_text','misc text 31',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028332,'misc_32_text','misc text 32',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028333,'misc_33_text','misc text 33',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028334,'misc_34_text','misc text 34',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028335,'misc_35_text','misc text 35',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028336,'misc_36_text','misc text 36',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028337,'misc_37_text','misc text 37',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028338,'misc_38_text','misc text 38',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028339,'misc_39_text','misc text 39',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028340,'misc_40_text','misc text 40',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028341,'misc_41_text','misc text 41',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028342,'misc_42_text','misc text 42',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028343,'misc_43_text','misc text 43',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028344,'misc_44_text','misc text 44',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028345,'misc_45_text','misc text 45',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028346,'misc_46_text','misc text 46',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028347,'misc_47_text','misc text 47',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028348,'misc_48_text','misc text 48',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028349,'misc_49_text','misc text 49',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028350,'misc_50_text','misc text 50',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028351,'misc_51_text','misc text 51',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028352,'misc_52_text','misc text 52',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028353,'misc_53_text','misc text 53',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028354,'misc_54_text','misc text 54',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028355,'misc_55_text','misc text 55',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028356,'misc_56_text','misc text 56',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028357,'misc_57_text','misc text 57',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028358,'misc_58_text','misc text 58',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028359,'misc_59_text','misc text 59',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028360,'misc_60_text','misc text 60',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028361,'misc_61_text','misc text 61',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028362,'misc_62_text','misc text 62',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028363,'misc_63_text','misc text 63',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028364,'misc_64_text','misc text 64',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028365,'misc_65_text','misc text 65',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028366,'misc_66_text','misc text 66',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028367,'misc_67_text','misc text 67',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028368,'misc_68_text','misc text 68',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028369,'misc_69_text','misc text 69',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028370,'misc_70_text','misc text 70',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028371,'misc_71_text','misc text 71',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028372,'misc_72_text','misc text 72',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028373,'misc_73_text','misc text 73',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028374,'misc_74_text','misc text 74',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028375,'misc_75_text','misc text 75',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028376,'misc_76_text','misc text 76',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028377,'misc_77_text','misc text 77',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028378,'misc_78_text','misc text 78',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028379,'misc_79_text','misc text 79',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028380,'misc_80_text','misc text 80',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028381,'misc_81_text','misc text 81',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028382,'misc_82_text','misc text 82',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028383,'misc_83_text','misc text 83',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028384,'misc_84_text','misc text 84',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028385,'misc_85_text','misc text 85',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028386,'misc_86_text','misc text 86',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028387,'misc_87_text','misc text 87',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028388,'misc_88_text','misc text 88',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028389,'misc_89_text','misc text 89',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028390,'misc_90_text','misc text 90',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028391,'misc_91_text','misc text 91',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028392,'misc_92_text','misc text 92',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028393,'misc_93_text','misc text 93',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028394,'misc_94_text','misc text 94',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028395,'misc_95_text','misc text 95',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028396,'misc_96_text','misc text 96',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028397,'misc_97_text','misc text 97',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028398,'misc_98_text','misc text 98',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
INSERT INTO imp_element_defs(elementkey,elementmnemonic,elementdesc,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
  VALUES (100028399,'misc_99_text','misc text 99',null,NULL,NULL,'bookmisc','textvalue',NULL,NULL,NULL,NULL,'firebrand', GETDATE(),null,null,null);
 go

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100020021, 'DABTitleCreated', 'DAB Title Created', NULL, NULL, NULL, 'bookdates', 'activedate', 20034, NULL, NULL, NULL, 'mkadmin',GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100020022, 'DABImportDate', 'DAB Import Date', NULL, NULL, NULL, 'bookdates', 'activedate', 422, NULL, NULL, NULL, 'mkadmin',GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100014074, 'csapprovalcode', 'csapprovalcode', NULL, NULL, NULL, 'bookdetail', 'csapprovalcode', NULL, NULL, NULL, NULL, 'mkadmin',GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100050010, 'DataSetup_OrgLevel', 'DataSetup_OrgLevel', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'mkadmin',GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100050011, 'DataSetup_AuthorRole', 'DataSetup_AuthorRole', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'mkadmin',GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100050012, 'DataSetup_BisacSubjectCode', 'DataSetup_BisacSubjectCode', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'mkadmin',GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100050013, 'DataSetup_ISBNPrefix', 'DataSetup_ISBNPrefix', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'mkadmin',GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100023000, 'ProcessComment1', 'ProcessComment1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'mkadmin',GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100023001, 'ProcessComment2', 'ProcessComment2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'mkadmin',GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100014154, 'LanguageType', 'LanguageType', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'mkadmin',GETDATE(),null,null,null)

INSERT INTO imp_element_defs(elementkey,elementdesc,elementmnemonic,tableid,datacode,datasubcode,destinationtable,destinationcolumn,datetypecode,lobind,importnullind,leadkeyname,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version)
VALUES (100014160, 'KeyWords', 'KeyWords', NULL, NULL, NULL, 'bookkeywords', 'keyword', NULL, NULL, NULL, NULL, 'qsiadmin',GETDATE(),null,null,null)

Insert into imp_element_defs(elementkey,elementmnemonic,elementdesc,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version) Select 100050000,'Generic_1_Delete','Delete From Table','qsiadmin',GETDATE(),null,null,null
Insert into imp_element_defs(elementkey,elementmnemonic,elementdesc,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version) Select 100050001,'Generic_2_Delete','Delete From Table','qsiadmin',GETDATE(),null,null,null
Insert into imp_element_defs(elementkey,elementmnemonic,elementdesc,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version) Select 100050002,'Generic_3_Delete','Delete From Table','qsiadmin',GETDATE(),null,null,null
Insert into imp_element_defs(elementkey,elementmnemonic,elementdesc,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version) Select 100050003,'Generic_4_Delete','Delete From Table','qsiadmin',GETDATE(),null,null,null
Insert into imp_element_defs(elementkey,elementmnemonic,elementdesc,lastuserid,lastmaintdate,DeprecatedInd,UsageNote,minimum_version) Select 100050004,'Generic_5_Delete','Delete From Table','qsiadmin',GETDATE(),null,null,null
