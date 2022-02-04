USE [jakub_surdej_14009]
GO
/****** Object:  UserDefinedFunction [dbo].[get_random_word]    Script Date: 05.02.2022 00:25:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--- Add function

CREATE FUNCTION [dbo].[get_random_word]
	(@lang NVARCHAR(3) = 'en')
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @word NVARCHAR(100)
    SET @word = (SELECT TOP 1 [word] FROM [dbo].[words] WHERE [language_code] = @lang ORDER BY (SELECT TOP 1 * FROM [dbo].[random]))
    RETURN @word
END;

GO
/****** Object:  Table [dbo].[challenges]    Script Date: 05.02.2022 00:25:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[challenges](
	[uuid] [nchar](36) NOT NULL,
	[word_content] [nvarchar](100) NOT NULL,
	[word_language_code] [nvarchar](3) NOT NULL,
	[challengeTypeId] [int] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [challenges_pkey] PRIMARY KEY CLUSTERED 
(
	[uuid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[challenge_participations]    Script Date: 05.02.2022 00:25:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[challenge_participations](
	[challenge_uuid] [nchar](36) NOT NULL,
	[user_uuid] [nchar](36) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [challenge_participations_pkey] PRIMARY KEY CLUSTERED 
(
	[challenge_uuid] ASC,
	[user_uuid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[challenge_solutions]    Script Date: 05.02.2022 00:25:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[challenge_solutions](
	[guess] [nvarchar](100) NOT NULL,
	[challenge_uuid] [nchar](36) NOT NULL,
	[user_uuid] [nchar](36) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
 CONSTRAINT [challenge_solutions_pkey] PRIMARY KEY CLUSTERED 
(
	[challenge_uuid] ASC,
	[user_uuid] ASC,
	[guess] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[scoreboard]    Script Date: 05.02.2022 00:25:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Add view

CREATE VIEW [dbo].[scoreboard] AS
	SELECT COUNT(*) as correct_answers, [dbo].[challenge_participations].[user_uuid] FROM [dbo].[challenge_participations]
	LEFT JOIN [dbo].[challenges] ON [dbo].[challenge_participations].[challenge_uuid] = [dbo].[challenges].[uuid]
	LEFT JOIN [dbo].[challenge_solutions] ON [dbo].[challenges].[word_content] = [dbo].[challenge_solutions].[guess] GROUP BY [dbo].[challenge_participations].[user_uuid];


GO
/****** Object:  Table [dbo].[languages]    Script Date: 05.02.2022 00:25:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[languages](
	[name] [nvarchar](1000) NOT NULL,
	[code] [nvarchar](3) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [languages_pkey] PRIMARY KEY CLUSTERED 
(
	[code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[popular_words]    Script Date: 05.02.2022 00:25:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--- Add view

CREATE VIEW [dbo].[popular_words] AS
	SELECT [dbo].[challenges].[word_content], [dbo].[languages].[name], COUNT(*) as [count] FROM challenges
	LEFT JOIN [dbo].[languages] ON [dbo].[challenges].[word_language_code] = [dbo].[languages].[code]
	GROUP BY [dbo].[languages].[name], [dbo].[challenges].[word_content];

GO
/****** Object:  Table [dbo].[users]    Script Date: 05.02.2022 00:25:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[users](
	[uuid] [nchar](36) NOT NULL,
	[password_digest] [nvarchar](60) NOT NULL,
	[name] [nvarchar](1000) NOT NULL,
	[email] [nvarchar](128) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [users_pkey] PRIMARY KEY CLUSTERED 
(
	[uuid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[users_by_challenge_count]    Script Date: 05.02.2022 00:25:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--- Create function

CREATE FUNCTION [dbo].[users_by_challenge_count]
    (@lang NVARCHAR(3) = 'en')
RETURNS TABLE
AS
RETURN 
    SELECT [user_uuid], COUNT([challenge_participations].[challenge_uuid]) AS [challenge_count]
    FROM [dbo].[users] RIGHT JOIN [dbo].[challenge_participations]
    ON [challenge_participations].[user_uuid] = [users].[uuid]
    LEFT JOIN [dbo].[challenges] ON [challenges].[uuid] = [challenge_uuid]
    WHERE [word_language_code] = @lang
    GROUP BY [user_uuid];

GO
/****** Object:  UserDefinedFunction [dbo].[solutions_for_langs]    Script Date: 05.02.2022 00:25:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--- Create function

CREATE FUNCTION [dbo].[solutions_for_langs] ()
RETURNS TABLE
AS
RETURN 
	SELECT [word_language_code], COUNT(*) as [count]
    FROM [dbo].[challenge_solutions]
    LEFT JOIN [dbo].[challenges]
    ON [challenges].[uuid] = [challenge_solutions].[challenge_uuid]
    GROUP BY [word_language_code];

GO
/****** Object:  View [dbo].[random]    Script Date: 05.02.2022 00:25:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--- Add view for getting random value

CREATE VIEW [dbo].[random]
AS
	SELECT CRYPT_GEN_RANDOM(4) AS random_value;

GO
/****** Object:  Table [dbo].[challenge_invites]    Script Date: 05.02.2022 00:25:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[challenge_invites](
	[uuid] [nchar](36) NOT NULL,
	[accepted_timestamp] [datetime2](7) NULL,
	[user_uuid] [nchar](36) NOT NULL,
	[challenge_uuid] [nchar](36) NOT NULL,
 CONSTRAINT [challenge_invites_pkey] PRIMARY KEY CLUSTERED 
(
	[uuid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[challenge_types]    Script Date: 05.02.2022 00:25:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[challenge_types](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](72) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[updated_at] [datetime2](7) NOT NULL,
 CONSTRAINT [challenge_types_pkey] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[words]    Script Date: 05.02.2022 00:25:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[words](
	[word] [nvarchar](100) NOT NULL,
	[length] [int] NOT NULL,
	[language_code] [nvarchar](3) NOT NULL,
 CONSTRAINT [words_pkey] PRIMARY KEY CLUSTERED 
(
	[word] ASC,
	[language_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'00b83827-6136-463d-8642-763ab9a1f2b0', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667283' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'00b83827-6136-463d-8642-763ab9a1f2b0', N'1be1d3ce-c3a2-4b8e-abca-174d6883ac5c', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667368' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'00b83827-6136-463d-8642-763ab9a1f2b0', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667379' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'056ff82a-a401-4fab-a32e-5b4b915c7160', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667385' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'056ff82a-a401-4fab-a32e-5b4b915c7160', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667391' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'07a412e5-9fe2-40e7-8bb3-1c6fbd103d0a', N'0bcfc380-b2ec-4919-8691-b4866e4f6133', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667425' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667431' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667438' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667444' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667474' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667481' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667487' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667494' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'1026cff0-bfeb-49cf-9666-cc89b9381869', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667501' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'1026cff0-bfeb-49cf-9666-cc89b9381869', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667508' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'1026cff0-bfeb-49cf-9666-cc89b9381869', N'fbae442c-6f4d-4b79-9583-9fe1c931fc65', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667515' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'129192bc-e689-4e25-801b-d236b7809ed3', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667521' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'12bdb886-fede-44aa-8ff4-a382918328f0', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667531' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'12bdb886-fede-44aa-8ff4-a382918328f0', N'89223031-6580-4ebd-92a7-6fcb09c9ca0b', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667537' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'12bdb886-fede-44aa-8ff4-a382918328f0', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667543' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'12bdb886-fede-44aa-8ff4-a382918328f0', N'93205c1d-0cde-42e8-bd37-ab5a09123c72', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667549' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'14575f82-13ae-4e08-918c-9d620c3fcf08', N'60b4e35f-4af8-4c39-8959-d263504c144c', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667556' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'17a82e36-ac43-44fe-9b3d-ba0ac3947da8', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667562' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'17a82e36-ac43-44fe-9b3d-ba0ac3947da8', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667568' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'17a82e36-ac43-44fe-9b3d-ba0ac3947da8', N'89223031-6580-4ebd-92a7-6fcb09c9ca0b', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667574' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667580' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667586' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667591' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667598' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'18dbfba5-253d-443d-9dc2-631d14d5515a', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667604' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'19cd4b2b-1d50-4c62-b221-42988e8e2265', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667610' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'19cd4b2b-1d50-4c62-b221-42988e8e2265', N'93205c1d-0cde-42e8-bd37-ab5a09123c72', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667615' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'1a143d92-d6ca-4926-b3ab-e41eed9ac694', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667621' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'1a815f63-45c8-49d4-a6c1-48e496c5ffd8', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667630' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'1aaf9d9c-e03f-48d4-b2ac-1c5345aeaab6', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667636' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'1fa8dbce-d7ac-43a0-9b80-3c007bdceb41', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667643' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'1fa8dbce-d7ac-43a0-9b80-3c007bdceb41', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667649' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'1fa8dbce-d7ac-43a0-9b80-3c007bdceb41', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667655' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'dcb267e6-009f-40ac-971c-5ccfc5409e7e', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667660' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667666' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667672' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667678' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'20334ec7-961c-4777-b953-0db3922c6093', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667684' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'20d20ea7-8d7c-4945-9ff6-3b2843be1a8e', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667690' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'244aa6a9-5c17-4519-80ec-9579e072f272', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667696' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2499f30e-55fd-4542-be16-045ec1374d42', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667703' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2499f30e-55fd-4542-be16-045ec1374d42', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667709' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2499f30e-55fd-4542-be16-045ec1374d42', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667715' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'24a9a7f6-1eff-4017-b7f9-2752012332ba', N'89223031-6580-4ebd-92a7-6fcb09c9ca0b', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667721' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'24a9a7f6-1eff-4017-b7f9-2752012332ba', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667728' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2540bca0-4019-4891-bc52-ddcef0cf29cf', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667733' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'25af3883-cb65-4917-ad63-c3518f83912d', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667739' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'25af3883-cb65-4917-ad63-c3518f83912d', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667745' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'27a74769-8025-4896-84d5-abf63e8c20f6', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667751' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'27a74769-8025-4896-84d5-abf63e8c20f6', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667757' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2a78f99e-54f0-4565-b607-c9c122ff6945', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667763' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2bfb6f6d-f877-4f8c-bb0b-4601d30d5198', N'd632112f-3364-4d51-b6f5-ef06929969f0', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667769' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2bfb6f6d-f877-4f8c-bb0b-4601d30d5198', N'd68eb68d-2ba1-473d-842e-efa9737cb4fa', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667775' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667781' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667787' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667795' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667802' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2ecb8a7f-7963-4ed4-ab3c-9c64e4b58b34', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667809' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667816' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667823' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667833' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667839' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'309529e6-b081-47af-9b60-007c4e97e82e', N'da90e20f-f35f-4fb5-a6ac-1e20120f4860', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667845' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'309529e6-b081-47af-9b60-007c4e97e82e', N'dcb267e6-009f-40ac-971c-5ccfc5409e7e', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667851' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'30af4466-e763-405d-b2f0-fb0ce6ad011f', N'1be1d3ce-c3a2-4b8e-abca-174d6883ac5c', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667856' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'30af4466-e763-405d-b2f0-fb0ce6ad011f', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667863' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'30af4466-e763-405d-b2f0-fb0ce6ad011f', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667869' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'30af4466-e763-405d-b2f0-fb0ce6ad011f', N'2041dad2-d4f8-4370-ac7b-d3f33eaf7ba3', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667875' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'30f8838e-e194-4718-a4a7-044b8deccb33', N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667880' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'30f8838e-e194-4718-a4a7-044b8deccb33', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667886' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'31932f27-38ed-4eae-bf90-d29e80b8c967', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667892' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'31932f27-38ed-4eae-bf90-d29e80b8c967', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667898' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'31e06003-5e6e-4c89-8b7a-f9cc843f2f9c', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667905' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'31e06003-5e6e-4c89-8b7a-f9cc843f2f9c', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667910' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'31e06003-5e6e-4c89-8b7a-f9cc843f2f9c', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667916' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667923' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'1be1d3ce-c3a2-4b8e-abca-174d6883ac5c', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667928' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667934' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667940' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'341183da-7158-435e-a781-a84d31babc97', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667946' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'341183da-7158-435e-a781-a84d31babc97', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667952' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3495ac14-494b-42ec-8991-159ef450f0c0', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667958' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3495ac14-494b-42ec-8991-159ef450f0c0', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667965' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'355d3c89-c760-4715-adda-9c252cbeb9b2', N'1be1d3ce-c3a2-4b8e-abca-174d6883ac5c', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667971' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'355d3c89-c760-4715-adda-9c252cbeb9b2', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667976' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'35908f1c-0166-47c3-b9b0-fb13ba21276e', N'd9c6aa61-a901-4273-8c9b-1db89a9a3352', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667982' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'366d0527-8417-4090-a49f-beb54dc8f62d', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667989' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'366d0527-8417-4090-a49f-beb54dc8f62d', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8667995' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'388dbf0f-97af-4ea0-b88c-bc9c66540766', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668000' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'39aa470d-bdf4-400f-9eab-65f5e5dbdf22', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668006' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'39aa470d-bdf4-400f-9eab-65f5e5dbdf22', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668012' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'39aa470d-bdf4-400f-9eab-65f5e5dbdf22', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668018' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'39bcaab3-0e58-4816-a3d0-1e613748857a', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668024' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'39bcaab3-0e58-4816-a3d0-1e613748857a', N'd632112f-3364-4d51-b6f5-ef06929969f0', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668030' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'39bcaab3-0e58-4816-a3d0-1e613748857a', N'd68eb68d-2ba1-473d-842e-efa9737cb4fa', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668036' AS DateTime2))
GO
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3aa323cf-0892-4b84-b3c2-3eed2f35f8ef', N'b78d69ea-1308-414e-acb0-b539b35ff945', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668042' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3aa323cf-0892-4b84-b3c2-3eed2f35f8ef', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668048' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3b89d3d9-59bc-4dca-8d0b-f745b47d1804', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668053' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3cb1c347-74b9-47b1-87c3-7d7e0961e4d6', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668059' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3cb1c347-74b9-47b1-87c3-7d7e0961e4d6', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668065' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668072' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668077' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668083' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3d63c271-5ede-467a-b4a8-f0ef99b0002c', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668089' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3d63c271-5ede-467a-b4a8-f0ef99b0002c', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668095' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3d63c271-5ede-467a-b4a8-f0ef99b0002c', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668101' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3eb0d0d4-ed5d-4675-9faf-66cd2083871c', N'256b1b1e-aae2-47b1-934b-c442a065a080', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668106' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3eb0d0d4-ed5d-4675-9faf-66cd2083871c', N'29f416b6-bf3e-48e3-bc69-7a0efcee0248', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668113' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3eb0d0d4-ed5d-4675-9faf-66cd2083871c', N'2abe0043-71bf-4647-a063-26405f88cde7', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668119' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4285150c-62ba-4e58-bdc4-b163f652c73a', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668125' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4285150c-62ba-4e58-bdc4-b163f652c73a', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668130' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'45a6c563-d24d-45f9-8ed1-2478ebbb680e', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668136' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'45a6c563-d24d-45f9-8ed1-2478ebbb680e', N'fbae442c-6f4d-4b79-9583-9fe1c931fc65', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668142' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'45fb9b03-b59c-4a1b-838a-0bb35ae6fcd5', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668148' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'45fb9b03-b59c-4a1b-838a-0bb35ae6fcd5', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668155' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'47f9d0f4-ec8c-464d-99c4-5fb9ef8fbe14', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668161' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'47f9d0f4-ec8c-464d-99c4-5fb9ef8fbe14', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668166' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'487b34ca-6417-431d-80c1-fbb630b2ca2d', N'da90e20f-f35f-4fb5-a6ac-1e20120f4860', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668172' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'499935dc-e24b-4793-8100-e562bc3adbcc', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668178' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'499935dc-e24b-4793-8100-e562bc3adbcc', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668184' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'499935dc-e24b-4793-8100-e562bc3adbcc', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668189' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4e33d54c-9e00-4c5d-933f-8e7d5b31f4d9', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668196' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4e33d54c-9e00-4c5d-933f-8e7d5b31f4d9', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668202' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4e33d54c-9e00-4c5d-933f-8e7d5b31f4d9', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668207' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4e59778d-ac70-4bb8-b4af-53a9debed1c7', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668223' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4e59778d-ac70-4bb8-b4af-53a9debed1c7', N'728519c3-3136-40b7-bfb9-561a50bc4ebd', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668229' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4e59778d-ac70-4bb8-b4af-53a9debed1c7', N'73070ab0-053a-4f45-8569-6e1ceaea9f02', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668236' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4fa21013-32e2-43b6-a89a-076f6ee70dcf', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668241' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4fa21013-32e2-43b6-a89a-076f6ee70dcf', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668249' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4fa21013-32e2-43b6-a89a-076f6ee70dcf', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668255' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'504a5221-61af-4670-8227-5f16df1128dd', N'2abe0043-71bf-4647-a063-26405f88cde7', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668260' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'504a5221-61af-4670-8227-5f16df1128dd', N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668266' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'52e6cb77-59e9-41f1-ad38-49b9ef0a4554', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668272' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'56c1b8d0-6a3a-41ac-934c-16e7f75e3f4c', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668278' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'56c1b8d0-6a3a-41ac-934c-16e7f75e3f4c', N'fbae442c-6f4d-4b79-9583-9fe1c931fc65', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668283' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668290' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668296' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668302' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'582d9b2d-60ad-4e60-aa5b-9b76ec0a50a2', N'2041dad2-d4f8-4370-ac7b-d3f33eaf7ba3', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668307' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'59a023ae-683c-4519-a443-fa02819e1747', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668313' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'728519c3-3136-40b7-bfb9-561a50bc4ebd', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668319' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'73070ab0-053a-4f45-8569-6e1ceaea9f02', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668325' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'744dea72-c59a-4785-ab1b-8f627c6901bf', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668331' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668337' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'5ab00c25-6eb4-440e-9928-5db410d8e3a0', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668343' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'5cb95288-e6a9-4471-b36e-aaa1131c4e54', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668349' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668355' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668361' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668367' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6090c485-49d6-4028-bae0-b752215fa1b8', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668374' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'03d23e9c-c1f2-4497-9d27-f164a101d41b', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668382' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'051e0399-8378-46dc-b0cb-bd60b002286b', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668399' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'06bc2ac4-1ba5-4e68-a7ff-f7181d7b696a', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668405' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'0b5db47b-7b06-4949-bfb7-cd15d80ab5c9', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668411' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'624cf2fa-8f23-4ce1-8ca1-a23a7d6f06a6', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668417' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'624cf2fa-8f23-4ce1-8ca1-a23a7d6f06a6', N'b78d69ea-1308-414e-acb0-b539b35ff945', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668422' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'624cf2fa-8f23-4ce1-8ca1-a23a7d6f06a6', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668429' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668440' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668446' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668452' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'744dea72-c59a-4785-ab1b-8f627c6901bf', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668457' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668463' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668468' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668475' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'671a22c6-c1a7-4f63-90d5-1cd55422d5a5', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668490' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'671a22c6-c1a7-4f63-90d5-1cd55422d5a5', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668496' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6778dcd9-83e0-40d4-acbc-6ed6312e84bf', N'557216b4-e674-496d-8bb4-5a8f51d766bd', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668502' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6778dcd9-83e0-40d4-acbc-6ed6312e84bf', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668507' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'684aa84a-488e-4893-b8e8-c738bf575502', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668513' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'684aa84a-488e-4893-b8e8-c738bf575502', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668518' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'684aa84a-488e-4893-b8e8-c738bf575502', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668525' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'684aa84a-488e-4893-b8e8-c738bf575502', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668536' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6ad61619-1ed6-432c-9242-f1294b25959b', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668542' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6ad61619-1ed6-432c-9242-f1294b25959b', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668548' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6ad61619-1ed6-432c-9242-f1294b25959b', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668553' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6b5adc20-b3ad-4b30-b377-e830b21d2837', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668559' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6b5adc20-b3ad-4b30-b377-e830b21d2837', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668565' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6d0680e8-9d76-4bd8-b162-d6f59ed9361b', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668578' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6d0680e8-9d76-4bd8-b162-d6f59ed9361b', N'5d819a6f-e9e9-4560-9d08-eed15fdb8c50', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668583' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6d0680e8-9d76-4bd8-b162-d6f59ed9361b', N'60b4e35f-4af8-4c39-8959-d263504c144c', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668589' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6d0680e8-9d76-4bd8-b162-d6f59ed9361b', N'613f9c48-1536-4a01-a97c-825f93bf11a4', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668594' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6d67ab92-ead9-433e-a2d5-0ab9f52e44bd', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668600' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6d67ab92-ead9-433e-a2d5-0ab9f52e44bd', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668606' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6d67ab92-ead9-433e-a2d5-0ab9f52e44bd', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668611' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6d67ab92-ead9-433e-a2d5-0ab9f52e44bd', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668624' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'71120ec8-777f-4027-8df8-b592c170b3d5', N'd961faf8-26a5-4785-8965-c043f64ac1f5', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668629' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'93205c1d-0cde-42e8-bd37-ab5a09123c72', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668635' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'972ebecb-b6e1-4d35-8ff6-ba321cca8419', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668640' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668646' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668651' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7278c38f-efc3-45fe-8598-527b92a117dd', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668663' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7278c38f-efc3-45fe-8598-527b92a117dd', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668670' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7278c38f-efc3-45fe-8598-527b92a117dd', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668675' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668682' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668687' AS DateTime2))
GO
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668693' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668699' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668710' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668717' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668722' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668728' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'77ef02f7-0c93-4dba-a6a3-73ec5c9f81be', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668734' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'77ef02f7-0c93-4dba-a6a3-73ec5c9f81be', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668739' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'77ef02f7-0c93-4dba-a6a3-73ec5c9f81be', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668761' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'78b6011b-6011-4cfd-ba85-5ef0468ea35f', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668766' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7ab4921f-ceb0-4236-a3a2-266707b912fe', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668773' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7ab8d589-258d-4228-a501-89c52b2b1b31', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668778' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7ab8d589-258d-4228-a501-89c52b2b1b31', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668784' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7ab8d589-258d-4228-a501-89c52b2b1b31', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668789' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7ca1dfad-6b4d-43b9-8b07-c4fc95d4b8dc', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668795' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7ca1dfad-6b4d-43b9-8b07-c4fc95d4b8dc', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668806' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7ca1dfad-6b4d-43b9-8b07-c4fc95d4b8dc', N'2041dad2-d4f8-4370-ac7b-d3f33eaf7ba3', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668812' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7ca1dfad-6b4d-43b9-8b07-c4fc95d4b8dc', N'256b1b1e-aae2-47b1-934b-c442a065a080', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668818' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668824' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668830' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668836' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668848' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7ea1ecea-34ab-47a3-8810-0db9d27136e3', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668854' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7f038d23-d35d-4b53-899f-86bb983d85f2', N'0c23f819-2c46-43de-ac47-1d6be2242339', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668860' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7f038d23-d35d-4b53-899f-86bb983d85f2', N'0cb10800-2fd6-4664-b849-973903be8021', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668866' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7f038d23-d35d-4b53-899f-86bb983d85f2', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668872' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7f35b964-351f-40f8-ad1b-ea747e2a9aa7', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668877' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7f35b964-351f-40f8-ad1b-ea747e2a9aa7', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668883' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'82336469-7b50-42cb-af50-5dff03a25f32', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668895' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'82336469-7b50-42cb-af50-5dff03a25f32', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668900' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'82336469-7b50-42cb-af50-5dff03a25f32', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668906' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'829c0b33-ca42-4f60-b9f9-b61eacf7b6ef', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668912' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'83e4c6b6-1cf7-4829-b83f-c3869fb99d57', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668918' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'83e4c6b6-1cf7-4829-b83f-c3869fb99d57', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668924' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'83e4c6b6-1cf7-4829-b83f-c3869fb99d57', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668929' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'88730b67-fcda-4750-a14d-56649250b33b', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668941' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'895c6f39-257f-4776-a8d5-37fe79d74648', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668946' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'89b92e6e-7b25-4acf-83de-0d99a1e3be6c', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668952' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'89b92e6e-7b25-4acf-83de-0d99a1e3be6c', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668959' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'89b92e6e-7b25-4acf-83de-0d99a1e3be6c', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668964' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'89e0061a-0070-4e35-a55c-7e4d132e7b45', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668970' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8b5620b6-afed-42f1-b7d9-7c26f33c78b1', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668981' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8b5620b6-afed-42f1-b7d9-7c26f33c78b1', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668987' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8bbf019b-c6b6-463d-a59f-6280533d54ac', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668992' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8bbf019b-c6b6-463d-a59f-6280533d54ac', N'13b76c36-b317-4541-8f77-f66ffdc38fbb', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8668998' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8bbf019b-c6b6-463d-a59f-6280533d54ac', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669004' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8bc65541-72d4-4593-91d2-c2eba66482c7', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669010' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8d64b1a7-fb69-4dea-af84-8828c55d4be4', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669016' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8d64b1a7-fb69-4dea-af84-8828c55d4be4', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669027' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8d64b1a7-fb69-4dea-af84-8828c55d4be4', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669033' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8dc0e90c-84dd-4064-bce6-84731818510c', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669039' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8dc0e90c-84dd-4064-bce6-84731818510c', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669044' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8dc0e90c-84dd-4064-bce6-84731818510c', N'557216b4-e674-496d-8bb4-5a8f51d766bd', CAST(N'2022-02-04T23:23:56.8650000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669050' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8dc0e90c-84dd-4064-bce6-84731818510c', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669056' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'9016d376-af54-4b9f-b551-3e71b7892505', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669067' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669073' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669079' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669101' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669106' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'91892c7a-c442-441f-ba6f-7368f7b23040', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669113' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'93e766ff-f02b-48e6-b128-8c1b55d9c42f', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669119' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'93e766ff-f02b-48e6-b128-8c1b55d9c42f', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669134' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'93f1f7c3-c207-4651-aeb1-e65d55342509', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669140' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'94f1d08e-d128-4262-a86f-77a3937d226f', N'2041dad2-d4f8-4370-ac7b-d3f33eaf7ba3', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669145' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'94f1d08e-d128-4262-a86f-77a3937d226f', N'256b1b1e-aae2-47b1-934b-c442a065a080', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669151' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669157' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669163' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669175' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669180' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'96aca781-ef20-47ed-afc4-403e74a21cf0', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669186' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'96aca781-ef20-47ed-afc4-403e74a21cf0', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669191' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'97c097b4-1248-4b08-ba61-c5a38ecf4256', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669197' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'97c097b4-1248-4b08-ba61-c5a38ecf4256', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669202' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'97c097b4-1248-4b08-ba61-c5a38ecf4256', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669209' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'9881d8c1-aa05-4dbd-8661-1c9852c71966', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669221' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'9881d8c1-aa05-4dbd-8661-1c9852c71966', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669226' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'9a3d1f42-44a5-4674-9228-ebc6af6c09dd', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669232' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'9d2566e7-4c35-4e92-afe4-b291bedfb386', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669238' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669243' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669249' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669255' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a0311cdf-e8c0-4449-8f07-e6bdb41bf393', N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669266' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a0311cdf-e8c0-4449-8f07-e6bdb41bf393', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669272' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a0311cdf-e8c0-4449-8f07-e6bdb41bf393', N'4130105a-24e1-41b7-917f-671188d8a4cd', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669277' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a0311cdf-e8c0-4449-8f07-e6bdb41bf393', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669283' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a90422c1-dd0d-40a4-99c9-b3d29cc34444', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669288' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a93f2194-99bf-4aa0-885a-9333dae80915', N'60b4e35f-4af8-4c39-8959-d263504c144c', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669294' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ad0c87a7-b1a6-487c-b9e5-ce74dad0f9a9', N'da15904a-934a-4531-95d2-b7369ecd4090', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669306' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ad0c87a7-b1a6-487c-b9e5-ce74dad0f9a9', N'da90e20f-f35f-4fb5-a6ac-1e20120f4860', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669312' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669317' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd632112f-3364-4d51-b6f5-ef06929969f0', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669322' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd68eb68d-2ba1-473d-842e-efa9737cb4fa', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669328' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd961faf8-26a5-4785-8965-c043f64ac1f5', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669334' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669339' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669351' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669357' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669363' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b248b6cf-d820-4081-881c-92b4e98e2e2f', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669368' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b5384ef5-478a-408f-b659-2c5f979259d8', N'4130105a-24e1-41b7-917f-671188d8a4cd', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669374' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b65c8e89-ef00-49fe-b758-957c1202e6b7', N'd961faf8-26a5-4785-8965-c043f64ac1f5', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669379' AS DateTime2))
GO
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b65c8e89-ef00-49fe-b758-957c1202e6b7', N'd9c6aa61-a901-4273-8c9b-1db89a9a3352', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669391' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b8359032-c382-4363-ab64-9d283a4ba93f', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669398' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b8359032-c382-4363-ab64-9d283a4ba93f', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669403' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b8359032-c382-4363-ab64-9d283a4ba93f', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669408' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b90a1103-2094-44cc-857c-355ae0d84e1c', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669414' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b90a1103-2094-44cc-857c-355ae0d84e1c', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669420' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b90a1103-2094-44cc-857c-355ae0d84e1c', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669425' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b941e2b0-e368-40fb-b8e0-869181245d28', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669444' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b97ac4ac-abe6-4b59-90e7-c181ee5d9b55', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669450' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b97ac4ac-abe6-4b59-90e7-c181ee5d9b55', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669456' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'bafd58a0-208d-44b3-822f-474fd2ee5951', N'fc91f5c7-229f-498e-b2dd-ad2f2d97621d', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669461' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669467' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669473' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669485' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'bc608b88-b675-49b8-875b-4927037d8d74', N'd9c6aa61-a901-4273-8c9b-1db89a9a3352', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669490' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'bc608b88-b675-49b8-875b-4927037d8d74', N'da15904a-934a-4531-95d2-b7369ecd4090', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669496' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'bf5c60dc-0c66-4dcd-a19f-b2ccc5b66b83', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669502' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'bf5c60dc-0c66-4dcd-a19f-b2ccc5b66b83', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669508' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c2c9037f-74e1-4b21-9772-8b6cd4275526', N'0c23f819-2c46-43de-ac47-1d6be2242339', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669514' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c2c9037f-74e1-4b21-9772-8b6cd4275526', N'0cb10800-2fd6-4664-b849-973903be8021', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669520' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c2c9037f-74e1-4b21-9772-8b6cd4275526', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669531' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c2e53b86-ea47-435c-b7fc-3ff72a155443', N'93205c1d-0cde-42e8-bd37-ab5a09123c72', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669537' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c2e53b86-ea47-435c-b7fc-3ff72a155443', N'972ebecb-b6e1-4d35-8ff6-ba321cca8419', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669543' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c5983e4f-6021-4909-b98a-59e5540e75de', N'13b76c36-b317-4541-8f77-f66ffdc38fbb', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669548' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c5983e4f-6021-4909-b98a-59e5540e75de', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669554' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c5d990bb-1e34-496b-83da-743298a069db', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669560' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669572' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669578' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669584' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669590' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c62640b4-9012-43b9-8f3d-041a008501f6', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669596' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c62640b4-9012-43b9-8f3d-041a008501f6', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669601' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c7269899-a326-41f1-b55b-10fd17540bd6', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669607' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c7269899-a326-41f1-b55b-10fd17540bd6', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669619' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c7269899-a326-41f1-b55b-10fd17540bd6', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669625' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'cbbdff6d-8f19-49a4-a703-45d43eefd101', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669630' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'cbbdff6d-8f19-49a4-a703-45d43eefd101', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669636' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'cc76083c-5c77-45dd-9c13-452066ad0877', N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669642' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'cc76083c-5c77-45dd-9c13-452066ad0877', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669647' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'cc76083c-5c77-45dd-9c13-452066ad0877', N'4130105a-24e1-41b7-917f-671188d8a4cd', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669653' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'cc76083c-5c77-45dd-9c13-452066ad0877', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669665' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ce22af16-9d31-4642-b206-e96cc6d7e0f3', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669670' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ce22af16-9d31-4642-b206-e96cc6d7e0f3', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669676' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ce22af16-9d31-4642-b206-e96cc6d7e0f3', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669683' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'cec7bdbd-0f1b-4708-b280-31ec38971bb2', N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669688' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'cec7bdbd-0f1b-4708-b280-31ec38971bb2', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669694' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'728519c3-3136-40b7-bfb9-561a50bc4ebd', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669700' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'73070ab0-053a-4f45-8569-6e1ceaea9f02', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669706' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'744dea72-c59a-4785-ab1b-8f627c6901bf', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669711' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669717' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'cfcc785c-b3b7-433a-a8c7-7ce63aab734c', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669723' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'cfcc785c-b3b7-433a-a8c7-7ce63aab734c', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669729' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd10fb17e-391f-4d3e-a948-c00482eacd77', N'613f9c48-1536-4a01-a97c-825f93bf11a4', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669734' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd10fb17e-391f-4d3e-a948-c00482eacd77', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669740' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669747' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669752' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669758' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669764' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd2dfecd1-4060-49ba-a046-7aad821b199f', N'13b76c36-b317-4541-8f77-f66ffdc38fbb', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669770' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd2dfecd1-4060-49ba-a046-7aad821b199f', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669776' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd5319834-7d9c-4d3f-bfec-50a38d1262ac', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669782' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669787' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669891' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669905' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669914' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'db2ad574-0f44-4e41-a261-eef71adff422', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669920' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'db2ad574-0f44-4e41-a261-eef71adff422', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669927' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'db2ad574-0f44-4e41-a261-eef71adff422', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669933' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'db2ad574-0f44-4e41-a261-eef71adff422', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669939' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'972ebecb-b6e1-4d35-8ff6-ba321cca8419', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669945' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669950' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669957' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669963' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669970' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669975' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669981' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669986' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669992' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8669998' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670004' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670010' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e1ca7d08-bcc9-4f85-9782-834db1d69e48', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670016' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e231f1a8-7c56-402d-bf96-7dee700c05c8', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670022' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e231f1a8-7c56-402d-bf96-7dee700c05c8', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670027' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e231f1a8-7c56-402d-bf96-7dee700c05c8', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670033' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e231f1a8-7c56-402d-bf96-7dee700c05c8', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670039' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e28aa984-a016-41be-b3d3-078b5e1345e3', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670046' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e28ec349-e24d-4d60-84e7-752fb5fac474', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670052' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e28ec349-e24d-4d60-84e7-752fb5fac474', N'b78d69ea-1308-414e-acb0-b539b35ff945', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670058' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e62374d5-d2a3-4332-90d2-d06ca338de64', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670063' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670069' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670074' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670081' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670086' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e730b417-2bf3-463b-a163-7b39113b689e', N'03d23e9c-c1f2-4497-9d27-f164a101d41b', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670092' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e81f69bc-775b-42ee-8e33-ac114030d448', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670097' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e831db5f-5a24-4b40-a5a2-4510368bb206', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670103' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e88dbadd-607f-4fcf-9463-095ff48613a6', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670108' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e88dbadd-607f-4fcf-9463-095ff48613a6', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670114' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e8a43cde-0406-4847-9c2e-dbc79fd73e9b', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670121' AS DateTime2))
GO
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e8a43cde-0406-4847-9c2e-dbc79fd73e9b', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670127' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e8a43cde-0406-4847-9c2e-dbc79fd73e9b', N'fbae442c-6f4d-4b79-9583-9fe1c931fc65', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670132' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e8a43cde-0406-4847-9c2e-dbc79fd73e9b', N'fc91f5c7-229f-498e-b2dd-ad2f2d97621d', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670137' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670143' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670148' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670154' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670160' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670166' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670171' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670177' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f12f3829-e8f6-4db7-8ac5-c96d9b9727af', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670183' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f26a57ba-179a-493a-b1b0-314a3886c684', N'dcb267e6-009f-40ac-971c-5ccfc5409e7e', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670188' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f26a57ba-179a-493a-b1b0-314a3886c684', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670194' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f26a57ba-179a-493a-b1b0-314a3886c684', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670200' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f2d68448-6cef-42f8-b355-104a7e1de37e', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670206' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f2d68448-6cef-42f8-b355-104a7e1de37e', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670211' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f2d68448-6cef-42f8-b355-104a7e1de37e', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670217' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f6d6c97f-cb2b-4bbb-87d5-c06cd77a15de', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670222' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f6d6c97f-cb2b-4bbb-87d5-c06cd77a15de', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670228' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'fa36be8e-fe7d-4c29-99c8-d85c62d6e59e', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670234' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'fa36be8e-fe7d-4c29-99c8-d85c62d6e59e', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670241' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'fa36be8e-fe7d-4c29-99c8-d85c62d6e59e', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670246' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'fa36be8e-fe7d-4c29-99c8-d85c62d6e59e', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670253' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670259' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670264' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670271' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670276' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670283' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670288' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670294' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:56.8660000' AS DateTime2), CAST(N'2022-02-04T23:23:56.8670299' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cośrodowe', N'00b83827-6136-463d-8642-763ab9a1f2b0', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dokwitłem', N'00b83827-6136-463d-8642-763ab9a1f2b0', N'1be1d3ce-c3a2-4b8e-abca-174d6883ac5c', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'znaglajmy', N'00b83827-6136-463d-8642-763ab9a1f2b0', N'1be1d3ce-c3a2-4b8e-abca-174d6883ac5c', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'imponując', N'00b83827-6136-463d-8642-763ab9a1f2b0', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kłopotała', N'00b83827-6136-463d-8642-763ab9a1f2b0', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pooplataj', N'00b83827-6136-463d-8642-763ab9a1f2b0', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'semickich', N'00b83827-6136-463d-8642-763ab9a1f2b0', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wełnicami', N'00b83827-6136-463d-8642-763ab9a1f2b0', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chilopod', N'056ff82a-a401-4fab-a32e-5b4b915c7160', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'circinal', N'056ff82a-a401-4fab-a32e-5b4b915c7160', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'devotion', N'056ff82a-a401-4fab-a32e-5b4b915c7160', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hopthumb', N'056ff82a-a401-4fab-a32e-5b4b915c7160', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'illuvium', N'056ff82a-a401-4fab-a32e-5b4b915c7160', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'innatism', N'056ff82a-a401-4fab-a32e-5b4b915c7160', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'renumber', N'056ff82a-a401-4fab-a32e-5b4b915c7160', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dumose', N'07a412e5-9fe2-40e7-8bb3-1c6fbd103d0a', N'0bcfc380-b2ec-4919-8691-b4866e4f6133', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'groyne', N'07a412e5-9fe2-40e7-8bb3-1c6fbd103d0a', N'0bcfc380-b2ec-4919-8691-b4866e4f6133', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lading', N'07a412e5-9fe2-40e7-8bb3-1c6fbd103d0a', N'0bcfc380-b2ec-4919-8691-b4866e4f6133', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niebollywoodzką', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieuzmysławiani', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'skonsygnowaniem', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spoważniałyście', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wydoktoryzowali', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaśmiardnęliśmy', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'najjurniejszymi', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niearcygroźnych', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieaukcjonowani', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepodczesujący', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieprolongująca', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezastawieniem', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'skonsygnowaniem', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'śródchrzęstnymi', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kontemplowałbym', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niehongkońskiej', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieinteligencja', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nienadpiławskim', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieordynowanych', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezdryfowanego', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'skonsygnowaniem', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unieważniałyśmy', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieoklaskaniami', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'skonsygnowaniem', N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'futraminy', N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hartleyem', N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podlepiać', N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozorania', N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wspinaniu', N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'narajacie', N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'orszańska', N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'oźrebcież', N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przyłęcką', N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rzeźniczą', N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sagownica', N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wygubione', N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chaparral', N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kiełkował', N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podlepiać', N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trynknęło', N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wygubione', N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyłamujmy', N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'counterlighted', N'1026cff0-bfeb-49cf-9666-cc89b9381869', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'escalloniaceae', N'1026cff0-bfeb-49cf-9666-cc89b9381869', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'meritmongering', N'1026cff0-bfeb-49cf-9666-cc89b9381869', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'misdescriptive', N'1026cff0-bfeb-49cf-9666-cc89b9381869', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonimpregnated', N'1026cff0-bfeb-49cf-9666-cc89b9381869', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'palanquiningly', N'1026cff0-bfeb-49cf-9666-cc89b9381869', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'superextremely', N'1026cff0-bfeb-49cf-9666-cc89b9381869', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'meritmongering', N'1026cff0-bfeb-49cf-9666-cc89b9381869', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'meritmongering', N'1026cff0-bfeb-49cf-9666-cc89b9381869', N'fbae442c-6f4d-4b79-9583-9fe1c931fc65', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'paramyosinogen', N'1026cff0-bfeb-49cf-9666-cc89b9381869', N'fbae442c-6f4d-4b79-9583-9fe1c931fc65', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pasteurisation', N'1026cff0-bfeb-49cf-9666-cc89b9381869', N'fbae442c-6f4d-4b79-9583-9fe1c931fc65', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'presuppression', N'1026cff0-bfeb-49cf-9666-cc89b9381869', N'fbae442c-6f4d-4b79-9583-9fe1c931fc65', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'superextremely', N'1026cff0-bfeb-49cf-9666-cc89b9381869', N'fbae442c-6f4d-4b79-9583-9fe1c931fc65', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'transformation', N'1026cff0-bfeb-49cf-9666-cc89b9381869', N'fbae442c-6f4d-4b79-9583-9fe1c931fc65', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dioninami', N'129192bc-e689-4e25-801b-d236b7809ed3', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kaperowań', N'129192bc-e689-4e25-801b-d236b7809ed3', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odświeżać', N'129192bc-e689-4e25-801b-d236b7809ed3', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zagładźże', N'129192bc-e689-4e25-801b-d236b7809ed3', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaprzątań', N'129192bc-e689-4e25-801b-d236b7809ed3', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zastukocę', N'129192bc-e689-4e25-801b-d236b7809ed3', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naklepanie', N'12bdb886-fede-44aa-8ff4-a382918328f0', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naszywałem', N'12bdb886-fede-44aa-8ff4-a382918328f0', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niecisnącą', N'12bdb886-fede-44aa-8ff4-a382918328f0', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pozużywało', N'12bdb886-fede-44aa-8ff4-a382918328f0', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zampolitem', N'12bdb886-fede-44aa-8ff4-a382918328f0', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'jodowanego', N'12bdb886-fede-44aa-8ff4-a382918328f0', N'89223031-6580-4ebd-92a7-6fcb09c9ca0b', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'barakowymi', N'12bdb886-fede-44aa-8ff4-a382918328f0', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naziębiłam', N'12bdb886-fede-44aa-8ff4-a382918328f0', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'otrzewnymi', N'12bdb886-fede-44aa-8ff4-a382918328f0', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pozużywało', N'12bdb886-fede-44aa-8ff4-a382918328f0', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pozużywało', N'12bdb886-fede-44aa-8ff4-a382918328f0', N'93205c1d-0cde-42e8-bd37-ab5a09123c72', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'oplątujcie', N'14575f82-13ae-4e08-918c-9d620c3fcf08', N'60b4e35f-4af8-4c39-8959-d263504c144c', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spropaguję', N'14575f82-13ae-4e08-918c-9d620c3fcf08', N'60b4e35f-4af8-4c39-8959-d263504c144c', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'warknęłyby', N'14575f82-13ae-4e08-918c-9d620c3fcf08', N'60b4e35f-4af8-4c39-8959-d263504c144c', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zwyższyłby', N'14575f82-13ae-4e08-918c-9d620c3fcf08', N'60b4e35f-4af8-4c39-8959-d263504c144c', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'amaranthine', N'17a82e36-ac43-44fe-9b3d-ba0ac3947da8', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'inadvertent', N'17a82e36-ac43-44fe-9b3d-ba0ac3947da8', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'preclothing', N'17a82e36-ac43-44fe-9b3d-ba0ac3947da8', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sternomancy', N'17a82e36-ac43-44fe-9b3d-ba0ac3947da8', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unbarbarous', N'17a82e36-ac43-44fe-9b3d-ba0ac3947da8', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'amaranthine', N'17a82e36-ac43-44fe-9b3d-ba0ac3947da8', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chaetetidae', N'17a82e36-ac43-44fe-9b3d-ba0ac3947da8', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'illinoisian', N'17a82e36-ac43-44fe-9b3d-ba0ac3947da8', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'jateorhizin', N'17a82e36-ac43-44fe-9b3d-ba0ac3947da8', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'preclothing', N'17a82e36-ac43-44fe-9b3d-ba0ac3947da8', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bifurcation', N'17a82e36-ac43-44fe-9b3d-ba0ac3947da8', N'89223031-6580-4ebd-92a7-6fcb09c9ca0b', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'illinoisian', N'17a82e36-ac43-44fe-9b3d-ba0ac3947da8', N'89223031-6580-4ebd-92a7-6fcb09c9ca0b', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'masculinism', N'17a82e36-ac43-44fe-9b3d-ba0ac3947da8', N'89223031-6580-4ebd-92a7-6fcb09c9ca0b', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unclenching', N'17a82e36-ac43-44fe-9b3d-ba0ac3947da8', N'89223031-6580-4ebd-92a7-6fcb09c9ca0b', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wheyishness', N'17a82e36-ac43-44fe-9b3d-ba0ac3947da8', N'89223031-6580-4ebd-92a7-6fcb09c9ca0b', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'compromisingly', N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'deutencephalic', N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'counterlighted', N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'escalloniaceae', N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'intuitionalist', N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonethicalness', N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overpowerfully', N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'palanquiningly', N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pasteurisation', N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spirillotropic', N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'allothigenetic', N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'escalloniaceae', N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kleptomaniacal', N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overpersecuted', N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overpowerfully', N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'superextremely', N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonethicalness', N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'perimetrically', N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'październikom', N'18dbfba5-253d-443d-9dc2-631d14d5515a', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaagitowałyby', N'18dbfba5-253d-443d-9dc2-631d14d5515a', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'devotion', N'19cd4b2b-1d50-4c62-b221-42988e8e2265', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'palliser', N'19cd4b2b-1d50-4c62-b221-42988e8e2265', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'renumber', N'19cd4b2b-1d50-4c62-b221-42988e8e2265', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'skittled', N'19cd4b2b-1d50-4c62-b221-42988e8e2265', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'alarmism', N'19cd4b2b-1d50-4c62-b221-42988e8e2265', N'93205c1d-0cde-42e8-bd37-ab5a09123c72', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'debugger', N'19cd4b2b-1d50-4c62-b221-42988e8e2265', N'93205c1d-0cde-42e8-bd37-ab5a09123c72', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'excerpta', N'19cd4b2b-1d50-4c62-b221-42988e8e2265', N'93205c1d-0cde-42e8-bd37-ab5a09123c72', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hybodont', N'19cd4b2b-1d50-4c62-b221-42988e8e2265', N'93205c1d-0cde-42e8-bd37-ab5a09123c72', CAST(N'2022-02-04T23:23:57.0380000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'guarachy', N'1a143d92-d6ca-4926-b3ab-e41eed9ac694', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kompleta', N'1a143d92-d6ca-4926-b3ab-e41eed9ac694', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odważają', N'1a143d92-d6ca-4926-b3ab-e41eed9ac694', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'porfirów', N'1a143d92-d6ca-4926-b3ab-e41eed9ac694', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sedesowi', N'1a143d92-d6ca-4926-b3ab-e41eed9ac694', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'serwujmy', N'1a143d92-d6ca-4926-b3ab-e41eed9ac694', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'siurkach', N'1a143d92-d6ca-4926-b3ab-e41eed9ac694', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'annexion', N'1a815f63-45c8-49d4-a6c1-48e496c5ffd8', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'challiho', N'1a815f63-45c8-49d4-a6c1-48e496c5ffd8', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ciconine', N'1a815f63-45c8-49d4-a6c1-48e496c5ffd8', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hematics', N'1a815f63-45c8-49d4-a6c1-48e496c5ffd8', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overbody', N'1a815f63-45c8-49d4-a6c1-48e496c5ffd8', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'palliser', N'1a815f63-45c8-49d4-a6c1-48e496c5ffd8', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sedanier', N'1a815f63-45c8-49d4-a6c1-48e496c5ffd8', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'violence', N'1a815f63-45c8-49d4-a6c1-48e496c5ffd8', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hydrozespoły', N'1aaf9d9c-e03f-48d4-b2ac-1c5345aeaab6', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieobsrywany', N'1aaf9d9c-e03f-48d4-b2ac-1c5345aeaab6', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'norwegizację', N'1aaf9d9c-e03f-48d4-b2ac-1c5345aeaab6', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'poprzeginali', N'1aaf9d9c-e03f-48d4-b2ac-1c5345aeaab6', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'upadlibyście', N'1aaf9d9c-e03f-48d4-b2ac-1c5345aeaab6', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ornamentują', N'1fa8dbce-d7ac-43a0-9b80-3c007bdceb41', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przyganiłem', N'1fa8dbce-d7ac-43a0-9b80-3c007bdceb41', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'modylionowi', N'1fa8dbce-d7ac-43a0-9b80-3c007bdceb41', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'smyczkowymi', N'1fa8dbce-d7ac-43a0-9b80-3c007bdceb41', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'konidialnej', N'1fa8dbce-d7ac-43a0-9b80-3c007bdceb41', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'likwidusami', N'1fa8dbce-d7ac-43a0-9b80-3c007bdceb41', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niedozujące', N'1fa8dbce-d7ac-43a0-9b80-3c007bdceb41', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odżywiajmyż', N'1fa8dbce-d7ac-43a0-9b80-3c007bdceb41', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zesmutniałą', N'1fa8dbce-d7ac-43a0-9b80-3c007bdceb41', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'whipperginny', N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'dcb267e6-009f-40ac-971c-5ccfc5409e7e', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'antigambling', N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'recrudescent', N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'strangurious', N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unactiveness', N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'underchamber', N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gesticulator', N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'heliochromic', N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'impoverisher', N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'recensionist', N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spidermonkey', N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'triangulates', N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unpermeating', N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unthundering', N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gastrulation', N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unthundering', N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'evolutoid', N'20334ec7-961c-4777-b953-0db3922c6093', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'exorcised', N'20334ec7-961c-4777-b953-0db3922c6093', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'noncoring', N'20334ec7-961c-4777-b953-0db3922c6093', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'phellonic', N'20334ec7-961c-4777-b953-0db3922c6093', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'skepsises', N'20334ec7-961c-4777-b953-0db3922c6093', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bifurcation', N'20d20ea7-8d7c-4945-9ff6-3b2843be1a8e', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'charcuterie', N'20d20ea7-8d7c-4945-9ff6-3b2843be1a8e', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'concentrate', N'20d20ea7-8d7c-4945-9ff6-3b2843be1a8e', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'glucolipine', N'20d20ea7-8d7c-4945-9ff6-3b2843be1a8e', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'phototypist', N'20d20ea7-8d7c-4945-9ff6-3b2843be1a8e', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'traducement', N'20d20ea7-8d7c-4945-9ff6-3b2843be1a8e', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unmotioning', N'20d20ea7-8d7c-4945-9ff6-3b2843be1a8e', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'venturously', N'20d20ea7-8d7c-4945-9ff6-3b2843be1a8e', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'stumplike', N'244aa6a9-5c17-4519-80ec-9579e072f272', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'antilibration', N'2499f30e-55fd-4542-be16-045ec1374d42', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cardiorrheuma', N'2499f30e-55fd-4542-be16-045ec1374d42', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'consolamentum', N'2499f30e-55fd-4542-be16-045ec1374d42', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'counterflight', N'2499f30e-55fd-4542-be16-045ec1374d42', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cruroinguinal', N'2499f30e-55fd-4542-be16-045ec1374d42', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'slavification', N'2499f30e-55fd-4542-be16-045ec1374d42', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'supraspinatus', N'2499f30e-55fd-4542-be16-045ec1374d42', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'counterflight', N'2499f30e-55fd-4542-be16-045ec1374d42', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'haemorrhaging', N'2499f30e-55fd-4542-be16-045ec1374d42', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'suburbanising', N'2499f30e-55fd-4542-be16-045ec1374d42', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'anathematised', N'2499f30e-55fd-4542-be16-045ec1374d42', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'antilibration', N'2499f30e-55fd-4542-be16-045ec1374d42', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'brachydactyly', N'2499f30e-55fd-4542-be16-045ec1374d42', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cardiorrheuma', N'2499f30e-55fd-4542-be16-045ec1374d42', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'counterflight', N'2499f30e-55fd-4542-be16-045ec1374d42', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'exceedingness', N'2499f30e-55fd-4542-be16-045ec1374d42', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'phlebenterism', N'2499f30e-55fd-4542-be16-045ec1374d42', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'retrogressive', N'2499f30e-55fd-4542-be16-045ec1374d42', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niemroczoną', N'24a9a7f6-1eff-4017-b7f9-2752012332ba', N'89223031-6580-4ebd-92a7-6fcb09c9ca0b', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'oberluftach', N'24a9a7f6-1eff-4017-b7f9-2752012332ba', N'89223031-6580-4ebd-92a7-6fcb09c9ca0b', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odżywiajmyż', N'24a9a7f6-1eff-4017-b7f9-2752012332ba', N'89223031-6580-4ebd-92a7-6fcb09c9ca0b', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'skrupulatkę', N'24a9a7f6-1eff-4017-b7f9-2752012332ba', N'89223031-6580-4ebd-92a7-6fcb09c9ca0b', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'urywającemu', N'24a9a7f6-1eff-4017-b7f9-2752012332ba', N'89223031-6580-4ebd-92a7-6fcb09c9ca0b', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zastrachana', N'24a9a7f6-1eff-4017-b7f9-2752012332ba', N'89223031-6580-4ebd-92a7-6fcb09c9ca0b', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zgniataczem', N'24a9a7f6-1eff-4017-b7f9-2752012332ba', N'89223031-6580-4ebd-92a7-6fcb09c9ca0b', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'antypasatom', N'24a9a7f6-1eff-4017-b7f9-2752012332ba', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dekorujcież', N'24a9a7f6-1eff-4017-b7f9-2752012332ba', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'doginałyśmy', N'24a9a7f6-1eff-4017-b7f9-2752012332ba', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dostrajałem', N'24a9a7f6-1eff-4017-b7f9-2752012332ba', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niemroczoną', N'24a9a7f6-1eff-4017-b7f9-2752012332ba', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trudnopalny', N'24a9a7f6-1eff-4017-b7f9-2752012332ba', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zatracaniom', N'24a9a7f6-1eff-4017-b7f9-2752012332ba', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'anachronously', N'2540bca0-4019-4891-bc52-ddcef0cf29cf', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cruroinguinal', N'2540bca0-4019-4891-bc52-ddcef0cf29cf', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'exploratively', N'2540bca0-4019-4891-bc52-ddcef0cf29cf', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'metallography', N'2540bca0-4019-4891-bc52-ddcef0cf29cf', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nondedicative', N'2540bca0-4019-4891-bc52-ddcef0cf29cf', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hebdu', N'25af3883-cb65-4917-ad63-c3518f83912d', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kupra', N'25af3883-cb65-4917-ad63-c3518f83912d', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pojeb', N'25af3883-cb65-4917-ad63-c3518f83912d', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dechy', N'25af3883-cb65-4917-ad63-c3518f83912d', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hebdu', N'25af3883-cb65-4917-ad63-c3518f83912d', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kupra', N'25af3883-cb65-4917-ad63-c3518f83912d', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pojeb', N'25af3883-cb65-4917-ad63-c3518f83912d', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rocku', N'25af3883-cb65-4917-ad63-c3518f83912d', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sorus', N'25af3883-cb65-4917-ad63-c3518f83912d', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tężca', N'25af3883-cb65-4917-ad63-c3518f83912d', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tymfy', N'25af3883-cb65-4917-ad63-c3518f83912d', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dozbrajań', N'27a74769-8025-4896-84d5-abf63e8c20f6', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'etylowano', N'27a74769-8025-4896-84d5-abf63e8c20f6', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'futraminy', N'27a74769-8025-4896-84d5-abf63e8c20f6', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozorania', N'27a74769-8025-4896-84d5-abf63e8c20f6', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wymywacie', N'27a74769-8025-4896-84d5-abf63e8c20f6', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'aliantach', N'27a74769-8025-4896-84d5-abf63e8c20f6', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'faraonowi', N'27a74769-8025-4896-84d5-abf63e8c20f6', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kabulskim', N'27a74769-8025-4896-84d5-abf63e8c20f6', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zakupicie', N'27a74769-8025-4896-84d5-abf63e8c20f6', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ziomalowi', N'27a74769-8025-4896-84d5-abf63e8c20f6', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'agnification', N'2a78f99e-54f0-4565-b607-c9c122ff6945', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'craftspeople', N'2a78f99e-54f0-4565-b607-c9c122ff6945', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'impoverisher', N'2a78f99e-54f0-4565-b607-c9c122ff6945', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reirrigation', N'2a78f99e-54f0-4565-b607-c9c122ff6945', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'stereotypies', N'2a78f99e-54f0-4565-b607-c9c122ff6945', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unredeemably', N'2a78f99e-54f0-4565-b607-c9c122ff6945', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'victorianize', N'2a78f99e-54f0-4565-b607-c9c122ff6945', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'oligomyodian', N'2bfb6f6d-f877-4f8c-bb0b-4601d30d5198', N'd632112f-3364-4d51-b6f5-ef06929969f0', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hypopygidium', N'2bfb6f6d-f877-4f8c-bb0b-4601d30d5198', N'd68eb68d-2ba1-473d-842e-efa9737cb4fa', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'oligomyodian', N'2bfb6f6d-f877-4f8c-bb0b-4601d30d5198', N'd68eb68d-2ba1-473d-842e-efa9737cb4fa', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'preadvertise', N'2bfb6f6d-f877-4f8c-bb0b-4601d30d5198', N'd68eb68d-2ba1-473d-842e-efa9737cb4fa', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sclerometric', N'2bfb6f6d-f877-4f8c-bb0b-4601d30d5198', N'd68eb68d-2ba1-473d-842e-efa9737cb4fa', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unanalogical', N'2bfb6f6d-f877-4f8c-bb0b-4601d30d5198', N'd68eb68d-2ba1-473d-842e-efa9737cb4fa', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lect', N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wush', N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cace', N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dict', N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'oats', N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'amay', N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'arri', N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cace', N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dict', N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'seba', N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'serb', N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kiki', N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lect', N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reen', N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'serb', N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'toho', N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zasycaną', N'2ecb8a7f-7963-4ed4-ab3c-9c64e4b58b34', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'blinter', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'censual', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kirundi', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wickiup', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'arcadia', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'censual', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hadrons', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naphtol', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rajidae', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'upshear', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'vincula', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'azuline', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'censual', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chazzan', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lapeler', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'luxuria', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'outfast', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'thugged', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'beghard', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'censual', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gonadal', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'highway', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'inlying', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rosetty', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'twelfth', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'washoff', N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'botcheries', N'309529e6-b081-47af-9b60-007c4e97e82e', N'da90e20f-f35f-4fb5-a6ac-1e20120f4860', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cystometer', N'309529e6-b081-47af-9b60-007c4e97e82e', N'da90e20f-f35f-4fb5-a6ac-1e20120f4860', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'durational', N'309529e6-b081-47af-9b60-007c4e97e82e', N'da90e20f-f35f-4fb5-a6ac-1e20120f4860', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'roundridge', N'309529e6-b081-47af-9b60-007c4e97e82e', N'da90e20f-f35f-4fb5-a6ac-1e20120f4860', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unvolitive', N'309529e6-b081-47af-9b60-007c4e97e82e', N'da90e20f-f35f-4fb5-a6ac-1e20120f4860', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'roundridge', N'309529e6-b081-47af-9b60-007c4e97e82e', N'dcb267e6-009f-40ac-971c-5ccfc5409e7e', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'haliczanin', N'30af4466-e763-405d-b2f0-fb0ce6ad011f', N'1be1d3ce-c3a2-4b8e-abca-174d6883ac5c', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kartoflarń', N'30af4466-e763-405d-b2f0-fb0ce6ad011f', N'1be1d3ce-c3a2-4b8e-abca-174d6883ac5c', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kersantytu', N'30af4466-e763-405d-b2f0-fb0ce6ad011f', N'1be1d3ce-c3a2-4b8e-abca-174d6883ac5c', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nielodzące', N'30af4466-e763-405d-b2f0-fb0ce6ad011f', N'1be1d3ce-c3a2-4b8e-abca-174d6883ac5c', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'paliczkowa', N'30af4466-e763-405d-b2f0-fb0ce6ad011f', N'1be1d3ce-c3a2-4b8e-abca-174d6883ac5c', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rzęsistszy', N'30af4466-e763-405d-b2f0-fb0ce6ad011f', N'1be1d3ce-c3a2-4b8e-abca-174d6883ac5c', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wybrzydzać', N'30af4466-e763-405d-b2f0-fb0ce6ad011f', N'1be1d3ce-c3a2-4b8e-abca-174d6883ac5c', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'haliczanin', N'30af4466-e763-405d-b2f0-fb0ce6ad011f', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'oplątujcie', N'30af4466-e763-405d-b2f0-fb0ce6ad011f', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozprzęgaj', N'30af4466-e763-405d-b2f0-fb0ce6ad011f', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozkułacza', N'30af4466-e763-405d-b2f0-fb0ce6ad011f', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'suberynach', N'30af4466-e763-405d-b2f0-fb0ce6ad011f', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'haliczanin', N'30af4466-e763-405d-b2f0-fb0ce6ad011f', N'2041dad2-d4f8-4370-ac7b-d3f33eaf7ba3', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'narwałyśmy', N'30f8838e-e194-4718-a4a7-044b8deccb33', N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'solipsysta', N'30f8838e-e194-4718-a4a7-044b8deccb33', N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'suberynach', N'30f8838e-e194-4718-a4a7-044b8deccb33', N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odgarniano', N'30f8838e-e194-4718-a4a7-044b8deccb33', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odmalowuje', N'30f8838e-e194-4718-a4a7-044b8deccb33', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozkułacza', N'30f8838e-e194-4718-a4a7-044b8deccb33', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rzęsistszy', N'30f8838e-e194-4718-a4a7-044b8deccb33', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'suberynach', N'30f8838e-e194-4718-a4a7-044b8deccb33', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'canty', N'31932f27-38ed-4eae-bf90-d29e80b8c967', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'shole', N'31932f27-38ed-4eae-bf90-d29e80b8c967', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sises', N'31932f27-38ed-4eae-bf90-d29e80b8c967', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'vivos', N'31932f27-38ed-4eae-bf90-d29e80b8c967', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'seral', N'31932f27-38ed-4eae-bf90-d29e80b8c967', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cardiorrheuma', N'31e06003-5e6e-4c89-8b7a-f9cc843f2f9c', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pneumatoscope', N'31e06003-5e6e-4c89-8b7a-f9cc843f2f9c', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ptenoglossate', N'31e06003-5e6e-4c89-8b7a-f9cc843f2f9c', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0390000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'transliterate', N'31e06003-5e6e-4c89-8b7a-f9cc843f2f9c', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'undeliberated', N'31e06003-5e6e-4c89-8b7a-f9cc843f2f9c', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unpatternized', N'31e06003-5e6e-4c89-8b7a-f9cc843f2f9c', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cardiorrheuma', N'31e06003-5e6e-4c89-8b7a-f9cc843f2f9c', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'organogenesis', N'31e06003-5e6e-4c89-8b7a-f9cc843f2f9c', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'palatoglossal', N'31e06003-5e6e-4c89-8b7a-f9cc843f2f9c', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'retrogressive', N'31e06003-5e6e-4c89-8b7a-f9cc843f2f9c', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unpatternized', N'31e06003-5e6e-4c89-8b7a-f9cc843f2f9c', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unpatternized', N'31e06003-5e6e-4c89-8b7a-f9cc843f2f9c', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'karbonylujmyż', N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nienapsikaniu', N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podprowadzony', N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zwietrzeniach', N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niebukowatych', N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'1be1d3ce-c3a2-4b8e-abca-174d6883ac5c', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zarachowałoby', N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'1be1d3ce-c3a2-4b8e-abca-174d6883ac5c', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kowariantnymi', N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nietrząsające', N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'porozmnażania', N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'proprioceptor', N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'szczecinowymi', N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'umilknięciami', N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaagitowałyby', N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieobrównywań', N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'oprzyrządowań', N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ponagrywaliby', N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rebirthingach', N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trigeminus', N'341183da-7158-435e-a781-a84d31babc97', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'handleable', N'341183da-7158-435e-a781-a84d31babc97', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'manometers', N'341183da-7158-435e-a781-a84d31babc97', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'osteoclast', N'341183da-7158-435e-a781-a84d31babc97', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'philonoist', N'341183da-7158-435e-a781-a84d31babc97', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'virtualism', N'341183da-7158-435e-a781-a84d31babc97', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'parturitions', N'3495ac14-494b-42ec-8991-159ef450f0c0', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pauciloquent', N'3495ac14-494b-42ec-8991-159ef450f0c0', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'subobliquely', N'3495ac14-494b-42ec-8991-159ef450f0c0', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'aecidiostage', N'3495ac14-494b-42ec-8991-159ef450f0c0', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ambulatorily', N'3495ac14-494b-42ec-8991-159ef450f0c0', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unmetaphysic', N'3495ac14-494b-42ec-8991-159ef450f0c0', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unperfidious', N'3495ac14-494b-42ec-8991-159ef450f0c0', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unstimulated', N'3495ac14-494b-42ec-8991-159ef450f0c0', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'decernment', N'355d3c89-c760-4715-adda-9c252cbeb9b2', N'1be1d3ce-c3a2-4b8e-abca-174d6883ac5c', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sociolatry', N'355d3c89-c760-4715-adda-9c252cbeb9b2', N'1be1d3ce-c3a2-4b8e-abca-174d6883ac5c', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cystometer', N'355d3c89-c760-4715-adda-9c252cbeb9b2', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'decernment', N'355d3c89-c760-4715-adda-9c252cbeb9b2', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hippodamia', N'355d3c89-c760-4715-adda-9c252cbeb9b2', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nondefiner', N'355d3c89-c760-4715-adda-9c252cbeb9b2', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'plagiaries', N'355d3c89-c760-4715-adda-9c252cbeb9b2', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'presetting', N'355d3c89-c760-4715-adda-9c252cbeb9b2', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'underhatch', N'355d3c89-c760-4715-adda-9c252cbeb9b2', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unsorrowed', N'355d3c89-c760-4715-adda-9c252cbeb9b2', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fiancailles', N'35908f1c-0166-47c3-b9b0-fb13ba21276e', N'd9c6aa61-a901-4273-8c9b-1db89a9a3352', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'heteroptics', N'35908f1c-0166-47c3-b9b0-fb13ba21276e', N'd9c6aa61-a901-4273-8c9b-1db89a9a3352', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mesosporium', N'35908f1c-0166-47c3-b9b0-fb13ba21276e', N'd9c6aa61-a901-4273-8c9b-1db89a9a3352', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'observative', N'35908f1c-0166-47c3-b9b0-fb13ba21276e', N'd9c6aa61-a901-4273-8c9b-1db89a9a3352', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kostkowatemu', N'366d0527-8417-4090-a49f-beb54dc8f62d', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'olszóweckimi', N'366d0527-8417-4090-a49f-beb54dc8f62d', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wietrznikach', N'366d0527-8417-4090-a49f-beb54dc8f62d', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'apokatastazę', N'366d0527-8417-4090-a49f-beb54dc8f62d', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'estymowałyby', N'366d0527-8417-4090-a49f-beb54dc8f62d', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niechlejącym', N'366d0527-8417-4090-a49f-beb54dc8f62d', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odhuknęliśmy', N'366d0527-8417-4090-a49f-beb54dc8f62d', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'okleiłybyśmy', N'366d0527-8417-4090-a49f-beb54dc8f62d', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'olszóweckimi', N'366d0527-8417-4090-a49f-beb54dc8f62d', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zniechęciłeś', N'366d0527-8417-4090-a49f-beb54dc8f62d', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'minezengerom', N'388dbf0f-97af-4ea0-b88c-bc9c66540766', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ośmioaktowej', N'388dbf0f-97af-4ea0-b88c-bc9c66540766', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'otworzeniach', N'388dbf0f-97af-4ea0-b88c-bc9c66540766', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przetasujesz', N'388dbf0f-97af-4ea0-b88c-bc9c66540766', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spokładanego', N'388dbf0f-97af-4ea0-b88c-bc9c66540766', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zagrzebianom', N'388dbf0f-97af-4ea0-b88c-bc9c66540766', N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'aecidiostage', N'39aa470d-bdf4-400f-9eab-65f5e5dbdf22', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'agnification', N'39aa470d-bdf4-400f-9eab-65f5e5dbdf22', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'clavicithern', N'39aa470d-bdf4-400f-9eab-65f5e5dbdf22', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'groundkeeper', N'39aa470d-bdf4-400f-9eab-65f5e5dbdf22', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'heliochromic', N'39aa470d-bdf4-400f-9eab-65f5e5dbdf22', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'philosophism', N'39aa470d-bdf4-400f-9eab-65f5e5dbdf22', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prepigmental', N'39aa470d-bdf4-400f-9eab-65f5e5dbdf22', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unsurrounded', N'39aa470d-bdf4-400f-9eab-65f5e5dbdf22', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'adenosarcoma', N'39aa470d-bdf4-400f-9eab-65f5e5dbdf22', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'equisetaceae', N'39aa470d-bdf4-400f-9eab-65f5e5dbdf22', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'impoverisher', N'39aa470d-bdf4-400f-9eab-65f5e5dbdf22', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'philosophism', N'39aa470d-bdf4-400f-9eab-65f5e5dbdf22', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unperfidious', N'39aa470d-bdf4-400f-9eab-65f5e5dbdf22', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'withholdings', N'39aa470d-bdf4-400f-9eab-65f5e5dbdf22', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'woodmancraft', N'39aa470d-bdf4-400f-9eab-65f5e5dbdf22', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'philosophism', N'39aa470d-bdf4-400f-9eab-65f5e5dbdf22', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'monopolowymi', N'39bcaab3-0e58-4816-a3d0-1e613748857a', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'olszóweckimi', N'39bcaab3-0e58-4816-a3d0-1e613748857a', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'udźwięcznisz', N'39bcaab3-0e58-4816-a3d0-1e613748857a', N'd632112f-3364-4d51-b6f5-ef06929969f0', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niechmielący', N'39bcaab3-0e58-4816-a3d0-1e613748857a', N'd68eb68d-2ba1-473d-842e-efa9737cb4fa', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'betangle', N'3aa323cf-0892-4b84-b3c2-3eed2f35f8ef', N'b78d69ea-1308-414e-acb0-b539b35ff945', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hircarra', N'3aa323cf-0892-4b84-b3c2-3eed2f35f8ef', N'b78d69ea-1308-414e-acb0-b539b35ff945', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'skittled', N'3aa323cf-0892-4b84-b3c2-3eed2f35f8ef', N'b78d69ea-1308-414e-acb0-b539b35ff945', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'violence', N'3aa323cf-0892-4b84-b3c2-3eed2f35f8ef', N'b78d69ea-1308-414e-acb0-b539b35ff945', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cameleon', N'3aa323cf-0892-4b84-b3c2-3eed2f35f8ef', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'charonic', N'3aa323cf-0892-4b84-b3c2-3eed2f35f8ef', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'foreguts', N'3aa323cf-0892-4b84-b3c2-3eed2f35f8ef', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'leverman', N'3aa323cf-0892-4b84-b3c2-3eed2f35f8ef', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'begrudged', N'3b89d3d9-59bc-4dca-8d0b-f745b47d1804', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'maestosos', N'3b89d3d9-59bc-4dca-8d0b-f745b47d1804', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overraked', N'3b89d3d9-59bc-4dca-8d0b-f745b47d1804', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'puppetdom', N'3b89d3d9-59bc-4dca-8d0b-f745b47d1804', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'subsystem', N'3b89d3d9-59bc-4dca-8d0b-f745b47d1804', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'błogosławionego', N'3cb1c347-74b9-47b1-87c3-7d7e0961e4d6', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nienadpiławskim', N'3cb1c347-74b9-47b1-87c3-7d7e0961e4d6', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podpuchnięciami', N'3cb1c347-74b9-47b1-87c3-7d7e0961e4d6', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'powyrąbywaliśmy', N'3cb1c347-74b9-47b1-87c3-7d7e0961e4d6', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wersyfikatorscy', N'3cb1c347-74b9-47b1-87c3-7d7e0961e4d6', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'intergranularna', N'3cb1c347-74b9-47b1-87c3-7d7e0961e4d6', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mikrofonującego', N'3cb1c347-74b9-47b1-87c3-7d7e0961e4d6', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepabianickimi', N'3cb1c347-74b9-47b1-87c3-7d7e0961e4d6', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezestrzelania', N'3cb1c347-74b9-47b1-87c3-7d7e0961e4d6', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odheroizowywana', N'3cb1c347-74b9-47b1-87c3-7d7e0961e4d6', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spoważniałyście', N'3cb1c347-74b9-47b1-87c3-7d7e0961e4d6', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'terkolilibyście', N'3cb1c347-74b9-47b1-87c3-7d7e0961e4d6', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prescience', N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unexhorted', N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unsorrowed', N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'badgerweed', N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'economiser', N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fourbagger', N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'presbyopia', N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'schooldays', N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'virtualism', N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'abortional', N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'antiselene', N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'elasticity', N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pinpricked', N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'plagiaries', N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'presuppose', N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tricennial', N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'undilating', N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'faraonowi', N'3d63c271-5ede-467a-b4a8-f0ef99b0002c', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaprzątań', N'3d63c271-5ede-467a-b4a8-f0ef99b0002c', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chaparral', N'3d63c271-5ede-467a-b4a8-f0ef99b0002c', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wegetując', N'3d63c271-5ede-467a-b4a8-f0ef99b0002c', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ziomalowi', N'3d63c271-5ede-467a-b4a8-f0ef99b0002c', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zmałpowań', N'3d63c271-5ede-467a-b4a8-f0ef99b0002c', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'amebowaty', N'3d63c271-5ede-467a-b4a8-f0ef99b0002c', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dioninami', N'3d63c271-5ede-467a-b4a8-f0ef99b0002c', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'południku', N'3d63c271-5ede-467a-b4a8-f0ef99b0002c', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'soplowate', N'3d63c271-5ede-467a-b4a8-f0ef99b0002c', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zagładźże', N'3d63c271-5ede-467a-b4a8-f0ef99b0002c', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaoponuje', N'3d63c271-5ede-467a-b4a8-f0ef99b0002c', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zapudłują', N'3d63c271-5ede-467a-b4a8-f0ef99b0002c', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ziomalowi', N'3d63c271-5ede-467a-b4a8-f0ef99b0002c', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'intergranularna', N'3eb0d0d4-ed5d-4675-9faf-66cd2083871c', N'256b1b1e-aae2-47b1-934b-c442a065a080', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieoblicowanymi', N'3eb0d0d4-ed5d-4675-9faf-66cd2083871c', N'256b1b1e-aae2-47b1-934b-c442a065a080', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepodczesujący', N'3eb0d0d4-ed5d-4675-9faf-66cd2083871c', N'256b1b1e-aae2-47b1-934b-c442a065a080', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pokancerowaniom', N'3eb0d0d4-ed5d-4675-9faf-66cd2083871c', N'256b1b1e-aae2-47b1-934b-c442a065a080', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wmanewrowaniach', N'3eb0d0d4-ed5d-4675-9faf-66cd2083871c', N'256b1b1e-aae2-47b1-934b-c442a065a080', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wydoktoryzowali', N'3eb0d0d4-ed5d-4675-9faf-66cd2083871c', N'256b1b1e-aae2-47b1-934b-c442a065a080', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieoklaskaniami', N'3eb0d0d4-ed5d-4675-9faf-66cd2083871c', N'29f416b6-bf3e-48e3-bc69-7a0efcee0248', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieskoślawienie', N'3eb0d0d4-ed5d-4675-9faf-66cd2083871c', N'29f416b6-bf3e-48e3-bc69-7a0efcee0248', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niewydatowanemu', N'3eb0d0d4-ed5d-4675-9faf-66cd2083871c', N'29f416b6-bf3e-48e3-bc69-7a0efcee0248', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przygięlibyście', N'3eb0d0d4-ed5d-4675-9faf-66cd2083871c', N'29f416b6-bf3e-48e3-bc69-7a0efcee0248', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaśmiardnęliśmy', N'3eb0d0d4-ed5d-4675-9faf-66cd2083871c', N'29f416b6-bf3e-48e3-bc69-7a0efcee0248', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niebodzechowska', N'3eb0d0d4-ed5d-4675-9faf-66cd2083871c', N'2abe0043-71bf-4647-a063-26405f88cde7', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bastowanie', N'4285150c-62ba-4e58-bdc4-b163f652c73a', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'paliczkowa', N'4285150c-62ba-4e58-bdc4-b163f652c73a', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozplatasz', N'4285150c-62ba-4e58-bdc4-b163f652c73a', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'serowarami', N'4285150c-62ba-4e58-bdc4-b163f652c73a', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'warknęłyby', N'4285150c-62ba-4e58-bdc4-b163f652c73a', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zamęczyłem', N'4285150c-62ba-4e58-bdc4-b163f652c73a', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'serowarami', N'4285150c-62ba-4e58-bdc4-b163f652c73a', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wilgotnawo', N'4285150c-62ba-4e58-bdc4-b163f652c73a', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fourfiusher', N'45a6c563-d24d-45f9-8ed1-2478ebbb680e', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'grippleness', N'45a6c563-d24d-45f9-8ed1-2478ebbb680e', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mesosporium', N'45a6c563-d24d-45f9-8ed1-2478ebbb680e', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'protocolize', N'45a6c563-d24d-45f9-8ed1-2478ebbb680e', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reapologies', N'45a6c563-d24d-45f9-8ed1-2478ebbb680e', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rewarehouse', N'45a6c563-d24d-45f9-8ed1-2478ebbb680e', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'aerifaction', N'45a6c563-d24d-45f9-8ed1-2478ebbb680e', N'fbae442c-6f4d-4b79-9583-9fe1c931fc65', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'biocenology', N'45a6c563-d24d-45f9-8ed1-2478ebbb680e', N'fbae442c-6f4d-4b79-9583-9fe1c931fc65', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'heteroptics', N'45a6c563-d24d-45f9-8ed1-2478ebbb680e', N'fbae442c-6f4d-4b79-9583-9fe1c931fc65', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'holostomate', N'45a6c563-d24d-45f9-8ed1-2478ebbb680e', N'fbae442c-6f4d-4b79-9583-9fe1c931fc65', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'menorhyncha', N'45a6c563-d24d-45f9-8ed1-2478ebbb680e', N'fbae442c-6f4d-4b79-9583-9fe1c931fc65', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reintuition', N'45a6c563-d24d-45f9-8ed1-2478ebbb680e', N'fbae442c-6f4d-4b79-9583-9fe1c931fc65', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rewarehouse', N'45a6c563-d24d-45f9-8ed1-2478ebbb680e', N'fbae442c-6f4d-4b79-9583-9fe1c931fc65', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ścisłego', N'45fb9b03-b59c-4a1b-838a-0bb35ae6fcd5', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'śledzisz', N'45fb9b03-b59c-4a1b-838a-0bb35ae6fcd5', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zasycaną', N'45fb9b03-b59c-4a1b-838a-0bb35ae6fcd5', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'guerille', N'45fb9b03-b59c-4a1b-838a-0bb35ae6fcd5', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ściekowy', N'45fb9b03-b59c-4a1b-838a-0bb35ae6fcd5', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'collations', N'47f9d0f4-ec8c-464d-99c4-5fb9ef8fbe14', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cystometer', N'47f9d0f4-ec8c-464d-99c4-5fb9ef8fbe14', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'decigramme', N'47f9d0f4-ec8c-464d-99c4-5fb9ef8fbe14', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trigeminus', N'47f9d0f4-ec8c-464d-99c4-5fb9ef8fbe14', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'aquaplaner', N'47f9d0f4-ec8c-464d-99c4-5fb9ef8fbe14', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fourbagger', N'47f9d0f4-ec8c-464d-99c4-5fb9ef8fbe14', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'osteolytic', N'47f9d0f4-ec8c-464d-99c4-5fb9ef8fbe14', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'presuppose', N'47f9d0f4-ec8c-464d-99c4-5fb9ef8fbe14', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'skeltonics', N'47f9d0f4-ec8c-464d-99c4-5fb9ef8fbe14', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unblanched', N'47f9d0f4-ec8c-464d-99c4-5fb9ef8fbe14', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unsorrowed', N'47f9d0f4-ec8c-464d-99c4-5fb9ef8fbe14', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mantrowaliby', N'487b34ca-6417-431d-80c1-fbb630b2ca2d', N'da90e20f-f35f-4fb5-a6ac-1e20120f4860', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pacierzowych', N'487b34ca-6417-431d-80c1-fbb630b2ca2d', N'da90e20f-f35f-4fb5-a6ac-1e20120f4860', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niebodzechowska', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nienadpiławskim', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepodczesujący', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieuciszających', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niewycałowującą', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezdryfowanego', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wersyfikatorscy', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wmanewrowaniach', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieoblicowanymi', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepodczesujący', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieuszczypliwym', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezestrzelania', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'potencjonalnych', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozwalalibyście', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'samoudręczaniom', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unieważniałyśmy', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'najjurniejszymi', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieaukcjonowani', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepoliczkowana', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieszczotkująca', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niewyksięgowani', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odheroizowywana', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'skonsygnowaniem', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'terkolilibyście', N'499935dc-e24b-4793-8100-e562bc3adbcc', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0400000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nienitrującymi', N'4e33d54c-9e00-4c5d-933f-8e7d5b31f4d9', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pazerniejszego', N'4e33d54c-9e00-4c5d-933f-8e7d5b31f4d9', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'technostresowi', N'4e33d54c-9e00-4c5d-933f-8e7d5b31f4d9', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wykolegowanych', N'4e33d54c-9e00-4c5d-933f-8e7d5b31f4d9', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wypukłodrukowi', N'4e33d54c-9e00-4c5d-933f-8e7d5b31f4d9', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bieszczadzkimi', N'4e33d54c-9e00-4c5d-933f-8e7d5b31f4d9', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fikobilinowymi', N'4e33d54c-9e00-4c5d-933f-8e7d5b31f4d9', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niedokopaniami', N'4e33d54c-9e00-4c5d-933f-8e7d5b31f4d9', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyświdrowywały', N'4e33d54c-9e00-4c5d-933f-8e7d5b31f4d9', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'eksplorowałaby', N'4e33d54c-9e00-4c5d-933f-8e7d5b31f4d9', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieprzypędzaną', N'4e33d54c-9e00-4c5d-933f-8e7d5b31f4d9', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'skarłowaciałej', N'4e33d54c-9e00-4c5d-933f-8e7d5b31f4d9', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyświdrowywały', N'4e33d54c-9e00-4c5d-933f-8e7d5b31f4d9', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pociecho', N'4e59778d-ac70-4bb8-b4af-53a9debed1c7', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'siurkach', N'4e59778d-ac70-4bb8-b4af-53a9debed1c7', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'omijania', N'4e59778d-ac70-4bb8-b4af-53a9debed1c7', N'728519c3-3136-40b7-bfb9-561a50bc4ebd', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'siurkach', N'4e59778d-ac70-4bb8-b4af-53a9debed1c7', N'728519c3-3136-40b7-bfb9-561a50bc4ebd', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bordunom', N'4e59778d-ac70-4bb8-b4af-53a9debed1c7', N'73070ab0-053a-4f45-8569-6e1ceaea9f02', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'omijania', N'4e59778d-ac70-4bb8-b4af-53a9debed1c7', N'73070ab0-053a-4f45-8569-6e1ceaea9f02', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'maestosos', N'4fa21013-32e2-43b6-a89a-076f6ee70dcf', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overspins', N'4fa21013-32e2-43b6-a89a-076f6ee70dcf', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'astrachan', N'4fa21013-32e2-43b6-a89a-076f6ee70dcf', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'maestosos', N'4fa21013-32e2-43b6-a89a-076f6ee70dcf', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'coverside', N'4fa21013-32e2-43b6-a89a-076f6ee70dcf', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lacewoman', N'4fa21013-32e2-43b6-a89a-076f6ee70dcf', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ninhydrin', N'4fa21013-32e2-43b6-a89a-076f6ee70dcf', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'basketries', N'504a5221-61af-4670-8227-5f16df1128dd', N'2abe0043-71bf-4647-a063-26405f88cde7', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'crocheting', N'504a5221-61af-4670-8227-5f16df1128dd', N'2abe0043-71bf-4647-a063-26405f88cde7', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dilucidate', N'504a5221-61af-4670-8227-5f16df1128dd', N'2abe0043-71bf-4647-a063-26405f88cde7', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cercocebus', N'504a5221-61af-4670-8227-5f16df1128dd', N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'choucroute', N'504a5221-61af-4670-8227-5f16df1128dd', N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'decigramme', N'504a5221-61af-4670-8227-5f16df1128dd', N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'elasticity', N'504a5221-61af-4670-8227-5f16df1128dd', N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'involucred', N'504a5221-61af-4670-8227-5f16df1128dd', N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'poriomanic', N'504a5221-61af-4670-8227-5f16df1128dd', N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sericteria', N'504a5221-61af-4670-8227-5f16df1128dd', N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pokancerowaniom', N'52e6cb77-59e9-41f1-ad38-49b9ef0a4554', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'błogosławionego', N'56c1b8d0-6a3a-41ac-934c-16e7f75e3f4c', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'intergranularna', N'56c1b8d0-6a3a-41ac-934c-16e7f75e3f4c', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieintabulowane', N'56c1b8d0-6a3a-41ac-934c-16e7f75e3f4c', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieotrząchnięty', N'56c1b8d0-6a3a-41ac-934c-16e7f75e3f4c', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieposłuszeństw', N'56c1b8d0-6a3a-41ac-934c-16e7f75e3f4c', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezestrzelania', N'56c1b8d0-6a3a-41ac-934c-16e7f75e3f4c', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tranzystorowymi', N'56c1b8d0-6a3a-41ac-934c-16e7f75e3f4c', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odrealniających', N'56c1b8d0-6a3a-41ac-934c-16e7f75e3f4c', N'fbae442c-6f4d-4b79-9583-9fe1c931fc65', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'górnicą', N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ponękać', N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chodami', N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'górnicą', N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'krewili', N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'łysieje', N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trącisz', N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'włamcie', N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zgadnąć', N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'górnicą', N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'krupcom', N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'magodie', N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pacnęła', N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ramnozy', N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trącisz', N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'żachnął', N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zgrabię', N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'barretry', N'582d9b2d-60ad-4e60-aa5b-9b76ec0a50a2', N'2041dad2-d4f8-4370-ac7b-d3f33eaf7ba3', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hornwood', N'582d9b2d-60ad-4e60-aa5b-9b76ec0a50a2', N'2041dad2-d4f8-4370-ac7b-d3f33eaf7ba3', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'laborage', N'582d9b2d-60ad-4e60-aa5b-9b76ec0a50a2', N'2041dad2-d4f8-4370-ac7b-d3f33eaf7ba3', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'leverman', N'582d9b2d-60ad-4e60-aa5b-9b76ec0a50a2', N'2041dad2-d4f8-4370-ac7b-d3f33eaf7ba3', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'millcake', N'582d9b2d-60ad-4e60-aa5b-9b76ec0a50a2', N'2041dad2-d4f8-4370-ac7b-d3f33eaf7ba3', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'picunche', N'582d9b2d-60ad-4e60-aa5b-9b76ec0a50a2', N'2041dad2-d4f8-4370-ac7b-d3f33eaf7ba3', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cervicolumbar', N'59a023ae-683c-4519-a443-fa02819e1747', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'exploratively', N'59a023ae-683c-4519-a443-fa02819e1747', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mousquetaires', N'59a023ae-683c-4519-a443-fa02819e1747', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'retrogressive', N'59a023ae-683c-4519-a443-fa02819e1747', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sensationally', N'59a023ae-683c-4519-a443-fa02819e1747', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'suburbanising', N'59a023ae-683c-4519-a443-fa02819e1747', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'transliterate', N'59a023ae-683c-4519-a443-fa02819e1747', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unspottedness', N'59a023ae-683c-4519-a443-fa02819e1747', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'antiselene', N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'728519c3-3136-40b7-bfb9-561a50bc4ebd', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'breakpoint', N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'728519c3-3136-40b7-bfb9-561a50bc4ebd', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'collations', N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'728519c3-3136-40b7-bfb9-561a50bc4ebd', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'crocheting', N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'728519c3-3136-40b7-bfb9-561a50bc4ebd', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'involucred', N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'728519c3-3136-40b7-bfb9-561a50bc4ebd', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'multicurie', N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'728519c3-3136-40b7-bfb9-561a50bc4ebd', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'underhatch', N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'728519c3-3136-40b7-bfb9-561a50bc4ebd', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dimensible', N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'73070ab0-053a-4f45-8569-6e1ceaea9f02', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'involucred', N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'73070ab0-053a-4f45-8569-6e1ceaea9f02', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'involucred', N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'744dea72-c59a-4785-ab1b-8f627c6901bf', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'semiacidic', N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'744dea72-c59a-4785-ab1b-8f627c6901bf', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'brassavola', N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dimensible', N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'equinities', N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'involucred', N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'proposable', N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sericteria', N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'synthetise', N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'katakumbami', N'5ab00c25-6eb4-440e-9928-5db410d8e3a0', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pyłoodporna', N'5ab00c25-6eb4-440e-9928-5db410d8e3a0', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tabuizowane', N'5ab00c25-6eb4-440e-9928-5db410d8e3a0', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieparciejąca', N'5cb95288-e6a9-4471-b36e-aaa1131c4e54', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niewybłaganym', N'5cb95288-e6a9-4471-b36e-aaa1131c4e54', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieżółciejący', N'5cb95288-e6a9-4471-b36e-aaa1131c4e54', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'umilknięciami', N'5cb95288-e6a9-4471-b36e-aaa1131c4e54', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bephilter', N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'coverside', N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'graveling', N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hieracite', N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'outmating', N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overwarms', N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'parameric', N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'underripe', N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bephilter', N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'casthouse', N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pleonasms', N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sargassos', N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'subtectal', N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'virgilism', N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mouthroot', N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'orbicular', N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'parameric', N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'shydepoke', N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hematics', N'6090c485-49d6-4028-bae0-b752215fa1b8', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'szafujące', N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'03d23e9c-c1f2-4497-9d27-f164a101d41b', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'drażliwcu', N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'051e0399-8378-46dc-b0cb-bd60b002286b', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kłopotała', N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'051e0399-8378-46dc-b0cb-bd60b002286b', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'narajacie', N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'051e0399-8378-46dc-b0cb-bd60b002286b', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niebodąca', N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'051e0399-8378-46dc-b0cb-bd60b002286b', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'warownych', N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'051e0399-8378-46dc-b0cb-bd60b002286b', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyklinano', N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'051e0399-8378-46dc-b0cb-bd60b002286b', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wykonalną', N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'051e0399-8378-46dc-b0cb-bd60b002286b', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wywróżyły', N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'051e0399-8378-46dc-b0cb-bd60b002286b', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'południku', N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'06bc2ac4-1ba5-4e68-a7ff-f7181d7b696a', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uległabym', N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'06bc2ac4-1ba5-4e68-a7ff-f7181d7b696a', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'znikające', N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'06bc2ac4-1ba5-4e68-a7ff-f7181d7b696a', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'faraonowi', N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'0b5db47b-7b06-4949-bfb7-cd15d80ab5c9', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kręgowcem', N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'0b5db47b-7b06-4949-bfb7-cd15d80ab5c9', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'neocenzur', N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'0b5db47b-7b06-4949-bfb7-cd15d80ab5c9', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'piętrzoną', N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'0b5db47b-7b06-4949-bfb7-cd15d80ab5c9', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zatajanie', N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'0b5db47b-7b06-4949-bfb7-cd15d80ab5c9', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'animizowanego', N'624cf2fa-8f23-4ce1-8ca1-a23a7d6f06a6', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niefluorowani', N'624cf2fa-8f23-4ce1-8ca1-a23a7d6f06a6', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podkopywałbyś', N'624cf2fa-8f23-4ce1-8ca1-a23a7d6f06a6', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przecinałyśmy', N'624cf2fa-8f23-4ce1-8ca1-a23a7d6f06a6', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozgrodzeniem', N'624cf2fa-8f23-4ce1-8ca1-a23a7d6f06a6', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyplotowanego', N'624cf2fa-8f23-4ce1-8ca1-a23a7d6f06a6', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyprodukowuję', N'624cf2fa-8f23-4ce1-8ca1-a23a7d6f06a6', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyrębywałyśmy', N'624cf2fa-8f23-4ce1-8ca1-a23a7d6f06a6', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'umilknięciami', N'624cf2fa-8f23-4ce1-8ca1-a23a7d6f06a6', N'b78d69ea-1308-414e-acb0-b539b35ff945', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zweryfikujcie', N'624cf2fa-8f23-4ce1-8ca1-a23a7d6f06a6', N'b78d69ea-1308-414e-acb0-b539b35ff945', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dekapilatorze', N'624cf2fa-8f23-4ce1-8ca1-a23a7d6f06a6', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'enkawudystami', N'624cf2fa-8f23-4ce1-8ca1-a23a7d6f06a6', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'karbonylujmyż', N'624cf2fa-8f23-4ce1-8ca1-a23a7d6f06a6', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podprowadzony', N'624cf2fa-8f23-4ce1-8ca1-a23a7d6f06a6', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyprodukowuję', N'624cf2fa-8f23-4ce1-8ca1-a23a7d6f06a6', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zweryfikujcie', N'624cf2fa-8f23-4ce1-8ca1-a23a7d6f06a6', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naprowadzałaś', N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niebaskwilowy', N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niewymamlaniu', N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'karbonylujmyż', N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ksenofobijnej', N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nadokienników', N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niebaskwilowy', N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozgrodzeniem', N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unaturalniały', N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zezwierzęcono', N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bezwapiennego', N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nadmieniajcie', N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nienafikaniem', N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieszanownemu', N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nietrząsające', N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podkopywałbyś', N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'proprioceptor', N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reklamóweczki', N'65d0c108-53e9-4780-93ac-e91203bb5869', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'antimetabolite', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'744dea72-c59a-4785-ab1b-8f627c6901bf', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'concommitantly', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'744dea72-c59a-4785-ab1b-8f627c6901bf', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'escalloniaceae', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'744dea72-c59a-4785-ab1b-8f627c6901bf', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'meritmongering', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'744dea72-c59a-4785-ab1b-8f627c6901bf', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'misdescriptive', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'744dea72-c59a-4785-ab1b-8f627c6901bf', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spirillotropic', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'744dea72-c59a-4785-ab1b-8f627c6901bf', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unannihilative', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'744dea72-c59a-4785-ab1b-8f627c6901bf', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'anthraquinonyl', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'compromisingly', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonsolvability', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'precurriculums', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'presuppression', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spirillotropic', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'underthroating', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spirillotropic', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unannihilative', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unstrangulable', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonsolvability', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'quadrauricular', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spirillotropic', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unannihilative', N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bastowanie', N'671a22c6-c1a7-4f63-90d5-1cd55422d5a5', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'farsiarzom', N'671a22c6-c1a7-4f63-90d5-1cd55422d5a5', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'klezmerski', N'671a22c6-c1a7-4f63-90d5-1cd55422d5a5', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naszywałem', N'671a22c6-c1a7-4f63-90d5-1cd55422d5a5', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'utylitarna', N'671a22c6-c1a7-4f63-90d5-1cd55422d5a5', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zrównywała', N'671a22c6-c1a7-4f63-90d5-1cd55422d5a5', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bindownico', N'671a22c6-c1a7-4f63-90d5-1cd55422d5a5', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'brzmiałbyś', N'671a22c6-c1a7-4f63-90d5-1cd55422d5a5', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'majtnięciu', N'671a22c6-c1a7-4f63-90d5-1cd55422d5a5', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naziębiłam', N'671a22c6-c1a7-4f63-90d5-1cd55422d5a5', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niecisnącą', N'671a22c6-c1a7-4f63-90d5-1cd55422d5a5', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przycioszę', N'671a22c6-c1a7-4f63-90d5-1cd55422d5a5', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zohydzenia', N'671a22c6-c1a7-4f63-90d5-1cd55422d5a5', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wymiotowałeś', N'6778dcd9-83e0-40d4-acbc-6ed6312e84bf', N'557216b4-e674-496d-8bb4-5a8f51d766bd', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zniechęciłeś', N'6778dcd9-83e0-40d4-acbc-6ed6312e84bf', N'557216b4-e674-496d-8bb4-5a8f51d766bd', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niekomesowym', N'6778dcd9-83e0-40d4-acbc-6ed6312e84bf', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wymiotowałeś', N'6778dcd9-83e0-40d4-acbc-6ed6312e84bf', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fizykalizm', N'684aa84a-488e-4893-b8e8-c738bf575502', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'irytujcież', N'684aa84a-488e-4893-b8e8-c738bf575502', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niecisnącą', N'684aa84a-488e-4893-b8e8-c738bf575502', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niedopałku', N'684aa84a-488e-4893-b8e8-c738bf575502', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podejrzysz', N'684aa84a-488e-4893-b8e8-c738bf575502', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pozużywało', N'684aa84a-488e-4893-b8e8-c738bf575502', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wilgotnawo', N'684aa84a-488e-4893-b8e8-c738bf575502', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wytrapiały', N'684aa84a-488e-4893-b8e8-c738bf575502', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'irytujcież', N'684aa84a-488e-4893-b8e8-c738bf575502', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'meteorycie', N'684aa84a-488e-4893-b8e8-c738bf575502', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odgarniano', N'684aa84a-488e-4893-b8e8-c738bf575502', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyśmignęli', N'684aa84a-488e-4893-b8e8-c738bf575502', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zrównywała', N'684aa84a-488e-4893-b8e8-c738bf575502', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:57.0410000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dwikoskich', N'684aa84a-488e-4893-b8e8-c738bf575502', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naszywałem', N'684aa84a-488e-4893-b8e8-c738bf575502', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ostygnęłaś', N'684aa84a-488e-4893-b8e8-c738bf575502', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pogujących', N'684aa84a-488e-4893-b8e8-c738bf575502', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ułatwiajże', N'684aa84a-488e-4893-b8e8-c738bf575502', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zgłaszanie', N'684aa84a-488e-4893-b8e8-c738bf575502', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'irytujcież', N'684aa84a-488e-4893-b8e8-c738bf575502', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'beetleheadedness', N'6ad61619-1ed6-432c-9242-f1294b25959b', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'foretellableness', N'6ad61619-1ed6-432c-9242-f1294b25959b', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonconscriptable', N'6ad61619-1ed6-432c-9242-f1294b25959b', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unsympathizingly', N'6ad61619-1ed6-432c-9242-f1294b25959b', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'beetleheadedness', N'6ad61619-1ed6-432c-9242-f1294b25959b', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'foretellableness', N'6ad61619-1ed6-432c-9242-f1294b25959b', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'imperceptibility', N'6ad61619-1ed6-432c-9242-f1294b25959b', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonconscriptable', N'6ad61619-1ed6-432c-9242-f1294b25959b', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'organizationally', N'6ad61619-1ed6-432c-9242-f1294b25959b', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'radiosensibility', N'6ad61619-1ed6-432c-9242-f1294b25959b', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unsympathizingly', N'6ad61619-1ed6-432c-9242-f1294b25959b', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'untautologically', N'6ad61619-1ed6-432c-9242-f1294b25959b', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'beetleheadedness', N'6ad61619-1ed6-432c-9242-f1294b25959b', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'intuitionalist', N'6b5adc20-b3ad-4b30-b377-e830b21d2837', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kleptomaniacal', N'6b5adc20-b3ad-4b30-b377-e830b21d2837', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overpersecuted', N'6b5adc20-b3ad-4b30-b377-e830b21d2837', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'meritmongering', N'6b5adc20-b3ad-4b30-b377-e830b21d2837', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonemotionally', N'6b5adc20-b3ad-4b30-b377-e830b21d2837', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonethicalness', N'6b5adc20-b3ad-4b30-b377-e830b21d2837', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pasteurisation', N'6b5adc20-b3ad-4b30-b377-e830b21d2837', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'perimetrically', N'6b5adc20-b3ad-4b30-b377-e830b21d2837', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'phenomenalized', N'6b5adc20-b3ad-4b30-b377-e830b21d2837', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'precurriculums', N'6b5adc20-b3ad-4b30-b377-e830b21d2837', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spirillotropic', N'6b5adc20-b3ad-4b30-b377-e830b21d2837', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'masticurous', N'6d0680e8-9d76-4bd8-b162-d6f59ed9361b', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ovatooblong', N'6d0680e8-9d76-4bd8-b162-d6f59ed9361b', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'biacetylene', N'6d0680e8-9d76-4bd8-b162-d6f59ed9361b', N'5d819a6f-e9e9-4560-9d08-eed15fdb8c50', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'disorganize', N'6d0680e8-9d76-4bd8-b162-d6f59ed9361b', N'5d819a6f-e9e9-4560-9d08-eed15fdb8c50', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonorthodox', N'6d0680e8-9d76-4bd8-b162-d6f59ed9361b', N'5d819a6f-e9e9-4560-9d08-eed15fdb8c50', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'beachmaster', N'6d0680e8-9d76-4bd8-b162-d6f59ed9361b', N'60b4e35f-4af8-4c39-8959-d263504c144c', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'biacetylene', N'6d0680e8-9d76-4bd8-b162-d6f59ed9361b', N'60b4e35f-4af8-4c39-8959-d263504c144c', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'commandress', N'6d0680e8-9d76-4bd8-b162-d6f59ed9361b', N'60b4e35f-4af8-4c39-8959-d263504c144c', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'expirations', N'6d0680e8-9d76-4bd8-b162-d6f59ed9361b', N'60b4e35f-4af8-4c39-8959-d263504c144c', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unmobilised', N'6d0680e8-9d76-4bd8-b162-d6f59ed9361b', N'60b4e35f-4af8-4c39-8959-d263504c144c', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unprospered', N'6d0680e8-9d76-4bd8-b162-d6f59ed9361b', N'60b4e35f-4af8-4c39-8959-d263504c144c', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'biacetylene', N'6d0680e8-9d76-4bd8-b162-d6f59ed9361b', N'613f9c48-1536-4a01-a97c-825f93bf11a4', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'heteroptics', N'6d0680e8-9d76-4bd8-b162-d6f59ed9361b', N'613f9c48-1536-4a01-a97c-825f93bf11a4', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reapologies', N'6d0680e8-9d76-4bd8-b162-d6f59ed9361b', N'613f9c48-1536-4a01-a97c-825f93bf11a4', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'begrudged', N'6d67ab92-ead9-433e-a2d5-0ab9f52e44bd', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'estuarial', N'6d67ab92-ead9-433e-a2d5-0ab9f52e44bd', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hackamore', N'6d67ab92-ead9-433e-a2d5-0ab9f52e44bd', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'inquirent', N'6d67ab92-ead9-433e-a2d5-0ab9f52e44bd', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'noncoring', N'6d67ab92-ead9-433e-a2d5-0ab9f52e44bd', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overraked', N'6d67ab92-ead9-433e-a2d5-0ab9f52e44bd', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cordately', N'6d67ab92-ead9-433e-a2d5-0ab9f52e44bd', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'posttests', N'6d67ab92-ead9-433e-a2d5-0ab9f52e44bd', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'estuarial', N'6d67ab92-ead9-433e-a2d5-0ab9f52e44bd', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'seamounts', N'6d67ab92-ead9-433e-a2d5-0ab9f52e44bd', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'akumulacyjni', N'71120ec8-777f-4027-8df8-b592c170b3d5', N'd961faf8-26a5-4785-8965-c043f64ac1f5', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niefekalnego', N'71120ec8-777f-4027-8df8-b592c170b3d5', N'd961faf8-26a5-4785-8965-c043f64ac1f5', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'popukującego', N'71120ec8-777f-4027-8df8-b592c170b3d5', N'd961faf8-26a5-4785-8965-c043f64ac1f5', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'porażającymi', N'71120ec8-777f-4027-8df8-b592c170b3d5', N'd961faf8-26a5-4785-8965-c043f64ac1f5', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prowadzające', N'71120ec8-777f-4027-8df8-b592c170b3d5', N'd961faf8-26a5-4785-8965-c043f64ac1f5', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przetasujesz', N'71120ec8-777f-4027-8df8-b592c170b3d5', N'd961faf8-26a5-4785-8965-c043f64ac1f5', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'roztłukujący', N'71120ec8-777f-4027-8df8-b592c170b3d5', N'd961faf8-26a5-4785-8965-c043f64ac1f5', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bilionowego', N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'93205c1d-0cde-42e8-bd37-ab5a09123c72', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kaleczyłoby', N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'93205c1d-0cde-42e8-bd37-ab5a09123c72', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nietoperzyk', N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'93205c1d-0cde-42e8-bd37-ab5a09123c72', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ornamentują', N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'93205c1d-0cde-42e8-bd37-ab5a09123c72', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'powybielano', N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'93205c1d-0cde-42e8-bd37-ab5a09123c72', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tabuizowane', N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'93205c1d-0cde-42e8-bd37-ab5a09123c72', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyręczonymi', N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'93205c1d-0cde-42e8-bd37-ab5a09123c72', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'marsowością', N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'972ebecb-b6e1-4d35-8ff6-ba321cca8419', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kaleczyłoby', N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'likwidusami', N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieodwikłań', N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezbawiona', N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'piastowałeś', N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'smyczkowymi', N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zadrzewiają', N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'marabuciemu', N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niewłochatą', N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'owocowałyby', N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podminowuje', N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pyłoodporna', N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'doholujcie', N'7278c38f-efc3-45fe-8598-527b92a117dd', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dotłoczoną', N'7278c38f-efc3-45fe-8598-527b92a117dd', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nadpisywań', N'7278c38f-efc3-45fe-8598-527b92a117dd', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naklepanie', N'7278c38f-efc3-45fe-8598-527b92a117dd', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'natrolicie', N'7278c38f-efc3-45fe-8598-527b92a117dd', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pożarskimi', N'7278c38f-efc3-45fe-8598-527b92a117dd', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wizjonerzy', N'7278c38f-efc3-45fe-8598-527b92a117dd', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kamerowany', N'7278c38f-efc3-45fe-8598-527b92a117dd', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naziębiłam', N'7278c38f-efc3-45fe-8598-527b92a117dd', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wizjonerzy', N'7278c38f-efc3-45fe-8598-527b92a117dd', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'haliczanin', N'7278c38f-efc3-45fe-8598-527b92a117dd', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'internistą', N'7278c38f-efc3-45fe-8598-527b92a117dd', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'otrzewnymi', N'7278c38f-efc3-45fe-8598-527b92a117dd', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'poobciągań', N'7278c38f-efc3-45fe-8598-527b92a117dd', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wizjonerzy', N'7278c38f-efc3-45fe-8598-527b92a117dd', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wytrapiały', N'7278c38f-efc3-45fe-8598-527b92a117dd', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zalęgnięty', N'7278c38f-efc3-45fe-8598-527b92a117dd', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'archipin', N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'beelines', N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'drinkery', N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hornwood', N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'laborage', N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'violence', N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'scourges', N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'charivan', N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'exsolved', N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mahuangs', N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sabaeism', N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'scourges', N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tessella', N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'vocality', N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'analgene', N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dimeters', N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'publicanism', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'thesmothete', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'aerifaction', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cubomedusan', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'galloflavin', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'masculinism', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'observative', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'thesmothete', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unprospered', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'caquetoires', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overliberal', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overtrimmed', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pedicellate', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'preclothing', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'proctoptoma', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'procyonidae', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unavertibly', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'creatorhood', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'masculinism', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'myogenicity', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonphenolic', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'phototypist', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pinkishness', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'propulsions', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'thesmothete', N'772314f5-a727-4be0-9e08-6f059d17f58e', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bastowanie', N'77ef02f7-0c93-4dba-a6a3-73ec5c9f81be', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niecisnącą', N'77ef02f7-0c93-4dba-a6a3-73ec5c9f81be', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pogujących', N'77ef02f7-0c93-4dba-a6a3-73ec5c9f81be', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pozużywało', N'77ef02f7-0c93-4dba-a6a3-73ec5c9f81be', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozprzęgaj', N'77ef02f7-0c93-4dba-a6a3-73ec5c9f81be', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'serowarami', N'77ef02f7-0c93-4dba-a6a3-73ec5c9f81be', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zamęczyłem', N'77ef02f7-0c93-4dba-a6a3-73ec5c9f81be', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'komutujesz', N'77ef02f7-0c93-4dba-a6a3-73ec5c9f81be', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pstrążkowi', N'77ef02f7-0c93-4dba-a6a3-73ec5c9f81be', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozprzęgaj', N'77ef02f7-0c93-4dba-a6a3-73ec5c9f81be', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'haliczanin', N'77ef02f7-0c93-4dba-a6a3-73ec5c9f81be', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mózgownicę', N'77ef02f7-0c93-4dba-a6a3-73ec5c9f81be', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'napiętniku', N'77ef02f7-0c93-4dba-a6a3-73ec5c9f81be', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'psoceniami', N'77ef02f7-0c93-4dba-a6a3-73ec5c9f81be', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyepilujmy', N'77ef02f7-0c93-4dba-a6a3-73ec5c9f81be', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wytropiono', N'77ef02f7-0c93-4dba-a6a3-73ec5c9f81be', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'besaile', N'78b6011b-6011-4cfd-ba85-5ef0468ea35f', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chazzan', N'78b6011b-6011-4cfd-ba85-5ef0468ea35f', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hattize', N'78b6011b-6011-4cfd-ba85-5ef0468ea35f', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'highway', N'78b6011b-6011-4cfd-ba85-5ef0468ea35f', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'murgavi', N'78b6011b-6011-4cfd-ba85-5ef0468ea35f', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'placers', N'78b6011b-6011-4cfd-ba85-5ef0468ea35f', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reflown', N'78b6011b-6011-4cfd-ba85-5ef0468ea35f', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wabbles', N'78b6011b-6011-4cfd-ba85-5ef0468ea35f', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kefirkom', N'7ab4921f-ceb0-4236-a3a2-266707b912fe', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'miksując', N'7ab4921f-ceb0-4236-a3a2-266707b912fe', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'napływaj', N'7ab4921f-ceb0-4236-a3a2-266707b912fe', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'usychają', N'7ab4921f-ceb0-4236-a3a2-266707b912fe', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wypławił', N'7ab4921f-ceb0-4236-a3a2-266707b912fe', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zasycaną', N'7ab4921f-ceb0-4236-a3a2-266707b912fe', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'darniaka', N'7ab8d589-258d-4228-a501-89c52b2b1b31', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nunataka', N'7ab8d589-258d-4228-a501-89c52b2b1b31', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prysłaby', N'7ab8d589-258d-4228-a501-89c52b2b1b31', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'guarachy', N'7ab8d589-258d-4228-a501-89c52b2b1b31', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hetmanów', N'7ab8d589-258d-4228-a501-89c52b2b1b31', N'd38c847c-33d1-4530-b014-ccad50e60866', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prysłaby', N'7ab8d589-258d-4228-a501-89c52b2b1b31', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'geodetyczni', N'7ca1dfad-6b4d-43b9-8b07-c4fc95d4b8dc', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nietoperzyk', N'7ca1dfad-6b4d-43b9-8b07-c4fc95d4b8dc', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dysonansowy', N'7ca1dfad-6b4d-43b9-8b07-c4fc95d4b8dc', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'geodetyczni', N'7ca1dfad-6b4d-43b9-8b07-c4fc95d4b8dc', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niedozujące', N'7ca1dfad-6b4d-43b9-8b07-c4fc95d4b8dc', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niemiganymi', N'7ca1dfad-6b4d-43b9-8b07-c4fc95d4b8dc', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'policzalnym', N'7ca1dfad-6b4d-43b9-8b07-c4fc95d4b8dc', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'potłumiałeś', N'7ca1dfad-6b4d-43b9-8b07-c4fc95d4b8dc', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'psikniętymi', N'7ca1dfad-6b4d-43b9-8b07-c4fc95d4b8dc', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spełniałbyś', N'7ca1dfad-6b4d-43b9-8b07-c4fc95d4b8dc', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'geodetyczni', N'7ca1dfad-6b4d-43b9-8b07-c4fc95d4b8dc', N'2041dad2-d4f8-4370-ac7b-d3f33eaf7ba3', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'geodetyczni', N'7ca1dfad-6b4d-43b9-8b07-c4fc95d4b8dc', N'256b1b1e-aae2-47b1-934b-c442a065a080', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niedojadani', N'7ca1dfad-6b4d-43b9-8b07-c4fc95d4b8dc', N'256b1b1e-aae2-47b1-934b-c442a065a080', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zesmutniałą', N'7ca1dfad-6b4d-43b9-8b07-c4fc95d4b8dc', N'256b1b1e-aae2-47b1-934b-c442a065a080', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyczerpywali', N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ekstyrpująca', N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'horteksowską', N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezakuleniu', N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podgrzałabyś', N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przepasanych', N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zakrywajcież', N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zasmagaliśmy', N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'aureomycynom', N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'budowniczego', N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'doginającego', N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ekstyrpująca', N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niekataralne', N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'szynkareczce', N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ekstyrpująca', N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kłamałybyśmy', N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieopisywane', N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'okleiłybyśmy', N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wietrznikach', N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'modłom', N'7ea1ecea-34ab-47a3-8810-0db9d27136e3', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nosiło', N'7ea1ecea-34ab-47a3-8810-0db9d27136e3', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'obstoi', N'7ea1ecea-34ab-47a3-8810-0db9d27136e3', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rwaczy', N'7ea1ecea-34ab-47a3-8810-0db9d27136e3', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wizuję', N'7ea1ecea-34ab-47a3-8810-0db9d27136e3', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dechy', N'7f038d23-d35d-4b53-899f-86bb983d85f2', N'0c23f819-2c46-43de-ac47-1d6be2242339', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dechy', N'7f038d23-d35d-4b53-899f-86bb983d85f2', N'0cb10800-2fd6-4664-b849-973903be8021', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hebdu', N'7f038d23-d35d-4b53-899f-86bb983d85f2', N'0cb10800-2fd6-4664-b849-973903be8021', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kupra', N'7f038d23-d35d-4b53-899f-86bb983d85f2', N'0cb10800-2fd6-4664-b849-973903be8021', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pojeb', N'7f038d23-d35d-4b53-899f-86bb983d85f2', N'0cb10800-2fd6-4664-b849-973903be8021', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rocku', N'7f038d23-d35d-4b53-899f-86bb983d85f2', N'0cb10800-2fd6-4664-b849-973903be8021', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sorus', N'7f038d23-d35d-4b53-899f-86bb983d85f2', N'0cb10800-2fd6-4664-b849-973903be8021', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hebdu', N'7f038d23-d35d-4b53-899f-86bb983d85f2', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kupra', N'7f038d23-d35d-4b53-899f-86bb983d85f2', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pojeb', N'7f038d23-d35d-4b53-899f-86bb983d85f2', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rocku', N'7f038d23-d35d-4b53-899f-86bb983d85f2', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sorus', N'7f038d23-d35d-4b53-899f-86bb983d85f2', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tymfy', N'7f038d23-d35d-4b53-899f-86bb983d85f2', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0420000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'centrodesmose', N'7f35b964-351f-40f8-ad1b-ea747e2a9aa7', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cruroinguinal', N'7f35b964-351f-40f8-ad1b-ea747e2a9aa7', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'metallography', N'7f35b964-351f-40f8-ad1b-ea747e2a9aa7', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'palatoglossal', N'7f35b964-351f-40f8-ad1b-ea747e2a9aa7', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'phlebenterism', N'7f35b964-351f-40f8-ad1b-ea747e2a9aa7', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pneumatoscope', N'7f35b964-351f-40f8-ad1b-ea747e2a9aa7', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unreproaching', N'7f35b964-351f-40f8-ad1b-ea747e2a9aa7', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'antilibration', N'7f35b964-351f-40f8-ad1b-ea747e2a9aa7', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cardiorrheuma', N'7f35b964-351f-40f8-ad1b-ea747e2a9aa7', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'palatoglossal', N'7f35b964-351f-40f8-ad1b-ea747e2a9aa7', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'slavification', N'7f35b964-351f-40f8-ad1b-ea747e2a9aa7', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'transliterate', N'82336469-7b50-42cb-af50-5dff03a25f32', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'antilibration', N'82336469-7b50-42cb-af50-5dff03a25f32', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'demonolatrous', N'82336469-7b50-42cb-af50-5dff03a25f32', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pneumatoscope', N'82336469-7b50-42cb-af50-5dff03a25f32', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'supraspinatus', N'82336469-7b50-42cb-af50-5dff03a25f32', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'transliterate', N'82336469-7b50-42cb-af50-5dff03a25f32', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'transliterate', N'82336469-7b50-42cb-af50-5dff03a25f32', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'awansowałaś', N'829c0b33-ca42-4f60-b9f9-b61eacf7b6ef', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ornamentują', N'829c0b33-ca42-4f60-b9f9-b61eacf7b6ef', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wykwateruje', N'829c0b33-ca42-4f60-b9f9-b61eacf7b6ef', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'autolizowanie', N'83e4c6b6-1cf7-4829-b83f-c3869fb99d57', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naprowadzałaś', N'83e4c6b6-1cf7-4829-b83f-c3869fb99d57', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niebydlęcenie', N'83e4c6b6-1cf7-4829-b83f-c3869fb99d57', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieobrównywań', N'83e4c6b6-1cf7-4829-b83f-c3869fb99d57', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niewybłaganym', N'83e4c6b6-1cf7-4829-b83f-c3869fb99d57', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pietruszkowym', N'83e4c6b6-1cf7-4829-b83f-c3869fb99d57', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ponagrywaliby', N'83e4c6b6-1cf7-4829-b83f-c3869fb99d57', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prawoflankowi', N'83e4c6b6-1cf7-4829-b83f-c3869fb99d57', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hiperbolizmów', N'83e4c6b6-1cf7-4829-b83f-c3869fb99d57', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niedoprawianą', N'83e4c6b6-1cf7-4829-b83f-c3869fb99d57', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'enkawudystami', N'83e4c6b6-1cf7-4829-b83f-c3869fb99d57', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'makrourzędowi', N'83e4c6b6-1cf7-4829-b83f-c3869fb99d57', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieolinowanej', N'83e4c6b6-1cf7-4829-b83f-c3869fb99d57', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieafirmatywnie', N'88730b67-fcda-4750-a14d-56649250b33b', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieenerdowskich', N'88730b67-fcda-4750-a14d-56649250b33b', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niewyksięgowani', N'88730b67-fcda-4750-a14d-56649250b33b', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pokalibrowaniom', N'88730b67-fcda-4750-a14d-56649250b33b', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'potencjonalnych', N'88730b67-fcda-4750-a14d-56649250b33b', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wszyściuteńkiej', N'88730b67-fcda-4750-a14d-56649250b33b', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'phaenanthery', N'895c6f39-257f-4776-a8d5-37fe79d74648', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'photostating', N'895c6f39-257f-4776-a8d5-37fe79d74648', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'beachmaster', N'89b92e6e-7b25-4acf-83de-0d99a1e3be6c', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'capitalists', N'89b92e6e-7b25-4acf-83de-0d99a1e3be6c', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pinkishness', N'89b92e6e-7b25-4acf-83de-0d99a1e3be6c', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reintuition', N'89b92e6e-7b25-4acf-83de-0d99a1e3be6c', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unmotioning', N'89b92e6e-7b25-4acf-83de-0d99a1e3be6c', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'antiatheism', N'89b92e6e-7b25-4acf-83de-0d99a1e3be6c', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'beachmaster', N'89b92e6e-7b25-4acf-83de-0d99a1e3be6c', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cogrediency', N'89b92e6e-7b25-4acf-83de-0d99a1e3be6c', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'observative', N'89b92e6e-7b25-4acf-83de-0d99a1e3be6c', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unfraternal', N'89b92e6e-7b25-4acf-83de-0d99a1e3be6c', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'consistence', N'89e0061a-0070-4e35-a55c-7e4d132e7b45', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'monocoelian', N'89e0061a-0070-4e35-a55c-7e4d132e7b45', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rewarehouse', N'89e0061a-0070-4e35-a55c-7e4d132e7b45', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'traducement', N'89e0061a-0070-4e35-a55c-7e4d132e7b45', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'krzepnięcie', N'8b5620b6-afed-42f1-b7d9-7c26f33c78b1', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'roztrącałam', N'8b5620b6-afed-42f1-b7d9-7c26f33c78b1', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spłaszczało', N'8b5620b6-afed-42f1-b7d9-7c26f33c78b1', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'teokrazjach', N'8b5620b6-afed-42f1-b7d9-7c26f33c78b1', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wnętrzników', N'8b5620b6-afed-42f1-b7d9-7c26f33c78b1', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'roztrącałam', N'8b5620b6-afed-42f1-b7d9-7c26f33c78b1', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trudnopalny', N'8b5620b6-afed-42f1-b7d9-7c26f33c78b1', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaprzestaję', N'8b5620b6-afed-42f1-b7d9-7c26f33c78b1', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zatracaniom', N'8b5620b6-afed-42f1-b7d9-7c26f33c78b1', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'deskryptywnemu', N'8bbf019b-c6b6-463d-a59f-6280533d54ac', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niemagnetytowi', N'8bbf019b-c6b6-463d-a59f-6280533d54ac', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'subiektywistka', N'8bbf019b-c6b6-463d-a59f-6280533d54ac', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niewśpiewywane', N'8bbf019b-c6b6-463d-a59f-6280533d54ac', N'13b76c36-b317-4541-8f77-f66ffdc38fbb', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'eksplorowałaby', N'8bbf019b-c6b6-463d-a59f-6280533d54ac', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'krótkobiegacza', N'8bbf019b-c6b6-463d-a59f-6280533d54ac', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podmarszczyłem', N'8bbf019b-c6b6-463d-a59f-6280533d54ac', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'postdatującego', N'8bbf019b-c6b6-463d-a59f-6280533d54ac', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'technostresowi', N'8bbf019b-c6b6-463d-a59f-6280533d54ac', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wykolegowanych', N'8bbf019b-c6b6-463d-a59f-6280533d54ac', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'alveolitis', N'8bc65541-72d4-4593-91d2-c2eba66482c7', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dimensible', N'8bc65541-72d4-4593-91d2-c2eba66482c7', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'semiacidic', N'8bc65541-72d4-4593-91d2-c2eba66482c7', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unexhorted', N'8bc65541-72d4-4593-91d2-c2eba66482c7', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'villainist', N'8bc65541-72d4-4593-91d2-c2eba66482c7', N'b08aafb8-1343-467c-aa38-7f2529d96f4e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'incendiarist', N'8d64b1a7-fb69-4dea-af84-8828c55d4be4', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'philosophism', N'8d64b1a7-fb69-4dea-af84-8828c55d4be4', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'stereotypies', N'8d64b1a7-fb69-4dea-af84-8828c55d4be4', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uncorrigible', N'8d64b1a7-fb69-4dea-af84-8828c55d4be4', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unmeridional', N'8d64b1a7-fb69-4dea-af84-8828c55d4be4', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'adenosarcoma', N'8d64b1a7-fb69-4dea-af84-8828c55d4be4', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'implementors', N'8d64b1a7-fb69-4dea-af84-8828c55d4be4', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'laticiferous', N'8d64b1a7-fb69-4dea-af84-8828c55d4be4', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unmeridional', N'8d64b1a7-fb69-4dea-af84-8828c55d4be4', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'theophylline', N'8d64b1a7-fb69-4dea-af84-8828c55d4be4', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unanalogical', N'8d64b1a7-fb69-4dea-af84-8828c55d4be4', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unmeridional', N'8d64b1a7-fb69-4dea-af84-8828c55d4be4', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unpermeating', N'8d64b1a7-fb69-4dea-af84-8828c55d4be4', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'victorianize', N'8d64b1a7-fb69-4dea-af84-8828c55d4be4', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gofrowała', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nacięłoby', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'orszańska', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trynknęło', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyłamujmy', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyżywiani', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'futraminy', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gofrowała', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mantykorą', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mięsistym', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odwiejemy', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rzeźniczą', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ulicówkom', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'znaglajmy', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'futraminy', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'557216b4-e674-496d-8bb4-5a8f51d766bd', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'szafujące', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'557216b4-e674-496d-8bb4-5a8f51d766bd', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wełnicami', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'557216b4-e674-496d-8bb4-5a8f51d766bd', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wywróżyły', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'557216b4-e674-496d-8bb4-5a8f51d766bd', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zeswatała', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'557216b4-e674-496d-8bb4-5a8f51d766bd', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'futraminy', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kalamicie', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mięsistym', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nacięłoby', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niekarscy', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rockmanek', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sierpówek', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wykurwimy', N'8dc0e90c-84dd-4064-bce6-84731818510c', N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieenerdowskich', N'9016d376-af54-4b9f-b551-3e71b7892505', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieodbębnieniom', N'9016d376-af54-4b9f-b551-3e71b7892505', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieoklaskaniami', N'9016d376-af54-4b9f-b551-3e71b7892505', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepabianickimi', N'9016d376-af54-4b9f-b551-3e71b7892505', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezapożyczanej', N'9016d376-af54-4b9f-b551-3e71b7892505', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezgranatowień', N'9016d376-af54-4b9f-b551-3e71b7892505', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'terkolilibyście', N'9016d376-af54-4b9f-b551-3e71b7892505', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bromobenzenów', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nabuntowałbyś', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nietobruckiej', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieturniowymi', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezaciśnięta', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ponagrywaliby', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trójtraktowej', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyprodukowuję', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hiperbolizmów', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ksenofobijnej', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieszawianach', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezbudowanie', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pietruszkowym', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zweryfikujcie', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pietruszkowym', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'domniemywaniu', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieobrównywań', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nierozryczany', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'orędownictwie', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pietruszkowym', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyrębywałyśmy', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zezwierzęcono', N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'commandress', N'91892c7a-c442-441f-ba6f-7368f7b23040', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'consistence', N'91892c7a-c442-441f-ba6f-7368f7b23040', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'grieshuckle', N'91892c7a-c442-441f-ba6f-7368f7b23040', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'heteroptics', N'91892c7a-c442-441f-ba6f-7368f7b23040', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'transducers', N'91892c7a-c442-441f-ba6f-7368f7b23040', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'counterpetition', N'93e766ff-f02b-48e6-b128-8c1b55d9c42f', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hydrocinchonine', N'93e766ff-f02b-48e6-b128-8c1b55d9c42f', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reconcilability', N'93e766ff-f02b-48e6-b128-8c1b55d9c42f', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unmetamorphosed', N'93e766ff-f02b-48e6-b128-8c1b55d9c42f', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'counterpetition', N'93e766ff-f02b-48e6-b128-8c1b55d9c42f', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hydrocinchonine', N'93e766ff-f02b-48e6-b128-8c1b55d9c42f', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'imperishability', N'93e766ff-f02b-48e6-b128-8c1b55d9c42f', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'laborage', N'93f1f7c3-c207-4651-aeb1-e65d55342509', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lazarets', N'93f1f7c3-c207-4651-aeb1-e65d55342509', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'stoneman', N'93f1f7c3-c207-4651-aeb1-e65d55342509', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'toadless', N'93f1f7c3-c207-4651-aeb1-e65d55342509', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'girlsom', N'94f1d08e-d128-4262-a86f-77a3937d226f', N'2041dad2-d4f8-4370-ac7b-d3f33eaf7ba3', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'klangor', N'94f1d08e-d128-4262-a86f-77a3937d226f', N'2041dad2-d4f8-4370-ac7b-d3f33eaf7ba3', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zakasze', N'94f1d08e-d128-4262-a86f-77a3937d226f', N'2041dad2-d4f8-4370-ac7b-d3f33eaf7ba3', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zasyceń', N'94f1d08e-d128-4262-a86f-77a3937d226f', N'2041dad2-d4f8-4370-ac7b-d3f33eaf7ba3', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zgadnąć', N'94f1d08e-d128-4262-a86f-77a3937d226f', N'2041dad2-d4f8-4370-ac7b-d3f33eaf7ba3', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'powiłaś', N'94f1d08e-d128-4262-a86f-77a3937d226f', N'256b1b1e-aae2-47b1-934b-c442a065a080', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'różnymi', N'94f1d08e-d128-4262-a86f-77a3937d226f', N'256b1b1e-aae2-47b1-934b-c442a065a080', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'konidialnej', N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tabuizowane', N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uskarżyłbym', N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zapleśnieję', N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bilionowego', N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dogęszczono', N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'łyżwiarskim', N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niefrotowym', N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ornamentują', N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'szwagierską', N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dostrajałem', N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'owocowałyby', N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pokulaniach', N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'smyczkowymi', N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zapleśnieję', N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niemroczoną', N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'smyczkowymi', N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'urywającemu', N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zapleśnieję', N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'burglar', N'96aca781-ef20-47ed-afc4-403e74a21cf0', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'capreol', N'96aca781-ef20-47ed-afc4-403e74a21cf0', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'coquito', N'96aca781-ef20-47ed-afc4-403e74a21cf0', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'crengle', N'96aca781-ef20-47ed-afc4-403e74a21cf0', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cystose', N'96aca781-ef20-47ed-afc4-403e74a21cf0', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'luxuria', N'96aca781-ef20-47ed-afc4-403e74a21cf0', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'myrcene', N'96aca781-ef20-47ed-afc4-403e74a21cf0', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nektons', N'96aca781-ef20-47ed-afc4-403e74a21cf0', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reflown', N'96aca781-ef20-47ed-afc4-403e74a21cf0', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dimensible', N'97c097b4-1248-4b08-ba61-c5a38ecf4256', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fetography', N'97c097b4-1248-4b08-ba61-c5a38ecf4256', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unsorrowed', N'97c097b4-1248-4b08-ba61-c5a38ecf4256', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'vociferize', N'97c097b4-1248-4b08-ba61-c5a38ecf4256', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'aquaplaner', N'97c097b4-1248-4b08-ba61-c5a38ecf4256', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dimensible', N'97c097b4-1248-4b08-ba61-c5a38ecf4256', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'encrusting', N'97c097b4-1248-4b08-ba61-c5a38ecf4256', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fricandoes', N'97c097b4-1248-4b08-ba61-c5a38ecf4256', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prescience', N'97c097b4-1248-4b08-ba61-c5a38ecf4256', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chirruping', N'97c097b4-1248-4b08-ba61-c5a38ecf4256', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dimensible', N'97c097b4-1248-4b08-ba61-c5a38ecf4256', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fricandoes', N'97c097b4-1248-4b08-ba61-c5a38ecf4256', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'negational', N'97c097b4-1248-4b08-ba61-c5a38ecf4256', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'proposable', N'97c097b4-1248-4b08-ba61-c5a38ecf4256', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'scyphiform', N'97c097b4-1248-4b08-ba61-c5a38ecf4256', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sidepieces', N'97c097b4-1248-4b08-ba61-c5a38ecf4256', N'ad366928-a9a8-46a4-83df-35bf48e1fb22', CAST(N'2022-02-04T23:23:57.0430000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chodami', N'9881d8c1-aa05-4dbd-8661-1c9852c71966', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'górnicą', N'9881d8c1-aa05-4dbd-8661-1c9852c71966', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'magodie', N'9881d8c1-aa05-4dbd-8661-1c9852c71966', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nagabną', N'9881d8c1-aa05-4dbd-8661-1c9852c71966', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'natłuką', N'9881d8c1-aa05-4dbd-8661-1c9852c71966', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trącisz', N'9881d8c1-aa05-4dbd-8661-1c9852c71966', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'żbiczym', N'9881d8c1-aa05-4dbd-8661-1c9852c71966', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'znawozi', N'9881d8c1-aa05-4dbd-8661-1c9852c71966', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chodami', N'9881d8c1-aa05-4dbd-8661-1c9852c71966', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'girlsom', N'9881d8c1-aa05-4dbd-8661-1c9852c71966', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'łódkowe', N'9881d8c1-aa05-4dbd-8661-1c9852c71966', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'żachnął', N'9881d8c1-aa05-4dbd-8661-1c9852c71966', N'81774506-a3cc-4fa2-98bc-8e2452eaca04', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'antiatheism', N'9a3d1f42-44a5-4674-9228-ebc6af6c09dd', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'botryllidae', N'9a3d1f42-44a5-4674-9228-ebc6af6c09dd', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'grieshuckle', N'9a3d1f42-44a5-4674-9228-ebc6af6c09dd', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'marmoreally', N'9a3d1f42-44a5-4674-9228-ebc6af6c09dd', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overliberal', N'9a3d1f42-44a5-4674-9228-ebc6af6c09dd', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'planetogeny', N'9a3d1f42-44a5-4674-9228-ebc6af6c09dd', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reapologies', N'9a3d1f42-44a5-4674-9228-ebc6af6c09dd', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'jaśniepanie', N'9d2566e7-4c35-4e92-afe4-b291bedfb386', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podminowuje', N'9d2566e7-4c35-4e92-afe4-b291bedfb386', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'połaskotano', N'9d2566e7-4c35-4e92-afe4-b291bedfb386', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'psikniętymi', N'9d2566e7-4c35-4e92-afe4-b291bedfb386', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wpakowanych', N'9d2566e7-4c35-4e92-afe4-b291bedfb386', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zapleśnieję', N'9d2566e7-4c35-4e92-afe4-b291bedfb386', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'karmuazowałyśmy', N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'najjurniejszymi', N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niedetencyjnych', N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepabianickimi', N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niewzbijającymi', N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wersyfikatorscy', N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'intergranularna', N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niedetencyjnych', N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pośniedziałyśmy', N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przekablowaniom', N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tranzystorowymi', N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mikrofonującego', N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieaukcjonowani', N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niedetencyjnych', N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niewyksięgowani', N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wszyściuteńkiej', N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wystrugalibyśmy', N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kbar', N'a0311cdf-e8c0-4449-8f07-e6bdb41bf393', N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'scow', N'a0311cdf-e8c0-4449-8f07-e6bdb41bf393', N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wush', N'a0311cdf-e8c0-4449-8f07-e6bdb41bf393', N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cace', N'a0311cdf-e8c0-4449-8f07-e6bdb41bf393', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'scyt', N'a0311cdf-e8c0-4449-8f07-e6bdb41bf393', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bons', N'a0311cdf-e8c0-4449-8f07-e6bdb41bf393', N'4130105a-24e1-41b7-917f-671188d8a4cd', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dict', N'a0311cdf-e8c0-4449-8f07-e6bdb41bf393', N'4130105a-24e1-41b7-917f-671188d8a4cd', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'erer', N'a0311cdf-e8c0-4449-8f07-e6bdb41bf393', N'4130105a-24e1-41b7-917f-671188d8a4cd', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nold', N'a0311cdf-e8c0-4449-8f07-e6bdb41bf393', N'4130105a-24e1-41b7-917f-671188d8a4cd', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'oats', N'a0311cdf-e8c0-4449-8f07-e6bdb41bf393', N'4130105a-24e1-41b7-917f-671188d8a4cd', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'scyt', N'a0311cdf-e8c0-4449-8f07-e6bdb41bf393', N'4130105a-24e1-41b7-917f-671188d8a4cd', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'toho', N'a0311cdf-e8c0-4449-8f07-e6bdb41bf393', N'4130105a-24e1-41b7-917f-671188d8a4cd', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'napu', N'a0311cdf-e8c0-4449-8f07-e6bdb41bf393', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ozłacaniami', N'a90422c1-dd0d-40a4-99c9-b3d29cc34444', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieodwikłań', N'a93f2194-99bf-4aa0-885a-9333dae80915', N'60b4e35f-4af8-4c39-8959-d263504c144c', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'policzalnym', N'a93f2194-99bf-4aa0-885a-9333dae80915', N'60b4e35f-4af8-4c39-8959-d263504c144c', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'potłumiałeś', N'a93f2194-99bf-4aa0-885a-9333dae80915', N'60b4e35f-4af8-4c39-8959-d263504c144c', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zabagniajże', N'a93f2194-99bf-4aa0-885a-9333dae80915', N'60b4e35f-4af8-4c39-8959-d263504c144c', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaagitowałyby', N'ad0c87a7-b1a6-487c-b9e5-ce74dad0f9a9', N'da15904a-934a-4531-95d2-b7369ecd4090', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dekapilatorze', N'ad0c87a7-b1a6-487c-b9e5-ce74dad0f9a9', N'da90e20f-f35f-4fb5-a6ac-1e20120f4860', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nadmieniajcie', N'ad0c87a7-b1a6-487c-b9e5-ce74dad0f9a9', N'da90e20f-f35f-4fb5-a6ac-1e20120f4860', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naopierdalało', N'ad0c87a7-b1a6-487c-b9e5-ce74dad0f9a9', N'da90e20f-f35f-4fb5-a6ac-1e20120f4860', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'natapirowałaś', N'ad0c87a7-b1a6-487c-b9e5-ce74dad0f9a9', N'da90e20f-f35f-4fb5-a6ac-1e20120f4860', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niefluorowani', N'ad0c87a7-b1a6-487c-b9e5-ce74dad0f9a9', N'da90e20f-f35f-4fb5-a6ac-1e20120f4860', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pietruszkowym', N'ad0c87a7-b1a6-487c-b9e5-ce74dad0f9a9', N'da90e20f-f35f-4fb5-a6ac-1e20120f4860', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podprowadzony', N'ad0c87a7-b1a6-487c-b9e5-ce74dad0f9a9', N'da90e20f-f35f-4fb5-a6ac-1e20120f4860', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'disorganize', N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'galloflavin', N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'propulsions', N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unmotioning', N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unreverence', N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'venturously', N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd61ecea9-186a-430b-9799-2405d7284f8b', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'heteroptics', N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd632112f-3364-4d51-b6f5-ef06929969f0', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reapologies', N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd632112f-3364-4d51-b6f5-ef06929969f0', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'conglobated', N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd68eb68d-2ba1-473d-842e-efa9737cb4fa', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'galloflavin', N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd68eb68d-2ba1-473d-842e-efa9737cb4fa', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'radiomedial', N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd68eb68d-2ba1-473d-842e-efa9737cb4fa', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reapologies', N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd68eb68d-2ba1-473d-842e-efa9737cb4fa', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chaetetidae', N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd961faf8-26a5-4785-8965-c043f64ac1f5', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'concentrate', N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd961faf8-26a5-4785-8965-c043f64ac1f5', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'holostomate', N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd961faf8-26a5-4785-8965-c043f64ac1f5', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'protocolize', N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd961faf8-26a5-4785-8965-c043f64ac1f5', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trailerload', N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd961faf8-26a5-4785-8965-c043f64ac1f5', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unmobilised', N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'd961faf8-26a5-4785-8965-c043f64ac1f5', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kirundi', N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'paiwari', N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bikeway', N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'capreol', N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'illbred', N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mascons', N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rooster', N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sassily', N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bikeway', N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lapeler', N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'assails', N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bikeway', N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'khalifs', N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kitabis', N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ootwith', N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'patarin', N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sparsim', N'afa38637-9fed-498d-877d-0aecfd4e710d', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'besplatter', N'b248b6cf-d820-4081-881c-92b4e98e2e2f', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chaiseless', N'b248b6cf-d820-4081-881c-92b4e98e2e2f', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'durational', N'b248b6cf-d820-4081-881c-92b4e98e2e2f', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'plagiaries', N'b248b6cf-d820-4081-881c-92b4e98e2e2f', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'substernal', N'b248b6cf-d820-4081-881c-92b4e98e2e2f', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tricennial', N'b248b6cf-d820-4081-881c-92b4e98e2e2f', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'villainist', N'b248b6cf-d820-4081-881c-92b4e98e2e2f', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bindownico', N'b5384ef5-478a-408f-b659-2c5f979259d8', N'4130105a-24e1-41b7-917f-671188d8a4cd', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pstrążkowi', N'b5384ef5-478a-408f-b659-2c5f979259d8', N'4130105a-24e1-41b7-917f-671188d8a4cd', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'exosmotic', N'b65c8e89-ef00-49fe-b758-957c1202e6b7', N'd961faf8-26a5-4785-8965-c043f64ac1f5', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fistnotes', N'b65c8e89-ef00-49fe-b758-957c1202e6b7', N'd961faf8-26a5-4785-8965-c043f64ac1f5', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'clubhouse', N'b65c8e89-ef00-49fe-b758-957c1202e6b7', N'd9c6aa61-a901-4273-8c9b-1db89a9a3352', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dragonism', N'b65c8e89-ef00-49fe-b758-957c1202e6b7', N'd9c6aa61-a901-4273-8c9b-1db89a9a3352', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'narrowing', N'b65c8e89-ef00-49fe-b758-957c1202e6b7', N'd9c6aa61-a901-4273-8c9b-1db89a9a3352', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'orbicular', N'b65c8e89-ef00-49fe-b758-957c1202e6b7', N'd9c6aa61-a901-4273-8c9b-1db89a9a3352', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'quinquino', N'b65c8e89-ef00-49fe-b758-957c1202e6b7', N'd9c6aa61-a901-4273-8c9b-1db89a9a3352', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'railroads', N'b65c8e89-ef00-49fe-b758-957c1202e6b7', N'd9c6aa61-a901-4273-8c9b-1db89a9a3352', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sclerosis', N'b65c8e89-ef00-49fe-b758-957c1202e6b7', N'd9c6aa61-a901-4273-8c9b-1db89a9a3352', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'apokatastazę', N'b8359032-c382-4363-ab64-9d283a4ba93f', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'upadlibyście', N'b8359032-c382-4363-ab64-9d283a4ba93f', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'apokatastazę', N'b8359032-c382-4363-ab64-9d283a4ba93f', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieobsrywany', N'b8359032-c382-4363-ab64-9d283a4ba93f', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepożalenia', N'b8359032-c382-4363-ab64-9d283a4ba93f', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieprzesrany', N'b8359032-c382-4363-ab64-9d283a4ba93f', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podgrzałabyś', N'b8359032-c382-4363-ab64-9d283a4ba93f', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'poprzeginali', N'b8359032-c382-4363-ab64-9d283a4ba93f', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wpierniczmyż', N'b8359032-c382-4363-ab64-9d283a4ba93f', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kostkowatemu', N'b8359032-c382-4363-ab64-9d283a4ba93f', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'diademy', N'b90a1103-2094-44cc-857c-355ae0d84e1c', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hurtowi', N'b90a1103-2094-44cc-857c-355ae0d84e1c', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'munster', N'b90a1103-2094-44cc-857c-355ae0d84e1c', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nagabną', N'b90a1103-2094-44cc-857c-355ae0d84e1c', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odrobek', N'b90a1103-2094-44cc-857c-355ae0d84e1c', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trącisz', N'b90a1103-2094-44cc-857c-355ae0d84e1c', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'załammy', N'b90a1103-2094-44cc-857c-355ae0d84e1c', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'girlsom', N'b90a1103-2094-44cc-857c-355ae0d84e1c', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odrobek', N'b90a1103-2094-44cc-857c-355ae0d84e1c', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'żarnowe', N'b90a1103-2094-44cc-857c-355ae0d84e1c', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zasyceń', N'b90a1103-2094-44cc-857c-355ae0d84e1c', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zgadnąć', N'b90a1103-2094-44cc-857c-355ae0d84e1c', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odrobek', N'b90a1103-2094-44cc-857c-355ae0d84e1c', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'horteksowską', N'b941e2b0-e368-40fb-b8e0-869181245d28', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kazamatowemu', N'b941e2b0-e368-40fb-b8e0-869181245d28', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niegrodzkimi', N'b941e2b0-e368-40fb-b8e0-869181245d28', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sygilografia', N'b941e2b0-e368-40fb-b8e0-869181245d28', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'udźwięcznisz', N'b941e2b0-e368-40fb-b8e0-869181245d28', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyszkalałyby', N'b941e2b0-e368-40fb-b8e0-869181245d28', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'antiselene', N'b97ac4ac-abe6-4b59-90e7-c181ee5d9b55', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fetography', N'b97ac4ac-abe6-4b59-90e7-c181ee5d9b55', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'multicurie', N'b97ac4ac-abe6-4b59-90e7-c181ee5d9b55', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'plagiaries', N'b97ac4ac-abe6-4b59-90e7-c181ee5d9b55', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'presbyopia', N'b97ac4ac-abe6-4b59-90e7-c181ee5d9b55', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'scyphiform', N'b97ac4ac-abe6-4b59-90e7-c181ee5d9b55', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unsubtlety', N'b97ac4ac-abe6-4b59-90e7-c181ee5d9b55', N'bc313b26-188f-4d90-acc1-473e4a11a8ab', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'alabastron', N'b97ac4ac-abe6-4b59-90e7-c181ee5d9b55', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'apophysate', N'b97ac4ac-abe6-4b59-90e7-c181ee5d9b55', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'decigramme', N'b97ac4ac-abe6-4b59-90e7-c181ee5d9b55', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pateriform', N'b97ac4ac-abe6-4b59-90e7-c181ee5d9b55', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'plagiaries', N'b97ac4ac-abe6-4b59-90e7-c181ee5d9b55', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'questioned', N'b97ac4ac-abe6-4b59-90e7-c181ee5d9b55', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unrippling', N'b97ac4ac-abe6-4b59-90e7-c181ee5d9b55', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'adnotacjo', N'bafd58a0-208d-44b3-822f-474fd2ee5951', N'fc91f5c7-229f-498e-b2dd-ad2f2d97621d', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'amebowaty', N'bafd58a0-208d-44b3-822f-474fd2ee5951', N'fc91f5c7-229f-498e-b2dd-ad2f2d97621d', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chaparral', N'bafd58a0-208d-44b3-822f-474fd2ee5951', N'fc91f5c7-229f-498e-b2dd-ad2f2d97621d', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'orszańska', N'bafd58a0-208d-44b3-822f-474fd2ee5951', N'fc91f5c7-229f-498e-b2dd-ad2f2d97621d', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'posolicie', N'bafd58a0-208d-44b3-822f-474fd2ee5951', N'fc91f5c7-229f-498e-b2dd-ad2f2d97621d', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rockmanek', N'bafd58a0-208d-44b3-822f-474fd2ee5951', N'fc91f5c7-229f-498e-b2dd-ad2f2d97621d', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rzeźniczą', N'bafd58a0-208d-44b3-822f-474fd2ee5951', N'fc91f5c7-229f-498e-b2dd-ad2f2d97621d', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaoponuje', N'bafd58a0-208d-44b3-822f-474fd2ee5951', N'fc91f5c7-229f-498e-b2dd-ad2f2d97621d', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'brantness', N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'footfault', N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pleonasms', N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'presaying', N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'seamounts', N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uncapable', N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'arbuscles', N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'begrudged', N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fistnotes', N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'foliolate', N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'maestosos', N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pleonasms', N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'railroads', N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sclerosis', N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ceaseless', N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mouthroot', N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'puppetdom', N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sharpshin', N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'limfokina', N'bc608b88-b675-49b8-875b-4927037d8d74', N'd9c6aa61-a901-4273-8c9b-1db89a9a3352', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'narajacie', N'bc608b88-b675-49b8-875b-4927037d8d74', N'd9c6aa61-a901-4273-8c9b-1db89a9a3352', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyżywiani', N'bc608b88-b675-49b8-875b-4927037d8d74', N'd9c6aa61-a901-4273-8c9b-1db89a9a3352', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kręgowcem', N'bc608b88-b675-49b8-875b-4927037d8d74', N'da15904a-934a-4531-95d2-b7369ecd4090', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'narajacie', N'bc608b88-b675-49b8-875b-4927037d8d74', N'da15904a-934a-4531-95d2-b7369ecd4090', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozpałkom', N'bc608b88-b675-49b8-875b-4927037d8d74', N'da15904a-934a-4531-95d2-b7369ecd4090', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozważona', N'bc608b88-b675-49b8-875b-4927037d8d74', N'da15904a-934a-4531-95d2-b7369ecd4090', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ulicówkom', N'bc608b88-b675-49b8-875b-4927037d8d74', N'da15904a-934a-4531-95d2-b7369ecd4090', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyżywiani', N'bc608b88-b675-49b8-875b-4927037d8d74', N'da15904a-934a-4531-95d2-b7369ecd4090', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zmałpowań', N'bc608b88-b675-49b8-875b-4927037d8d74', N'da15904a-934a-4531-95d2-b7369ecd4090', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kostkowatemu', N'bf5c60dc-0c66-4dcd-a19f-b2ccc5b66b83', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nadużywającą', N'bf5c60dc-0c66-4dcd-a19f-b2ccc5b66b83', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niegrodzkimi', N'bf5c60dc-0c66-4dcd-a19f-b2ccc5b66b83', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niesztangowy', N'bf5c60dc-0c66-4dcd-a19f-b2ccc5b66b83', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ośmioaktowej', N'bf5c60dc-0c66-4dcd-a19f-b2ccc5b66b83', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'otworzeniach', N'bf5c60dc-0c66-4dcd-a19f-b2ccc5b66b83', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'popowstawała', N'bf5c60dc-0c66-4dcd-a19f-b2ccc5b66b83', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zasmagaliśmy', N'bf5c60dc-0c66-4dcd-a19f-b2ccc5b66b83', N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chemisorpcję', N'bf5c60dc-0c66-4dcd-a19f-b2ccc5b66b83', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odhuknęliśmy', N'bf5c60dc-0c66-4dcd-a19f-b2ccc5b66b83', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odmieniający', N'bf5c60dc-0c66-4dcd-a19f-b2ccc5b66b83', N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kleptomaniacal', N'c2c9037f-74e1-4b21-9772-8b6cd4275526', N'0c23f819-2c46-43de-ac47-1d6be2242339', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonemotionally', N'c2c9037f-74e1-4b21-9772-8b6cd4275526', N'0c23f819-2c46-43de-ac47-1d6be2242339', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spirillotropic', N'c2c9037f-74e1-4b21-9772-8b6cd4275526', N'0c23f819-2c46-43de-ac47-1d6be2242339', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'superextremely', N'c2c9037f-74e1-4b21-9772-8b6cd4275526', N'0c23f819-2c46-43de-ac47-1d6be2242339', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'concentrically', N'c2c9037f-74e1-4b21-9772-8b6cd4275526', N'0cb10800-2fd6-4664-b849-973903be8021', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonethicalness', N'c2c9037f-74e1-4b21-9772-8b6cd4275526', N'0cb10800-2fd6-4664-b849-973903be8021', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'perimetrically', N'c2c9037f-74e1-4b21-9772-8b6cd4275526', N'0cb10800-2fd6-4664-b849-973903be8021', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pithecanthropi', N'c2c9037f-74e1-4b21-9772-8b6cd4275526', N'0cb10800-2fd6-4664-b849-973903be8021', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'precurriculums', N'c2c9037f-74e1-4b21-9772-8b6cd4275526', N'0cb10800-2fd6-4664-b849-973903be8021', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'presuppression', N'c2c9037f-74e1-4b21-9772-8b6cd4275526', N'0cb10800-2fd6-4664-b849-973903be8021', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'deutencephalic', N'c2c9037f-74e1-4b21-9772-8b6cd4275526', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonemotionally', N'c2c9037f-74e1-4b21-9772-8b6cd4275526', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'paramyosinogen', N'c2c9037f-74e1-4b21-9772-8b6cd4275526', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0440000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spirillotropic', N'c2c9037f-74e1-4b21-9772-8b6cd4275526', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'underthroating', N'c2c9037f-74e1-4b21-9772-8b6cd4275526', N'125a595d-7349-4459-9dec-e7c0c249daf6', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lutao', N'c2e53b86-ea47-435c-b7fc-3ff72a155443', N'93205c1d-0cde-42e8-bd37-ab5a09123c72', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'slope', N'c2e53b86-ea47-435c-b7fc-3ff72a155443', N'93205c1d-0cde-42e8-bd37-ab5a09123c72', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'stash', N'c2e53b86-ea47-435c-b7fc-3ff72a155443', N'93205c1d-0cde-42e8-bd37-ab5a09123c72', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'aired', N'c2e53b86-ea47-435c-b7fc-3ff72a155443', N'972ebecb-b6e1-4d35-8ff6-ba321cca8419', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'arrau', N'c2e53b86-ea47-435c-b7fc-3ff72a155443', N'972ebecb-b6e1-4d35-8ff6-ba321cca8419', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'canli', N'c2e53b86-ea47-435c-b7fc-3ff72a155443', N'972ebecb-b6e1-4d35-8ff6-ba321cca8419', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'canty', N'c2e53b86-ea47-435c-b7fc-3ff72a155443', N'972ebecb-b6e1-4d35-8ff6-ba321cca8419', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kaneh', N'c2e53b86-ea47-435c-b7fc-3ff72a155443', N'972ebecb-b6e1-4d35-8ff6-ba321cca8419', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lutao', N'c2e53b86-ea47-435c-b7fc-3ff72a155443', N'972ebecb-b6e1-4d35-8ff6-ba321cca8419', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ciliola', N'c5983e4f-6021-4909-b98a-59e5540e75de', N'13b76c36-b317-4541-8f77-f66ffdc38fbb', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'farfara', N'c5983e4f-6021-4909-b98a-59e5540e75de', N'13b76c36-b317-4541-8f77-f66ffdc38fbb', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'impends', N'c5983e4f-6021-4909-b98a-59e5540e75de', N'13b76c36-b317-4541-8f77-f66ffdc38fbb', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kirundi', N'c5983e4f-6021-4909-b98a-59e5540e75de', N'13b76c36-b317-4541-8f77-f66ffdc38fbb', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'parrock', N'c5983e4f-6021-4909-b98a-59e5540e75de', N'13b76c36-b317-4541-8f77-f66ffdc38fbb', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ciliola', N'c5983e4f-6021-4909-b98a-59e5540e75de', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'farfara', N'c5983e4f-6021-4909-b98a-59e5540e75de', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unyoked', N'c5983e4f-6021-4909-b98a-59e5540e75de', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'akumulacyjni', N'c5d990bb-1e34-496b-83da-743298a069db', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'akwakulturze', N'c5d990bb-1e34-496b-83da-743298a069db', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dekadenckiej', N'c5d990bb-1e34-496b-83da-743298a069db', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'milenami', N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'napływaj', N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'porfirów', N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ściekowy', N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ukwapach', N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ukwapach', N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wsadziło', N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bekieszą', N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'epifitia', N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'marblity', N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prósząca', N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zasycaną', N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zawiałem', N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'analizuj', N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bursalni', N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kredytów', N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'objedźże', N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pouchyla', N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sedesowi', N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ukwapach', N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kilkugroszowego', N'c62640b4-9012-43b9-8f3d-041a008501f6', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieneopogańskim', N'c62640b4-9012-43b9-8f3d-041a008501f6', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odheroizowywana', N'c62640b4-9012-43b9-8f3d-041a008501f6', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozwalalibyście', N'c62640b4-9012-43b9-8f3d-041a008501f6', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wydoktoryzowali', N'c62640b4-9012-43b9-8f3d-041a008501f6', N'e120f98d-d18d-43a9-9bed-a4118d247410', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niewycałowującą', N'c62640b4-9012-43b9-8f3d-041a008501f6', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niewydatowanemu', N'c62640b4-9012-43b9-8f3d-041a008501f6', N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bazgrałem', N'c7269899-a326-41f1-b55b-10fd17540bd6', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dokwitłem', N'c7269899-a326-41f1-b55b-10fd17540bd6', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odwiejemy', N'c7269899-a326-41f1-b55b-10fd17540bd6', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozważona', N'c7269899-a326-41f1-b55b-10fd17540bd6', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wykurwimy', N'c7269899-a326-41f1-b55b-10fd17540bd6', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'znikające', N'c7269899-a326-41f1-b55b-10fd17540bd6', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chaparral', N'c7269899-a326-41f1-b55b-10fd17540bd6', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cośrodowe', N'c7269899-a326-41f1-b55b-10fd17540bd6', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hartleyem', N'c7269899-a326-41f1-b55b-10fd17540bd6', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mantykorą', N'c7269899-a326-41f1-b55b-10fd17540bd6', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sędziwszą', N'c7269899-a326-41f1-b55b-10fd17540bd6', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zapudłują', N'c7269899-a326-41f1-b55b-10fd17540bd6', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zeswatała', N'c7269899-a326-41f1-b55b-10fd17540bd6', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zwinęłyby', N'c7269899-a326-41f1-b55b-10fd17540bd6', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mięsistym', N'c7269899-a326-41f1-b55b-10fd17540bd6', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odwiejemy', N'c7269899-a326-41f1-b55b-10fd17540bd6', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'warownych', N'c7269899-a326-41f1-b55b-10fd17540bd6', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wykonalną', N'c7269899-a326-41f1-b55b-10fd17540bd6', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zagładźże', N'c7269899-a326-41f1-b55b-10fd17540bd6', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'znaglajmy', N'c7269899-a326-41f1-b55b-10fd17540bd6', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chodami', N'cbbdff6d-8f19-49a4-a703-45d43eefd101', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'klangor', N'cbbdff6d-8f19-49a4-a703-45d43eefd101', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'łódkowe', N'cbbdff6d-8f19-49a4-a703-45d43eefd101', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pacnęła', N'cbbdff6d-8f19-49a4-a703-45d43eefd101', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'szaleję', N'cbbdff6d-8f19-49a4-a703-45d43eefd101', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trącisz', N'cbbdff6d-8f19-49a4-a703-45d43eefd101', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'jebanej', N'cbbdff6d-8f19-49a4-a703-45d43eefd101', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'moczmyż', N'cbbdff6d-8f19-49a4-a703-45d43eefd101', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ramnozy', N'cbbdff6d-8f19-49a4-a703-45d43eefd101', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'żarnowe', N'cbbdff6d-8f19-49a4-a703-45d43eefd101', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaznane', N'cbbdff6d-8f19-49a4-a703-45d43eefd101', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'antigambling', N'cc76083c-5c77-45dd-9c13-452066ad0877', N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'heliochromic', N'cc76083c-5c77-45dd-9c13-452066ad0877', N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unsurrounded', N'cc76083c-5c77-45dd-9c13-452066ad0877', N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'antigambling', N'cc76083c-5c77-45dd-9c13-452066ad0877', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'clavicithern', N'cc76083c-5c77-45dd-9c13-452066ad0877', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cogitability', N'cc76083c-5c77-45dd-9c13-452066ad0877', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'parturitions', N'cc76083c-5c77-45dd-9c13-452066ad0877', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pauciloquent', N'cc76083c-5c77-45dd-9c13-452066ad0877', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'subobliquely', N'cc76083c-5c77-45dd-9c13-452066ad0877', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unmeridional', N'cc76083c-5c77-45dd-9c13-452066ad0877', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unperfidious', N'cc76083c-5c77-45dd-9c13-452066ad0877', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'multitasking', N'cc76083c-5c77-45dd-9c13-452066ad0877', N'4130105a-24e1-41b7-917f-671188d8a4cd', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'polydactylus', N'cc76083c-5c77-45dd-9c13-452066ad0877', N'4130105a-24e1-41b7-917f-671188d8a4cd', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sulfobenzide', N'cc76083c-5c77-45dd-9c13-452066ad0877', N'4130105a-24e1-41b7-917f-671188d8a4cd', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'aecidiostage', N'cc76083c-5c77-45dd-9c13-452066ad0877', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'articulative', N'cc76083c-5c77-45dd-9c13-452066ad0877', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unmeridional', N'cc76083c-5c77-45dd-9c13-452066ad0877', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unpermeating', N'cc76083c-5c77-45dd-9c13-452066ad0877', N'43a69367-b056-405f-a664-36d459c60753', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bumsucking', N'ce22af16-9d31-4642-b206-e96cc6d7e0f3', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'choucroute', N'ce22af16-9d31-4642-b206-e96cc6d7e0f3', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unvolitive', N'ce22af16-9d31-4642-b206-e96cc6d7e0f3', N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'contradict', N'ce22af16-9d31-4642-b206-e96cc6d7e0f3', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hemimorphy', N'ce22af16-9d31-4642-b206-e96cc6d7e0f3', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pateriform', N'ce22af16-9d31-4642-b206-e96cc6d7e0f3', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'plagiaries', N'ce22af16-9d31-4642-b206-e96cc6d7e0f3', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'villainist', N'ce22af16-9d31-4642-b206-e96cc6d7e0f3', N'b57a33b0-797e-465e-839f-82077880afd2', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prescience', N'ce22af16-9d31-4642-b206-e96cc6d7e0f3', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tricennial', N'ce22af16-9d31-4642-b206-e96cc6d7e0f3', N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'autentysta', N'cec7bdbd-0f1b-4708-b280-31ec38971bb2', N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kesonowało', N'cec7bdbd-0f1b-4708-b280-31ec38971bb2', N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mózgownicę', N'cec7bdbd-0f1b-4708-b280-31ec38971bb2', N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niedopałku', N'cec7bdbd-0f1b-4708-b280-31ec38971bb2', N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieumarzłą', N'cec7bdbd-0f1b-4708-b280-31ec38971bb2', N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wizjonerzy', N'cec7bdbd-0f1b-4708-b280-31ec38971bb2', N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'błękitnymi', N'cec7bdbd-0f1b-4708-b280-31ec38971bb2', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kesonowało', N'cec7bdbd-0f1b-4708-b280-31ec38971bb2', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pstrążkowi', N'cec7bdbd-0f1b-4708-b280-31ec38971bb2', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cytokininowego', N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'728519c3-3136-40b7-bfb9-561a50bc4ebd', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fikobilinowymi', N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'728519c3-3136-40b7-bfb9-561a50bc4ebd', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niekretynowate', N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'728519c3-3136-40b7-bfb9-561a50bc4ebd', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieprzysurowej', N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'728519c3-3136-40b7-bfb9-561a50bc4ebd', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niewykupionego', N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'728519c3-3136-40b7-bfb9-561a50bc4ebd', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pokrzywdziłbym', N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'728519c3-3136-40b7-bfb9-561a50bc4ebd', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przerąbywałoby', N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'728519c3-3136-40b7-bfb9-561a50bc4ebd', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zazielenionych', N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'728519c3-3136-40b7-bfb9-561a50bc4ebd', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niefalklandzka', N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'73070ab0-053a-4f45-8569-6e1ceaea9f02', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepowzdymania', N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'73070ab0-053a-4f45-8569-6e1ceaea9f02', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezamrażająca', N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'73070ab0-053a-4f45-8569-6e1ceaea9f02', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'postkomunizmem', N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'73070ab0-053a-4f45-8569-6e1ceaea9f02', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieodzywaniach', N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'744dea72-c59a-4785-ab1b-8f627c6901bf', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieprzypędzaną', N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'744dea72-c59a-4785-ab1b-8f627c6901bf', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pokrzywdziłbym', N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'744dea72-c59a-4785-ab1b-8f627c6901bf', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zabijałybyście', N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'744dea72-c59a-4785-ab1b-8f627c6901bf', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zazielenionych', N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'744dea72-c59a-4785-ab1b-8f627c6901bf', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pokrzywdziłbym', N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'brachydactyly', N'cfcc785c-b3b7-433a-a8c7-7ce63aab734c', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'megalopolises', N'cfcc785c-b3b7-433a-a8c7-7ce63aab734c', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'phlebenterism', N'cfcc785c-b3b7-433a-a8c7-7ce63aab734c', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'slavification', N'cfcc785c-b3b7-433a-a8c7-7ce63aab734c', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'transliterate', N'cfcc785c-b3b7-433a-a8c7-7ce63aab734c', N'1ccd2561-39ab-45fb-ba18-053e46700132', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'demonolatrous', N'cfcc785c-b3b7-433a-a8c7-7ce63aab734c', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'haemorrhaging', N'cfcc785c-b3b7-433a-a8c7-7ce63aab734c', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ichthyography', N'cfcc785c-b3b7-433a-a8c7-7ce63aab734c', N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'marblity', N'd10fb17e-391f-4d3e-a948-c00482eacd77', N'613f9c48-1536-4a01-a97c-825f93bf11a4', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ojcujmyż', N'd10fb17e-391f-4d3e-a948-c00482eacd77', N'613f9c48-1536-4a01-a97c-825f93bf11a4', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pouchyla', N'd10fb17e-391f-4d3e-a948-c00482eacd77', N'613f9c48-1536-4a01-a97c-825f93bf11a4', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'śledzisz', N'd10fb17e-391f-4d3e-a948-c00482eacd77', N'613f9c48-1536-4a01-a97c-825f93bf11a4', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'snycerka', N'd10fb17e-391f-4d3e-a948-c00482eacd77', N'613f9c48-1536-4a01-a97c-825f93bf11a4', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ukwapach', N'd10fb17e-391f-4d3e-a948-c00482eacd77', N'613f9c48-1536-4a01-a97c-825f93bf11a4', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wypławił', N'd10fb17e-391f-4d3e-a948-c00482eacd77', N'613f9c48-1536-4a01-a97c-825f93bf11a4', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zasycaną', N'd10fb17e-391f-4d3e-a948-c00482eacd77', N'613f9c48-1536-4a01-a97c-825f93bf11a4', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bordunom', N'd10fb17e-391f-4d3e-a948-c00482eacd77', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dwuczuba', N'd10fb17e-391f-4d3e-a948-c00482eacd77', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'epifitia', N'd10fb17e-391f-4d3e-a948-c00482eacd77', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'jezydzie', N'd10fb17e-391f-4d3e-a948-c00482eacd77', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'łepeczku', N'd10fb17e-391f-4d3e-a948-c00482eacd77', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'napływaj', N'd10fb17e-391f-4d3e-a948-c00482eacd77', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'porfirów', N'd10fb17e-391f-4d3e-a948-c00482eacd77', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zasycaną', N'd10fb17e-391f-4d3e-a948-c00482eacd77', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dimeryzacją', N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'łyżwiarskim', N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mateologiom', N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naszczałyby', N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'piwowarskim', N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'popękałabyś', N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nietulowską', N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'otamowujmyż', N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ozłacaniami', N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'smyczkowymi', N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zapleśnieję', N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'łyżwiarskim', N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepęcinową', N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'łączniowate', N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'łyżwiarskim', N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'otamowujmyż', N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'strzałowaci', N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zapleśnieję', N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zesmutniałą', N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fikobilinowymi', N'd2dfecd1-4060-49ba-a046-7aad821b199f', N'13b76c36-b317-4541-8f77-f66ffdc38fbb', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'krótkofalarscy', N'd2dfecd1-4060-49ba-a046-7aad821b199f', N'13b76c36-b317-4541-8f77-f66ffdc38fbb', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niekretynowate', N'd2dfecd1-4060-49ba-a046-7aad821b199f', N'13b76c36-b317-4541-8f77-f66ffdc38fbb', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niemagnetytowi', N'd2dfecd1-4060-49ba-a046-7aad821b199f', N'13b76c36-b317-4541-8f77-f66ffdc38fbb', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepozapędzane', N'd2dfecd1-4060-49ba-a046-7aad821b199f', N'13b76c36-b317-4541-8f77-f66ffdc38fbb', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieprzysurowej', N'd2dfecd1-4060-49ba-a046-7aad821b199f', N'13b76c36-b317-4541-8f77-f66ffdc38fbb', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pomieszkiwania', N'd2dfecd1-4060-49ba-a046-7aad821b199f', N'13b76c36-b317-4541-8f77-f66ffdc38fbb', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'praktykantkach', N'd2dfecd1-4060-49ba-a046-7aad821b199f', N'13b76c36-b317-4541-8f77-f66ffdc38fbb', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niekretynowate', N'd2dfecd1-4060-49ba-a046-7aad821b199f', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nienadźwiganie', N'd2dfecd1-4060-49ba-a046-7aad821b199f', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieprzysurowej', N'd2dfecd1-4060-49ba-a046-7aad821b199f', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'postkomunizmem', N'd2dfecd1-4060-49ba-a046-7aad821b199f', N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', CAST(N'2022-02-04T23:23:57.0450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'annexion', N'd5319834-7d9c-4d3f-bfec-50a38d1262ac', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'betangle', N'd5319834-7d9c-4d3f-bfec-50a38d1262ac', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'courtier', N'd5319834-7d9c-4d3f-bfec-50a38d1262ac', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'innatism', N'd5319834-7d9c-4d3f-bfec-50a38d1262ac', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'laborage', N'd5319834-7d9c-4d3f-bfec-50a38d1262ac', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mitering', N'd5319834-7d9c-4d3f-bfec-50a38d1262ac', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overhang', N'd5319834-7d9c-4d3f-bfec-50a38d1262ac', N'389d174d-d3e9-4478-bd91-1733394fef65', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cervicolumbar', N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'demonolatrous', N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dephysicalize', N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'exceedingness', N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rhabdocoelida', N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unlubricating', N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unpatternized', N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'anathematised', N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'antilibration', N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'counterflight', N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'extractorship', N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hutchinsonite', N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pneumatoscope', N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sensationally', N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'698b27a2-78d5-4d6b-a189-baccfc00786b', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nondistortion', N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unlubricating', N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'corruptionist', N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'counterflight', N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sensationally', N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unlubricating', N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'6bbb6e1c-23ea-453f-8654-1e800896b147', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'absentees', N'db2ad574-0f44-4e41-a261-eef71adff422', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'agentries', N'db2ad574-0f44-4e41-a261-eef71adff422', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bephilter', N'db2ad574-0f44-4e41-a261-eef71adff422', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overloves', N'db2ad574-0f44-4e41-a261-eef71adff422', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uncapable', N'db2ad574-0f44-4e41-a261-eef71adff422', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'arthurian', N'db2ad574-0f44-4e41-a261-eef71adff422', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'auspicate', N'db2ad574-0f44-4e41-a261-eef71adff422', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'breaching', N'db2ad574-0f44-4e41-a261-eef71adff422', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'exorcised', N'db2ad574-0f44-4e41-a261-eef71adff422', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hieracite', N'db2ad574-0f44-4e41-a261-eef71adff422', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'steapsins', N'db2ad574-0f44-4e41-a261-eef71adff422', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trihydric', N'db2ad574-0f44-4e41-a261-eef71adff422', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ditchside', N'db2ad574-0f44-4e41-a261-eef71adff422', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'globulins', N'db2ad574-0f44-4e41-a261-eef71adff422', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'registrer', N'db2ad574-0f44-4e41-a261-eef71adff422', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'steellike', N'db2ad574-0f44-4e41-a261-eef71adff422', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unresumed', N'db2ad574-0f44-4e41-a261-eef71adff422', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'vandalism', N'db2ad574-0f44-4e41-a261-eef71adff422', N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'attestant', N'db2ad574-0f44-4e41-a261-eef71adff422', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'exorcised', N'db2ad574-0f44-4e41-a261-eef71adff422', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ivoriness', N'db2ad574-0f44-4e41-a261-eef71adff422', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'quinquino', N'db2ad574-0f44-4e41-a261-eef71adff422', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'registrer', N'db2ad574-0f44-4e41-a261-eef71adff422', N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'anathematised', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'972ebecb-b6e1-4d35-8ff6-ba321cca8419', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'centrodesmose', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'972ebecb-b6e1-4d35-8ff6-ba321cca8419', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pneumatoscope', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'972ebecb-b6e1-4d35-8ff6-ba321cca8419', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'retrogressive', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'972ebecb-b6e1-4d35-8ff6-ba321cca8419', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sensationally', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'972ebecb-b6e1-4d35-8ff6-ba321cca8419', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'slavification', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'972ebecb-b6e1-4d35-8ff6-ba321cca8419', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unreproaching', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'972ebecb-b6e1-4d35-8ff6-ba321cca8419', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cervicolumbar', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'criticisingly', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dephysicalize', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sensationally', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'transliterate', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'demonolatrous', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mousquetaires', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nondistortion', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'phlebenterism', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pneumatoscope', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sensationally', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unpatternized', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cardiorrheuma', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'centrodesmose', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'heterocarpism', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overhostilely', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ptenoglossate', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'supraspinatus', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'symbionticism', N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'groundkeeper', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'heliochromic', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'incendiarist', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'metastasized', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pauciloquent', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'politicizing', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unreluctance', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gastrulation', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'groundkeeper', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lamentations', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'laticiferous', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'metastasized', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'equisetaceae', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spidermonkey', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'subobliquely', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'victorianize', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'adenosarcoma', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cameralistic', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'groundkeeper', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'politicizing', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'polydactylus', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unactiveness', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unmeridional', N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niekobiece', N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieumarzłą', N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'solipsysta', N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wdzydzkich', N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zgłaszanie', N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gałęziastą', N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niekobiece', N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wydeptujmy', N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'majtnięciu', N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'werbowałem', N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wybawiłoby', N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zamęczyłem', N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bindownico', N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niekobiece', N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tamowanemu', N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'werbowałem', N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'beghard', N'e1ca7d08-bcc9-4f85-9782-834db1d69e48', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'monkism', N'e1ca7d08-bcc9-4f85-9782-834db1d69e48', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reflown', N'e1ca7d08-bcc9-4f85-9782-834db1d69e48', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sharply', N'e1ca7d08-bcc9-4f85-9782-834db1d69e48', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trombiną', N'e231f1a8-7c56-402d-bf96-7dee700c05c8', N'7912de18-3416-478c-b390-467b0e63c156', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bekieszą', N'e231f1a8-7c56-402d-bf96-7dee700c05c8', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kredytów', N'e231f1a8-7c56-402d-bf96-7dee700c05c8', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'porfirów', N'e231f1a8-7c56-402d-bf96-7dee700c05c8', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'usychają', N'e231f1a8-7c56-402d-bf96-7dee700c05c8', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wsadziło', N'e231f1a8-7c56-402d-bf96-7dee700c05c8', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'żgaliśmy', N'e231f1a8-7c56-402d-bf96-7dee700c05c8', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'epifitia', N'e231f1a8-7c56-402d-bf96-7dee700c05c8', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pokuciem', N'e231f1a8-7c56-402d-bf96-7dee700c05c8', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'porfirów', N'e231f1a8-7c56-402d-bf96-7dee700c05c8', N'7d046d6d-7062-4866-9260-537e4da79c62', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pokuciem', N'e231f1a8-7c56-402d-bf96-7dee700c05c8', N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieposłuszeństw', N'e28aa984-a016-41be-b3d3-078b5e1345e3', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niewyjękniętych', N'e28aa984-a016-41be-b3d3-078b5e1345e3', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'okleiłybyśmy', N'e28ec349-e24d-4d60-84e7-752fb5fac474', N'b6d3c418-4096-4e82-a91b-86517f43fbb5', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'minezengerom', N'e28ec349-e24d-4d60-84e7-752fb5fac474', N'b78d69ea-1308-414e-acb0-b539b35ff945', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odrodziłabym', N'e28ec349-e24d-4d60-84e7-752fb5fac474', N'b78d69ea-1308-414e-acb0-b539b35ff945', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'okleiłybyśmy', N'e28ec349-e24d-4d60-84e7-752fb5fac474', N'b78d69ea-1308-414e-acb0-b539b35ff945', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'remontowcami', N'e28ec349-e24d-4d60-84e7-752fb5fac474', N'b78d69ea-1308-414e-acb0-b539b35ff945', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'avouched', N'e62374d5-d2a3-4332-90d2-d06ca338de64', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hircarra', N'e62374d5-d2a3-4332-90d2-d06ca338de64', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lazarets', N'e62374d5-d2a3-4332-90d2-d06ca338de64', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mudstone', N'e62374d5-d2a3-4332-90d2-d06ca338de64', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'stoneman', N'e62374d5-d2a3-4332-90d2-d06ca338de64', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sturdied', N'e62374d5-d2a3-4332-90d2-d06ca338de64', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kostkowatemu', N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepodegraną', N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odpoczynkami', N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pokostowałem', N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'polerowanych', N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prowadzające', N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyczerpywali', N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'estymowałyby', N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niechlejącym', N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4a3e90d2-3244-476a-b421-9b7be32688b7', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niesztangowy', N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'popowstawała', N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozmówiłyśmy', N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'akumulacyjni', N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niechlejącym', N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'polerowanych', N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przerzynałam', N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'remontowcami', N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'roztłukujący', N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'barciach', N'e730b417-2bf3-463b-a163-7b39113b689e', N'03d23e9c-c1f2-4497-9d27-f164a101d41b', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'porzućmy', N'e730b417-2bf3-463b-a163-7b39113b689e', N'03d23e9c-c1f2-4497-9d27-f164a101d41b', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ściekowy', N'e730b417-2bf3-463b-a163-7b39113b689e', N'03d23e9c-c1f2-4497-9d27-f164a101d41b', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sedesowi', N'e730b417-2bf3-463b-a163-7b39113b689e', N'03d23e9c-c1f2-4497-9d27-f164a101d41b', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bindownico', N'e81f69bc-775b-42ee-8e33-ac114030d448', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieomiatań', N'e81f69bc-775b-42ee-8e33-ac114030d448', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'oplątujcie', N'e81f69bc-775b-42ee-8e33-ac114030d448', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pozużywało', N'e81f69bc-775b-42ee-8e33-ac114030d448', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'siklawicom', N'e81f69bc-775b-42ee-8e33-ac114030d448', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ukartujemy', N'e81f69bc-775b-42ee-8e33-ac114030d448', N'7bf154bb-8053-474f-acce-9ab5967fd6b9', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cieszą', N'e831db5f-5a24-4b40-a5a2-4510368bb206', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dobada', N'e831db5f-5a24-4b40-a5a2-4510368bb206', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nagnać', N'e831db5f-5a24-4b40-a5a2-4510368bb206', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ozanów', N'e831db5f-5a24-4b40-a5a2-4510368bb206', N'ef631367-7def-4d0f-8ff9-02a77169efe7', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'biocenology', N'e88dbadd-607f-4fcf-9463-095ff48613a6', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'botryllidae', N'e88dbadd-607f-4fcf-9463-095ff48613a6', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'compilement', N'e88dbadd-607f-4fcf-9463-095ff48613a6', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'holostomate', N'e88dbadd-607f-4fcf-9463-095ff48613a6', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'inadvertent', N'e88dbadd-607f-4fcf-9463-095ff48613a6', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'masculinism', N'e88dbadd-607f-4fcf-9463-095ff48613a6', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonphenolic', N'e88dbadd-607f-4fcf-9463-095ff48613a6', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tootinghole', N'e88dbadd-607f-4fcf-9463-095ff48613a6', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'holostomate', N'e88dbadd-607f-4fcf-9463-095ff48613a6', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zheblujesz', N'e8a43cde-0406-4847-9c2e-dbc79fd73e9b', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zheblujesz', N'e8a43cde-0406-4847-9c2e-dbc79fd73e9b', N'fa6649f7-2e06-4689-a994-5f89251ffc79', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zheblujesz', N'e8a43cde-0406-4847-9c2e-dbc79fd73e9b', N'fbae442c-6f4d-4b79-9583-9fe1c931fc65', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'autentysta', N'e8a43cde-0406-4847-9c2e-dbc79fd73e9b', N'fc91f5c7-229f-498e-b2dd-ad2f2d97621d', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'beenowskie', N'e8a43cde-0406-4847-9c2e-dbc79fd73e9b', N'fc91f5c7-229f-498e-b2dd-ad2f2d97621d', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cesarczyka', N'e8a43cde-0406-4847-9c2e-dbc79fd73e9b', N'fc91f5c7-229f-498e-b2dd-ad2f2d97621d', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'narwałyśmy', N'e8a43cde-0406-4847-9c2e-dbc79fd73e9b', N'fc91f5c7-229f-498e-b2dd-ad2f2d97621d', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pozużywało', N'e8a43cde-0406-4847-9c2e-dbc79fd73e9b', N'fc91f5c7-229f-498e-b2dd-ad2f2d97621d', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'warknęłyby', N'e8a43cde-0406-4847-9c2e-dbc79fd73e9b', N'fc91f5c7-229f-498e-b2dd-ad2f2d97621d', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'apophysate', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'blackheads', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'breakpoint', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'economiser', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'paraenesis', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'surfeiting', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'underhatch', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'virtualism', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cinematize', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'decigramme', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'woodsheddi', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aab181cc-8188-46f1-80da-cccefc128553', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dimensible', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hollyhocks', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lorettoite', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mannersome', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'presuppose', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rosefishes', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'singhalese', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unexhorted', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'aba31de6-9407-4169-b316-058f860dc4b4', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'abortional', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dingthrift', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hollyhocks', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rurigenous', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'villainist', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'woodsheddi', N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'venoms', N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'aucuba', N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'calesa', N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cotyla', N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'darryl', N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dungol', N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fogies', N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tubate', N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'urchin', N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'inisle', N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lading', N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'muscae', N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nerita', N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'twyers', N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uppish', N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'venoms', N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zyryan', N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'f9174142-9a18-4ffc-a25e-7053c376e39d', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'convented', N'f12f3829-e8f6-4db7-8ac5-c96d9b9727af', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'megampere', N'f12f3829-e8f6-4db7-8ac5-c96d9b9727af', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonfluids', N'f12f3829-e8f6-4db7-8ac5-c96d9b9727af', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'outbeggar', N'f12f3829-e8f6-4db7-8ac5-c96d9b9727af', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pyelotomy', N'f12f3829-e8f6-4db7-8ac5-c96d9b9727af', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unweighty', N'f12f3829-e8f6-4db7-8ac5-c96d9b9727af', N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niechłonięciom', N'f26a57ba-179a-493a-b1b0-314a3886c684', N'dcb267e6-009f-40ac-971c-5ccfc5409e7e', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niedublowanemu', N'f26a57ba-179a-493a-b1b0-314a3886c684', N'dcb267e6-009f-40ac-971c-5ccfc5409e7e', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'technostresowi', N'f26a57ba-179a-493a-b1b0-314a3886c684', N'dcb267e6-009f-40ac-971c-5ccfc5409e7e', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ubiegłorocznym', N'f26a57ba-179a-493a-b1b0-314a3886c684', N'dcb267e6-009f-40ac-971c-5ccfc5409e7e', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyświdrowywały', N'f26a57ba-179a-493a-b1b0-314a3886c684', N'dcb267e6-009f-40ac-971c-5ccfc5409e7e', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'konfrontatywna', N'f26a57ba-179a-493a-b1b0-314a3886c684', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niekajakowaniu', N'f26a57ba-179a-493a-b1b0-314a3886c684', N'e0abba51-2767-4e84-85c8-24bddc905ba5', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niekajakowaniu', N'f26a57ba-179a-493a-b1b0-314a3886c684', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieprzesłanych', N'f26a57ba-179a-493a-b1b0-314a3886c684', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podmarszczyłem', N'f26a57ba-179a-493a-b1b0-314a3886c684', N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nielochającymi', N'f2d68448-6cef-42f8-b355-104a7e1de37e', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nienadźwiganie', N'f2d68448-6cef-42f8-b355-104a7e1de37e', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieudręczająco', N'f2d68448-6cef-42f8-b355-104a7e1de37e', N'a6230e58-5fa7-48ad-bf00-3480e00792f5', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieudręczająco', N'f2d68448-6cef-42f8-b355-104a7e1de37e', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pozastawianego', N'f2d68448-6cef-42f8-b355-104a7e1de37e', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'subiektywistka', N'f2d68448-6cef-42f8-b355-104a7e1de37e', N'a8760359-6d60-490c-b036-c762e90c4eb9', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niedokopaniami', N'f2d68448-6cef-42f8-b355-104a7e1de37e', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepozapędzane', N'f2d68448-6cef-42f8-b355-104a7e1de37e', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zabatożyłyście', N'f2d68448-6cef-42f8-b355-104a7e1de37e', N'aa92e8c2-a045-4be2-b686-97b7b50864cd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'abortional', N'f6d6c97f-cb2b-4bbb-87d5-c06cd77a15de', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'alabastron', N'f6d6c97f-cb2b-4bbb-87d5-c06cd77a15de', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'buddhology', N'f6d6c97f-cb2b-4bbb-87d5-c06cd77a15de', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pateriform', N'f6d6c97f-cb2b-4bbb-87d5-c06cd77a15de', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'surfeiting', N'f6d6c97f-cb2b-4bbb-87d5-c06cd77a15de', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'underhatch', N'f6d6c97f-cb2b-4bbb-87d5-c06cd77a15de', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'paraenesis', N'f6d6c97f-cb2b-4bbb-87d5-c06cd77a15de', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pateriform', N'f6d6c97f-cb2b-4bbb-87d5-c06cd77a15de', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bezwapiennego', N'fa36be8e-fe7d-4c29-99c8-d85c62d6e59e', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'diastolicznym', N'fa36be8e-fe7d-4c29-99c8-d85c62d6e59e', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niebukowatych', N'fa36be8e-fe7d-4c29-99c8-d85c62d6e59e', N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niebukowatych', N'fa36be8e-fe7d-4c29-99c8-d85c62d6e59e', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieodpisywane', N'fa36be8e-fe7d-4c29-99c8-d85c62d6e59e', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieparciejąca', N'fa36be8e-fe7d-4c29-99c8-d85c62d6e59e', N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nietrząsające', N'fa36be8e-fe7d-4c29-99c8-d85c62d6e59e', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieżyłowaniem', N'fa36be8e-fe7d-4c29-99c8-d85c62d6e59e', N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'diastolicznym', N'fa36be8e-fe7d-4c29-99c8-d85c62d6e59e', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nadmieniajcie', N'fa36be8e-fe7d-4c29-99c8-d85c62d6e59e', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niebukowatych', N'fa36be8e-fe7d-4c29-99c8-d85c62d6e59e', N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'censer', N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'curlew', N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'censer', N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gurdle', N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rubato', N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spuria', N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'calces', N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'impart', N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'marree', N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'scribe', N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spuria', N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'4f2adedb-722b-4418-ab20-bad685f412bd', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'calces', N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'empasm', N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nerita', N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'petate', N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rakery', N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rubato', N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'quantify', N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'together', N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c379fc7a-0dae-425d-8df5-99b41cc6c255', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'charivan', N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'foreguts', N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hematics', N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'outstank', N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'swimmier', N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'together', N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wenchman', N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c3f12149-9380-48f0-b770-aa83d8cf528a', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'beelines', N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hircarra', N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'skiplane', N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c509dffb-e04d-479f-81d8-0bf58fcbe593', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'besquirt', N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'betangle', N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'carboloy', N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dimeters', N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'quantify', N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sedanier', N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'c75684e6-5a47-4330-8bde-1a99b417e809', CAST(N'2022-02-04T23:23:57.0470000' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[challenge_types] ON 

INSERT [dbo].[challenge_types] ([id], [name], [created_at], [updated_at]) VALUES (1, N'daily', CAST(N'2022-02-04T23:23:56.7740000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7747796' AS DateTime2))
INSERT [dbo].[challenge_types] ([id], [name], [created_at], [updated_at]) VALUES (2, N'weekly', CAST(N'2022-02-04T23:23:56.7740000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7747828' AS DateTime2))
INSERT [dbo].[challenge_types] ([id], [name], [created_at], [updated_at]) VALUES (3, N'private', CAST(N'2022-02-04T23:23:56.7740000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7747839' AS DateTime2))
SET IDENTITY_INSERT [dbo].[challenge_types] OFF
GO
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'00b83827-6136-463d-8642-763ab9a1f2b0', N'cośrodowe', N'pl', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901509' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'056ff82a-a401-4fab-a32e-5b4b915c7160', N'redyeing', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901523' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'06dbbd0a-f962-4bef-83e4-d3a9e37bd52b', N'horteksowską', N'pl', 2, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900215' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'07a412e5-9fe2-40e7-8bb3-1c6fbd103d0a', N'groyne', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900770' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'0b447693-fe68-40d9-a8bc-896cd8adcf57', N'skonsygnowaniem', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900910' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'0d5fe0f0-cc88-41a5-a597-487ddf9ad7cc', N'hartleyem', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901296' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'1026cff0-bfeb-49cf-9666-cc89b9381869', N'meritmongering', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900672' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'129192bc-e689-4e25-801b-d236b7809ed3', N'kaperowań', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901354' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'12bdb886-fede-44aa-8ff4-a382918328f0', N'pozużywało', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901224' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'14575f82-13ae-4e08-918c-9d620c3fcf08', N'poobłupują', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900742' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'17a82e36-ac43-44fe-9b3d-ba0ac3947da8', N'preclothing', N'en', 2, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900358' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'17cecdc2-1007-4b6c-a409-768ff9e46f6e', N'nonethicalness', N'en', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900756' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'18dbfba5-253d-443d-9dc2-631d14d5515a', N'październikom', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900974' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'19cd4b2b-1d50-4c62-b221-42988e8e2265', N'devotion', N'en', 3, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900265' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'1a143d92-d6ca-4926-b3ab-e41eed9ac694', N'sedesowi', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901168' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'1a815f63-45c8-49d4-a6c1-48e496c5ffd8', N'sedanier', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900714' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'1aaf9d9c-e03f-48d4-b2ac-1c5345aeaab6', N'hydrozespoły', N'pl', 2, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900171' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'1fa8dbce-d7ac-43a0-9b80-3c007bdceb41', N'absurdalnym', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901161' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'201c4bbc-9ede-4582-b2cf-fc5f268d7566', N'unthundering', N'en', 2, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900301' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'20334ec7-961c-4777-b953-0db3922c6093', N'steersmen', N'en', 2, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900315' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'20d20ea7-8d7c-4945-9ff6-3b2843be1a8e', N'thesmothete', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901403' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'244aa6a9-5c17-4519-80ec-9579e072f272', N'stumplike', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900812' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'2499f30e-55fd-4542-be16-045ec1374d42', N'counterflight', N'en', 1, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900272' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'24a9a7f6-1eff-4017-b7f9-2752012332ba', N'zgniataczem', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901147' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'2540bca0-4019-4891-bc52-ddcef0cf29cf', N'pneumatoscope', N'en', 1, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900415' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'25af3883-cb65-4917-ad63-c3518f83912d', N'hebdu', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900847' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'27a74769-8025-4896-84d5-abf63e8c20f6', N'wymywacie', N'pl', 2, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900279' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'2a78f99e-54f0-4565-b607-c9c122ff6945', N'victorianize', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900506' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'2bfb6f6d-f877-4f8c-bb0b-4601d30d5198', N'oligomyodian', N'en', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900826' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'2e921fdd-b8e7-43a2-a429-7f04657cf4d8', N'serb', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900931' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'2ecb8a7f-7963-4ed4-ab3c-9c64e4b58b34', N'zasycaną', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900785' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'305094c3-5285-4ef6-92d9-f61a6f9be8d7', N'censual', N'en', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901063' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'309529e6-b081-47af-9b60-007c4e97e82e', N'roundridge', N'en', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900798' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'30af4466-e763-405d-b2f0-fb0ce6ad011f', N'haliczanin', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901481' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'30f8838e-e194-4718-a4a7-044b8deccb33', N'suberynach', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901488' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'31932f27-38ed-4eae-bf90-d29e80b8c967', N'seral', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900693' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'31e06003-5e6e-4c89-8b7a-f9cc843f2f9c', N'unpatternized', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901238' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'3335f4a1-b8e6-435b-b6ad-2c5c5725792d', N'nienożycowymi', N'pl', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901383' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'341183da-7158-435e-a781-a84d31babc97', N'philonoist', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900651' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'3495ac14-494b-42ec-8991-159ef450f0c0', N'unmetaphysic', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900521' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'355d3c89-c760-4715-adda-9c252cbeb9b2', N'decernment', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900559' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'35908f1c-0166-47c3-b9b0-fb13ba21276e', N'heteroptics', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900833' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'366d0527-8417-4090-a49f-beb54dc8f62d', N'olszóweckimi', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901002' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'388dbf0f-97af-4ea0-b88c-bc9c66540766', N'niekumpelski', N'pl', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900587' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'39aa470d-bdf4-400f-9eab-65f5e5dbdf22', N'philosophism', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901417' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'39bcaab3-0e58-4816-a3d0-1e613748857a', N'olszóweckimi', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901439' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'3aa323cf-0892-4b84-b3c2-3eed2f35f8ef', N'betangle', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900552' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'3b89d3d9-59bc-4dca-8d0b-f745b47d1804', N'puppetdom', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901253' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'3cb1c347-74b9-47b1-87c3-7d7e0961e4d6', N'podpuchnięciami', N'pl', 2, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900226' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'3d0fbc7b-1c17-48ac-90e1-386c9a5d6478', N'elasticity', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901203' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'3d63c271-5ede-467a-b4a8-f0ef99b0002c', N'wegetując', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900917' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'3eb0d0d4-ed5d-4675-9faf-66cd2083871c', N'pokancerowaniom', N'pl', 1, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900429' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'4285150c-62ba-4e58-bdc4-b163f652c73a', N'serowarami', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900861' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'45a6c563-d24d-45f9-8ed1-2478ebbb680e', N'protocolize', N'en', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901134' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'45fb9b03-b59c-4a1b-838a-0bb35ae6fcd5', N'brzytwom', N'pl', 3, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900373' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'47f9d0f4-ec8c-464d-99c4-5fb9ef8fbe14', N'trigeminus', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901876' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'487b34ca-6417-431d-80c1-fbb630b2ca2d', N'rozdzierając', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900573' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'499935dc-e24b-4793-8100-e562bc3adbcc', N'niepodczesujący', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901317' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'4e33d54c-9e00-4c5d-933f-8e7d5b31f4d9', N'wyświdrowywały', N'pl', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901467' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'4e59778d-ac70-4bb8-b4af-53a9debed1c7', N'siurkach', N'pl', 2, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900293' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'4fa21013-32e2-43b6-a89a-076f6ee70dcf', N'maestosos', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900729' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'504a5221-61af-4670-8227-5f16df1128dd', N'poriomanic', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901530' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'52e6cb77-59e9-41f1-ad38-49b9ef0a4554', N'pokancerowaniom', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900763' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'56c1b8d0-6a3a-41ac-934c-16e7f75e3f4c', N'błogosławionego', N'pl', 3, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900233' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'581f8525-baad-489e-a91c-94f1b5bbc9f2', N'górnicą', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900644' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'582d9b2d-60ad-4e60-aa5b-9b76ec0a50a2', N'hopthumb', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901446' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'59a023ae-683c-4519-a443-fa02819e1747', N'cervicolumbar', N'en', 2, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900258' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'5a36eabf-fbdd-4e40-afb1-68c2a23c63d7', N'involucred', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901275' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'5ab00c25-6eb4-440e-9928-5db410d8e3a0', N'nieulżeniom', N'pl', 3, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900337' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'5c864f2a-c513-4c59-a09f-4a507361ae3e', N'nondefiner', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900722' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'5cb95288-e6a9-4471-b36e-aaa1131c4e54', N'umilknięciami', N'pl', 2, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900286' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'5e4c9d5a-50de-4bd8-ab96-8641c82eaba0', N'paracyanogen', N'en', 2, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900422' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'5ebc55db-342e-45cf-87d5-70c000c55b61', N'bephilter', N'en', 3, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900401' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'6090c485-49d6-4028-bae0-b752215fa1b8', N'hematics', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901396' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'61d455b8-afe7-4c6a-872d-bed5dde73a73', N'uległabym', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900988' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'624cf2fa-8f23-4ce1-8ca1-a23a7d6f06a6', N'wyprodukowuję', N'pl', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901474' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'65d0c108-53e9-4780-93ac-e91203bb5869', N'niebaskwilowy', N'pl', 1, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900394' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'6618d84f-cad5-46a7-a712-9e2a05e350a9', N'spirillotropic', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900791' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'66f66227-33bf-4af2-b483-7322a60af684', N'pozakupowanie', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900938' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'671a22c6-c1a7-4f63-90d5-1cd55422d5a5', N'przycioszę', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901361' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'6778dcd9-83e0-40d4-acbc-6ed6312e84bf', N'wymiotowałeś', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900535' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'684aa84a-488e-4893-b8e8-c738bf575502', N'irytujcież', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901375' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'6ad61619-1ed6-432c-9242-f1294b25959b', N'beetleheadedness', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901189' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'6b5adc20-b3ad-4b30-b377-e830b21d2837', N'kleptomaniacal', N'en', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901105' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'6d0680e8-9d76-4bd8-b162-d6f59ed9361b', N'biacetylene', N'en', 2, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900366' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'6d67ab92-ead9-433e-a2d5-0ab9f52e44bd', N'estuarial', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901325' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'6e9980dc-fb03-4688-accb-0692e3669e0c', N'prepigmental', N'en', 3, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900201' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'71120ec8-777f-4027-8df8-b592c170b3d5', N'niefekalnego', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900623' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'71cd1b41-8e7e-48c7-8d8d-4d69620639e7', N'kaleczyłoby', N'pl', 1, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900379' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'7278c38f-efc3-45fe-8598-527b92a117dd', N'wizjonerzy', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900602' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'74bc44e3-5ca3-43f3-a3c1-22ba8d7dce86', N'scourges', N'en', 1, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900465' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'772314f5-a727-4be0-9e08-6f059d17f58e', N'thesmothete', N'en', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900924' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'77ef02f7-0c93-4dba-a6a3-73ec5c9f81be', N'rozprzęgaj', N'pl', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901016' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'78b6011b-6011-4cfd-ba85-5ef0468ea35f', N'reflown', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901303' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'78ee5f59-727d-4f24-b3d0-a7959413f33c', N'aecidiostage', N'en', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901176' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'7ab4921f-ceb0-4236-a3a2-266707b912fe', N'napływaj', N'pl', 1, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900436' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'7ab8d589-258d-4228-a501-89c52b2b1b31', N'prysłaby', N'pl', 3, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900208' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'7ca1dfad-6b4d-43b9-8b07-c4fc95d4b8dc', N'geodetyczni', N'pl', 1, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900029' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'7d909a1c-96f4-48e4-9022-11ca74e9d1cf', N'ekstyrpująca', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900686' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'7ea1ecea-34ab-47a3-8810-0db9d27136e3', N'agamia', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900805' AS DateTime2))
GO
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'7f038d23-d35d-4b53-899f-86bb983d85f2', N'dechy', N'pl', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901196' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'7f35b964-351f-40f8-ad1b-ea747e2a9aa7', N'palatoglossal', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901537' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'7f813af5-70d0-482c-8d33-6576251f8e25', N'roztropnieniem', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900875' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'82336469-7b50-42cb-af50-5dff03a25f32', N'transliterate', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901368' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'829c0b33-ca42-4f60-b9f9-b61eacf7b6ef', N'wykwateruje', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900567' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'83e4c6b6-1cf7-4829-b83f-c3869fb99d57', N'hiperbolizmów', N'pl', 2, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900072' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'88730b67-fcda-4750-a14d-56649250b33b', N'powyrąbywaliśmy', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901120' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'895c6f39-257f-4776-a8d5-37fe79d74648', N'ditheistical', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901056' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'89b92e6e-7b25-4acf-83de-0d99a1e3be6c', N'beachmaster', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901231' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'89e0061a-0070-4e35-a55c-7e4d132e7b45', N'unmotioning', N'en', 3, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900098' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'8b5620b6-afed-42f1-b7d9-7c26f33c78b1', N'roztrącałam', N'pl', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900778' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'8bbf019b-c6b6-463d-a59f-6280533d54ac', N'niemagnetytowi', N'pl', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900854' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'8bc65541-72d4-4593-91d2-c2eba66482c7', N'dimensible', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901091' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'8d64b1a7-fb69-4dea-af84-8828c55d4be4', N'unmeridional', N'en', 3, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900185' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'8dc0e90c-84dd-4064-bce6-84731818510c', N'futraminy', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900736' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'9016d376-af54-4b9f-b551-3e71b7892505', N'niezapożyczanej', N'pl', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900903' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'904467ed-d73d-4195-a0cc-5f8887cdc161', N'pietruszkowym', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901502' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'91892c7a-c442-441f-ba6f-7368f7b23040', N'grieshuckle', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901339' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'93e766ff-f02b-48e6-b128-8c1b55d9c42f', N'imperishability', N'en', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900615' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'93f1f7c3-c207-4651-aeb1-e65d55342509', N'halalcor', N'en', 1, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900493' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'94f1d08e-d128-4262-a86f-77a3937d226f', N'jebanej', N'pl', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900945' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'95827e8b-5633-4c50-a733-e3f4cf372e17', N'zapleśnieję', N'pl', 2, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900241' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'96aca781-ef20-47ed-afc4-403e74a21cf0', N'reflown', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900959' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'97c097b4-1248-4b08-ba61-c5a38ecf4256', N'dimensible', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900868' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'984e7f5c-f36f-4309-87c5-093d568aba9e', N'overraked', N'en', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900545' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'9881d8c1-aa05-4dbd-8661-1c9852c71966', N'chodami', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900701' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'99787542-2eb2-4fa9-b567-858ed6481a15', N'wahałybyśmy', N'pl', 1, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900164' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'9a3d1f42-44a5-4674-9228-ebc6af6c09dd', N'grieshuckle', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901389' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'9d2566e7-4c35-4e92-afe4-b291bedfb386', N'psikniętymi', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901267' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'9d3449bc-4830-4b16-8c0d-002bd0b9df0b', N'niedetencyjnych', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901023' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'9fb158a8-0efc-47c0-9114-b13b1d36b18b', N'nieneopogańskim', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901154' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'a0311cdf-e8c0-4449-8f07-e6bdb41bf393', N'scyt', N'en', 2, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900472' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'a90422c1-dd0d-40a4-99c9-b3d29cc34444', N'ozłacaniami', N'pl', 3, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900479' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'a93f2194-99bf-4aa0-885a-9333dae80915', N'policzalnym', N'pl', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901112' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'aa836c3c-70d5-4ece-8127-f4ea2ffb979a', N'niepapierosowa', N'pl', 1, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900081' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'ad0c87a7-b1a6-487c-b9e5-ce74dad0f9a9', N'niebaskwilowy', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900708' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'ad9e1996-9c89-4c61-b135-9f08aa835d8b', N'circinal', N'en', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900882' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'ae37f2cf-7db2-4fbc-9af0-a747e79db73a', N'reapologies', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900749' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'afa38637-9fed-498d-877d-0aecfd4e710d', N'bikeway', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900514' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'b248b6cf-d820-4081-881c-92b4e98e2e2f', N'tricennial', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901282' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'b5384ef5-478a-408f-b659-2c5f979259d8', N'pstrążkowi', N'pl', 1, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900014' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'b65c8e89-ef00-49fe-b758-957c1202e6b7', N'railroads', N'en', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901078' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'b8359032-c382-4363-ab64-9d283a4ba93f', N'apokatastazę', N'pl', 3, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900499' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'b90a1103-2094-44cc-857c-355ae0d84e1c', N'odrobek', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901460' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'b941e2b0-e368-40fb-b8e0-869181245d28', N'estymowałyby', N'pl', 2, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900387' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'b97ac4ac-abe6-4b59-90e7-c181ee5d9b55', N'plagiaries', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901099' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'bafd58a0-208d-44b3-822f-474fd2ee5951', N'chaparral', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901310' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'bb8eeb12-8e4f-401b-847f-43bcdfbed508', N'mouthroot', N'en', 3, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7899973' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'bc608b88-b675-49b8-875b-4927037d8d74', N'narajacie', N'pl', 3, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900322' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'bf5c60dc-0c66-4dcd-a19f-b2ccc5b66b83', N'odmieniający', N'pl', 3, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900330' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'c17ba17a-4524-4604-b306-90f824902ae7', N'limfokina', N'pl', 3, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900249' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'c2c9037f-74e1-4b21-9772-8b6cd4275526', N'spirillotropic', N'en', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901495' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'c2e53b86-ea47-435c-b7fc-3ff72a155443', N'keech', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901009' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'c5983e4f-6021-4909-b98a-59e5540e75de', N'parrock', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901425' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'c5d990bb-1e34-496b-83da-743298a069db', N'zakrywajcież', N'pl', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900952' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'c5dc9e11-a4f8-48c6-969f-a4bcc8347b99', N'ukwapach', N'pl', 3, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900450' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'c615494f-d5b7-4fad-b695-96c30fb995b6', N'radiomedial', N'en', 1, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900193' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'c62640b4-9012-43b9-8f3d-041a008501f6', N'niewycałowującą', N'pl', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900995' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'c6c22f9d-8ec6-4f64-a40a-00d838a71010', N'imam', N'en', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901084' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'c7269899-a326-41f1-b55b-10fd17540bd6', N'odwiejemy', N'pl', 1, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900038' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'cbbdff6d-8f19-49a4-a703-45d43eefd101', N'łódkowe', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900608' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'cc76083c-5c77-45dd-9c13-452066ad0877', N'parturitions', N'en', 1, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900178' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'ce22af16-9d31-4642-b206-e96cc6d7e0f3', N'apophysate', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900967' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'cec7bdbd-0f1b-4708-b280-31ec38971bb2', N'kesonowało', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901453' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'cf882f66-1160-4b2b-8b91-a3a0a038fec2', N'pokrzywdziłbym', N'pl', 3, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900308' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'cfcc785c-b3b7-433a-a8c7-7ce63aab734c', N'ichthyography', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901346' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'd10fb17e-391f-4d3e-a948-c00482eacd77', N'marblity', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901432' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'd1db1d12-daaf-482a-b8d6-99ee32bafee9', N'łyżwiarskim', N'pl', 1, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900443' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'd2693877-346b-4a75-a11b-008b58b7c164', N'primus', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900658' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'd2dfecd1-4060-49ba-a046-7aad821b199f', N'niekretynowate', N'pl', 3, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900457' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'd5319834-7d9c-4d3f-bfec-50a38d1262ac', N'metaurus', N'en', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901182' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'da3f5e50-1618-4eac-9e1b-5dad82dd2519', N'unlubricating', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901210' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'da652ea6-a671-412f-9e21-f1d0fbf74185', N'counterlighted', N'en', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901030' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'db2ad574-0f44-4e41-a261-eef71adff422', N'exorcised', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900840' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'dc2223ca-83b2-406e-a928-76e4567ab0cf', N'sensationally', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900630' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'ddc78687-712c-47e1-8dec-ba6124f5bbf4', N'groundkeeper', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901245' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'e10f7281-0e2e-46f6-b5f3-b811328fa20d', N'niekobiece', N'pl', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901260' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'e1ca7d08-bcc9-4f85-9782-834db1d69e48', N'beghard', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900896' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'e231f1a8-7c56-402d-bf96-7dee700c05c8', N'pokuciem', N'pl', 2, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900091' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'e28aa984-a016-41be-b3d3-078b5e1345e3', N'śródchrzęstnymi', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900889' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'e28ec349-e24d-4d60-84e7-752fb5fac474', N'okleiłybyśmy', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900594' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'e62374d5-d2a3-4332-90d2-d06ca338de64', N'sturdied', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900664' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'e72140e3-0802-4d1b-85a5-206152dcdeb1', N'niechlejącym', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901217' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'e730b417-2bf3-463b-a163-7b39113b689e', N'ściekowy', N'pl', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900679' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'e81f69bc-775b-42ee-8e33-ac114030d448', N'siklawicom', N'pl', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901070' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'e831db5f-5a24-4b40-a5a2-4510368bb206', N'dobada', N'pl', 2, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900486' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'e88dbadd-607f-4fcf-9463-095ff48613a6', N'holostomate', N'en', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900819' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'e8a43cde-0406-4847-9c2e-dbc79fd73e9b', N'zheblujesz', N'pl', 2, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900351' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'e981c5fa-6919-4dc1-81a0-8d0021ab9c2f', N'surfeiting', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901141' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'ee30c661-54c5-4cba-a2ca-3e1dfb17d53e', N'venoms', N'en', 2, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901289' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f0bb0924-48fd-42bf-8ddd-9141947a75fa', N'namacajmy', N'pl', 3, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900408' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f12f3829-e8f6-4db7-8ac5-c96d9b9727af', N'unweighty', N'en', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901332' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f26a57ba-179a-493a-b1b0-314a3886c684', N'niekajakowaniu', N'pl', 3, CAST(N'2022-02-04T23:23:56.7880000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900047' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f2d68448-6cef-42f8-b355-104a7e1de37e', N'nieudręczająco', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900636' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f6d6c97f-cb2b-4bbb-87d5-c06cd77a15de', N'pateriform', N'en', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900981' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f92a476d-14f7-452a-b25f-908869894c72', N'wytropiono', N'pl', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901410' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'fa36be8e-fe7d-4c29-99c8-d85c62d6e59e', N'niebukowatych', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901049' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'fd56f2cd-48ff-45f5-850e-39db791c1dd4', N'spuria', N'en', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901127' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'fdcb1180-c0f8-4432-a36c-4410a3f129af', N'together', N'en', 3, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7900528' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'fe76467d-54eb-4469-9737-1b8c286c35e2', N'wypłacalność', N'pl', 1, CAST(N'2022-02-04T23:23:56.7890000' AS DateTime2), CAST(N'2022-02-04T23:23:56.7901516' AS DateTime2))
GO
INSERT [dbo].[languages] ([name], [code], [created_at], [updated_at]) VALUES (N'English', N'en', CAST(N'2022-02-04T23:23:53.5410000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5410487' AS DateTime2))
INSERT [dbo].[languages] ([name], [code], [created_at], [updated_at]) VALUES (N'Polski', N'pl', CAST(N'2022-02-04T23:23:53.5410000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5410522' AS DateTime2))
GO
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'008eb6c0-d7a7-4ebf-b128-1d0e65255070', N'$2b$04$pNJ5IbtBUkQg65v282SfsOVx0FKf67RTUDdf3xnJgnTmqhWloUZbi', N'Dino.Cartwright80', N'Cristian75@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109186' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'03d23e9c-c1f2-4497-9d27-f164a101d41b', N'$2b$04$BgBVLVtrukyftq1tJyOz9euuyIjcKndpLRecpoaxSaVNW//f60N5G', N'Shirley_Wunsch0', N'Jamaal_Daugherty21@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109311' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'051e0399-8378-46dc-b0cb-bd60b002286b', N'$2b$04$955Rn6Er81Z7WVBHWjNV2.JLQACa/gUluIj2izeFDEYsDCeTGeSb2', N'Adrienne_Stamm47', N'Ezekiel.Wiza68@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109619' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'06bc2ac4-1ba5-4e68-a7ff-f7181d7b696a', N'$2b$04$8SWB8tQ7cFO0OPv9kLKmEO3VFYUuQ70t6hmYBZVklc/EMpGSefmO2', N'Leon.OConnell96', N'Nova.Parker27@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109027' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'0b5db47b-7b06-4949-bfb7-cd15d80ab5c9', N'$2b$04$tEqRZXU.kTGGPe2F3GsZNenJclp1SvdZThoYzHGGa/KdUqwhBHAsu', N'Amanda0', N'Elyse37@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109439' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'0bcfc380-b2ec-4919-8691-b4866e4f6133', N'$2b$04$1GN0gH.B9cZcWLuuFEoqDuEuoHV58RldaDIg5.g4Hx2dpf/vW9YXS', N'Justus26', N'Brandt.Stoltenberg97@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5108732' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'0c23f819-2c46-43de-ac47-1d6be2242339', N'$2b$04$jp3OkCWo0TqI3F2W4MHAu.d0kYbs0rO6A6IvqVM/dQjS7.EKotEvO', N'Craig_Fritsch69', N'Ewald15@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5108718' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'0cb10800-2fd6-4664-b849-973903be8021', N'$2b$04$Dm7zOiHsOyqI9QHl.kfDxuaUHAwCBkk193jFDTdaU/FYrmLO6l6JW', N'Dortha36', N'Jade60@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109412' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'125a595d-7349-4459-9dec-e7c0c249daf6', N'$2b$04$FcbURX3mp6ZrT3yl6zlkTeKG03WO6GfGg0Ov.ghX8yVm1TNJQYEwG', N'Zane_Wisozk10', N'Russel98@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109405' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'13b76c36-b317-4541-8f77-f66ffdc38fbb', N'$2b$04$PDkLcyWkMI9.GQr7UOv2cetowcLWy7km1DiQA8utlgZ7ryYzBzjOq', N'Kurtis.Cummings25', N'Grayson87@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5108750' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'13cdbae7-7021-4bb7-a5c1-c7785b21291e', N'$2b$04$7VCUy1bKL9Ld6CNjNqd/Tu2LnqtOHeoEvzSQyCEjdCMDjH3QZOpf.', N'Antwon.Runolfsson', N'Emmalee_OHara85@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109151' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'1be1d3ce-c3a2-4b8e-abca-174d6883ac5c', N'$2b$04$XJ7VAOyZVkRhjDxeecq1KeDG7QvbQ4xZUHGilgdSomyMRBHxiJaTO', N'Rafael.Berge', N'Arjun_Hills11@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5108741' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'1ccd2561-39ab-45fb-ba18-053e46700132', N'$2b$04$dQ.yydakN6l9IILkurul6upK7YdkRuit4oGBFFAwCJrR/KZjRlSke', N'Dameon_Yundt', N'Claude87@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109110' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'1d9a60df-2bea-4c10-8e89-0fe9d35954da', N'$2b$04$KJdxX9/mi3jkFkv.15f4Yetp62e0f46Mm9/j06slab9E4e0q2oheW', N'Travon.Kirlin29', N'Arvid.Weimann90@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5108983' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'2041dad2-d4f8-4370-ac7b-d3f33eaf7ba3', N'$2b$04$b.g33gjh0PxFERJ.oMhK7u19k1SaBYuj6OWc9gRoTeoNk4DpUhZb.', N'Aletha_Bauch62', N'Melody40@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109606' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'256b1b1e-aae2-47b1-934b-c442a065a080', N'$2b$04$KcBTnjunWNrHI26F0GAsE./mRItw5vEHKYfeOyh2lVo5RVmIjuGIq', N'Boyd_Metz', N'Vickie41@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109431' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'29f416b6-bf3e-48e3-bc69-7a0efcee0248', N'$2b$04$9a99yzb3neJDh55kteZ5V.LlIyrQFcmsmrGgq8tSN7By4x.oHRRRi', N'Karley_Jast72', N'Aimee45@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109584' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'2abe0043-71bf-4647-a063-26405f88cde7', N'$2b$04$ClgLz8ICG.37FU9N.1jc3.pFVb7G9q2ONs71SYyI0Y7TaNAp5779S', N'Carmen28', N'Lizeth_Berge@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5108975' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'3332ea6c-da0d-434f-9bef-f3c81ec627d7', N'$2b$04$zJbJ6Lw3sEW.RWVfoAc3Gus1RvFULA1.MTe1HWLIBmLR/ZTIZfh1.', N'Thora_Thompson67', N'Kelsie.Wiegand53@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109424' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'389d174d-d3e9-4478-bd91-1733394fef65', N'$2b$04$aYYv9Lf2VQffnbMiP4kRvOpxafpgf3.xtd0AsLUBAjIhGHeSMJA6W', N'Granville54', N'Twila_Krajcik11@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109549' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'4130105a-24e1-41b7-917f-671188d8a4cd', N'$2b$04$yYIOeDAnrHHZj2EPz.RLdeVYnTJj5B0ahSufD1ou27lA.a4S5gNOq', N'Gennaro25', N'Vincenzo_Haag@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109671' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'43a69367-b056-405f-a664-36d459c60753', N'$2b$04$OoytncKSKUuC.NQmizrPLOe2.ZWCpAZGqxNpiAi4f4it1UkJRCcPO', N'King91', N'Dasia95@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109103' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'4583f2f7-df74-41a1-a85c-b6c755bbb1d7', N'$2b$04$5VTCw06geepDCGV23as8ZupQv9AY59aAX4q1UUfcBWzyEtVb520yC', N'Providenci_Hane53', N'Vance38@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109178' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'4a3e90d2-3244-476a-b421-9b7be32688b7', N'$2b$04$/D1a1LZxUkB0Xq.2m9RbPOXqtmh9vxcgMbx5dlVrohNPaROWazLbS', N'Alexys.McCullough', N'Davin_Turcotte@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109218' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'4a8e3317-de72-40d9-b46e-b13bf1dcb5df', N'$2b$04$Scd/5i0.rWc6SDeGvpee9.wyHa4hU8o6xJucILPqyatgaQ4sZTW7e', N'Alexys99', N'Isabell12@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109054' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'4e517100-b24e-4cd4-b280-b0f8c14c86fd', N'$2b$04$RBBtRDWA.dpqYCzmL9jbFuFicuiBbUK14c5pDRQZMUqffmkL2byhe', N'Jennyfer39', N'Karolann85@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109062' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'4f2adedb-722b-4418-ab20-bad685f412bd', N'$2b$04$0nKZ5K.EQU57WaUZEHnS4uT2wW7ZvWBTw1Qp00/zxaQ65Bn3WiYO6', N'Clotilde19', N'Preston_Dietrich@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109556' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'5018189e-0224-4f1f-9d3a-7c15bb02d4d8', N'$2b$04$c0a1dmHpRcMnNz.hlWOpNOQAl75j4p9xtvCgj6O5re8KBTfxNTCqW', N'Fredy.Bogan', N'Justine.Swaniawski13@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109127' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'51df04d7-e523-4335-b20a-7bfdd24ae1c8', N'$2b$04$JrLBYRnbZvoQZKATHvOV2OtZ7Kny2HDCgy.L1dd8UJA62pgGSLxOW', N'Dax.Feeney', N'Camille_Oberbrunner@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109612' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'557216b4-e674-496d-8bb4-5a8f51d766bd', N'$2b$04$4p/jOHkK392ErIN.uIFjr.q2fzc5MwuMXzFzi2K0hr/2Ru4lCevDu', N'Christophe_Romaguera', N'Candice.Wehner27@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109563' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'5aea0816-d4d6-4d1a-b7e7-bf0ffdb8f64e', N'$2b$04$I6NeuXiCNqEg0JvLye3jJ.df43JGEf6F/zrrkE2TByR/H0KkFPP7i', N'Cade.Cole50', N'Gwen_Shanahan@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5108708' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'5d819a6f-e9e9-4560-9d08-eed15fdb8c50', N'$2b$04$pxdzslETq.DHLAGn1AxSiOH139IgLdXuiRn..BPhX3TlczySUZwJe', N'Dakota94', N'Arielle_Carroll@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109319' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'60b4e35f-4af8-4c39-8959-d263504c144c', N'$2b$04$qeFhFovI1xOZUJ6PoSsLweW4TFLoeXGDjvLb7rOhDXlbFDZaOaap6', N'Ericka_Skiles', N'Conner.Schumm@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109470' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'613f9c48-1536-4a01-a97c-825f93bf11a4', N'$2b$04$aSvDKYr1cCMfj6YGsvh15eepzLwAK7mFnJ1g96/q3eSfjWi9/kR8O', N'Reginald83', N'Keshaun.OKeefe@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109226' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'61c15ab1-f86d-4609-a4e9-c2aa60502ca5', N'$2b$04$9iCtP4aEEoRHrFN0GjrWWe4F1QT6xbR9l8q6.F5hZyiH9AUHrWvx6', N'Jed_Shields2', N'Willie_Ziemann45@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109087' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'62205832-25cb-4063-b3e1-9d9fdee7b0d0', N'$2b$04$z64TkYe2fnRFLPQ//ponouTBTIl4TA7efrzOFn8ZpIjwF3dzD7mOC', N'Tremaine65', N'Constance43@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109642' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'63dfa5e2-1fe7-4c86-a65f-60158ed3b051', N'$2b$04$UkhDSi..iFFVBaM34rW2t.O/t46hRV876QVqQfPDFGhl5Q9752yGa', N'Ryann.Bogisich15', N'Khalil.Maggio@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109326' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'698b27a2-78d5-4d6b-a189-baccfc00786b', N'$2b$04$nMQcsTVbRwktC290hXcKtOKA1zRgTHV1TrHFPGD.zQi0bmB0duJcq', N'Angel_Lowe58', N'Valentin.Okuneva58@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109571' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'6b954cb7-99e0-4e04-abc6-37b4748eb19f', N'$2b$04$yeBCT2T/Oz4fOE45Gmp8SOzn5yI9aFZWQvMDBjNMeq1eturd2IPOO', N'Deanna_Turner', N'Natasha99@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109598' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'6bbb6e1c-23ea-453f-8654-1e800896b147', N'$2b$04$8K9TubiZXbg6v1HWP9MESOU04WjcmBBd3jZ8Aan6mvM8cgjdEKkW2', N'Weston.Stoltenberg', N'Gavin_Lehner34@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5108725' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'728519c3-3136-40b7-bfb9-561a50bc4ebd', N'$2b$04$I6Mx/e24ZK6Hje27Jx/7euG2ZWwddnDjZ69YKJc1oBIYMfA8TVt5e', N'Clara_Nikolaus', N'Clotilde.Bernhard98@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109391' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'73070ab0-053a-4f45-8569-6e1ceaea9f02', N'$2b$04$5u0pXjfpJMf3toLCsJn97eGnwmnfbch0k9zADSOjhP89Q9z9iZ6ie', N'Alisha_Fritsch68', N'Kaley.Paucek@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109514' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'744dea72-c59a-4785-ab1b-8f627c6901bf', N'$2b$04$FfmsSyFP9428017sXjCBFe2sB6QawkPEq8Nx6aHy1VeWuMdhw9rEm', N'Alek_Keebler95', N'Woodrow_Ferry@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109304' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'7912de18-3416-478c-b390-467b0e63c156', N'$2b$04$tsVAu8J56njXqC8xqqf9OuQVQRiuvRKYVv2AQsESW.BGe0rUqAD6K', N'Phyllis_Armstrong', N'Leland.Ratke68@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5108992' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'7bf154bb-8053-474f-acce-9ab5967fd6b9', N'$2b$04$cax7oyyR2b7nIhpQ0KPju.yqZYT/F0/ooErmzlQun5UvffBEIMqZS', N'Madaline78', N'Kristina45@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109656' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'7d046d6d-7062-4866-9260-537e4da79c62', N'$2b$04$HlFycsqfmO2TjfP8Vm1IBOhqU8wgZ4Op5NouPgO7lhQr/CzgwBZK.', N'Nikko.Smith10', N'Christop53@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109521' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'7eee710e-69a3-4336-a4be-3ae262fbd4d8', N'$2b$04$I4HYOPf7uA1kdjOpVE8aGex/mdv4SHbb0tKcq5pkwMZ.x8ch70slC', N'Rashad40', N'Jeffrey_Welch67@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109542' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'81774506-a3cc-4fa2-98bc-8e2452eaca04', N'$2b$04$UnduMSB.ODt.sm6BId4pAer45SjKeepUkA0EWCFwBMjmOQaE5FTNe', N'Amos.Bauch77', N'Selmer.Rosenbaum@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109363' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'89223031-6580-4ebd-92a7-6fcb09c9ca0b', N'$2b$04$eeyalft9ZrY7m4UMh24FP.1N5fLvJwAsyMzZ6Gpleag.ne3Gc7tte', N'Malika50', N'Anastasia.Russel91@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109454' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'915df36a-1dfe-429a-87c4-cc2ffaa6309e', N'$2b$04$guejQGCGDwmRUp3Dg.06O.Riv22J5OB9DXjn9lKLKlSLaCUodfTxS', N'Reagan_Wilderman', N'Elsie3@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109578' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'93205c1d-0cde-42e8-bd37-ab5a09123c72', N'$2b$04$MqI1qz.FNrNw3hA9Xa8WCehuvOQs7LvL0OjV62OHyWWnhcODvaRWW', N'Marjolaine22', N'Kayden87@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109274' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'972ebecb-b6e1-4d35-8ff6-ba321cca8419', N'$2b$04$74mkfvX1XJ4WRI2l1YQlx.3RsNWw0.vVhwyOfNFEvPiqbg2VtUu2y', N'Leopold.Kirlin32', N'Antone42@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5108765' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'9c5f4e32-89e6-4cbe-8fc0-a089b77bab8f', N'$2b$04$eclAh2/4Pz8u6FYui8CwleFNmbVFyHR62hfUshVgez837kHL9H/7m', N'Ollie3', N'Sabrina.Stiedemann@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109167' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'a0a4fc87-851a-4eff-9c4a-c5b948038a22', N'$2b$04$l9XpZGgSlfbJMnamFI4KY.c2c9ZbfRHsSuJSyWqHOKqNjMEqbaXxC', N'Tommie.Jast', N'Norma93@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109134' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'a11bc457-0ab4-4533-a95d-7c8e6918e7d4', N'$2b$04$FwPV88otRlPYUL3.kmlgbeoxIAbfFls5bCChNXenvn.9YeYlxuom.', N'Lavina_Cronin', N'Melvina.Kovacek94@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109119' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'a5f8fbce-b34a-4634-b882-d8e2c2f79b34', N'$2b$04$5zXHgaQ4HYX8ytDJ4IPhiukvluCvYsF8B30A4Zorqqlsj5diWMML6', N'Heidi59', N'Alessandra.Mann@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109242' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'a6230e58-5fa7-48ad-bf00-3480e00792f5', N'$2b$04$a1favr8jHvea7pLGUvr7EOxnEBppYFB3ZaPoFY0NL0EqhyQs4y9UC', N'Eleonore.Runte', N'Melvina.Runolfsdottir@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109649' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'a8760359-6d60-490c-b036-c762e90c4eb9', N'$2b$04$2jtmErM4KNoAOS.TmEJdk.rS3OYTNXiB9CGDcwxcPMGE0LTMf9RJS', N'Kenya.Corwin6', N'Milton93@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109377' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'aa92e8c2-a045-4be2-b686-97b7b50864cd', N'$2b$04$WbCtahJ1/HoC4o.iQQmyn.mGUGNUJaU/wvd4xD2IdGe/B.pJQ5w1G', N'Vernie_Witting', N'Kamryn39@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109500' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'aab181cc-8188-46f1-80da-cccefc128553', N'$2b$04$9aFeCFoWB62KEki6vc1.Tu3PJ2YOpTA4fKxMJpmIxAYFSExfXdpjO', N'Wyatt.Flatley48', N'Megane_Pfannerstill@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109234' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'aba31de6-9407-4169-b316-058f860dc4b4', N'$2b$04$vrBeUIaTpSpIiSAwI2XQ9.YP/h9DZR6Ls2QcHSygR1qNs/UBfZg8K', N'Adam_Bradtke61', N'Sven_Bashirian65@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109001' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'acb302ea-6a6b-4ab8-a193-7ddf21e4a45c', N'$2b$04$bRW.EQuqZjhjgbcA1ewf.OapakPZKVgpGpuqqYaiussdPXHrQvOl2', N'Jacinthe13', N'Tom.Windler47@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109384' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'ad366928-a9a8-46a4-83df-35bf48e1fb22', N'$2b$04$Mavt.aTgkxwcw8Y9Wrl5IOE6GSBxuoTfaya56qynEr/dtN1VyaG8O', N'Cassandre.Abernathy', N'Fannie_Runolfsdottir59@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109333' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'b08aafb8-1343-467c-aa38-7f2529d96f4e', N'$2b$04$bEWh88AQAzwkEKUzBlOk1uWp9f2JPMih4.G9UXrrxyLmhYIH5NVdi', N'Kelvin.Schaefer28', N'Mollie37@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109493' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'b4b15614-7aca-44a3-b046-f5fbfaf6db36', N'$2b$04$q.VuyMtUbpvVoLNrdjUh5.2OYlluGwX9aGjbmOPbH7zKHQ4DAOt0W', N'Augustine32', N'Katrine.Hansen43@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109143' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'b57a33b0-797e-465e-839f-82077880afd2', N'$2b$04$FnbzO0JVTxWSWxGZsepnfOxgyjQIsFU1/Omdxms.MiVijdylut97u', N'Sarina.Goodwin', N'Hermina_Kovacek99@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109289' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'b6bfe6e8-dc34-4fa7-b79e-ad8bc715fb66', N'$2b$04$5e6DRH1CaiZWbpO6b035..vkFP0ernlMGZbdLQ4rXKOvARV0PaJ0m', N'Tremayne16', N'Theresia_Schaefer94@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5108655' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'b6d3c418-4096-4e82-a91b-86517f43fbb5', N'$2b$04$PrbfWen715NAvkfcblNX1e/wvejVGvuh3BKwsQjC77SgOkTg.YsYi', N'Gillian_Rippin25', N'Jailyn51@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109095' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'b78d69ea-1308-414e-acb0-b539b35ff945', N'$2b$04$m.P/maYqPx7ovIi/VRhs3ubxVL1PsfQK5F0dvjIiJCTwiMQrN2eea', N'Cayla31', N'Heather.Rempel26@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109462' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'ba71b4f2-c6d3-4efe-8c80-e41317f11c49', N'$2b$04$GrClxreUlmMB2X.xUwgohO/1375zSa9st3N2WfYRm8l6K8ToWjLX2', N'Drew.Crist', N'Narciso.Bergstrom71@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109266' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'bc313b26-188f-4d90-acc1-473e4a11a8ab', N'$2b$04$nLaSg89MGPYTrsBJuOPIKeuCaXTCIXhFdJQ5MQTTW3QfF34pktOjC', N'Addison_Koepp37', N'Roberto_Baumbach@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109281' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'be97d7b3-a39e-420c-93c1-9df4bfd436cb', N'$2b$04$ttAW2KkijOjUoFScJ5MtSunmoZcdOqgSFnwhyLm7RerZi/ac2G89O', N'Anais.Bashirian81', N'Martin17@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109507' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'bf646c28-ff89-4eb6-ad49-651d79aabc6f', N'$2b$04$2.G2dPIx/C6suAWmCJLLieCAfxQgiw3zHDfReB2YmT/oNgA9aUJxK', N'Laura_Weber', N'Eldridge_Bartell10@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109079' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'c379fc7a-0dae-425d-8df5-99b41cc6c255', N'$2b$04$yavHpmrkIMk2wYIqba6xve1ZrkutrFlIBOySayn9ID5ZBpqHCr8Tu', N'Frankie53', N'Carmella24@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109486' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'c3f12149-9380-48f0-b770-aa83d8cf528a', N'$2b$04$t0LA1KFop0y1pUkTLI4VTOOK6Y3cEdoHNeEEYi.YwoPy/nWqr9B6C', N'Dessie_Schoen', N'Tyree_Heathcote@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109046' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'c509dffb-e04d-479f-81d8-0bf58fcbe593', N'$2b$04$GlQOPnhz5jkSWq0xBmjpKOxmwg589yA7zACM3DbEc9gNzUiUdLNUK', N'Buddy.Dickens', N'Yasmeen_Nienow@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109478' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'c75684e6-5a47-4330-8bde-1a99b417e809', N'$2b$04$IqDbHFPwFj4OHWhoI0XcZO86eKaxuG/BbZidPrqwuIDpKoEh1iR6.', N'Vincenza.Thompson77', N'Zita71@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109194' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'd220e6cc-3dc9-4cd4-8732-f603c0b46e9e', N'$2b$04$6hozdtVvwyFCvjcQuyY7C.B7T.JAvFEIf9sr3erX8f8cknYFMC9QO', N'Eladio77', N'Arturo_Weissnat43@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109257' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'd316a1f4-3c3b-440f-98f1-ee85e8647e3c', N'$2b$04$2j7BSFT/iJYx92K3pus5aO2Oj1QafkXccmlmQjOW3EE9ysVkqBrEy', N'Myrtie_Bins93', N'Reba_Hauck4@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109399' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'd38c847c-33d1-4530-b014-ccad50e60866', N'$2b$04$330b99ZkKGCCAh.6uGjU7OZPd7l.IAbKZ0D/cIwZzsOWRtg7ZX6aa', N'Favian_Willms60', N'Eliane_McClure@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109297' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'd61ecea9-186a-430b-9799-2405d7284f8b', N'$2b$04$TgTmrbIxrsPfGm3698qZfO.Xbe6mF6C5gtGCi26zMnYK.8r5tw6gK', N'Loyal46', N'Clemens.Hoppe@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109447' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'd632112f-3364-4d51-b6f5-ef06929969f0', N'$2b$04$7SFRcJUmenci1lvedbAqfuKMr2NFxaepzyv2W3DL0HgaAwy/JS0g6', N'Justyn.Boyer94', N'Cecilia_Ratke55@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109019' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'd68eb68d-2ba1-473d-842e-efa9737cb4fa', N'$2b$04$Z7Bxd8SFJj0P2mIikQLpEO6lAd6lLyQvZjapEHap.FEIVHvv5Jn7m', N'Krystina.Cruickshank4', N'Vivienne61@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109663' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'd961faf8-26a5-4785-8965-c043f64ac1f5', N'$2b$04$id6B.2ODSpFgF.s45IphRufyxsVidZyggczAqkj.94V5ps8JUt/wO', N'Pedro.Miller71', N'Athena.Ortiz15@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109356' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'd9c6aa61-a901-4273-8c9b-1db89a9a3352', N'$2b$04$0.KNGZYV9aOCmVs9p.6B6O9nV2.DvWmBpKr40D38gNMAf2sqEMxaC', N'Elian_Grant0', N'Rahsaan78@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109592' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'da15904a-934a-4531-95d2-b7369ecd4090', N'$2b$04$yIy7eOP/jj7.XyMVLBGwJek.hm07kKCj2O4Wdmohuwc31bC0uxPg6', N'Ivory.Moen56', N'Roy.Strosin88@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109036' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'da90e20f-f35f-4fb5-a6ac-1e20120f4860', N'$2b$04$0oVdSmkIwbuOqrF4ZhvsseUi0bNivsdjvjz4zj6whQINMtVNqgXRq', N'Jeffery_Boyer17', N'Darwin93@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109370' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'dcb267e6-009f-40ac-971c-5ccfc5409e7e', N'$2b$04$EIs7KG7ToX2AhqfmD12DHuw6G5LCZwebZLokS.Rdx2ab3RFMSYQUe', N'Ferne.Wiegand80', N'Annabel_Zemlak73@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109009' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'e0abba51-2767-4e84-85c8-24bddc905ba5', N'$2b$04$ttTdmtR08a07jQaQZSYzFOHcRB2VmVv3JX9jeOcD2vqRKb/A6qtwS', N'Kaycee.Hackett54', N'Nya_MacGyver88@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5108758' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'e0ee2283-5701-49be-80d5-e2e83c3f42b4', N'$2b$04$9.dLJe9fqK8XDgR3acnEwOyNSUkAgY/W68uxe86Vj.RvT4N.aXfjC', N'Fernando_Kiehn', N'Camilla_Nitzsche18@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109159' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'e120f98d-d18d-43a9-9bed-a4118d247410', N'$2b$04$z1hqrF/QFAYi0/cY4nvSZO2KHlSZgANdiMApx9vRPM10P/vj1j.6G', N'Lucious.Harvey', N'Michaela_Wilderman9@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109341' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'ed565ee9-eef5-4a57-8c42-f43743ec7cda', N'$2b$04$F9wAUG8shVZmOuxvvf4HeeHAQeVmElQreNQbtrgY/2vp.vFlYNbmG', N'Lucy53', N'Margaret_Stracke32@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109348' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'ef631367-7def-4d0f-8ff9-02a77169efe7', N'$2b$04$UkneyVtmkHzPfG/h1HobV.Dg7EMhP6NJY.Ex9m00ajMeP13Hh712i', N'Madge_Brakus', N'Mohammad_Kshlerin66@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109528' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'f4ee5537-b6eb-4254-b6ea-922686ea81ff', N'$2b$04$WT5VuruPY7mH8EL4nWlXZ.7qyYm9hUAfcZ21MHa3Z0XbfpKJyDyBC', N'John.Wiza', N'Cordia_Berge84@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109202' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'f7f36710-89a0-4f7f-806e-d0d6b070a4bd', N'$2b$04$7zU8z2K/K7/vjWvod4rlJeI9JkSMgDkgf57OGGIMvU0p2gSwYSbnK', N'Coy_Smitham19', N'Lamar15@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109210' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'f9174142-9a18-4ffc-a25e-7053c376e39d', N'$2b$04$AYsifso7jvoXCbPtwRlVz.bcVznRxHFT57PVvVuf17/F4niOYVTeW', N'Ward_Erdman', N'Cecil.Mayer@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109070' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'fa6649f7-2e06-4689-a994-5f89251ffc79', N'$2b$04$GPOpwJIKiuCiFZ3RJhSjsuZNUEAY.Xr3mu76o5bD9562k958QpOJW', N'Guillermo_Shields16', N'Santiago.Ernser@yahoo.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109634' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'fbae442c-6f4d-4b79-9583-9fe1c931fc65', N'$2b$04$UxMcN4yf0STrRYB//z80COP0N0jOwe3FE2I0fSCnMaDjpjpIkqdVK', N'Eve.Lind', N'Alta62@gmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109535' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'fc91f5c7-229f-498e-b2dd-ad2f2d97621d', N'$2b$04$GgWiy3ShIUEC59hiAulLz.SNro1WCeQRIjJeFp5HxMKfH4XSpCbzm', N'Ressie_OReilly79', N'Amanda84@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109626' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'ff44f99e-fce2-4c71-a0be-0b626354aaba', N'$2b$04$DQo2R1oJalI7inlo7r3C3O08xQmv39RaspsGFCcg2h2vHuuxcEygS', N'Aracely.Gerlach', N'Jonathon_Wilkinson72@hotmail.com', CAST(N'2022-02-04T23:23:53.5100000' AS DateTime2), CAST(N'2022-02-04T23:23:53.5109249' AS DateTime2))
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'x', 2, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bola', 4, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'czym', 4, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'deb', 4, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hon', 4, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'iou', 4, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tef', 4, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uti', 4, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'aion', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'amay', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'arri', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bons', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cace', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dechy', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dict', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'erer', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ginn', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hebdu', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'imam', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kbar', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kiki', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kupra', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lect', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'leng', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lent', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'napu', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'narw', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nold', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'oats', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pojeb', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reen', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rocku', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rubs', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'scow', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'scyt', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'seba', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'serb', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sorus', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tężca', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'toho', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tymfy', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wush', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'aevum', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'agamia', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'aired', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'aminki', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'arrau', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'basic', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'calic', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'canli', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'canty', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ciągał', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cieszą', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cigar', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'civil', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'colds', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'curer', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cynara', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dobada', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'donny', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'femur', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'humid', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kaneh', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'keech', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kłujkę', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'linami', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lipse', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lutao', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mobby', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'modłom', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nagnać', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'newly', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nosiło', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'obstoi', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odmyję', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odważę', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'opakuj', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ozanów', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pesky', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'płaksą', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'poove', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prana', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prostu', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pyres', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reeve', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rooti', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rwaczy', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'scalz', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'senam', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'seral', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'shole', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sises', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'slope', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'slush', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spars', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'stash', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tandy', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ulmic', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'vista', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'vivos', 6, N'en')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wheem', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wizuję', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wynds', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zwęźże', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'abysms', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'alexia', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ascher', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'aucuba', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'barile', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bawler', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bidpai', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'borean', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bullae', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bumpsy', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cabots', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'calces', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'calesa', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'censer', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chodami', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cleave', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'clever', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cnicus', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'codium', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'coroll', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cotyla', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'coupee', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'curlew', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'darnel', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'darryl', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'diademy', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dipygi', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dumose', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dungol', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'edital', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'elanet', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'empasm', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'encoop', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ethics', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'falter', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fascet', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fellas', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fogies', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'galops', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gander', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ganefs', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'girlsom', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gładząc', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'górnicą', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'groyne', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gurdle', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hidage', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hirtch', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hurtowi', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hyoids', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'impart', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'inisle', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'jebanej', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'klangor', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'krewili', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'krupcom', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lading', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lapsed', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'łódkowe', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lunate', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'łysieje', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'magodie', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'marree', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'merger', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'moczmyż', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'munster', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'muscae', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nagabną', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'natłuką', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nerita', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odrobek', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odsieli', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'omarzli', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'orlage', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pacnęła', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'paying', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'petate', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pialyn', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ponękać', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'powiłaś', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'primus', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'psotach', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pucówka', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rakery', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ramnozy', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'redder', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'retake', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rinner', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'różnymi', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rubato', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ryfejów', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'scribe', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'scruft', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'septet', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'snapps', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sondes', 7, N'en')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spuria', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'stimes', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'świadku', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'szaleję', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'trącisz', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tubate', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'twyers', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unfond', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uppish', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'urchin', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'urokami', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'usednt', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'vacual', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'venoms', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'warman', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'warryn', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'włamcie', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'worded', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'żachnął', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zakasze', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zakresu', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'załammy', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'żarnowe', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zasyceń', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaznane', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'żbiczym', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zgadnąć', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zgrabię', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zlatała', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'znawozi', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zyryan', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'alphyls', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'analizuj', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'arcadia', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'arsenal', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'arsoite', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'assails', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'azuline', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'barciach', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'beghard', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bekieszą', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'besaile', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bikeway', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'blinter', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'boikenom', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bordunom', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'brabble', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'braszpil', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'brzytwom', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'burglar', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bursalni', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bystrzom', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'capreol', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'caradoc', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'casheen', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cebulowi', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'censual', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chazzan', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chlupmyż', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ciliola', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cinerin', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'connach', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'coquito', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cordeau', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cotinus', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'crengle', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cystose', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'darniaka', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dawting', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'deliver', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dibbuks', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dismark', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'drissel', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dwuczuba', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'emphase', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'enecate', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'epifitia', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'estevin', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fairily', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'farfara', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fielded', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fizzles', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'flankiem', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fotofoby', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'foziest', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gonadal', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'guarachy', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'guardee', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'guerille', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hadrons', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hattize', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hetmanów', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'highway', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'illbred', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'impends', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'inlying', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'intones', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'jezydzie', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kapelany', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kefirkom', 8, N'pl')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'khalifs', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kirundi', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kitabis', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'komarowe', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kompleta', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kredytów', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lapeler', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'legator', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'łepeczku', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'leptera', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'logiest', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'luxuria', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mangoes', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'marblity', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'markhor', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mascons', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'medimno', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mięchami', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'miksując', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'milenami', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'monkism', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'murgavi', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'myrcene', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'naphtol', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'napływaj', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nektons', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nunataka', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'objedźże', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'oblasts', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'obskoków', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odważają', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ojcujmyż', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'okserami', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'omijania', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'oomiaks', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ootwith', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'orantes', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'outfast', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'outpurl', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'paiwari', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'parrock', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'patarin', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pechili', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'peropod', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pierces', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'piggins', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pilotuję', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'placers', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pociecho', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podatus', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podgląda', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pokuciem', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'półfinał', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ponzite', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'porfirów', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'porzućmy', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'posmażmy', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pouchyla', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prósząca', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prysłaby', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przytocz', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'puerile', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pythium', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'quizzes', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rajidae', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'recenzyj', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reflown', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reunify', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rooster', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rosetty', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozginaj', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rubbing', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'saltman', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sassily', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ściekowy', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ścinkowi', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ścisłego', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sedesowi', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'seizins', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'serwujmy', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sharply', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'siurkach', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'śledzisz', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'snycerka', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sparsim', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'squills', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sunland', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'teapoys', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ternary', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'theeked', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'threaps', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'thugged', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'trombiną', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'twelfth', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ukiszony', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ukwapach', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unfatty', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unsappy', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unyoked', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'upshear', 8, N'en')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'urinose', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'usychają', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'vincula', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wabbles', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'washoff', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wawling', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'whussle', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wickiup', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wnikania', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wsadziło', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wypławił', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'yatigan', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zakrętkę', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaświatu', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zasycaną', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zawiałem', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zeolitów', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'żgałabyś', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'żgaliśmy', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zonules', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'adnotacjo', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'alarmism', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'aliantach', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'amebowaty', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'analgene', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'annexion', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'archipin', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'avouched', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'balneary', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'barretry', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bazgrałem', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bearwort', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'beelines', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'besquirt', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'betangle', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'britzkas', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'brzydziło', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'buhlwork', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cameleon', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'carboloy', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'centring', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'challiho', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chaparral', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'charivan', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'charonic', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chilopod', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chivaree', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ciconine', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'circinal', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'classing', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cohesion', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'coniform', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cordovan', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cośrodowe', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'courtier', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cremorne', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'crescendu', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'czapeczek', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'debugger', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'decating', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'desugars', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'devotion', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'diaczkiem', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dimeters', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dioninami', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dokręcono', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dokwitłem', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dozbrajań', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'drażliwcu', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'drinkery', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dziwakiem', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'elamitic', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'elemisami', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'eloigner', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'enceinte', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'equivote', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'etylowano', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'excerpta', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'exsolved', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'familiami', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'faraonowi', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'feastraw', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fleckled', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'foreguts', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'frezowali', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'furculae', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'futraminy', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gesnerad', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gofrowała', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'halalcor', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hartleyem', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hematics', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hircarra', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hopthumb', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hornwood', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'houghite', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hybodont', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'illuvium', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'imponując', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'innatism', 9, N'en')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kabulskim', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kalamicie', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kaolines', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kaperowań', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kasarkami', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kiełkował', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kłopotała', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kręgowcem', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kwarciani', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kyanizes', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'laborage', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lazarets', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'leniency', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'leucones', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'leverman', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'limfokina', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'longlick', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mahuangs', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mantykorą', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'maravedi', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'metaurus', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mięsistym', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mijnheer', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'millcake', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'minibike', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mitering', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'muchacho', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mudpuppy', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mudstone', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'muirfowl', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'myokymia', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'myriadly', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nacięłoby', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nadwątlam', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'namacajmy', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'narajacie', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'neocenzur', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebodąca', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebrocki', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niekarscy', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonguilt', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonquota', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odmarznąć', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odświeżać', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odwiejemy', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'okopywało', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'opalałaby', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'orszańska', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'outstank', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overbody', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overhang', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'oźrebcież', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'palliser', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pellucid', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'picunche', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'piętrzoną', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podlepiać', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podłożyło', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'polaronom', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'południku', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pooplataj', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'poparzymy', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'posolicie', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'powering', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przyłęcką', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'quantify', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rasamala', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'redemise', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'redyeing', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'refusive', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'renumber', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'robiłabym', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'roccella', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rockmanek', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozorania', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozpałkom', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozważona', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rzeźniczą', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sabaeism', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sagownica', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'scourges', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sedanier', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sędziwszą', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'semickich', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'shoother', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sideless', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sierpówek', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'skiplane', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'skittled', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'skłębiała', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'snigging', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'soplowate', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spoonily', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'stoneman', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'strząchań', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sturdied', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'subtlety', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'swimmier', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'szafujące', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tessella', 9, N'en')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tickless', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'toadless', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'together', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'torchere', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'trynknęło', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uległabym', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ulicówkom', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unclamps', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uptrends', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'utrząśnie', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'vietminh', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'vildness', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'violence', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'vocality', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'warownych', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wegetując', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wełenkami', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wełnicami', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wenchman', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wirydonem', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wooziest', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wspinaniu', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wygubione', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyklinano', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wykonalną', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wykurwimy', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyłamujmy', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wymamioną', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wymywacie', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wypychają', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wysiąkano', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wywróżyły', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyżywiani', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zagładźże', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zakupicie', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaoponuje', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaprzątań', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zapudłują', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zastukocę', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaszczani', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zatajanie', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zeswatała', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ziomalowi', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zmałpowań', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'znaglajmy', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'znikające', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zwinęłyby', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'absentees', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'acetanion', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'agentries', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'alimented', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'antinovel', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'arbuscles', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'arthurian', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'aspirantkę', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'astrachan', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'attestant', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'auspicate', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'autentysta', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bajzlowały', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'banitujcie', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'barakowymi', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bastowanie', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bechtającą', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'beenowskie', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'begrudged', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bephilter', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bepicture', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'biedactwie', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bindownico', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'błękitnymi', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'brantness', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'breaching', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'brotheler', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'brzmiałbyś', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'burdeners', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'casthouse', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ceaseless', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cesarczyka', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chajderami', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chapbooks', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chumashan', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cliffside', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'clubhouse', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'coadamite', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'colonised', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'convented', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cordately', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'coverside', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cusparine', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ćwiekaczom', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'defiladed', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dirtboard', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ditchside', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'doholujcie', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dolomickie', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dotłoczoną', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dragonism', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'drizzling', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dwikoskich', 10, N'pl')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ecuadoran', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'eirenarch', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'endorsees', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'engorging', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'eruciform', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'erythrism', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'estuarial', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'evolutoid', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'exorcised', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'exosmotic', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'farsiarzom', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'figlarność', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fistnotes', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fizykalizm', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'foliolate', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'footfault', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'forespent', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gadkujcież', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gałęziastą', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'galliform', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'garmented', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'globulins', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'graveling', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'grawiurach', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hackamore', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'haliczanin', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hieracite', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'inquirent', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'internistą', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'iphigenia', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'irytujcież', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'isoaurore', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ivoriness', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'jodowanego', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kamerowany', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kantowałam', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kartoflarń', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kawomatach', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kersantytu', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kesonowało', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'klendusic', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'klezmerski', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'klikniętym', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'komutujesz', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lacewoman', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lapponian', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lebrancho', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'litholyte', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'louringly', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'maestosos', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'majtnięciu', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'matmaking', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'megampere', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'melodized', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'meteorycie', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ministruje', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mouthroot', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mózgownicę', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'muensters', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nadpalałam', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nadpisywań', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'naklepanie', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'napiętniku', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'narrowing', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'narwałyśmy', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nasuniętej', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'naszczekań', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'naszywałem', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'natrolicie', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nawlekajże', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'naziębiłam', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebromawe', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niecisnącą', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niedopałku', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niekobiece', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nielodzące', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieomiatań', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nietułacka', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieumarzłą', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nightgale', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ninhydrin', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'noncoring', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonfluids', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odgarniano', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odmalowuje', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'oplątujcie', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'orbicular', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ostracods', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ostygnęłaś', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'otrzewnymi', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'outbeggar', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'outmating', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'outstroke', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overloves', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overraked', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overspins', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overwarms', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'paliczkowa', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'paralinin', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'parameric', 10, N'en')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pedagogal', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pemmicans', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pepperbox', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'phellonic', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pleonasms', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podejrzysz', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pogujących', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pokiwałbyś', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'poobciągań', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'poobłupują', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'poodkurzań', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'portholes', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'posttests', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'potaknąłem', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pożarskimi', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pozużywało', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prayingly', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'presaying', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'probating', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przerzedłe', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przesoleni', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przycioszę', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'psoceniami', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pstrążkowi', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pterofagią', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'puppetdom', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pyelotomy', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pyrgnęłyby', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'quinovate', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'quinquino', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'racketier', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'railroads', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'redissect', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'registrer', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'revocandi', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozkułacza', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozmażecie', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozplatasz', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozprzęgaj', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozwikłały', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rzęsistszy', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sargassos', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sclerosis', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'scrapable', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'seamounts', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'serowarami', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sharpshin', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'shielding', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'shydepoke', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'siklawicom', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'skepsises', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sklepiałeś', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'snobbiest', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'soldiered', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'solipsysta', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spropaguję', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spulchnieć', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'stalinite', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'steapsins', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'steellike', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'steersmen', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'strongyls', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'stumplike', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'suberynach', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'subsystem', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'subtectal', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'synergism', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'szambowego', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tamowanemu', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'thyridial', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tłoczeniem', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'trihydric', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ubarwiaczy', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ukartujemy', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ułatwiajże', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uncapable', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'undeciman', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'underripe', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unrefined', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unresumed', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unweighty', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'utylitarna', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'vandalism', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'venenific', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'virgilism', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wagonowych', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'warknęłyby', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wdzydzkich', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'werbowałem', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wgarniania', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wieczorków', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wilgotnawo', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'williwaus', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wizjonerzy', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wybawiłoby', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wybrzydzać', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wydeptujmy', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wydukanych', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyepilujmy', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyrżniętym', 10, N'pl')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyśmignęli', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wytrapiały', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wytropiono', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zakatowali', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zalęgnięty', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zamęczyłem', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zampolitem', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zbogaciłeś', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zgłaszanie', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zheblujesz', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zmydlanymi', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zohydzenia', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zrównywała', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zwlekałyby', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zwyższyłby', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'abortional', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'absurdalnym', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'alabastron', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'allochthon', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'alveolitis', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'antimasker', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'antiselene', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'antypasatom', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'apophysate', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'aquaplaner', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'arizońskich', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'attirement', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'awansowałaś', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'badgerweed', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'basketries', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'besplatter', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bilionowego', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'blackheads', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'botcheries', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'brahmsowski', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'brassavola', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'breakpoint', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'buddhology', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bumsucking', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bzdęgoleniu', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'carpetwork', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'castellany', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cercocebus', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chaiseless', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chirruping', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'choucroute', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cinematize', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'clabbering', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'collations', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'collecting', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'contradict', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'crocheting', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cynipidous', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cystometer', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'decernment', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'decigramme', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dekorujcież', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dilucidate', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dimensible', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dimeryzacją', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dingthrift', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dogęszczono', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'doginałyśmy', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dostrajałem', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'doszukaniem', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dotruwaliby', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'durational', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dynastidan', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dysonansowy', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'economiser', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'elasticity', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'encrusting', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'epiplasmic', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'equinities', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'felietonami', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fetography', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'foliałowemu', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fourbagger', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fricandoes', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'galivanted', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'geodetyczni', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'glottology', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gluttonous', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'handleable', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hemimorphy', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hippodamia', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hollyhocks', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'insultable', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'interblent', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'involucred', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'jaśniepanie', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kaleczyłoby', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'karburujące', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'karcerowych', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'katakumbami', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'keelhauled', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kickboksera', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kinetogram', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kinszaskiej', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kondensować', 11, N'pl')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'konidialnej', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'krzepnięcie', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'łączniowate', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'likwidusami', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lorettoite', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'łyżwiarskim', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mannersome', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'manometers', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'marabuciemu', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'marsowością', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mateologiom', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mesopodium', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'metonimiami', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'modylionowi', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'multicurie', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'naoklejacie', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'naszczałyby', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'necromania', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'negational', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niedojadani', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niedozujące', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niedylewska', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niefrotowym', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niefurażową', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niemączkowa', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niemiganymi', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niemłotkowi', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niemroczoną', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nienidzicka', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieodwikłań', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepęcinową', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niesłodowań', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niestrąkową', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nietoperzyk', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nietulowską', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieulecenia', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieulżeniom', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieumarzaną', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewłochatą', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezbawiona', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nincompoop', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nondefiner', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nondoubter', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'normańskiej', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'oberluftach', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'obmierzałem', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odlewarkach', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odlutowałam', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odumarłyśmy', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odżywiajmyż', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'okratowałaś', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ornamentują', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ortoskopowy', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ośmiotomowa', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'osteoclast', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'osteolytic', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'otamowujmyż', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'outgnawing', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'owocowałyby', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ozłacaniami', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'paraenesis', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pateriform', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'philonoist', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'phlorhizin', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'piastowałeś', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pinpricked', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'piwowarskim', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'plagiaries', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pocechowaną', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podminowuje', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pokierowany', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pokulaniach', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'połaskotano', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'policzalnym', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'poluźniając', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'popękałabyś', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'poriomanic', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'potłumiałeś', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'powybielano', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'powyróżniaj', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'precurrent', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'presbyopia', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prescience', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'presetting', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'presuppose', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'proposable', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prużyliście', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przybrnąłeś', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przyganiłem', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'psikniętymi', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pyłoodporna', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'questioned', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reinvading', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rosefishes', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'roughdries', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'roundridge', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'różowiących', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'roztrącałam', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rurigenous', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'schooldays', 11, N'en')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'scyphiform', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'semiacidic', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'semiferous', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sentiently', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sericteria', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sidepieces', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'simonizing', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'singhalese', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'skeltonics', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'skrupulatkę', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'smyczkowymi', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sociolatry', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'speckiness', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spełniałbyś', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spłaszczało', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'stetryczała', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'strzałowaci', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'subphratry', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'substernal', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'surfeiting', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'synthetise', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'syrupiness', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'szwagierską', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tabuizowane', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'teokrazjach', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ternarious', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tricennial', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'trigeminus', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'trudnopalny', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unblanched', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'undeported', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'underhatch', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'undilating', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unexhorted', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unhealably', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unrippling', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unsorrowed', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unsubtlety', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unvolitive', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'urywającemu', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uskarżyłbym', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'villainist', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'virtualism', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'vociferize', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wahałybyśmy', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wilczątkiem', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wnętrzników', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'womanizers', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'woodsheddi', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wpakowanych', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wykwateruje', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyręczonymi', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zabagniajże', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zachlupaniu', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zadrzewiają', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaktywowało', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaokiennica', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zapeszającą', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zapleśnieję', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaprzestaję', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zastrachana', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zatracaniom', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zbrojnikach', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zesmutniałą', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zgniataczem', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ziarnowanej', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zwoleńskiej', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'abrogowaniem', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'acquiescent', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'aerifaction', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'akumulacyjni', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'akwakulturze', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'akwamanilach', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'alacriously', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'amaranthine', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'anthracnose', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'antiatheism', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'antichamber', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'antydatowaną', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'apokatastazę', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'apologizing', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'apopleksjami', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ascertainer', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'augustynizmy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'aureomycynom', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'autoutleniań', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'beachmaster', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bestraddled', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'biacetylene', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bielnikowych', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bifurcation', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'biocenology', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'botryllidae', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'budowniczego', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'capitalists', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'caquetoires', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chaetetidae', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'charcuterie', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chemisorpcję', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cogrediency', 12, N'en')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'commandress', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'compilement', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'concentrate', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'conglobated', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'consistence', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cooperation', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'creatorhood', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cubomedusan', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dekadenckiej', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'disorganize', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'doginającego', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ekshumowałem', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ekstyrpująca', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'energetical', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'eremiteship', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'estymowałyby', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'executrices', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'expirations', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fasetowanemu', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fiancailles', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fourfiusher', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'galloflavin', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'glucolipine', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'grieshuckle', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'grippleness', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'helmintozach', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'heteroptics', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'holostomate', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'horteksowską', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hydroforniom', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hydrozespoły', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'illinoisian', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'inadvertent', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'infertility', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'informowałeś', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'intervolute', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'jateorhizin', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'jednorzędową', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kauteryzujże', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kazamatowemu', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kłamałybyśmy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kobaltowałem', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kompaktorach', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kontrofercie', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kostkowatemu', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'leszowałabym', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lethargized', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'limitowałbyś', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lonżowałyśmy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'magazynierce', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mantrowaliby', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'margrabianką', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'marmoreally', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'masculinism', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'masticurous', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'menorhyncha', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mesosporium', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mineralogic', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'minezengerom', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'monocoelian', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'monopolowymi', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'myogenicity', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mystacinous', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nadużywającą', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'naopieprzało', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nawygadujesz', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebłonicowi', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebuchającą', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niechlejącym', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niechłonnemu', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niechmielący', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niefekalnego', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niegrodzkimi', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niejuwenalny', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niekataralne', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niekomesowym', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niekumpelski', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nielubieńską', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nienumeański', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nienurowatej', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieobsrywany', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieopisywane', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieopłaconym', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieostrouchy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepakowność', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepełniutką', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepodegraną', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepożalenia', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieprzesrany', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niesmykniętą', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieśródleśny', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieszanowany', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niesztangowy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieumykające', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewątlutkie', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewielouste', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezakuleniu', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonapparent', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonorthodox', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonphenolic', 12, N'en')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'norwegizację', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'observative', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ocynkowywana', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odciążyłabyś', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odhuknęliśmy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odmieniający', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odpoczynkami', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odrodziłabym', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'okleiłybyśmy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'olszóweckimi', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ośmioaktowej', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'otworzeniach', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ovatooblong', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overflogged', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overliberal', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overtrimmed', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pacierzowych', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'palikowanego', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'paragrapher', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pedicellate', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'phoneticism', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'phototypist', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pinkishness', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'planetogeny', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podgniwałbym', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podgrzałabyś', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pogdybaliśmy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pokostowałem', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'polerowanych', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'poosłaniałaś', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'popowstawała', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'poprzeginali', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'popukującego', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'porażającymi', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'potylicowego', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prealphabet', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'preclothing', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pretoriaństw', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'priorytetowo', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'proctoptoma', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'procyonidae', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'propulsions', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'protocolize', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prowadzające', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przepasanych', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przerastajże', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przerzynałam', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przetasujesz', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przetykanymi', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przewracaniu', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'psychofugal', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'publicanism', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'radiomedial', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reapologies', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'recondensed', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reintuition', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'remontowcami', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rewarehouse', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozdzierając', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozmówiłyśmy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozpuchłyśmy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozrywaliśmy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozszywanemu', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'roztłukujący', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spokładanego', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sprawowaniem', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sternomancy', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'stumetrowiec', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sygilografia', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'synthetical', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sztampowatym', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'szynkareczce', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'szyprującego', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tetracerous', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'thesmothete', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tootinghole', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'traducement', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'trailerload', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'transducers', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'udźwięcznisz', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unavertibly', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unbarbarous', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unclenching', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'underjailer', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unfraternal', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unlucidness', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unmobilised', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unmotioning', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unprospered', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unreverence', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'upadlibyście', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'utorowałyśmy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uzbierałabym', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'venturously', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'węglokoksowe', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wheyishness', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wietrznikach', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wpierniczmyż', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wulgaryzmowi', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyczerpywali', 12, N'pl')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wydokowałbyś', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wymiotowałeś', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wypełniający', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wypłacalność', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wypomniałaby', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyrugowawszy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyskamlanymi', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyszkalałyby', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyzbywaniami', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wzmiankowało', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zabejcowaniu', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zagrzebianom', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zakrywajcież', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zarefowałaby', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zasmagaliśmy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaterkoczcie', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zatynkowałeś', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zmydliliście', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zniechęciłeś', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'adenosarcoma', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'aecidiostage', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'agnification', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'allothogenic', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ambulatorily', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'animizowanego', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'antigambling', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'articulative', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'assibilating', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'autolizowanie', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bezwapiennego', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bromobenzenów', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cameralistic', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'clavicithern', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cogitability', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'collodiotype', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'condemnatory', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'craftspeople', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dekapilatorze', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'deputowałabyś', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'diastolicznym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'diffusionism', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ditheistical', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'domniemywaniu', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'electrolytes', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'enkawudystami', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'equisetaceae', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gastrulation', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gesticulator', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'grawitropizmu', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'groundkeeper', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'heliochromic', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'heraldycznego', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hiperbolizmów', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'homogenizing', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'homovanillic', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'horacjańskimi', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hypopygidium', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'implementors', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'impoverisher', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'inaugurowanym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'incendiarist', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'inobservance', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'izotonicznemu', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'karbonylujmyż', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'każdodniowych', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kombinatorscy', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'koncyliarysta', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kowariantnymi', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ksenofobijnej', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'labioversion', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lamentations', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'laticiferous', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'makrourzędowi', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'metastasized', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mountaineers', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'multitasking', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'musztrowaliby', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nabuntowałbyś', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nadmieniajcie', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nadokienników', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nadwigrzańscy', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nakierowaniem', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'naopierdalało', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'naprowadzałaś', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nasterowaniem', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'natapirowałaś', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nawpierdalaną', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebaskwilowy', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebazującemu', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebezerukowe', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebogatyńska', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebukowatych', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebydlęcenie', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niedoprawianą', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niefluorowani', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niegrębkowska', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niehypetralne', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niejodynująca', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nielapidarnie', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nienafikaniem', 13, N'pl')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nienapsikaniu', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nienożycowymi', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieobligowego', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieobrównywań', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieobwieszona', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieodpisywane', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieolinowanej', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepalmyrskim', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieparciejąca', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepodawanych', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepółmartwym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nierozryczany', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niesaradelowi', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieszanownemu', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieszawianach', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nietobruckiej', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nietrząsające', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieturniowymi', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewpijaniach', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewybłaganym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewymamlaniu', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewypichceni', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezaciśnięta', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezbaraniali', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezbudowanie', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieżółciejący', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieżyłowaniem', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonassertion', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonasthmatic', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'obtapiającemu', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'oczynszowanie', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odazotowałoby', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odcieleśniłam', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'oligomyodian', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'oprzyrządowań', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'orędownictwie', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'osierociałaby', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'panierowanemu', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'paracyanogen', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'parturitions', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pauciloquent', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'październikom', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'perfumowanemu', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'phaenanthery', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'philosophism', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'photostating', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'physiography', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pietruszkowym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'plebiscytarna', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podkopywałbyś', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podpływałabyś', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podprowadzony', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pokrapiającym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'politicizing', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'polydactylus', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pomarkotniałą', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ponagrywaliby', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'poodpisywaniu', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'porozmnażania', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'posklecałabym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'powzbierawszy', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pozakupowanie', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prawoflankowi', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'preadvertise', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prepigmental', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'proprioceptor', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prostytuowały', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przecinałyśmy', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przepacaniach', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przestrzegają', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przetrwałabym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przytarłyście', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rebirthingach', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'recensionist', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'recrudescent', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reinducement', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reirrigation', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reklamóweczki', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'roccellaceae', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozgrodzeniem', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozwiąźlejsza', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sclerometric', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'seksbiznesach', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'siphonoglyph', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'skierowywałby', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'snowboardingu', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spidermonkey', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'stereotypies', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'strangurious', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'subalternant', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'subobliquely', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sulfobenzide', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'szczecinowymi', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'termolecular', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'theophylline', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'triangulates', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'trójtraktowej', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'umilknięciami', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unactiveness', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unanalogical', 13, N'en')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unaturalniały', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uncorrigible', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'underchamber', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unexculpable', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unmeridional', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unmetaphysic', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unneutrality', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unperfidious', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unpermeating', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unpredicting', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unredeemably', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unreluctance', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unstimulated', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unsurrounded', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unthundering', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uskrzydlanych', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'vaginicoline', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'verecundness', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'victorianize', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'whipperginny', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wieczornikach', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'windsurferowi', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'withholdings', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'woodmancraft', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wydębilibyśmy', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wynagrodźcież', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyplotowanego', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyprodukowuję', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wypukiwaliśmy', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyrębywałyśmy', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wytarmoszonej', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaagitowałyby', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zabałaganiała', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zadrukowywana', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zahartowałyby', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zamieszkajcie', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zanitowałyśmy', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaplanowaniom', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zarachowałoby', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaradziłyście', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zatoczyliście', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zezwierzęcono', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'złupkowacieje', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zweryfikujcie', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zwietrzeniach', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'anachronously', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'anathematised', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'antilibration', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bieszczadzkimi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'brachydactyly', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cardiorrheuma', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'centrodesmose', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cervicolumbar', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ciśnieniowcami', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'collaterality', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'consolamentum', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'corruptionist', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'counterflight', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'criticisingly', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cruroinguinal', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cytokininowego', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'demonolatrous', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dephysicalize', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'deskryptywnemu', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dodrukowaniami', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'eksplorowałaby', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'exceedingness', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'expatiatingly', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'exploratively', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'extractorship', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fikobilinowymi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gburowaciejąca', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gentilization', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'haemorrhaging', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'heresiologist', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'heterocarpism', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hutchinsonite', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ichthyography', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ichthyomantic', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'intercolumnal', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'konfrontatywna', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'korniszonowaty', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'krótkobiegacza', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'krótkofalarscy', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kryminalistyka', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kwestionowałby', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'laicyzacyjnego', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'listerelloses', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'megalopolises', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'metallography', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mousquetaires', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'multivincular', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nadtłukłybyśmy', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'neoromantyzmie', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieapanażowymi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebąknięciach', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebodiakowego', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niecelkowanymi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niechłonięciom', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niedokopaniami', 14, N'pl')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niedublowanemu', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niefalklandzka', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niegrandzących', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niegryzującemu', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niekajakarskim', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niekajakowaniu', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niekatedrowych', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niekompletowym', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niekretynowate', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niekultycznemu', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nielejbikowaty', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nielochającymi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niemagnetytowi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nienadźwiganie', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nienekielskich', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nienitrującymi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieodzywaniach', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieokreśleniom', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepapierosowa', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepobrzękłymi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepopasionymi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepowzdymania', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepozapędzane', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieprzesłanych', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieprzypędzaną', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieprzysurowej', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieróżowożółci', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nierozrostowym', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nietotalitarni', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieudręczająco', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewielobarwni', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewśpiewywane', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewybawionego', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewykupionego', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezamrażająca', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezużywającym', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nondedicative', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nondistortion', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'organogenesis', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'otyczkowywanej', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overearnestly', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overhostilely', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'palatoglossal', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'paleontologiom', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pazerniejszego', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'philocynicism', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'phlebenterism', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'piuricapsular', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pneumatoscope', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podmarszczyłem', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podostawiajcie', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podpowiadający', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podyskotekować', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pokrzywdziłbym', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'półzwierzęcych', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pomieszkiwania', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'postdatującego', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'postkomunizmem', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pozaścieławszy', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pozastawianego', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'praktykantkach', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prevolitional', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'proclaimingly', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przegarniajcie', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przemejlowałam', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przerąbywałoby', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przyłoilibyśmy', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przyoblekaliby', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przysładzanych', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przystojniaków', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'psychodeliczki', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ptenoglossate', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'quinquennalia', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'refinansowałaś', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'remiksowałabyś', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'retrogressive', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rhabdocoelida', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'romantyzujcież', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozkapryszania', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozmiksowałyby', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozpoznawałbyś', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozspacjowujże', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'roztropnieniem', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'roztrzaskanego', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sanguinolency', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'semidelirious', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'semipałatyński', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sensationally', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'skarłowaciałej', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'slavification', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sporophyllary', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'subiektywistka', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'suburbanising', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'superindustry', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'supraspinatus', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'symbionticism', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'technostresowi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'transliterate', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'traumatyzacjom', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ubiegłorocznym', 14, N'pl')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unbastardized', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uncreatedness', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'undeliberated', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ungodmothered', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unjeopardized', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unlubricating', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unpatternized', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unreclaimable', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unreproaching', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unspottedness', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wieczerzającej', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'współoznaczamy', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wykolegowanych', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wypakowującego', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wypukłodrukowi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyświdrowywały', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zabatożyłyście', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zabijałybyście', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zadowcipkujmyż', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zazielenionych', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'allothigenetic', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'anthraquinonyl', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'antimetabolite', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'błogosławionego', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'compromisingly', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'concentrically', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'concommitantly', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'counterlighted', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dekomunizatorem', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'deutencephalic', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dynamoelectric', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'effervescently', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'escalloniaceae', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'intergranularna', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'intuitionalist', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'jednowiosłowego', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'karmuazowałyśmy', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kilkugroszowego', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kleptomaniacal', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kontemplowałbym', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'meritmongering', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mikrofonującego', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'misdescriptive', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'najjurniejszymi', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nanoplanktonach', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieafirmatywnie', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niearcygroźnych', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieaukcjonowani', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebeczułkowaty', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebodzechowska', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebollywoodzką', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niedetencyjnych', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niedziwerowanie', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieenerdowskich', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niehongkońskiej', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieintabulowane', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieinteligencja', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niekorsjowatych', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nienadpiławskim', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nienatrzepanego', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieneopogańskim', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieoblicowanymi', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieodbębnieniom', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieodcumowującą', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieoklaskaniami', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieordynowanych', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieotamowywaniu', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieotrząchnięty', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepabianickimi', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepodczesujący', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepoliczkowana', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieposłuszeństw', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieprolongująca', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieskoślawienie', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieszczotkująca', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nietaśmociągowi', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieuciszających', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieuszczypliwym', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieuzmysławiani', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewycałowującą', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewydatowanemu', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewyjękniętych', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewyksięgowani', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewystrzyżenia', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewzbijającymi', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezapakowywaną', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezapożyczanej', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezastawieniem', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezdryfowanego', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezestrzelania', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezgranatowień', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonemotionally', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonethicalness', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonimpregnated', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonostensively', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonsolvability', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'obyczajnościami', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odheroizowywana', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odrealniających', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overpersecuted', 15, N'en')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overpowerfully', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overstrongness', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'palanquiningly', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'paramyosinogen', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pasteurisation', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'perimetrically', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'peritrichously', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'phenomenalized', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pithecanthropi', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'poćwiartowaniem', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podpuchnięciami', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pokalibrowaniom', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pokancerowaniom', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pośniedziałyśmy', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'potencjonalnych', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'powyrąbywaliśmy', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'precurriculums', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'presuppression', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przekablowaniom', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przybandażowaną', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przygięlibyście', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pterygopalatal', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'quadrauricular', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozwalalibyście', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'samoudręczaniom', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'skonsygnowaniem', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spirillotropic', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spoważniałyście', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sprzeciwiajcież', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'śródchrzęstnymi', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'superextremely', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'terkolilibyście', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'transformation', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tranzystorowymi', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'triunification', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unannihilative', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unchildishness', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'underthroating', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unieważniałyśmy', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unstrangulable', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wersyfikatorscy', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wielodziałowemu', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wmanewrowaniach', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wokółsłonecznej', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wszyściuteńkiej', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wydoktoryzowali', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyekscerpowanym', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wystrugalibyśmy', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaśmiardnęliśmy', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zawiązalibyście', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'autotrepanation', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'basidiolichenes', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'counterpetition', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cyclohexatriene', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hydrocinchonine', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'imperishability', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'inapplicability', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'inconveniencies', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'interresistance', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'microdissection', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'monticuliporoid', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'noncatastrophic', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'peristeropodous', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'photoregression', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'quinquarticular', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reconcilability', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'semiamplexicaul', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'subcompensating', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unmetamorphosed', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unornamentation', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unsurpassedness', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'beetleheadedness', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'contraprovectant', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'demorphinization', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'discriminatively', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'foretellableness', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'guanidopropionic', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'imperceptibility', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'laryngopharynxes', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonconscriptable', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonenigmatically', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'organizationally', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'radiosensibility', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unintellectually', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unsympathizingly', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'untautologically', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'duodenocystostomy', 18, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'intraperitoneally', 18, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonaccidentalness', 18, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'noncongratulatory', 18, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'phytophenological', 18, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'platystencephalic', 18, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unconcealableness', 18, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'encephalopsychesis', 19, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'saccharometabolism', 19, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'deoxyribonucleotide', 20, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'orthoveratraldehyde', 20, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'phenomenalistically', 20, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'supersuperabundance', 20, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unanachronistically', 20, N'en')
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [challenge_types_name_key]    Script Date: 05.02.2022 00:25:30 ******/
ALTER TABLE [dbo].[challenge_types] ADD  CONSTRAINT [challenge_types_name_key] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [languages_name_key]    Script Date: 05.02.2022 00:25:30 ******/
ALTER TABLE [dbo].[languages] ADD  CONSTRAINT [languages_name_key] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[challenge_participations] ADD  CONSTRAINT [challenge_participations_created_at_df]  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[challenge_solutions] ADD  CONSTRAINT [challenge_solutions_created_at_df]  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[challenge_types] ADD  CONSTRAINT [challenge_types_created_at_df]  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[challenges] ADD  CONSTRAINT [challenges_created_at_df]  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[languages] ADD  CONSTRAINT [languages_created_at_df]  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[users] ADD  CONSTRAINT [users_created_at_df]  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[challenge_invites]  WITH CHECK ADD  CONSTRAINT [challenge_invites_challenge_uuid_fkey] FOREIGN KEY([challenge_uuid])
REFERENCES [dbo].[challenges] ([uuid])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[challenge_invites] CHECK CONSTRAINT [challenge_invites_challenge_uuid_fkey]
GO
ALTER TABLE [dbo].[challenge_invites]  WITH CHECK ADD  CONSTRAINT [notifications_user_uuid_fkey] FOREIGN KEY([user_uuid])
REFERENCES [dbo].[users] ([uuid])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[challenge_invites] CHECK CONSTRAINT [notifications_user_uuid_fkey]
GO
ALTER TABLE [dbo].[challenge_participations]  WITH CHECK ADD  CONSTRAINT [user_solutions_challenge_uuid_fkey] FOREIGN KEY([challenge_uuid])
REFERENCES [dbo].[challenges] ([uuid])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[challenge_participations] CHECK CONSTRAINT [user_solutions_challenge_uuid_fkey]
GO
ALTER TABLE [dbo].[challenge_participations]  WITH CHECK ADD  CONSTRAINT [user_solutions_user_uuid_fkey] FOREIGN KEY([user_uuid])
REFERENCES [dbo].[users] ([uuid])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[challenge_participations] CHECK CONSTRAINT [user_solutions_user_uuid_fkey]
GO
ALTER TABLE [dbo].[challenge_solutions]  WITH CHECK ADD  CONSTRAINT [challenge_solutions_challenge_uuid_user_uuid_fkey] FOREIGN KEY([challenge_uuid], [user_uuid])
REFERENCES [dbo].[challenge_participations] ([challenge_uuid], [user_uuid])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[challenge_solutions] CHECK CONSTRAINT [challenge_solutions_challenge_uuid_user_uuid_fkey]
GO
ALTER TABLE [dbo].[challenges]  WITH CHECK ADD  CONSTRAINT [challenges_challengeTypeId_fkey] FOREIGN KEY([challengeTypeId])
REFERENCES [dbo].[challenge_types] ([id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[challenges] CHECK CONSTRAINT [challenges_challengeTypeId_fkey]
GO
ALTER TABLE [dbo].[challenges]  WITH CHECK ADD  CONSTRAINT [challenges_word_content_word_language_code_fkey] FOREIGN KEY([word_content], [word_language_code])
REFERENCES [dbo].[words] ([word], [language_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[challenges] CHECK CONSTRAINT [challenges_word_content_word_language_code_fkey]
GO
ALTER TABLE [dbo].[words]  WITH CHECK ADD  CONSTRAINT [words_language_code_fkey] FOREIGN KEY([language_code])
REFERENCES [dbo].[languages] ([code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[words] CHECK CONSTRAINT [words_language_code_fkey]
GO
/****** Object:  StoredProcedure [dbo].[drop_challenge_duplicates]    Script Date: 05.02.2022 00:25:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create procedure

CREATE PROCEDURE [dbo].[drop_challenge_duplicates]
AS
BEGIN
WITH [duplicates] AS (
	SELECT ROW_NUMBER() OVER(PARTITION BY [word_content], [word_language_code] ORDER BY [created_at] DESC)
	AS [rn]
	FROM [dbo].[challenges]
)
DELETE [duplicates] WHERE [rn] > 1
END;

GO
/****** Object:  StoredProcedure [dbo].[insert_word]    Script Date: 05.02.2022 00:25:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--- Add procedure

CREATE PROCEDURE [dbo].[insert_word]
	@language_code NVARCHAR(3),
	@word NVARCHAR(100)
AS
BEGIN
	INSERT INTO [dbo].[words] ([word], [language_code], [length])
	VALUES (@word, @language_code, LEN(@word))
END

GO
/****** Object:  StoredProcedure [dbo].[start_game]    Script Date: 05.02.2022 00:25:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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

GO
