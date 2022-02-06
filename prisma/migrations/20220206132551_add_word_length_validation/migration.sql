--- Add constraint

ALTER TABLE [dbo].[words]
	ADD CONSTRAINT [CK_words_length]
	CHECK ([length] = LEN(word));