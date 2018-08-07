
-- Case #37435
CREATE NONCLUSTERED INDEX [IX_coretitleinfo_fbs07]
ON [dbo].[coretitleinfo] ([mediatypecode])
INCLUDE ([bookkey],[printingkey],[issuenumber],[standardind],[origincode],[usageclasscode])
GO



