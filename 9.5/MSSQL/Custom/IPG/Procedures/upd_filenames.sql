/* Drop the PROCEDURE if it exists */
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.upd_filenames') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.upd_filenames
END
GO

/****** Object:  StoredProcedure [dbo].[upd_filenames]    Script Date: 02/29/2012 14:33:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE upd_filenames (@i_path varchar(2000), @i_typecode int) AS
  declare
    @c_filename       varchar(50)

  declare
    @v_isbn     varchar(50),
    @v_extension  varchar(13),
    @v_formatcode   int,
    @v_typecode   int,
    @v_est_start   int,
    @v_book_hit   int,
   -- @v_next_key   int,
    @v_newkey1		int,
    @v_newkey2		int,
    @v_bookkey   int

  declare imp_filename cursor for 
    select 
      file_name
      from importfilenames

  open imp_filename

  fetch imp_filename into 
    @c_filename       

  if @@fetch_status = -1
    goto exitloop

  while @@fetch_status = 0
    begin

      if @c_filename is not null 
        begin
          set @v_est_start =PATINDEX ( '%.%' , @c_filename ) 
          if @v_est_start > 1
            begin
              set @v_isbn = substring(@c_filename,1,@v_est_start-1)
              set @v_extension = substring(@c_filename,@v_est_start,len(@c_filename)-@v_est_start)
            end
          else 
            goto skip_to_fetch
        end
      else
        goto skip_to_fetch
      if len(@v_isbn)=13
        begin
          select @v_book_hit=count(*)
            from isbn 
            where ean13=@v_isbn
          if @v_book_hit = 1
            select @v_bookkey = bookkey
            from isbn 
            where ean13=@v_isbn
          else 
            goto skip_to_fetch
        end 
      else 
        goto skip_to_fetch

      select @v_book_hit=count(*)
        from filelocation
        where bookkey=@v_bookkey
          and printingkey=1
          and filetypecode=@i_typecode 
      if @v_book_hit = 1
        update filelocation
          set pathname=@i_path+'\'+@c_filename
          where bookkey=@v_bookkey
            and printingkey=1
            and filetypecode=@i_typecode ;
      else
        begin
     --     update keys set generickey=generickey+1
     --     select @v_next_key=generickey from keys
     	    execute get_next_key 'QSIADMIN',@v_newkey1 OUTPUT
     	    execute get_next_key 'QSIADMIN',@v_newkey2 OUTPUT
          insert filelocation
            (bookkey,printingkey,filetypecode,filelocationkey,pathname,filelocationgeneratedkey,lastuserid,lastmaintdate)
            values
            (@v_bookkey,1,@i_typecode,@v_newkey1,@i_path+'\'+@c_filename,@v_newkey2,'import',getdate());
        end

      skip_to_fetch:

      fetch imp_filename into 
        @c_filename       

      if @@fetch_status = -1
        goto exitloop 

     end

  exitloop:

  close imp_filename
  deallocate imp_filename

GO
