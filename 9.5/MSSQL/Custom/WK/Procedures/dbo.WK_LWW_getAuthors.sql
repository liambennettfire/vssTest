if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_LWW_getAuthors') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_LWW_getAuthors
GO

CREATE PROCEDURE [dbo].[WK_LWW_getAuthors]
--@globalcontactkey int
AS
BEGIN


/*
(MULTISET
                 (SELECT pa.product_actor_id intauthorid,pa.SUCCEEDING_TITLES STRSUCCEEDINGTITLES,
                         DECODE
                              (pa.first_name,
                               NULL, ' ',
                                  SUBSTR (pa.first_name, 1, 40)
                               || ' '
                               || SUBSTR (pa.middle_name, 1, 1)
                              ) AS strauthorfirstname,
                         DECODE
                            (TYPE,
                             'com.lww.pace.domain.actor.ProductOrganizationActor', SUBSTR
                                                      (pa.society_author_name,
                                                       1,
                                                       80
                                                      ),
                             SUBSTR (pa.last_name, 1, 80)
                            ) AS strauthorlastname,
                         DECODE
                            (TYPE,
                             'com.lww.pace.domain.actor.ProductOrganizationActor', cleanolstext
                                              (SUBSTR (pa.society_author_name,
                                                       1,
                                                       83
                                                      )
                                              ),
                             LOWER (   SUBSTR (pa.first_name, 1, 40)
                                    || ' '
                                    || SUBSTR (pa.middle_name, 1, 1)
                                    || ' '
                                    || cleanolstext (SUBSTR (pa.last_name,
                                                             1,
                                                             83
                                                            )
                                                    )
                                   )
                            ) AS strauthoranglicizedlastname,
                         SUBSTR (pa.preceding_titles, 1, 20) strauthortitle,
                         SUBSTR (pa.succeeding_titles, 1,
                                 100) strauthorsuffix
                    FROM product_actor pa
                   WHERE pa.common_product_id(+) = p.common_product_id
                 ) AS authorlist_spl
             ) AS authlist,


Select  DISTINCT PRECEDING_TITLES FROM WK_ORA.WKDBA.PRODUCT_ACTOR

Select  * FROM WK_ORA.WKDBA.PRODUCT_ACTOR

tableid = 210
Select Distinct accreditationcode FROM globalcontact

Select * FROM globalcontact
where groupname is not null

dbo.WK_LWW_getAuthors 717009

Select * FROM globalcontact
where grouptypecode > 0

Select * FROM globalcontact

Select * FROM bookauthor

dbo.WK_LWW_getAuthors



SELECT 
globalcontactkey as intauthorid,
(CASE WHEN degree IS NULL THEN ''
ELSE degree END) as STRSUCCEEDINGTITLES,
((CASE WHEN firstname is NULL or firstname = '' THEN ''
	ELSE SUBSTRING(firstname, 1, 40) END)
+ (CASE 
	WHEN middlename IS NULL and firstname is NOT NULL THEN ''
	WHEN middlename IS NULL and firstname is NULL THEN ''
	WHEN middlename is NOT NULL and firstname is NOT NULL THEN ' '+ SUBSTRING(middlename, 1,1)
			ELSE ''
	END)) as strauthorfirstname,

(CASE WHEN grouptypecode IS NOT NULL  and grouptypecode > 0 THEN SUBSTRING(groupname, 1, 80)
	 ELSE lastname END) as strauthorlastname,

(CASE WHEN grouptypecode IS NOT NULL and grouptypecode > 0 THEN SUBSTRING(groupname, 1, 83)
	  WHEN middlename is NOT NULL THEN lower(SUBSTRING(firstname, 1, 40) + ' ' + SUBSTRING(middlename, 1, 1) + ' ' + lastname)
	  ELSE lower(SUBSTRING(firstname, 1, 40) + ' ' + lastname) END)
as strauthoranglicizedlastname,

(CASE WHEN accreditationcode IS NULL THEN ''
	 ELSE SUBSTRING([dbo].[rpt_get_gentables_field](210, accreditationcode, 'D'), 1, 20) END)
as strauthortitle,
(CASE WHEN degree is NULL THEN ''
     ELSE degree END) as strauthorsuffix
FROM globalcontact
WHERE globalcontactkey = @globalcontactkey

END

*/
SELECT DISTINCT
gc.globalcontactkey as intauthorid,
(CASE WHEN gc.degree IS NULL THEN ''
ELSE gc.degree END) as STRSUCCEEDINGTITLES,
SUBSTRING(
((CASE WHEN gc.firstname is NULL or gc.firstname = '' THEN ''
	ELSE SUBSTRING(gc.firstname, 1, 40) END)
+ (CASE 
	WHEN gc.middlename IS NULL and gc.firstname is NOT NULL THEN ''
	WHEN gc.middlename IS NULL and gc.firstname is NULL THEN ''
	WHEN gc.middlename is NOT NULL and gc.firstname is NOT NULL THEN ' '+ SUBSTRING(gc.middlename, 1,1)
			ELSE ''
	END))
,1,40) as strauthorfirstname,

--(CASE WHEN gc.grouptypecode IS NOT NULL  and gc.grouptypecode > 0 THEN SUBSTRING(gc.groupname, 1, 80)
--	 ELSE gc.lastname END) as strauthorlastname,
(CASE WHEN gc.groupname IS NOT NULL  and gc.groupname <> '' THEN SUBSTRING(gc.groupname, 1, 80)
	 ELSE gc.lastname END) as strauthorlastname,

--(CASE WHEN gc.grouptypecode IS NOT NULL and gc.grouptypecode > 0 THEN SUBSTRING(gc.groupname, 1, 83)
--	  WHEN gc.middlename is NOT NULL THEN SUBSTRING((lower(SUBSTRING(gc.firstname, 1, 40) + ' ' + SUBSTRING(gc.middlename, 1, 1) + ' ' + gc.lastname)),1,83)
--	  ELSE SUBSTRING(lower(SUBSTRING(gc.firstname, 1, 40) + ' ' + gc.lastname), 1, 83) END)

(CASE WHEN gc.groupname IS NOT NULL and gc.groupname <> '' THEN SUBSTRING(gc.groupname, 1, 83)
	  WHEN gc.middlename is NOT NULL and gc.middlename <> '' THEN SUBSTRING((lower(SUBSTRING(gc.firstname, 1, 40) + ' ' + SUBSTRING(gc.middlename, 1, 1) + ' ' + gc.lastname)),1,83)
	  ELSE SUBSTRING(lower(SUBSTRING(gc.firstname, 1, 40) + ' ' + gc.lastname), 1, 83) END)
as strauthoranglicizedlastname,

(CASE WHEN gc.accreditationcode IS NULL THEN ''
	 ELSE SUBSTRING([dbo].[rpt_get_gentables_field](210, gc.accreditationcode, 'D'), 1, 40) END)
as strauthortitle,
(CASE WHEN gc.degree is NULL THEN ''
     ELSE gc.degree END) as strauthorsuffix
FROM bookauthor ba
JOIN globalcontact gc
ON ba.authorkey = gc.globalcontactkey
WHERE dbo.WK_IsEligibleforLWW(ba.bookkey) = 'Y'
and gc.activeind = 1

END

