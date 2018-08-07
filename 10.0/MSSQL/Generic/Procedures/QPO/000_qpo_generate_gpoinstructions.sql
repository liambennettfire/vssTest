if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpo_generate_gpoinstructions') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qpo_generate_gpoinstructions
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpo_generate_gpoinstructions
 (@i_projectkey           integer,
  @i_related_projectkey   integer,
  @i_gpokey               integer,
  @i_lastuserid           varchar(30),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qpo_generate_gpoinstructions
**  Desc: This procedure will be called from the Generate PO Report Function.
**        New projectkey key, related project key, gpokey and lastuserid 
**        will be passed in.
**  Auth: Kusum
**  Date: 14 August 2014
*******************************************************************************
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:      Case #:   Description:
**    --------    --------     -------   --------------------------------------
**    09/29/17    Colman       46975     Special Instructions lose text in GPOINSTRUCTIONS table   
*******************************************************************************/
BEGIN

 SET @o_error_code = 0
 SET @o_error_desc = ''
 
 DECLARE @v_shipping_inst_commenttype_datacode INT,
         @v_shipping_inst_commenttype_datasubcode  INT,
         @v_commentkey  INT,
         @v_count  INT,
         @v_commenttext NVARCHAR(MAX),
         @v_maxchunklen INT,
         @v_sequence INT,
         @v_chunk VARCHAR(250),
         @v_string VARCHAR(250),
         @v_instructionkey INT,
         @v_roletypecode INT,
         @v_globalcontactkey INT,
         @v_misckey INT,
         @v_textvalue VARCHAR(255),
         @v_longvalue INT,
         @v_substring VARCHAR(255),
         @v_reversestring VARCHAR(400),
         @v_trimmedreversestring VARCHAR(500),
         @v_spacepos INT,
         @v_chunklen INT
     
  SET @v_sequence = 0
  SET @v_commentkey = 0
         
  DELETE FROM gpoinstructions WHERE gpokey = @i_gpokey AND instructiontype in (1,2)
 
  SELECT @v_shipping_inst_commenttype_datacode = datacode,
         @v_shipping_inst_commenttype_datasubcode = datasubcode
  FROM subgentables 
  WHERE tableid = 284 and qsicode = 2
  
  SELECT TOP 1 @v_commentkey = ISNULL(commentkey, 0)
  FROM taqprojectcomments
  WHERE taqprojectkey = @i_related_projectkey
    AND commenttypecode = @v_shipping_inst_commenttype_datacode 
    AND commenttypesubcode = @v_shipping_inst_commenttype_datasubcode
 
  IF @v_commentkey > 0 
  BEGIN
    SELECT @v_commenttext = ISNULL(commenttext, '')
    FROM qsicomments
    WHERE commentkey = @v_commentkey
 
    SET @v_maxchunklen = 250
    SET @v_commenttext = LTRIM(RTRIM(@v_commenttext))

    WHILE LEN(@v_commenttext) > 0 
    BEGIN
      SET @v_sequence = @v_sequence + 1

      IF LEN(@v_commenttext) <= @v_maxchunklen 
      BEGIN
        IF NOT EXISTS (SELECT 1 FROM gpoinstructions WHERE gpokey = @i_gpokey AND detail = @v_commenttext)
        BEGIN
          EXEC get_next_key @i_lastuserid, @v_instructionkey output

          INSERT INTO gpoinstructions 
            (gpokey, instructionkey, detaillinenbr, detail, instructiontype, lastuserid, lastmaintdate)
          VALUES 
            (@i_gpokey, @v_instructionkey, @v_sequence, @v_commenttext, 1, @i_lastuserid, getdate())
        END
        BREAK
      END
      ELSE BEGIN 
        SET @v_substring = LEFT(@v_commenttext, @v_maxchunklen)
        SET @v_reversestring = REVERSE(@v_substring)
        SET @v_spacepos = CHARINDEX(' ', @v_reversestring)
        SET @v_trimmedreversestring = SUBSTRING(@v_reversestring, @v_spacepos, len(@v_reversestring))
        SET @v_chunk =  REVERSE(@v_trimmedreversestring)
        SET @v_chunklen = len(@v_chunk)
          
        SET @v_commenttext = RIGHT(@v_commenttext, @v_maxchunklen - @v_chunklen + 1)
        SET @v_commenttext = LTRIM(RTRIM(@v_commenttext))

        SET @v_chunk = RTRIM(LTRIM(@v_chunk))

        IF NOT EXISTS (SELECT 1 FROM gpoinstructions WHERE gpokey = @i_gpokey AND detail = @v_chunk)
        BEGIN
          EXEC get_next_key @i_lastuserid, @v_instructionkey output

          INSERT INTO gpoinstructions 
            (gpokey, instructionkey, detaillinenbr, detail, instructiontype, lastuserid, lastmaintdate)
          VALUES 
            (@i_gpokey, @v_instructionkey, @v_sequence, @v_chunk, 1, @i_lastuserid, getdate())
        END
      END
    END -- WHILE LEN(@v_commenttext) > 0 
  END --IF @v_commentkey > 0 BEGIN
 
   -- FOB and Net Days 
   SELECT @v_roletypecode = datacode FROM gentables WHERE tableid = 285 and qsicode = 15 -- Vendor
     
     
   IF @v_roletypecode > 0 BEGIN
    SELECT @v_globalcontactkey = c.globalcontactkey
      FROM taqprojectcontact c, taqprojectcontactrole r
      WHERE c.taqprojectcontactkey = r.taqprojectcontactkey AND 
        c.taqprojectkey = @i_projectkey AND
        r.rolecode = @v_roletypecode
        
        
    IF @v_globalcontactkey > 0 BEGIN
       SELECT @v_misckey = misckey FROM bookmiscitems WHERE qsicode =  11 --FOB
       
        --check the po summary first for net days, if none, then go to the vendor contact
       SELECT @v_textvalue = textvalue FROM taqprojectmisc WHERE taqprojectkey= @i_related_projectkey AND misckey = @v_misckey 
    
       IF coalesce(@v_textvalue,'')=''
       begin
       SELECT @v_textvalue = textvalue FROM globalcontactmisc WHERE globalcontactkey = @v_globalcontactkey AND misckey = @v_misckey
            end
         
       IF @v_textvalue IS NOT NULL AND @v_textvalue <> '' BEGIN
        SET @v_string = @v_textvalue
            
        SET @v_sequence = @v_sequence + 1
            
        exec get_next_key @i_lastuserid, @v_instructionkey output
        --insert into gpoinstruction here
        INSERT INTO gpoinstructions (gpokey,instructionkey,detaillinenbr,detail,instructiontype,lastuserid,lastmaintdate)
          VALUES (@i_gpokey,@v_instructionkey,@v_sequence,@v_string,2,@i_lastuserid,getdate())
       END
               
       SELECT @v_misckey = misckey FROM bookmiscitems WHERE qsicode = 12 --Net Days renamed to Payment Days
       
        --check the po summary first for net days, if none, then go to the vendor contact
       SELECT @v_textvalue = textvalue FROM taqprojectmisc WHERE taqprojectkey= @i_related_projectkey AND misckey = @v_misckey 
    
       IF coalesce(@v_textvalue,'')=''
       begin
        SELECT @v_textvalue = textvalue FROM globalcontactmisc WHERE globalcontactkey = @v_globalcontactkey AND misckey = @v_misckey
            end  
       
       IF @v_textvalue IS NOT NULL AND @v_textvalue <> '' BEGIN
        SET @v_string = 'Terms: Net ' + @v_textvalue
            
        SET @v_sequence = @v_sequence + 1
            
        exec get_next_key @i_lastuserid, @v_instructionkey output
        --insert into gpoinstruction here
        INSERT INTO gpoinstructions (gpokey,instructionkey,detaillinenbr,detail,instructiontype,lastuserid,lastmaintdate)
          VALUES (@i_gpokey,@v_instructionkey,@v_sequence,@v_string,2,@i_lastuserid,getdate())
       END
    END


   END


END
GO

GRANT EXEC ON qpo_generate_gpoinstructions TO PUBLIC
GO
