PRINT 'STORED PROCEDURE : dbo.Merge_Custom_IPG'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.Merge_Custom_IPG') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.Merge_Custom_IPG 
end

GO
CREATE PROCEDURE Merge_Custom_IPG (@i_bookkey int) AS

begin
  declare @v_rows int
  declare @v_newline varchar(10)
  declare @v_text varchar(4000)
  declare @v_html varchar(4000)
  declare @v_label varchar(100)
  declare @v_float float
  declare @v_ind int
  declare @v_int int

  --set @v_newline = char(13)+char(10)
  set @v_newline = ', '
  set @v_text = ' '

  -- Color Photo (customfloat01)
  select @v_float = customfloat01
    from bookcustom
    where bookkey=@i_bookkey
  select @v_label = customfieldlabel 
    from customfieldsetup
    where customfieldname='customfloat01'
  if @v_float is not null
    set @v_text = @v_text + COALESCE(cast(@v_float as varchar(20)),' ') + ' ' + COALESCE(dbo.Remove_plural(@v_label,@v_float ),' ') + @v_newline

  -- B&W Photo (customfloat03)
  select @v_float = customfloat03
    from bookcustom
    where bookkey=@i_bookkey
  select @v_label = customfieldlabel 
    from customfieldsetup
    where customfieldname='customfloat03'
  if @v_float is not null
    set @v_text = @v_text + COALESCE(cast(@v_float as varchar(20)),' ') + ' ' + COALESCE(dbo.Remove_plural(@v_label,@v_float ),' ') + @v_newline

  -- Color Illustration (customfloat02)
  select @v_float = customfloat02
    from bookcustom
    where bookkey=@i_bookkey
  select @v_label = customfieldlabel 
    from customfieldsetup
    where customfieldname='customfloat02'
  if @v_float is not null
    set @v_text = @v_text + COALESCE(cast(@v_float as varchar(20)),' ') + ' ' + COALESCE(dbo.Remove_plural(@v_label,@v_float ),' ') + @v_newline

  -- B&W Illustration (customfloat04)
  select @v_float = customfloat04
    from bookcustom
    where bookkey=@i_bookkey
  select @v_label = customfieldlabel 
    from customfieldsetup
    where customfieldname='customfloat04'
  if @v_float is not null
    set @v_text = @v_text + COALESCE(cast(@v_float as varchar(20)),' ') + ' ' + COALESCE(dbo.Remove_plural(@v_label,@v_float ),' ') + @v_newline

  -- Line Drawings (customint01)
  select @v_int = customint01
    from bookcustom
    where bookkey=@i_bookkey
  select @v_label = customfieldlabel 
    from customfieldsetup
    where customfieldname='customint01'
  if @v_int is not null
    set @v_text = @v_text + COALESCE(cast(@v_int as varchar(20)),' ') + ' ' + COALESCE(dbo.Remove_plural(@v_label,@v_int ),' ') + @v_newline
  
  -- Watercolor Illustrations (customfloat05)
  select @v_float = customfloat05
    from bookcustom
    where bookkey=@i_bookkey
  select @v_label = customfieldlabel 
    from customfieldsetup
    where customfieldname='customfloat05'
  if @v_float is not null
    set @v_text = @v_text + COALESCE(cast(@v_float as varchar(20)),' ') + ' ' + COALESCE(dbo.Remove_plural(@v_label,@v_float),' ') + @v_newline

  -- Charts (customint02)
  select @v_int = customint02
    from bookcustom
    where bookkey=@i_bookkey
  select @v_label = customfieldlabel 
    from customfieldsetup
    where customfieldname='customint02'
  if @v_int is not null
    set @v_text = @v_text + COALESCE(cast(@v_int as varchar(20)),' ') + ' ' + COALESCE(dbo.Remove_plural(@v_label,@v_int ),' ') + @v_newline

  -- Tables (customint03)
  select @v_int = customint03
    from bookcustom
    where bookkey=@i_bookkey
  select @v_label = customfieldlabel 
    from customfieldsetup
    where customfieldname='customint03'
  if @v_int is not null
    set @v_text = @v_text + COALESCE(cast(@v_int as varchar(20)),' ') + ' ' + COALESCE(dbo.Remove_plural(@v_label,@v_int ),' ') + @v_newline

  -- Graphs (customint04)
  select @v_int = customint04
    from bookcustom
    where bookkey=@i_bookkey
  select @v_label = customfieldlabel 
    from customfieldsetup
    where customfieldname='customint04'
  if @v_int is not null
    set @v_text = @v_text + COALESCE(cast(@v_int as varchar(20)),' ') + ' ' + COALESCE(dbo.Remove_plural(@v_label,@v_int ),' ') + @v_newline

  -- Diagrams (customint05)
  select @v_int = customint05
    from bookcustom
    where bookkey=@i_bookkey
  select @v_label = customfieldlabel 
    from customfieldsetup
    where customfieldname='customint05'
  if @v_int is not null
    set @v_text = @v_text + COALESCE(cast(@v_int as varchar(20)),' ') + ' ' + COALESCE(dbo.Remove_plural(@v_label,@v_int ),' ') + @v_newline

  -- Maps (customint06)
  select @v_int = customint06
    from bookcustom
    where bookkey=@i_bookkey
  select @v_label = customfieldlabel 
    from customfieldsetup
    where customfieldname='customint06'
  if @v_int is not null
    set @v_text = @v_text + COALESCE(cast(@v_int as varchar(20)),' ') + ' ' + COALESCE(dbo.Remove_plural(@v_label,@v_int ),' ') + @v_newline

  -- Screen Shots (customint07)
  select @v_int = customint07
    from bookcustom
    where bookkey=@i_bookkey
  select @v_label = customfieldlabel 
    from customfieldsetup
    where customfieldname='customint07'
  if @v_int is not null
    set @v_text = @v_text + COALESCE(cast(@v_int as varchar(20)),' ') + ' ' + COALESCE(dbo.Remove_plural(@v_label,@v_int ),' ') + @v_newline

  -- Reproducables (customint10)
  select @v_int = customint10
    from bookcustom
    where bookkey=@i_bookkey
  select @v_label = customfieldlabel 
    from customfieldsetup
    where customfieldname='customint10'
  if @v_int is not null
    set @v_text = @v_text + COALESCE(cast(@v_int as varchar(20)),' ') + ' ' + COALESCE(dbo.Remove_plural(@v_label,@v_int ),' ') + @v_newline

  -- Two Color Interior (customind09)
  select @v_ind = customind09
    from bookcustom
    where bookkey=@i_bookkey
  select @v_label = customfieldlabel 
    from customfieldsetup
    where customfieldname='customind09'
  if @v_ind >0
    set @v_text = @v_text + COALESCE(@v_label,' ') + @v_newline

  -- Four Color Interior (customind10)
  select @v_ind = customind10
    from bookcustom
    where bookkey=@i_bookkey
  select @v_label = customfieldlabel 
    from customfieldsetup
    where customfieldname='customind10'
  if @v_ind >0
    set @v_text = @v_text + COALESCE(@v_label,' ') + @v_newline

  -- update or insert comment rows
  if @v_text is not null and @v_text <> '' 
    begin
      -- remove leading spaces and trailing separator
      set @v_text = ltrim(@v_text)
      if substring(@v_text,len(@v_text),len(@v_newline))=@v_newline and len(@v_text)>len(@v_newline)
        set @v_text = substring(@v_text,1,len(@v_text)-len(@v_newline))
	
      set @v_html = dbo.plaintext_to_html(@v_text)    
	
      select @v_rows = count(*)
        from bookcomments
        where bookkey =  @i_bookkey
          and printingkey = 1
          and commenttypecode=4
          and commenttypesubcode=20005
      if @v_rows=0 or @v_rows is null
        begin
          insert into bookcomments
            (bookkey,printingkey,commenttypecode,commenttypesubcode,commenttext,commenthtml, commenthtmllite, lastuserid,lastmaintdate)
            values
            (@i_bookkey,1,4,20005,@v_text,@v_html,@v_html, 'qsi_i',getdate())
        end 
      else
        begin
          update bookcomments
            set commenttext = @v_text,
		commenthtml = replace(@v_html, @v_newline,'<BR>'),
		commenthtmllite = replace(@v_html, @v_newline,'<BR>'),
                lastuserid='qsi_u',
                lastmaintdate=getdate()
            where bookkey =  @i_bookkey
              and printingkey = 1
              and commenttypecode=4
              and commenttypesubcode=20005
        end
      end
    else
      begin
        select @v_rows = count(*)
          from bookcomments
          where bookkey =  @i_bookkey
            and printingkey = 1
            and commenttypecode=4
            and commenttypesubcode=20005
        if @v_rows>0 or @v_rows is null
          begin
            delete bookcomments
            where bookkey =  @i_bookkey
              and printingkey = 1
              and commenttypecode=4
              and commenttypesubcode=20005
          end 
        select @v_rows = count(*)
          from bookcommentrtf
          where bookkey =  @i_bookkey
            and printingkey = 1
            and commenttypecode=4
            and commenttypesubcode=20005
      end
end

GO


