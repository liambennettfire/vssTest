IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_assoc_title_price]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_assoc_title_price]
GO

Create FUNCTION [dbo].[rpt_get_assoc_title_price]  
  (@i_bookkey INT,  
  @i_order INT,  
  @i_type  INT)  
  
RETURNS VARCHAR(10)  
  
/* The purpose of the rpt_get_assoc_title_author function is to return a the Price  from associated title table  
 for the row specified by the @i_order (sort order) parameter.    
  
 Parameter Options  
  bookkey  
  
  
  Order  
   1 = Returns first Associate Title Type  
   2 = Returns second Associate Title Type  
   3 = Returns third Associate Title Type  
   4  
   5  
   .  
   .  
   .  
   n   
  
  Type  
   1 = Competitive Titles  
   2 = Comparative Titles  
   3 = Author Sales Track    
   4 = BISAC Related Titles  
  
*/   
  
AS  
  
BEGIN  
  
 DECLARE @RETURN   VARCHAR(10)  
 DECLARE @v_price  VARCHAR(10)  
 DECLARE @i_assocbookkey  INT  
  
 SELECT @i_assocbookkey = associatetitlebookkey  
 FROM associatedtitles  
 WHERE bookkey = @i_bookkey   
   AND sortorder = @i_order   
   AND associationtypecode = @i_type  
  
  
 IF @i_assocbookkey > 0  
  BEGIN  
   SELECT @v_price = dbo.rpt_get_price(@i_assocbookkey,8,6,'B')  
   FROM book  
   WHERE bookkey = @i_assocbookkey  
  END  
 ELSE  
  BEGIN  
   SELECT @v_price = CONVERT(VARCHAR,price)  
   FROM associatedtitles  
   WHERE bookkey = @i_bookkey   
     AND sortorder = @i_order  
     AND associationtypecode = @i_type  
  END  
  
 IF LEN(@v_price) > 0  
  BEGIN  
   SELECT @RETURN = @v_price  
  END  
 ELSE  
  BEGIN  
   SELECT @RETURN = ''  
  END  
  
  
RETURN @RETURN  
  
  
END  

Go
Grant all on rpt_get_assoc_title_price to public  