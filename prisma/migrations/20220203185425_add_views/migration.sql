-- Add view

CREATE VIEW scoreboard AS
	SELECT COUNT(*) as correct_answers, [dbo].[challenge_participations].[user_uuid] FROM [dbo].[challenge_participations]
	LEFT JOIN [dbo].[challenges] ON [dbo].[challenge_participations].[challenge_uuid] = [dbo].[challenges].[uuid]
	LEFT JOIN [dbo].[challenge_solutions] ON [dbo].[challenges].[word_content] = [dbo].[challenge_solutions].[guess] GROUP BY [dbo].[challenge_participations].[user_uuid];


--- Add view

CREATE VIEW [dbo].[popular_words] AS
	SELECT [dbo].[challenges].[word_content], [dbo].[languages].[name], COUNT(*) as [count] FROM challenges
	LEFT JOIN [dbo].[languages] ON [dbo].[challenges].[word_language_code] = [dbo].[languages].[code]
	GROUP BY [dbo].[languages].[name], [dbo].[challenges].[word_content];
