IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.import_contact_phone') AND (type = 'P' OR type = 'RF'))
  BEGIN
    DROP proc dbo.import_contact_phone
  END

GO

CREATE PROCEDURE dbo.import_contact_phone 
   (@batchkey INT, @importsrckey INT, @phone VARCHAR(30), @phonecodedesc VARCHAR(50), 
    @userid VARCHAR(30), @phoneindex VARCHAR(2), @importstatus INT OUTPUT, @phonecode INT OUTPUT)
AS
  DECLARE @impmsg VARCHAR(255)

  IF (@phone IS NULL) OR (@phone = '')
    BEGIN
      SELECT @phonecode = NULL
    END
  ELSE
    BEGIN
      EXEC gentable_by_desc_import @importsrckey, 209, @phonecodedesc, 'N', @phonecode OUTPUT
      IF (@phonecode IS NULL)
        BEGIN
          SELECT @impmsg = 'Phone ' + @phoneindex + ' description could not be mapped. Description is "' + @phonecodedesc + '".'
          EXEC importmsg @importsrckey, @batchkey, 2, 2, @impmsg, @userid
          SELECT @importstatus = 140
        END
    END

RETURN

GO

GRANT EXECUTE ON  dbo.import_contact_phone TO PUBLIC

GO
