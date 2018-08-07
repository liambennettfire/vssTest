/******************************************************************************
**  Name: imp_300014081001
**  Desc: IKE Add/Replace VerificationStatus
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300014081001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300014081001]
GO

CREATE PROCEDURE dbo.imp_300014081001 
  
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

/* Add/Replace VerificationStatus */

BEGIN 

DECLARE
    @v_elementval		VARCHAR(4000),
	@v_errcode		INT,
  	@v_errmsg 		VARCHAR(4000),
	@v_elementdesc		VARCHAR(4000),
	@v_elementkey		BIGINT,
	@v_bookkey 		INT,
	@v_datacode 		INT,
	@v_datacode_org 		INT,
	@v_tableid 		INT,
	@v_addl_verfs int,
	@v_hit			INT
	
BEGIN
	SET @v_hit = 0
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_errmsg = 'VerificationStatus'
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
	
	SELECT
	    @v_elementval =  LTRIM(RTRIM(originalvalue)),
	    @v_elementkey = b.elementkey,
	    @v_tableid = ed.tableid
	  FROM imp_batch_detail b , imp_DML_elements d, imp_element_defs ed
	  WHERE b.batchkey = @i_batch
        AND b.row_id = @i_row
	    AND b.elementseq = @i_elementseq
	    AND d.dmlkey = @i_dmlkey
	    AND d.elementkey = b.elementkey
	    AND d.elementkey = ed.elementkey
	    
	SELECT @v_datacode = datacode
	  FROM gentables 
      WHERE tableid=@v_tableid
        and datadesc=@v_elementval

    SELECT @v_hit=count(*)
	  FROM bookverification
      WHERE bookkey=@v_bookkey 
        and verificationtypecode = 1
        
    IF @v_hit=0
      BEGIN
        insert into bookverification
          (bookkey,verificationtypecode,titleverifystatuscode,lastuserid,lastmaintdate)
          values
          (@v_bookkey,1,@v_datacode,@i_userid,getdate())
        SET @o_writehistoryind = 1
      	SET @v_errmsg = 'VerificationStatus added'
      END
    else
      begin
        SELECT @v_datacode_org=titleverifystatuscode
	       FROM bookverification
           WHERE bookkey=@v_bookkey 
             and verificationtypecode = 1
        if coalesce(@v_datacode_org,0)<>coalesce(@v_datacode,0)
          begin
            update bookverification
              set titleverifystatuscode=@v_datacode
              where bookkey=@v_bookkey 
                and verificationtypecode = 1
            SET @o_writehistoryind = 1
            SET @v_errmsg = 'VerificationStatus updated'
          end
        else
          begin
            SET @o_writehistoryind = 0
            SET @v_errmsg = 'VerificationStatus unchanged'
          end

      end
      
    -- add missing verf rows if missing
    set @v_addl_verfs = 2
    while @v_addl_verfs <= 4
      begin
        SELECT @v_hit=count(*)
	      FROM bookverification
          WHERE bookkey=@v_bookkey 
            and verificationtypecode = @v_addl_verfs
        IF @v_hit=0
          BEGIN
            insert into bookverification
              (bookkey,verificationtypecode,titleverifystatuscode,lastuserid,lastmaintdate)
              values
              (@v_bookkey,@v_addl_verfs,0,@i_userid,getdate())
          END
        set @v_addl_verfs=@v_addl_verfs+1
      end
			
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

GRANT EXECUTE ON dbo.[imp_300014081001] to PUBLIC 
GO
