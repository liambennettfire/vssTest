UPDATE qsiconfigspecsync 
SET tablename='audiocassettespecs' 
WHERE tablename='cdromspecs' AND columnname='totalruntime'

UPDATE qsiconfigspecsync 
SET tablename='audiocassettespecs', columnname='numcassettes' 
WHERE tablename='cdromspecs' AND columnname='numcds'
