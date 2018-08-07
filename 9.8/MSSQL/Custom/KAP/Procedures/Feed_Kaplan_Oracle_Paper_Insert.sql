alter proc dbo.Feed_Kaplan_Oracle_Paper_Insert (@i_batchkey int, @i_gpokey int, @i_feedkapheaderkey int)
AS

BEGIN

DECLARE @i_materialkey int,
        @i_papersequence int

--cursor
	DECLARE cursor_paper INSENSITIVE CURSOR
	FOR

	Select materialkey 
	from materialspecs ms, gposection gs
	where gs.gpokey = @i_gpokey
	and gs.key1 = ms.bookkey
	and gs.key2 = ms.printingkey
	and gs.key3 = 3 --just printing components with paper

	FOR READ ONLY

	OPEN cursor_paper

	Select @i_papersequence = 0


	FETCH NEXT FROM cursor_paper
	INTO @i_materialkey

	while (@@FETCH_STATUS<>-1 )
	begin
		IF (@@FETCH_STATUS<>-2)
		begin


			Select @i_papersequence = @i_papersequence + 1

			print '@i_papersequence '
			print @i_papersequence

			insert into  Feed_Kaplan_Oracle_Paper 
				(feedkapheaderkey, 
				datecreated, 
				batchkey, 
				pokey,
				materialkey, 
				sequence, 
				paperisbn, 
				totalpaperallocation,
				rawmaterialcode)

				select  @i_feedkapheaderkey,
						getdate(),
						@i_batchkey,
						gs.gpokey,
						ms.materialkey,
						@i_papersequence,
						substring(ms.stockdesc,1,13),
						ms.allocation,
						ms.rmc
					from gposection gs, gpo g, compspec cs, materialspecs ms
					where g.gpokey = gs.gpokey
						and gs.key3 = cs.compkey
						and gs.key1 = cs.bookkey
						and gs.key2 = cs.printingkey
						and gs.key1 = ms.bookkey
						and gs.key2 = ms.printingkey
						and g.gpostatus = 'F'
						and cs.compkey = 3
						and ms.matsuppliercode = 2  -- 2 = Reserve  1 = Printer
					--	and ms.reserveind = 'Y'  THIS RETURNS NOTHING RIGHT NOW -- USING above instead 10/5/07
						and gs.gpokey = @i_gpokey
						and ms.materialkey = @i_materialkey

				print 'Feed_Kaplan_Oracle_Paper insert for gpokey: ' + CAST(@i_gpokey as varchar) 

		end
	FETCH NEXT FROM cursor_paper
	INTO @i_materialkey        
	
	end

close cursor_paper
deallocate cursor_paper

END
