BEGIN
  DECLARE @v_gpokey INT,
	  @v_taqprojectcontactkey	INT,
	  @v_taqprojectkey	INT,
	  @v_globalcontactkey INT,
	  @v_conversionkey INT,
	  @v_vendorkey INT,
	  @v_correctglobalcontactkey INT,
	  @v_correctgroupname varchar(255),
	  @NumberRecords INT,
	  @RowCount INT

  CREATE TABLE #gpoconversion (
	RowID int IDENTITY (1,1),
	taqprojectcontactkey	INT,
	taqprojectkey	INT,
	globalcontactkey INT,
	conversionkey INT,
	vendorkey INT,
	correctglobalcontactkey INT,
	correctgroupname varchar(255))
	
  insert into #gpoconversion
  select distinct tpc.taqprojectcontactkey,tpc.taqprojectkey,tpc.globalcontactkey,gc.conversionkey,g.vendorkey,
  (select globalcontactkey from globalcontact gc2 where gc2.conversionkey = g.vendorkey) correctglobalcontactkey,
  (select groupname from globalcontact gc2 where gc2.conversionkey = g.vendorkey) correctgroupname
  from taqprojectcontact tpc, globalcontact gc, gpo g
  where tpc.globalcontactkey = gc.globalcontactkey
  and g.gpokey = tpc.taqprojectkey
  and g.vendorkey <> gc.conversionkey
  
  --SELECT * from #gpoconversion
  --order by taqprojectcontactkey,taqprojectkey,globalcontactkey

  SET @NumberRecords	= @@ROWCOUNT
  SET @RowCount = 1

  --print '@NumberRecords'
  --print @NumberRecords

  WHILE @RowCount <= @NumberRecords BEGIN
    SELECT @v_taqprojectcontactkey = taqprojectcontactkey, @v_taqprojectkey = taqprojectkey, @v_correctglobalcontactkey = correctglobalcontactkey
      FROM #gpoconversion
     WHERE ROWID = @RowCount

    IF @v_correctglobalcontactkey > 0 BEGIN
      --print '@v_taqprojectcontactkey'
      --print @v_taqprojectcontactkey

      update taqprojectcontact
         set globalcontactkey = @v_correctglobalcontactkey
       where taqprojectcontactkey = @v_taqprojectcontactkey
         and taqprojectkey = @v_taqprojectkey
    END

  	SET @RowCount = @RowCount + 1
  END
 
  DROP TABLE #gpoconversion
END
go