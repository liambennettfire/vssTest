IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'tmm_seesaw_maintain_xml_main')
BEGIN
  DROP  Procedure  tmm_seesaw_maintain_xml_main
END
GO

  CREATE 
    PROCEDURE dbo.tmm_seesaw_maintain_xml_main 
        @i_xmltype integer,
        @i_batchkey integer,
        @i_jobkey integer,
        @i_jobtypecode integer,
        @i_jobtypesubcode integer,
        @i_userid varchar(100),
        @o_error_code integer OUTPUT ,
        @o_error_desc varchar(255) OUTPUT 
    AS
      BEGIN
          DECLARE 
            @cursor_row$KEY1 integer,
            @cursor_row$KEY2 integer,
            @cursor_row$KEY3 integer,
            @v_messagetypecode integer,
            @v_msg varchar(4000),
            @v_msgshort varchar(255),
            @v_retcode integer,
            @v_error_desc varchar(2000),
            @v_jobkey integer,
            @v_batchkey integer,
            @return_sys_err_code integer,
            @return_nodata_err_code integer,
            @return_no_err_code integer          

          SET @return_sys_err_code =  -1
          SET @return_nodata_err_code = 0
          SET @return_no_err_code = 1
          SET @v_jobkey = @i_jobkey
          SET @v_batchkey = @i_batchkey

            BEGIN

              DECLARE 
                @cursor_row$KEY1$2 integer,
                @cursor_row$KEY2$2 integer,
                @cursor_row$KEY3$2 integer              

              DECLARE 
                keys_cursor CURSOR LOCAL 
                 FOR 
                  SELECT dbo.QSIEXPORTKEYS.KEY1, dbo.QSIEXPORTKEYS.KEY2, dbo.QSIEXPORTKEYS.KEY3
                    FROM dbo.QSIEXPORTKEYS
                    WHERE (dbo.QSIEXPORTKEYS.QSIBATCHKEY = @i_batchkey)
              

              OPEN keys_cursor

              FETCH NEXT FROM keys_cursor
                INTO @cursor_row$KEY1$2, @cursor_row$KEY2$2, @cursor_row$KEY3$2

              WHILE  NOT(@@FETCH_STATUS = -1)
                BEGIN

                  IF (@@FETCH_STATUS = -1)
                    BEGIN

                      SET @v_messagetypecode = 4

                      /*  Information */

                      SET @v_msg = 'No Rows on qsiexportkeys'

                      SET @v_msgshort = 'No Rows on qsiexportkeys'

                      EXEC dbo.WRITE_QSIJOBMESSAGE @v_batchkey OUTPUT, @v_jobkey OUTPUT, @i_jobtypecode, @i_jobtypesubcode, '', '', @i_userid, 0, 0, 0, @v_messagetypecode, @v_msg, @v_msgshort, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                      BREAK 

                    END

                  EXEC dbo.TMM_SEESAW_MAINTAIN_XML_ONIX21 @cursor_row$KEY1$2, @cursor_row$KEY2$2, @i_xmltype, @v_batchkey, @v_jobkey, @i_jobtypecode, @i_jobtypesubcode, @i_userid, @v_retcode OUTPUT, @v_error_desc OUTPUT 

                  IF (@v_retcode < 0)
                    BEGIN

                     /*  error should have been written to qsijobmessages already - just return */
                      SET @o_error_code = @v_retcode
                      SET @o_error_desc = @v_error_desc
                      RETURN 
                    END

                  FETCH NEXT FROM keys_cursor
                    INTO @cursor_row$KEY1$2, @cursor_row$KEY2$2, @cursor_row$KEY3$2
                END

              CLOSE keys_cursor
              DEALLOCATE keys_cursor
            END

            IF (cursor_status(N'local', N'keys_cursor') = 1)
              BEGIN
                CLOSE keys_cursor
                DEALLOCATE keys_cursor
              END

      END

go
grant execute on tmm_seesaw_maintain_xml_main  to public
go

