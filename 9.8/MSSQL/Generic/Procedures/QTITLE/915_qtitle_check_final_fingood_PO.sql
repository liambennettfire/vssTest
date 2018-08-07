if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_check_final_fingood_po') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_check_final_fingood_po
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_check_final_fingood_po
 (@i_bookkey        integer,
  @i_printingkey    integer,
  @i_check_proforma integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*****************************************************************************************************
**  File: 
**  Name: qtitle_check_final_fingood_po
**  Desc: This stored procedure checks if a finalized finished good PO exists
**        for the bookkey/printingkey. 
** 
**        Returns:  1  no finalized finished good po exists
**                 -1  error
**                 -99 a finished good po exists
**
**    Auth: Alan Katzen
**    Date: 01 May 2006
*******************************************************************************************************
**    Change History
*******************************************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @count_var INT
  DECLARE @potypekey_var INT
  DECLARE @fingood_compkey_var INT
  DECLARE @check_proforma_var INT
  DECLARE @po_desc VARCHAR(20)

  IF @i_bookkey = 0 OR @i_bookkey is null BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to check for finalized finished good PO: Invalid Bookkey.'
    RETURN
  END 

  IF @i_printingkey = 0 OR @i_printingkey is null BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to check for finalized finished good PO: Invalid Printingkey.'
    RETURN
  END 

  SET @check_proforma_var = @i_check_proforma
  IF @check_proforma_var is null BEGIN
    SET @check_proforma_var = 0
  END 

  SELECT @count_var = count(*)
    FROM compspec
   WHERE bookkey = @i_bookkey AND
         printingkey = @i_printingkey AND
         activeind = 1 AND
         upper(finishedgoodind) = 'Y'

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error Retrieving From compspec: bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)  
    RETURN
  END 

  IF @count_var > 0 BEGIN
    SELECT DISTINCT @potypekey_var = potypekey, @fingood_compkey_var = compkey
      FROM compspec
     WHERE bookkey = @i_bookkey AND
           printingkey = @i_printingkey AND
           activeind = 1 AND
           upper(finishedgoodind) = 'Y'

    -- Save the @@ERROR and @@ROWCOUNT values in local 
    -- variables before they are cleared.
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Error Retrieving From compspec: bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)  
      RETURN
    END 

    SET @count_var = 0
    SET @po_desc = 'finalized'

    -- single title PO
    IF @potypekey_var = 1 BEGIN
      SELECT @count_var = count(*)
        FROM component c, gpo g
       WHERE c.bookkey = @i_bookkey AND
             c.printingkey = @i_printingkey AND
             c.compkey = @fingood_compkey_var AND
             c.pokey = g.gpokey AND
             upper(g.gpostatus) in ('F','I')

      -- Save the @@ERROR and @@ROWCOUNT values in local 
      -- variables before they are cleared.
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Error Retrieving From gpo (PO): bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)  
        RETURN
      END 

      -- look for a proforma PO
      IF @count_var = 0 AND @check_proforma_var = 1 BEGIN
        SET @po_desc = 'proforma'

        SELECT @count_var = count(*)
          FROM component c, gpo g
         WHERE c.bookkey = @i_bookkey AND
               c.printingkey = @i_printingkey AND
               c.compkey = @fingood_compkey_var AND
               c.pokey = g.gpokey AND
               upper(g.gpostatus) = 'P'

        -- Save the @@ERROR and @@ROWCOUNT values in local 
        -- variables before they are cleared.
        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Error Retrieving From gpo (PO): bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)  
          RETURN
        END 
      END
    END

    -- Finished Good XPO
    IF @potypekey_var = 2 BEGIN
      SELECT @count_var = count(*)
        FROM gposection s, gpo g
       WHERE s.key1 = @i_bookkey AND
             s.key2 = @i_printingkey AND
             s.gpokey = g.gpokey AND
             g.potypekey = @potypekey_var AND
             upper(g.gpostatus) in ('F','I')

      -- Save the @@ERROR and @@ROWCOUNT values in local 
      -- variables before they are cleared.
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Error Retrieving From gpo (XPO): bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)  
        RETURN
      END 

      -- look for a proforma PO
      IF @count_var = 0 AND @check_proforma_var = 1 BEGIN
        SET @po_desc = 'proforma'

        SELECT @count_var = count(*)
          FROM gposection s, gpo g
         WHERE s.key1 = @i_bookkey AND
               s.key2 = @i_printingkey AND
               s.gpokey = g.gpokey AND
               g.potypekey = @potypekey_var AND
               upper(g.gpostatus) = 'P'

        -- Save the @@ERROR and @@ROWCOUNT values in local 
        -- variables before they are cleared.
        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Error Retrieving From gpo (PO): bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)  
          RETURN
        END 
      END
    END

    -- Common Forms OR Gang Run PO
    IF @potypekey_var = 3 OR @potypekey_var = 4 BEGIN
      SELECT @count_var = count(*)
        FROM gposection s, gpo g
       WHERE s.key1 = @i_bookkey AND
             s.key2 = @i_printingkey AND
             s.key3 = @fingood_compkey_var AND
             s.sectiontype = 3 AND
             s.gpokey = g.gpokey AND
             upper(g.gpostatus) in ('F','I')

      -- Save the @@ERROR and @@ROWCOUNT values in local 
      -- variables before they are cleared.
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Error Retrieving From gpo (CFPO): bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)  
        RETURN
      END 

      -- look for a proforma PO
      IF @count_var = 0 AND @check_proforma_var = 1 BEGIN
        SET @po_desc = 'proforma'

        SELECT @count_var = count(*)
          FROM gposection s, gpo g
         WHERE s.key1 = @i_bookkey AND
               s.key2 = @i_printingkey AND
               s.key3 = @fingood_compkey_var AND
               s.sectiontype = 3 AND
               s.gpokey = g.gpokey AND
               upper(g.gpostatus) = 'P'

        -- Save the @@ERROR and @@ROWCOUNT values in local 
        -- variables before they are cleared.
        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Error Retrieving From gpo (PO): bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)  
          RETURN
        END 
      END
    END

    -- Assembly Order PO
    IF @potypekey_var = 5 BEGIN
      SELECT @count_var = count(*)
        FROM aopos a, gpo g
       WHERE a.bookkey = @i_bookkey AND
             a.printingkey = @i_printingkey AND
             a.gpokey = g.gpokey AND
             upper(g.gpostatus) in ('F','I')

      -- Save the @@ERROR and @@ROWCOUNT values in local 
      -- variables before they are cleared.
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Error Retrieving From gpo (AO): bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)  
        RETURN
      END 

      -- look for a proforma PO
      IF @count_var = 0 AND @check_proforma_var = 1 BEGIN
        SET @po_desc = 'proforma'

        SELECT @count_var = count(*)
          FROM aopos a, gpo g
         WHERE a.bookkey = @i_bookkey AND
               a.printingkey = @i_printingkey AND
               a.gpokey = g.gpokey AND
               upper(g.gpostatus) = 'P'

        -- Save the @@ERROR and @@ROWCOUNT values in local 
        -- variables before they are cleared.
        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @o_error_code = -1
          SET @o_error_desc = 'Error Retrieving From gpo (PO): bookkey = ' + cast(@i_bookkey AS VARCHAR) + ' and printingkey = ' + cast(@i_printingkey AS VARCHAR)  
          RETURN
        END 
      END
    END
 
    IF @count_var > 0 BEGIN
      SET @o_error_code = -99
      SET @o_error_desc = 'A ' + @po_desc + ' finished good PO exists for this title/printing.'
      RETURN
    END
  END
 
  SET @o_error_code = 0
  RETURN
GO

GRANT EXEC ON qtitle_check_final_fingood_po TO PUBLIC
GO
