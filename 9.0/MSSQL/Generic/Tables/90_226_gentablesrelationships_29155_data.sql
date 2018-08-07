INSERT INTO gentablesrelationships
  (gentablesrelationshipkey, description, gentable1id, gentable2id, showallind, mappingind, mapinitialvalueind, gentable1level, gentable2level, lastuserid, lastmaintdate,
   notes)
VALUES
  (29, 'Role Type to Contact Relationship (for Participant by Role section)', 285, 519, 0, 2, 0, 1, 1, 'QSIDBA', getdate(),
   'This relationship will identify the relationship type(s) that will be used to populate the related contacts dropdown when the participant for that role type is added through a Participant by Role Section.')
go
