IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ORIM_price_history]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ORIM_price_history]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
  
CREATE  PROCEDURE [dbo].[ORIM_price_history]  
  
AS  
BEGIN  

/* This SP was created to allow for tracking of price changes. It should be set up as an automated job to run daily.
   The results are stored in table ORIM_PriceChanges to pull data from as well as historically in ORIM_pricechange_history
   There is a view rpt_title_history_view that was created to pull this data as well as other changes to be used in a Crystal Report Change_Memo_Release_to_Prod
*/

/* ORIM_bookprice hold last snapshot of bookprice table - this will populate the table initially - end of proc will drop & create each time run */  
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.ORIM_bookprice') AND OBJECTPROPERTY(id, N'IsTable') = 1)  
 BEGIN  
  SELECT * INTO dbo.ORIM_bookprice  
    FROM bookprice bp   
   WHERE EXISTS (  
                  SELECT 1 
				    FROM printing p  
                   WHERE p.bookkey = bp.bookkey 
				     AND p.printingkey = 1
					 --AND bp.pricetypecode = 8  /*only MSRP */
					 --AND bp.currencytypecode in (6,11) /* only tracking US and Canadian prices */  
                     AND bp.finalprice IS NOT NULL 
				)   
 END   
 
/* ORIM_pricechanges hold the most recent update by price and currency type  */
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.ORIM_pricechanges') AND OBJECTPROPERTY(id, N'IsTable') = 1)  
 BEGIN  

   CREATE TABLE dbo.ORIM_pricechanges(  
     pricekey int,  
     bookkey int,  
     printingkey int,  
     fieldname varchar(100),  
     fielddescription varchar(256),  
     originalvalue varchar(255),  
     currentvalue varchar(255),  
     lastuserid varchar(30),  
     lastmaintdate datetime,  
     updatedate datetime,
	 activeind tinyint,
	 changedescription varchar(30) 
   )  
    
 END   
   
/* ORIM_pricechange_history hold all historic price changes (once sp is initiated) can be used for troubleshooting as well  */  
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.ORIM_pricechange_history') AND OBJECTPROPERTY(id, N'IsTable') = 1)  
 BEGIN  
   
   CREATE TABLE dbo.ORIM_pricechange_history(  
     pricekey int,  
     bookkey int,  
     printingkey int,  
     fieldname varchar(100),  
     fielddescription varchar(256),  
     originalvalue varchar(255),  
     currentvalue varchar(255),  
     lastuserid varchar(30),  
     lastmaintdate datetime,  
     updatedate datetime,
	 activeind tinyint,
	 changedescription varchar(30) 
   )  
    
 END   

/* grab updated prices   */ 
 SELECT   
       bp.pricekey, 
	   bp.bookkey, 
	   bp.currencytypecode, 
	   h.finalprice as previous_price, 
	   bp.finalprice,   
       bp.lastuserid, 
	   bp.lastmaintdate, 
	   bp.history_order,
	   bp.pricetypecode,
	   bp.activeind,
	   'Price Update ' as changedescription
INTO #temp_price  
 FROM dbo.ORIM_bookprice h   
 JOIN bookprice bp ON h.pricekey = bp.pricekey   -- to account for deleted ones 
WHERE ISNULL(h.finalprice, 0) <> bp.finalprice   

/* grab new entries */
INSERT into #temp_price   
SELECT bp.pricekey, 
       bp.bookkey, 
	   bp.currencytypecode, 
	   NULL, 
	   bp.finalprice,   
       bp.lastuserid, 
	   bp.lastmaintdate, 
	   bp.sortorder,
	   bp.pricetypecode,
	   bp.activeind,
	   'New Entry'
  FROM bookprice bp 
 WHERE bp.lastmaintdate >= getdate() -3 
   AND bp.pricekey not in ( SELECT pricekey FROM ORIM_bookprice h WHERE bp.bookkey = h.bookkey) 
   
/* grab deleted prices */  
INSERT into #temp_price   
SELECT h.pricekey, 
       h.bookkey, 
	   h.currencytypecode, 
	   h.finalprice, 
	   NULL,   
       h.lastuserid, 
	   h.lastmaintdate, 
	   h.history_order,
	   h.pricetypecode,
	   h.activeind,
	   'Deleted'
  FROM dbo.ORIM_bookprice h  
 WHERE NOT EXISTS ( SELECT 1 FROM dbo.bookprice bp WHERE bp.pricekey = h.pricekey)  

/* grab status changes */
INSERT into #temp_price
SELECT bp.pricekey, 
	   bp.bookkey, 
	   bp.currencytypecode, 
	   h.finalprice, 
	   bp.finalprice,   
       bp.lastuserid, 
	   bp.lastmaintdate, 
	   bp.history_order,
	   bp.pricetypecode,
	   bp.activeind,
	   'Status Change'
 FROM dbo.ORIM_bookprice h   
 JOIN bookprice bp ON h.pricekey = bp.pricekey   
WHERE bp.activeind <> h.activeind   

  
DECLARE @pricekey int   
DECLARE @bookkey int  
DECLARE @currencytypecode int  
DECLARE @previous_price float   
DECLARE @new_price float   
DECLARE @lastuserid varchar(30)  
DECLARE @lastmaintdate datetime
DECLARE @i_pricetypecode int  
DECLARE @sortorder int 
DECLARE @activeind tinyint 
DECLARE @changedescription varchar(30)
DECLARE @i_titlefetchstatus int 
 
  
 DECLARE c_price_changes CURSOR LOCAL  
   FOR  
     
   SELECT * FROM #temp_price   
   ORDER BY pricekey, lastmaintdate   
     
   FOR READ ONLY  
       
   OPEN c_price_changes  
  
   FETCH NEXT FROM c_price_changes  
              INTO  @pricekey, @bookkey ,@currencytypecode,@previous_price,@new_price,@lastuserid,@lastmaintdate, @sortorder, @i_pricetypecode, @activeind, @changedescription
       SELECT  @i_titlefetchstatus = @@FETCH_STATUS  
  
        WHILE (@i_titlefetchstatus >-1 )  
       BEGIN  
           IF (@i_titlefetchstatus <>-2)   
           BEGIN  
           
            INSERT into dbo.ORIM_pricechange_history  
              SELECT @pricekey, 
			         @bookkey, 
					 1, 
					 'Actual Price', 
					 'Price ' + CAST(@sortorder as varchar(10)) + ' - ' + dbo.rpt_Get_Price_Type_Description (@i_pricetypecode),  
                     (CASE WHEN @previous_price IS NULL THEN '(Not Present)'   
                           ELSE CAST(@previous_price as varchar(30)) + ' ' + dbo.rpt_get_gentables_desc (122, @currencytypecode,'short')
			           END
			         ),    
                     (CASE WHEN @new_price IS NULL THEN '(Deleted)'   
                           ELSE CAST(@new_price as varchar(30)) + ' ' + dbo.rpt_get_gentables_desc (122, @currencytypecode,'short') 
			           END
			          ),  
                     @lastuserid,  
                     @lastmaintdate,  
                     GETDATE(),
					 @activeind,
					 @changedescription  
            
          IF exists (SELECT 1 from dbo.ORIM_pricechanges where  pricekey = @pricekey)  
          BEGIN  
             
             UPDATE dbo.ORIM_pricechanges  
                SET originalvalue = (CASE WHEN @previous_price IS NULL THEN '(Not Present)'   
                                          ELSE CAST(@previous_price as varchar(30)) + ' ' + dbo.rpt_get_gentables_desc (122, @currencytypecode,'short') 
				  					  END
				  				    ),  
                    currentvalue = (CASE WHEN @new_price IS NULL THEN '(Deleted)'   
                                       ELSE CAST(@new_price as varchar(30)) + ' ' + dbo.rpt_get_gentables_desc (122, @currencytypecode,'short')  
								    END
								    ),   
                    lastuserid = @lastuserid,  
                    lastmaintdate = @lastmaintdate,  
                    updatedate = GETDATE(),
					activeind = @activeind,
					changedescription = @changedescription  
               FROM dbo.ORIM_pricechanges  
              WHERE pricekey  = @pricekey   

           END  

           ELSE   
           
		   BEGIN  
               INSERT INTO dbo.ORIM_pricechanges  
               SELECT @pricekey, 
			          @bookkey, 
					  1, 
					  'Actual Price', 
					  'Price ' + CAST(@sortorder as varchar(10)) + ' - ' + dbo.rpt_Get_Price_Type_Description (@i_pricetypecode),  
                      CASE WHEN @previous_price IS NULL THEN '(Not Present)'   
                           ELSE CAST(@previous_price as varchar(30)) + ' ' + dbo.rpt_get_gentables_desc (122, @currencytypecode,'short') 
					  END,    
                      CASE WHEN @new_price IS NULL THEN '(Deleted)'   
                           ELSE CAST(@new_price as varchar(30)) + ' ' + dbo.rpt_get_gentables_desc (122, @currencytypecode,'short')  
					  END,  
                     @lastuserid,  
                     @lastmaintdate,  
                     GETDATE(),
					 @activeind,
					 @changedescription  
             END   
  
        END  
        FETCH NEXT FROM c_price_changes  
                   INTO  @pricekey, @bookkey ,@currencytypecode,@previous_price,@new_price,@lastuserid,@lastmaintdate, @sortorder, @i_pricetypecode, @activeind, @changedescription    
             SELECT  @i_titlefetchstatus  = @@FETCH_STATUS  
       END  
       
  
       CLOSE c_price_changes  
  DEALLOCATE c_price_changes   
 
  
DROP TABLE #temp_price  
 
/* Grab the most recent prices */  
  
DROP TABLE dbo.ORIM_bookprice  
  
 SELECT * INTO dbo.ORIM_bookprice  
    FROM bookprice bp   
   WHERE EXISTS (  
                  SELECT 1 
				    FROM printing p  
                   WHERE p.bookkey = bp.bookkey 
				     AND p.printingkey = 1
					 --AND bp.pricetypecode = 8  /*only MSRP */
					 --AND bp.currencytypecode in (6,11) /* only tracking US and Canadian prices */
                     AND bp.finalprice IS NOT NULL 
				)  
END  
  
  
GO