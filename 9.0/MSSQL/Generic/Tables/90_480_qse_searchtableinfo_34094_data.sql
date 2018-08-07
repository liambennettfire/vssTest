INSERT INTO qse_searchtableinfo
  (searchitemcode, tablename, jointoresultstablefrom, jointoresultstablewhere)
VALUES
  (2, 'qsicomments', 'qsicomments', 'corecontactinfo.contactkey = qsicomments.commentkey AND qsicomments.commenttypecode = (SELECT COALESCE(clientdefaultvalue, 0) FROM clientdefaults WHERE clientdefaultid = 82)')
go