/******************************************************************************
**  Name: imp_gentables
**  Desc: IKE Insert gentables
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.imp_gentables') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.imp_gentables
END
GO

CREATE PROCEDURE [dbo].[imp_gentables](
			@Tableid 	INT,
			@code			VARCHAR(40),
			@elementdesc		VARCHAR(255),
			@ColumnCheck		CHAR(1),
  			@AddInd		 	CHAR(1),
			@datacode 		INT		OUTPUT,
			@newcodeind		INT		OUTPUT) 
AS
	DECLARE @tablemnemonic			VARCHAR(40)
	SET @newcodeind = 0
	BEGIN
		IF COALESCE(@Elementdesc,'') = ''
			BEGIN
				SELECT @datacode = NULL
			END
  		ELSE
			BEGIN
				SELECT @datacode = NULL
				IF UPPER(@ColumnCheck) = 'D' 
					SELECT @datacode = datacode
					FROM gentables 	
					WHERE tableid = @Tableid 
							AND UPPER(datadesc) = UPPER(@Elementdesc)
				IF UPPER(@ColumnCheck) ='S' 
					SELECT @datacode = datacode
					FROM gentables
					WHERE tableid = @Tableid 
							AND UPPER(datadescshort) = UPPER(@Elementdesc)
				IF UPPER(@ColumnCheck) ='E' 
					SELECT @datacode = datacode
					FROM gentables
					WHERE tableid = @Tableid 
							AND UPPER(datadesc) = UPPER(@Elementdesc)
				IF UPPER(@ColumnCheck) ='B' 
					SELECT @datacode = datacode
					FROM gentables
					WHERE tableid = @Tableid 
							AND UPPER(datadesc) = UPPER(@Elementdesc)
				IF UPPER(@ColumnCheck) ='1' 
				 	SELECT @datacode = datacode
					FROM gentables
					WHERE tableid = @Tableid 
							AND UPPER(datadesc) = UPPER(@Elementdesc)
				IF UPPER(@ColumnCheck) ='2' 
					SELECT @datacode = datacode
					FROM gentables 
					WHERE tableid = @Tableid 
							AND UPPER(datadesc) = UPPER(@Elementdesc)
				IF UPPER(@ColumnCheck) ='T' 
					SELECT @datacode = datacode
					FROM gentables
					WHERE tableid = @Tableid 
							AND UPPER(datadesc) = UPPER(@Elementdesc)
										
				IF (@datacode IS NULL) AND (UPPER(@AddInd) = 'Y')
  					BEGIN
        					SELECT @datacode = MAX(datacode) + 1
        					FROM gentables
        					WHERE tableid=@Tableid
        
		       				IF @datacode IS NULL
        						SET @datacode = 1
        
						SELECT @tablemnemonic = tablemnemonic
        					FROM gentablesdesc
        					WHERE tableid = @Tableid
        	
						INSERT gentables
            						(tableid, datacode, datadesc, datadescshort,tablemnemonic, externalcode,alternatedesc1,lastuserid,lastmaintdate)
          					VALUES
          						(@Tableid, @datacode, SUBSTRING(@Elementdesc,1,40), SUBSTRING(@Elementdesc,1,20),@tablemnemonic,@code ,
							SUBSTRING(@Elementdesc,1,255),'imp_gentable', getdate())
						SET @newcodeind = 1
	        			END
			END
	END
  



