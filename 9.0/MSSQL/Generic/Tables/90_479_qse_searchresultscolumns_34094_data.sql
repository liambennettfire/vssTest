insert into qse_searchresultscolumns (searchtypecode,searchitemcode,usageclasscode,columnnumber,
objectname,columnlabel,defaultwidth,tablename,columnname,displayind,keycolumnind,defaultsortorder,
websortorder,webhorizontalalign, 
columnvaluesql)
values (8,2,0,10,
'Contact Comment','Contact Comment',50,'qsicomments','c_commenttext',1,0,9,
9,'left', 
'(SELECT CONVERT(VARCHAR(MAX), commenttext) as commenttext from qsicomments WHERE corecontactinfo.contactkey = qsicomments.commentkey AND commenttypecode = (SELECT COALESCE(clientdefaultvalue, 0) FROM clientdefaults WHERE clientdefaultid = 82))')
go