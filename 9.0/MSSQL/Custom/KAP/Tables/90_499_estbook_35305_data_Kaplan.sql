DECLARE
	@v_estkey INT

execute get_next_key 'QSIDBA',@v_estkey OUTPUT

INSERT INTO estbook (estkey, bookkey, printingkey, lastuserid, lastmaintdate)
VALUES (@v_estkey, 11430189, 2, 'QSIDBA', GETDATE())