/*
set indicator 1 for all media/formats currently set up to auto create Marketing projects
*/

update gentablesrelationshipdetail
set indicator1 = 1
where gentablesrelationshipkey = 34
GO