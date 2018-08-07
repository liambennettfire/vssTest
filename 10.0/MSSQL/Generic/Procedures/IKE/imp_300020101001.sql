/******************************************************************************
**  Name: imp_300020101001
**  Desc: IKE Add/Replace Dates
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[imp_300020101001]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[imp_300020101001]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[imp_300020101001] 
  
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

/* Add/Replace Dates */

BEGIN 

DECLARE
  @v_elementval VARCHAR(4000),
  @v_errcode INT,
  @v_errmsg VARCHAR(4000),
  @v_elementdesc VARCHAR(4000),
  @v_element_value VARCHAR(4000),
  @v_elementkey BIGINT,
  @v_taskkey INT,
  @v_bookkey INT,
  @v_printingkey     INT,
  @v_hit      INT,
  @v_webschedind      INT,
  @v_actualind      INT,
  @v_sortorder INT,
  @v_new_date DATETIME,
  @v_curr_date DATETIME,
  @v_org_date DATETIME,
  @v_original_date DATETIME,
  @v_addlqualifier VARCHAR(50),
  @v_datetypecode INT,
  @v_datetype VARCHAR(50),
  @v_act_est varchar(50),
  @v_pntr int,
  @v_curr_actualind int

  SET @v_errcode=1
  SET @v_bookkey=dbo.resolve_keyset(@i_titlekeyset,1)
  SET @v_printingkey=dbo.resolve_keyset(@i_titlekeyset,2)
  SELECT @v_elementval= LTRIM(RTRIM(b.originalvalue)),@v_elementkey=b.elementkey,
   @v_elementdesc=elementdesc,@v_addlqualifier=td.addlqualifier
    FROM imp_batch_detail b ,imp_DML_elements d,imp_element_defs e,imp_template_detail td
    WHERE b.batchkey=@i_batch
      AND b.row_id=@i_row
      AND b.elementseq=@i_elementseq
      AND d.dmlkey=@i_dmlkey
      AND d.elementkey=b.elementkey
      and td.templatekey=@i_templatekey
      and b.elementkey=td.elementkey
  set @v_act_est=substring(@v_addlqualifier,1,3)
  set @v_pntr=charindex(',',@v_addlqualifier)
  set @v_datetypecode=cast(substring(@v_addlqualifier,@v_pntr+1,10) as int)
  set @v_errmsg=@v_elementdesc+' Updated'
  select @v_webschedind=coalesce(optionvalue,0)
    from clientoptions
    where optionid=72
  SET @v_new_date=dbo.resolve_date(@v_elementval)

  if @v_webschedind=0
    begin
      SELECT @v_hit=COUNT(*)
        FROM bookdates
        WHERE bookkey=@v_bookkey
          AND datetypecode=@v_datetypecode
          AND printingkey=@v_printingkey
      IF @v_hit=0
        BEGIN
          SELECT @v_sortorder=COALESCE(MAX(sortorder),0)+1
            FROM bookdates
            WHERE bookkey=@v_bookkey
          IF @v_act_est='act'
            BEGIN
              INSERT INTO bookdates(bookkey,printingkey,datetypecode,activedate,lastuserid,lastmaintdate,sortorder,bestdate)
                VALUES (@v_bookkey,1,@v_datetypecode,@v_new_date,@i_userid,GETDATE(),@v_sortorder,@v_new_date)
              exec qtitle_update_titlehistory 'bookdates','activedate',@v_bookkey,1,@v_datetypecode,
                @v_element_value,'insert',@i_userid,null,null,@v_errcode output,@v_errmsg output
            END
          IF @v_act_est='est'
            BEGIN
              INSERT INTO bookdates(bookkey,printingkey,datetypecode,estdate,lastuserid,lastmaintdate,sortorder,bestdate)
                VALUES (@v_bookkey,1,@v_datetypecode,@v_new_date,@i_userid,GETDATE(),@v_sortorder,@v_new_date)
              exec qtitle_update_titlehistory 'bookdates','estdate',@v_bookkey,1,@v_datetypecode,
                @v_element_value,'insert',@i_userid,null,null,@v_errcode output,@v_errmsg output
            END
        END
      else
        BEGIN
          IF @v_act_est='act'
            BEGIN
              SELECT @v_curr_date=activedate
                FROM bookdates
                WHERE bookkey=@v_bookkey
                  AND printingkey=@v_printingkey
                  AND datetypecode=@v_datetypecode
              IF CONVERT(VARCHAR(20),@v_new_date,101)<>CONVERT(VARCHAR(20),@v_curr_date,101) or (@v_curr_date is null)
                BEGIN
                  UPDATE bookdates
                    SET activedate=@v_new_date,lastuserid=@i_userid,lastmaintdate=GETDATE(),bestdate=@v_new_date
                    WHERE bookkey=@v_bookkey
                      AND printingkey=1
                      AND datetypecode=@v_datetypecode
                  exec qtitle_update_titlehistory 'bookdates','activedate',@v_bookkey,1,@v_datetypecode,
                    @v_element_value,'update',@i_userid,null,null,@v_errcode output,@v_errmsg output
                END
            END
          IF @v_act_est='est'
            BEGIN
              SELECT @v_curr_date=estdate
                FROM bookdates
                WHERE bookkey=@v_bookkey
                  AND printingkey=@v_printingkey
                  AND datetypecode=@v_datetypecode
              IF CONVERT(VARCHAR(20),@v_new_date,101)<>CONVERT(VARCHAR(20),@v_curr_date,101) or (@v_curr_date is null)
                BEGIN
                  UPDATE bookdates
                    SET estdate=@v_new_date,lastuserid=@i_userid,lastmaintdate=GETDATE(),bestdate=@v_new_date
                    WHERE bookkey=@v_bookkey
                      AND printingkey=1
                      AND datetypecode=@v_datetypecode
                  exec qtitle_update_titlehistory 'bookdates','estdate',@v_bookkey,1,@v_datetypecode,
                    @v_element_value,'update',@i_userid,null,null,@v_errcode output,@v_errmsg output
                END
            END
    end

  END

  IF @v_new_date is NOT NULL and @v_webschedind=1
    BEGIN
      if @v_act_est = 'est'
        begin
          set @v_actualind=0
        end
      else  --default to actual
        begin
          set @v_actualind=1
        end
      SELECT @v_hit = COUNT(*), @v_curr_actualind = isnull(min(actualind),0)
        FROM taqprojecttask
        WHERE bookkey = @v_bookkey
          AND datetypecode = @v_datetypecode
          AND printingkey = @v_printingkey
	  if not( @v_actualind = 0 and isnull(@v_curr_actualind,0) = 1)
		begin
		  if @v_hit=1 
			begin
			  SELECT @v_curr_date = activedate,
					 --mk>2012.07.17
				     @v_original_date=originaldate
				FROM taqprojecttask
				WHERE bookkey = @v_bookkey
				  AND printingkey = @v_printingkey
				  AND datetypecode = @v_datetypecode
			  
			  --mk>2012.07.17
			  --if @v_new_date<>@v_curr_date or @v_curr_date is null
			  if coalesce(@v_new_date,'')<> coalesce(@v_curr_date ,'')		  
			  
				begin
				  update taqprojecttask
					set activedate=@v_new_date,
						--mk>2012.07.17
					    originaldate=coalesce(@v_original_date,@v_new_date),
                        lastuserid=@i_userid,
                        lastmaintdate=getdate()
					where bookkey = @v_bookkey
					  AND printingkey = @v_printingkey
					  AND datetypecode = @v_datetypecode
				end
			  SELECT @v_org_date=originaldate
				FROM taqprojecttask
				WHERE bookkey = @v_bookkey
				  AND printingkey = @v_printingkey
				  AND datetypecode = @v_datetypecode
			  if @v_org_date is null
				begin
				  update taqprojecttask
					set originaldate=@v_new_date,
                        lastuserid=@i_userid,
                        lastmaintdate=getdate()
					where bookkey = @v_bookkey
					  AND printingkey = @v_printingkey
					  AND datetypecode = @v_datetypecode
				end
			end
		  else
			begin
			  update keys set generickey=generickey+1
			  select @v_taskkey=generickey from keys
			  insert into taqprojecttask
				(taqtaskkey,bookkey,printingkey,activedate, originaldate,keyind, actualind,datetypecode,lastmaintdate,lastuserid)
				values
				(@v_taskkey,@v_bookkey,@v_printingkey,@v_new_date, @v_new_date,1, @v_actualind,@v_datetypecode,getdate(),@i_userid)
			end
		end
    END

  EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq ,@i_dmlkey ,@v_errmsg,@i_level,3
END


go

grant execute on [imp_300020101001] to public
go