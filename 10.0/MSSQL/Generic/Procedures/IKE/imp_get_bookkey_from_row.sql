/******************************************************************************
**  Name: imp_get_bookkey_from_row
**  Desc: IKE retrieve bookkey from a given feedback row
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.imp_get_bookkey_from_row') AND type = 'FN')
	DROP function [dbo].[imp_get_bookkey_from_row]
GO
CREATE FUNCTION [dbo].[imp_get_bookkey_from_row]
  (@i_batchkey int, @i_row_id int)
   RETURNS int
BEGIN
  declare
    @v_count int,
    @v_bookkey int,
    @o_bookkey int,
    @v_elementkey int,
    @v_originalvalue varchar(500),
    @v_destinationtable varchar(500),
    @v_destinationcolumn varchar(500),
    @v_lead_value varchar(500),
    @v_sqlblock nvarchar(4000),
    @v_bookkey_parmdef nvarchar(2000),
    @v_returncode int,
    @v_returnmsg varchar(500)
  
  -- look for isbn
  if @v_bookkey is null
    begin
      select @v_originalvalue=originalvalue
        from imp_batch_detail
        where batchkey=@i_batchkey
          and row_id=@i_row_id
          and elementkey=100010000  
      if @v_originalvalue is not null
        begin
          select @v_bookkey=bookkey
            from isbn 
            where isbn=@v_originalvalue
        end
    end

  -- look for isbn10
  if @v_bookkey is null
    begin
      select @v_originalvalue=originalvalue
        from imp_batch_detail
        where batchkey=@i_batchkey
          and row_id=@i_row_id
          and elementkey=100010001  
      if @v_originalvalue is not null
        begin
          select @v_bookkey=bookkey
            from isbn 
            where isbn10=@v_originalvalue
        end
    end

  -- look for ean
  if @v_bookkey is null
    begin
      select @v_originalvalue=originalvalue
        from imp_batch_detail
        where batchkey=@i_batchkey
          and row_id=@i_row_id
          and elementkey=100010002  
      if @v_originalvalue is not null
        begin
          select @v_bookkey=bookkey
            from isbn 
            where ean=@v_originalvalue
        end
    end

  -- look for ean13
  if @v_bookkey is null
    begin
      select @v_originalvalue=originalvalue
        from imp_batch_detail
        where batchkey=@i_batchkey
          and row_id=@i_row_id
          and elementkey=100010003  
      if @v_originalvalue is not null
        begin
          select @v_bookkey=bookkey
            from isbn 
            where ean13=@v_originalvalue
        end
    end

  -- look for ItemNo
  if @v_bookkey is null
    begin
      select @v_originalvalue=originalvalue
        from imp_batch_detail
        where batchkey=@i_batchkey
          and row_id=@i_row_id
          and elementkey=100010007  
      if @v_originalvalue is not null
        begin
          select @v_bookkey=bookkey
            from isbn 
            where itemnumber=@v_originalvalue
        end
    end

  RETURN @v_bookkey
END
go

