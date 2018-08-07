DELETE FROM taqversionformatrelatedproject
WHERE taqprojectkey NOT IN (SELECT taqprojectkey from taqproject)

DELETE FROM taqversionformatrelatedproject
WHERE relatedprojectkey NOT IN (SELECT taqprojectkey from taqproject)

GO