IF EXISTS (
    SELECT *
    FROM sysobjects
    WHERE id = object_id('dbo.book_subtitle_copy')
      AND type = 'TR'
    )
  DROP TRIGGER [dbo].[book_subtitle_copy]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE TRIGGER [dbo].[book_subtitle_copy] ON [dbo].[book]
FOR INSERT
  ,UPDATE
AS
IF 
  UPDATE (copyfrombookkey)

BEGIN
  DECLARE @v_bookkey INT
    ,@v_bookkey_copiedfrom INT
    ,@v_subtitle VARCHAR(MAX)

  SELECT @v_bookkey = i.bookkey
    ,@v_bookkey_copiedfrom = ISNULL(i.copyfrombookkey, 0)
    ,@v_subtitle = ISNULL(i.subtitle, '')
  FROM inserted i
  JOIN gentables g ON g.tableid = 550
    AND g.qsicode = 1                  -- Only for Titles

  IF ISNULL(@v_bookkey, 0) > 0
    AND @v_bookkey_copiedfrom > 0
    AND @v_bookkey_copiedfrom <> @v_bookkey
    AND @v_subtitle = ''                -- Don't overwrite existing subtitle
  BEGIN
    SELECT @v_subtitle = ISNULL(subtitle, '')
    FROM book b
    WHERE b.bookkey = @v_bookkey_copiedfrom

    IF @v_subtitle <> ''
      UPDATE book
      SET subtitle = @v_subtitle
      WHERE bookkey = @v_bookkey
  END
END
GO

ALTER TABLE [dbo].[book] ENABLE TRIGGER [book_subtitle_copy]
GO


