if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_Organizations') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.WK_Organizations
GO
CREATE PROCEDURE dbo.WK_Organizations
@bookkey int,
@globalcontactkey int
AS
BEGIN

/*
--Update this proc once we know how organizations are converted from PACE
--Organizations are converted into globalcontact comments
--do we use globalcontactkey for comments?

dbo.WK_Organizations 568591, 703826

Select * FROM bookauthor 

Select * FROM WK_ORA.WKDBA.ORGANIZATION

Select * FROM qsicomments
where commenttypecode = 9
and commenttext like 'Hammersmith Hospital, London, England%'

Select * FROM WK_ORA.WKDBA.PRODUCT_ACTOR
Select Count(*) FROM WK_ORA.WKDBA.PRODUCT_ACTOR --30564
Select Count(Distinct pssglobalcontactkey) FROM WK_ORA.WKDBA.PRODUCT_ACTOR 
 
Select * FROM globalcontact
where globalcontactkey = 703318

Select * FROM gentables
where tableid = 528 and datacode = 11

DELETE from gentables
where tableid = 528 and datacode = 11

Select * FROM dbo.WK_ORGANIZATION o JOIN dbo.WK_PRODUCT_ACTOR pa ON o.PRODUCT_ACTOR_ID = pa.PRODUCT_ACTOR_ID WHERE pa.COMMON_PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and pa.pssglobalcontactkey = @globalcontactkey

*/
Select
--(CASE WHEN [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') IS NULL OR [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') = '' THEN @globalcontactkey
--ELSE (
--CASE WHEN EXISTS (Select * FROM dbo.WK_ORGANIZATION o JOIN dbo.WK_PRODUCT_ACTOR pa ON o.PRODUCT_ACTOR_ID = pa.PRODUCT_ACTOR_ID WHERE pa.COMMON_PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and pa.pssglobalcontactkey = @globalcontactkey)
--	 THEN ( Select TOP 1 ORGANIZATION_ID FROM dbo.WK_ORGANIZATION o JOIN dbo.WK_PRODUCT_ACTOR pa ON o.PRODUCT_ACTOR_ID = pa.PRODUCT_ACTOR_ID WHERE pa.COMMON_PRODUCT_ID = [dbo].[rpt_get_misc_value](@bookkey, 2, 'long') and pa.pssglobalcontactkey = @globalcontactkey ORDER BY o.DISPLAY_SEQUENCE )
--    ELSE @globalcontactkey END)
--END) as [idField], 
commentkey as [idField],
1 as [sequenceField],
commenttext as [textField]
FROM qsicomments 
WHERE commentkey = @globalcontactkey
and commenttypecode = 9
and commenttext is not null and LEN(Cast(commenttext as varchar(max))) > 0
END

--Select 
--globalcontactrelationshipkey as [id],
--sortorder as [sequence],
--globalcontactname2 as [text]
--FROM globalcontactrelationship 
--WHERE globalcontactkey1= @globalcontactkey
--ORDER BY sortorder

--Select * FROM gentables
--where tableid = 528
--
--Select * FROM qsicomments
--WHERE CAST(commenttext as varchar(max)) = 'Hammersmith Hospital, London, England'
--
--Select * FROM globalcontact
--where globalcontactkey = 714334

