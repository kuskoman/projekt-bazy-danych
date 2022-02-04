BEGIN TRY

BEGIN TRAN;

-- DropForeignKey
ALTER TABLE [dbo].[challenge_invites] DROP CONSTRAINT [challenge_invites_challenge_uuid_fkey];

-- DropForeignKey
ALTER TABLE [dbo].[challenge_invites] DROP CONSTRAINT [notifications_user_uuid_fkey];

-- DropForeignKey
ALTER TABLE [dbo].[challenge_participations] DROP CONSTRAINT [user_solutions_challenge_uuid_fkey];

-- DropForeignKey
ALTER TABLE [dbo].[challenge_participations] DROP CONSTRAINT [user_solutions_user_uuid_fkey];

-- DropForeignKey
ALTER TABLE [dbo].[challenge_solutions] DROP CONSTRAINT [challenge_solutions_challenge_uuid_user_uuid_fkey];

-- DropForeignKey
ALTER TABLE [dbo].[challenges] DROP CONSTRAINT [challenges_challengeTypeId_fkey];

-- DropForeignKey
ALTER TABLE [dbo].[challenges] DROP CONSTRAINT [challenges_word_content_word_language_code_fkey];

-- AddForeignKey
ALTER TABLE [dbo].[challenges] ADD CONSTRAINT [challenges_word_content_word_language_code_fkey] FOREIGN KEY ([word_content], [word_language_code]) REFERENCES [dbo].[words]([word],[language_code]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[challenges] ADD CONSTRAINT [challenges_challengeTypeId_fkey] FOREIGN KEY ([challengeTypeId]) REFERENCES [dbo].[challenge_types]([id]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[challenge_participations] ADD CONSTRAINT [user_solutions_user_uuid_fkey] FOREIGN KEY ([user_uuid]) REFERENCES [dbo].[users]([uuid]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[challenge_participations] ADD CONSTRAINT [user_solutions_challenge_uuid_fkey] FOREIGN KEY ([challenge_uuid]) REFERENCES [dbo].[challenges]([uuid]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[challenge_solutions] ADD CONSTRAINT [challenge_solutions_challenge_uuid_user_uuid_fkey] FOREIGN KEY ([challenge_uuid], [user_uuid]) REFERENCES [dbo].[challenge_participations]([challenge_uuid],[user_uuid]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[challenge_invites] ADD CONSTRAINT [notifications_user_uuid_fkey] FOREIGN KEY ([user_uuid]) REFERENCES [dbo].[users]([uuid]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[challenge_invites] ADD CONSTRAINT [challenge_invites_challenge_uuid_fkey] FOREIGN KEY ([challenge_uuid]) REFERENCES [dbo].[challenges]([uuid]) ON DELETE CASCADE ON UPDATE CASCADE;

COMMIT TRAN;

END TRY
BEGIN CATCH

IF @@TRANCOUNT > 0
BEGIN
    ROLLBACK TRAN;
END;
THROW

END CATCH
