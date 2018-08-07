DECLARE  @v_count int,
         @o_datacode int,
         @o_gentablesrelationshipdetailkey integer,
         @o_error_code	integer,
         @o_error_desc	varchar(2000)

SELECT @v_count = COUNT(*) FROM gentablesrelationships WHERE gentablesrelationshipkey=36
IF @v_count = 0 BEGIN
  INSERT INTO gentablesrelationships
    (gentablesrelationshipkey, description, gentable1id, gentable2id, showallind, mappingind, mapinitialvalueind, gentable1level, gentable2level, lastuserid, lastmaintdate, notes)
  VALUES
    (36, 'Key Project Relationship: Project Class to Project Relationship', 550, 582, 0, 1, 0, 2, 1, 'QSIDBA', getdate(), 'This relationship will allow the client to display a key related project for each project in the search results.')
END

GO
