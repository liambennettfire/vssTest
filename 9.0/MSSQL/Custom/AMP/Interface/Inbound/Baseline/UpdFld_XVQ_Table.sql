
IF OBJECT_ID('dbo.UpdFld_XVQ_Table') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_Table
GO

CREATE PROCEDURE dbo.UpdFld_XVQ_Table
@tablename      varchar(100),        -- not to be confused with @tableid which is only for gentable indirection where applicable
@bookkey        int,
@columnname     varchar(100),
@tableid        int,                 -- 0 if the column is not a gentables code
@codeform       int,                 -- 0 if the column is not a gentables code, otherwise 1=code#, 2=externalcode, 3=datadesc
@parentcode     int,                 -- only matters if @codeform is non-zero - data is a SUBgentables code under @parentcode
@record_buffer  varchar(2000),
@offset         int,
@length         int,
@userid         varchar(30),
@transform_sproc_name  varchar(100), -- null, or name of sproc that does pre- and/or post-validation transformation of the data.
@validation_sproc_name varchar(100), -- null, 'isnumeric', 'isdate', or name of sproc that takes appropriate parameters (see template)
@vldn_type_code int,                 -- 1=no validation test, 2=caller decides invalid effect-code, 3=sproc decides or defers to caller default.
@effect_code    int,                 -- exception scope/effect code: abort job, abort rec, abort group, abort fld, write fld w/warning, write fld w/info
@jobrec_id      varchar(255),        -- only for error reporting, something in raw data record to easily find it, e.g. ISBN#
@qsijobkey      int,                 -- if null, skip qsijob stuff, but do the rest
@o_result_code  int output,
@o_result_desc  varchar(2000) output -- caller should pass in variable set to null except for situations listed in Note below
AS
BEGIN

-- UpdFld_XXXX encapsulates generic data-field insert, update, and titlehistory functions.  Sitting on top of that,
-- UpdFld_XVQ_XXXX provides an integrated layer of transformation, validation, QsiJob reporting, and flow-control.

-- Result scope/effect codes:
--   -1 - system error or other non-validation error - abort job
--    0 - undefined (reserved) - should not happen
--    1 - abort job
--    2 - abort record
--    3 - abort group of fields
--    4 - abort field
--    5 - success but with warning
--    6 - success but with information
--    7 - unqualified success with no other info
-- Additional UpdFld_XVQ_XXXX SYSTEM ERROR result codes:
--   -1 - non-specific system error coming from a subroutine called by UpdFld_XVQ_XXXX
--   -2 - validation_sproc was named (parameter was not null), but sproc doesn't exist
--   -3 - validation_sproc returned an unrecognized result code

-- Note: @effect_code parameter must be > 0 unless @vldn_type_code = 1 (pre-determined result)

-- Note: The @o_result_desc parameter is primarily an output variable, but there are 2 types of
-- situations where the caller passes IN a variable containing a non-null value:
-- 1) For a predetermined "result" (validation type code = 1), the passed-in value in @o_result_desc
--    will be the message written to the qsijobmessages table.
-- 2) When success should be noted in the qsijobmessages table as well as error, the passed-in value
--    will be the qsijob message "suffix" in the event of success.
-- In all other situations the parameter passed in should be an input/output variable set to NULL.

declare @qsijob_success_msg varchar(2000)
set     @qsijob_success_msg = null --disable for now @o_result_desc

declare @is_valid int

declare @result_code      int
declare @result_desc      varchar(2000)
declare @vldn_result_code int
declare @vldn_result_desc varchar(2000)

declare @extract varchar(2000)  -- used to extract specific field from record buffer
set @extract = ltrim(rtrim(substring(@record_buffer, @offset, @length)))


if @bookkey is null begin
	set @vldn_type_code = 1   -- title doesn't exist -> fasttrack it to error reporting
	if @effect_code > 2
		set @effect_code = 2  -- at least abort the record, if not the job

	set @bookkey = 0          -- qsijob reporting doesn't allow null values for referencekey1, so set it to 0
	set @o_result_desc = 'Title does not exist'
end


if @vldn_type_code = 1  -- it's a no-validation, pre-determined "result"
begin
	set @result_code = @effect_code    -- process as normal but skip validation test
	set @result_desc = @o_result_desc  -- use pre-determined message for pre-determined result

	-- We already know by other means...
--	if UpdFld_XVQ_Effect(@effect_code,'NonAbort') = 1
	if @effect_code in (5,6,7)
		set @is_valid = 1  -- ...data is valid -> do ins/upd/TH & write any msg to qsijobmessages table
	else
		set @is_valid = 0  -- ...data is invalid -> just write msg to qsijobmessages table
end
else if @vldn_type_code in (2, 3)
begin
	if @transform_sproc_name is not null AND OBJECT_ID(@transform_sproc_name) is not null
		EXEC @transform_sproc_name 1, @columnname, @tableid, @codeform, @parentcode, @extract output, @length output, @bookkey

	set @is_valid = case lower(isnull(@validation_sproc_name,''))
						when ''			 then 1  -- everything is valid
						when 'isnumeric' then ISNUMERIC(@extract)  -- standard sql function
						when 'isdate'	 then ISDATE(@extract)     -- standard sql function
						else			 null -- need to execute validation sproc below
					end

	if @is_valid is not null begin
		-- Was a "simple" validation test
		if @is_valid = 1 or len(@extract) = 0 begin  -- for simple test, default that empty means valid delete
			set @is_valid = 1        -- in case was 'len(@extract) = 0', need to set this
			set @result_code = 7     -- can't get a warning on simple validation test
			set @result_desc = @qsijob_success_msg
		end
		else begin
			set @result_code = @effect_code
			set @result_desc = null  -- simply "invalid" on a simple validation test
		end
	end
	else begin
		-- It's a more "advanced" validation test

		if OBJECT_ID(@validation_sproc_name) is null begin
			-- Handle as system error, or else as qsijob error, or else should we write all system errors to qsijobmessages table?
			set @result_code = -2  -- if the validation_sproc is named but doesn't exist -> abort the job
			set @result_desc = 'The specified validation stored procedure (' + @validation_sproc_name + ') does not exist.'
		end
		else begin
			EXEC @validation_sproc_name @bookkey, @columnname, @tableid, @codeform, @parentcode, @extract, @vldn_result_code output, @vldn_result_desc output

			set @is_valid = 0  -- assume failure until determine success

			if @vldn_result_code = 7 begin
				set @is_valid = 1
				set @result_code = 7  -- success
				set @result_desc = @qsijob_success_msg  -- usually null
			end
			else if @vldn_result_code = 8 begin
				set @result_code = @vldn_result_code
				set @result_desc = @vldn_result_desc
				RETURN  -- result code 8 = ignore (empty field) -> nothing more to do
			end
			else if @vldn_result_code < 0 begin
				-- system error of some sort
				if @vldn_result_desc is null begin
					set @result_code = -1
					set @result_desc = 'System error during validation procedure: ' + @validation_sproc_name
				end
				else begin
					set @result_code = @vldn_result_code
					set @result_desc = @vldn_result_desc
				end
			end
			else if @vldn_result_code not in (0,1,2,3,4,5,6,7) begin  -- should probably have a function with the set of valid result codes
				-- An invalid result code is a problem - how best to handle? abort job? just the record?
				--set @result_code = -3  -- if unrecognized result code from validation_sproc -> abort the job
				set @result_code = @effect_code  -- if unrecognized result code from validation_sproc -> abort the job
				set @result_desc = 'The validation stored procedure (' + @validation_sproc_name +
				                   ') returned an unrecognized result code (' + @vldn_result_code + ').'
			end
			else begin
				if @vldn_type_code = 2 or @vldn_result_code = 0 begin
					-- Effect is either pre-determined, or ...
					-- effect is dynamic but validation_sproc couldn't determine proper effect, so use default effect

					set @result_code = @effect_code
					set @result_desc = @vldn_result_desc  -- should be null if not filled in by SYSTEM ERROR handling, or
					                                      -- if sproc decided data invalid, but didn't decide effect
				end
				else if @vldn_type_code = 3 begin
					-- Effect is dynamic - determined by validation_sproc

					if @vldn_result_code in (5,6)  -- warning or information statement, but "valid enough" to write to db
						set @is_valid = 1
					else
						set @is_valid = 0

					set @result_code = @vldn_result_code
					set @result_desc = @vldn_result_desc
				end
			end  -- effect code > 0
		end  -- validation_sproc exists
	end  -- advanced validation
end  -- perform validation
else begin
	set @result_code = -4  -- if invalid validation-type-code -> abort the job
	--set @result_code = min(@effect_code,4)  -- if invalid validation-type-code -> abort the job
	set @result_desc = 'The validation type code parameter (' + @vldn_type_code + ') was itself invalid.'
end


if @is_valid = 1
begin
	if @transform_sproc_name is not null AND OBJECT_ID(@transform_sproc_name) is not null
		EXEC @transform_sproc_name 2, @columnname, @tableid, @codeform, @parentcode, @extract output, @length output, @bookkey

	declare @uf_error_code int
	declare @uf_error_desc varchar(2000)

	-- Do insert/update and (if applicable) titlehistory
	declare @UF_T_sproc_name varchar(50)
	set     @UF_T_sproc_name = 'dbo.UpdFld_Table_' + @tablename
	EXEC @UF_T_sproc_name @bookkey, @columnname, @tableid, @codeform, @parentcode, @extract, 1, @length, @userid, @uf_error_code output, @uf_error_desc output

	if (@uf_error_code < 0) begin
		set @result_code = @uf_error_code
		set @result_desc = @uf_error_desc
	end
end


if @qsijobkey is not null AND (@result_code <> 7 OR @qsijob_success_msg is not null)
begin  -- write to the qsijobmessage table

	-- Code specific to Table_xxxx class data
	declare @datadesc varchar(256)

	if @codeform = 0
		set @datadesc = upper(@columnname)  -- use this for lack of a better description
	else
	begin
		if @parentcode = 0   -- the column is a gentables value rather than a SUBgentables value
		begin
			select	@datadesc = tabledesclong
			from	gentablesdesc
			where	tableid = @tableid
		end
		else   -- the column is a SUBgentables value rather than a gentables value
		begin
			select	@datadesc = datadesc
			from	gentables
			where	tableid = @tableid
					and
					datacode = @parentcode
		end
	end

	-- Generalized code

	declare @qsijob_msgtype_code int            -- used to get/pass the qsijob messagetypecode mapped from the UpdFld_XVQ_XXXX scope/effect code
	declare @qsijob_long_msg     varchar(4000)  -- used to get/pass the qsijobmessages messagelongdesc value
	declare @qsijob_short_msg    varchar(30)    -- used to get/pass an "UpdFld_XXXX standardized" qsijobmessages messageshortdesc value

	EXEC UpdFld_XVQ_QsiJob_MessageBuilder @result_code, @result_desc, @jobrec_id, @datadesc, @extract, @qsijob_msgtype_code output, @qsijob_long_msg output, @qsijob_short_msg output

	declare @qj_error_code int
	declare @qj_error_desc varchar(2000)

	EXEC dbo.UpdFld_XVQ_QsiJob_WriteMessage @qsijobkey, @userid, @bookkey, 0, 0, @qsijob_msgtype_code, @qsijob_long_msg, @qsijob_short_msg, @qj_error_code output, @qj_error_desc output

	if @qj_error_code < 0 begin
		-- Unable to write to qsijob table(s), use/return their @o_error_code and @o_error_desc settings as is

		-- Turn this off (0=1) in order to NOT have qsijob system error msg take precedence over whatever msg got us here
		if (1=1) begin
			set @result_code = @qj_error_code
			set @result_desc = @qj_error_desc
		end
		else begin
			if @is_valid <> 1 and @result_code = 1 begin
				-- If already set to job-abort due to content, that's more interesting to client?
				if len(@qj_error_desc) + len(@vldn_result_desc) + 20 < 2000
					set @result_desc = 'Data and System errors: ' + @vldn_result_desc + '; ' + @qj_error_desc
			end
			else if NOT (@vldn_result_code < 0 and @vldn_result_desc is not null) begin
				-- If there was a system error of some sort during validation_sproc call, then the conditional
				-- clause in the line just above that controls entry to this code block makes the validation
				-- system error message take precedence over the qsijob system error message.
				set @result_code = @qj_error_code
				set @result_desc = @qj_error_desc
			end
		end
	end
end

set @o_result_code = @result_code
set @o_result_desc = @result_desc

END
GO
