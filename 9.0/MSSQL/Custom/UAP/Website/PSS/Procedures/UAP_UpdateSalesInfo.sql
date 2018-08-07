if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UAP_UpdateSalesInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UAP_UpdateSalesInfo]


CREATE procedure [dbo].[UAP_UpdateSalesInfo]
AS
BEGIN

DELETE from uap..bookmisc
where misckey = 1


Insert into uap..bookmisc
Select i.bookkey, 1, c.bookkey, NULL, NULL, 'qsiadmin',getdate(),0 
FROM cdc..isbn c
JOIN uap..isbn i
on c.ean13 = i.ean13
WHERE i.bookkey is NOT NULL
and c.bookkey is NOT NULL
and c.bookkey in
(
Select * FROM cdc..uap_bookkeys()
)

--Select * FROM uap..bookcustom bc
--join uap..bookmisc bm
--on bc.bookkey = bm.bookkey
--WHERE bm.misckey = 1

DELETE FROM uap..bookcustom
WHERE bookkey in 
(
Select bookkey from uap..bookmisc
where misckey = 1
)

Insert into uap..bookcustom
Select u.bookkey,
c.customind01,c.customind02,c.customind03,c.customind04,c.customind05,
c.customind06,c.customind07,c.customind08,c.customind09,c.customind10,
c.customcode01,c.customcode02,c.customcode03,c.customcode04,c.customcode05,
c.customcode06,c.customcode07,c.customcode08,c.customcode09,c.customcode10,
c.customint01,c.customint02,c.customint03,c.customint04,c.customint05,
c.customint06,c.customint07,c.customint08,c.customint09,c.customint10,
c.customfloat01,c.customfloat02,c.customfloat03,c.customfloat04,c.customfloat05,
c.customfloat06,c.customfloat07,c.customfloat08,c.customfloat09,c.customfloat10,
'qsiadmin', getdate()
FROM cdc..bookcustom c
JOIN uap..bookmisc u
ON c.bookkey = u.longvalue
where u.misckey = 1


END

GO
Grant execute on dbo.UAP_UpdateSalesInfo to Public
GO