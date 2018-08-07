INSERT INTO gentablesrelationships
  (gentablesrelationshipkey, description, gentable1id, gentable2id, showallind, mappingind, mapinitialvalueind, gentable1level, gentable2level, lastuserid, lastmaintdate,
   notes)
VALUES
  (28, 'Role Type to Contact Comment Type (for Participant Note Default)', 285, 528, 0, 0, 0, 1, 1, 'QSIDBA', getdate(),
   'This relationship will identify the comment type that should be used to default the participant note based on the role type of the participant when the participant for that role type is added through a Participant by Role Section')
go
