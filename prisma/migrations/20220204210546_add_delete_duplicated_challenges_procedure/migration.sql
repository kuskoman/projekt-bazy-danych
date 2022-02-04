-- Create procedure

CREATE PROCEDURE [drop_challenge_duplicates]
AS
BEGIN
WITH [duplicates] AS (
	SELECT ROW_NUMBER() OVER(PARTITION BY [word_content], [word_language_code] ORDER BY [created_at] DESC)
	AS [rn]
	FROM [dbo].[challenges]
)
DELETE [duplicates] WHERE [rn] > 1
END;
