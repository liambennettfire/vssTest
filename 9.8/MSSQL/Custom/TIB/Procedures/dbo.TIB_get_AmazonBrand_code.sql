if exists (select * from dbo.sysobjects where id = object_id(N'dbo.TIB_get_AmazonBrand_code') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.TIB_get_AmazonBrand_code
GO

CREATE PROC dbo.TIB_get_AmazonBrand_code
(@i_bookkey INT, @result VARCHAR(255) output)
AS 
BEGIN
DECLARE @amazon_brand_code varchar(255)
SET @amazon_brand_code = ''

/*
This procedure will be used for a calculated misc item for TIME. 
It returns family codes excluding the first 2 digits from category 412

Exec dbo.TIB_get_AmazonBrand_code @bookkey, @result output

Created By: TT
Created On: 03-09-2017


add elo field identifier for 

DPIDXBIZORAMZBCD - Amazon Brand Code

Select * FROM gentables where tableid = 560

Delete from gentables_Ext where tableid = 560 and datacode = 28

Delete from gentables where tableid = 560 and datacode = 28


declare @datacode int
select @datacode=max(datacode) +1 from gentables where tableid=560
  
   INSERT INTO gentables
   (tableid,
   datacode,
   datadesc,
   deletestatus,
   sortorder,
   tablemnemonic,
   datadescshort,
   lastuserid,
   lastmaintdate,
   acceptedbyeloquenceind,
   exporteloquenceind,
   eloquencefieldtag )
   VALUES
  (560,
   @datacode,
   'DPIDXBIZORAMZBCD - Amazon Brand Code',
   'N',
   @datacode,
   'ValidEloFieldIds',
   'Amazon Brand Code',
   'FBTDBA',
   getdate(),
   1,
   1,
   'DPIDXBIZORAMZBCD')




*/


Select --bsc.bookkey, 
@amazon_brand_code = Cast (g.externalcode as varchar(10)) + Cast (s.externalcode as varchar(10)) + Cast (s2.externalcode as varchar(10))
FROM booksubjectcategory bsc 
JOIN sub2gentables s2
ON bsc.categorytableid = s2.tableid and bsc.categorycode = s2.datacode and bsc.categorysubcode = s2.datasubcode and bsc.categorysub2code = s2.datasub2code
JOIN subgentables s
ON s2.tableid = s.tableid and s2.datasubcode = s.datasubcode and s2.datacode = s.datacode 
JOIN gentables g 
ON s.tableid = g.tableid and s.datacode = g.datacode 
where bsc.bookkey = @i_bookkey
and categorytableid = 412
and ISNULL(categorycode, 0) <> 0 
AND ISNULL(categorysubcode, 0) <> 0
AND ISNULL(categorysub2code, 0) <> 0
AND s2.deletestatus = 'N' and s.deletestatus = 'N' and g.deletestatus = 'N'

--IF ISNULL(@amazon_brand_code, '') = '' 
--	SET @amazon_brand_code = ''


IF ISNULL(@amazon_brand_code, '') <> ''
	BEGIN 
		IF EXISTS (SELECT 1 FROM bookmisc WHERE bookkey = @i_bookkey AND misckey = 270)
			BEGIN 
				UPDATE bookmisc 
				SET textvalue = @amazon_brand_code, lastuserid ='qsiadmin', lastmaintdate = GETDATE()
				WHERE bookkey = @i_bookkey AND misckey = 270
			END
		ELSE
			BEGIN 
				INSERT INTO bookmisc (bookkey, misckey, textvalue, lastuserid, lastmaintdate, sendtoeloquenceind)
				SELECT @i_bookkey, 270, @amazon_brand_code, 'qsiadmin', GETDATE(), 1

			END
	END



Select @result = @amazon_brand_code

END

GO

GRANT EXEC ON dbo.TIB_get_AmazonBrand_code TO PUBLIC 
