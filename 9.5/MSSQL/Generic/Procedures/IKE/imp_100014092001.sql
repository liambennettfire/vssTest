/******************************************************************************
**  Name: imp_100014092001
**  Desc: IKE Territory load from Template
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100014092001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100014092001]
GO

CREATE PROCEDURE dbo.imp_100014092001 
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

/* Territory load from Template */

BEGIN 

DECLARE  @v_errcode 	INT,
	@v_new_seq 	INT,
	@v_template_value 	VARCHAR(max),
	@v_template_key  int,
	@v_effdate	VARCHAR(4000),	
	@v_errlevel 	INT,
	@v_msg 		VARCHAR(4000),
	@v_taqprojectkey int,
	@v_territoryrightskey int,
	@v_pricetype	VARCHAR(40),
	@v_currentterritorycode int,
	@v_debug int

BEGIN
	SET @v_errcode = 0
	SET @v_errlevel = 0
	SET @v_msg = 'Rights template expansion'
	SET @v_debug=0

  if @v_debug<>0 print 'territory rights lodaer rule'

  SELECT @v_template_value = originalvalue
	FROM imp_batch_detail 
	WHERE batchkey = @i_batchkey
		    and row_id = @i_row
		    and elementseq = @i_elementseq
		    and elementkey = 100014092

  select @v_taqprojectkey=taqprojectkey from taqproject where externalcode=@v_template_value
  select 
	@v_territoryrightskey=territoryrightskey,
	@v_currentterritorycode=currentterritorycode
	from  territoryrights 
	where taqprojectkey=@v_taqprojectkey
  select @v_template_key=rightskey from taqprojectrights where rightsdescription=@v_template_value

  if @v_debug<>0 print 'Loading taqprojectkey '+coalesce(cast(@v_territoryrightskey as varchar),'n/a')

  delete imp_territory where batchkey=@i_batchkey and row_id=@i_row
  insert into imp_territory
    select @i_batchkey,@i_row,
	c.itemtype,c.forsaleind,c.contractexclusiveind,c.nonexclusivesubrightsoldind,c.currentexclusiveind,c.exclusivesubrightsoldind,
	g.datadesc,c.countrycode,c.contractexclusiveind,0
	from taqproject p, territoryrights r, territoryrightcountries c, gentables g
      where p.externalcode=@v_template_value
      and p.taqprojectkey=r.taqprojectkey
	  and r.territoryrightskey=c.territoryrightskey
	  and c.countrycode=g.datacode
	  and tableid=114

  IF @v_errlevel >= @i_level 
    BEGIN
      EXECUTE imp_write_feedback @i_batchkey, @i_row, null, @i_elementseq, @i_rulekey , @v_msg, @v_errlevel, 1
    END

END

end



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100014092001] to PUBLIC 
GO
