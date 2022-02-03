--- Add view

CREATE VIEW [dbo].[popular_words] AS
	SELECT [dbo].[challenges].[word_content], [dbo].[languages].[name], COUNT(*) as [count] FROM challenges
	LEFT JOIN [dbo].[languages] ON [dbo].[challenges].[word_language_code] = [dbo].[languages].[code]
	GROUP BY [dbo].[languages].[name], [dbo].[challenges].[word_content];
