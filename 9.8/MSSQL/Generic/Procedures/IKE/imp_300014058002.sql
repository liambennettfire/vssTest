/******************************************************************************
**  Name: imp_300014058002
**  Desc: IKE Add/Replace Territories
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300014058002]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300014058002]
GO

CREATE PROCEDURE dbo.imp_300014058002 
  
  @i_batch int, 
  @i_row int , 
  @i_dmlkey bigint, 
  @i_titlekeyset varchar(500),
  @i_contactkeyset varchar(500),
  @i_templatekey int,
  @i_elementseq int,
  @i_level int,
  @i_userid varchar(50),
  @i_newtitleind int,
  @i_newcontactind int,
  @o_writehistoryind int output
AS

/* Add/Replace Territories */

BEGIN 

SET NOCOUNT ON
/* DEFINE BATCH VARIABLES		*/
DECLARE @v_elementval		VARCHAR(4000),
	@v_errcode		INT,
  	@v_errmsg 		VARCHAR(4000),
	@v_elementdesc		VARCHAR(4000),
	@v_elementkey		BIGINT,
	@v_lobcheck 		VARCHAR(20),
	@v_lobkey 		INT,
	@v_bookkey 		INT

/*  DEFINE LOCAL VARIABLES		*/
DECLARE 
	@v_ORIGTerritoriesCode		INT,
	@v_NEWTerritoriescode		INT,
	@v_hit			INT,
	@v_datacode int,
	@v_datadesc varchar(max), 
	@DEBUG INT
		
BEGIN
	SET @v_hit = 0
	SET @v_ORIGTerritoriesCode = 0
	SET @v_NEWTerritoriescode = 0
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_errmsg = 'Territories updated'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
	SET @DEBUG=0

/*  GET IMPORTED Territories 			*/
	SELECT @v_elementval =  LTRIM(RTRIM(originalvalue)),
		@v_elementkey = b.elementkey
	FROM imp_batch_detail b , imp_DML_elements d
	WHERE b.batchkey = @i_batch
      				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND d.dmlkey = @i_dmlkey
				AND d.elementkey = b.elementkey


/* GET CURRENT CURRENT Territories VALUE		*/
	SELECT @v_ORIGTerritoriesCode = COALESCE(Territoriescode,0)
	FROM book
    	WHERE bookkey=@v_bookkey 

/* FIND IMPORT Territories ON GENTABLES 		*/	

	--SELECT @v_hit = COUNT(*)
	--FROM gentables
	--WHERE tableid = 131  AND datadesc = @v_elementval
	
	if @DEBUG > 0 print 'start: imp_300014058002 '
	if @DEBUG > 0 print 'exec find_gentables_mixed @v_elementval,131,@v_NEWTerritoriescode output,@v_datadesc output'
	
	exec find_gentables_mixed @v_elementval,131,@v_NEWTerritoriescode output,@v_datadesc output

	if @DEBUG > 0 print '@v_elementval = ' + @v_elementval
	if @DEBUG > 0 print '@v_NEWTerritoriescode = ' + cast(@v_NEWTerritoriescode as varchar(max))
	if @DEBUG > 0 print '@v_ORIGTerritoriescode = ' + cast(@v_ORIGTerritoriescode as varchar(max))

	IF @v_NEWTerritoriescode >0
		BEGIN
			--SELECT @v_NEWTerritoriescode = datacode
			--FROM gentables
			--WHERE tableid = 131  AND datadesc = @v_elementval
			
	/* IF VALUE HAS CHANGED - UPDATE BOOKDETAIL AND SET WRITE HISTORY INDICATOR	*/
			IF @v_NEWTerritoriescode <> @v_ORIGTerritoriesCode
				BEGIN
					UPDATE book
					SET Territoriescode = @v_NEWTerritoriescode,
						lastuserid = @i_userid,
						lastmaintdate = GETDATE()
					WHERE bookkey = @v_bookkey
	
					SET @o_writehistoryind = 1
				END
			END
	ELSE			
		BEGIN
			SET @i_level = 2
			SET @v_errmsg = 'Can not find ('+@v_elementval+') value on Territories User Table(131).  Territories was not updated'
		END
				

		
   	IF @v_errcode < 2
    		BEGIN
			EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , @v_errmsg, @i_level, 3 
    		END

END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300014058002] to PUBLIC 
GO
