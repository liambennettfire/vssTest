PRINT 'STORED PROCEDURE : dbo.datawarehouse_bookcmnt_parse'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_bookcmnt_parse') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_bookcmnt_parse
end

GO

CREATE  proc dbo.datawarehouse_bookcmnt_parse
@ware_bookkey int, @ware_logkey int, @ware_warehousekey int,
@ware_system_date datetime,@ware_commenttypecode int,@ware_commenttypesubcode int,
@ware_beginline int,@ware_endline int,@ware_commentline int,@ware_releasetoeloq varchar

AS 

DECLARE @out_val VARCHAR(8000) 
DECLARE @out_length INTEGER  
DECLARE @ll_length int
DECLARE @ll_begin int 
DECLARE @v_src_len int 
DECLARE @v_src_pointer binary(16) 
DECLARE @v_dst_pointer binary(16) 

DECLARE @ware_length int 
DECLARE @ware_length2 int 
DECLARE @ware_totallength int 


SELECT @v_src_len = datalength(commenttext),
       @v_src_pointer = TEXTPTR(commenttext)
  FROM bookcomments 
  WHERE bookkey = @ware_bookkey
    and printingkey = 1
    and commenttypecode = @ware_commenttypecode 
    and commenttypesubcode = @ware_commenttypesubcode


 
  IF @ware_commentline > 0 
    begin
     IF @v_src_len > 0 
       begin
BEGIN tran
      if @ware_commentline = 1 
        begin
          update whtitlecomments
            set commenttext1 = 'x',
              releloind1 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext1)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext1 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 2   
         begin
          update whtitlecomments
            set commenttext2 = 'x',
              releloind2 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext2)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext2 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 3 
        begin
          update whtitlecomments
            set commenttext3 = 'x',
              releloind3 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext3)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext3 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 4 
        begin
          update whtitlecomments
            set commenttext4 = 'x',
              releloind4 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext4)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext4 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 5 
        begin
          update whtitlecomments
            set commenttext5 = 'x',
              releloind5 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext5)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext5 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 6 
         begin
          update whtitlecomments
            set commenttext6 = 'x',
              releloind6 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext6)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext6 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 7 
        begin
          update whtitlecomments
            set commenttext7 = 'x',
              releloind7 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext7)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext7 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 8 
        begin
          update whtitlecomments
            set commenttext8 = 'x',
              releloind8 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext8)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext8 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 9 
        begin
          update whtitlecomments
            set commenttext9 = 'x',
              releloind9 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext9)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext9 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 10 
        begin
          update whtitlecomments
            set commenttext10 = 'x',
              releloind10 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext10)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext10 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 11 
        begin
          update whtitlecomments
            set commenttext11 = 'x',
              releloind11 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext11)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext11 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 12 
        begin
          update whtitlecomments
            set commenttext12 = 'x',
              releloind12 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext12)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext12 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 13 
        begin
          update whtitlecomments
            set commenttext13 = 'x',
              releloind13 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext13)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext13 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 14 
        begin
          update whtitlecomments
            set commenttext14 = 'x',
              releloind14 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext14)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext14 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 15 
        begin
          update whtitlecomments
            set commenttext15 = 'x',
              releloind15 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext15)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext15 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 16 
        begin
          update whtitlecomments
            set commenttext16 = 'x',
              releloind16 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext16)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext16 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 17 
        begin
          update whtitlecomments
            set commenttext17 = 'x',
              releloind17 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext17)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext17 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 18 
        begin
          update whtitlecomments
            set commenttext18 = 'x',
              releloind18 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext18)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext18 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 19
         begin
          update whtitlecomments
            set commenttext19 = 'x',
              releloind19 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext19)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext19 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 20 
        begin
          update whtitlecomments
            set commenttext20 = 'x',
              releloind20 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext20)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext20 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 21 
        begin
          update whtitlecomments
            set commenttext21 = 'x',
              releloind21 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext21)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext21 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 22 
        begin
          update whtitlecomments
            set commenttext22 = 'x',
              releloind22 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext22)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext22 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 23 
        begin
          update whtitlecomments
            set commenttext23 = 'x',
              releloind23 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext23)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext23 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 24 
        begin
          update whtitlecomments
            set commenttext24 = 'x',
              releloind24 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext24)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext24 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 25 
        begin
          update whtitlecomments
            set commenttext25 = 'x',
              releloind25 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext25)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext25 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 26 
        begin
          update whtitlecomments
            set commenttext26 = 'x',
              releloind26 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext26)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext26 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 27 
        begin
          update whtitlecomments
            set commenttext27 = 'x',
              releloind27 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext27)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext27 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 28 
        begin        
          update whtitlecomments
            set commenttext28 = 'x',
              releloind28 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext28)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext28 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 29 
        begin
          update whtitlecomments
            set commenttext29 = 'x',
              releloind29 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext29)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext29 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 30 
        begin
          update whtitlecomments
            set commenttext30 = 'x',
              releloind30 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext30)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext30 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 31 
        begin
          update whtitlecomments
            set commenttext31 = 'x',
              releloind31 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext31)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext31 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 32 
        begin
          update whtitlecomments
            set commenttext32 = 'x',
              releloind32 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext32)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext32 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 33 
        begin
          update whtitlecomments
            set commenttext33 = 'x',
              releloind33 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext33)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext33 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 34 
        begin
          update whtitlecomments
            set commenttext34 = 'x',
              releloind34 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext34)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext34 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 35 
        begin
          update whtitlecomments
            set commenttext35 = 'x',
              releloind35 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext35)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext35 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 36 
        begin
          update whtitlecomments
            set commenttext36 = 'x',
              releloind36 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext36)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext36 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 37 
        begin
          update whtitlecomments
            set commenttext37 = 'x',
              releloind37 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext37)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext37 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 38 
        begin
          update whtitlecomments
            set commenttext38 = 'x',
              releloind38 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext38)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext38 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 39 
        begin
          update whtitlecomments
            set commenttext39 = 'x',
              releloind39 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext39)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext39 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 40 
        begin
          update whtitlecomments
            set commenttext40 = 'x',
              releloind40 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext40)
            FROM whtitlecomments 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments.commenttext40 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 41 
        begin
          update whtitlecomments2
            set commenttext41 = 'x',
              releloind41 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext41)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext41 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 42 
        begin
          update whtitlecomments2
            set commenttext42 = 'x',
              releloind42 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext42)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext42 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 43 
        begin
          update whtitlecomments2
            set commenttext43 = 'x',
              releloind43 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext43)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext43 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 44 
        begin
          update whtitlecomments2
            set commenttext44 = 'x',
              releloind44 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext44)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext44 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 45 
        begin
          update whtitlecomments2
            set commenttext45 = 'x',
              releloind45 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext45)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext45 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 46 
        begin
          update whtitlecomments2
            set commenttext46 = 'x',
              releloind46 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext46)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext46 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 47 
        begin
          update whtitlecomments2
            set commenttext47 = 'x',
              releloind47 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext47)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext47 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 48 
        begin
          update whtitlecomments2
            set commenttext48 = 'x',
              releloind48 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext48)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext48 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 49 
        begin
          update whtitlecomments2
            set commenttext49 = 'x',
              releloind49 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext49)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext49 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 50 
        begin
          update whtitlecomments2
            set commenttext50 = 'x',
              releloind50 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext50)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext50 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 51   
        begin
          update whtitlecomments2
            set commenttext51 = 'x',
              releloind51 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext51)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext51 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 52 
        begin
          update whtitlecomments2
            set commenttext52 = 'x',
              releloind52 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext52)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext52 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 53 
        begin
          update whtitlecomments2
            set commenttext53 = 'x',
              releloind53 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext53)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext53 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 54 
        begin
          update whtitlecomments2
            set commenttext54 = 'x',
              releloind54 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext54)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext54 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 55 
        begin
          update whtitlecomments2
            set commenttext55 = 'x',
              releloind55 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext55)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext55 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 56 
        begin
          update whtitlecomments2
            set commenttext56 = 'x',
              releloind56 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext56)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext56 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 57 
        begin
          update whtitlecomments2
            set commenttext57 = 'x',
              releloind57 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext57)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext57 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 58 
        begin
          update whtitlecomments2
            set commenttext58 = 'x',
              releloind58 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext58)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext58 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 59 
        begin
          update whtitlecomments2
            set commenttext59 = 'x',
              releloind59 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext59)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext59 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 60 
        begin
          update whtitlecomments2
            set commenttext60 = 'x',
              releloind60 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext60)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext60 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 61 
        begin
          update whtitlecomments2
            set commenttext61 = 'x',
              releloind61 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext61)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext61 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 62 
        begin
          update whtitlecomments2
            set commenttext62 = 'x',
              releloind62 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext62)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext62 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 63 
        begin
          update whtitlecomments2
            set commenttext63 = 'x',
              releloind63 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext63)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext63 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 64 
        begin
          update whtitlecomments2
            set commenttext64 = 'x',
              releloind64 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext64)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext64 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 65 
        begin
          update whtitlecomments2
            set commenttext65 = 'x',
              releloind65 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext65)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext65 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 66 
        begin
          update whtitlecomments2
            set commenttext66 = 'x',
              releloind66 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext66)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext66 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 67 
        begin
          update whtitlecomments2
            set commenttext67 = 'x',
              releloind67 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext67)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext67 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 68 
        begin
          update whtitlecomments2
            set commenttext68 = 'x',
              releloind68 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext68)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext68 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 69 
        begin
          update whtitlecomments2
            set commenttext69 = 'x',
              releloind69 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext69)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext69 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 70 
        begin
          update whtitlecomments2
            set commenttext70 = 'x',
              releloind70 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext70)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext70 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 71 
        begin
          update whtitlecomments2
            set commenttext71 = 'x',
              releloind71 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext71)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext71 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 72 
        begin
          update whtitlecomments2
            set commenttext72 = 'x',
              releloind72 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext72)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext72 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 73 
        begin
          update whtitlecomments2
            set commenttext73 = 'x',
              releloind73 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext73)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext73 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 74 
        begin
          update whtitlecomments2
            set commenttext74 = 'x',
              releloind74 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext74)
            FROM whtitlecomments2
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext74 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 75 
        begin
          update whtitlecomments2
            set commenttext75 = 'x',
              releloind75 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext75)
            FROM whtitlecomments2
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext75 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 76 
        begin
          update whtitlecomments2
            set commenttext76 = 'x',
              releloind76 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext76)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext76 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 77 
        begin
          update whtitlecomments2
            set commenttext77 = 'x',
              releloind77 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext77)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext77 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 78 
        begin
          update whtitlecomments2
            set commenttext78 = 'x',
              releloind78 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext78)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext78 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 79 
        begin
          update whtitlecomments2
            set commenttext79 = 'x',
              releloind79 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext79)
            FROM whtitlecomments2 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext79 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 80 
        begin
          update whtitlecomments2
            set commenttext80 = 'x',
              releloind80 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext80)
            FROM whtitlecomments2
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments2.commenttext80 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 81 
        begin
          update whtitlecomments3
            set commenttext81 = 'x',
              releloind81 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext81)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext81 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end  
      if @ware_commentline = 82 
        begin
          update whtitlecomments3
            set commenttext82 = 'x',
              releloind82 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext82)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext82 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 83 
        begin
          update whtitlecomments3
            set commenttext83 = 'x',
              releloind83 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext83)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext83 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 84 
        begin
          update whtitlecomments3
            set commenttext84 = 'x',
              releloind84 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext84)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext84 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 85 
        begin
          update whtitlecomments3
            set commenttext85 = 'x',
              releloind85 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext85)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext85 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 86 
        begin
          update whtitlecomments3
            set commenttext86 = 'x',
              releloind86 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext86)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext86 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 87 
      begin
          update whtitlecomments3
            set commenttext87 = 'x',
              releloind87 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext87)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext87 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
      end
      if @ware_commentline = 88 
        begin
          update whtitlecomments3
            set commenttext88 = 'x',
              releloind88 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext88)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext88 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 89 
        begin
          update whtitlecomments3
            set commenttext89 = 'x',
              releloind89 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext89)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext89 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 90 
        begin
          update whtitlecomments3
            set commenttext90 = 'x',
              releloind90 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext90)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext90 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 91 
        begin
          update whtitlecomments3
            set commenttext91 = 'x',
              releloind91 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext91)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext91 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 92 
        begin
          update whtitlecomments3
            set commenttext92 = 'x',
              releloind92 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext92)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext92 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 93 
        begin
          update whtitlecomments3
            set commenttext93 = 'x',
              releloind93 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext93)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext93 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 94 
        begin
          update whtitlecomments3
            set commenttext94 = 'x',
              releloind94 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext94)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext94 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 95 
        begin
          update whtitlecomments3
            set commenttext95 = 'x',
              releloind95 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext95)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext95 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
          end
      if @ware_commentline = 96 
        begin
          update whtitlecomments3
            set commenttext96 = 'x',
              releloind96 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext96)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext96 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 97 
        begin
          update whtitlecomments3
            set commenttext97 = 'x',
              releloind97 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext97)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext97 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 98         
        begin
          update whtitlecomments3
            set commenttext98 = 'x',
              releloind98 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext98)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext98 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 99 
        begin
          update whtitlecomments3
            set commenttext99 = 'x',
              releloind99 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext99)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext99 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 100 
        begin
          update whtitlecomments3
            set commenttext100 = 'x',
              releloind100 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext100)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext100 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 101 
        begin
          update whtitlecomments3
            set commenttext101 = 'x',
              releloind101 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext101)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext101 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 102 
        begin
          update whtitlecomments3
            set commenttext102 = 'x',
              releloind102 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext102)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext102 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 103 
        begin
          update whtitlecomments3
            set commenttext103 = 'x',
              releloind103 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext103)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext103 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 104 
        begin
          update whtitlecomments3
            set commenttext104 = 'x',
              releloind104 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext104)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext104 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 105 
        begin
          update whtitlecomments3
            set commenttext105 = 'x',
              releloind105 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext105)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext105 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 106 
        begin
          update whtitlecomments3
            set commenttext106 = 'x',
              releloind106 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext106)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext106 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 107 
        begin
          update whtitlecomments3
            set commenttext107 = 'x',
              releloind107 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext107)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext107 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 108 
        begin
          update whtitlecomments3
            set commenttext108 = 'x',
              releloind108 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext108)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext108 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 109 
        begin
          update whtitlecomments3
            set commenttext109 = 'x',
              releloind109 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext109)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext109 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 110 
        begin
          update whtitlecomments3
            set commenttext110 = 'x',
              releloind110 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext110)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext110 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 111 
        begin
          update whtitlecomments3
            set commenttext111 = 'x',
              releloind111 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext111)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext111 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 112 
        begin
          update whtitlecomments3
            set commenttext112 = 'x',
              releloind112 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext112)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext112 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 113 
        begin
          update whtitlecomments3
            set commenttext113 = 'x',
              releloind113 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext113)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext113 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 114 
        begin
          update whtitlecomments3
            set commenttext114 = 'x',
              releloind114 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext114)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext114 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 115 
        begin
          update whtitlecomments3
            set commenttext115 = 'x',
              releloind115 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext115)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext115 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 116 
        begin
          update whtitlecomments3
            set commenttext116 = 'x',
              releloind116 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext116)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext116 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 117 
        begin
          update whtitlecomments3
            set commenttext117 = 'x',
              releloind117 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext117)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext117 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 118 
      begin
          update whtitlecomments3
            set commenttext118 = 'x',
              releloind118 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext118)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext118 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 119 
        begin
          update whtitlecomments3
            set commenttext119 = 'x',
              releloind119 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext119)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext119 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
      if @ware_commentline = 120 
        begin
          update whtitlecomments3
            set commenttext120 = 'x',
              releloind120 = @ware_releasetoeloq
            where bookkey= @ware_bookkey
          SELECT  @v_dst_pointer = TEXTPTR(commenttext120)
            FROM whtitlecomments3 
            where bookkey= @ware_bookkey
          UPDATETEXT whtitlecomments3.commenttext120 @v_dst_pointer 0 null bookcomments.commenttext @v_src_pointer 
        end
commit tran
         END  /* @ware_length2 > 0 */
    
--    END  /*@ware_totallength */
 END  /* comment line > 0 */
GO