if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcs_get_misc_generic') and OBJECTPROPERTY(id, N'IsTableFunction') = 1)
drop function dbo.qcs_get_misc_generic
GO

CREATE FUNCTION dbo.qcs_get_misc_generic (@bookkey INT,
@productTag VARCHAR(50))

RETURNS @generic_misc TABLE(
    --[Id] [uniqueidentifier] NOT NULL,
    Tag  VARCHAR(50),
    [Key] VARCHAR(25),
    AlternateKey VARCHAR(25),
	Value VARCHAR(4000) NULL
	)
AS
BEGIN

		  INSERT INTO @generic_misc
		  SELECT 
         -- NEWID() AS Id,
          @productTag + '-' + 'PRDTYPE' AS Tag, 
          'DPIDXBIZPRDTYPE' AS 'Key', 
          'PRDTYPE' AS AlternateKey, 
          (case when oe.customid1 like 'QS81%' THEN 'QDS'
			   when ISNULL(g.externalcode, '') = '' THEN ''
	           else  g.externalcode end) as Value

			FROM
			bookdetail  bd
			JOIN gentables g
			ON bd.mediatypecode = g.datacode 
			JOIN bookorgentry boe 
			on bd.bookkey = boe.bookkey 
			JOIN orgentry oe 
			on boe.orgentrykey = oe.orgentrykey 
			WHERE bd.bookkey = @bookkey
			and boe.orglevelkey = 5 
			and oe.orglevelkey = 5
			and g.tableid = 312 
		  
		  
		 
		Insert into @generic_misc
		SElect 
		-- NEWID() AS Id,
          @productTag + '-' + 'GENZPPT' AS Tag, 
          'DPIDXBIZPPT' AS 'Key', 
          'ZPPT' AS AlternateKey, 
		  (case when mediatypecode = 9 then 100 -- PPT is 100% on eBooks 
		        when (Select Coalesce(finalprice, budgetprice) from bookprice where bookkey = @bookkey and pricetypecode = 31 and currencytypecode = 37 and activeind = 1) = (Select Coalesce(finalprice, budgetprice) from bookprice where bookkey = @bookkey and pricetypecode = 8 and currencytypecode = 37 and activeind = 1) THEN 0 -- standard book, 0 % taxable
				else 100 end) AS Value -- if not an ebook and price incl. tax doesn't equal price excl. tax we assume it is 100% taxable. adult colouring books or books+CD or books + something else
			FROM
          bookdetail  bd
		  where bd.bookkey = @bookkey  
		  and exists(Select 1 from bookprice where bookkey = @bookkey and pricetypecode = 31 and currencytypecode = 37 and (ISNULL(budgetprice,0) <> 0 OR ISNULL(finalprice,0) <> 0) and activeind = 1) -- RRP Including Tax price exists for GBP
		  and exists (Select 1 from bookprice where bookkey = @bookkey and pricetypecode = 8 and currencytypecode = 37 and (ISNULL(budgetprice,0) <> 0 OR ISNULL(finalprice,0) <> 0) and activeind = 1) -- MSR excluding Tax price exists for GBP
		     
		 -- hachette format codes, stored in externalcode of subgentable 312 
		 Insert into @generic_misc
		 Select  
		 -- NEWID() AS Id,
          @productTag + '-' + 'HBGFORMAT' AS Tag, 
          'DPIDXBIZHBGFORMAT' AS 'Key', 
          'HBGFORMAT' AS AlternateKey, 
		  s.externalcode as Value 
		  From bookdetail bd 
		  JOIN subgentables s
		  On bd.mediatypecode = s.datacode and bd.mediatypesubcode = s.datasubcode 
		  where bd.bookkey = @bookkey and s.tableid = 312 
		  and s.deletestatus = 'N' and ISNULL(bd.mediatypecode, 0) <> 0 and ISNULL(bd.mediatypesubcode,0) <> 0 and ISNULL(s.externalcode, '') <> '' 


		  -- AltItemID - stored in isbn.dsmarc field, need to send it to Hachette 
		 --Insert into @generic_misc
		 --Select  
		 ---- NEWID() AS Id,
   --       @productTag + '-' + 'ALTITEMID' AS Tag, 
   --       'DPIDXBIZALTITEMID' AS 'Key', 
   --       'ALTITEMID' AS AlternateKey, 
		 -- dsmarc as Value 
		 -- FROM isbn 
		 -- WHERE bookkey = @bookkey and ISNULL(dsmarc, '') <> ''


		  Insert into @generic_misc
		  Select  
		 -- NEWID() AS Id,
          @productTag + '-' + 'ZHBGALTID_QPG#' AS Tag, 
          'DPIDXBIZHBGALTID_QPG#' AS 'Key', 
          'ZHBGALTID_QPG#' AS AlternateKey, 
		  dsmarc as Value 
		  FROM isbn 
		  WHERE bookkey = @bookkey and ISNULL(dsmarc, '') <> ''

		  -- Hachette sub format codes, stored in child format, need to sent it to Hachette 

		  Insert into @generic_misc
		  Select  
		 -- NEWID() AS Id,
          @productTag + '-' + 'SUBFORMAT' AS Tag, 
          'DPIDXBIZSUBFORMAT' AS 'Key', 
          'SUBFORMAT' AS AlternateKey, 
		  g.externalcode as Value 
		  FROM booksimon b
		  JOIN gentables g
		  on b.formatchildcode = g.datacode 
		  WHERE bookkey = @bookkey and ISNULL(b.formatchildcode, 0) <> 0 and g.tableid = 300 and ISNULL(g.externalcode, '') <> '' and g.deletestatus = 'N'

		  -- UPC Code will be sent to Hachette 
		  Insert into @generic_misc
		  Select  
		 -- NEWID() AS Id,
          @productTag + '-' + 'ZHBGALTID_UPC' AS Tag, 
          'DPIDXBIZHBGALTID_UPC' AS 'Key', 
          'ZHBGALTID_UPC' AS AlternateKey, 
		  upc as Value 
		  FROM isbn 
		  WHERE bookkey = @bookkey and ISNULL(upc, '') <> ''


		  -- UPC VERSION TITLES 
		  -- Identify them by Familcode 
		  -- QS801901, QS802001
		  INSERT INTO @generic_misc
			SELECT 
			-- NEWID() AS Id,
			@productTag + '-' + 'UPCVERSION' AS Tag, 
			'DPIDXBIZUPCVERSION' AS 'Key', 
			'UPCVERSION' AS AlternateKey, 
			(case when ISNULL(oe.customid1, '') in ('QS802001', 'QS801901') THEN 'Y'
			else  'N' end) as Value
			FROM bookorgentry boe 
			JOIN orgentry oe 
			on boe.orgentrykey = oe.orgentrykey 
			WHERE boe.bookkey = @bookkey
			and boe.orglevelkey = 5 
			and oe.orglevelkey = 5


			-- Send Hachette verification status to the cloud
			-- we will use it to filter out failed titles
			-- by creating a filter expression on the channel
			-- 05/22/17
			Insert into @generic_misc
			Select  
			-- NEWID() AS Id,
			@productTag + '-' + 'ZHBGVERSTATUS' AS Tag, 
			'DPIDXBIZHBGVERSTATUS' AS 'Key', 
			'ZHBGVERSTATUS' AS AlternateKey, 
			g.datadesc as Value 
			FROM bookverification bv
			JOIN gentables g 
			ON bv.titleverifystatuscode = g.datacode 
			WHERE bv.bookkey = @bookkey 
			and g.tableid = 513 
			and bv.verificationtypecode = 7 -- Hachette



			
			-- 09/12/17 If populated but sendtoeloquenceind = 0 send the value
			IF EXISTS (Select 1 from bookmisc where bookkey = @bookkey and misckey = 145 and ISNULL(longvalue, 0) <> 0 and ISNULL(sendtoeloquenceind, 0) = 0)
				BEGIN
					INSERT INTO @generic_misc
					SELECT 
					-- NEWID() AS Id,
					@productTag + '-' + 'ZPRDPROF' AS Tag,
					'DPIDXBIZPRDPROF' AS 'Key', 
					'ZPRDPROF' AS AlternateKey, 
					Cast(longvalue as varchar(10)) as Value  
					FROM bookmisc 
					where bookkey = @bookkey and misckey = 145 


				END
			ELSE -- IF PRODUCT PROFILE IS NOT POPULATED USE THIS LOGIC TO SEND ONE - It is required in Hachette. 
				BEGIN
					IF NOT EXISTS (Select 1 FROM bookmisc where bookkey = @bookkey and misckey = 145) OR EXISTS (Select 1 from bookmisc where bookkey = @bookkey and misckey = 145 and longvalue is NULL)
						BEGIN

							IF exists (Select 1 from bookbisaccategory bbc
										join gentables g 
										on bbc.bisaccategorycode = g.datacode 
										where bbc.bookkey = @bookkey and bbc.printingkey = 1
										and g.tableid = 339 and g.deletestatus = 'N' and g.eloquencefieldtag in ('FIC','JUV', 'YAF'))
							OR EXISTS (Select 1 from bookbisaccategory bbc
										join subgentables s 
										on bbc.bisaccategorycode = s.datacode and s.datasubcode = bbc.bisaccategorysubcode
										where bbc.bookkey = @bookkey and bbc.printingkey = 1
										and s.tableid = 339 and s.deletestatus = 'N' and 
										(s.datadesc like '% Fiction%' OR s.datadesc like 'Fiction%')
										and s.eloquencefieldtag not in ('LIT004260', 'ART050060'))
								BEGIN
									INSERT INTO @generic_misc
									SELECT 
									-- NEWID() AS Id,
									@productTag + '-' + 'ZPRDPROF' AS Tag,
									'DPIDXBIZPRDPROF' AS 'Key', 
									'ZPRDPROF' AS AlternateKey, 
									'1' as Value  -- Default to Non-fiction
								END
							ELSE
								BEGIN
									INSERT INTO @generic_misc
									SELECT 
									-- NEWID() AS Id,
									@productTag + '-' + 'ZPRDPROF' AS Tag,
									'DPIDXBIZPRDPROF' AS 'Key', 
									'ZPRDPROF' AS AlternateKey, 
									'2' as Value  -- Default to Non-fiction
				
								END

						END
					END

			-- New logic as of 5/14/17, Only send Y if it's populated that way in TM o/w blank. 
			INSERT INTO @generic_misc
			SELECT 
			-- NEWID() AS Id,
			@productTag + '-' + 'NOCHARGEFLG' AS Tag, 
			'DPIDXBIZNOCHARGEFLG' AS 'Key', 
			'NOCHARGEFLG' AS AlternateKey, 
			(Case when longvalue = 1  THEN 'Y' ELSE '' END) AS Value
			FROM
			bookmisc  bm
			--JOIN gentables g
			--ON bd.mediatypecode = g.datacode 
			WHERE bookkey = @bookkey and misckey = 144


			-- CT - 06/12/17
			 --productavailability for each market will be sent using misc items so that an existing channel setting can be used
		   Insert into @generic_misc
		   Select  
		 -- NEWID() AS Id,
          @productTag + '-' + 'ZAVAIL_GB' AS Tag, 
          'DPIDXBIZAVAIL_GB' AS 'Key', 
          'ZAVAIL_GB' AS AlternateKey, 
		   sg.eloquencefieldtag as Value 
		  FROM  
		   bookproductdetail bpd join subgentables sg on sg.tableid=bpd.tableid and sg.datacode=bpd.datacode and sg.datasubcode=bpd.datasubcode 
		   --and sg2.datasub2code=bpd.datasub2code 
		   WHERE bpd.tableid = 659 AND bpd.datacode in (1) AND bpd.datasubcode IN (1,8,15)--uk
		  and bookkey = @bookkey and sg.eloquencefieldtag is NOT NULL and sg.exporteloquenceind=1

		    Insert into @generic_misc
		   Select  
		 -- NEWID() AS Id,
          @productTag + '-' + 'ZAVAIL_US' AS Tag, 
          'DPIDXBIZAVAIL_US' AS 'Key', 
          'ZAVAIL_US' AS AlternateKey, 
		   sg.eloquencefieldtag as Value 
		  FROM  
		   bookproductdetail bpd join subgentables sg on sg.tableid=bpd.tableid and sg.datacode=bpd.datacode and sg.datasubcode=bpd.datasubcode 
		   --and sg2.datasub2code=bpd.datasub2code 
		   WHERE bpd.tableid = 659 AND bpd.datacode in (2) AND bpd.datasubcode IN (1,8,15)--us
		  and bookkey = @bookkey and sg.eloquencefieldtag is NOT NULL and sg.exporteloquenceind=1
		  



	 RETURN
END
GO
GRANT SELECT ON dbo.qcs_get_misc_generic TO PUBLIC
