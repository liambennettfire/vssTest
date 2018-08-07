IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'get_htmllite_procedure')
BEGIN
  DROP  Procedure  get_htmllite_procedure
END
GO
  CREATE 
    PROCEDURE dbo.get_htmllite_procedure
      (
        @i_bookkey integer,
	@i_printingkey integer,
        @i_commenttypecode integer,
        @i_commenttypesubcode integer,
	@i_start integer,
	@i_length integer,
	@i_string varchar(8000) output
      ) 
    AS
BEGIN
set @i_string = ''

              SELECT @i_string = substring(BOOKCOMMENTS.COMMENTHTMLLITE, @i_start, @i_length)
                FROM BOOKCOMMENTS
                WHERE BOOKCOMMENTS.COMMENTTYPECODE = @i_commenttypecode AND 
                      BOOKCOMMENTS.COMMENTTYPESUBCODE = @i_commenttypesubcode AND 
                      BOOKCOMMENTS.BOOKKEY = @i_bookkey and
		      printingkey = @i_printingkey
			

END
GO

grant execute on get_htmllite_procedure  to public
go
