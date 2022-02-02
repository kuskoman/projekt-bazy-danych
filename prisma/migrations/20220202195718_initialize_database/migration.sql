BEGIN TRY

BEGIN TRAN;

-- CreateTable
CREATE TABLE [dbo].[users] (
    [uuid] NCHAR(36) NOT NULL,
    [password_digest] NVARCHAR(60) NOT NULL,
    [name] NVARCHAR(1000) NOT NULL,
    [email] NVARCHAR(128) NOT NULL,
    [created_at] DATETIME2 NOT NULL CONSTRAINT [users_created_at_df] DEFAULT CURRENT_TIMESTAMP,
    [updated_at] DATETIME2 NOT NULL,
    CONSTRAINT [users_pkey] PRIMARY KEY ([uuid])
);

-- CreateTable
CREATE TABLE [dbo].[languages] (
    [name] NVARCHAR(1000) NOT NULL,
    [code] NVARCHAR(3) NOT NULL,
    [created_at] DATETIME2 NOT NULL CONSTRAINT [languages_created_at_df] DEFAULT CURRENT_TIMESTAMP,
    [updated_at] DATETIME2 NOT NULL,
    CONSTRAINT [languages_pkey] PRIMARY KEY ([code]),
    CONSTRAINT [languages_name_key] UNIQUE ([name])
);

-- CreateTable
CREATE TABLE [dbo].[words] (
    [word] NVARCHAR(100) NOT NULL,
    [length] INT NOT NULL,
    [language_code] NVARCHAR(3) NOT NULL,
    CONSTRAINT [words_pkey] PRIMARY KEY ([word],[language_code])
);

-- CreateTable
CREATE TABLE [dbo].[challenges] (
    [uuid] NCHAR(36) NOT NULL,
    [word_content] NVARCHAR(100) NOT NULL,
    [word_language_code] NVARCHAR(3) NOT NULL,
    [challengeTypeId] INT NOT NULL,
    [created_at] DATETIME2 NOT NULL CONSTRAINT [challenges_created_at_df] DEFAULT CURRENT_TIMESTAMP,
    [updated_at] DATETIME2 NOT NULL,
    CONSTRAINT [challenges_pkey] PRIMARY KEY ([uuid])
);

-- CreateTable
CREATE TABLE [dbo].[challenge_types] (
    [id] INT NOT NULL IDENTITY(1,1),
    [name] NVARCHAR(72) NOT NULL,
    [created_at] DATETIME2 NOT NULL CONSTRAINT [challenge_types_created_at_df] DEFAULT CURRENT_TIMESTAMP,
    [updated_at] DATETIME2 NOT NULL,
    CONSTRAINT [challenge_types_pkey] PRIMARY KEY ([id]),
    CONSTRAINT [challenge_types_name_key] UNIQUE ([name])
);

-- CreateTable
CREATE TABLE [dbo].[challenge_participations] (
    [challenge_uuid] NCHAR(36) NOT NULL,
    [user_uuid] NCHAR(36) NOT NULL,
    [created_at] DATETIME2 NOT NULL CONSTRAINT [challenge_participations_created_at_df] DEFAULT CURRENT_TIMESTAMP,
    [updated_at] DATETIME2 NOT NULL,
    CONSTRAINT [challenge_participations_pkey] PRIMARY KEY ([challenge_uuid],[user_uuid])
);

-- CreateTable
CREATE TABLE [dbo].[challenge_solutions] (
    [guess] NVARCHAR(100) NOT NULL,
    [challenge_uuid] NCHAR(36) NOT NULL,
    [user_uuid] NCHAR(36) NOT NULL,
    [created_at] DATETIME2 NOT NULL CONSTRAINT [challenge_solutions_created_at_df] DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT [challenge_solutions_pkey] PRIMARY KEY ([challenge_uuid],[user_uuid],[guess])
);

-- CreateTable
CREATE TABLE [dbo].[challenge_invites] (
    [uuid] NCHAR(36) NOT NULL,
    [accepted_timestamp] DATETIME2,
    [user_uuid] NCHAR(36) NOT NULL,
    [challengeUuid] NCHAR(36) NOT NULL,
    CONSTRAINT [challenge_invites_pkey] PRIMARY KEY ([uuid])
);

-- CreateIndex
CREATE INDEX [words_length_word_language_code_idx] ON [dbo].[words]([length], [word], [language_code]);

-- AddForeignKey
ALTER TABLE [dbo].[words] ADD CONSTRAINT [words_language_code_fkey] FOREIGN KEY ([language_code]) REFERENCES [dbo].[languages]([code]) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[challenges] ADD CONSTRAINT [challenges_word_content_word_language_code_fkey] FOREIGN KEY ([word_content], [word_language_code]) REFERENCES [dbo].[words]([word],[language_code]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[challenges] ADD CONSTRAINT [challenges_challengeTypeId_fkey] FOREIGN KEY ([challengeTypeId]) REFERENCES [dbo].[challenge_types]([id]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[challenge_participations] ADD CONSTRAINT [user_solutions_user_uuid_fkey] FOREIGN KEY ([user_uuid]) REFERENCES [dbo].[users]([uuid]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[challenge_participations] ADD CONSTRAINT [user_solutions_challenge_uuid_fkey] FOREIGN KEY ([challenge_uuid]) REFERENCES [dbo].[challenges]([uuid]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[challenge_solutions] ADD CONSTRAINT [challenge_solutions_challenge_uuid_user_uuid_fkey] FOREIGN KEY ([challenge_uuid], [user_uuid]) REFERENCES [dbo].[challenge_participations]([challenge_uuid],[user_uuid]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[challenge_invites] ADD CONSTRAINT [notifications_user_uuid_fkey] FOREIGN KEY ([user_uuid]) REFERENCES [dbo].[users]([uuid]) ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE [dbo].[challenge_invites] ADD CONSTRAINT [challenge_invites_challengeUuid_fkey] FOREIGN KEY ([challengeUuid]) REFERENCES [dbo].[challenges]([uuid]) ON DELETE NO ACTION ON UPDATE CASCADE;

COMMIT TRAN;

END TRY
BEGIN CATCH

IF @@TRANCOUNT > 0
BEGIN
    ROLLBACK TRAN;
END;
THROW

END CATCH
