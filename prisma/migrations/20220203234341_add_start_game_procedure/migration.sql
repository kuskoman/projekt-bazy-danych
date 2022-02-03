--- Add procedure

CREATE PROCEDURE [dbo].[start_game]
	@language_code NVARCHAR(3),
	@type_id INT
AS
BEGIN
	BEGIN TRANSACTION;
	SAVE TRANSACTION [start_game_transaction];

	DECLARE @word NVARCHAR(100)
	DECLARE @challenge_uuid NVARCHAR(36)
	DECLARE @random_players_uuids TABLE (uuid NVARCHAR(36))

	BEGIN TRY
		SET @word = [dbo].[get_random_word] (@language_code);
		SET @challenge_uuid = NEWID()

		INSERT INTO [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [updated_at])
		VALUES (@challenge_uuid, @word, @language_code, @type_id, GETDATE());

		--- selecting random 10 players to invite
		INSERT INTO @random_players_uuids SELECT TOP 10 [uuid] FROM [dbo].[users] ORDER BY CRYPT_GEN_RANDOM(4)

		INSERT INTO [dbo].[challenge_invites] ([uuid], [user_uuid], [challenge_uuid])
		SELECT NEWID(), [uuid], @challenge_uuid FROM @random_players_uuids
	COMMIT TRANSACTION 
	END TRY

	BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION [start_game_transaction]; -- rollback to start_game_transaction save point
       END
    END CATCH
END
