--CREATE PROCEDURE [dbo].[qutl_insert_subgentable_value]
-- (@i_tableid              integer,
--  @i_datacode             integer,
--  @i_tablemnemonic        varchar (40),
--  @i_qsicode              integer,
--  @i_datadesc             varchar (40),
--  @i_sortorder   		  integer,
--  @i_lockbyqsiind		  integer,
--  @o_datasubcode          integer output,
--  @o_error_code           integer output,
--  @o_error_desc			  varchar(2000) output)

BEGIN

  DECLARE
   @v_datacode		       integer,
   @v_datasubcode integer,
   @v_error_code  integer,
   @v_error_desc varchar(2000)  
   
   ---A Codes Datacode 1
   SET @v_datacode = 1
   
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'A305 - Synchronised audio', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Synchronised audio',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'A305',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78'  
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'A410 - Mono', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Mono',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'A410',
    lockbyeloquenceind = 1,   lastuserid =  'CONV FROM Code List 78'  
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'A420 - Stereo', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Stereo',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'A4210',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'A421 - Stereo 2.1', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Stereo 2.1',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'A421',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'A441 - Surround 4.1', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Surround 4.1',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'A441',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'A451 - Surround 5.1', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Surround 5.1',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'A451',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode

	---B Codes Datacode 2
   SET @v_datacode = 2
   
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'B211 - Toy / die-cut book', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Toy / die-cut',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'B211',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'B314 - Coiled wire bound', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Coiled wire bound',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'B314',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'B315 - Trade binding', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Trade binding',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'B315',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'B400 - Self-cover', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Self-cover',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'B400',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'B416 - Card cover', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Card cover',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'B416',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'B511 - With foldout', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'With foldout',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'B511',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'B512 - Wide margin', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Wide margin',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'B512',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'B513 - With fastening strap', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'W. fastening strap',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'B513',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'B514 - With perforated pages', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'W. perforated pages',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'B514',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'B610 - Syllabification', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Syllabification',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'B610',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
   
   ---D Codes Datacode 3
   SET @v_datacode = 3
   
   ---E Codes Datacode 4
   SET @v_datacode = 4
   
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'E210 - Landscape', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Landscape',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'E210',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'E211 - Portrait', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Portrait',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'E211',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'E221 - 5:4', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = '5:4',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'E221',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'E222 - 4:3', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = '4:3',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'E222',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'E223 - 3:2', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = '5:4',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'E223',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'E224 - 16:10', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = '16:10',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'E224',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'E225 - 16:9', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = '16:9',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'E225',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
    
   ---P Codes Datacode 6
   SET @v_datacode = 6
   
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'P120 - Picture story cards', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Picture story cards',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'P120',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'P201 - Hardback (stationery)', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Hardback',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'P201',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'P202 - Paperback / softback (stationery)', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Paperback / softback',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'P202',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'P203 - Spiral bound (stationery)', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Spiral bound',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'P203',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'P204 - Leather / fine binding (stationery)', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Leather/fine bind.',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'P204',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
    exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'P301 - With hanging straps', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'W. hanging straps',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'P301',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
    
   ---V Codes Datacode 7
   SET @v_datacode = 7
   
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'V220 - Home use', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Home use',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'V220',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
    
   exec qutl_insert_subgentable_value 654, @v_datacode,'PRDFMDTL',NULL,'V221 - Classroom use', NULL,1,
	@v_datasubcode OUTPUT,@v_error_code OUTPUT,@v_error_desc OUTPUT
   UPDATE subgentables SET datadescshort = 'Classroom use',acceptedbyeloquenceind = 1, exporteloquenceind = 1, eloquencefieldtag = 'V221',
    lockbyeloquenceind = 1,  lastuserid =  'CONV FROM Code List 78' 
    WHERE tableid = 654 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
END  
  
 GO