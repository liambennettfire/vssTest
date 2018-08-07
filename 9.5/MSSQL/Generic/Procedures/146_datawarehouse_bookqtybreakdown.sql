-- 6/17/04 - PV - CRM 01285 - The WH Qty Breakdown tables should be built 
-- from a stored procedure which can be called either from an Incremental 
-- or Full Build procedure.  Build both tables according to bookkey,
-- printingkey and control table. ** Be sure to create a row on both tables 
-- at all times even if no rows exist on Quantity Breakdown

PRINT 'STORED PROCEDURE : dbo.datawarehouse_bookqtybreakdown'
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = 
		Object_id('dbo.datawarehouse_bookqtybreakdown') AND (type = 'P' OR type = 'RF'))
BEGIN
	DROP PROC dbo.datawarehouse_bookqtybreakdown
END

GO

CREATE  proc dbo.datawarehouse_bookqtybreakdown
@ware_bookkey int, @ware_system_date datetime

AS

DECLARE @ware_qtyoutlet			INT
DECLARE @ware_qtyoutletcode		INT
DECLARE @ware_qtyoutletsubcode		INT
DECLARE @ware_qtyoutlettype_long	VARCHAR(40)
DECLARE @ware_qtyoutlet_long		VARCHAR(40)
DECLARE @ware_qtyoutlettype_short	VARCHAR(20)
DECLARE @ware_qtyoutlet_short		VARCHAR(20)
DECLARE @ware_linenum  INT

DECLARE warehousebookqtybreakdown CURSOR FOR
      SELECT qtyoutletcode, qtyoutletsubcode, linenumber
      FROM whcqtybreakdown

BEGIN

	DELETE FROM whqtybreakdown
	WHERE bookkey = @ware_bookkey

	INSERT INTO whqtybreakdown (bookkey, lastuserid, lastmaintdate)
	  VALUES (@ware_bookkey, 'WARE_STORED_PROC', @ware_system_date)

	DELETE FROM whprintingqtybreakdown
	WHERE bookkey = @ware_bookkey AND
		printingkey = 1

	INSERT INTO whprintingqtybreakdown (bookkey, printingkey, lastuserid, lastmaintdate)
	  VALUES (@ware_bookkey, 1, 'WARE_STORED_PROC', @ware_system_date)


	OPEN warehousebookqtybreakdown

	FETCH NEXT FROM warehousebookqtybreakdown
	  INTO @ware_qtyoutletcode, @ware_qtyoutletsubcode, @ware_linenum

	WHILE (@@FETCH_STATUS <> - 1)
	  BEGIN

/** CRM 1684: Initialize the qty variable - added by DSL 8/5/2004 **/ 
		select @ware_qtyoutlet = 0 

		SELECT @ware_qtyoutlet = qty
                FROM bookqtybreakdoWn
                WHERE bookkey = @ware_bookkey AND
  			printingkey = 1 AND
			qtyoutletcode = @ware_qtyoutletcode AND
			qtyoutletsubcode = @ware_qtyoutletsubcode

		IF @ware_qtyoutletcode > 0 
		  BEGIN
			exec gentables_longdesc 527,@ware_qtyoutletcode,@ware_qtyoutlettype_long OUTPUT
			exec  gentables_shortdesc 527,@ware_qtyoutletcode,@ware_qtyoutlettype_short OUTPUT
			select @ware_qtyoutlettype_short = substring(@ware_qtyoutlettype_short,1,20)
		  END
		ELSE
		  BEGIN
			select @ware_qtyoutlettype_long  = ''
			select @ware_qtyoutlettype_short = ''
		  END

		IF @ware_qtyoutletsubcode > 0 
		  BEGIN
			exec subgent_longdesc 527,@ware_qtyoutletcode, @ware_qtyoutletsubcode,@ware_qtyoutlet_long OUTPUT
			exec  subgent_shortdesc 527,@ware_qtyoutletcode,@ware_qtyoutletsubcode,@ware_qtyoutlet_short OUTPUT
			select @ware_qtyoutlet_short = substring(@ware_qtyoutlet_short,1,20)
		  END
		ELSE
		  BEGIN
			select @ware_qtyoutlet_long  = ''
			select @ware_qtyoutlet_short = ''
		  END

		IF @ware_linenum = 1 
                  BEGIN
                  	UPDATE whqtybreakdown 
			SET qtyoutlettypedesc1 = @ware_qtyoutlettype_long, 
				qtyoutletdesc1 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc1 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc1 = @ware_qtyoutlet_short,
				qtyoutletqty1 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey

			UPDATE whprintingqtybreakdown 
			SET qtyoutlettypedesc1 = @ware_qtyoutlettype_long, 
				qtyoutletdesc1 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc1 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc1 = @ware_qtyoutlet_short,
				qtyoutletqty1 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey AND printingkey = 1
                  END
               	ELSE IF @ware_linenum = 2 
                  BEGIN
                     	UPDATE whqtybreakdown 
			SET qtyoutlettypedesc2 = @ware_qtyoutlettype_long,
				qtyoutletdesc2 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc2 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc2 = @ware_qtyoutlet_short,
				qtyoutletqty2 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey

			UPDATE whprintingqtybreakdown 
			SET qtyoutlettypedesc2 = @ware_qtyoutlettype_long, 
				qtyoutletdesc2 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc2 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc2 = @ware_qtyoutlet_short,
				qtyoutletqty2 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey AND printingkey = 1
                  END
               	ELSE IF @ware_linenum = 3 
                  BEGIN
                     	UPDATE whqtybreakdown 
			SET qtyoutlettypedesc3 = @ware_qtyoutlettype_long,
				qtyoutletdesc3 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc3 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc3 = @ware_qtyoutlet_short,
				qtyoutletqty3 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey

			UPDATE whprintingqtybreakdown 
			SET qtyoutlettypedesc3 = @ware_qtyoutlettype_long, 
				qtyoutletdesc3 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc3 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc3 = @ware_qtyoutlet_short,
				qtyoutletqty3 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey AND printingkey = 1
                  END
               	ELSE IF @ware_linenum = 4 
                  BEGIN
                     	UPDATE whqtybreakdown 
			SET qtyoutlettypedesc4 = @ware_qtyoutlettype_long,
				qtyoutletdesc4 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc4 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc4 = @ware_qtyoutlet_short,
				qtyoutletqty4 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey

			UPDATE whprintingqtybreakdown 
			SET qtyoutlettypedesc4 = @ware_qtyoutlettype_long, 
				qtyoutletdesc4 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc4 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc4 = @ware_qtyoutlet_short,
				qtyoutletqty4 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey AND printingkey = 1
                  END
               	ELSE IF @ware_linenum = 5 
                  BEGIN
                     	UPDATE whqtybreakdown 
			SET qtyoutlettypedesc5 = @ware_qtyoutlettype_long,
				qtyoutletdesc5 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc5 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc5 = @ware_qtyoutlet_short,
				qtyoutletqty5 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey

			UPDATE whprintingqtybreakdown 
			SET qtyoutlettypedesc5 = @ware_qtyoutlettype_long, 
				qtyoutletdesc5 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc5 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc5 = @ware_qtyoutlet_short,
				qtyoutletqty5 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey AND printingkey = 1
                  END
               	ELSE IF @ware_linenum = 6 
                  BEGIN
                     	UPDATE whqtybreakdown 
			SET qtyoutlettypedesc6 = @ware_qtyoutlettype_long,
				qtyoutletdesc6 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc6 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc6 = @ware_qtyoutlet_short,
				qtyoutletqty6 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey

			UPDATE whprintingqtybreakdown 
			SET qtyoutlettypedesc6 = @ware_qtyoutlettype_long, 
				qtyoutletdesc6 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc6 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc6 = @ware_qtyoutlet_short,
				qtyoutletqty6 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey AND printingkey = 1
                  END
               	ELSE IF @ware_linenum = 7 
                  BEGIN
                     	UPDATE whqtybreakdown 
			SET qtyoutlettypedesc7 = @ware_qtyoutlettype_long,
				qtyoutletdesc7 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc7 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc7 = @ware_qtyoutlet_short,
				qtyoutletqty7 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey

			UPDATE whprintingqtybreakdown 
			SET qtyoutlettypedesc7 = @ware_qtyoutlettype_long, 
				qtyoutletdesc7 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc7 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc7 = @ware_qtyoutlet_short,
				qtyoutletqty7 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey AND printingkey = 1
                  END
               	ELSE IF @ware_linenum = 8 
                  BEGIN
                     	UPDATE whqtybreakdown 
			SET qtyoutlettypedesc8 = @ware_qtyoutlettype_long,
				qtyoutletdesc8 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc8 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc8 = @ware_qtyoutlet_short,
				qtyoutletqty8 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey

			UPDATE whprintingqtybreakdown 
			SET qtyoutlettypedesc8 = @ware_qtyoutlettype_long, 
				qtyoutletdesc8 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc8 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc8 = @ware_qtyoutlet_short,
				qtyoutletqty8 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey AND printingkey = 1
                  END
               	ELSE IF @ware_linenum = 9 
                  BEGIN
                     	UPDATE whqtybreakdown 
			SET qtyoutlettypedesc9 = @ware_qtyoutlettype_long,
				qtyoutletdesc9 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc9 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc9 = @ware_qtyoutlet_short,
				qtyoutletqty9 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey

			UPDATE whprintingqtybreakdown 
			SET qtyoutlettypedesc9 = @ware_qtyoutlettype_long, 
				qtyoutletdesc9 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc9 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc9 = @ware_qtyoutlet_short,
				qtyoutletqty9 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey AND printingkey = 1
                  END
               	ELSE IF @ware_linenum = 10 
                  BEGIN
         		UPDATE whqtybreakdown 
			SET qtyoutlettypedesc10 = @ware_qtyoutlettype_long,
				qtyoutletdesc10 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc10 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc10 = @ware_qtyoutlet_short,
				qtyoutletqty10 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey

			UPDATE whprintingqtybreakdown 
			SET qtyoutlettypedesc10 = @ware_qtyoutlettype_long, 
				qtyoutletdesc10 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc10 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc10 = @ware_qtyoutlet_short,
				qtyoutletqty10 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey AND printingkey = 1
                  END
               	ELSE IF @ware_linenum = 11 
                  BEGIN
                     	UPDATE whqtybreakdown 
			SET qtyoutlettypedesc11 = @ware_qtyoutlettype_long,
				qtyoutletdesc11 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc11 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc11 = @ware_qtyoutlet_short,
				qtyoutletqty11 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey

			UPDATE whprintingqtybreakdown 
			SET qtyoutlettypedesc11 = @ware_qtyoutlettype_long, 
				qtyoutletdesc11 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc11 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc11 = @ware_qtyoutlet_short,
				qtyoutletqty11 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey AND printingkey = 1
                  END
               	ELSE IF @ware_linenum = 12 
                  BEGIN
                     	UPDATE whqtybreakdown 
			SET qtyoutlettypedesc12 = @ware_qtyoutlettype_long,
				qtyoutletdesc12 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc12 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc12 = @ware_qtyoutlet_short,
				qtyoutletqty12 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey

			UPDATE whprintingqtybreakdown 
			SET qtyoutlettypedesc12 = @ware_qtyoutlettype_long, 
				qtyoutletdesc12 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc12 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc12 = @ware_qtyoutlet_short,
				qtyoutletqty12 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey AND printingkey = 1
                  END
               	ELSE IF @ware_linenum = 13 
                  BEGIN
                     	UPDATE whqtybreakdown 
			SET qtyoutlettypedesc13 = @ware_qtyoutlettype_long,
				qtyoutletdesc13 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc13 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc13 = @ware_qtyoutlet_short,
				qtyoutletqty13 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey

			UPDATE whprintingqtybreakdown 
			SET qtyoutlettypedesc13 = @ware_qtyoutlettype_long, 
				qtyoutletdesc13 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc13 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc13 = @ware_qtyoutlet_short,
				qtyoutletqty13 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey AND printingkey = 1
                  END
               	ELSE IF @ware_linenum = 14 
                  BEGIN
                     	UPDATE whqtybreakdown 
			SET qtyoutlettypedesc14 = @ware_qtyoutlettype_long,
				qtyoutletdesc14 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc14 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc14 = @ware_qtyoutlet_short,
				qtyoutletqty14 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey

			UPDATE whprintingqtybreakdown 
			SET qtyoutlettypedesc14 = @ware_qtyoutlettype_long, 
				qtyoutletdesc14 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc14 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc14 = @ware_qtyoutlet_short,
				qtyoutletqty14 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey AND printingkey = 1
                  END
               	ELSE IF @ware_linenum = 15 
                  BEGIN
                     	UPDATE whqtybreakdown 
			SET qtyoutlettypedesc15 = @ware_qtyoutlettype_long,
				qtyoutletdesc15 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc15 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc15 = @ware_qtyoutlet_short,
				qtyoutletqty15 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey

			UPDATE whprintingqtybreakdown 
			SET qtyoutlettypedesc15 = @ware_qtyoutlettype_long, 
				qtyoutletdesc15 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc15 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc15 = @ware_qtyoutlet_short,
				qtyoutletqty15 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey AND printingkey = 1
                  END
               	ELSE IF @ware_linenum = 16 
                  BEGIN
                     	UPDATE whqtybreakdown 
			SET qtyoutlettypedesc16 = @ware_qtyoutlettype_long,
				qtyoutletdesc16 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc16 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc16 = @ware_qtyoutlet_short,
				qtyoutletqty16 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey

			UPDATE whprintingqtybreakdown 
			SET qtyoutlettypedesc16 = @ware_qtyoutlettype_long, 
				qtyoutletdesc16 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc16 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc16 = @ware_qtyoutlet_short,
				qtyoutletqty16 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey AND printingkey = 1
                  END
               	ELSE IF @ware_linenum = 17 
                  BEGIN
                     	UPDATE whqtybreakdown 
			SET qtyoutlettypedesc17 = @ware_qtyoutlettype_long,
				qtyoutletdesc17 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc17 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc17 = @ware_qtyoutlet_short,
				qtyoutletqty17 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey

			UPDATE whprintingqtybreakdown 
			SET qtyoutlettypedesc17 = @ware_qtyoutlettype_long, 
				qtyoutletdesc17 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc17 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc17 = @ware_qtyoutlet_short,
				qtyoutletqty17 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey AND printingkey = 1
                  END
               	ELSE IF @ware_linenum = 18 
                  BEGIN
                     	UPDATE whqtybreakdown 
			SET qtyoutlettypedesc18 = @ware_qtyoutlettype_long,
				qtyoutletdesc18 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc18 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc18 = @ware_qtyoutlet_short,
				qtyoutletqty18 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey

			UPDATE whprintingqtybreakdown 
			SET qtyoutlettypedesc18 = @ware_qtyoutlettype_long, 
				qtyoutletdesc18 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc18 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc18 = @ware_qtyoutlet_short,
				qtyoutletqty18 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey AND printingkey = 1
                  END
               	ELSE IF @ware_linenum = 19 
                  BEGIN
                     	UPDATE whqtybreakdown 
			SET qtyoutlettypedesc19 = @ware_qtyoutlettype_long,
				qtyoutletdesc19 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc19 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc19 = @ware_qtyoutlet_short,
				qtyoutletqty19 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey

			UPDATE whprintingqtybreakdown 
			SET qtyoutlettypedesc19 = @ware_qtyoutlettype_long, 
				qtyoutletdesc19 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc19 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc19 = @ware_qtyoutlet_short,
				qtyoutletqty19 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey AND printingkey = 1
                  END
               	ELSE IF @ware_linenum = 20 
                  BEGIN
                     	UPDATE whqtybreakdown 
			SET qtyoutlettypedesc20 = @ware_qtyoutlettype_long,
				qtyoutletdesc20 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc20 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc20 = @ware_qtyoutlet_short,
				qtyoutletqty20 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey

			UPDATE whprintingqtybreakdown 
			SET qtyoutlettypedesc20 = @ware_qtyoutlettype_long, 
				qtyoutletdesc20 = @ware_qtyoutlet_long,
				qtyoutlettypeshortdesc20 = @ware_qtyoutlettype_short,
				qtyoutletshortdesc20 = @ware_qtyoutlet_short,
				qtyoutletqty20 = @ware_qtyoutlet
			WHERE bookkey = @ware_bookkey AND printingkey = 1
                  END


		FETCH NEXT FROM warehousebookqtybreakdown 
		INTO @ware_qtyoutletcode, @ware_qtyoutletsubcode, @ware_linenum
	  END
      
	CLOSE warehousebookqtybreakdown
	DEALLOCATE warehousebookqtybreakdown
END

GO

GRANT EXECUTE ON  dbo.datawarehouse_bookqtybreakdown TO PUBLIC

GO