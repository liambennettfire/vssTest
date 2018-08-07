IF exists (select * from dbo.sysobjects where id = object_id(N'feed_insert_gentables') and xtype in (N'FN', N'IF', N'TF'))
  DROP PROCEDURE feed_insert_gentables

GO


  CREATE PROCEDURE feed_insert_gentables
       @feedin_tableid INT,
       @feedin_gent_insert varchar(40), 
       @feedin_datacode int output
    AS
      BEGIN

        DECLARE 
          @feedin_count INT,
          @feedin_tablemon VARCHAR(30),
          @feedin_concat VARCHAR(100), 
          @feedin_concat2 VARCHAR(200), 
          @feedin_concat3 VARCHAR(200)    

        SELECT @feedin_count = count(*)
          FROM gentables
         WHERE tableid = @feedin_tableid

        IF @feedin_count > 0
        BEGIN
           SELECT @feedin_datacode = MAX(datacode)
             FROM gentables
            WHERE tableid = @feedin_tableid 
        END 
        ELSE
        BEGIN
          SET @feedin_datacode = 0
		  END

		  SET @feedin_datacode = @feedin_datacode + 1

		  SELECT DISTINCT @feedin_tablemon = tablemnemonic
          FROM gentablesdesc
         WHERE tableid = @feedin_tableid

        SET @feedin_concat = 'Undefined for' + @feedin_gent_insert

        INSERT INTO dbo.gentables
          (tableid,datacode,datadesc,deletestatus,sortorder,tablemnemonic,externalcode,datadescshort,eloquencefieldtag)
          	VALUES(@feedin_tableid,@feedin_datacode,@feedin_concat,'N',@feedin_datacode,@feedin_tablemon,
                 @feedin_gent_insert,@feedin_gent_insert,'N/A')

		  SET @feedin_concat = 'Gentable row inserted for tableid' + @feedin_tableid + ' and datacode ';
        SET @feedin_concat2 =  @feedin_datacode + ' and description ' + @feedin_gent_insert;
        SET @feedin_concat3 = @feedin_concat + @feedin_concat2
         

        INSERT INTO dbo.feederror(batchnumber,processdate,errordesc)
            VALUES('3',getdate(),@feedin_concat3)
         
     END

GO



