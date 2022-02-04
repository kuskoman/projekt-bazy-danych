--- Create function

CREATE FUNCTION solutions_for_langs ()
RETURNS TABLE
AS
RETURN 
	SELECT [word_language_code], COUNT(*) as [count]
    FROM [dbo].[challenge_solutions]
    LEFT JOIN [dbo].[challenges]
    ON [challenges].[uuid] = [challenge_solutions].[challenge_uuid]
    GROUP BY [word_language_code];
