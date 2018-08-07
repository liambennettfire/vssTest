/******************************************************************************
**  Name: imp_300014090001
**  Desc: IKE Territory Rights add
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300014090001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300014090001]
GO

CREATE PROCEDURE dbo.imp_300014090001 
  
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

/* Territory Rights add */

BEGIN 

DECLARE @v_elementval			VARCHAR(4000),
	@v_errcode			INT,
  	@v_errmsg 			VARCHAR(4000),
	@v_elementdesc			VARCHAR(4000),
	@v_elementkey			BIGINT,
	@v_lobcheck 			VARCHAR(20),
	@v_lobkey 			INT,
	@v_bookkey 			INT,
	@v_new_customint		INT,
	@v_curr_customint		INT,
	@v_rowcount			INT,
	@v_count			INT,
	@v_territoryrightskey int, 
	@v_itemtype int, 
	@v_currentterritorycode int, 
	@v_contractterritorycode int, 
	@v_description varchar(50), 
	@v_country_text varchar(50), 
	@v_autoterritorydescind int, 
	@v_exclusivecode int, 
	@v_singlecountrycode int,
	@v_singlecountrygroupcode int, 
	@v_updatewithsubrightsind int, 
	@v_note varchar(200), 
	@v_forsalehistory varchar(200), 
	@v_notforsalehistory varchar(200),
	@v_countrycode int, 
	@v_forsaleind int, 
	@v_contractexclusiveind int, 
	@v_nonexclusivesubrightsoldind int,
	@v_currentexclusiveind int, 
	@v_exclusivesubrightsoldind int
	
BEGIN
	SET @v_rowcount = 0
	SET @v_new_customint = 0
	SET @v_curr_customint = 0
	SET @o_writehistoryind = 0
	SET @v_errcode = 1
	SET @v_errmsg = ''
	SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
	
	SET @v_itemtype=10 --???
	SET @v_exclusivecode=0 --???
	
	SELECT @v_country_text = COALESCE(originalvalue,''), @v_elementkey = b.elementkey
      FROM imp_batch_detail b , imp_DML_elements d
      WHERE b.batchkey = @i_batch
        AND b.row_id = @i_row
        AND b.elementseq = @i_elementseq
        AND b.elementkey = d.elementkey
        AND d.DMLkey = @i_dmlkey
    select @v_count=COUNT(*)
      from territoryrights
      where bookkey=@v_bookkey
	if @v_count=0
	  begin
		EXEC get_next_key @i_userid, @v_territoryrightskey OUTPUT
		INSERT INTO territoryrights
		 (territoryrightskey, itemtype, bookkey, currentterritorycode, contractterritorycode, description, autoterritorydescind, exclusivecode, singlecountrycode,
		  singlecountrygroupcode, updatewithsubrightsind, note, forsalehistory, notforsalehistory, lastuserid, lastmaintdate)
		VALUES
		 (@v_territoryrightskey, @v_itemtype, @v_bookkey, @v_currentterritorycode, @v_contractterritorycode, @v_description, @v_autoterritorydescind, @v_exclusivecode, @v_singlecountrycode,
		  @v_singlecountrygroupcode, @v_updatewithsubrightsind, @v_note, @v_forsalehistory, @v_notforsalehistory, @i_userid, GETDATE())
	  end
	else
	  begin
        select @v_territoryrightskey=territoryrightskey
          from territoryrights
          where bookkey=@v_bookkey
	  end
	  

	exec [dbo].[find_gentables_mixed] @v_country_text,114,@v_countrycode output,@v_description output
    select @v_count=COUNT(*)
      from territoryrightcountries
      where bookkey=@v_bookkey
	if @v_count=0
	  begin
		INSERT INTO territoryrightcountries
		  (territoryrightskey, countrycode, itemtype, bookkey, forsaleind, contractexclusiveind, nonexclusivesubrightsoldind,
		   currentexclusiveind, exclusivesubrightsoldind, lastuserid, lastmaintdate)
		VALUES
		  (@v_territoryrightskey, @v_countrycode, @v_itemtype, @v_bookkey, @v_forsaleind, @v_contractexclusiveind, @v_nonexclusivesubrightsoldind,
		   @v_currentexclusiveind, @v_exclusivesubrightsoldind, @i_userid, getdate())
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

GRANT EXECUTE ON dbo.[imp_300014090001] to PUBLIC 
GO
