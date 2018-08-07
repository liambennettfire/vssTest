/****** Object:  StoredProcedure [dbo].[insert_gentablesitemtype_from_subgentables]    Script Date: 11/17/2014 11:44:25 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[insert_gentablesitemtype_from_gentables]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[insert_gentablesitemtype_from_gentables]
GO

/****** Object:  StoredProcedure [dbo].[insert_gentablesitemtype_from_gentables]    Script Date: 11/17/2014 11:44:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[insert_gentablesitemtype_from_gentables] (
@i_tableid int,
@i_datacode int,
@_itemtypecode int,
@i_itemtypesubcode int,
@v_userid varchar(20))

AS

BEGIN
	insert into gentablesitemtype (gentablesitemtypekey, tableid,datacode,datasubcode,datasub2code,itemtypecode,itemtypesubcode,defaultind,lastuserid,lastmaintdate,
	sortorder,relateddatacode,indicator1,text1)
	select
	row_number() over(Partition by 1 order by datacode) + (Select generickey from keys), 
	@i_tableid,
	@i_datacode,
	0,
	0,
	@_itemtypecode,
	@i_itemtypesubcode,
	0,
	@v_userid ,
	GETDATE(),
	null,
	null,
	null,
	null
	from gentables 
	where tableid=@i_tableid 
	and datacode=@i_datacode
	and datacode not in (select datacode from gentablesitemtype where itemtypecode=@_itemtypecode and itemtypesubcode = @i_itemtypesubcode and tableid=@i_tableid) 

	update keys set generickey = (Select max(gentablesitemtypekey) from [gentablesitemtype])

END


GO


