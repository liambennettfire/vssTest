if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[whviewbuild_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[whviewbuild_sp]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



CREATE procedure whviewbuild_sp
as
begin

/** This procedure will create views for the warehouse tables replacing **/
/** the generic column names (i.e. actdate1) with the desctription from the **/
/** related gentable 'i.e. Publication Date-Actual**/
/** i.e. Publication Date  based on the type selected in the control table. **/
/** DSL 7/2/2004*/



/*************************************************************/
/**                                                         **/
/**                    Title Dates                          **/
/**                                                         **/
/*************************************************************/

exec whviewbuildtitledates_sp


/*************************************************************/
/**                                                         **/
/**                    SCHEDULES                            **/
/**                                                         **/
/*************************************************************/

/** There are 10+ schedule tables, so we need to build views for each. **/
/** This procedure accepts the tablenumber as a parameter. if more tables are **/
/** added, the whbuildscheduleviews will also need to be changed due to the **/
/** Declare Cursor mods required                                          **/

exec whviewbuildschedule_sp 1
exec whviewbuildschedule_sp 2
exec whviewbuildschedule_sp 3
exec whviewbuildschedule_sp 4
exec whviewbuildschedule_sp 5
exec whviewbuildschedule_sp 6
exec whviewbuildschedule_sp 7
exec whviewbuildschedule_sp 8
exec whviewbuildschedule_sp 9
exec whviewbuildschedule_sp 10

/*************************************************************/
/**                                                         **/
/**                    Personnel                            **/
/**                                                         **/
/*************************************************************/

exec whviewbuildtitlepersonnel_sp
exec whviewbuildprintingpersonnel_sp


/*************************************************************/
/**                                                         **/
/**                    TITLE COMMENTS                       **/
/**                                                         **/
/*************************************************************/

/** There are 3+ Title Comment tables, so we need to build views for each.  **/
/** This procedure accepts the tablenumber as a parameter. if more tables are **/
/** added, the whbuildtitlecommentsviews_sp will also need to be changed due to the **/
/** Declare Cursor mods required                                          **/

exec whviewbuildtitlecomments_sp 1
exec whviewbuildtitlecomments_sp 2
exec whviewbuildtitlecomments_sp 3

end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

