--- Add procedure

CREATE PROCEDURE [dbo].[insert_word]
	@language_code NVARCHAR(3),
	@word NVARCHAR(100)
AS
BEGIN
	INSERT INTO [dbo].[words] ([word], [language_code], [length])
	VALUES (@word, @language_code, LEN(@word))
END
