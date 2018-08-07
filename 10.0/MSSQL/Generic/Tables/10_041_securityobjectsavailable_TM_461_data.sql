DECLARE @v_windowid int

select @v_windowid = windowid from qsiwindows where windowname = 'productsummary'

delete from securityobjects
where availsecurityobjectkey in (select availablesecurityobjectskey from securityobjectsavailable
                                  where availobjectid = 'shSubjectCategories' and windowid = @v_windowid)

delete from securityobjectsavailable
where availobjectid = 'shSubjectCategories'
and windowid = @v_windowid

update securityobjectsavailable
set availobjectid = 'shSubjectCategories'
where availobjectid = 'shTitleCategories'
and windowid = @v_windowid

