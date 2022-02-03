--- Add function

CREATE FUNCTION get_random_word
	(@lang NVARCHAR(3) = 'en')
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @word NVARCHAR(100)
    SET @word = (SELECT TOP 1 [word] FROM [dbo].[words] WHERE [language_code] = @lang ORDER BY (SELECT TOP 1 * FROM [dbo].[random]))
    RETURN @word
END;
