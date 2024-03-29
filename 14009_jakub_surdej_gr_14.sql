USE master;
GO
IF DB_ID (N'jakub_surdej_14009') IS NOT NULL
DROP DATABASE [jakub_surdej_14009];

CREATE DATABASE [jakub_surdej_14009]
COLLATE Polish_100_CI_AS; 
GO

USE [jakub_surdej_14009]
GO
/****** Object:  UserDefinedFunction [dbo].[get_random_word]    Script Date: 06.02.2022 14:38:13 ******/
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
/****** Object:  Table [dbo].[challenges]    Script Date: 06.02.2022 14:38:13 ******/
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
/****** Object:  Table [dbo].[challenge_participations]    Script Date: 06.02.2022 14:38:13 ******/
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
/****** Object:  Table [dbo].[challenge_solutions]    Script Date: 06.02.2022 14:38:13 ******/
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
/****** Object:  View [dbo].[scoreboard]    Script Date: 06.02.2022 14:38:13 ******/
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
/****** Object:  Table [dbo].[languages]    Script Date: 06.02.2022 14:38:13 ******/
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
/****** Object:  View [dbo].[popular_words]    Script Date: 06.02.2022 14:38:13 ******/
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
/****** Object:  Table [dbo].[users]    Script Date: 06.02.2022 14:38:13 ******/
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
/****** Object:  UserDefinedFunction [dbo].[users_by_challenge_count]    Script Date: 06.02.2022 14:38:13 ******/
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
/****** Object:  UserDefinedFunction [dbo].[solutions_for_langs]    Script Date: 06.02.2022 14:38:13 ******/
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
/****** Object:  View [dbo].[random]    Script Date: 06.02.2022 14:38:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--- Add view for getting random value

CREATE VIEW [dbo].[random]
AS
	SELECT CRYPT_GEN_RANDOM(4) AS random_value;

GO
/****** Object:  Table [dbo].[challenge_invites]    Script Date: 06.02.2022 14:38:13 ******/
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
/****** Object:  Table [dbo].[challenge_types]    Script Date: 06.02.2022 14:38:13 ******/
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
/****** Object:  Table [dbo].[words]    Script Date: 06.02.2022 14:38:13 ******/
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
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'06093559-116a-466f-9f3d-bf57963cb5ba', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731191' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'06093559-116a-466f-9f3d-bf57963cb5ba', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731251' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'06093559-116a-466f-9f3d-bf57963cb5ba', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731261' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'063bb82f-c61b-49d8-bf07-7f226fa8026a', N'2b1b01f3-59ab-472c-a49c-c053b25eb4eb', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731268' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'063bb82f-c61b-49d8-bf07-7f226fa8026a', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731275' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'063d8d0e-64d6-448e-8866-cb01df622849', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731318' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'063d8d0e-64d6-448e-8866-cb01df622849', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731324' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'96aed832-57a1-4204-ad3c-1d662855e890', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731332' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731338' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731371' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731379' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0c88f5f8-fe81-40a3-8af2-95927a3e6dc1', N'4217cb86-c05c-436e-a9f6-0b5e5f70db81', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731385' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0c88f5f8-fe81-40a3-8af2-95927a3e6dc1', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731392' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0c88f5f8-fe81-40a3-8af2-95927a3e6dc1', N'46f32deb-fd2a-4544-88f4-27e9aaafe0a3', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731398' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0c8e557d-60ea-4b32-8719-5b8d93e44f84', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731405' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0cfd8571-d336-4df2-aeb1-89596ec5cedb', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731412' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0d0da875-5a47-472f-b852-6c49522f21d9', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731419' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0e640fb9-f988-436c-98bb-1e3e04fc62e6', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731429' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0e640fb9-f988-436c-98bb-1e3e04fc62e6', N'f5ca7f60-0d49-4c12-bd33-87fbfdec7edd', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731435' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0e640fb9-f988-436c-98bb-1e3e04fc62e6', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731442' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0f19991c-059e-4b87-aad7-6afac408efcb', N'25dde876-8acb-41ee-919f-0cfc5fde07c7', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731449' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0fe871d4-efbe-482b-b78b-70ecbc93b859', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731455' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'0fe871d4-efbe-482b-b78b-70ecbc93b859', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731461' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'10b60554-3abe-4e43-b1b1-96d35a1049a6', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731467' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'10b60554-3abe-4e43-b1b1-96d35a1049a6', N'7956ec3d-07d9-404e-b517-29c315e45119', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731473' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'10b60554-3abe-4e43-b1b1-96d35a1049a6', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731479' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'10b60554-3abe-4e43-b1b1-96d35a1049a6', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731485' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'11734c10-bda2-483e-9dbb-04c961fe86a9', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731491' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'11734c10-bda2-483e-9dbb-04c961fe86a9', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731497' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'11734c10-bda2-483e-9dbb-04c961fe86a9', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731503' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'142e2de5-7fd4-4f0b-8411-fcd5e4e2aaae', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731509' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'14a47bcd-3b7c-447b-91aa-76be52ce8b1f', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731515' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'14a47bcd-3b7c-447b-91aa-76be52ce8b1f', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731520' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'14a47bcd-3b7c-447b-91aa-76be52ce8b1f', N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731530' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'14f749e5-5b93-49b2-84ee-33d9353b3261', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731536' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'14f749e5-5b93-49b2-84ee-33d9353b3261', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731543' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'14f749e5-5b93-49b2-84ee-33d9353b3261', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731550' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'14f749e5-5b93-49b2-84ee-33d9353b3261', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731555' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731561' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'7956ec3d-07d9-404e-b517-29c315e45119', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731567' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731574' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731580' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'17542693-cac1-455b-889c-e115b27e4320', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731590' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'17542693-cac1-455b-889c-e115b27e4320', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731596' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'17542693-cac1-455b-889c-e115b27e4320', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731602' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'1b7b3d7c-de2a-4f8c-acd2-73bf92a86402', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731607' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'1cdaa460-4b96-4bb7-afd1-1beeda32c57d', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731613' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'1f5213ff-313f-4c19-874e-95c794efa89b', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731619' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'1f5213ff-313f-4c19-874e-95c794efa89b', N'7956ec3d-07d9-404e-b517-29c315e45119', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731626' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'1f5213ff-313f-4c19-874e-95c794efa89b', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731633' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'1f5213ff-313f-4c19-874e-95c794efa89b', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731638' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'1fdc49f7-9cd2-4e1c-b1d3-ed12f6962445', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731644' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731650' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731656' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731661' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'21d0080a-5316-42f3-84bf-89bcc5eccc6d', N'74d3f2e2-a0c4-418f-933f-890e26a64328', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731668' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'229c4f6e-976e-46ec-b165-2691dad8ee34', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731674' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'229c4f6e-976e-46ec-b165-2691dad8ee34', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731680' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2382d2d3-eb3c-4bc0-9f18-8ace2e60ce85', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731686' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2382d2d3-eb3c-4bc0-9f18-8ace2e60ce85', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731692' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2382d2d3-eb3c-4bc0-9f18-8ace2e60ce85', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731698' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'24cba4c3-a464-4fc0-9acf-9991a1d5f2f5', N'572b7747-e3eb-4ccf-8211-f013d3618acd', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731704' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'24cba4c3-a464-4fc0-9acf-9991a1d5f2f5', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731710' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2706580c-0fa0-4934-bdf1-7868b60f6ab2', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731716' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'27b3113d-1d2e-48a8-bd96-da994b22aaec', N'0846669c-07f1-41f4-9381-e038ec3351d6', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731722' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731732' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731738' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731744' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731750' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'29143e5b-7753-4b9c-9d43-7c62bef2f975', N'037a6380-46ef-4327-b1bb-5aef7a64dbc5', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731756' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'29ea49f2-602e-4fb6-b0c6-4c869ecfd65e', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731762' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'29ea49f2-602e-4fb6-b0c6-4c869ecfd65e', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731768' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'29ea49f2-602e-4fb6-b0c6-4c869ecfd65e', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731776' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'29ea49f2-602e-4fb6-b0c6-4c869ecfd65e', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731782' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2d05b32d-c4af-49cf-8dcb-a8f8739b8529', N'a469291c-45ea-4395-b544-c3f5e2ac9887', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731788' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2d05b32d-c4af-49cf-8dcb-a8f8739b8529', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731795' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2f803c3d-16c7-456e-83e7-cfb72ed08ec4', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731801' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'2f803c3d-16c7-456e-83e7-cfb72ed08ec4', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731807' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3155e8c9-8bb8-42cc-bf80-94f1aed72ff3', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731813' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3155e8c9-8bb8-42cc-bf80-94f1aed72ff3', N'7956ec3d-07d9-404e-b517-29c315e45119', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731819' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3180cfb0-4434-4b3a-8434-3d272021016f', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731825' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3180cfb0-4434-4b3a-8434-3d272021016f', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731832' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'32b744fe-35e1-44c4-a6cf-4d5558c8329d', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731838' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'32b744fe-35e1-44c4-a6cf-4d5558c8329d', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731843' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'37ede4fe-d321-41e5-8907-d63de5e16bc1', N'0aa51811-6ba5-47f1-b2b8-4ae519845a0b', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731850' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'37ede4fe-d321-41e5-8907-d63de5e16bc1', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731855' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'37ede4fe-d321-41e5-8907-d63de5e16bc1', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731861' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731867' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731873' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731879' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731885' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731891' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731897' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731903' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c842d25a-3950-48d0-baaa-3be138f8ace4', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731909' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'39d441db-46a1-46b2-a2e4-ba3ac9822570', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731914' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'39d441db-46a1-46b2-a2e4-ba3ac9822570', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731920' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'39d441db-46a1-46b2-a2e4-ba3ac9822570', N'34849063-3080-40ca-b64a-205dbf62e4f2', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731926' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'39d441db-46a1-46b2-a2e4-ba3ac9822570', N'407691e8-1a33-4c43-ab9c-0193bc408464', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731932' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3a6b91a6-0ab3-45b2-b9ee-d6a7cdef325c', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731938' AS DateTime2))
GO
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3a6b91a6-0ab3-45b2-b9ee-d6a7cdef325c', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731944' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3a6b91a6-0ab3-45b2-b9ee-d6a7cdef325c', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731949' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3ddc6f45-c9f3-464c-9f5d-6fd26638dcaf', N'2b1b01f3-59ab-472c-a49c-c053b25eb4eb', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731956' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3ddc6f45-c9f3-464c-9f5d-6fd26638dcaf', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731962' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3ddc6f45-c9f3-464c-9f5d-6fd26638dcaf', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731967' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3ddd38bb-32f0-4725-b6f3-731e47a79049', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731974' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3e65e949-f091-40a1-970c-d05184575d70', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731980' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3e65e949-f091-40a1-970c-d05184575d70', N'9f85aedf-6139-484b-9fc6-f9ea39e50079', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731985' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3e65e949-f091-40a1-970c-d05184575d70', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731991' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3e65e949-f091-40a1-970c-d05184575d70', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4731997' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3f668179-03a9-4871-b578-406c09ec4798', N'efd2d829-2500-4c66-bd27-586989316647', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732003' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3fee4164-d1ca-499d-81ff-ea4c0a4633aa', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732008' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3fee4164-d1ca-499d-81ff-ea4c0a4633aa', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732015' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'3fee4164-d1ca-499d-81ff-ea4c0a4633aa', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732021' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'43c52861-4420-4abd-a679-3be7bc025008', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732026' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'43c52861-4420-4abd-a679-3be7bc025008', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732032' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'43c52861-4420-4abd-a679-3be7bc025008', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732038' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'43c52861-4420-4abd-a679-3be7bc025008', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732044' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'46340f04-eb26-4fcc-b518-eae6d7b95972', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732050' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'46340f04-eb26-4fcc-b518-eae6d7b95972', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732056' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'46340f04-eb26-4fcc-b518-eae6d7b95972', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732062' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'478e0a76-88d2-400a-956f-872c11b56001', N'25dde876-8acb-41ee-919f-0cfc5fde07c7', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732068' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'478e0a76-88d2-400a-956f-872c11b56001', N'2b1b01f3-59ab-472c-a49c-c053b25eb4eb', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732073' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'478e0a76-88d2-400a-956f-872c11b56001', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732079' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'478e0a76-88d2-400a-956f-872c11b56001', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732085' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'48e0b390-b18c-43a2-869b-973ed8b3ef7e', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732091' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'48e0b390-b18c-43a2-869b-973ed8b3ef7e', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732098' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'48e0b390-b18c-43a2-869b-973ed8b3ef7e', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732104' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'48f1e2af-3726-48ad-aa46-d790ee3821d4', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732110' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'48f1e2af-3726-48ad-aa46-d790ee3821d4', N'34849063-3080-40ca-b64a-205dbf62e4f2', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732126' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'48f1e2af-3726-48ad-aa46-d790ee3821d4', N'407691e8-1a33-4c43-ab9c-0193bc408464', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732134' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4abe1b50-6fd2-423b-8a65-984f22d18f33', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732140' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4abe1b50-6fd2-423b-8a65-984f22d18f33', N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732146' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4bd970b2-2f63-448e-8141-f236a0e0737f', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732153' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4bd970b2-2f63-448e-8141-f236a0e0737f', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732159' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4e7da533-7a4d-4c13-bee2-182be873188e', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732165' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4e7da533-7a4d-4c13-bee2-182be873188e', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732171' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4ef0b9d1-e7c4-42b5-a520-9cc0de991554', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732177' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4ef0b9d1-e7c4-42b5-a520-9cc0de991554', N'46f32deb-fd2a-4544-88f4-27e9aaafe0a3', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732182' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4f8d2a4c-c743-4bbe-99e5-5f928394450d', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732189' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4f8d2a4c-c743-4bbe-99e5-5f928394450d', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732195' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4f8d2a4c-c743-4bbe-99e5-5f928394450d', N'837b4e63-6c22-4508-936d-cb31fcb0a58e', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732201' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'4f8d2a4c-c743-4bbe-99e5-5f928394450d', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732206' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'50d3ec0e-41d5-45cc-84c5-4f51049abd0f', N'0814f578-8e38-4615-a110-f342a97e9ba2', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732212' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'520a02b1-4694-4d21-bb6e-cd8eb19c4017', N'407691e8-1a33-4c43-ab9c-0193bc408464', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732218' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'520a02b1-4694-4d21-bb6e-cd8eb19c4017', N'407c141a-e8dd-4029-8feb-faa202fa7a5b', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732224' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'520a02b1-4694-4d21-bb6e-cd8eb19c4017', N'4217cb86-c05c-436e-a9f6-0b5e5f70db81', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732229' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732236' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732242' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732247' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732253' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732259' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732265' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732271' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732277' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'5801126f-c87e-429c-ae1a-7e699b483408', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732282' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'5801126f-c87e-429c-ae1a-7e699b483408', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732288' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'5bc89b50-f7c8-4914-b826-79862ba0fa44', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732294' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'5bc89b50-f7c8-4914-b826-79862ba0fa44', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732300' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'5bc89b50-f7c8-4914-b826-79862ba0fa44', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732306' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'5bc89b50-f7c8-4914-b826-79862ba0fa44', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732312' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'5d990ef5-d383-4a92-b749-32d7415e197a', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732318' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'5d990ef5-d383-4a92-b749-32d7415e197a', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732324' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'5d990ef5-d383-4a92-b749-32d7415e197a', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732330' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'5d990ef5-d383-4a92-b749-32d7415e197a', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732336' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'60a814ce-6f40-448f-a61c-5bf138e9f48e', N'bb9362f3-c1cc-41c9-b529-67a31cb42e36', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732342' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'60a814ce-6f40-448f-a61c-5bf138e9f48e', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732348' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'63fe98d1-b26b-449d-b8ab-a53a688bc1af', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732354' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'63fe98d1-b26b-449d-b8ab-a53a688bc1af', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732360' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'63fe98d1-b26b-449d-b8ab-a53a688bc1af', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732366' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'692d12d0-9486-40e6-80e4-bbf6f20efd0f', N'037a6380-46ef-4327-b1bb-5aef7a64dbc5', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732372' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'692d12d0-9486-40e6-80e4-bbf6f20efd0f', N'062bfaca-f1ba-4664-a5f3-7988132458b9', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732377' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'69eca4d8-710f-4dd4-9dee-401611bcd04d', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732383' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'69eca4d8-710f-4dd4-9dee-401611bcd04d', N'25dde876-8acb-41ee-919f-0cfc5fde07c7', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732389' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6b5fca17-9d8b-49d7-984c-4e03239a461e', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732395' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6b5fca17-9d8b-49d7-984c-4e03239a461e', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732401' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6bd6d864-fd23-49dd-9e83-2cd148642b11', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.4710000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732407' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6c36ecb0-a905-476c-877b-85939758d473', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732413' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6c36ecb0-a905-476c-877b-85939758d473', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732419' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6c36ecb0-a905-476c-877b-85939758d473', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732425' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6c36ecb0-a905-476c-877b-85939758d473', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732430' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6cd8848a-07fc-476f-83e3-8e7b19648345', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732436' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6cd8848a-07fc-476f-83e3-8e7b19648345', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732443' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6cd8848a-07fc-476f-83e3-8e7b19648345', N'5601a294-6cd8-4969-9e4a-4ff2901ae924', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732448' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6ce0e0a3-7181-46cf-a042-6f5a2d482fd1', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732454' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6ce0e0a3-7181-46cf-a042-6f5a2d482fd1', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732460' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6e815a5e-bfa4-4320-985f-40e238bda8ba', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732466' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'6f4bc015-3809-43e6-845f-2dc6f10b85aa', N'e2532790-0bef-45d7-bd16-81709f211432', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732471' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'707b7592-3eab-49fb-ad59-dcc689d7b92f', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732477' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'707b7592-3eab-49fb-ad59-dcc689d7b92f', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732484' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'707b7592-3eab-49fb-ad59-dcc689d7b92f', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732489' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'729c1e00-a464-4525-b2f2-ac2f45238f63', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732496' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'729c1e00-a464-4525-b2f2-ac2f45238f63', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732502' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732508' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732514' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732522' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732528' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'74afd494-67b5-41ee-bcda-f12f2a11575c', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732534' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'74afd494-67b5-41ee-bcda-f12f2a11575c', N'e59bcd84-c04a-45cf-98e8-3580f6750984', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732540' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'74afd494-67b5-41ee-bcda-f12f2a11575c', N'e5f9c68a-18c1-4907-ae44-c85861dfb739', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732546' AS DateTime2))
GO
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'77418136-b2b5-4ab3-866a-4c3ca5dcfd09', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732552' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'77418136-b2b5-4ab3-866a-4c3ca5dcfd09', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732576' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'78a19c00-782c-4118-9c4b-b2fa9aa04a65', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732582' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'78a19c00-782c-4118-9c4b-b2fa9aa04a65', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732588' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'b5b62c52-6dc1-4cb2-b5e8-769b03a302f0', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732594' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'bb9362f3-c1cc-41c9-b529-67a31cb42e36', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732599' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732605' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732611' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7d130e15-3309-4219-8acf-71f110c188f8', N'0814f578-8e38-4615-a110-f342a97e9ba2', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732622' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7d130e15-3309-4219-8acf-71f110c188f8', N'0846669c-07f1-41f4-9381-e038ec3351d6', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732628' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7d130e15-3309-4219-8acf-71f110c188f8', N'0aa51811-6ba5-47f1-b2b8-4ae519845a0b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732634' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7d130e15-3309-4219-8acf-71f110c188f8', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732639' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732645' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'46f32deb-fd2a-4544-88f4-27e9aaafe0a3', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732651' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732665' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732671' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732677' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732683' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'f5ca7f60-0d49-4c12-bd33-87fbfdec7edd', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732688' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732694' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8270c149-34b3-427d-8491-1efe73b86490', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732700' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8270c149-34b3-427d-8491-1efe73b86490', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732711' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'85cd4b44-f7ee-4b73-82cc-422cdb3e88e3', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732717' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'85cd4b44-f7ee-4b73-82cc-422cdb3e88e3', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732722' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'85cd4b44-f7ee-4b73-82cc-422cdb3e88e3', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732728' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'86c42784-16ff-415f-8204-ff50fec91c4c', N'6fc830b2-17d2-430c-9188-8310faa228e8', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732734' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'86c42784-16ff-415f-8204-ff50fec91c4c', N'74d3f2e2-a0c4-418f-933f-890e26a64328', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732739' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'86c42784-16ff-415f-8204-ff50fec91c4c', N'77a7f8c8-af2c-48e5-80ef-6c2f41dc93cc', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732751' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'870d908a-e66f-427c-a07d-1079df085fd9', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732756' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'870d908a-e66f-427c-a07d-1079df085fd9', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732762' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'870d908a-e66f-427c-a07d-1079df085fd9', N'b5b62c52-6dc1-4cb2-b5e8-769b03a302f0', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732767' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732774' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732780' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732785' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'5601a294-6cd8-4969-9e4a-4ff2901ae924', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732798' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8b4bd7da-f65b-4da6-8773-b25a8e83bc79', N'572b7747-e3eb-4ccf-8211-f013d3618acd', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732803' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8b4bd7da-f65b-4da6-8773-b25a8e83bc79', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732809' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8b4bd7da-f65b-4da6-8773-b25a8e83bc79', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732814' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8b7a0109-5875-478d-b9a9-307f0bf2984c', N'efd2d829-2500-4c66-bd27-586989316647', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732821' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8b7a0109-5875-478d-b9a9-307f0bf2984c', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732827' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8b7a0109-5875-478d-b9a9-307f0bf2984c', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732839' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'f5ca7f60-0d49-4c12-bd33-87fbfdec7edd', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732845' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732851' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732857' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8f538ce6-eaf1-4f45-9dbc-eac2959ef0e1', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732862' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8f538ce6-eaf1-4f45-9dbc-eac2959ef0e1', N'9f85aedf-6139-484b-9fc6-f9ea39e50079', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732869' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8f538ce6-eaf1-4f45-9dbc-eac2959ef0e1', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732874' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'8f538ce6-eaf1-4f45-9dbc-eac2959ef0e1', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732886' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'9092b367-a415-4e4d-8782-8fea8741ea36', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732892' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'9092b367-a415-4e4d-8782-8fea8741ea36', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732897' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'9092b367-a415-4e4d-8782-8fea8741ea36', N'b5b62c52-6dc1-4cb2-b5e8-769b03a302f0', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732903' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'9092b367-a415-4e4d-8782-8fea8741ea36', N'bb9362f3-c1cc-41c9-b529-67a31cb42e36', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732908' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'90f2504f-79ee-446e-9b04-5ab8f371d33f', N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732914' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'920562af-3734-4b73-89c2-ae800fd006b1', N'22d39998-47eb-43e4-8174-dff7d3c344fb', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732920' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'9288c00f-9ed2-4708-8da0-f4c84a698aae', N'407c141a-e8dd-4029-8feb-faa202fa7a5b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732926' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'950c4796-9c54-4042-a468-bfca8b6fc2a3', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732932' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'950c4796-9c54-4042-a468-bfca8b6fc2a3', N'25dde876-8acb-41ee-919f-0cfc5fde07c7', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732938' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'950c4796-9c54-4042-a468-bfca8b6fc2a3', N'2b1b01f3-59ab-472c-a49c-c053b25eb4eb', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732961' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'958cf3b1-3ed1-45e7-b689-5188423ca274', N'6fc830b2-17d2-430c-9188-8310faa228e8', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732967' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'97a139ac-a7b3-428f-85ae-a995d1a94419', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732974' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'97a139ac-a7b3-428f-85ae-a995d1a94419', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732981' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'97a139ac-a7b3-428f-85ae-a995d1a94419', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732987' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'97a139ac-a7b3-428f-85ae-a995d1a94419', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732993' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'99a34d25-f370-498b-95f5-3c66600539b3', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4732999' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'99a34d25-f370-498b-95f5-3c66600539b3', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733005' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'99a34d25-f370-498b-95f5-3c66600539b3', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733011' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'9b59cc47-7d34-4935-b45f-816b2cd1b1d3', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733017' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'9c4ae5a5-9164-4efe-9f7f-b5f283d87a32', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733023' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'9c4ae5a5-9164-4efe-9f7f-b5f283d87a32', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733029' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733035' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733041' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733047' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a44b03a7-25d6-4920-a662-013c790297ef', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733052' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a200f9cc-2918-46f1-8bb1-1b4c3f4f5684', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733058' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a39921f7-df95-4238-abfa-f4ec2758e304', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733064' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a39921f7-df95-4238-abfa-f4ec2758e304', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733069' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a39921f7-df95-4238-abfa-f4ec2758e304', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733076' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733081' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733087' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'5601a294-6cd8-4969-9e4a-4ff2901ae924', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733092' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'572b7747-e3eb-4ccf-8211-f013d3618acd', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733099' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a60292d5-d19c-448c-b93c-5bf1a89b0bf8', N'21b134fc-b41d-4feb-a647-0b6b7cf87967', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733106' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a73247b9-4020-4cd1-9944-e934ab6eb437', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733111' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733117' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733122' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733128' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a83ec9ff-e82f-4b09-8701-f468d40ebf5f', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733133' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a83ec9ff-e82f-4b09-8701-f468d40ebf5f', N'9f85aedf-6139-484b-9fc6-f9ea39e50079', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733139' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a85375a5-87e8-4aa3-936f-d6ece46f5491', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733145' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'a85375a5-87e8-4aa3-936f-d6ece46f5491', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733150' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'aa1aa489-849d-4570-89c3-5ab9549a7ff7', N'e2f0e6b6-70d8-410b-b42d-deb2d32e00ae', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733156' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'aa1aa489-849d-4570-89c3-5ab9549a7ff7', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733161' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'aa1aa489-849d-4570-89c3-5ab9549a7ff7', N'e59bcd84-c04a-45cf-98e8-3580f6750984', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733167' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'aa1aa489-849d-4570-89c3-5ab9549a7ff7', N'e5f9c68a-18c1-4907-ae44-c85861dfb739', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733173' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733180' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733185' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733191' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ae47c74e-5834-49d6-89df-534ede6093b6', N'037a6380-46ef-4327-b1bb-5aef7a64dbc5', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733196' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ae47c74e-5834-49d6-89df-534ede6093b6', N'062bfaca-f1ba-4664-a5f3-7988132458b9', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733202' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ae47c74e-5834-49d6-89df-534ede6093b6', N'0814f578-8e38-4615-a110-f342a97e9ba2', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733208' AS DateTime2))
GO
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733215' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733221' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733227' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b1fe816e-d997-48e8-adb7-f2b59f7409ec', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733232' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b1fe816e-d997-48e8-adb7-f2b59f7409ec', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733238' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b3a1d09c-2ff4-460d-b3cf-f10a11dd8645', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733243' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b404fbaa-365e-43d6-a96c-f127c83d5ee3', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733250' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b495de52-6a04-4526-b5e6-e25e23e7ac55', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733256' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b495de52-6a04-4526-b5e6-e25e23e7ac55', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733263' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b4a49c43-0886-42be-ba4e-df4fc01eb7d0', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733269' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b4a49c43-0886-42be-ba4e-df4fc01eb7d0', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733275' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b4a49c43-0886-42be-ba4e-df4fc01eb7d0', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733280' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b4a49c43-0886-42be-ba4e-df4fc01eb7d0', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733286' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b690524b-2082-416a-a319-ea7cc54d9c18', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733292' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b690524b-2082-416a-a319-ea7cc54d9c18', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733298' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b690524b-2082-416a-a319-ea7cc54d9c18', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733304' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b690524b-2082-416a-a319-ea7cc54d9c18', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733310' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733315' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733321' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733327' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733333' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'bc293cb9-ef1e-43f6-a97d-f7ffc63e3f32', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733339' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ea538c2f-7230-4d87-bbda-29db9fed309b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733345' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ee30ba09-6787-4cbe-b7d5-4136d7aa91a6', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733351' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ef87dbf8-a3ad-40e0-87e4-3c4633366b28', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733356' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733362' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733368' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733374' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c14e83b4-ea76-40ac-b861-b206e01f706b', N'9f85aedf-6139-484b-9fc6-f9ea39e50079', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733380' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c14e83b4-ea76-40ac-b861-b206e01f706b', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733386' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c14e83b4-ea76-40ac-b861-b206e01f706b', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733392' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c14e83b4-ea76-40ac-b861-b206e01f706b', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733397' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733404' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'46f32deb-fd2a-4544-88f4-27e9aaafe0a3', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733410' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733415' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c24152a9-f8dd-44ec-9355-df4a5192902b', N'efd2d829-2500-4c66-bd27-586989316647', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733421' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c24152a9-f8dd-44ec-9355-df4a5192902b', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733427' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c24152a9-f8dd-44ec-9355-df4a5192902b', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733433' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c44928ae-a1c7-4b92-86b6-f9efd26f9f11', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733438' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c44928ae-a1c7-4b92-86b6-f9efd26f9f11', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733447' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c44928ae-a1c7-4b92-86b6-f9efd26f9f11', N'837b4e63-6c22-4508-936d-cb31fcb0a58e', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733453' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733458' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733464' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733471' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733477' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c6be93cb-588c-4dd5-ac98-072aeda5dd89', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733483' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c6be93cb-588c-4dd5-ac98-072aeda5dd89', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733489' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'c6be93cb-588c-4dd5-ac98-072aeda5dd89', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733495' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ccdc9c9c-555c-467c-a671-b4a914ea514f', N'e2f0e6b6-70d8-410b-b42d-deb2d32e00ae', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733500' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ccdc9c9c-555c-467c-a671-b4a914ea514f', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733506' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ccf366d2-679f-4e86-9d82-45074cd38300', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733512' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ccf366d2-679f-4e86-9d82-45074cd38300', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733518' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ccf366d2-679f-4e86-9d82-45074cd38300', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733524' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'cd8b394a-655e-403b-9ac0-99f44563c439', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733530' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'cd8b394a-655e-403b-9ac0-99f44563c439', N'96aed832-57a1-4204-ad3c-1d662855e890', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733536' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'cd8b394a-655e-403b-9ac0-99f44563c439', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733541' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ce744950-8172-4392-8663-675d2ab0867b', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733547' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ce744950-8172-4392-8663-675d2ab0867b', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733553' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ce744950-8172-4392-8663-675d2ab0867b', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733558' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ce744950-8172-4392-8663-675d2ab0867b', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733564' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'cedaa45a-ae23-4b6c-ae9d-e5f7811fe90a', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733570' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'cedaa45a-ae23-4b6c-ae9d-e5f7811fe90a', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733576' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd03b2469-f02b-4b4e-99e6-569b49a1252b', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733581' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd03b2469-f02b-4b4e-99e6-569b49a1252b', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733587' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd03b2469-f02b-4b4e-99e6-569b49a1252b', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733593' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd274435a-b02d-4ef7-814d-10ec9660d561', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733599' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd274435a-b02d-4ef7-814d-10ec9660d561', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733604' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd274435a-b02d-4ef7-814d-10ec9660d561', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733609' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd3b101cd-48ef-4b7f-8b34-83347b76e32f', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733615' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd3b101cd-48ef-4b7f-8b34-83347b76e32f', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733620' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd42b1a49-bf1a-499f-94d9-670e0c3f7b99', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733626' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd42b1a49-bf1a-499f-94d9-670e0c3f7b99', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733633' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd42b1a49-bf1a-499f-94d9-670e0c3f7b99', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733638' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733644' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733650' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733656' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'e2532790-0bef-45d7-bd16-81709f211432', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733662' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'da2b21b2-4639-4862-b3c3-ca45837c559c', N'efd2d829-2500-4c66-bd27-586989316647', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733668' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733674' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733680' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733685' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'db60a923-a419-4891-bfa9-6996811a87fd', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733691' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'db60a923-a419-4891-bfa9-6996811a87fd', N'837b4e63-6c22-4508-936d-cb31fcb0a58e', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733696' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'def3e01c-8d48-40d6-86a9-baad5125ffa7', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733702' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'df4e5ab0-1be8-44e0-8099-6c5ba15540bd', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733708' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e09de163-e0cd-46e0-a206-b1c4ca45668c', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733714' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e305757c-3ff1-490d-98d4-a4fe5ca76237', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733720' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e305757c-3ff1-490d-98d4-a4fe5ca76237', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733725' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e305757c-3ff1-490d-98d4-a4fe5ca76237', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733731' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e654a1ee-ce8b-4fd7-bfbd-11699177b91e', N'e2f0e6b6-70d8-410b-b42d-deb2d32e00ae', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733737' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e654a1ee-ce8b-4fd7-bfbd-11699177b91e', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733742' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e7e83a2c-e3d4-4c60-8363-f902fc714422', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733747' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e8412762-7863-4580-b68a-2b0864e9b858', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733754' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e8412762-7863-4580-b68a-2b0864e9b858', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733759' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e8412762-7863-4580-b68a-2b0864e9b858', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733765' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'e8412762-7863-4580-b68a-2b0864e9b858', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733770' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'96aed832-57a1-4204-ad3c-1d662855e890', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733776' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733781' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733788' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ebe2f6da-a76c-48cd-b361-6d652df9a0ae', N'e2f0e6b6-70d8-410b-b42d-deb2d32e00ae', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733795' AS DateTime2))
GO
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ed1f8b57-eff5-4c99-ae7d-963894721ac6', N'21b134fc-b41d-4feb-a647-0b6b7cf87967', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733801' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ed4d65ae-af63-43a5-8252-d0db08c6ac1d', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733807' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ed4d65ae-af63-43a5-8252-d0db08c6ac1d', N'a44b03a7-25d6-4920-a662-013c790297ef', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733813' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ed4d65ae-af63-43a5-8252-d0db08c6ac1d', N'a469291c-45ea-4395-b544-c3f5e2ac9887', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733820' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ed4d65ae-af63-43a5-8252-d0db08c6ac1d', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733826' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733832' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'46f32deb-fd2a-4544-88f4-27e9aaafe0a3', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733838' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733843' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733849' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ef55d12b-edb6-4354-a287-e81f86eb7091', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733854' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ef55d12b-edb6-4354-a287-e81f86eb7091', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733860' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ef55d12b-edb6-4354-a287-e81f86eb7091', N'96aed832-57a1-4204-ad3c-1d662855e890', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733866' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'ef5b58a7-c26b-4f42-a75f-e36a92c0bb33', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733872' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f0a7c6f5-d135-47d7-ac25-2eaea179b80d', N'c842d25a-3950-48d0-baaa-3be138f8ace4', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733878' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f13a3fea-ba34-492a-a277-9c6e4d023ea4', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733883' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f20eef3e-a7d1-4187-a285-05571fd61d0a', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733889' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f2337436-3c31-4125-b735-4cfc38d6a3e9', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733894' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f2337436-3c31-4125-b735-4cfc38d6a3e9', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733900' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f2337436-3c31-4125-b735-4cfc38d6a3e9', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733906' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f2337436-3c31-4125-b735-4cfc38d6a3e9', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733912' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f2756d24-1384-4600-8472-e7df479077d4', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733918' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f4f93a65-6b0f-4c4d-8089-f12b5404b620', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733924' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f4f93a65-6b0f-4c4d-8089-f12b5404b620', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733929' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f54c3200-308d-4a84-b1d5-7f94ece8b523', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733935' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f54c3200-308d-4a84-b1d5-7f94ece8b523', N'837b4e63-6c22-4508-936d-cb31fcb0a58e', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733940' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f60eb2e4-ca30-4cd6-80bb-1d4ba66d799c', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733946' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f60eb2e4-ca30-4cd6-80bb-1d4ba66d799c', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733951' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f60eb2e4-ca30-4cd6-80bb-1d4ba66d799c', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733958' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f60eb2e4-ca30-4cd6-80bb-1d4ba66d799c', N'c842d25a-3950-48d0-baaa-3be138f8ace4', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733963' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f6cc795d-a75a-4ce1-9f67-e15f820b5a43', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733969' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f6cc795d-a75a-4ce1-9f67-e15f820b5a43', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733974' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f6cc795d-a75a-4ce1-9f67-e15f820b5a43', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733980' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f8722bac-7a05-49ca-8ee5-46fd589f07f9', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733985' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f8722bac-7a05-49ca-8ee5-46fd589f07f9', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733991' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f8722bac-7a05-49ca-8ee5-46fd589f07f9', N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4733997' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f8bdeee4-bd07-4594-8e12-291a05831a61', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4734003' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f8bdeee4-bd07-4594-8e12-291a05831a61', N'e2532790-0bef-45d7-bd16-81709f211432', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4734008' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f8bdeee4-bd07-4594-8e12-291a05831a61', N'e2f0e6b6-70d8-410b-b42d-deb2d32e00ae', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4734014' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f8dcbbb7-68e4-4e90-90bf-8a256afcc622', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4734019' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f928b49b-bc95-4d66-9501-d77675761760', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4734025' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f928b49b-bc95-4d66-9501-d77675761760', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.4720000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4734031' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f928b49b-bc95-4d66-9501-d77675761760', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4734037' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'f928b49b-bc95-4d66-9501-d77675761760', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4734043' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4734048' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4734054' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4734059' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4734065' AS DateTime2))
INSERT [dbo].[challenge_participations] ([challenge_uuid], [user_uuid], [created_at], [updated_at]) VALUES (N'fda36f04-08fb-4f32-962c-5bf7d25f3497', N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', CAST(N'2022-02-06T13:34:36.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:36.4734070' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kalekiemu', N'06093559-116a-466f-9f3d-bf57963cb5ba', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'namłócili', N'06093559-116a-466f-9f3d-bf57963cb5ba', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'normistko', N'06093559-116a-466f-9f3d-bf57963cb5ba', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'poślizgom', N'06093559-116a-466f-9f3d-bf57963cb5ba', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wkreślony', N'06093559-116a-466f-9f3d-bf57963cb5ba', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zasalutuj', N'06093559-116a-466f-9f3d-bf57963cb5ba', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ładniutką', N'06093559-116a-466f-9f3d-bf57963cb5ba', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieopętań', N'06093559-116a-466f-9f3d-bf57963cb5ba', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'normistko', N'06093559-116a-466f-9f3d-bf57963cb5ba', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'płoziłbym', N'06093559-116a-466f-9f3d-bf57963cb5ba', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pobierało', N'06093559-116a-466f-9f3d-bf57963cb5ba', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'poślizgom', N'06093559-116a-466f-9f3d-bf57963cb5ba', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'woryszkom', N'06093559-116a-466f-9f3d-bf57963cb5ba', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mecenasce', N'06093559-116a-466f-9f3d-bf57963cb5ba', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'poślizgom', N'06093559-116a-466f-9f3d-bf57963cb5ba', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozsianie', N'06093559-116a-466f-9f3d-bf57963cb5ba', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'torfujemy', N'06093559-116a-466f-9f3d-bf57963cb5ba', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'usidłałaś', N'06093559-116a-466f-9f3d-bf57963cb5ba', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zazbroimy', N'06093559-116a-466f-9f3d-bf57963cb5ba', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przepustkowicze', N'063bb82f-c61b-49d8-bf07-7f226fa8026a', N'2b1b01f3-59ab-472c-a49c-c053b25eb4eb', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'interferencyjną', N'063bb82f-c61b-49d8-bf07-7f226fa8026a', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'masztalerstwach', N'063bb82f-c61b-49d8-bf07-7f226fa8026a', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niegenologiczną', N'063bb82f-c61b-49d8-bf07-7f226fa8026a', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przepustkowicze', N'063bb82f-c61b-49d8-bf07-7f226fa8026a', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'łataczami', N'063d8d0e-64d6-448e-8866-cb01df622849', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nachlacie', N'063d8d0e-64d6-448e-8866-cb01df622849', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podsypało', N'063d8d0e-64d6-448e-8866-cb01df622849', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'duplikatu', N'063d8d0e-64d6-448e-8866-cb01df622849', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'usidłałaś', N'063d8d0e-64d6-448e-8866-cb01df622849', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wygłaskań', N'063d8d0e-64d6-448e-8866-cb01df622849', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'frettage
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'96aed832-57a1-4204-ad3c-1d662855e890', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gnarlier
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'96aed832-57a1-4204-ad3c-1d662855e890', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'jaggeder
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'96aed832-57a1-4204-ad3c-1d662855e890', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tesseral
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'96aed832-57a1-4204-ad3c-1d662855e890', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ungloved
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'96aed832-57a1-4204-ad3c-1d662855e890', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'acoelomi
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'boothage
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'crustate
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'jaggeder
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'parasite
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'suchness
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'utilises
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'descrial
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hogreeve
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'inkstand
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'jaggeder
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mealless
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'patronly
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'simility
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bulimiac
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'challies
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hoofbeat
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'jaggeder
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'quaffers
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'regauges
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sheraton
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ungraced
', N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepastorałkowa', N'0c88f5f8-fe81-40a3-8af2-95927a3e6dc1', N'4217cb86-c05c-436e-a9f6-0b5e5f70db81', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepodkrajaniem', N'0c88f5f8-fe81-40a3-8af2-95927a3e6dc1', N'4217cb86-c05c-436e-a9f6-0b5e5f70db81', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nietasiemkowymi', N'0c88f5f8-fe81-40a3-8af2-95927a3e6dc1', N'4217cb86-c05c-436e-a9f6-0b5e5f70db81', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezarównywaniu', N'0c88f5f8-fe81-40a3-8af2-95927a3e6dc1', N'4217cb86-c05c-436e-a9f6-0b5e5f70db81', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'obiektywizowane', N'0c88f5f8-fe81-40a3-8af2-95927a3e6dc1', N'4217cb86-c05c-436e-a9f6-0b5e5f70db81', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'plumbogummitowi', N'0c88f5f8-fe81-40a3-8af2-95927a3e6dc1', N'4217cb86-c05c-436e-a9f6-0b5e5f70db81', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozdzióbywanemu', N'0c88f5f8-fe81-40a3-8af2-95927a3e6dc1', N'4217cb86-c05c-436e-a9f6-0b5e5f70db81', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niearchiwalnego', N'0c88f5f8-fe81-40a3-8af2-95927a3e6dc1', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niegenologiczną', N'0c88f5f8-fe81-40a3-8af2-95927a3e6dc1', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieodprzęgający', N'0c88f5f8-fe81-40a3-8af2-95927a3e6dc1', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepastorałkowa', N'0c88f5f8-fe81-40a3-8af2-95927a3e6dc1', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieprzymusowość', N'0c88f5f8-fe81-40a3-8af2-95927a3e6dc1', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezatoczkowaty', N'0c88f5f8-fe81-40a3-8af2-95927a3e6dc1', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'obiektywizowane', N'0c88f5f8-fe81-40a3-8af2-95927a3e6dc1', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'znokautowałabym', N'0c88f5f8-fe81-40a3-8af2-95927a3e6dc1', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6450000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepastorałkowa', N'0c88f5f8-fe81-40a3-8af2-95927a3e6dc1', N'46f32deb-fd2a-4544-88f4-27e9aaafe0a3', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dokopujmy', N'0c8e557d-60ea-4b32-8719-5b8d93e44f84', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'jędrniało', N'0c8e557d-60ea-4b32-8719-5b8d93e44f84', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'makijażom', N'0c8e557d-60ea-4b32-8719-5b8d93e44f84', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mecenasce', N'0c8e557d-60ea-4b32-8719-5b8d93e44f84', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'okrwawiło', N'0c8e557d-60ea-4b32-8719-5b8d93e44f84', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'próżniacy', N'0c8e557d-60ea-4b32-8719-5b8d93e44f84', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tonowanie', N'0c8e557d-60ea-4b32-8719-5b8d93e44f84', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cholee
', N'0cfd8571-d336-4df2-aeb1-89596ec5cedb', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cutely
', N'0cfd8571-d336-4df2-aeb1-89596ec5cedb', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'girdle
', N'0cfd8571-d336-4df2-aeb1-89596ec5cedb', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prevue
', N'0cfd8571-d336-4df2-aeb1-89596ec5cedb', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'regalo
', N'0cfd8571-d336-4df2-aeb1-89596ec5cedb', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'snatch
', N'0cfd8571-d336-4df2-aeb1-89596ec5cedb', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sunglo
', N'0cfd8571-d336-4df2-aeb1-89596ec5cedb', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'teenty
', N'0cfd8571-d336-4df2-aeb1-89596ec5cedb', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'barracking
', N'0d0da875-5a47-472f-b852-6c49522f21d9', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'boneflower
', N'0d0da875-5a47-472f-b852-6c49522f21d9', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'invitatory
', N'0d0da875-5a47-472f-b852-6c49522f21d9', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'millesimal
', N'0d0da875-5a47-472f-b852-6c49522f21d9', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'shrineless
', N'0d0da875-5a47-472f-b852-6c49522f21d9', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'theologise
', N'0d0da875-5a47-472f-b852-6c49522f21d9', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'untunneled
', N'0d0da875-5a47-472f-b852-6c49522f21d9', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozjuszenia', N'0e640fb9-f988-436c-98bb-1e3e04fc62e6', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozpracujże', N'0e640fb9-f988-436c-98bb-1e3e04fc62e6', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zagustowała', N'0e640fb9-f988-436c-98bb-1e3e04fc62e6', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'załączonemu', N'0e640fb9-f988-436c-98bb-1e3e04fc62e6', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'akwirowania', N'0e640fb9-f988-436c-98bb-1e3e04fc62e6', N'f5ca7f60-0d49-4c12-bd33-87fbfdec7edd', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dedukującym', N'0e640fb9-f988-436c-98bb-1e3e04fc62e6', N'f5ca7f60-0d49-4c12-bd33-87fbfdec7edd', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niemasowana', N'0e640fb9-f988-436c-98bb-1e3e04fc62e6', N'f5ca7f60-0d49-4c12-bd33-87fbfdec7edd', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nienaćkanie', N'0e640fb9-f988-436c-98bb-1e3e04fc62e6', N'f5ca7f60-0d49-4c12-bd33-87fbfdec7edd', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uszczypliwy', N'0e640fb9-f988-436c-98bb-1e3e04fc62e6', N'f5ca7f60-0d49-4c12-bd33-87fbfdec7edd', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaklaskajże', N'0e640fb9-f988-436c-98bb-1e3e04fc62e6', N'f5ca7f60-0d49-4c12-bd33-87fbfdec7edd', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'załączonemu', N'0e640fb9-f988-436c-98bb-1e3e04fc62e6', N'f5ca7f60-0d49-4c12-bd33-87fbfdec7edd', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'załączonemu', N'0e640fb9-f988-436c-98bb-1e3e04fc62e6', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'stalely
', N'0f19991c-059e-4b87-aad7-6afac408efcb', N'25dde876-8acb-41ee-919f-0cfc5fde07c7', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ephelis
', N'0fe871d4-efbe-482b-b78b-70ecbc93b859', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gluteal
', N'0fe871d4-efbe-482b-b78b-70ecbc93b859', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'oppress
', N'0fe871d4-efbe-482b-b78b-70ecbc93b859', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'athbash
', N'0fe871d4-efbe-482b-b78b-70ecbc93b859', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fatally
', N'0fe871d4-efbe-482b-b78b-70ecbc93b859', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reclose
', N'0fe871d4-efbe-482b-b78b-70ecbc93b859', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'twanger
', N'0fe871d4-efbe-482b-b78b-70ecbc93b859', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'upcurls
', N'0fe871d4-efbe-482b-b78b-70ecbc93b859', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'regauges
', N'10b60554-3abe-4e43-b1b1-96d35a1049a6', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'yestreen
', N'10b60554-3abe-4e43-b1b1-96d35a1049a6', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'regauges
', N'10b60554-3abe-4e43-b1b1-96d35a1049a6', N'7956ec3d-07d9-404e-b517-29c315e45119', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'benefact
', N'10b60554-3abe-4e43-b1b1-96d35a1049a6', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bushfire
', N'10b60554-3abe-4e43-b1b1-96d35a1049a6', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cirrhose
', N'10b60554-3abe-4e43-b1b1-96d35a1049a6', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fireburn
', N'10b60554-3abe-4e43-b1b1-96d35a1049a6', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'groomlet
', N'10b60554-3abe-4e43-b1b1-96d35a1049a6', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pasquils
', N'10b60554-3abe-4e43-b1b1-96d35a1049a6', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'regauges
', N'10b60554-3abe-4e43-b1b1-96d35a1049a6', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ajentek', N'11734c10-bda2-483e-9dbb-04c961fe86a9', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dowołaj', N'11734c10-bda2-483e-9dbb-04c961fe86a9', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pochlip', N'11734c10-bda2-483e-9dbb-04c961fe86a9', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'toposem', N'11734c10-bda2-483e-9dbb-04c961fe86a9', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odcieki', N'11734c10-bda2-483e-9dbb-04c961fe86a9', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'popłaca', N'11734c10-bda2-483e-9dbb-04c961fe86a9', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'klamoty', N'11734c10-bda2-483e-9dbb-04c961fe86a9', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odcieki', N'11734c10-bda2-483e-9dbb-04c961fe86a9', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'shavings
', N'142e2de5-7fd4-4f0b-8411-fcd5e4e2aaae', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ammoniuret
', N'14a47bcd-3b7c-447b-91aa-76be52ce8b1f', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'echinulate
', N'14a47bcd-3b7c-447b-91aa-76be52ce8b1f', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'harvestbug
', N'14a47bcd-3b7c-447b-91aa-76be52ce8b1f', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'muscleless
', N'14a47bcd-3b7c-447b-91aa-76be52ce8b1f', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'simpletons
', N'14a47bcd-3b7c-447b-91aa-76be52ce8b1f', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trematodes
', N'14a47bcd-3b7c-447b-91aa-76be52ce8b1f', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'vegeteness
', N'14a47bcd-3b7c-447b-91aa-76be52ce8b1f', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'afterstudy
', N'14a47bcd-3b7c-447b-91aa-76be52ce8b1f', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ammoniuret
', N'14a47bcd-3b7c-447b-91aa-76be52ce8b1f', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bromthymol
', N'14a47bcd-3b7c-447b-91aa-76be52ce8b1f', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'intendente
', N'14a47bcd-3b7c-447b-91aa-76be52ce8b1f', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'leptandrin
', N'14a47bcd-3b7c-447b-91aa-76be52ce8b1f', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lithophyll
', N'14a47bcd-3b7c-447b-91aa-76be52ce8b1f', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'varicocele
', N'14a47bcd-3b7c-447b-91aa-76be52ce8b1f', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'muscleless
', N'14a47bcd-3b7c-447b-91aa-76be52ce8b1f', N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'semiyearly
', N'14a47bcd-3b7c-447b-91aa-76be52ce8b1f', N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spiderflower
', N'14f749e5-5b93-49b2-84ee-33d9353b3261', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tropospheric
', N'14f749e5-5b93-49b2-84ee-33d9353b3261', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'acetyliodide
', N'14f749e5-5b93-49b2-84ee-33d9353b3261', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'disregardant
', N'14f749e5-5b93-49b2-84ee-33d9353b3261', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'endocarditic
', N'14f749e5-5b93-49b2-84ee-33d9353b3261', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'xalostockite
', N'14f749e5-5b93-49b2-84ee-33d9353b3261', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'disregardant
', N'14f749e5-5b93-49b2-84ee-33d9353b3261', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'abbreviators
', N'14f749e5-5b93-49b2-84ee-33d9353b3261', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'asperuloside
', N'14f749e5-5b93-49b2-84ee-33d9353b3261', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'committeeman
', N'14f749e5-5b93-49b2-84ee-33d9353b3261', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nephelometer
', N'14f749e5-5b93-49b2-84ee-33d9353b3261', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'postscutella
', N'14f749e5-5b93-49b2-84ee-33d9353b3261', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rhineurynter
', N'14f749e5-5b93-49b2-84ee-33d9353b3261', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unvigorously
', N'14f749e5-5b93-49b2-84ee-33d9353b3261', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unwassailing
', N'14f749e5-5b93-49b2-84ee-33d9353b3261', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naplótł', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odmiano', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pochlip', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'porysuj', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tenreku', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trzymam', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'workach', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wrębiło', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'porysuj', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'7956ec3d-07d9-404e-b517-29c315e45119', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sercową', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'7956ec3d-07d9-404e-b517-29c315e45119', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'siorpań', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'7956ec3d-07d9-404e-b517-29c315e45119', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'workach', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'7956ec3d-07d9-404e-b517-29c315e45119', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wzwodem', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'7956ec3d-07d9-404e-b517-29c315e45119', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'workach', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'czartów', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fiderem', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lonżach', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'omyciem', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pędraka', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'workach', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wwlekła', N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ammotherapy
', N'17542693-cac1-455b-889c-e115b27e4320', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gametophyll
', N'17542693-cac1-455b-889c-e115b27e4320', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'imperforata
', N'17542693-cac1-455b-889c-e115b27e4320', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'retrocaecal
', N'17542693-cac1-455b-889c-e115b27e4320', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'typicalness
', N'17542693-cac1-455b-889c-e115b27e4320', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'misemployed
', N'17542693-cac1-455b-889c-e115b27e4320', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sphaeridial
', N'17542693-cac1-455b-889c-e115b27e4320', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'xerophagies
', N'17542693-cac1-455b-889c-e115b27e4320', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'recorporify
', N'17542693-cac1-455b-889c-e115b27e4320', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'afterstudy
', N'1b7b3d7c-de2a-4f8c-acd2-73bf92a86402', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'latecomers
', N'1b7b3d7c-de2a-4f8c-acd2-73bf92a86402', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'noneconomy
', N'1b7b3d7c-de2a-4f8c-acd2-73bf92a86402', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dampishly
', N'1cdaa460-4b96-4bb7-afd1-1beeda32c57d', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pathetism
', N'1cdaa460-4b96-4bb7-afd1-1beeda32c57d', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'blachowniach', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kałożerstwom', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'łagodniejący', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nienałogowej', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'powyłupujcie', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sojuszniczek', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'storpedujcie', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zdmuchujecie', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'opiniowałbyś', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'7956ec3d-07d9-404e-b517-29c315e45119', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pograbiejesz', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'7956ec3d-07d9-404e-b517-29c315e45119', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przeganianie', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'7956ec3d-07d9-404e-b517-29c315e45119', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'smorodinówek', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'7956ec3d-07d9-404e-b517-29c315e45119', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wróżbiarkach', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'7956ec3d-07d9-404e-b517-29c315e45119', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zabukowaniem', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'7956ec3d-07d9-404e-b517-29c315e45119', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zeskromnieli', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'7956ec3d-07d9-404e-b517-29c315e45119', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zeświecczcie', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'7956ec3d-07d9-404e-b517-29c315e45119', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'komentatorkę', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nienapasioną', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pozasiadajmy', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozścielanej', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sojuszniczek', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unasienniamy', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zhasalibyśmy', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'koncentracje', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'krochmaleniu', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepodłapana', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepsiknięta', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'racjonowania', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaplombujmyż', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zeświecczcie', N'1f5213ff-313f-4c19-874e-95c794efa89b', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieprzebaczalny', N'1fdc49f7-9cd2-4e1c-b1d3-ed12f6962445', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieprzerzucaniu', N'1fdc49f7-9cd2-4e1c-b1d3-ed12f6962445', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nietasiemkowymi', N'1fdc49f7-9cd2-4e1c-b1d3-ed12f6962445', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozmazgajającym', N'1fdc49f7-9cd2-4e1c-b1d3-ed12f6962445', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'znokautowałabym', N'1fdc49f7-9cd2-4e1c-b1d3-ed12f6962445', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ammotherapy
', N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'decahydrate
', N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'formicicide
', N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gametophyll
', N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'germinating
', N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'laparoscope
', N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonstorable
', N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'peroxidized
', N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'radiomovies
', N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reharmonize
', N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'aftergrowth
', N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ammotherapy
', N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'microcosmus
', N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odontotrypy
', N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'recorporify
', N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'speronaroes
', N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'typicalness
', N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'xerophagies
', N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chondroganoidei
', N'229c4f6e-976e-46ec-b165-2691dad8ee34', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'microanatomical
', N'229c4f6e-976e-46ec-b165-2691dad8ee34', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overaffirmation
', N'229c4f6e-976e-46ec-b165-2691dad8ee34', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'paterfamiliases
', N'229c4f6e-976e-46ec-b165-2691dad8ee34', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'patripassianism
', N'229c4f6e-976e-46ec-b165-2691dad8ee34', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'precontribution
', N'229c4f6e-976e-46ec-b165-2691dad8ee34', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'subcommissarial
', N'229c4f6e-976e-46ec-b165-2691dad8ee34', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fissidentaceous
', N'229c4f6e-976e-46ec-b165-2691dad8ee34', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overaffirmation
', N'229c4f6e-976e-46ec-b165-2691dad8ee34', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'precontribution
', N'229c4f6e-976e-46ec-b165-2691dad8ee34', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'promiscuousness
', N'229c4f6e-976e-46ec-b165-2691dad8ee34', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'subcommissarial
', N'229c4f6e-976e-46ec-b165-2691dad8ee34', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'formicicide
', N'2382d2d3-eb3c-4bc0-9f18-8ace2e60ce85', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'topocentric
', N'2382d2d3-eb3c-4bc0-9f18-8ace2e60ce85', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'undiffusive
', N'2382d2d3-eb3c-4bc0-9f18-8ace2e60ce85', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'recontracts
', N'2382d2d3-eb3c-4bc0-9f18-8ace2e60ce85', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chinchayote
', N'2382d2d3-eb3c-4bc0-9f18-8ace2e60ce85', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dracontites
', N'2382d2d3-eb3c-4bc0-9f18-8ace2e60ce85', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'premidnight
', N'2382d2d3-eb3c-4bc0-9f18-8ace2e60ce85', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'recontracts
', N'2382d2d3-eb3c-4bc0-9f18-8ace2e60ce85', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'retrocaecal
', N'2382d2d3-eb3c-4bc0-9f18-8ace2e60ce85', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'xenophanean
', N'2382d2d3-eb3c-4bc0-9f18-8ace2e60ce85', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonodoriferously
', N'24cba4c3-a464-4fc0-9acf-9991a1d5f2f5', N'572b7747-e3eb-4ccf-8211-f013d3618acd', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'precorrespondent
', N'24cba4c3-a464-4fc0-9acf-9991a1d5f2f5', N'572b7747-e3eb-4ccf-8211-f013d3618acd', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pseudomonastical
', N'24cba4c3-a464-4fc0-9acf-9991a1d5f2f5', N'572b7747-e3eb-4ccf-8211-f013d3618acd', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'selfpreservatory
', N'24cba4c3-a464-4fc0-9acf-9991a1d5f2f5', N'572b7747-e3eb-4ccf-8211-f013d3618acd', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cytoarchitecture
', N'24cba4c3-a464-4fc0-9acf-9991a1d5f2f5', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'institutionalise
', N'24cba4c3-a464-4fc0-9acf-9991a1d5f2f5', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'noncleistogamous
', N'24cba4c3-a464-4fc0-9acf-9991a1d5f2f5', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonodoriferously
', N'24cba4c3-a464-4fc0-9acf-9991a1d5f2f5', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'perigastrulation
', N'24cba4c3-a464-4fc0-9acf-9991a1d5f2f5', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'precorrespondent
', N'24cba4c3-a464-4fc0-9acf-9991a1d5f2f5', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'selfpreservatory
', N'24cba4c3-a464-4fc0-9acf-9991a1d5f2f5', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'valetudinariness
', N'24cba4c3-a464-4fc0-9acf-9991a1d5f2f5', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'appliques
', N'2706580c-0fa0-4934-bdf1-7868b60f6ab2', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'benzoxate
', N'2706580c-0fa0-4934-bdf1-7868b60f6ab2', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'collegium
', N'2706580c-0fa0-4934-bdf1-7868b60f6ab2', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'benzoxate
', N'27b3113d-1d2e-48a8-bd96-da994b22aaec', N'0846669c-07f1-41f4-9381-e038ec3351d6', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dyslectic
', N'27b3113d-1d2e-48a8-bd96-da994b22aaec', N'0846669c-07f1-41f4-9381-e038ec3351d6', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'grassiest
', N'27b3113d-1d2e-48a8-bd96-da994b22aaec', N'0846669c-07f1-41f4-9381-e038ec3351d6', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'iridaceae
', N'27b3113d-1d2e-48a8-bd96-da994b22aaec', N'0846669c-07f1-41f4-9381-e038ec3351d6', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pintadoes
', N'27b3113d-1d2e-48a8-bd96-da994b22aaec', N'0846669c-07f1-41f4-9381-e038ec3351d6', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'xenagogue
', N'27b3113d-1d2e-48a8-bd96-da994b22aaec', N'0846669c-07f1-41f4-9381-e038ec3351d6', CAST(N'2022-02-06T13:34:36.6460000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bromobenzenu', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kabaretujemy', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naopowiadaną', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nefelometrom', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieparobkowa', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odwróciłyśmy', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'różowiejcież', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kabaretujemy', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'łagodniejący', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naładowałoby', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nielernejscy', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepodłapana', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'orkiestronie', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozpatrujmyż', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wróżbiarkach', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kościańskich', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'łagodniejący', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nefelometrom', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przygłaszali', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wiśniewskiej', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wypiękniliby', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zhasalibyśmy', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'demodulatory', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niegładzenia', N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fryzowałam', N'29143e5b-7753-4b9c-9d43-7c62bef2f975', N'037a6380-46ef-4327-b1bb-5aef7a64dbc5', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'obkupiwszy', N'29143e5b-7753-4b9c-9d43-7c62bef2f975', N'037a6380-46ef-4327-b1bb-5aef7a64dbc5', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'paszowicki', N'29143e5b-7753-4b9c-9d43-7c62bef2f975', N'037a6380-46ef-4327-b1bb-5aef7a64dbc5', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rachowałem', N'29143e5b-7753-4b9c-9d43-7c62bef2f975', N'037a6380-46ef-4327-b1bb-5aef7a64dbc5', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ujadaniach', N'29143e5b-7753-4b9c-9d43-7c62bef2f975', N'037a6380-46ef-4327-b1bb-5aef7a64dbc5', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zatajałbym', N'29143e5b-7753-4b9c-9d43-7c62bef2f975', N'037a6380-46ef-4327-b1bb-5aef7a64dbc5', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'geesowsku', N'29ea49f2-602e-4fb6-b0c6-4c869ecfd65e', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odspoiłby', N'29ea49f2-602e-4fb6-b0c6-4c869ecfd65e', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wkreślony', N'29ea49f2-602e-4fb6-b0c6-4c869ecfd65e', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieulowym', N'29ea49f2-602e-4fb6-b0c6-4c869ecfd65e', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pojadajmy', N'29ea49f2-602e-4fb6-b0c6-4c869ecfd65e', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'usidłałaś', N'29ea49f2-602e-4fb6-b0c6-4c869ecfd65e', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gadkujmyż', N'29ea49f2-602e-4fb6-b0c6-4c869ecfd65e', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieulowym', N'29ea49f2-602e-4fb6-b0c6-4c869ecfd65e', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieulowym', N'29ea49f2-602e-4fb6-b0c6-4c869ecfd65e', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dicier
', N'2d05b32d-c4af-49cf-8dcb-a8f8739b8529', N'a469291c-45ea-4395-b544-c3f5e2ac9887', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'homing
', N'2d05b32d-c4af-49cf-8dcb-a8f8739b8529', N'a469291c-45ea-4395-b544-c3f5e2ac9887', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kubong
', N'2d05b32d-c4af-49cf-8dcb-a8f8739b8529', N'a469291c-45ea-4395-b544-c3f5e2ac9887', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'muscle
', N'2d05b32d-c4af-49cf-8dcb-a8f8739b8529', N'a469291c-45ea-4395-b544-c3f5e2ac9887', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reeked
', N'2d05b32d-c4af-49cf-8dcb-a8f8739b8529', N'a469291c-45ea-4395-b544-c3f5e2ac9887', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'streen
', N'2d05b32d-c4af-49cf-8dcb-a8f8739b8529', N'a469291c-45ea-4395-b544-c3f5e2ac9887', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tottum
', N'2d05b32d-c4af-49cf-8dcb-a8f8739b8529', N'a469291c-45ea-4395-b544-c3f5e2ac9887', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'barker
', N'2d05b32d-c4af-49cf-8dcb-a8f8739b8529', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reeked
', N'2d05b32d-c4af-49cf-8dcb-a8f8739b8529', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'regalo
', N'2d05b32d-c4af-49cf-8dcb-a8f8739b8529', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'toquet
', N'2d05b32d-c4af-49cf-8dcb-a8f8739b8529', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ewangelikom', N'2f803c3d-16c7-456e-83e7-cfb72ed08ec4', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'liofobowych', N'2f803c3d-16c7-456e-83e7-cfb72ed08ec4', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niemrugnięć', N'2f803c3d-16c7-456e-83e7-cfb72ed08ec4', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pastelistów', N'2f803c3d-16c7-456e-83e7-cfb72ed08ec4', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podiwanieni', N'2f803c3d-16c7-456e-83e7-cfb72ed08ec4', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przybliżone', N'2f803c3d-16c7-456e-83e7-cfb72ed08ec4', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wsztukowane', N'2f803c3d-16c7-456e-83e7-cfb72ed08ec4', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przybliżone', N'2f803c3d-16c7-456e-83e7-cfb72ed08ec4', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przyczepami', N'2f803c3d-16c7-456e-83e7-cfb72ed08ec4', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ryżobrodego', N'2f803c3d-16c7-456e-83e7-cfb72ed08ec4', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wytrzeźwiam', N'2f803c3d-16c7-456e-83e7-cfb72ed08ec4', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lokacyjnych', N'3155e8c9-8bb8-42cc-bf80-94f1aed72ff3', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'miligramowy', N'3155e8c9-8bb8-42cc-bf80-94f1aed72ff3', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'następowały', N'3155e8c9-8bb8-42cc-bf80-94f1aed72ff3', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ruszczących', N'3155e8c9-8bb8-42cc-bf80-94f1aed72ff3', N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nasarkałbyś', N'3155e8c9-8bb8-42cc-bf80-94f1aed72ff3', N'7956ec3d-07d9-404e-b517-29c315e45119', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ruszczących', N'3155e8c9-8bb8-42cc-bf80-94f1aed72ff3', N'7956ec3d-07d9-404e-b517-29c315e45119', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'artemis
', N'3180cfb0-4434-4b3a-8434-3d272021016f', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gercrow
', N'3180cfb0-4434-4b3a-8434-3d272021016f', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'girosol
', N'3180cfb0-4434-4b3a-8434-3d272021016f', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'justers
', N'3180cfb0-4434-4b3a-8434-3d272021016f', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mistook
', N'3180cfb0-4434-4b3a-8434-3d272021016f', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sakeber
', N'3180cfb0-4434-4b3a-8434-3d272021016f', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tantawy
', N'3180cfb0-4434-4b3a-8434-3d272021016f', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'diobely
', N'3180cfb0-4434-4b3a-8434-3d272021016f', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'flotsen
', N'3180cfb0-4434-4b3a-8434-3d272021016f', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'garners
', N'3180cfb0-4434-4b3a-8434-3d272021016f', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gercrow
', N'3180cfb0-4434-4b3a-8434-3d272021016f', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'phonies
', N'3180cfb0-4434-4b3a-8434-3d272021016f', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sakeber
', N'3180cfb0-4434-4b3a-8434-3d272021016f', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'towages
', N'3180cfb0-4434-4b3a-8434-3d272021016f', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gajowcem', N'32b744fe-35e1-44c4-a6cf-4d5558c8329d', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chiragro', N'32b744fe-35e1-44c4-a6cf-4d5558c8329d', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dognicia', N'32b744fe-35e1-44c4-a6cf-4d5558c8329d', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gajowcem', N'32b744fe-35e1-44c4-a6cf-4d5558c8329d', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gorzenie', N'32b744fe-35e1-44c4-a6cf-4d5558c8329d', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wrogiego', N'32b744fe-35e1-44c4-a6cf-4d5558c8329d', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zagnoiły', N'32b744fe-35e1-44c4-a6cf-4d5558c8329d', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'deflektometrami', N'37ede4fe-d321-41e5-8907-d63de5e16bc1', N'0aa51811-6ba5-47f1-b2b8-4ae519845a0b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dopieralibyście', N'37ede4fe-d321-41e5-8907-d63de5e16bc1', N'0aa51811-6ba5-47f1-b2b8-4ae519845a0b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepomasowaniem', N'37ede4fe-d321-41e5-8907-d63de5e16bc1', N'0aa51811-6ba5-47f1-b2b8-4ae519845a0b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepowykładanym', N'37ede4fe-d321-41e5-8907-d63de5e16bc1', N'0aa51811-6ba5-47f1-b2b8-4ae519845a0b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieprzerzucaniu', N'37ede4fe-d321-41e5-8907-d63de5e16bc1', N'0aa51811-6ba5-47f1-b2b8-4ae519845a0b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'petrarkowskiego', N'37ede4fe-d321-41e5-8907-d63de5e16bc1', N'0aa51811-6ba5-47f1-b2b8-4ae519845a0b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'umożliwialiście', N'37ede4fe-d321-41e5-8907-d63de5e16bc1', N'0aa51811-6ba5-47f1-b2b8-4ae519845a0b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ekstraspekcjach', N'37ede4fe-d321-41e5-8907-d63de5e16bc1', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezaślepiający', N'37ede4fe-d321-41e5-8907-d63de5e16bc1', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przesuwnikowych', N'37ede4fe-d321-41e5-8907-d63de5e16bc1', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'amyloplastid
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nephelometer
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'opisthodetic
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'originatress
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'repatriating
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'strumousness
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uncarbonated
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'apometabolic
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'charivariing
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'disregardant
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'galactosemic
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'strumousness
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'entosternite
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'galactosemic
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'holosomatous
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overreliance
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'abbreviators
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'disregardant
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fraternation
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'galactosemic
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overreliance
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'semibachelor
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sporangiolum
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uncarbonated
', N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'befluster
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'beworries
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hyponymic
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'injectors
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lamellule
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reladling
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'stumpwise
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'witnesses
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'adsorbate
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'apennines
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gustatory
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'injectors
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'millerole
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'paguridae
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reanimate
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'arracacia
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lipomyoma
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'microfilm
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rhopalium
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'stumpwise
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'volkslied
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'millerole
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c842d25a-3950-48d0-baaa-3be138f8ace4', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unlegible
', N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'c842d25a-3950-48d0-baaa-3be138f8ace4', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'featherhead
', N'39d441db-46a1-46b2-a2e4-ba3ac9822570', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overservice
', N'39d441db-46a1-46b2-a2e4-ba3ac9822570', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'recorporify
', N'39d441db-46a1-46b2-a2e4-ba3ac9822570', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'supracostal
', N'39d441db-46a1-46b2-a2e4-ba3ac9822570', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'typicalness
', N'39d441db-46a1-46b2-a2e4-ba3ac9822570', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zygophyceae
', N'39d441db-46a1-46b2-a2e4-ba3ac9822570', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'caudotibial
', N'39d441db-46a1-46b2-a2e4-ba3ac9822570', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'misemployed
', N'39d441db-46a1-46b2-a2e4-ba3ac9822570', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'solaceproof
', N'39d441db-46a1-46b2-a2e4-ba3ac9822570', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'featherhead
', N'39d441db-46a1-46b2-a2e4-ba3ac9822570', N'34849063-3080-40ca-b64a-205dbf62e4f2', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dundrearies
', N'39d441db-46a1-46b2-a2e4-ba3ac9822570', N'407691e8-1a33-4c43-ab9c-0193bc408464', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'featherhead
', N'39d441db-46a1-46b2-a2e4-ba3ac9822570', N'407691e8-1a33-4c43-ab9c-0193bc408464', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'merostomous
', N'39d441db-46a1-46b2-a2e4-ba3ac9822570', N'407691e8-1a33-4c43-ab9c-0193bc408464', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pedagogying
', N'39d441db-46a1-46b2-a2e4-ba3ac9822570', N'407691e8-1a33-4c43-ab9c-0193bc408464', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'napaść', N'3a6b91a6-0ab3-45b2-b9ee-d6a7cdef325c', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rąbków', N'3a6b91a6-0ab3-45b2-b9ee-d6a7cdef325c', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sektów', N'3a6b91a6-0ab3-45b2-b9ee-d6a7cdef325c', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'szreka', N'3a6b91a6-0ab3-45b2-b9ee-d6a7cdef325c', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'osmoli', N'3a6b91a6-0ab3-45b2-b9ee-d6a7cdef325c', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rąbków', N'3a6b91a6-0ab3-45b2-b9ee-d6a7cdef325c', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sektów', N'3a6b91a6-0ab3-45b2-b9ee-d6a7cdef325c', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gezami', N'3a6b91a6-0ab3-45b2-b9ee-d6a7cdef325c', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mopuję', N'3a6b91a6-0ab3-45b2-b9ee-d6a7cdef325c', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'napaść', N'3a6b91a6-0ab3-45b2-b9ee-d6a7cdef325c', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'osmoli', N'3a6b91a6-0ab3-45b2-b9ee-d6a7cdef325c', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sektów', N'3a6b91a6-0ab3-45b2-b9ee-d6a7cdef325c', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uczniu', N'3a6b91a6-0ab3-45b2-b9ee-d6a7cdef325c', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'analagous
', N'3ddc6f45-c9f3-464c-9f5d-6fd26638dcaf', N'2b1b01f3-59ab-472c-a49c-c053b25eb4eb', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'beworries
', N'3ddc6f45-c9f3-464c-9f5d-6fd26638dcaf', N'2b1b01f3-59ab-472c-a49c-c053b25eb4eb', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dungarees
', N'3ddc6f45-c9f3-464c-9f5d-6fd26638dcaf', N'2b1b01f3-59ab-472c-a49c-c053b25eb4eb', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'goldfinny
', N'3ddc6f45-c9f3-464c-9f5d-6fd26638dcaf', N'2b1b01f3-59ab-472c-a49c-c053b25eb4eb', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gustatory
', N'3ddc6f45-c9f3-464c-9f5d-6fd26638dcaf', N'2b1b01f3-59ab-472c-a49c-c053b25eb4eb', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'iridaceae
', N'3ddc6f45-c9f3-464c-9f5d-6fd26638dcaf', N'2b1b01f3-59ab-472c-a49c-c053b25eb4eb', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'microfilm
', N'3ddc6f45-c9f3-464c-9f5d-6fd26638dcaf', N'2b1b01f3-59ab-472c-a49c-c053b25eb4eb', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'beworries
', N'3ddc6f45-c9f3-464c-9f5d-6fd26638dcaf', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'outpushed
', N'3ddc6f45-c9f3-464c-9f5d-6fd26638dcaf', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'beworries
', N'3ddc6f45-c9f3-464c-9f5d-6fd26638dcaf', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'flycaster
', N'3ddc6f45-c9f3-464c-9f5d-6fd26638dcaf', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gustatory
', N'3ddc6f45-c9f3-464c-9f5d-6fd26638dcaf', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mutilates
', N'3ddc6f45-c9f3-464c-9f5d-6fd26638dcaf', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tripodian
', N'3ddc6f45-c9f3-464c-9f5d-6fd26638dcaf', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unbrittle
', N'3ddc6f45-c9f3-464c-9f5d-6fd26638dcaf', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'assumes
', N'3ddd38bb-32f0-4725-b6f3-731e47a79049', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'deplete
', N'3ddd38bb-32f0-4725-b6f3-731e47a79049', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'immerse
', N'3ddd38bb-32f0-4725-b6f3-731e47a79049', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'jiveass
', N'3ddd38bb-32f0-4725-b6f3-731e47a79049', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'moronic
', N'3ddd38bb-32f0-4725-b6f3-731e47a79049', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'phonies
', N'3ddd38bb-32f0-4725-b6f3-731e47a79049', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wailing
', N'3ddd38bb-32f0-4725-b6f3-731e47a79049', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ambury
', N'3e65e949-f091-40a1-970c-d05184575d70', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'toping
', N'3e65e949-f091-40a1-970c-d05184575d70', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'toquet
', N'3e65e949-f091-40a1-970c-d05184575d70', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'arbute
', N'3e65e949-f091-40a1-970c-d05184575d70', N'9f85aedf-6139-484b-9fc6-f9ea39e50079', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'edible
', N'3e65e949-f091-40a1-970c-d05184575d70', N'9f85aedf-6139-484b-9fc6-f9ea39e50079', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sunglo
', N'3e65e949-f091-40a1-970c-d05184575d70', N'9f85aedf-6139-484b-9fc6-f9ea39e50079', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'jaeger
', N'3e65e949-f091-40a1-970c-d05184575d70', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'proode
', N'3e65e949-f091-40a1-970c-d05184575d70', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reperk
', N'3e65e949-f091-40a1-970c-d05184575d70', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tingly
', N'3e65e949-f091-40a1-970c-d05184575d70', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'varnas
', N'3e65e949-f091-40a1-970c-d05184575d70', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zariba
', N'3e65e949-f091-40a1-970c-d05184575d70', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'arbute
', N'3e65e949-f091-40a1-970c-d05184575d70', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'blonds
', N'3e65e949-f091-40a1-970c-d05184575d70', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cuecas
', N'3e65e949-f091-40a1-970c-d05184575d70', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cyanol
', N'3e65e949-f091-40a1-970c-d05184575d70', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sunglo
', N'3e65e949-f091-40a1-970c-d05184575d70', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'theory
', N'3e65e949-f091-40a1-970c-d05184575d70', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'toping
', N'3e65e949-f091-40a1-970c-d05184575d70', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trojan
', N'3e65e949-f091-40a1-970c-d05184575d70', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bromobenzenu', N'3f668179-03a9-4871-b578-406c09ec4798', N'efd2d829-2500-4c66-bd27-586989316647', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przedpisemne', N'3f668179-03a9-4871-b578-406c09ec4798', N'efd2d829-2500-4c66-bd27-586989316647', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kapcanieniom', N'3fee4164-d1ca-499d-81ff-ea4c0a4633aa', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niedunitowej', N'3fee4164-d1ca-499d-81ff-ea4c0a4633aa', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niesądzących', N'3fee4164-d1ca-499d-81ff-ea4c0a4633aa', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pokształciła', N'3fee4164-d1ca-499d-81ff-ea4c0a4633aa', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sojuszniczek', N'3fee4164-d1ca-499d-81ff-ea4c0a4633aa', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zdmuchujecie', N'3fee4164-d1ca-499d-81ff-ea4c0a4633aa', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'demaskowałem', N'3fee4164-d1ca-499d-81ff-ea4c0a4633aa', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'horodelskiej', N'3fee4164-d1ca-499d-81ff-ea4c0a4633aa', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kościańskich', N'3fee4164-d1ca-499d-81ff-ea4c0a4633aa', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kraniometryj', N'3fee4164-d1ca-499d-81ff-ea4c0a4633aa', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6470000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieponatykań', N'3fee4164-d1ca-499d-81ff-ea4c0a4633aa', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sojuszniczek', N'3fee4164-d1ca-499d-81ff-ea4c0a4633aa', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zdmuchujecie', N'3fee4164-d1ca-499d-81ff-ea4c0a4633aa', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sojuszniczek', N'3fee4164-d1ca-499d-81ff-ea4c0a4633aa', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'udeptałyście', N'3fee4164-d1ca-499d-81ff-ea4c0a4633aa', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaminowujesz', N'3fee4164-d1ca-499d-81ff-ea4c0a4633aa', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'camoca
', N'43c52861-4420-4abd-a679-3be7bc025008', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'graeme
', N'43c52861-4420-4abd-a679-3be7bc025008', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ampery
', N'43c52861-4420-4abd-a679-3be7bc025008', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'brines
', N'43c52861-4420-4abd-a679-3be7bc025008', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cunyie
', N'43c52861-4420-4abd-a679-3be7bc025008', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'edible
', N'43c52861-4420-4abd-a679-3be7bc025008', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'homing
', N'43c52861-4420-4abd-a679-3be7bc025008', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'regalo
', N'43c52861-4420-4abd-a679-3be7bc025008', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'araise
', N'43c52861-4420-4abd-a679-3be7bc025008', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nitril
', N'43c52861-4420-4abd-a679-3be7bc025008', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'vatful
', N'43c52861-4420-4abd-a679-3be7bc025008', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'acylal
', N'43c52861-4420-4abd-a679-3be7bc025008', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'coneen
', N'43c52861-4420-4abd-a679-3be7bc025008', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'homing
', N'43c52861-4420-4abd-a679-3be7bc025008', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'miting
', N'43c52861-4420-4abd-a679-3be7bc025008', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dyslokacyjnymi', N'46340f04-eb26-4fcc-b518-eae6d7b95972', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niearkansaskim', N'46340f04-eb26-4fcc-b518-eae6d7b95972', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieaspiracyjna', N'46340f04-eb26-4fcc-b518-eae6d7b95972', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niewszeptanemu', N'46340f04-eb26-4fcc-b518-eae6d7b95972', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niewyfrezowani', N'46340f04-eb26-4fcc-b518-eae6d7b95972', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odpełźnięciami', N'46340f04-eb26-4fcc-b518-eae6d7b95972', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieaspiracyjna', N'46340f04-eb26-4fcc-b518-eae6d7b95972', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zdetonowaniach', N'46340f04-eb26-4fcc-b518-eae6d7b95972', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kolposkopowego', N'46340f04-eb26-4fcc-b518-eae6d7b95972', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieaspiracyjna', N'46340f04-eb26-4fcc-b518-eae6d7b95972', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cuecas
', N'478e0a76-88d2-400a-956f-872c11b56001', N'25dde876-8acb-41ee-919f-0cfc5fde07c7', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fathom
', N'478e0a76-88d2-400a-956f-872c11b56001', N'25dde876-8acb-41ee-919f-0cfc5fde07c7', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'acylal
', N'478e0a76-88d2-400a-956f-872c11b56001', N'2b1b01f3-59ab-472c-a49c-c053b25eb4eb', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dicier
', N'478e0a76-88d2-400a-956f-872c11b56001', N'2b1b01f3-59ab-472c-a49c-c053b25eb4eb', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prolia
', N'478e0a76-88d2-400a-956f-872c11b56001', N'2b1b01f3-59ab-472c-a49c-c053b25eb4eb', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bouncy
', N'478e0a76-88d2-400a-956f-872c11b56001', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'geests
', N'478e0a76-88d2-400a-956f-872c11b56001', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tingly
', N'478e0a76-88d2-400a-956f-872c11b56001', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'toquet
', N'478e0a76-88d2-400a-956f-872c11b56001', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'acylal
', N'478e0a76-88d2-400a-956f-872c11b56001', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'girdle
', N'478e0a76-88d2-400a-956f-872c11b56001', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lotong
', N'478e0a76-88d2-400a-956f-872c11b56001', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prolia
', N'478e0a76-88d2-400a-956f-872c11b56001', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'snatch
', N'478e0a76-88d2-400a-956f-872c11b56001', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'teenty
', N'478e0a76-88d2-400a-956f-872c11b56001', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tingly
', N'478e0a76-88d2-400a-956f-872c11b56001', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'varnas
', N'478e0a76-88d2-400a-956f-872c11b56001', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'interioryzację', N'48e0b390-b18c-43a2-869b-973ed8b3ef7e', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niechlupotliwą', N'48e0b390-b18c-43a2-869b-973ed8b3ef7e', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieskwarkowego', N'48e0b390-b18c-43a2-869b-973ed8b3ef7e', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odpełźnięciami', N'48e0b390-b18c-43a2-869b-973ed8b3ef7e', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieoziębianiom', N'48e0b390-b18c-43a2-869b-973ed8b3ef7e', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ponastrajaliby', N'48e0b390-b18c-43a2-869b-973ed8b3ef7e', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wpieprzającymi', N'48e0b390-b18c-43a2-869b-973ed8b3ef7e', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nienaczekaniem', N'48e0b390-b18c-43a2-869b-973ed8b3ef7e', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'esencji', N'48f1e2af-3726-48ad-aa46-d790ee3821d4', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'giserzy', N'48f1e2af-3726-48ad-aa46-d790ee3821d4', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hopsasa', N'48f1e2af-3726-48ad-aa46-d790ee3821d4', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wrębiło', N'48f1e2af-3726-48ad-aa46-d790ee3821d4', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'giserzy', N'48f1e2af-3726-48ad-aa46-d790ee3821d4', N'34849063-3080-40ca-b64a-205dbf62e4f2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieśnej', N'48f1e2af-3726-48ad-aa46-d790ee3821d4', N'34849063-3080-40ca-b64a-205dbf62e4f2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'okręceń', N'48f1e2af-3726-48ad-aa46-d790ee3821d4', N'34849063-3080-40ca-b64a-205dbf62e4f2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'socjetę', N'48f1e2af-3726-48ad-aa46-d790ee3821d4', N'34849063-3080-40ca-b64a-205dbf62e4f2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'workach', N'48f1e2af-3726-48ad-aa46-d790ee3821d4', N'34849063-3080-40ca-b64a-205dbf62e4f2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zęzowej', N'48f1e2af-3726-48ad-aa46-d790ee3821d4', N'34849063-3080-40ca-b64a-205dbf62e4f2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'giserzy', N'48f1e2af-3726-48ad-aa46-d790ee3821d4', N'407691e8-1a33-4c43-ab9c-0193bc408464', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podtyło', N'48f1e2af-3726-48ad-aa46-d790ee3821d4', N'407691e8-1a33-4c43-ab9c-0193bc408464', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sterczę', N'48f1e2af-3726-48ad-aa46-d790ee3821d4', N'407691e8-1a33-4c43-ab9c-0193bc408464', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'butterfingers
', N'4abe1b50-6fd2-423b-8a65-984f22d18f33', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'detectability
', N'4abe1b50-6fd2-423b-8a65-984f22d18f33', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'immatriculate
', N'4abe1b50-6fd2-423b-8a65-984f22d18f33', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'microsporidia
', N'4abe1b50-6fd2-423b-8a65-984f22d18f33', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'neighbourlike
', N'4abe1b50-6fd2-423b-8a65-984f22d18f33', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'precautioning
', N'4abe1b50-6fd2-423b-8a65-984f22d18f33', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'preexposition
', N'4abe1b50-6fd2-423b-8a65-984f22d18f33', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pyretogenetic
', N'4abe1b50-6fd2-423b-8a65-984f22d18f33', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'acceptability
', N'4abe1b50-6fd2-423b-8a65-984f22d18f33', N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'parakeratosis
', N'4abe1b50-6fd2-423b-8a65-984f22d18f33', N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'politicalized
', N'4abe1b50-6fd2-423b-8a65-984f22d18f33', N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pyretogenetic
', N'4abe1b50-6fd2-423b-8a65-984f22d18f33', N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sixpennyworth
', N'4abe1b50-6fd2-423b-8a65-984f22d18f33', N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'underbeveling
', N'4abe1b50-6fd2-423b-8a65-984f22d18f33', N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unpuritanical
', N'4abe1b50-6fd2-423b-8a65-984f22d18f33', N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'theophrastaceae
', N'4bd970b2-2f63-448e-8141-f236a0e0737f', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chondroganoidei
', N'4bd970b2-2f63-448e-8141-f236a0e0737f', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fissidentaceous
', N'4bd970b2-2f63-448e-8141-f236a0e0737f', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'interlinguistic
', N'4bd970b2-2f63-448e-8141-f236a0e0737f', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nontangibleness
', N'4bd970b2-2f63-448e-8141-f236a0e0737f', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'promiscuousness
', N'4bd970b2-2f63-448e-8141-f236a0e0737f', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rachioscoliosis
', N'4bd970b2-2f63-448e-8141-f236a0e0737f', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'theophrastaceae
', N'4bd970b2-2f63-448e-8141-f236a0e0737f', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trafficableness
', N'4bd970b2-2f63-448e-8141-f236a0e0737f', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niespory', N'4e7da533-7a4d-4c13-bee2-182be873188e', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'oratorze', N'4e7da533-7a4d-4c13-bee2-182be873188e', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dropiaty', N'4e7da533-7a4d-4c13-bee2-182be873188e', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nawadnia', N'4e7da533-7a4d-4c13-bee2-182be873188e', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'popasani', N'4e7da533-7a4d-4c13-bee2-182be873188e', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spasajże', N'4e7da533-7a4d-4c13-bee2-182be873188e', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaślepić', N'4e7da533-7a4d-4c13-bee2-182be873188e', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'grene
', N'4ef0b9d1-e7c4-42b5-a520-9cc0de991554', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'quare
', N'4ef0b9d1-e7c4-42b5-a520-9cc0de991554', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'yeses
', N'4ef0b9d1-e7c4-42b5-a520-9cc0de991554', N'46f32deb-fd2a-4544-88f4-27e9aaafe0a3', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hypersentimental
', N'4f8d2a4c-c743-4bbe-99e5-5f928394450d', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'institutionalise
', N'4f8d2a4c-c743-4bbe-99e5-5f928394450d', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonodoriferously
', N'4f8d2a4c-c743-4bbe-99e5-5f928394450d', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'perigastrulation
', N'4f8d2a4c-c743-4bbe-99e5-5f928394450d', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'valetudinariness
', N'4f8d2a4c-c743-4bbe-99e5-5f928394450d', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uncontrovertably
', N'4f8d2a4c-c743-4bbe-99e5-5f928394450d', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cytoarchitecture
', N'4f8d2a4c-c743-4bbe-99e5-5f928394450d', N'837b4e63-6c22-4508-936d-cb31fcb0a58e', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hypersentimental
', N'4f8d2a4c-c743-4bbe-99e5-5f928394450d', N'837b4e63-6c22-4508-936d-cb31fcb0a58e', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'noncleistogamous
', N'4f8d2a4c-c743-4bbe-99e5-5f928394450d', N'837b4e63-6c22-4508-936d-cb31fcb0a58e', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pseudomonastical
', N'4f8d2a4c-c743-4bbe-99e5-5f928394450d', N'837b4e63-6c22-4508-936d-cb31fcb0a58e', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'selfpreservatory
', N'4f8d2a4c-c743-4bbe-99e5-5f928394450d', N'837b4e63-6c22-4508-936d-cb31fcb0a58e', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'valetudinariness
', N'4f8d2a4c-c743-4bbe-99e5-5f928394450d', N'837b4e63-6c22-4508-936d-cb31fcb0a58e', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'palaeoentomology
', N'4f8d2a4c-c743-4bbe-99e5-5f928394450d', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'valetudinariness
', N'4f8d2a4c-c743-4bbe-99e5-5f928394450d', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dowołaj', N'50d3ec0e-41d5-45cc-84c5-4f51049abd0f', N'0814f578-8e38-4615-a110-f342a97e9ba2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kwakier', N'50d3ec0e-41d5-45cc-84c5-4f51049abd0f', N'0814f578-8e38-4615-a110-f342a97e9ba2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lonżach', N'50d3ec0e-41d5-45cc-84c5-4f51049abd0f', N'0814f578-8e38-4615-a110-f342a97e9ba2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mazidłu', N'50d3ec0e-41d5-45cc-84c5-4f51049abd0f', N'0814f578-8e38-4615-a110-f342a97e9ba2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'obielmo', N'50d3ec0e-41d5-45cc-84c5-4f51049abd0f', N'0814f578-8e38-4615-a110-f342a97e9ba2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odmiano', N'50d3ec0e-41d5-45cc-84c5-4f51049abd0f', N'0814f578-8e38-4615-a110-f342a97e9ba2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ammophila
', N'520a02b1-4694-4d21-bb6e-cd8eb19c4017', N'407691e8-1a33-4c43-ab9c-0193bc408464', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cementoma
', N'520a02b1-4694-4d21-bb6e-cd8eb19c4017', N'407691e8-1a33-4c43-ab9c-0193bc408464', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'coiffures
', N'520a02b1-4694-4d21-bb6e-cd8eb19c4017', N'407691e8-1a33-4c43-ab9c-0193bc408464', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hymettian
', N'520a02b1-4694-4d21-bb6e-cd8eb19c4017', N'407691e8-1a33-4c43-ab9c-0193bc408464', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mutilates
', N'520a02b1-4694-4d21-bb6e-cd8eb19c4017', N'407691e8-1a33-4c43-ab9c-0193bc408464', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'postnasal
', N'520a02b1-4694-4d21-bb6e-cd8eb19c4017', N'407691e8-1a33-4c43-ab9c-0193bc408464', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ziphiinae
', N'520a02b1-4694-4d21-bb6e-cd8eb19c4017', N'407691e8-1a33-4c43-ab9c-0193bc408464', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bioscopes
', N'520a02b1-4694-4d21-bb6e-cd8eb19c4017', N'407c141a-e8dd-4029-8feb-faa202fa7a5b', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'enunciate
', N'520a02b1-4694-4d21-bb6e-cd8eb19c4017', N'407c141a-e8dd-4029-8feb-faa202fa7a5b', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'insectine
', N'520a02b1-4694-4d21-bb6e-cd8eb19c4017', N'407c141a-e8dd-4029-8feb-faa202fa7a5b', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'millerole
', N'520a02b1-4694-4d21-bb6e-cd8eb19c4017', N'407c141a-e8dd-4029-8feb-faa202fa7a5b', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wartiness
', N'520a02b1-4694-4d21-bb6e-cd8eb19c4017', N'407c141a-e8dd-4029-8feb-faa202fa7a5b', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'arracacia
', N'520a02b1-4694-4d21-bb6e-cd8eb19c4017', N'4217cb86-c05c-436e-a9f6-0b5e5f70db81', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'coiffures
', N'520a02b1-4694-4d21-bb6e-cd8eb19c4017', N'4217cb86-c05c-436e-a9f6-0b5e5f70db81', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rhopalium
', N'520a02b1-4694-4d21-bb6e-cd8eb19c4017', N'4217cb86-c05c-436e-a9f6-0b5e5f70db81', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'benzoquinone
', N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fraternation
', N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'iconophilist
', N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'precausation
', N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'30adcf04-da22-4e3f-ad87-50df41211a6f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'asperuloside
', N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'iconophilist
', N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nephelometer
', N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'semihumorous
', N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unaccumulate
', N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'apometabolic
', N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cantankerous
', N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'coenamorment
', N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'undreadfully
', N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unicuspidate
', N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'xalostockite
', N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonselection
', N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'phylloideous
', N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rhineurynter
', N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tropospheric
', N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'frygnięte', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'joginiach', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kaflowymi', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lobbowało', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nachlacie', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'starczych', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'usidłałaś', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wygłaskań', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'frygnięte', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'geesowsku', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mecenasce', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ogławiali', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pojebania', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'śrutownie', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niesterań', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pojebania', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kimałabym', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'muflarnia', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'obleczmyż', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'próżniacy', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trakenami', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'umierajmy', N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'deskryptorową', N'5801126f-c87e-429c-ae1a-7e699b483408', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'helmintologię', N'5801126f-c87e-429c-ae1a-7e699b483408', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'klerykałowską', N'5801126f-c87e-429c-ae1a-7e699b483408', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wysokoudarowa', N'5801126f-c87e-429c-ae1a-7e699b483408', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezabębniony', N'5801126f-c87e-429c-ae1a-7e699b483408', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gelosine
', N'5d990ef5-d383-4a92-b749-32d7415e197a', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pitiable
', N'5d990ef5-d383-4a92-b749-32d7415e197a', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'shavings
', N'5d990ef5-d383-4a92-b749-32d7415e197a', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cokneyfy
', N'5d990ef5-d383-4a92-b749-32d7415e197a', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gleesome
', N'5d990ef5-d383-4a92-b749-32d7415e197a', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unsensed
', N'5d990ef5-d383-4a92-b749-32d7415e197a', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'arculite
', N'5d990ef5-d383-4a92-b749-32d7415e197a', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'balaghat
', N'5d990ef5-d383-4a92-b749-32d7415e197a', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pitiable
', N'5d990ef5-d383-4a92-b749-32d7415e197a', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'suchness
', N'5d990ef5-d383-4a92-b749-32d7415e197a', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tesseral
', N'5d990ef5-d383-4a92-b749-32d7415e197a', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'treasury
', N'5d990ef5-d383-4a92-b749-32d7415e197a', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'audition
', N'5d990ef5-d383-4a92-b749-32d7415e197a', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'blastide
', N'5d990ef5-d383-4a92-b749-32d7415e197a', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'deniably
', N'5d990ef5-d383-4a92-b749-32d7415e197a', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hoofbeat
', N'5d990ef5-d383-4a92-b749-32d7415e197a', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pampered
', N'5d990ef5-d383-4a92-b749-32d7415e197a', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pitiable
', N'5d990ef5-d383-4a92-b749-32d7415e197a', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sakeber
', N'60a814ce-6f40-448f-a61c-5bf138e9f48e', N'bb9362f3-c1cc-41c9-b529-67a31cb42e36', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'debates
', N'60a814ce-6f40-448f-a61c-5bf138e9f48e', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'justina
', N'60a814ce-6f40-448f-a61c-5bf138e9f48e', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sakeber
', N'60a814ce-6f40-448f-a61c-5bf138e9f48e', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'benzoquinone
', N'63fe98d1-b26b-449d-b8ab-a53a688bc1af', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'phentolamine
', N'63fe98d1-b26b-449d-b8ab-a53a688bc1af', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'retrenchable
', N'63fe98d1-b26b-449d-b8ab-a53a688bc1af', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'strumousness
', N'63fe98d1-b26b-449d-b8ab-a53a688bc1af', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unwashedness
', N'63fe98d1-b26b-449d-b8ab-a53a688bc1af', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'abbreviators
', N'63fe98d1-b26b-449d-b8ab-a53a688bc1af', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'apometabolic
', N'63fe98d1-b26b-449d-b8ab-a53a688bc1af', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'entrancement
', N'63fe98d1-b26b-449d-b8ab-a53a688bc1af', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonaffection
', N'63fe98d1-b26b-449d-b8ab-a53a688bc1af', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonsentience
', N'63fe98d1-b26b-449d-b8ab-a53a688bc1af', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'precausation
', N'63fe98d1-b26b-449d-b8ab-a53a688bc1af', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'waggonwayman
', N'63fe98d1-b26b-449d-b8ab-a53a688bc1af', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'strumousness
', N'63fe98d1-b26b-449d-b8ab-a53a688bc1af', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unappealably
', N'63fe98d1-b26b-449d-b8ab-a53a688bc1af', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'duplikat', N'692d12d0-9486-40e6-80e4-bbf6f20efd0f', N'037a6380-46ef-4327-b1bb-5aef7a64dbc5', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podkulał', N'692d12d0-9486-40e6-80e4-bbf6f20efd0f', N'037a6380-46ef-4327-b1bb-5aef7a64dbc5', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rajfurko', N'692d12d0-9486-40e6-80e4-bbf6f20efd0f', N'037a6380-46ef-4327-b1bb-5aef7a64dbc5', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'roztrzęś', N'692d12d0-9486-40e6-80e4-bbf6f20efd0f', N'037a6380-46ef-4327-b1bb-5aef7a64dbc5', CAST(N'2022-02-06T13:34:36.6480000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ciskacze', N'692d12d0-9486-40e6-80e4-bbf6f20efd0f', N'062bfaca-f1ba-4664-a5f3-7988132458b9', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'egotysty', N'692d12d0-9486-40e6-80e4-bbf6f20efd0f', N'062bfaca-f1ba-4664-a5f3-7988132458b9', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odrapani', N'692d12d0-9486-40e6-80e4-bbf6f20efd0f', N'062bfaca-f1ba-4664-a5f3-7988132458b9', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'benefact
', N'69eca4d8-710f-4dd4-9dee-401611bcd04d', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bruising
', N'69eca4d8-710f-4dd4-9dee-401611bcd04d', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'crustate
', N'69eca4d8-710f-4dd4-9dee-401611bcd04d', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'homopter
', N'69eca4d8-710f-4dd4-9dee-401611bcd04d', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tchincou
', N'69eca4d8-710f-4dd4-9dee-401611bcd04d', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bruising
', N'69eca4d8-710f-4dd4-9dee-401611bcd04d', N'25dde876-8acb-41ee-919f-0cfc5fde07c7', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'curiatii
', N'69eca4d8-710f-4dd4-9dee-401611bcd04d', N'25dde876-8acb-41ee-919f-0cfc5fde07c7', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'strophic
', N'69eca4d8-710f-4dd4-9dee-401611bcd04d', N'25dde876-8acb-41ee-919f-0cfc5fde07c7', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zapluskwijcież', N'6b5fca17-9d8b-49d7-984c-4e03239a461e', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dekoncentrowań', N'6b5fca17-9d8b-49d7-984c-4e03239a461e', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dostępowałabyś', N'6b5fca17-9d8b-49d7-984c-4e03239a461e', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'legitymizowały', N'6b5fca17-9d8b-49d7-984c-4e03239a461e', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odfiltrowujesz', N'6b5fca17-9d8b-49d7-984c-4e03239a461e', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'roztasowywanej', N'6b5fca17-9d8b-49d7-984c-4e03239a461e', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zapluskwijcież', N'6b5fca17-9d8b-49d7-984c-4e03239a461e', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'żółtozielonemu', N'6b5fca17-9d8b-49d7-984c-4e03239a461e', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ciachnięciu', N'6bd6d864-fd23-49dd-9e83-2cd148642b11', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dosiadywane', N'6bd6d864-fd23-49dd-9e83-2cd148642b11', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieugadywań', N'6bd6d864-fd23-49dd-9e83-2cd148642b11', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'obtapiałyby', N'6bd6d864-fd23-49dd-9e83-2cd148642b11', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unarodowiła', N'6bd6d864-fd23-49dd-9e83-2cd148642b11', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyprężałbyś', N'6bd6d864-fd23-49dd-9e83-2cd148642b11', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'obunogi', N'6c36ecb0-a905-476c-877b-85939758d473', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pchając', N'6c36ecb0-a905-476c-877b-85939758d473', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pędraka', N'6c36ecb0-a905-476c-877b-85939758d473', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'popłaca', N'6c36ecb0-a905-476c-877b-85939758d473', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'skarżąc', N'6c36ecb0-a905-476c-877b-85939758d473', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tyrałaś', N'6c36ecb0-a905-476c-877b-85939758d473', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naglisz', N'6c36ecb0-a905-476c-877b-85939758d473', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nowinie', N'6c36ecb0-a905-476c-877b-85939758d473', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odmiano', N'6c36ecb0-a905-476c-877b-85939758d473', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sercową', N'6c36ecb0-a905-476c-877b-85939758d473', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'skarżąc', N'6c36ecb0-a905-476c-877b-85939758d473', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tenreku', N'6c36ecb0-a905-476c-877b-85939758d473', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zapacał', N'6c36ecb0-a905-476c-877b-85939758d473', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zęzowej', N'6c36ecb0-a905-476c-877b-85939758d473', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cieplak', N'6c36ecb0-a905-476c-877b-85939758d473', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naglisz', N'6c36ecb0-a905-476c-877b-85939758d473', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odcieki', N'6c36ecb0-a905-476c-877b-85939758d473', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'remulad', N'6c36ecb0-a905-476c-877b-85939758d473', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'toposem', N'6c36ecb0-a905-476c-877b-85939758d473', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wybiela', N'6c36ecb0-a905-476c-877b-85939758d473', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zawisać', N'6c36ecb0-a905-476c-877b-85939758d473', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'omyciem', N'6c36ecb0-a905-476c-877b-85939758d473', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'skarżąc', N'6c36ecb0-a905-476c-877b-85939758d473', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'socjetę', N'6c36ecb0-a905-476c-877b-85939758d473', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sterczę', N'6c36ecb0-a905-476c-877b-85939758d473', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wciekną', N'6c36ecb0-a905-476c-877b-85939758d473', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wybiela', N'6c36ecb0-a905-476c-877b-85939758d473', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bucefały', N'6cd8848a-07fc-476f-83e3-8e7b19648345', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dorywczo', N'6cd8848a-07fc-476f-83e3-8e7b19648345', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'popasani', N'6cd8848a-07fc-476f-83e3-8e7b19648345', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spasajże', N'6cd8848a-07fc-476f-83e3-8e7b19648345', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nagadana', N'6cd8848a-07fc-476f-83e3-8e7b19648345', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nawadnia', N'6cd8848a-07fc-476f-83e3-8e7b19648345', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wymywane', N'6cd8848a-07fc-476f-83e3-8e7b19648345', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zbłąkane', N'6cd8848a-07fc-476f-83e3-8e7b19648345', N'5601a294-6cd8-4969-9e4a-4ff2901ae924', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'beefiest
', N'6ce0e0a3-7181-46cf-a042-6f5a2d482fd1', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'carpuspi
', N'6ce0e0a3-7181-46cf-a042-6f5a2d482fd1', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'inkstand
', N'6ce0e0a3-7181-46cf-a042-6f5a2d482fd1', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'quaffers
', N'6ce0e0a3-7181-46cf-a042-6f5a2d482fd1', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unsensed
', N'6ce0e0a3-7181-46cf-a042-6f5a2d482fd1', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'banjoist
', N'6ce0e0a3-7181-46cf-a042-6f5a2d482fd1', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hospitia
', N'6ce0e0a3-7181-46cf-a042-6f5a2d482fd1', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'litterer
', N'6ce0e0a3-7181-46cf-a042-6f5a2d482fd1', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'validity
', N'6ce0e0a3-7181-46cf-a042-6f5a2d482fd1', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'catcher
', N'6e815a5e-bfa4-4320-985f-40e238bda8ba', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fatally
', N'6e815a5e-bfa4-4320-985f-40e238bda8ba', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'znieruchomiałaś', N'6f4bc015-3809-43e6-845f-2dc6f10b85aa', N'e2532790-0bef-45d7-bd16-81709f211432', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'antiresonance
', N'707b7592-3eab-49fb-ad59-dcc689d7b92f', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'brutification
', N'707b7592-3eab-49fb-ad59-dcc689d7b92f', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'butterfingers
', N'707b7592-3eab-49fb-ad59-dcc689d7b92f', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chloroplastic
', N'707b7592-3eab-49fb-ad59-dcc689d7b92f', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'decorticating
', N'707b7592-3eab-49fb-ad59-dcc689d7b92f', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'interrogatrix
', N'707b7592-3eab-49fb-ad59-dcc689d7b92f', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'microsporidia
', N'707b7592-3eab-49fb-ad59-dcc689d7b92f', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'slavonization
', N'707b7592-3eab-49fb-ad59-dcc689d7b92f', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cobelligerent
', N'707b7592-3eab-49fb-ad59-dcc689d7b92f', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reinfiltrated
', N'707b7592-3eab-49fb-ad59-dcc689d7b92f', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'repersonalize
', N'707b7592-3eab-49fb-ad59-dcc689d7b92f', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'consonantized
', N'707b7592-3eab-49fb-ad59-dcc689d7b92f', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'microsporidia
', N'707b7592-3eab-49fb-ad59-dcc689d7b92f', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ornithosauria
', N'707b7592-3eab-49fb-ad59-dcc689d7b92f', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pyretogenetic
', N'707b7592-3eab-49fb-ad59-dcc689d7b92f', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'befluster
', N'729c1e00-a464-4525-b2f2-ac2f45238f63', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bioscopes
', N'729c1e00-a464-4525-b2f2-ac2f45238f63', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gustatory
', N'729c1e00-a464-4525-b2f2-ac2f45238f63', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'homeopath
', N'729c1e00-a464-4525-b2f2-ac2f45238f63', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'inactuate
', N'729c1e00-a464-4525-b2f2-ac2f45238f63', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bioscopes
', N'729c1e00-a464-4525-b2f2-ac2f45238f63', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hymettian
', N'729c1e00-a464-4525-b2f2-ac2f45238f63', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'iridaceae
', N'729c1e00-a464-4525-b2f2-ac2f45238f63', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'larghetto
', N'729c1e00-a464-4525-b2f2-ac2f45238f63', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pathetism
', N'729c1e00-a464-4525-b2f2-ac2f45238f63', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reladling
', N'729c1e00-a464-4525-b2f2-ac2f45238f63', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'repursues
', N'729c1e00-a464-4525-b2f2-ac2f45238f63', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'anxiously
', N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'azureness
', N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hymettian
', N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sulphuryl
', N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'anxiously
', N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'collegium
', N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cunningly
', N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cupressus
', N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overtimid
', N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'injectors
', N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'jellified
', N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'perviable
', N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pintadoes
', N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'stumpwise
', N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sulphuryl
', N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'anxiously
', N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'peartness
', N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'branchiest
', N'74afd494-67b5-41ee-bcda-f12f2a11575c', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'disleafing
', N'74afd494-67b5-41ee-bcda-f12f2a11575c', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hexacyclic
', N'74afd494-67b5-41ee-bcda-f12f2a11575c', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'latecomers
', N'74afd494-67b5-41ee-bcda-f12f2a11575c', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'oreotragus
', N'74afd494-67b5-41ee-bcda-f12f2a11575c', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'springlock
', N'74afd494-67b5-41ee-bcda-f12f2a11575c', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unwatchful
', N'74afd494-67b5-41ee-bcda-f12f2a11575c', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'azotenesis
', N'74afd494-67b5-41ee-bcda-f12f2a11575c', N'e59bcd84-c04a-45cf-98e8-3580f6750984', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'disleafing
', N'74afd494-67b5-41ee-bcda-f12f2a11575c', N'e59bcd84-c04a-45cf-98e8-3580f6750984', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tariffless
', N'74afd494-67b5-41ee-bcda-f12f2a11575c', N'e59bcd84-c04a-45cf-98e8-3580f6750984', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uniflorous
', N'74afd494-67b5-41ee-bcda-f12f2a11575c', N'e59bcd84-c04a-45cf-98e8-3580f6750984', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'waterbloom
', N'74afd494-67b5-41ee-bcda-f12f2a11575c', N'e59bcd84-c04a-45cf-98e8-3580f6750984', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'springlock
', N'74afd494-67b5-41ee-bcda-f12f2a11575c', N'e5f9c68a-18c1-4907-ae44-c85861dfb739', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'marianowskimi', N'77418136-b2b5-4ab3-866a-4c3ca5dcfd09', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'montserrackie', N'77418136-b2b5-4ab3-866a-4c3ca5dcfd09', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'klerykałowską', N'77418136-b2b5-4ab3-866a-4c3ca5dcfd09', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozczesaniami', N'77418136-b2b5-4ab3-866a-4c3ca5dcfd09', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'scałowywaniem', N'77418136-b2b5-4ab3-866a-4c3ca5dcfd09', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaśniedzonych', N'77418136-b2b5-4ab3-866a-4c3ca5dcfd09', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zatłoczeniach', N'77418136-b2b5-4ab3-866a-4c3ca5dcfd09', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieporowata', N'78a19c00-782c-4118-9c4b-b2fa9aa04a65', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uhonorowuje', N'78a19c00-782c-4118-9c4b-b2fa9aa04a65', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wchodziłoby', N'78a19c00-782c-4118-9c4b-b2fa9aa04a65', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaklaskajże', N'78a19c00-782c-4118-9c4b-b2fa9aa04a65', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wchodziłoby', N'78a19c00-782c-4118-9c4b-b2fa9aa04a65', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ateizowałabym', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'b5b62c52-6dc1-4cb2-b5e8-769b03a302f0', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niesierpeckie', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'b5b62c52-6dc1-4cb2-b5e8-769b03a302f0', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezestarzały', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'b5b62c52-6dc1-4cb2-b5e8-769b03a302f0', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pasibrzuchami', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'b5b62c52-6dc1-4cb2-b5e8-769b03a302f0', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przetrawiałeś', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'b5b62c52-6dc1-4cb2-b5e8-769b03a302f0', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozwarstwieni', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'b5b62c52-6dc1-4cb2-b5e8-769b03a302f0', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wysokoudarowa', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'b5b62c52-6dc1-4cb2-b5e8-769b03a302f0', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'znormalizujże', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'b5b62c52-6dc1-4cb2-b5e8-769b03a302f0', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieplotkujące', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'bb9362f3-c1cc-41c9-b529-67a31cb42e36', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieposiewowej', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'bb9362f3-c1cc-41c9-b529-67a31cb42e36', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'stębnowaniami', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'bb9362f3-c1cc-41c9-b529-67a31cb42e36', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wysuszających', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'bb9362f3-c1cc-41c9-b529-67a31cb42e36', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyzdrowiałymi', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'bb9362f3-c1cc-41c9-b529-67a31cb42e36', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zabalsamowaną', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'bb9362f3-c1cc-41c9-b529-67a31cb42e36', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niefrunięciem', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieowinięciem', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'brzegoskłonów', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'jeleśniańskim', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niedotruwanie', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podrąbywanych', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podśmiechujkę', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przetrawiałeś', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wystrzeleniom', N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'capiałaby', N'7d130e15-3309-4219-8acf-71f110c188f8', N'0814f578-8e38-4615-a110-f342a97e9ba2', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'geesowsku', N'7d130e15-3309-4219-8acf-71f110c188f8', N'0814f578-8e38-4615-a110-f342a97e9ba2', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ładniutką', N'7d130e15-3309-4219-8acf-71f110c188f8', N'0814f578-8e38-4615-a110-f342a97e9ba2', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'locativów', N'7d130e15-3309-4219-8acf-71f110c188f8', N'0814f578-8e38-4615-a110-f342a97e9ba2', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'namłócili', N'7d130e15-3309-4219-8acf-71f110c188f8', N'0814f578-8e38-4615-a110-f342a97e9ba2', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przywykał', N'7d130e15-3309-4219-8acf-71f110c188f8', N'0814f578-8e38-4615-a110-f342a97e9ba2', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zazbroimy', N'7d130e15-3309-4219-8acf-71f110c188f8', N'0814f578-8e38-4615-a110-f342a97e9ba2', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'capiałaby', N'7d130e15-3309-4219-8acf-71f110c188f8', N'0846669c-07f1-41f4-9381-e038ec3351d6', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odpijałam', N'7d130e15-3309-4219-8acf-71f110c188f8', N'0846669c-07f1-41f4-9381-e038ec3351d6', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyskubane', N'7d130e15-3309-4219-8acf-71f110c188f8', N'0aa51811-6ba5-47f1-b2b8-4ae519845a0b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zasalutuj', N'7d130e15-3309-4219-8acf-71f110c188f8', N'0aa51811-6ba5-47f1-b2b8-4ae519845a0b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'capiałaby', N'7d130e15-3309-4219-8acf-71f110c188f8', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dochodzić', N'7d130e15-3309-4219-8acf-71f110c188f8', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odpijałam', N'7d130e15-3309-4219-8acf-71f110c188f8', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rugującej', N'7d130e15-3309-4219-8acf-71f110c188f8', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wydrwiono', N'7d130e15-3309-4219-8acf-71f110c188f8', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'boatlike
', N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'embolize
', N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'exornate
', N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pandorea
', N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trimeric
', N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tyramine
', N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'displume
', N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'46f32deb-fd2a-4544-88f4-27e9aaafe0a3', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tyramine
', N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'46f32deb-fd2a-4544-88f4-27e9aaafe0a3', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tyramine
', N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'utilises
', N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'benefact
', N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'exorcism
', N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pasquils
', N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pitiable
', N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tyramine
', N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ungloved
', N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'validity
', N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'justina
', N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'orarian
', N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pfennig
', N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ephelis
', N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'goldbug
', N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'jazzers
', N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'justina
', N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'partile
', N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pronaoi
', N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'strokes
', N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'upcoast
', N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pronaoi
', N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'f5ca7f60-0d49-4c12-bd33-87fbfdec7edd', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sakeber
', N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'f5ca7f60-0d49-4c12-bd33-87fbfdec7edd', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cambers
', N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'duskily
', N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'goldbug
', N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niemumiowatej', N'8270c149-34b3-427d-8491-1efe73b86490', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepobudzanym', N'8270c149-34b3-427d-8491-1efe73b86490', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odpolitycznić', N'8270c149-34b3-427d-8491-1efe73b86490', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przetrawiałeś', N'8270c149-34b3-427d-8491-1efe73b86490', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyzdrowiałymi', N'8270c149-34b3-427d-8491-1efe73b86490', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fototropizmie', N'8270c149-34b3-427d-8491-1efe73b86490', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kapitanowałam', N'8270c149-34b3-427d-8491-1efe73b86490', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'monologującym', N'8270c149-34b3-427d-8491-1efe73b86490', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niewygładzani', N'8270c149-34b3-427d-8491-1efe73b86490', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przetrawiałeś', N'8270c149-34b3-427d-8491-1efe73b86490', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rocznicowości', N'8270c149-34b3-427d-8491-1efe73b86490', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6490000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wszędobylstwo', N'8270c149-34b3-427d-8491-1efe73b86490', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieanoreksyjna', N'85cd4b44-f7ee-4b73-82cc-422cdb3e88e3', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieulęgającymi', N'85cd4b44-f7ee-4b73-82cc-422cdb3e88e3', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieanoreksyjna', N'85cd4b44-f7ee-4b73-82cc-422cdb3e88e3', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieaspiracyjna', N'85cd4b44-f7ee-4b73-82cc-422cdb3e88e3', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieskwarkowego', N'85cd4b44-f7ee-4b73-82cc-422cdb3e88e3', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ponastrajaliby', N'85cd4b44-f7ee-4b73-82cc-422cdb3e88e3', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'roztasowywanej', N'85cd4b44-f7ee-4b73-82cc-422cdb3e88e3', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kolposkopowego', N'85cd4b44-f7ee-4b73-82cc-422cdb3e88e3', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieanoreksyjna', N'85cd4b44-f7ee-4b73-82cc-422cdb3e88e3', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieworkowatego', N'85cd4b44-f7ee-4b73-82cc-422cdb3e88e3', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odfiltrowujesz', N'85cd4b44-f7ee-4b73-82cc-422cdb3e88e3', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ówczesnościach', N'85cd4b44-f7ee-4b73-82cc-422cdb3e88e3', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'szafowałybyśmy', N'85cd4b44-f7ee-4b73-82cc-422cdb3e88e3', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'felineness
', N'86c42784-16ff-415f-8204-ff50fec91c4c', N'6fc830b2-17d2-430c-9188-8310faa228e8', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'miscreancy
', N'86c42784-16ff-415f-8204-ff50fec91c4c', N'6fc830b2-17d2-430c-9188-8310faa228e8', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonagenary
', N'86c42784-16ff-415f-8204-ff50fec91c4c', N'6fc830b2-17d2-430c-9188-8310faa228e8', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'afterstudy
', N'86c42784-16ff-415f-8204-ff50fec91c4c', N'74d3f2e2-a0c4-418f-933f-890e26a64328', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'anadidymus
', N'86c42784-16ff-415f-8204-ff50fec91c4c', N'74d3f2e2-a0c4-418f-933f-890e26a64328', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'disleafing
', N'86c42784-16ff-415f-8204-ff50fec91c4c', N'74d3f2e2-a0c4-418f-933f-890e26a64328', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'miscreancy
', N'86c42784-16ff-415f-8204-ff50fec91c4c', N'74d3f2e2-a0c4-418f-933f-890e26a64328', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'invitatory
', N'86c42784-16ff-415f-8204-ff50fec91c4c', N'77a7f8c8-af2c-48e5-80ef-6c2f41dc93cc', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'miscreancy
', N'86c42784-16ff-415f-8204-ff50fec91c4c', N'77a7f8c8-af2c-48e5-80ef-6c2f41dc93cc', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'perspiring
', N'86c42784-16ff-415f-8204-ff50fec91c4c', N'77a7f8c8-af2c-48e5-80ef-6c2f41dc93cc', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'shrineless
', N'86c42784-16ff-415f-8204-ff50fec91c4c', N'77a7f8c8-af2c-48e5-80ef-6c2f41dc93cc', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unsmutched
', N'86c42784-16ff-415f-8204-ff50fec91c4c', N'77a7f8c8-af2c-48e5-80ef-6c2f41dc93cc', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'agrammatica
', N'870d908a-e66f-427c-a07d-1079df085fd9', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cummerbunds
', N'870d908a-e66f-427c-a07d-1079df085fd9', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'galloperdix
', N'870d908a-e66f-427c-a07d-1079df085fd9', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonneurotic
', N'870d908a-e66f-427c-a07d-1079df085fd9', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'photochromy
', N'870d908a-e66f-427c-a07d-1079df085fd9', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'syllabising
', N'870d908a-e66f-427c-a07d-1079df085fd9', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'telangiosis
', N'870d908a-e66f-427c-a07d-1079df085fd9', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unscalloped
', N'870d908a-e66f-427c-a07d-1079df085fd9', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'formicicide
', N'870d908a-e66f-427c-a07d-1079df085fd9', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'monstrances
', N'870d908a-e66f-427c-a07d-1079df085fd9', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'premidnight
', N'870d908a-e66f-427c-a07d-1079df085fd9', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'syllabising
', N'870d908a-e66f-427c-a07d-1079df085fd9', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zygophyceae
', N'870d908a-e66f-427c-a07d-1079df085fd9', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'monstrances
', N'870d908a-e66f-427c-a07d-1079df085fd9', N'b5b62c52-6dc1-4cb2-b5e8-769b03a302f0', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'telangiosis
', N'870d908a-e66f-427c-a07d-1079df085fd9', N'b5b62c52-6dc1-4cb2-b5e8-769b03a302f0', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mierzwiącą', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zjędrnieli', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'balistytem', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dzięciołów', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gęstnącymi', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kanciatemu', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mierzwiącą', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naważonemu', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'powięziłeś', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przysłanym', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dworeczkom', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kodycylowi', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mierzwiącą', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'powięziłeś', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'powspinały', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przepocono', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uintymniło', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mierzwiącą', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'5601a294-6cd8-4969-9e4a-4ff2901ae924', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naparzonej', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'5601a294-6cd8-4969-9e4a-4ff2901ae924', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przygańmyż', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'5601a294-6cd8-4969-9e4a-4ff2901ae924', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'słoniskiem', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'5601a294-6cd8-4969-9e4a-4ff2901ae924', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zbereźniki', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'5601a294-6cd8-4969-9e4a-4ff2901ae924', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zirytowaną', N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'5601a294-6cd8-4969-9e4a-4ff2901ae924', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fototropizmie', N'8b4bd7da-f65b-4da6-8773-b25a8e83bc79', N'572b7747-e3eb-4ccf-8211-f013d3618acd', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'parafowaniach', N'8b4bd7da-f65b-4da6-8773-b25a8e83bc79', N'572b7747-e3eb-4ccf-8211-f013d3618acd', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przydawkowemu', N'8b4bd7da-f65b-4da6-8773-b25a8e83bc79', N'572b7747-e3eb-4ccf-8211-f013d3618acd', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uspokajajcież', N'8b4bd7da-f65b-4da6-8773-b25a8e83bc79', N'572b7747-e3eb-4ccf-8211-f013d3618acd', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezałatwianą', N'8b4bd7da-f65b-4da6-8773-b25a8e83bc79', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rocznicowości', N'8b4bd7da-f65b-4da6-8773-b25a8e83bc79', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spolerowywano', N'8b4bd7da-f65b-4da6-8773-b25a8e83bc79', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nastopyrczymy', N'8b4bd7da-f65b-4da6-8773-b25a8e83bc79', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezałatwianą', N'8b4bd7da-f65b-4da6-8773-b25a8e83bc79', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyodrębnianej', N'8b4bd7da-f65b-4da6-8773-b25a8e83bc79', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'decorticating
', N'8b7a0109-5875-478d-b9a9-307f0bf2984c', N'efd2d829-2500-4c66-bd27-586989316647', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'heteroerotism
', N'8b7a0109-5875-478d-b9a9-307f0bf2984c', N'efd2d829-2500-4c66-bd27-586989316647', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'neighbourlike
', N'8b7a0109-5875-478d-b9a9-307f0bf2984c', N'efd2d829-2500-4c66-bd27-586989316647', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ovipositional
', N'8b7a0109-5875-478d-b9a9-307f0bf2984c', N'efd2d829-2500-4c66-bd27-586989316647', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'scleroxanthin
', N'8b7a0109-5875-478d-b9a9-307f0bf2984c', N'efd2d829-2500-4c66-bd27-586989316647', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sixpennyworth
', N'8b7a0109-5875-478d-b9a9-307f0bf2984c', N'efd2d829-2500-4c66-bd27-586989316647', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'underbeveling
', N'8b7a0109-5875-478d-b9a9-307f0bf2984c', N'efd2d829-2500-4c66-bd27-586989316647', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'confectioners
', N'8b7a0109-5875-478d-b9a9-307f0bf2984c', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'consonantized
', N'8b7a0109-5875-478d-b9a9-307f0bf2984c', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'scleroxanthin
', N'8b7a0109-5875-478d-b9a9-307f0bf2984c', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sodioplatinic
', N'8b7a0109-5875-478d-b9a9-307f0bf2984c', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unaudibleness
', N'8b7a0109-5875-478d-b9a9-307f0bf2984c', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'underbeveling
', N'8b7a0109-5875-478d-b9a9-307f0bf2984c', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'confectioners
', N'8b7a0109-5875-478d-b9a9-307f0bf2984c', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'debates
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'f5ca7f60-0d49-4c12-bd33-87fbfdec7edd', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'errable
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'f5ca7f60-0d49-4c12-bd33-87fbfdec7edd', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hyraxes
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'f5ca7f60-0d49-4c12-bd33-87fbfdec7edd', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'onstage
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'f5ca7f60-0d49-4c12-bd33-87fbfdec7edd', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sakeber
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'f5ca7f60-0d49-4c12-bd33-87fbfdec7edd', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sequani
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'f5ca7f60-0d49-4c12-bd33-87fbfdec7edd', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'faconde
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fatally
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'flotsen
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'goldbug
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gondite
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pronaoi
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'savarin
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spitous
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'f8a9e103-3c02-4dd2-b574-c79957887e5c', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'athbash
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'deplete
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'intrude
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'larixin
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'notably
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spinner
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ucayale
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'upcoast
', N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'defenestracją', N'8f538ce6-eaf1-4f45-9dbc-eac2959ef0e1', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'karbolującemu', N'8f538ce6-eaf1-4f45-9dbc-eac2959ef0e1', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nabuntowanymi', N'8f538ce6-eaf1-4f45-9dbc-eac2959ef0e1', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ułagodziłyśmy', N'8f538ce6-eaf1-4f45-9dbc-eac2959ef0e1', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'marianowskimi', N'8f538ce6-eaf1-4f45-9dbc-eac2959ef0e1', N'9f85aedf-6139-484b-9fc6-f9ea39e50079', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niesucholubny', N'8f538ce6-eaf1-4f45-9dbc-eac2959ef0e1', N'9f85aedf-6139-484b-9fc6-f9ea39e50079', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odpolitycznić', N'8f538ce6-eaf1-4f45-9dbc-eac2959ef0e1', N'9f85aedf-6139-484b-9fc6-f9ea39e50079', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'polemizującym', N'8f538ce6-eaf1-4f45-9dbc-eac2959ef0e1', N'9f85aedf-6139-484b-9fc6-f9ea39e50079', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przemnożonymi', N'8f538ce6-eaf1-4f45-9dbc-eac2959ef0e1', N'9f85aedf-6139-484b-9fc6-f9ea39e50079', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przydawkowemu', N'8f538ce6-eaf1-4f45-9dbc-eac2959ef0e1', N'9f85aedf-6139-484b-9fc6-f9ea39e50079', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zjednoliconej', N'8f538ce6-eaf1-4f45-9dbc-eac2959ef0e1', N'9f85aedf-6139-484b-9fc6-f9ea39e50079', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'flegmatyzmowi', N'8f538ce6-eaf1-4f45-9dbc-eac2959ef0e1', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spolerowywano', N'8f538ce6-eaf1-4f45-9dbc-eac2959ef0e1', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ułagodziłyśmy', N'8f538ce6-eaf1-4f45-9dbc-eac2959ef0e1', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ułagodziłyśmy', N'8f538ce6-eaf1-4f45-9dbc-eac2959ef0e1', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieżwanieckiej', N'9092b367-a415-4e4d-8782-8fea8741ea36', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'homodontyzmami', N'9092b367-a415-4e4d-8782-8fea8741ea36', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieskwarkowego', N'9092b367-a415-4e4d-8782-8fea8741ea36', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieszarpaniami', N'9092b367-a415-4e4d-8782-8fea8741ea36', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieulęgającymi', N'9092b367-a415-4e4d-8782-8fea8741ea36', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odpełźnięciami', N'9092b367-a415-4e4d-8782-8fea8741ea36', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ponastrajaliby', N'9092b367-a415-4e4d-8782-8fea8741ea36', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przekraczanych', N'9092b367-a415-4e4d-8782-8fea8741ea36', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'serwohamulcowi', N'9092b367-a415-4e4d-8782-8fea8741ea36', N'b5b62c52-6dc1-4cb2-b5e8-769b03a302f0', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'helmintologiem', N'9092b367-a415-4e4d-8782-8fea8741ea36', N'bb9362f3-c1cc-41c9-b529-67a31cb42e36', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ponastrajaliby', N'9092b367-a415-4e4d-8782-8fea8741ea36', N'bb9362f3-c1cc-41c9-b529-67a31cb42e36', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'serwohamulcowi', N'9092b367-a415-4e4d-8782-8fea8741ea36', N'bb9362f3-c1cc-41c9-b529-67a31cb42e36', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaabsorbowania', N'9092b367-a415-4e4d-8782-8fea8741ea36', N'bb9362f3-c1cc-41c9-b529-67a31cb42e36', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wódczanych', N'90f2504f-79ee-446e-9b04-5ab8f371d33f', N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naszlochałoby', N'920562af-3734-4b73-89c2-ae800fd006b1', N'22d39998-47eb-43e4-8174-dff7d3c344fb', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niebezsolnymi', N'920562af-3734-4b73-89c2-ae800fd006b1', N'22d39998-47eb-43e4-8174-dff7d3c344fb', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niefantowania', N'920562af-3734-4b73-89c2-ae800fd006b1', N'22d39998-47eb-43e4-8174-dff7d3c344fb', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieświdnickie', N'920562af-3734-4b73-89c2-ae800fd006b1', N'22d39998-47eb-43e4-8174-dff7d3c344fb', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odpolitycznić', N'920562af-3734-4b73-89c2-ae800fd006b1', N'22d39998-47eb-43e4-8174-dff7d3c344fb', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przetrawiałeś', N'920562af-3734-4b73-89c2-ae800fd006b1', N'22d39998-47eb-43e4-8174-dff7d3c344fb', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uspokajajcież', N'920562af-3734-4b73-89c2-ae800fd006b1', N'22d39998-47eb-43e4-8174-dff7d3c344fb', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'współzależący', N'920562af-3734-4b73-89c2-ae800fd006b1', N'22d39998-47eb-43e4-8174-dff7d3c344fb', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'boatlike
', N'9288c00f-9ed2-4708-8da0-f4c84a698aae', N'407c141a-e8dd-4029-8feb-faa202fa7a5b', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chazzans
', N'9288c00f-9ed2-4708-8da0-f4c84a698aae', N'407c141a-e8dd-4029-8feb-faa202fa7a5b', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'crustate
', N'9288c00f-9ed2-4708-8da0-f4c84a698aae', N'407c141a-e8dd-4029-8feb-faa202fa7a5b', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'displume
', N'9288c00f-9ed2-4708-8da0-f4c84a698aae', N'407c141a-e8dd-4029-8feb-faa202fa7a5b', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gnarlier
', N'9288c00f-9ed2-4708-8da0-f4c84a698aae', N'407c141a-e8dd-4029-8feb-faa202fa7a5b', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'shavings
', N'9288c00f-9ed2-4708-8da0-f4c84a698aae', N'407c141a-e8dd-4029-8feb-faa202fa7a5b', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trapunto
', N'9288c00f-9ed2-4708-8da0-f4c84a698aae', N'407c141a-e8dd-4029-8feb-faa202fa7a5b', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unsocket
', N'9288c00f-9ed2-4708-8da0-f4c84a698aae', N'407c141a-e8dd-4029-8feb-faa202fa7a5b', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cieplak', N'950c4796-9c54-4042-a468-bfca8b6fc2a3', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'esencji', N'950c4796-9c54-4042-a468-bfca8b6fc2a3', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'karettą', N'950c4796-9c54-4042-a468-bfca8b6fc2a3', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'liftuje', N'950c4796-9c54-4042-a468-bfca8b6fc2a3', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odmiano', N'950c4796-9c54-4042-a468-bfca8b6fc2a3', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'popłaca', N'950c4796-9c54-4042-a468-bfca8b6fc2a3', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'workach', N'950c4796-9c54-4042-a468-bfca8b6fc2a3', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hopsasa', N'950c4796-9c54-4042-a468-bfca8b6fc2a3', N'25dde876-8acb-41ee-919f-0cfc5fde07c7', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'leghorn', N'950c4796-9c54-4042-a468-bfca8b6fc2a3', N'25dde876-8acb-41ee-919f-0cfc5fde07c7', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'liftuje', N'950c4796-9c54-4042-a468-bfca8b6fc2a3', N'25dde876-8acb-41ee-919f-0cfc5fde07c7', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'liftuje', N'950c4796-9c54-4042-a468-bfca8b6fc2a3', N'2b1b01f3-59ab-472c-a49c-c053b25eb4eb', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lonżach', N'950c4796-9c54-4042-a468-bfca8b6fc2a3', N'2b1b01f3-59ab-472c-a49c-c053b25eb4eb', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odmiano', N'950c4796-9c54-4042-a468-bfca8b6fc2a3', N'2b1b01f3-59ab-472c-a49c-c053b25eb4eb', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'siorpań', N'950c4796-9c54-4042-a468-bfca8b6fc2a3', N'2b1b01f3-59ab-472c-a49c-c053b25eb4eb', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'grounders
', N'958cf3b1-3ed1-45e7-b689-5188423ca274', N'6fc830b2-17d2-430c-9188-8310faa228e8', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'blonds
', N'97a139ac-a7b3-428f-85ae-a995d1a94419', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rissel
', N'97a139ac-a7b3-428f-85ae-a995d1a94419', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'araise
', N'97a139ac-a7b3-428f-85ae-a995d1a94419', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hartly
', N'97a139ac-a7b3-428f-85ae-a995d1a94419', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'muscle
', N'97a139ac-a7b3-428f-85ae-a995d1a94419', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rissel
', N'97a139ac-a7b3-428f-85ae-a995d1a94419', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'whelms
', N'97a139ac-a7b3-428f-85ae-a995d1a94419', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hexadd
', N'97a139ac-a7b3-428f-85ae-a995d1a94419', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'aiding
', N'97a139ac-a7b3-428f-85ae-a995d1a94419', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'miting
', N'97a139ac-a7b3-428f-85ae-a995d1a94419', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reeked
', N'97a139ac-a7b3-428f-85ae-a995d1a94419', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rissel
', N'97a139ac-a7b3-428f-85ae-a995d1a94419', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'squirm
', N'97a139ac-a7b3-428f-85ae-a995d1a94419', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'teenty
', N'97a139ac-a7b3-428f-85ae-a995d1a94419', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'liofobowych', N'99a34d25-f370-498b-95f5-3c66600539b3', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lobbowaliby', N'99a34d25-f370-498b-95f5-3c66600539b3', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieporowata', N'99a34d25-f370-498b-95f5-3c66600539b3', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pogrążyliby', N'99a34d25-f370-498b-95f5-3c66600539b3', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unarodowiła', N'99a34d25-f370-498b-95f5-3c66600539b3', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wymienienia', N'99a34d25-f370-498b-95f5-3c66600539b3', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wytrzeźwiam', N'99a34d25-f370-498b-95f5-3c66600539b3', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kleptomanie', N'99a34d25-f370-498b-95f5-3c66600539b3', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieporowata', N'99a34d25-f370-498b-95f5-3c66600539b3', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'paszalikaty', N'99a34d25-f370-498b-95f5-3c66600539b3', N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieporowata', N'99a34d25-f370-498b-95f5-3c66600539b3', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieulaniach', N'99a34d25-f370-498b-95f5-3c66600539b3', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'obstąpiłoby', N'99a34d25-f370-498b-95f5-3c66600539b3', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'porżnięciem', N'99a34d25-f370-498b-95f5-3c66600539b3', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bostal
', N'9b59cc47-7d34-4935-b45f-816b2cd1b1d3', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dacron
', N'9b59cc47-7d34-4935-b45f-816b2cd1b1d3', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'devels
', N'9b59cc47-7d34-4935-b45f-816b2cd1b1d3', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'edible
', N'9b59cc47-7d34-4935-b45f-816b2cd1b1d3', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'excels
', N'9b59cc47-7d34-4935-b45f-816b2cd1b1d3', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ferine
', N'9b59cc47-7d34-4935-b45f-816b2cd1b1d3', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'jaeger
', N'9b59cc47-7d34-4935-b45f-816b2cd1b1d3', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'karettą', N'9c4ae5a5-9164-4efe-9f7f-b5f283d87a32', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pchając', N'9c4ae5a5-9164-4efe-9f7f-b5f283d87a32', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odcieki', N'9c4ae5a5-9164-4efe-9f7f-b5f283d87a32', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'okręceń', N'9c4ae5a5-9164-4efe-9f7f-b5f283d87a32', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pchając', N'9c4ae5a5-9164-4efe-9f7f-b5f283d87a32', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'popłaca', N'9c4ae5a5-9164-4efe-9f7f-b5f283d87a32', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'toposem', N'9c4ae5a5-9164-4efe-9f7f-b5f283d87a32', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'workach', N'9c4ae5a5-9164-4efe-9f7f-b5f283d87a32', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'aiding
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'boatel
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bouncy
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hoicks
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lovage
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'testor
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'updrag
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6500000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'acylal
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'liefer
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'testor
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bostal
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bouffe
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cholee
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ferine
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'liefer
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'status
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'viewly
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'homing
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a44b03a7-25d6-4920-a662-013c790297ef', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kubong
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a44b03a7-25d6-4920-a662-013c790297ef', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'liefer
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a44b03a7-25d6-4920-a662-013c790297ef', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sheila
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a44b03a7-25d6-4920-a662-013c790297ef', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'toquet
', N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'a44b03a7-25d6-4920-a662-013c790297ef', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cumin
', N'a200f9cc-2918-46f1-8bb1-1b4c3f4f5684', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cupel
', N'a200f9cc-2918-46f1-8bb1-1b4c3f4f5684', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nasty
', N'a200f9cc-2918-46f1-8bb1-1b4c3f4f5684', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sabal
', N'a200f9cc-2918-46f1-8bb1-1b4c3f4f5684', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kobierczykowi', N'a39921f7-df95-4238-abfa-f4ec2758e304', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepobudzanym', N'a39921f7-df95-4238-abfa-f4ec2758e304', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podrąbywanych', N'a39921f7-df95-4238-abfa-f4ec2758e304', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ponakreślałeś', N'a39921f7-df95-4238-abfa-f4ec2758e304', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przydawkowemu', N'a39921f7-df95-4238-abfa-f4ec2758e304', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spiekalniczym', N'a39921f7-df95-4238-abfa-f4ec2758e304', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaczadziałbyś', N'a39921f7-df95-4238-abfa-f4ec2758e304', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odpolitycznić', N'a39921f7-df95-4238-abfa-f4ec2758e304', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaczadziałbyś', N'a39921f7-df95-4238-abfa-f4ec2758e304', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dopieralibyście', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nietraktatowymi', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przydźwigaliśmy', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozmazgajającym', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ześrubowaliście', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'intensywniejąca', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieprzebaczalny', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nietasiemkowymi', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zdramatyzowałem', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niearchiwalnego', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'5601a294-6cd8-4969-9e4a-4ff2901ae924', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niegazyfikowany', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'5601a294-6cd8-4969-9e4a-4ff2901ae924', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niegenologiczną', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'5601a294-6cd8-4969-9e4a-4ff2901ae924', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepozawiązywań', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'5601a294-6cd8-4969-9e4a-4ff2901ae924', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieptolemejskim', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'5601a294-6cd8-4969-9e4a-4ff2901ae924', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niewybranieckie', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'5601a294-6cd8-4969-9e4a-4ff2901ae924', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozdzióbywanemu', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'5601a294-6cd8-4969-9e4a-4ff2901ae924', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zdramatyzowałem', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'5601a294-6cd8-4969-9e4a-4ff2901ae924', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niegazyfikowany', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'572b7747-e3eb-4ccf-8211-f013d3618acd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niekażolowanymi', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'572b7747-e3eb-4ccf-8211-f013d3618acd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieksięgowanego', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'572b7747-e3eb-4ccf-8211-f013d3618acd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nietasiemkowymi', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'572b7747-e3eb-4ccf-8211-f013d3618acd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przepustkowicze', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'572b7747-e3eb-4ccf-8211-f013d3618acd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'szaroczerwonemu', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'572b7747-e3eb-4ccf-8211-f013d3618acd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wychwaszczeniem', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'572b7747-e3eb-4ccf-8211-f013d3618acd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zdramatyzowałem', N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'572b7747-e3eb-4ccf-8211-f013d3618acd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dosychajmy', N'a60292d5-d19c-448c-b93c-5bf1a89b0bf8', N'21b134fc-b41d-4feb-a647-0b6b7cf87967', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cieplak', N'a73247b9-4020-4cd1-9944-e934ab6eb437', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'esencji', N'a73247b9-4020-4cd1-9944-e934ab6eb437', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kwakier', N'a73247b9-4020-4cd1-9944-e934ab6eb437', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pchając', N'a73247b9-4020-4cd1-9944-e934ab6eb437', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pędraka', N'a73247b9-4020-4cd1-9944-e934ab6eb437', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podtyło', N'a73247b9-4020-4cd1-9944-e934ab6eb437', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'toposem', N'a73247b9-4020-4cd1-9944-e934ab6eb437', N'24cc5ed4-1554-4928-b506-86af57e5317a', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hospitantach', N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kabaretujemy', N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niehadziaccy', N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'semazjologią', N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tabulowanego', N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unaocznionej', N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zabłagałabyś', N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'anagnoryzmom', N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'libracyjnymi', N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naopowiadaną', N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezdwojonym', N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieznęcanego', N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niespecjalny', N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pozamalarska', N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozpatrujmyż', N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zabłagałabyś', N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zmotyczkować', N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cambiata
', N'a83ec9ff-e82f-4b09-8701-f468d40ebf5f', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'exorcism
', N'a83ec9ff-e82f-4b09-8701-f468d40ebf5f', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'liquored
', N'a83ec9ff-e82f-4b09-8701-f468d40ebf5f', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'locksman
', N'a83ec9ff-e82f-4b09-8701-f468d40ebf5f', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'utilises
', N'a83ec9ff-e82f-4b09-8701-f468d40ebf5f', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'validity
', N'a83ec9ff-e82f-4b09-8701-f468d40ebf5f', N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'audition
', N'a83ec9ff-e82f-4b09-8701-f468d40ebf5f', N'9f85aedf-6139-484b-9fc6-f9ea39e50079', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'paraphed
', N'a83ec9ff-e82f-4b09-8701-f468d40ebf5f', N'9f85aedf-6139-484b-9fc6-f9ea39e50079', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cephalodiscida
', N'a85375a5-87e8-4aa3-936f-d6ece46f5491', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'disarticulated
', N'a85375a5-87e8-4aa3-936f-d6ece46f5491', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'healthsomeness
', N'a85375a5-87e8-4aa3-936f-d6ece46f5491', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ichthyophagous
', N'a85375a5-87e8-4aa3-936f-d6ece46f5491', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'intercessorial
', N'a85375a5-87e8-4aa3-936f-d6ece46f5491', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'intermunicipal
', N'a85375a5-87e8-4aa3-936f-d6ece46f5491', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'noncontractual
', N'a85375a5-87e8-4aa3-936f-d6ece46f5491', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'photographable
', N'a85375a5-87e8-4aa3-936f-d6ece46f5491', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'healthsomeness
', N'a85375a5-87e8-4aa3-936f-d6ece46f5491', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hyperdelicious
', N'a85375a5-87e8-4aa3-936f-d6ece46f5491', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'inamissibility
', N'a85375a5-87e8-4aa3-936f-d6ece46f5491', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonefficacious
', N'a85375a5-87e8-4aa3-936f-d6ece46f5491', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'redimensioning
', N'a85375a5-87e8-4aa3-936f-d6ece46f5491', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uncollectively
', N'a85375a5-87e8-4aa3-936f-d6ece46f5491', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unnitrogenised
', N'a85375a5-87e8-4aa3-936f-d6ece46f5491', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bruising
', N'aa1aa489-849d-4570-89c3-5ab9549a7ff7', N'e2f0e6b6-70d8-410b-b42d-deb2d32e00ae', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bruising
', N'aa1aa489-849d-4570-89c3-5ab9549a7ff7', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bruising
', N'aa1aa489-849d-4570-89c3-5ab9549a7ff7', N'e59bcd84-c04a-45cf-98e8-3580f6750984', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'calicoes
', N'aa1aa489-849d-4570-89c3-5ab9549a7ff7', N'e59bcd84-c04a-45cf-98e8-3580f6750984', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'goshawks
', N'aa1aa489-849d-4570-89c3-5ab9549a7ff7', N'e59bcd84-c04a-45cf-98e8-3580f6750984', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hospitia
', N'aa1aa489-849d-4570-89c3-5ab9549a7ff7', N'e59bcd84-c04a-45cf-98e8-3580f6750984', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'paraphed
', N'aa1aa489-849d-4570-89c3-5ab9549a7ff7', N'e59bcd84-c04a-45cf-98e8-3580f6750984', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pitiable
', N'aa1aa489-849d-4570-89c3-5ab9549a7ff7', N'e59bcd84-c04a-45cf-98e8-3580f6750984', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sheraton
', N'aa1aa489-849d-4570-89c3-5ab9549a7ff7', N'e59bcd84-c04a-45cf-98e8-3580f6750984', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ungraced
', N'aa1aa489-849d-4570-89c3-5ab9549a7ff7', N'e59bcd84-c04a-45cf-98e8-3580f6750984', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'balaghat
', N'aa1aa489-849d-4570-89c3-5ab9549a7ff7', N'e5f9c68a-18c1-4907-ae44-c85861dfb739', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bruising
', N'aa1aa489-849d-4570-89c3-5ab9549a7ff7', N'e5f9c68a-18c1-4907-ae44-c85861dfb739', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cambiata
', N'aa1aa489-849d-4570-89c3-5ab9549a7ff7', N'e5f9c68a-18c1-4907-ae44-c85861dfb739', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'quaffers
', N'aa1aa489-849d-4570-89c3-5ab9549a7ff7', N'e5f9c68a-18c1-4907-ae44-c85861dfb739', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unlocker
', N'aa1aa489-849d-4570-89c3-5ab9549a7ff7', N'e5f9c68a-18c1-4907-ae44-c85861dfb739', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'monstrousness
', N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'neighbourlike
', N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ornithosauria
', N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'parakeratosis
', N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sodioplatinic
', N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'antepenultima
', N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'immatriculate
', N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'intercalative
', N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'microsporidia
', N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'monstrousness
', N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'parakeratosis
', N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'quadriternate
', N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unpuritanical
', N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'detectability
', N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'interrogatrix
', N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'monstrousness
', N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'parakeratosis
', N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'underbeveling
', N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unpuritanical
', N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'malpresentation
', N'ae47c74e-5834-49d6-89df-534ede6093b6', N'037a6380-46ef-4327-b1bb-5aef7a64dbc5', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'enantiomorphism
', N'ae47c74e-5834-49d6-89df-534ede6093b6', N'062bfaca-f1ba-4664-a5f3-7988132458b9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hyperexaltation
', N'ae47c74e-5834-49d6-89df-534ede6093b6', N'062bfaca-f1ba-4664-a5f3-7988132458b9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'malpresentation
', N'ae47c74e-5834-49d6-89df-534ede6093b6', N'062bfaca-f1ba-4664-a5f3-7988132458b9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overaffirmation
', N'ae47c74e-5834-49d6-89df-534ede6093b6', N'062bfaca-f1ba-4664-a5f3-7988132458b9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'precontribution
', N'ae47c74e-5834-49d6-89df-534ede6093b6', N'062bfaca-f1ba-4664-a5f3-7988132458b9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unmanageability
', N'ae47c74e-5834-49d6-89df-534ede6093b6', N'062bfaca-f1ba-4664-a5f3-7988132458b9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'inexpungibility
', N'ae47c74e-5834-49d6-89df-534ede6093b6', N'0814f578-8e38-4615-a110-f342a97e9ba2', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'malpresentation
', N'ae47c74e-5834-49d6-89df-534ede6093b6', N'0814f578-8e38-4615-a110-f342a97e9ba2', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nontangibleness
', N'ae47c74e-5834-49d6-89df-534ede6093b6', N'0814f578-8e38-4615-a110-f342a97e9ba2', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prenecessitated
', N'ae47c74e-5834-49d6-89df-534ede6093b6', N'0814f578-8e38-4615-a110-f342a97e9ba2', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'blastide
', N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'challies
', N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'liquored
', N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'litterer
', N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'misspace
', N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uncoaxal
', N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'avantlay
', N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'babiches
', N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'blastide
', N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'captance
', N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'edeology
', N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'subruler
', N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'actiones
', N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'beefiest
', N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'blastide
', N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'guanayes
', N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'misspace
', N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'olivetan
', N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'venomous
', N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'epidemiologist
', N'b1fe816e-d997-48e8-adb7-f2b59f7409ec', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'intercessorial
', N'b1fe816e-d997-48e8-adb7-f2b59f7409ec', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonefficacious
', N'b1fe816e-d997-48e8-adb7-f2b59f7409ec', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'disarticulated
', N'b1fe816e-d997-48e8-adb7-f2b59f7409ec', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonefficacious
', N'b1fe816e-d997-48e8-adb7-f2b59f7409ec', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'supersweetness
', N'b1fe816e-d997-48e8-adb7-f2b59f7409ec', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odmiano', N'b3a1d09c-2ff4-460d-b3cf-f10a11dd8645', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'anisocytosis
', N'b404fbaa-365e-43d6-a96c-f127c83d5ee3', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unvigorously
', N'b404fbaa-365e-43d6-a96c-f127c83d5ee3', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'boatel
', N'b495de52-6a04-4526-b5e6-e25e23e7ac55', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kubong
', N'b495de52-6a04-4526-b5e6-e25e23e7ac55', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reeked
', N'b495de52-6a04-4526-b5e6-e25e23e7ac55', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sheila
', N'b495de52-6a04-4526-b5e6-e25e23e7ac55', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'teenty
', N'b495de52-6a04-4526-b5e6-e25e23e7ac55', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'whidah
', N'b495de52-6a04-4526-b5e6-e25e23e7ac55', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zombis
', N'b495de52-6a04-4526-b5e6-e25e23e7ac55', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'snatch
', N'b495de52-6a04-4526-b5e6-e25e23e7ac55', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ochotona
', N'b4a49c43-0886-42be-ba4e-df4fc01eb7d0', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'undarned
', N'b4a49c43-0886-42be-ba4e-df4fc01eb7d0', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'paraphed
', N'b4a49c43-0886-42be-ba4e-df4fc01eb7d0', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'undarned
', N'b4a49c43-0886-42be-ba4e-df4fc01eb7d0', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'descrial
', N'b4a49c43-0886-42be-ba4e-df4fc01eb7d0', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'undarned
', N'b4a49c43-0886-42be-ba4e-df4fc01eb7d0', N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'advocaat
', N'b4a49c43-0886-42be-ba4e-df4fc01eb7d0', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'boatlike
', N'b4a49c43-0886-42be-ba4e-df4fc01eb7d0', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'locksman
', N'b4a49c43-0886-42be-ba4e-df4fc01eb7d0', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mealless
', N'b4a49c43-0886-42be-ba4e-df4fc01eb7d0', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pasquils
', N'b4a49c43-0886-42be-ba4e-df4fc01eb7d0', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'totalise
', N'b4a49c43-0886-42be-ba4e-df4fc01eb7d0', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'undarned
', N'b4a49c43-0886-42be-ba4e-df4fc01eb7d0', N'52a35941-62c8-42c1-88e1-37b98a0d272f', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'filcowałabyś', N'b690524b-2082-416a-a319-ea7cc54d9c18', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kaledonidami', N'b690524b-2082-416a-a319-ea7cc54d9c18', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kałożerstwom', N'b690524b-2082-416a-a319-ea7cc54d9c18', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'powyłupujcie', N'b690524b-2082-416a-a319-ea7cc54d9c18', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sideromancję', N'b690524b-2082-416a-a319-ea7cc54d9c18', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wiśniewskiej', N'b690524b-2082-416a-a319-ea7cc54d9c18', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zabłagałabyś', N'b690524b-2082-416a-a319-ea7cc54d9c18', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'poflotacyjni', N'b690524b-2082-416a-a319-ea7cc54d9c18', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pokształciła', N'b690524b-2082-416a-a319-ea7cc54d9c18', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ponawadnianą', N'b690524b-2082-416a-a319-ea7cc54d9c18', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przeganianie', N'b690524b-2082-416a-a319-ea7cc54d9c18', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niedunitowej', N'b690524b-2082-416a-a319-ea7cc54d9c18', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepodłapana', N'b690524b-2082-416a-a319-ea7cc54d9c18', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'poflotacyjni', N'b690524b-2082-416a-a319-ea7cc54d9c18', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'poflotacyjni', N'b690524b-2082-416a-a319-ea7cc54d9c18', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wiosłowałaby', N'b690524b-2082-416a-a319-ea7cc54d9c18', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zdmuchujecie', N'b690524b-2082-416a-a319-ea7cc54d9c18', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'catcher
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'netbush
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'preloan
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rewrote
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'samisen
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'scopula
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'shrines
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wailing
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6510000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'alecize
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'coeliac
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hyraxes
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'isocrat
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'minimal
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pinkeye
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unsteek
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unthrid
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'coeliac
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dapicho
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'deplete
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'flotsen
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rewrote
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wearing
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'coeliac
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'justers
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mayhaps
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'semikah
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sequani
', N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'aiding
', N'bc293cb9-ef1e-43f6-a97d-f7ffc63e3f32', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'arbute
', N'bc293cb9-ef1e-43f6-a97d-f7ffc63e3f32', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'devels
', N'bc293cb9-ef1e-43f6-a97d-f7ffc63e3f32', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'medius
', N'bc293cb9-ef1e-43f6-a97d-f7ffc63e3f32', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prevue
', N'bc293cb9-ef1e-43f6-a97d-f7ffc63e3f32', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dosychajmy', N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ea538c2f-7230-4d87-bbda-29db9fed309b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'falszburto', N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ea538c2f-7230-4d87-bbda-29db9fed309b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'obkupiwszy', N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ea538c2f-7230-4d87-bbda-29db9fed309b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'obrzynanie', N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ea538c2f-7230-4d87-bbda-29db9fed309b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rachowałem', N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ea538c2f-7230-4d87-bbda-29db9fed309b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'szepnęliby', N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ea538c2f-7230-4d87-bbda-29db9fed309b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'urabiające', N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ea538c2f-7230-4d87-bbda-29db9fed309b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zapominane', N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ea538c2f-7230-4d87-bbda-29db9fed309b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fulańskiej', N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ee30ba09-6787-4cbe-b7d5-4136d7aa91a6', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lojalistce', N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ee30ba09-6787-4cbe-b7d5-4136d7aa91a6', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mierzwiącą', N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ee30ba09-6787-4cbe-b7d5-4136d7aa91a6', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'osaczaniem', N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ee30ba09-6787-4cbe-b7d5-4136d7aa91a6', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przygańmyż', N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ee30ba09-6787-4cbe-b7d5-4136d7aa91a6', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tłoczonych', N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ee30ba09-6787-4cbe-b7d5-4136d7aa91a6', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uaktywniać', N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ee30ba09-6787-4cbe-b7d5-4136d7aa91a6', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zatajałbym', N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ee30ba09-6787-4cbe-b7d5-4136d7aa91a6', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hakowaniem', N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ef87dbf8-a3ad-40e0-87e4-3c4633366b28', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'obrzynanie', N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ef87dbf8-a3ad-40e0-87e4-3c4633366b28', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tłoczonych', N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ef87dbf8-a3ad-40e0-87e4-3c4633366b28', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wartogłowy', N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'ef87dbf8-a3ad-40e0-87e4-3c4633366b28', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'antiresonance
', N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'intercalative
', N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'microsporidia
', N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'monstrousness
', N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nasosinusitis
', N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'plagiocephaly
', N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pyretogenetic
', N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'continentaler
', N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'disconnective
', N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'parakeratosis
', N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'politicalized
', N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pyretogenetic
', N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reinfiltrated
', N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sexualization
', N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'acceptability
', N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'intercalative
', N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pyretogenetic
', N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unpuritanical
', N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'captance
', N'c14e83b4-ea76-40ac-b861-b206e01f706b', N'9f85aedf-6139-484b-9fc6-f9ea39e50079', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fireburn
', N'c14e83b4-ea76-40ac-b861-b206e01f706b', N'9f85aedf-6139-484b-9fc6-f9ea39e50079', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'flickers
', N'c14e83b4-ea76-40ac-b861-b206e01f706b', N'9f85aedf-6139-484b-9fc6-f9ea39e50079', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'decagons
', N'c14e83b4-ea76-40ac-b861-b206e01f706b', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'goshawks
', N'c14e83b4-ea76-40ac-b861-b206e01f706b', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prebills
', N'c14e83b4-ea76-40ac-b861-b206e01f706b', N'a0a31ca1-3db7-433d-962a-cae885a1c872', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'validity
', N'c14e83b4-ea76-40ac-b861-b206e01f706b', N'a37d819d-bb8f-41a7-9bfb-330deef38df3', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'boatlike
', N'c14e83b4-ea76-40ac-b861-b206e01f706b', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'decagons
', N'c14e83b4-ea76-40ac-b861-b206e01f706b', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'deniably
', N'c14e83b4-ea76-40ac-b861-b206e01f706b', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'embolize
', N'c14e83b4-ea76-40ac-b861-b206e01f706b', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'freshish
', N'c14e83b4-ea76-40ac-b861-b206e01f706b', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hoosiers
', N'c14e83b4-ea76-40ac-b861-b206e01f706b', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hospitia
', N'c14e83b4-ea76-40ac-b861-b206e01f706b', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'shavings
', N'c14e83b4-ea76-40ac-b861-b206e01f706b', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'capo
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'elmy
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'leno
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'limo
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'munt
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'peck
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'star
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tiny
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'capo
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'46f32deb-fd2a-4544-88f4-27e9aaafe0a3', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'elmy
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'46f32deb-fd2a-4544-88f4-27e9aaafe0a3', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'limo
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'46f32deb-fd2a-4544-88f4-27e9aaafe0a3', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ovis
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'46f32deb-fd2a-4544-88f4-27e9aaafe0a3', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tiny
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'46f32deb-fd2a-4544-88f4-27e9aaafe0a3', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'coda
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dowf
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'elmy
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'leno
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'munt
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ovis
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'paws
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'peck
', N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'demagnetyzować', N'c24152a9-f8dd-44ec-9355-df4a5192902b', N'efd2d829-2500-4c66-bd27-586989316647', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'demagnetyzować', N'c24152a9-f8dd-44ec-9355-df4a5192902b', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezwieszający', N'c24152a9-f8dd-44ec-9355-df4a5192902b', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zdetonowaniach', N'c24152a9-f8dd-44ec-9355-df4a5192902b', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'napoprawiajcie', N'c24152a9-f8dd-44ec-9355-df4a5192902b', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niedodrukowane', N'c24152a9-f8dd-44ec-9355-df4a5192902b', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niedysfotyczni', N'c24152a9-f8dd-44ec-9355-df4a5192902b', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'serwohamulcowi', N'c24152a9-f8dd-44ec-9355-df4a5192902b', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zdetonowaniach', N'c24152a9-f8dd-44ec-9355-df4a5192902b', N'f19efa75-22a8-4287-9bd0-f088ed41f30b', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'decapodiform
', N'c44928ae-a1c7-4b92-86b6-f9efd26f9f11', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'jeffersonian
', N'c44928ae-a1c7-4b92-86b6-f9efd26f9f11', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonsentience
', N'c44928ae-a1c7-4b92-86b6-f9efd26f9f11', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'semibachelor
', N'c44928ae-a1c7-4b92-86b6-f9efd26f9f11', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unwassailing
', N'c44928ae-a1c7-4b92-86b6-f9efd26f9f11', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'apometabolic
', N'c44928ae-a1c7-4b92-86b6-f9efd26f9f11', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonsentience
', N'c44928ae-a1c7-4b92-86b6-f9efd26f9f11', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'undreadfully
', N'c44928ae-a1c7-4b92-86b6-f9efd26f9f11', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ileocolotomy
', N'c44928ae-a1c7-4b92-86b6-f9efd26f9f11', N'837b4e63-6c22-4508-936d-cb31fcb0a58e', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'jeffersonian
', N'c44928ae-a1c7-4b92-86b6-f9efd26f9f11', N'837b4e63-6c22-4508-936d-cb31fcb0a58e', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonsentience
', N'c44928ae-a1c7-4b92-86b6-f9efd26f9f11', N'837b4e63-6c22-4508-936d-cb31fcb0a58e', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'otologically
', N'c44928ae-a1c7-4b92-86b6-f9efd26f9f11', N'837b4e63-6c22-4508-936d-cb31fcb0a58e', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'phentolamine
', N'c44928ae-a1c7-4b92-86b6-f9efd26f9f11', N'837b4e63-6c22-4508-936d-cb31fcb0a58e', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'retrenchable
', N'c44928ae-a1c7-4b92-86b6-f9efd26f9f11', N'837b4e63-6c22-4508-936d-cb31fcb0a58e', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dozorującymi', N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hospitantach', N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieparobkowa', N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'parapitekach', N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'posnobujecie', N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przedpisemne', N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wiosłowałaby', N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zeświecczcie', N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'basketballom', N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dozorującymi', N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'opiniowałbyś', N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pozamalarska', N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sojuszniczek', N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kałożerstwom', N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'opiniowałbyś', N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'adsorbowałeś', N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'łagodniejący', N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieciernisty', N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nietuczarski', N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'upieprzyliby', N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'obiektywizowane', N'c6be93cb-588c-4dd5-ac98-072aeda5dd89', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zamiauczałyście', N'c6be93cb-588c-4dd5-ac98-072aeda5dd89', N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niearchiwalnego', N'c6be93cb-588c-4dd5-ac98-072aeda5dd89', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepodkrajaniem', N'c6be93cb-588c-4dd5-ac98-072aeda5dd89', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepomasowaniem', N'c6be93cb-588c-4dd5-ac98-072aeda5dd89', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieprzebaczalny', N'c6be93cb-588c-4dd5-ac98-072aeda5dd89', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieprzerzucaniu', N'c6be93cb-588c-4dd5-ac98-072aeda5dd89', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'roztłamszeniami', N'c6be93cb-588c-4dd5-ac98-072aeda5dd89', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'szaroczerwonemu', N'c6be93cb-588c-4dd5-ac98-072aeda5dd89', N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepowykładanym', N'c6be93cb-588c-4dd5-ac98-072aeda5dd89', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'obiektywizowane', N'c6be93cb-588c-4dd5-ac98-072aeda5dd89', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'petrarkowskiego', N'c6be93cb-588c-4dd5-ac98-072aeda5dd89', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przydźwigaliśmy', N'c6be93cb-588c-4dd5-ac98-072aeda5dd89', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'raves
', N'ccdc9c9c-555c-467c-a671-b4a914ea514f', N'e2f0e6b6-70d8-410b-b42d-deb2d32e00ae', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spill
', N'ccdc9c9c-555c-467c-a671-b4a914ea514f', N'e2f0e6b6-70d8-410b-b42d-deb2d32e00ae', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'viewy
', N'ccdc9c9c-555c-467c-a671-b4a914ea514f', N'e2f0e6b6-70d8-410b-b42d-deb2d32e00ae', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'write
', N'ccdc9c9c-555c-467c-a671-b4a914ea514f', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'yeses
', N'ccdc9c9c-555c-467c-a671-b4a914ea514f', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'banksias
', N'ccf366d2-679f-4e86-9d82-45074cd38300', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'liquored
', N'ccf366d2-679f-4e86-9d82-45074cd38300', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'minitant
', N'ccf366d2-679f-4e86-9d82-45074cd38300', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reclined
', N'ccf366d2-679f-4e86-9d82-45074cd38300', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chapourn
', N'ccf366d2-679f-4e86-9d82-45074cd38300', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'boatlike
', N'ccf366d2-679f-4e86-9d82-45074cd38300', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chapourn
', N'ccf366d2-679f-4e86-9d82-45074cd38300', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ochotona
', N'ccf366d2-679f-4e86-9d82-45074cd38300', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'presound
', N'ccf366d2-679f-4e86-9d82-45074cd38300', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gledy
', N'cd8b394a-655e-403b-9ac0-99f44563c439', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'knell
', N'cd8b394a-655e-403b-9ac0-99f44563c439', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sabal
', N'cd8b394a-655e-403b-9ac0-99f44563c439', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'skiwy
', N'cd8b394a-655e-403b-9ac0-99f44563c439', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sheer
', N'cd8b394a-655e-403b-9ac0-99f44563c439', N'96aed832-57a1-4204-ad3c-1d662855e890', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'yeses
', N'cd8b394a-655e-403b-9ac0-99f44563c439', N'96aed832-57a1-4204-ad3c-1d662855e890', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'askoi
', N'cd8b394a-655e-403b-9ac0-99f44563c439', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gledy
', N'cd8b394a-655e-403b-9ac0-99f44563c439', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'yeses
', N'cd8b394a-655e-403b-9ac0-99f44563c439', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'acoelomi
', N'ce744950-8172-4392-8663-675d2ab0867b', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'caracoli
', N'ce744950-8172-4392-8663-675d2ab0867b', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'carpuspi
', N'ce744950-8172-4392-8663-675d2ab0867b', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chamorro
', N'ce744950-8172-4392-8663-675d2ab0867b', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'groomlet
', N'ce744950-8172-4392-8663-675d2ab0867b', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prebills
', N'ce744950-8172-4392-8663-675d2ab0867b', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rechoose
', N'ce744950-8172-4392-8663-675d2ab0867b', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'beefiest
', N'ce744950-8172-4392-8663-675d2ab0867b', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'encysted
', N'ce744950-8172-4392-8663-675d2ab0867b', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'glyceric
', N'ce744950-8172-4392-8663-675d2ab0867b', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'guanayes
', N'ce744950-8172-4392-8663-675d2ab0867b', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hoofbeat
', N'ce744950-8172-4392-8663-675d2ab0867b', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'infusing
', N'ce744950-8172-4392-8663-675d2ab0867b', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tchincou
', N'ce744950-8172-4392-8663-675d2ab0867b', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'utilises
', N'ce744950-8172-4392-8663-675d2ab0867b', N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'boatlike
', N'ce744950-8172-4392-8663-675d2ab0867b', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cokneyfy
', N'ce744950-8172-4392-8663-675d2ab0867b', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unlocker
', N'ce744950-8172-4392-8663-675d2ab0867b', N'afb97918-833e-4047-bc1e-15013125f24a', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bitbrace
', N'ce744950-8172-4392-8663-675d2ab0867b', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bruising
', N'ce744950-8172-4392-8663-675d2ab0867b', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'manistic
', N'ce744950-8172-4392-8663-675d2ab0867b', N'b2a341cf-1161-40b8-9aac-9531719e66f0', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'jednokomórkowi', N'cedaa45a-ae23-4b6c-ae9d-e5f7811fe90a', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieuprawnienie', N'cedaa45a-ae23-4b6c-ae9d-e5f7811fe90a', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezwieszający', N'cedaa45a-ae23-4b6c-ae9d-e5f7811fe90a', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pourządzałabyś', N'cedaa45a-ae23-4b6c-ae9d-e5f7811fe90a', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chloramfenikol', N'cedaa45a-ae23-4b6c-ae9d-e5f7811fe90a', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niedysfotyczni', N'cedaa45a-ae23-4b6c-ae9d-e5f7811fe90a', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieinhibicyjne', N'cedaa45a-ae23-4b6c-ae9d-e5f7811fe90a', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieuprawnienie', N'cedaa45a-ae23-4b6c-ae9d-e5f7811fe90a', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'freshish
', N'd03b2469-f02b-4b4e-99e6-569b49a1252b', N'65d5ff57-2e47-4394-8819-11740013b756', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cambiata
', N'd03b2469-f02b-4b4e-99e6-569b49a1252b', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'freshish
', N'd03b2469-f02b-4b4e-99e6-569b49a1252b', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'greasing
', N'd03b2469-f02b-4b4e-99e6-569b49a1252b', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'olivetan
', N'd03b2469-f02b-4b4e-99e6-569b49a1252b', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'utilises
', N'd03b2469-f02b-4b4e-99e6-569b49a1252b', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'yestreen
', N'd03b2469-f02b-4b4e-99e6-569b49a1252b', N'67789511-6503-4c37-9de6-ec5e65be7dde', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dieldrin
', N'd03b2469-f02b-4b4e-99e6-569b49a1252b', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'freshish
', N'd03b2469-f02b-4b4e-99e6-569b49a1252b', N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'boczeniami', N'd274435a-b02d-4ef7-814d-10ec9660d561', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'eklektykom', N'd274435a-b02d-4ef7-814d-10ec9660d561', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaśliniłem', N'd274435a-b02d-4ef7-814d-10ec9660d561', N'31f730a1-1735-445c-8365-6bdc59d77a28', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'boczeniami', N'd274435a-b02d-4ef7-814d-10ec9660d561', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odwirujesz', N'd274435a-b02d-4ef7-814d-10ec9660d561', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podobijamy', N'd274435a-b02d-4ef7-814d-10ec9660d561', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zbereźniki', N'd274435a-b02d-4ef7-814d-10ec9660d561', N'322056ff-d55d-42c9-93d3-3fe560e3559c', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'boczeniami', N'd274435a-b02d-4ef7-814d-10ec9660d561', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kanciatemu', N'd274435a-b02d-4ef7-814d-10ec9660d561', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mierzwiącą', N'd274435a-b02d-4ef7-814d-10ec9660d561', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieodrowym', N'd274435a-b02d-4ef7-814d-10ec9660d561', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'poustalasz', N'd274435a-b02d-4ef7-814d-10ec9660d561', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przepocono', N'd274435a-b02d-4ef7-814d-10ec9660d561', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wartogłowy', N'd274435a-b02d-4ef7-814d-10ec9660d561', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zmokniętej', N'd274435a-b02d-4ef7-814d-10ec9660d561', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6520000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'imprejudicate
', N'd3b101cd-48ef-4b7f-8b34-83347b76e32f', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'preconquestal
', N'd3b101cd-48ef-4b7f-8b34-83347b76e32f', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'heteroerotism
', N'd3b101cd-48ef-4b7f-8b34-83347b76e32f', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'immatriculate
', N'd3b101cd-48ef-4b7f-8b34-83347b76e32f', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'plagiocephaly
', N'd3b101cd-48ef-4b7f-8b34-83347b76e32f', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'preconquestal
', N'd3b101cd-48ef-4b7f-8b34-83347b76e32f', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'banksias
', N'd42b1a49-bf1a-499f-94d9-670e0c3f7b99', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'descrial
', N'd42b1a49-bf1a-499f-94d9-670e0c3f7b99', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'shavings
', N'd42b1a49-bf1a-499f-94d9-670e0c3f7b99', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'excretal
', N'd42b1a49-bf1a-499f-94d9-670e0c3f7b99', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'paraphed
', N'd42b1a49-bf1a-499f-94d9-670e0c3f7b99', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'undarned
', N'd42b1a49-bf1a-499f-94d9-670e0c3f7b99', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chamorro
', N'd42b1a49-bf1a-499f-94d9-670e0c3f7b99', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'excretal
', N'd42b1a49-bf1a-499f-94d9-670e0c3f7b99', N'639f539a-d0d5-4ae8-8501-922f204025aa', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'diabantite
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'disleafing
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'limpnesses
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'palatality
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'planetable
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'squirelike
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'suppliancy
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'buckboards
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cochleitis
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'felineness
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ineligibly
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'planetable
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rostellate
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uniflorous
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'azotenesis
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chironomus
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'noneconomy
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'planetable
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tariffless
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'berascaled
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'e2532790-0bef-45d7-bd16-81709f211432', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lithophyll
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'e2532790-0bef-45d7-bd16-81709f211432', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'planetable
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'e2532790-0bef-45d7-bd16-81709f211432', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'quinnipiac
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'e2532790-0bef-45d7-bd16-81709f211432', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'springlock
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'e2532790-0bef-45d7-bd16-81709f211432', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trematodes
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'e2532790-0bef-45d7-bd16-81709f211432', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unfineable
', N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'e2532790-0bef-45d7-bd16-81709f211432', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'corrosionproof
', N'da2b21b2-4639-4862-b3c3-ca45837c559c', N'efd2d829-2500-4c66-bd27-586989316647', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'haemocytoblast
', N'da2b21b2-4639-4862-b3c3-ca45837c559c', N'efd2d829-2500-4c66-bd27-586989316647', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'stereoblastula
', N'da2b21b2-4639-4862-b3c3-ca45837c559c', N'efd2d829-2500-4c66-bd27-586989316647', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trappabilities
', N'da2b21b2-4639-4862-b3c3-ca45837c559c', N'efd2d829-2500-4c66-bd27-586989316647', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uncollectively
', N'da2b21b2-4639-4862-b3c3-ca45837c559c', N'efd2d829-2500-4c66-bd27-586989316647', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'elastorze', N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kimałabym', N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przywykał', N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rugującej', N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wazelinom', N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wygwizdów', N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'alsiferem', N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'łataczami', N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naśladuję', N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieulowym', N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieżyjące', N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podskubmy', N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wkreślony', N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wygwizdów', N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kalekiemu', N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'makijażom', N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'podłamuję', N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wygwizdów', N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chenopods
', N'db60a923-a419-4891-bfa9-6996811a87fd', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'engrafter
', N'db60a923-a419-4891-bfa9-6996811a87fd', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hymettian
', N'db60a923-a419-4891-bfa9-6996811a87fd', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'miniscule
', N'db60a923-a419-4891-bfa9-6996811a87fd', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'penseroso
', N'db60a923-a419-4891-bfa9-6996811a87fd', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tricresol
', N'db60a923-a419-4891-bfa9-6996811a87fd', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'engrafter
', N'db60a923-a419-4891-bfa9-6996811a87fd', N'837b4e63-6c22-4508-936d-cb31fcb0a58e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'challies
', N'def3e01c-8d48-40d6-86a9-baad5125ffa7', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'encysted
', N'def3e01c-8d48-40d6-86a9-baad5125ffa7', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'greasing
', N'def3e01c-8d48-40d6-86a9-baad5125ffa7', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'homotype
', N'def3e01c-8d48-40d6-86a9-baad5125ffa7', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pandorea
', N'def3e01c-8d48-40d6-86a9-baad5125ffa7', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'regauges
', N'def3e01c-8d48-40d6-86a9-baad5125ffa7', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unringed
', N'def3e01c-8d48-40d6-86a9-baad5125ffa7', N'32ee171b-9194-40ff-9c4f-dc75b1266a99', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'connectedly
', N'df4e5ab0-1be8-44e0-8099-6c5ba15540bd', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'geniculated
', N'df4e5ab0-1be8-44e0-8099-6c5ba15540bd', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'merostomous
', N'df4e5ab0-1be8-44e0-8099-6c5ba15540bd', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'monosomatic
', N'df4e5ab0-1be8-44e0-8099-6c5ba15540bd', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prederiving
', N'df4e5ab0-1be8-44e0-8099-6c5ba15540bd', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sphaeridial
', N'df4e5ab0-1be8-44e0-8099-6c5ba15540bd', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'squirtingly
', N'df4e5ab0-1be8-44e0-8099-6c5ba15540bd', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cementoma
', N'e09de163-e0cd-46e0-a206-b1c4ca45668c', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cunningly
', N'e09de163-e0cd-46e0-a206-b1c4ca45668c', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'emergents
', N'e09de163-e0cd-46e0-a206-b1c4ca45668c', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fieldward
', N'e09de163-e0cd-46e0-a206-b1c4ca45668c', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'goldfinny
', N'e09de163-e0cd-46e0-a206-b1c4ca45668c', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'karyomere
', N'e09de163-e0cd-46e0-a206-b1c4ca45668c', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'miniscule
', N'e09de163-e0cd-46e0-a206-b1c4ca45668c', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unbrittle
', N'e09de163-e0cd-46e0-a206-b1c4ca45668c', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bromobenzenu', N'e305757c-3ff1-490d-98d4-a4fe5ca76237', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hospitantach', N'e305757c-3ff1-490d-98d4-a4fe5ca76237', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kontestowano', N'e305757c-3ff1-490d-98d4-a4fe5ca76237', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kroksztynkom', N'e305757c-3ff1-490d-98d4-a4fe5ca76237', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'orkiestronie', N'e305757c-3ff1-490d-98d4-a4fe5ca76237', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozścielanej', N'e305757c-3ff1-490d-98d4-a4fe5ca76237', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sensytywnych', N'e305757c-3ff1-490d-98d4-a4fe5ca76237', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'styliolitach', N'e305757c-3ff1-490d-98d4-a4fe5ca76237', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'znobilitujmy', N'e305757c-3ff1-490d-98d4-a4fe5ca76237', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'biomechaniką', N'e305757c-3ff1-490d-98d4-a4fe5ca76237', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'waggonwayman
', N'e654a1ee-ce8b-4fd7-bfbd-11699177b91e', N'e2f0e6b6-70d8-410b-b42d-deb2d32e00ae', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'acetyliodide
', N'e654a1ee-ce8b-4fd7-bfbd-11699177b91e', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'austronesian
', N'e654a1ee-ce8b-4fd7-bfbd-11699177b91e', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonselection
', N'e654a1ee-ce8b-4fd7-bfbd-11699177b91e', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'originatress
', N'e654a1ee-ce8b-4fd7-bfbd-11699177b91e', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rhineurynter
', N'e654a1ee-ce8b-4fd7-bfbd-11699177b91e', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'spiderflower
', N'e654a1ee-ce8b-4fd7-bfbd-11699177b91e', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'waggonwayman
', N'e654a1ee-ce8b-4fd7-bfbd-11699177b91e', N'e595025e-707b-461a-9182-f7d465d2f91f', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cysticarpic
', N'e7e83a2c-e3d4-4c60-8363-f902fc714422', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pericycloid
', N'e7e83a2c-e3d4-4c60-8363-f902fc714422', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reharmonize
', N'e7e83a2c-e3d4-4c60-8363-f902fc714422', N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'beefiest
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'guanayes
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'captance
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'crevalle
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'edeology
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'guanayes
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'overtrim
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prebills
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unsensed
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'arculite
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'caddises
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chamorro
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'guanayes
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'shavings
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'simility
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ungraced
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'banjoist
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bitbrace
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cirrhose
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'curiatii
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dinamode
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'guanayes
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hoofbeat
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ochotona
', N'e8412762-7863-4580-b68a-2b0864e9b858', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'geesowsku', N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'96aed832-57a1-4204-ad3c-1d662855e890', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bobowałem', N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'diuretyno', N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naśladuję', N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieopętań', N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niesterań', N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'piłkowata', N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'torfujemy', N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wazelinom', N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bobowałem', N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'burkińsku', N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'joginiach', N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'łataczami', N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'locativów', N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'margaryno', N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'poślizgom', N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wygwizdów', N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'9b1155aa-8ba2-4787-a116-61033d2f35b7', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'autokomisu', N'ebe2f6da-a76c-48cd-b361-6d652df9a0ae', N'e2f0e6b6-70d8-410b-b42d-deb2d32e00ae', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'forytowały', N'ebe2f6da-a76c-48cd-b361-6d652df9a0ae', N'e2f0e6b6-70d8-410b-b42d-deb2d32e00ae', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pogadywali', N'ebe2f6da-a76c-48cd-b361-6d652df9a0ae', N'e2f0e6b6-70d8-410b-b42d-deb2d32e00ae', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wydziałową', N'ebe2f6da-a76c-48cd-b361-6d652df9a0ae', N'e2f0e6b6-70d8-410b-b42d-deb2d32e00ae', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'epidemiologist
', N'ed1f8b57-eff5-4c99-ae7d-963894721ac6', N'21b134fc-b41d-4feb-a647-0b6b7cf87967', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'phytomastigoda
', N'ed1f8b57-eff5-4c99-ae7d-963894721ac6', N'21b134fc-b41d-4feb-a647-0b6b7cf87967', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'protopatrician
', N'ed1f8b57-eff5-4c99-ae7d-963894721ac6', N'21b134fc-b41d-4feb-a647-0b6b7cf87967', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'redimensioning
', N'ed1f8b57-eff5-4c99-ae7d-963894721ac6', N'21b134fc-b41d-4feb-a647-0b6b7cf87967', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'thioantimonate
', N'ed1f8b57-eff5-4c99-ae7d-963894721ac6', N'21b134fc-b41d-4feb-a647-0b6b7cf87967', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'untranquilized
', N'ed1f8b57-eff5-4c99-ae7d-963894721ac6', N'21b134fc-b41d-4feb-a647-0b6b7cf87967', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cysticarpic
', N'ed4d65ae-af63-43a5-8252-d0db08c6ac1d', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gametophyll
', N'ed4d65ae-af63-43a5-8252-d0db08c6ac1d', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'underbutler
', N'ed4d65ae-af63-43a5-8252-d0db08c6ac1d', N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'merostomous
', N'ed4d65ae-af63-43a5-8252-d0db08c6ac1d', N'a44b03a7-25d6-4920-a662-013c790297ef', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'underbutler
', N'ed4d65ae-af63-43a5-8252-d0db08c6ac1d', N'a44b03a7-25d6-4920-a662-013c790297ef', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fructuously
', N'ed4d65ae-af63-43a5-8252-d0db08c6ac1d', N'a469291c-45ea-4395-b544-c3f5e2ac9887', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'recorporify
', N'ed4d65ae-af63-43a5-8252-d0db08c6ac1d', N'a469291c-45ea-4395-b544-c3f5e2ac9887', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'retrocaecal
', N'ed4d65ae-af63-43a5-8252-d0db08c6ac1d', N'a469291c-45ea-4395-b544-c3f5e2ac9887', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'solaceproof
', N'ed4d65ae-af63-43a5-8252-d0db08c6ac1d', N'a469291c-45ea-4395-b544-c3f5e2ac9887', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'aftergrowth
', N'ed4d65ae-af63-43a5-8252-d0db08c6ac1d', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'formicicide
', N'ed4d65ae-af63-43a5-8252-d0db08c6ac1d', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'underbutler
', N'ed4d65ae-af63-43a5-8252-d0db08c6ac1d', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'undisputing
', N'ed4d65ae-af63-43a5-8252-d0db08c6ac1d', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6530000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cutely
', N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'excels
', N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ferine
', N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hoicks
', N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'status
', N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tingly
', N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'whelms
', N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'celebe
', N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'46f32deb-fd2a-4544-88f4-27e9aaafe0a3', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'celebe
', N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cunyie
', N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mashed
', N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sheila
', N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'status
', N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'teenty
', N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'toping
', N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'49bb4258-18d3-4519-bbc6-f0016cea52de', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'regalo
', N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'4cfd8062-1f4a-474d-9917-0397acf14443', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'opiniowałbyś', N'ef55d12b-edb6-4354-a287-e81f86eb7091', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pograbiejesz', N'ef55d12b-edb6-4354-a287-e81f86eb7091', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'upieprzyliby', N'ef55d12b-edb6-4354-a287-e81f86eb7091', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wypożyczyłby', N'ef55d12b-edb6-4354-a287-e81f86eb7091', N'940815b3-1066-4912-94e3-2d51a31d8da2', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'kaszarstwach', N'ef55d12b-edb6-4354-a287-e81f86eb7091', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieponatykań', N'ef55d12b-edb6-4354-a287-e81f86eb7091', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odwróciłyśmy', N'ef55d12b-edb6-4354-a287-e81f86eb7091', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'opiniowałbyś', N'ef55d12b-edb6-4354-a287-e81f86eb7091', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'przygłaszali', N'ef55d12b-edb6-4354-a287-e81f86eb7091', N'94c75617-7ba9-42d9-9efa-c28f1d284cde', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieoziębiana', N'ef55d12b-edb6-4354-a287-e81f86eb7091', N'96aed832-57a1-4204-ad3c-1d662855e890', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'opiniowałbyś', N'ef55d12b-edb6-4354-a287-e81f86eb7091', N'96aed832-57a1-4204-ad3c-1d662855e890', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wylawirowało', N'ef55d12b-edb6-4354-a287-e81f86eb7091', N'96aed832-57a1-4204-ad3c-1d662855e890', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'murenger
', N'ef5b58a7-c26b-4f42-a75f-e36a92c0bb33', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'versatec
', N'ef5b58a7-c26b-4f42-a75f-e36a92c0bb33', N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'arbute
', N'f0a7c6f5-d135-47d7-ac25-2eaea179b80d', N'c842d25a-3950-48d0-baaa-3be138f8ace4', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cholee
', N'f0a7c6f5-d135-47d7-ac25-2eaea179b80d', N'c842d25a-3950-48d0-baaa-3be138f8ace4', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cuecas
', N'f0a7c6f5-d135-47d7-ac25-2eaea179b80d', N'c842d25a-3950-48d0-baaa-3be138f8ace4', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cunyie
', N'f0a7c6f5-d135-47d7-ac25-2eaea179b80d', N'c842d25a-3950-48d0-baaa-3be138f8ace4', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'geests
', N'f0a7c6f5-d135-47d7-ac25-2eaea179b80d', N'c842d25a-3950-48d0-baaa-3be138f8ace4', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'varnas
', N'f0a7c6f5-d135-47d7-ac25-2eaea179b80d', N'c842d25a-3950-48d0-baaa-3be138f8ace4', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cum
', N'f13a3fea-ba34-492a-a277-9c6e4d023ea4', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'iof
', N'f13a3fea-ba34-492a-a277-9c6e4d023ea4', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pwt
', N'f13a3fea-ba34-492a-a277-9c6e4d023ea4', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rax
', N'f13a3fea-ba34-492a-a277-9c6e4d023ea4', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'sfm
', N'f13a3fea-ba34-492a-a277-9c6e4d023ea4', N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dyslokacyjnymi', N'f20eef3e-a7d1-4187-a285-05571fd61d0a', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'helmintologiem', N'f20eef3e-a7d1-4187-a285-05571fd61d0a', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'interpelowałeś', N'f20eef3e-a7d1-4187-a285-05571fd61d0a', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieinhibicyjne', N'f20eef3e-a7d1-4187-a285-05571fd61d0a', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieoziębianiom', N'f20eef3e-a7d1-4187-a285-05571fd61d0a', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niepokrywające', N'f20eef3e-a7d1-4187-a285-05571fd61d0a', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pantopon', N'f2337436-3c31-4125-b735-4cfc38d6a3e9', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'stupajom', N'f2337436-3c31-4125-b735-4cfc38d6a3e9', N'd31e921c-fdec-4de7-a7d0-9ab86700416e', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niespory', N'f2337436-3c31-4125-b735-4cfc38d6a3e9', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odrapani', N'f2337436-3c31-4125-b735-4cfc38d6a3e9', N'da2c67a1-2963-4736-b93c-98c43953b32d', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bucefały', N'f2337436-3c31-4125-b735-4cfc38d6a3e9', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'izogamia', N'f2337436-3c31-4125-b735-4cfc38d6a3e9', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pantopon', N'f2337436-3c31-4125-b735-4cfc38d6a3e9', N'dada2ed4-f692-434e-953e-3184d241f5d2', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dognicia', N'f2337436-3c31-4125-b735-4cfc38d6a3e9', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'jedziemy', N'f2337436-3c31-4125-b735-4cfc38d6a3e9', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'legowano', N'f2337436-3c31-4125-b735-4cfc38d6a3e9', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pantopon', N'f2337436-3c31-4125-b735-4cfc38d6a3e9', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ukrócany', N'f2337436-3c31-4125-b735-4cfc38d6a3e9', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaślepić', N'f2337436-3c31-4125-b735-4cfc38d6a3e9', N'db5a6ce1-9a59-4a45-a13b-afb862369784', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'askoi
', N'f2756d24-1384-4600-8472-e7df479077d4', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'birch
', N'f2756d24-1384-4600-8472-e7df479077d4', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gibli
', N'f2756d24-1384-4600-8472-e7df479077d4', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gledy
', N'f2756d24-1384-4600-8472-e7df479077d4', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'quare
', N'f2756d24-1384-4600-8472-e7df479077d4', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uparm
', N'f2756d24-1384-4600-8472-e7df479077d4', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'yuruk
', N'f2756d24-1384-4600-8472-e7df479077d4', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'mecenasce', N'f4f93a65-6b0f-4c4d-8089-f12b5404b620', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'muflarnia', N'f4f93a65-6b0f-4c4d-8089-f12b5404b620', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ogławiali', N'f4f93a65-6b0f-4c4d-8089-f12b5404b620', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'petitkiem', N'f4f93a65-6b0f-4c4d-8089-f12b5404b620', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'skulanymi', N'f4f93a65-6b0f-4c4d-8089-f12b5404b620', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'gandziach', N'f4f93a65-6b0f-4c4d-8089-f12b5404b620', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ładniutką', N'f4f93a65-6b0f-4c4d-8089-f12b5404b620', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'margaryno', N'f4f93a65-6b0f-4c4d-8089-f12b5404b620', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'patologia', N'f4f93a65-6b0f-4c4d-8089-f12b5404b620', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'petitkiem', N'f4f93a65-6b0f-4c4d-8089-f12b5404b620', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pobierało', N'f4f93a65-6b0f-4c4d-8089-f12b5404b620', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tłamsiłaś', N'f4f93a65-6b0f-4c4d-8089-f12b5404b620', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyświetlę', N'f4f93a65-6b0f-4c4d-8089-f12b5404b620', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dostępowałabyś', N'f54c3200-308d-4a84-b1d5-7f94ece8b523', N'82359986-2785-4708-9b69-7a5d748437b8', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dostępowałabyś', N'f54c3200-308d-4a84-b1d5-7f94ece8b523', N'837b4e63-6c22-4508-936d-cb31fcb0a58e', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieulęgającymi', N'f54c3200-308d-4a84-b1d5-7f94ece8b523', N'837b4e63-6c22-4508-936d-cb31fcb0a58e', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reymontowskimi', N'f54c3200-308d-4a84-b1d5-7f94ece8b523', N'837b4e63-6c22-4508-936d-cb31fcb0a58e', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'niezdołowaną', N'f60eb2e4-ca30-4cd6-80bb-1d4ba66d799c', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pozasiadajmy', N'f60eb2e4-ca30-4cd6-80bb-1d4ba66d799c', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bimbalibyśmy', N'f60eb2e4-ca30-4cd6-80bb-1d4ba66d799c', N'c65c5b99-3c93-412a-9344-432282a18203', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naładowałoby', N'f60eb2e4-ca30-4cd6-80bb-1d4ba66d799c', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pozasiadajmy', N'f60eb2e4-ca30-4cd6-80bb-1d4ba66d799c', N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'naczesałabyś', N'f60eb2e4-ca30-4cd6-80bb-1d4ba66d799c', N'c842d25a-3950-48d0-baaa-3be138f8ace4', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pozasiadajmy', N'f60eb2e4-ca30-4cd6-80bb-1d4ba66d799c', N'c842d25a-3950-48d0-baaa-3be138f8ace4', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonsubstitutional
', N'f6cc795d-a75a-4ce1-9f67-e15f820b5a43', N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'electrochemically
', N'f6cc795d-a75a-4ce1-9f67-e15f820b5a43', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonconspiratorial
', N'f6cc795d-a75a-4ce1-9f67-e15f820b5a43', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonsubstitutional
', N'f6cc795d-a75a-4ce1-9f67-e15f820b5a43', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'protosiphonaceous
', N'f6cc795d-a75a-4ce1-9f67-e15f820b5a43', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'subadministration
', N'f6cc795d-a75a-4ce1-9f67-e15f820b5a43', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'trisacramentarian
', N'f6cc795d-a75a-4ce1-9f67-e15f820b5a43', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unblameworthiness
', N'f6cc795d-a75a-4ce1-9f67-e15f820b5a43', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unconceivableness
', N'f6cc795d-a75a-4ce1-9f67-e15f820b5a43', N'bfd4779e-530f-4f4e-963c-7f967075854a', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'laryngoscopically
', N'f6cc795d-a75a-4ce1-9f67-e15f820b5a43', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonsubstitutional
', N'f6cc795d-a75a-4ce1-9f67-e15f820b5a43', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uncommendableness
', N'f6cc795d-a75a-4ce1-9f67-e15f820b5a43', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unconceivableness
', N'f6cc795d-a75a-4ce1-9f67-e15f820b5a43', N'c1cb3696-2ea2-4838-a591-a33697d944e7', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'krzniańskim', N'f8722bac-7a05-49ca-8ee5-46fd589f07f9', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nieczepiana', N'f8722bac-7a05-49ca-8ee5-46fd589f07f9', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'panegirysty', N'f8722bac-7a05-49ca-8ee5-46fd589f07f9', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'snadniejszy', N'f8722bac-7a05-49ca-8ee5-46fd589f07f9', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unarodowiła', N'f8722bac-7a05-49ca-8ee5-46fd589f07f9', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyprężałbyś', N'f8722bac-7a05-49ca-8ee5-46fd589f07f9', N'11030b68-8788-4abb-ac69-7060985954e7', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'harfowanemu', N'f8722bac-7a05-49ca-8ee5-46fd589f07f9', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'koziorożcom', N'f8722bac-7a05-49ca-8ee5-46fd589f07f9', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'lobbowaliby', N'f8722bac-7a05-49ca-8ee5-46fd589f07f9', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'rozdygocesz', N'f8722bac-7a05-49ca-8ee5-46fd589f07f9', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wsztukowane', N'f8722bac-7a05-49ca-8ee5-46fd589f07f9', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'wyprężałbyś', N'f8722bac-7a05-49ca-8ee5-46fd589f07f9', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zaklaskajże', N'f8722bac-7a05-49ca-8ee5-46fd589f07f9', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zamocowanie', N'f8722bac-7a05-49ca-8ee5-46fd589f07f9', N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'potynkujemy', N'f8722bac-7a05-49ca-8ee5-46fd589f07f9', N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'faultfinding
', N'f8bdeee4-bd07-4594-8e12-291a05831a61', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'hellenophile
', N'f8bdeee4-bd07-4594-8e12-291a05831a61', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'retrenchable
', N'f8bdeee4-bd07-4594-8e12-291a05831a61', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'undreadfully
', N'f8bdeee4-bd07-4594-8e12-291a05831a61', N'e19cc307-4e54-49c5-a43c-7a4489e475c0', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'cryptoglioma
', N'f8bdeee4-bd07-4594-8e12-291a05831a61', N'e2532790-0bef-45d7-bd16-81709f211432', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'fraternation
', N'f8bdeee4-bd07-4594-8e12-291a05831a61', N'e2532790-0bef-45d7-bd16-81709f211432', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'nonaffection
', N'f8bdeee4-bd07-4594-8e12-291a05831a61', N'e2532790-0bef-45d7-bd16-81709f211432', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unbrutalised
', N'f8bdeee4-bd07-4594-8e12-291a05831a61', N'e2532790-0bef-45d7-bd16-81709f211432', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'asperuloside
', N'f8bdeee4-bd07-4594-8e12-291a05831a61', N'e2f0e6b6-70d8-410b-b42d-deb2d32e00ae', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'benzoquinone
', N'f8bdeee4-bd07-4594-8e12-291a05831a61', N'e2f0e6b6-70d8-410b-b42d-deb2d32e00ae', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'phentolamine
', N'f8bdeee4-bd07-4594-8e12-291a05831a61', N'e2f0e6b6-70d8-410b-b42d-deb2d32e00ae', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'transverbate
', N'f8bdeee4-bd07-4594-8e12-291a05831a61', N'e2f0e6b6-70d8-410b-b42d-deb2d32e00ae', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bezrzęsnemu', N'f8dcbbb7-68e4-4e90-90bf-8a256afcc622', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dosiadywane', N'f8dcbbb7-68e4-4e90-90bf-8a256afcc622', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'następowały', N'f8dcbbb7-68e4-4e90-90bf-8a256afcc622', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odwieziecie', N'f8dcbbb7-68e4-4e90-90bf-8a256afcc622', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pelargonino', N'f8dcbbb7-68e4-4e90-90bf-8a256afcc622', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'porżnięciem', N'f8dcbbb7-68e4-4e90-90bf-8a256afcc622', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'zapacaniami', N'f8dcbbb7-68e4-4e90-90bf-8a256afcc622', N'a860b60b-dbb6-452b-9ac2-d6be098176d9', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'deniably
', N'f928b49b-bc95-4d66-9501-d77675761760', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'guanayes
', N'f928b49b-bc95-4d66-9501-d77675761760', N'588d61c8-872a-4474-854b-f615074ca6cd', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'aegrotat
', N'f928b49b-bc95-4d66-9501-d77675761760', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'arculite
', N'f928b49b-bc95-4d66-9501-d77675761760', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'decagons
', N'f928b49b-bc95-4d66-9501-d77675761760', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dieldrin
', N'f928b49b-bc95-4d66-9501-d77675761760', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'guanayes
', N'f928b49b-bc95-4d66-9501-d77675761760', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prebeset
', N'f928b49b-bc95-4d66-9501-d77675761760', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'prebills
', N'f928b49b-bc95-4d66-9501-d77675761760', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'unjudged
', N'f928b49b-bc95-4d66-9501-d77675761760', N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'bruising
', N'f928b49b-bc95-4d66-9501-d77675761760', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'deniably
', N'f928b49b-bc95-4d66-9501-d77675761760', N'626be7e9-0485-4628-807c-25e7043059b2', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'basilect
', N'f928b49b-bc95-4d66-9501-d77675761760', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'challies
', N'f928b49b-bc95-4d66-9501-d77675761760', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'deniably
', N'f928b49b-bc95-4d66-9501-d77675761760', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'descrial
', N'f928b49b-bc95-4d66-9501-d77675761760', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'guanayes
', N'f928b49b-bc95-4d66-9501-d77675761760', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ochotona
', N'f928b49b-bc95-4d66-9501-d77675761760', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pitiable
', N'f928b49b-bc95-4d66-9501-d77675761760', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'regauges
', N'f928b49b-bc95-4d66-9501-d77675761760', N'63303109-e406-43e4-80b6-4f6f9449b4de', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chinchayote
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'chlorhydric
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'doubtlessly
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'merchanteer
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'merostomous
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'relishingly
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'supracostal
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'cd7a9861-2eca-47af-a99a-0e34dbc550af', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'dracontites
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'laparoscope
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'odontotrypy
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'ripsnorting
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tyrannously
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'proamniotic
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reharmonize
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'speronaroes
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'supracostal
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'uninsulated
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'd1004529-5785-4357-aefc-2dc8620eb117', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'germinating
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'pericycloid
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'photochromy
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'premidnight
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'quinquangle
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'reharmonize
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'tyrannously
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
GO
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'xenophanean
', N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'd173f583-5c58-4c01-8abe-814f3e469f8b', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'charmingly
', N'fda36f04-08fb-4f32-962c-5bf7d25f3497', N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'latecomers
', N'fda36f04-08fb-4f32-962c-5bf7d25f3497', N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'limpnesses
', N'fda36f04-08fb-4f32-962c-5bf7d25f3497', N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
INSERT [dbo].[challenge_solutions] ([guess], [challenge_uuid], [user_uuid], [created_at]) VALUES (N'porosities
', N'fda36f04-08fb-4f32-962c-5bf7d25f3497', N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', CAST(N'2022-02-06T13:34:36.6540000' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[challenge_types] ON 

INSERT [dbo].[challenge_types] ([id], [name], [created_at], [updated_at]) VALUES (1, N'daily', CAST(N'2022-02-06T13:34:36.3840000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3846171' AS DateTime2))
INSERT [dbo].[challenge_types] ([id], [name], [created_at], [updated_at]) VALUES (2, N'weekly', CAST(N'2022-02-06T13:34:36.3840000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3846203' AS DateTime2))
INSERT [dbo].[challenge_types] ([id], [name], [created_at], [updated_at]) VALUES (3, N'private', CAST(N'2022-02-06T13:34:36.3840000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3846211' AS DateTime2))
SET IDENTITY_INSERT [dbo].[challenge_types] OFF
GO
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'06093559-116a-466f-9f3d-bf57963cb5ba', N'poślizgom', N'pl', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988786' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'063bb82f-c61b-49d8-bf07-7f226fa8026a', N'przepustkowicze', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989717' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'063d8d0e-64d6-448e-8866-cb01df622849', N'łataczami', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989018' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'0aa648cf-4e31-473e-ac65-b1f71ff5111a', N'jaggeder
', N'en', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988554' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'0c88f5f8-fe81-40a3-8af2-95927a3e6dc1', N'niepastorałkowa', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989710' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'0c8e557d-60ea-4b32-8719-5b8d93e44f84', N'margaryno', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989159' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'0cfd8571-d336-4df2-aeb1-89596ec5cedb', N'cutely
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989194' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'0d0da875-5a47-472f-b852-6c49522f21d9', N'ineligibly
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989605' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'0e640fb9-f988-436c-98bb-1e3e04fc62e6', N'załączonemu', N'pl', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988862' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'0f19991c-059e-4b87-aad7-6afac408efcb', N'stalely
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989243' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'0fe871d4-efbe-482b-b78b-70ecbc93b859', N'reclose
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989514' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'10b60554-3abe-4e43-b1b1-96d35a1049a6', N'regauges
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989250' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'1108d8bd-5348-46fd-b4fb-8b5570a66594', N'apometabolic
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989794' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'11734c10-bda2-483e-9dbb-04c961fe86a9', N'odcieki', N'pl', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988807' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'142e2de5-7fd4-4f0b-8411-fcd5e4e2aaae', N'kaffiyeh
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989521' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'14a47bcd-3b7c-447b-91aa-76be52ce8b1f', N'muscleless
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989215' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'14f749e5-5b93-49b2-84ee-33d9353b3261', N'disregardant
', N'en', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988480' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'1664c558-bee2-46c1-9280-38b7a554dd0b', N'workach', N'pl', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988540' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'16fb556a-ac20-43ee-93d3-dc74e0400199', N'patologia', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989024' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'1723f89b-ce60-447a-9809-559fab2bd983', N'blastide
', N'en', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988743' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'17542693-cac1-455b-889c-e115b27e4320', N'recorporify
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989102' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'1b7b3d7c-de2a-4f8c-acd2-73bf92a86402', N'felineness
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989479' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'1cdaa460-4b96-4bb7-afd1-1beeda32c57d', N'pathetism
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989542' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'1f5213ff-313f-4c19-874e-95c794efa89b', N'sojuszniczek', N'pl', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988905' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'1fdc49f7-9cd2-4e1c-b1d3-ed12f6962445', N'apodyktyczności', N'pl', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988672' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'20f886c6-25c6-4293-aa86-b3d7bbc88c05', N'pozachwycaliby', N'pl', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989508' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'2100f26a-e371-4ed8-b6ae-8ac1d6820c70', N'ammotherapy
', N'en', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988948' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'21150a1f-c049-471c-a79e-7aa73cf73e4d', N'lotong
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988990' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'21d0080a-5316-42f3-84bf-89bcc5eccc6d', N'ln
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989089' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'229c4f6e-976e-46ec-b165-2691dad8ee34', N'precontribution
', N'en', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988397' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'2382d2d3-eb3c-4bc0-9f18-8ace2e60ce85', N'recontracts
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989285' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'24cba4c3-a464-4fc0-9acf-9991a1d5f2f5', N'precorrespondent
', N'en', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988934' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'2706580c-0fa0-4934-bdf1-7868b60f6ab2', N'cupressus
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989039' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'274a07c9-c116-468f-bb9a-5b3700ba9cf7', N'assimilable
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989801' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'27b3113d-1d2e-48a8-bd96-da994b22aaec', N'pintadoes
', N'en', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988386' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'284fa9db-c3ed-4121-91c7-b249037f1efc', N'pelargikon
', N'en', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988955' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'287d14a0-7e58-4ba2-95dc-856df969e45c', N'kabaretujemy', N'pl', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988472' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'29143e5b-7753-4b9c-9d43-7c62bef2f975', N'konflikcie', N'pl', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989179' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'29ea49f2-602e-4fb6-b0c6-4c869ecfd65e', N'nieulowym', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989675' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'2d05b32d-c4af-49cf-8dcb-a8f8739b8529', N'reeked
', N'en', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988836' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'2d5ca328-2b09-4cc3-8dac-098537e1bc1d', N'unguicorn
', N'en', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988494' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'2f803c3d-16c7-456e-83e7-cfb72ed08ec4', N'przybliżone', N'pl', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989437' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'3155e8c9-8bb8-42cc-bf80-94f1aed72ff3', N'ruszczących', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989563' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'3180cfb0-4434-4b3a-8434-3d272021016f', N'sakeber
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989591' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'32b744fe-35e1-44c4-a6cf-4d5558c8329d', N'gajowcem', N'pl', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988883' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'37ede4fe-d321-41e5-8907-d63de5e16bc1', N'nieksięgowanego', N'pl', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989423' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'388e0fde-5657-463a-acd1-5be2cf5b3489', N'galactosemic
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989229' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'38f9d7b3-2734-48f1-aae5-6c8ef3e59884', N'stumpwise
', N'en', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988757' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'39d441db-46a1-46b2-a2e4-ba3ac9822570', N'featherhead
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988969' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'3a6b91a6-0ab3-45b2-b9ee-d6a7cdef325c', N'rąbków', N'pl', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988547' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'3ddc6f45-c9f3-464c-9f5d-6fd26638dcaf', N'beworries
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3990129' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'3ddd38bb-32f0-4725-b6f3-731e47a79049', N'wailing
', N'en', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988869' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'3e65e949-f091-40a1-970c-d05184575d70', N'sunglo
', N'en', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988270' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'3f668179-03a9-4871-b578-406c09ec4798', N'bromobenzenu', N'pl', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988651' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'3fee4164-d1ca-499d-81ff-ea4c0a4633aa', N'sojuszniczek', N'pl', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989550' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'43c52861-4420-4abd-a679-3be7bc025008', N'ampery
', N'en', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988715' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'46340f04-eb26-4fcc-b518-eae6d7b95972', N'nieaspiracyjna', N'pl', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989633' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'478e0a76-88d2-400a-956f-872c11b56001', N'acylal
', N'en', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988800' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'48e0b390-b18c-43a2-869b-973ed8b3ef7e', N'nienaczekaniem', N'pl', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989374' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'48f1e2af-3726-48ad-aa46-d790ee3821d4', N'giserzy', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989430' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'4abe1b50-6fd2-423b-8a65-984f22d18f33', N'precautioning
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989619' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'4bd970b2-2f63-448e-8141-f236a0e0737f', N'theophrastaceae
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989278' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'4e7da533-7a4d-4c13-bee2-182be873188e', N'niespory', N'pl', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989095' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'4ef0b9d1-e7c4-42b5-a520-9cc0de991554', N'yeses
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989346' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'4f8d2a4c-c743-4bbe-99e5-5f928394450d', N'valetudinariness
', N'en', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988487' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'50d3ec0e-41d5-45cc-84c5-4f51049abd0f', N'czartów', N'pl', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988843' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'520a02b1-4694-4d21-bb6e-cd8eb19c4017', N'coiffures
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989501' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'55f70bda-fab3-4eb6-b6af-03cf888fef10', N'spychałabyś', N'pl', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989486' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'568b4adb-9eac-4d3a-88c3-f11369dad4f9', N'nonselection
', N'en', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988722' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'56a4bd47-aa91-4608-8859-b45b6fed8226', N'pojebania', N'pl', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988813' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'5801126f-c87e-429c-ae1a-7e699b483408', N'niezabębniony', N'pl', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988519' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'5bc89b50-f7c8-4914-b826-79862ba0fa44', N'sternocleidomastoideus
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989773' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'5d990ef5-d383-4a92-b749-32d7415e197a', N'pitiable
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989528' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'60a814ce-6f40-448f-a61c-5bf138e9f48e', N'sakeber
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989570' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'63fe98d1-b26b-449d-b8ab-a53a688bc1af', N'strumousness
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989331' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'692d12d0-9486-40e6-80e4-bbf6f20efd0f', N'duplikat', N'pl', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988404' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'69eca4d8-710f-4dd4-9dee-401611bcd04d', N'bruising
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989472' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'6b4d6533-e479-4b67-9a26-4b49938a3c91', N'lethargize
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989361' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'6b5fca17-9d8b-49d7-984c-4e03239a461e', N'zapluskwijcież', N'pl', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989745' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'6bd6d864-fd23-49dd-9e83-2cd148642b11', N'wyprężałbyś', N'pl', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988665' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'6c36ecb0-a905-476c-877b-85939758d473', N'skarżąc', N'pl', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989299' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'6cd8848a-07fc-476f-83e3-8e7b19648345', N'ciskacze', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989655' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'6ce0e0a3-7181-46cf-a042-6f5a2d482fd1', N'carpuspi
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989074' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'6d668e29-28f8-4402-b7f9-5c69303a2b54', N'ujadaniach', N'pl', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989396' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'6e815a5e-bfa4-4320-985f-40e238bda8ba', N'surfman
', N'en', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988584' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'6ee7e64e-cde3-4ff0-a9e0-8f376db0a809', N'cambers
', N'en', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988562' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'6f4bc015-3809-43e6-845f-2dc6f10b85aa', N'znieruchomiałaś', N'pl', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989409' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'707b7592-3eab-49fb-ad59-dcc689d7b92f', N'chloroplastic
', N'en', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988658' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'71c8222a-4b82-4e81-b58c-1df1a9e1131a', N'rocznicowości', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989759' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'729c1e00-a464-4525-b2f2-ac2f45238f63', N'bioscopes
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989152' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'72d75714-c06d-418b-b249-0512b5ccaaf3', N'anxiously
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988983' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'74afd494-67b5-41ee-bcda-f12f2a11575c', N'disleafing
', N'en', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988764' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'76061b61-19a0-403a-9047-02a6b02b1690', N'adherant
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989668' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'77418136-b2b5-4ab3-866a-4c3ca5dcfd09', N'scałowywaniem', N'pl', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988687' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'78a19c00-782c-4118-9c4b-b2fa9aa04a65', N'wchodziłoby', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989766' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'7aac3418-c2c4-4c22-bc9c-14910bca8e8b', N'przetrawiałeś', N'pl', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988750' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'7bbceec7-ea18-4b62-ad75-2b17dad4b4a1', N'esencji', N'pl', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989535' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'7d130e15-3309-4219-8acf-71f110c188f8', N'capiałaby', N'pl', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989752' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'7fc4f942-57da-4a34-b796-c2e385b326a9', N'tyramine
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989123' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'814aaf32-d0c8-4268-ae18-7c5569fa0381', N'pronaoi
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989208' AS DateTime2))
GO
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'8270c149-34b3-427d-8491-1efe73b86490', N'przetrawiałeś', N'pl', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988456' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'85cd4b44-f7ee-4b73-82cc-422cdb3e88e3', N'nieanoreksyjna', N'pl', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988821' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'86c42784-16ff-415f-8204-ff50fec91c4c', N'miscreancy
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989257' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'870d908a-e66f-427c-a07d-1079df085fd9', N'monstrances
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989110' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'8a80db17-fd12-4d12-a2c2-991ded3683c6', N'mierzwiącą', N'pl', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988576' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'8b4bd7da-f65b-4da6-8773-b25a8e83bc79', N'niezałatwianą', N'pl', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989011' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'8b7a0109-5875-478d-b9a9-307f0bf2984c', N'confectioners
', N'en', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988448' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'8cf8f4b9-2fa8-4117-8283-98b860462326', N'onstage
', N'en', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988526' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'8f538ce6-eaf1-4f45-9dbc-eac2959ef0e1', N'ułagodziłyśmy', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989271' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'9092b367-a415-4e4d-8782-8fea8741ea36', N'serwohamulcowi', N'pl', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989046' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'90f2504f-79ee-446e-9b04-5ab8f371d33f', N'kancerujmy', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989201' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'920562af-3734-4b73-89c2-ae800fd006b1', N'uspokajajcież', N'pl', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988736' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'9288c00f-9ed2-4708-8da0-f4c84a698aae', N'chazzans
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989067' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'950c4796-9c54-4042-a468-bfca8b6fc2a3', N'liftuje', N'pl', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989317' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'958cf3b1-3ed1-45e7-b689-5188423ca274', N'outpushed
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989324' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'97a139ac-a7b3-428f-85ae-a995d1a94419', N'rissel
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989465' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'99a34d25-f370-498b-95f5-3c66600539b3', N'nieporowata', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989445' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'9b59cc47-7d34-4935-b45f-816b2cd1b1d3', N'devels
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989738' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'9c4ae5a5-9164-4efe-9f7f-b5f283d87a32', N'pchając', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989004' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'a1fe6cac-10c7-4e7d-9311-0403942372c0', N'liefer
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989690' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'a200f9cc-2918-46f1-8bb1-1b4c3f4f5684', N'pamhy
', N'en', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988793' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'a39921f7-df95-4238-abfa-f4ec2758e304', N'zaczadziałbyś', N'pl', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989388' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'a58e69d5-4191-4905-9cd8-b7c9be52ef58', N'zdramatyzowałem', N'pl', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989053' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'a60292d5-d19c-448c-b93c-5bf1a89b0bf8', N'dosychajmy', N'pl', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988324' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'a73247b9-4020-4cd1-9944-e934ab6eb437', N'kwakier', N'pl', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988598' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'a7636bac-bcfa-4511-acd3-961d97a737d4', N'zabłagałabyś', N'pl', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989165' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'a83ec9ff-e82f-4b09-8701-f468d40ebf5f', N'audition
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989236' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'a85375a5-87e8-4aa3-936f-d6ece46f5491', N'healthsomeness
', N'en', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988533' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'aa1aa489-849d-4570-89c3-5ab9549a7ff7', N'bruising
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989353' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'abc20f7c-f934-4cc5-b947-f0469a54fb0a', N'brutification
', N'en', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988605' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'ad845c2c-47e1-4bc4-b0de-4ece293d657b', N'parakeratosis
', N'en', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988304' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'ae47c74e-5834-49d6-89df-534ede6093b6', N'malpresentation
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989584' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'b0c4e5f4-6099-4a6e-a074-5779ded6ccd7', N'blastide
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989641' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'b1d8c3f1-177e-4115-af8a-f92954c17970', N'garwoliński', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989661' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'b1fe816e-d997-48e8-adb7-f2b59f7409ec', N'nonefficacious
', N'en', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988680' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'b3a1d09c-2ff4-460d-b3cf-f10a11dd8645', N'odmiano', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988962' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'b404fbaa-365e-43d6-a96c-f127c83d5ee3', N'anisocytosis
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989780' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'b495de52-6a04-4526-b5e6-e25e23e7ac55', N'kubong
', N'en', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988623' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'b4a49c43-0886-42be-ba4e-df4fc01eb7d0', N'undarned
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989458' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'b690524b-2082-416a-a319-ea7cc54d9c18', N'poflotacyjni', N'pl', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989173' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'b90e0c3b-f856-49ac-a24d-8b9996ba3179', N'coeliac
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989292' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'bc293cb9-ef1e-43f6-a97d-f7ffc63e3f32', N'prevue
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989494' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'bd44faa1-be25-43bc-9bc0-95c1b5f13d49', N'tłoczonych', N'pl', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988505' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'c037e760-a4ee-416e-84cf-377ba7460d6d', N'pyretogenetic
', N'en', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988332' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'c14e83b4-ea76-40ac-b861-b206e01f706b', N'decagons
', N'en', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988898' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'c1e350ca-7d65-4d1e-bfa3-758ca933d9f9', N'munt
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989060' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'c24152a9-f8dd-44ec-9355-df4a5192902b', N'demagnetyzować', N'pl', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988612' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'c44928ae-a1c7-4b92-86b6-f9efd26f9f11', N'nonsentience
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989416' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'c4a4f5a0-0d59-445f-bb8c-a11d20fc32ee', N'dozorującymi', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989703' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'c6be93cb-588c-4dd5-ac98-072aeda5dd89', N'obiektywizowane', N'pl', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989731' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'ccdc9c9c-555c-467c-a671-b4a914ea514f', N'write
', N'en', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988778' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'ccf366d2-679f-4e86-9d82-45074cd38300', N'chapourn
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989577' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'cd8b394a-655e-403b-9ac0-99f44563c439', N'yeses
', N'en', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988701' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'ce744950-8172-4392-8663-675d2ab0867b', N'unlocker
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989187' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'cedaa45a-ae23-4b6c-ae9d-e5f7811fe90a', N'nieuprawnienie', N'pl', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988708' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'cf2ff1a5-647c-4759-b656-d71f8ef47b91', N'przesuwnikowych', N'pl', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988920' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'd03b2469-f02b-4b4e-99e6-569b49a1252b', N'freshish
', N'en', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988637' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'd0a06bde-9502-47e9-927d-5ae0ac9e3aa5', N'supracostal
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989381' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'd274435a-b02d-4ef7-814d-10ec9660d561', N'boczeniami', N'pl', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988512' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'd3b101cd-48ef-4b7f-8b34-83347b76e32f', N'imprejudicate
', N'en', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988913' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'd42b1a49-bf1a-499f-94d9-670e0c3f7b99', N'excretal
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989556' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'd599d1d2-3c04-42cf-9771-82e0b2d6ec29', N'faints
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989222' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'd7b0c7e9-c250-4efd-8ff9-00c6bd43e0c2', N'zapacaniami', N'pl', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988316' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'd833e9a0-6983-4474-9f52-d7b9515d5e86', N'planetable
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989264' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'da2b21b2-4639-4862-b3c3-ca45837c559c', N'nonefficacious
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989724' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'dae254a3-39e9-4080-8f2c-635eaf17ae71', N'wygwizdów', N'pl', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988891' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'db60a923-a419-4891-bfa9-6996811a87fd', N'engrafter
', N'en', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988941' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'def3e01c-8d48-40d6-86a9-baad5125ffa7', N'greasing
', N'en', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988855' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'df4e5ab0-1be8-44e0-8099-6c5ba15540bd', N'beatificate
', N'en', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988569' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'e09de163-e0cd-46e0-a206-b1c4ca45668c', N'emergents
', N'en', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988694' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'e305757c-3ff1-490d-98d4-a4fe5ca76237', N'bromobenzenu', N'pl', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988927' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'e654a1ee-ce8b-4fd7-bfbd-11699177b91e', N'waggonwayman
', N'en', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988771' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'e7e83a2c-e3d4-4c60-8363-f902fc714422', N'peevishness
', N'en', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988440' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'e8412762-7863-4580-b68a-2b0864e9b858', N'guanayes
', N'en', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988591' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'e89fe0eb-59a4-4d5b-a877-2fd55902018e', N'chapnęłoby', N'pl', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988729' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'ea9332b5-ea71-4c87-bb4e-cbf105ba4c39', N'geesowsku', N'pl', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988463' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'ebe2f6da-a76c-48cd-b361-6d652df9a0ae', N'forytowały', N'pl', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989367' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'ed1f8b57-eff5-4c99-ae7d-963894721ac6', N'undepreciatory
', N'en', 1, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988876' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'ed4d65ae-af63-43a5-8252-d0db08c6ac1d', N'underbutler
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989612' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'eda76eb5-2c11-4507-ae01-62625e1fc633', N'celebe
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989138' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'ef55d12b-edb6-4354-a287-e81f86eb7091', N'opiniowałbyś', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989081' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'ef5b58a7-c26b-4f42-a75f-e36a92c0bb33', N'versatec
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989648' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f0a7c6f5-d135-47d7-ac25-2eaea179b80d', N'geests
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989338' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f13a3fea-ba34-492a-a277-9c6e4d023ea4', N'pwt
', N'en', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989145' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f20eef3e-a7d1-4187-a285-05571fd61d0a', N'niepokrywające', N'pl', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989626' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f2337436-3c31-4125-b735-4cfc38d6a3e9', N'pantopon', N'pl', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989031' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f2756d24-1384-4600-8472-e7df479077d4', N'askoi
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989682' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f3bf7a8a-ecf4-439d-b062-f521bdcbcda4', N'zhasalibyśmy', N'pl', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989403' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f499e99c-c7be-4d5f-89fa-a75b615023f6', N'decorticating
', N'en', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988828' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f4f93a65-6b0f-4c4d-8089-f12b5404b620', N'petitkiem', N'pl', 2, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988630' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f54c3200-308d-4a84-b1d5-7f94ece8b523', N'dostępowałabyś', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989599' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f60eb2e4-ca30-4cd6-80bb-1d4ba66d799c', N'pozasiadajmy', N'pl', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988997' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f6cc795d-a75a-4ce1-9f67-e15f820b5a43', N'uncommendableness
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989130' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f8722bac-7a05-49ca-8ee5-46fd589f07f9', N'wyprężałbyś', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989696' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f8bdeee4-bd07-4594-8e12-291a05831a61', N'undreadfully
', N'en', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988379' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f8dcbbb7-68e4-4e90-90bf-8a256afcc622', N'dosiadywane', N'pl', 3, CAST(N'2022-02-06T13:34:36.3970000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988644' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'f928b49b-bc95-4d66-9501-d77675761760', N'deniably
', N'en', 1, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3988976' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'fa8085a1-7979-4a6b-b4d9-e5622e06dc31', N'giserzy', N'pl', 2, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989787' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'fb1df595-1c83-4bfb-9e32-02ddcf53ae87', N'supracostal
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989451' AS DateTime2))
INSERT [dbo].[challenges] ([uuid], [word_content], [word_language_code], [challengeTypeId], [created_at], [updated_at]) VALUES (N'fda36f04-08fb-4f32-962c-5bf7d25f3497', N'tariffless
', N'en', 3, CAST(N'2022-02-06T13:34:36.3980000' AS DateTime2), CAST(N'2022-02-06T13:34:36.3989116' AS DateTime2))
GO
INSERT [dbo].[languages] ([name], [code], [created_at], [updated_at]) VALUES (N'English', N'en', CAST(N'2022-02-06T13:34:29.5010000' AS DateTime2), CAST(N'2022-02-06T13:34:29.5012706' AS DateTime2))
INSERT [dbo].[languages] ([name], [code], [created_at], [updated_at]) VALUES (N'Polski', N'pl', CAST(N'2022-02-06T13:34:29.5010000' AS DateTime2), CAST(N'2022-02-06T13:34:29.5012742' AS DateTime2))
GO
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'01b32977-0bc9-4f73-b372-aaeff01b9218', N'$2b$04$vYJ54D8JzAQuiFulbeF5U.0j9F8TKZynKpLGGjcLLTwlt7nkvjMmm', N'Devin_Gleichner', N'Suzanne28@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739113' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'037a6380-46ef-4327-b1bb-5aef7a64dbc5', N'$2b$04$VWr0lZS8XfIN3uEyTQzCfeo7HXivtWREutYEf/z4FDfZM08hYJjsO', N'Koby_Vandervort0', N'Camren_Heathcote@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739154' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'062bfaca-f1ba-4664-a5f3-7988132458b9', N'$2b$04$iOMaIG4jXDuC4lxrnZVD8.ieC6Ps5b2HMrsF6.ztfBRoPRGjq7wLW', N'Carey85', N'Yadira1@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738497' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'0814f578-8e38-4615-a110-f342a97e9ba2', N'$2b$04$K5iy8TseLSGFRZxDTI/k/evVPgdXEqXYncBfs0E/V3/igRlLeUXe.', N'Nona.Davis93', N'Brandon94@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738489' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'0846669c-07f1-41f4-9381-e038ec3351d6', N'$2b$04$Nyfd0uHcBWXso4ViJb2krOdi./cwmEujqDUGKpWk/sbB74/bD2NCq', N'Micaela19', N'Ray41@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739311' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'0aa51811-6ba5-47f1-b2b8-4ae519845a0b', N'$2b$04$5AFqlNH4BNIoDf8W5JCJlepAwbbhLKfzsfM9l25TCwfzbJ6gan5qG', N'Domenico87', N'Sam51@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739064' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'11030b68-8788-4abb-ac69-7060985954e7', N'$2b$04$2aMDVqBi6wlJuzvgaTOh4uldAQJhP186x6XUHMCGXrNkMBS/EMMp6', N'Veda.Bednar', N'Reilly68@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739304' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'1375e5d3-7388-47d8-8a2d-e5c5cb83c9db', N'$2b$04$mdeGfo3Qjh8j1yKL0Z/CPu3fyDWKwZUsRlYMpQRHiqKLCuhnvvAqW', N'Beatrice_Erdman', N'Laurianne73@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738817' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'1aeb7ba1-11a5-4ed5-a299-cf17b030ce97', N'$2b$04$gL1oRIlQRe2ea/.NltvyYePRMUu7liVU.TQ7Vpj5Sj6lBohr/FMza', N'Kris_Considine66', N'Laverna_Hickle99@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738795' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'1c91c827-ceea-4288-aed4-b3a75c1ac3c6', N'$2b$04$02AmZWTEzpZscU8xxDbQseB6oHSCmUsG3hYBk2wGqZic2Tm87Hv.C', N'Gabe.Cummings', N'Alanis36@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739381' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'21b134fc-b41d-4feb-a647-0b6b7cf87967', N'$2b$04$aX/96OeQlduYrUDevt65yuNesdgcxqTnEeZROcQGQ3sRke4.pB76G', N'Daphne5', N'Genoveva.Kling32@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738877' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'22d39998-47eb-43e4-8174-dff7d3c344fb', N'$2b$04$0SHd7aXFTFinddvoK7.OfusCtt8.U6Hi9lPdhrGGbAv2XOWFXP0V6', N'Verner.Braun', N'Micaela.Halvorson@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739262' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'24cc5ed4-1554-4928-b506-86af57e5317a', N'$2b$04$CrfEBnEZEu5lOT3d/l99Eea0KvjSr1KhXSdwJQc3PlmL8qS5CebuK', N'Maurice32', N'Ena42@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739057' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'25dde876-8acb-41ee-919f-0cfc5fde07c7', N'$2b$04$.B2uDEt8.2lQQqtoiYrzD.Ute5P8rsVcu.7AYTTMDcEQWNlEFCEL2', N'Lillie.Gislason70', N'Destinee_Prohaska48@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739388' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'2b1b01f3-59ab-472c-a49c-c053b25eb4eb', N'$2b$04$44RRY0axsABd9vN.sEXNSeonfbvzSSS23RjM2AHd9Cv9rJEC68/Y6', N'Annamarie97', N'Kaya_Parker@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738970' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'30adcf04-da22-4e3f-ad87-50df41211a6f', N'$2b$04$Ex5m32e7O7DVZ5DFb.fGkOZQsvRFP3O2/aLORWEpE8mILDy6pif5q', N'Kevon.Kub', N'Amelia.Thompson72@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739001' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'31f730a1-1735-445c-8365-6bdc59d77a28', N'$2b$04$Li9C5DU5Tn8SVlijzBBk/ub0bKCtjqvbReC2ihAppuP953/tNZhDu', N'Martine10', N'Alanis.Stamm89@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739008' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'322056ff-d55d-42c9-93d3-3fe560e3559c', N'$2b$04$LuS4kn/cDY3fP.piREi6qe2J5nFQ.28TThDFzR/2OIxxn6AbtIWtS', N'Liana.Strosin20', N'Cielo.Abbott5@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738743' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'32ee171b-9194-40ff-9c4f-dc75b1266a99', N'$2b$04$2purrNHdxV87j3qW8u.WBu63hMPlGfYMzKv57pAurjXIIsM5NGcbK', N'Glennie.Gorczany79', N'Cecelia.Olson33@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738859' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'34849063-3080-40ca-b64a-205dbf62e4f2', N'$2b$04$hF2PleadRsshKCkdwzeHVOVesA9bJrWZZVr0sJgcDUIjkuU4XW2nq', N'Lysanne_Stanton', N'Obie.Berge@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739015' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'407691e8-1a33-4c43-ab9c-0193bc408464', N'$2b$04$EEbLfsfV9wEe3WbLXTQLs.8pgEi0YKDwwvYX8ZsmW2C6LEjRK8zna', N'Ashton65', N'Ned_Wuckert@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739430' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'407c141a-e8dd-4029-8feb-faa202fa7a5b', N'$2b$04$fGPMOAPmGJ2JZw473Cn1s.ga2Gehw6.ESngZyddxWWFYkYpUQZ6AW', N'Libbie_Lang78', N'Braulio48@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738423' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'4217cb86-c05c-436e-a9f6-0b5e5f70db81', N'$2b$04$EJ5wQreCFg2na6DFSaLcYOEZfcBF3e4EoJhL2FRlGGAHyArRIUpHO', N'Sienna_Howe', N'Daryl.Hoeger21@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739297' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'4327c0c1-2b70-48f3-8d58-f3380e671a8f', N'$2b$04$mrTq7xkycNvXEIxbHmzUg.zdZVRJdmhvEBO4dA85.lhKuL0mazUSu', N'Raven_Reichert', N'Kellie26@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739202' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'46f32deb-fd2a-4544-88f4-27e9aaafe0a3', N'$2b$04$2epTHBsFtJnWBquGwyXmiOq8hBhEIkmKesgvgWU6/UXIkJYV.YLeG', N'Emery91', N'Alexander_Rippin73@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739099' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'49bb4258-18d3-4519-bbc6-f0016cea52de', N'$2b$04$FNzCibFF/To6Wl1IfsAWLOvDW/9xi3RZ.pppNLH0sa5.xfc6nEwCK', N'Hunter_Hayes29', N'Duncan.Abbott@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738465' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'4cfd8062-1f4a-474d-9917-0397acf14443', N'$2b$04$kn1EADUfyzVdqdRonTTAmef2WgjyqE44RBLZ32LYB/iR8PnE/wOte', N'Marisa.Orn', N'Gordon80@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738752' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'4f8f1387-d628-4ab3-abf9-e04016e45fa9', N'$2b$04$qcrmZD6U398XBSC2hThtvuNOZeN8boAt62/PjrKswFiP5BR03Pbw6', N'Elyssa53', N'Minnie_Keebler@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738777' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'52a35941-62c8-42c1-88e1-37b98a0d272f', N'$2b$04$UXrGHv5Oibr2Xxbodjkf/.voE6WXsgaujEHA6Nvyoj3BWOHxgV3u6', N'Nickolas_Koss33', N'Emmanuel43@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738934' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'5601a294-6cd8-4969-9e4a-4ff2901ae924', N'$2b$04$t6C11F6QcEPhEVRsp2wLg.xiExjEIlUZurGWcy2BeNWHvkWzxe.vi', N'Gudrun_Schaden30', N'Nettie.Jerde48@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739367' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'572b7747-e3eb-4ccf-8211-f013d3618acd', N'$2b$04$bbBTq.cotea4XTyPIGJBA.8kcJ5AvV5juZiu9dgbhJZNY2iPDtMKC', N'Lori_Kuhn', N'Jack.Haag55@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738986' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'588d61c8-872a-4474-854b-f615074ca6cd', N'$2b$04$UHMdYW2nVrE1f24eBT1lKe2dY3FFgZyMWU2rbh3rvZSZwbdGZBlra', N'Miracle_Weimann50', N'Priscilla_Treutel53@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738505' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'5dfe35cf-7e1f-44ac-9c04-284b9a964784', N'$2b$04$BVHvuaK0TrnKlR3WSfzBUOgO2VjLsHMuuZXu2YdQBfpoIhMafpTi.', N'Tomas_Emmerich94', N'Thomas.Kreiger@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738962' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'626be7e9-0485-4628-807c-25e7043059b2', N'$2b$04$9kGqLsdkBTx4rXtoDCkVE.cnrT3J1DgAmB.Xr9NsdCCcirJ397qR2', N'Katrine.Bahringer63', N'Triston.Krajcik8@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739036' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'63303109-e406-43e4-80b6-4f6f9449b4de', N'$2b$04$V6zPeMt6OzzyWru3MVNnoeI.r7FrUDiVIMwwS46kJ1h/C49bWIJde', N'Olga_Kshlerin87', N'Vada.Russel82@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738868' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'639f539a-d0d5-4ae8-8501-922f204025aa', N'$2b$04$m1vluv1oPBiFUJDb5nCHn.K.xbaFA50C8SGjMlREUrLVMG7TQaNrK', N'Easter_Dibbert83', N'Flo_Conroy@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739210' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'65b8b0ca-3ff5-41db-83c2-f259b1c734a8', N'$2b$04$q4Sh0bigb43JI.s1bRsMmekhoJf/4caRb.dBUE5ZOI7tnyxCmfUa.', N'Mozelle63', N'Ernestine_Collier39@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738919' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'65d5ff57-2e47-4394-8819-11740013b756', N'$2b$04$6k4a.0z2jmjB1iouVVoR5uXRUYMSDzuJw7suChQpKckVjE9P04L0a', N'Coy53', N'Aliyah34@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738838' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'67789511-6503-4c37-9de6-ec5e65be7dde', N'$2b$04$plMrUMY4XHt7s8qqLDLWMOSNmBoCbp1SCMs6Pc5WEHKaj0h7A.mCC', N'Buck24', N'Edwina.Rau@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739141' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'6ed77239-deae-4d1b-b1ba-0c2eddae133d', N'$2b$04$tBYeBEnMJTgNAymW6J5eBeeouvqoE.FTxSBk5pqhaAzwqoKK3g4Tq', N'Isaias.Cormier73', N'Drake1@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739084' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'6fc830b2-17d2-430c-9188-8310faa228e8', N'$2b$04$dhypW5szhg7hiyPqY5MHce3iooP0PbKs3G.sU50jX/ZgAwycui9mG', N'Larissa_Turcotte60', N'Ellen38@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738828' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'74d3f2e2-a0c4-418f-933f-890e26a64328', N'$2b$04$0q./7yvjessJJDD7UlHS5u4vAJW.JUsWJASUjmPqJTu1NhN0muwla', N'Jana.Kuphal', N'Selina_Crist@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739071' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'77a7f8c8-af2c-48e5-80ef-6c2f41dc93cc', N'$2b$04$1wfsog5w2YsnXKWXpcrUL.ceVB57d3nfyKydMKCNxqN8xf/A8QPPW', N'Ford_Littel', N'Aurelie50@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739353' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'77bd59f8-8a72-4d0c-bb66-0cbd43b059d5', N'$2b$04$tSCf3IbRRDL90Tl2akeBPOgnl89lJC7CY8HTPW7em2Vurr8SOFw.O', N'Miracle.Zemlak', N'Arlo.Rath5@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739134' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'7956ec3d-07d9-404e-b517-29c315e45119', N'$2b$04$QgWfgPVbtxWh3KFrSPP5ZOHD03VBhoBXwAkezKQeB6njzUE4kD3Ye', N'Jamaal_Reilly', N'Evie_Batz@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738786' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'7ce80c36-4836-47ad-bfa4-8b380ea961c8', N'$2b$04$97kIkwxIOY8Oql.c1GJhBePr1eJr/Jdp4S0Tf861ItMXfN6taR/z6', N'Donna.Blick37', N'Howell_Stracke@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738482' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'82359986-2785-4708-9b69-7a5d748437b8', N'$2b$04$/TiFlOMM39RhEtvOpJpw.Oq2TxVvS2Dl9eVxAUFmsH3tWd0lysM5i', N'Jamie_Spinka45', N'Justen67@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738850' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'837b4e63-6c22-4508-936d-cb31fcb0a58e', N'$2b$04$JX7bSlNqsfaGNao3kjfsH.IcblF9EvNhfbEGoZVyHddpZcqSysFMu', N'Alejandrin.Blanda', N'Sandrine_Hills@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739225' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'8c370d2c-c3f9-4a15-a407-e8410ab4b62f', N'$2b$04$t8k8cx8aBc0AxtN6oMpSBOWOXhKZyh0HOeAj.BBdGYc49EtNfqaRm', N'Owen.Medhurst', N'Makenzie_Parisian43@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739416' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'92fdd0eb-26cd-4e67-8a4e-5371345d3670', N'$2b$04$UYtSK5hdJIYsUXHQ6b8vyeXmvoxL0yvsVhPq44ZNlwI1bG8Fz33PG', N'Louvenia.Nicolas54', N'Antonietta.Schinner27@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738895' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'940815b3-1066-4912-94e3-2d51a31d8da2', N'$2b$04$bcSIs1vjFqvrcLtk68q1gu0ei063VKLiZQC7Qcj7uKdlqEC4RSVQe', N'Nasir_Herman44', N'Shakira.Botsford@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739360' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'94c75617-7ba9-42d9-9efa-c28f1d284cde', N'$2b$04$J/kJ76hnutuoBdGmBNkSPerQ9m84p6uDlwq2l32x3aYmXGx5nGXv.', N'Blaze_Olson', N'Ricky69@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738944' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'96aed832-57a1-4204-ad3c-1d662855e890', N'$2b$04$u71ZSMoT394HtGJEwFH4P.VUtKjWiwunfjYcg0/fBSCoRS3W4jNqG', N'Carey.MacGyver15', N'Tamia9@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739077' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'99fea5e3-e32e-43ef-b83f-8ed4da00f15e', N'$2b$04$loa125D3z.Y/ES/RNb2UGOtc58MSD8vjLEI1DgPtXeEh2j.D5rzKS', N'Julia.Kshlerin', N'Opal_Steuber19@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739248' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'9b1155aa-8ba2-4787-a116-61033d2f35b7', N'$2b$04$EyiLtrCyS9GgMNDffW6RmukrKVy.7uVm9RyE7fXRcRYC2xkeW2nSq', N'Stanford65', N'Keaton_Thiel@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739346' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'9cf01d77-d8f0-4e4a-979e-7ed4935bcb50', N'$2b$04$J1tZQ92i3xi89KfPfNZSB.Zh65tJBmkYS7dOX25jGSGhH7qlLfMuq', N'Krista.Larkin43', N'Maximillia66@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739290' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'9f85aedf-6139-484b-9fc6-f9ea39e50079', N'$2b$04$/0cRIAiWbFHLuMb9SajiauqJ42GLrJ47lBTHLbMxefErogv9Rxqby', N'Madonna_Cronin', N'Natasha.Quitzon@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739374' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'a0a31ca1-3db7-433d-962a-cae885a1c872', N'$2b$04$Qd9mnIjSVXaZYNujH1ysZOOMePWVVTi7cj9.KvFx0WHN/oiRkuOty', N'Dagmar_Senger', N'Louvenia_Brakus34@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738993' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'a37d819d-bb8f-41a7-9bfb-330deef38df3', N'$2b$04$Nx5g.tXAT2K6rV.M6TGktuUsAZ/guZnTG7Go/CcqGXDglfEct.KTK', N'Alysha_Carroll', N'Clementina_Okuneva@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739395' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'a3c6ae94-fe8b-40bb-b945-a9b28fe5ee3b', N'$2b$04$uFG2pr5J2FKof6kbVvA.ZOimwTLuw29BYUfPtZ1DBBVnDBuZJtFhO', N'Karl_Blanda16', N'Julius.Wuckert40@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739194' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'a44b03a7-25d6-4920-a662-013c790297ef', N'$2b$04$bu/Qy6RYIvUlDDpzwToATemeF8ndHHtMQzZbom9xcYsAFucilWRCC', N'Raleigh.Kulas78', N'Frederick.Brown@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739269' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'a469291c-45ea-4395-b544-c3f5e2ac9887', N'$2b$04$tPtxj1.TBA60arnaqzw.bujp7o5fu3uxBt.faPkNoh2zo4fNBCocC', N'Ofelia_Sawayn', N'Lila_Harvey@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739148' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'a860b60b-dbb6-452b-9ac2-d6be098176d9', N'$2b$04$P2hy9n6S8hFR3OMOYYao8Orc0Ip7FXMXrY5T/6GnnLtnS8xbMuM02', N'Zechariah_Stoltenberg', N'Nat10@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739409' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'a9c3213d-fa7f-404e-afc9-352d36fa2b03', N'$2b$04$WlTph2SoF19KOqwYCUVX2OIFFsbKgjiLs1Y83q1J0uDtYgSgFd5HC', N'Maribel_Hayes', N'Armani4@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739283' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'afb97918-833e-4047-bc1e-15013125f24a', N'$2b$04$qV9xhUbJY6JRdHFy06kRhux7pwGtVJgrQ6UIwhpyGDabDCp55aKiq', N'Aditya99', N'Fredrick.Emard@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739233' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'b2a341cf-1161-40b8-9aac-9531719e66f0', N'$2b$04$oSh1ldAACBqoduuj2BwzRejqxOztpfWZ/HuGspI4H10MJ2j0cucPy', N'Dorothea.Hilpert', N'Estel_Hilll@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738926' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'b5b62c52-6dc1-4cb2-b5e8-769b03a302f0', N'$2b$04$gsz3yyxbOMgg.zfLP30RieO9hfs6gq6O.hQxbRS8D1teD6c.XlmsK', N'Florence15', N'Zechariah.Daugherty@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739092' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'bb9362f3-c1cc-41c9-b529-67a31cb42e36', N'$2b$04$3u6s3RShzA6QhDs9Xb6PNuGBEU.IpCRPtkhe4.JsIigbDa9QLQSMG', N'Jared.Mueller', N'Madalyn.Dicki@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739241' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'bd7bceb6-551f-4500-a81d-fc2b024a4b10', N'$2b$04$pGdMMOdKShfGux7WHOHRc.RInOg80ibzMYjVgHsE3VJXRVC3AjNU6', N'Clint.Grimes14', N'Mariana.Bergstrom70@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738886' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'bfd4779e-530f-4f4e-963c-7f967075854a', N'$2b$04$J2k/cU26k7RyciivA7eUBuM8M0RaxY7KtuwOLUwrkGl0xTuRqeLeK', N'Lynn_Purdy', N'Russell.Kuphal78@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738911' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'c1cb3696-2ea2-4838-a591-a33697d944e7', N'$2b$04$w3LE6XK6fhkFbUC/MPEiJuqoP9Ou3Aj5Z8n3wXUJDFTNcHT3zZes.', N'Ida79', N'Rosalinda_Harvey@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739402' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'c65c5b99-3c93-412a-9344-432282a18203', N'$2b$04$wcERnUeihDAetrh0.uY/k.elgc66vAr156shUaKpS/pAbTjC4PzoW', N'Jaclyn_Mann80', N'Mitchell.Lesch@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738768' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'c6e698a0-f3ef-4a92-a699-fcc7ac99cfac', N'$2b$04$nbjyH5E23vkZyLlppCyUhupKZoooggDb9YfuSz6fDj8BgYAe1ZcaS', N'Pearline84', N'Alexis_Boyle@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739029' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'c842d25a-3950-48d0-baaa-3be138f8ace4', N'$2b$04$XMq6OeJSSGQhr./.euzRBe5QuUTjRuFGX23TAWr2XJ8r.wHETCO0O', N'Mariam.Leannon', N'Nicola.Stroman@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739043' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'cd7a9861-2eca-47af-a99a-0e34dbc550af', N'$2b$04$PQS3weepL2AUAwep0DNwCe5LBXqb4nvCNTWgFh6fv.4szz/OLfeVm', N'Chloe_MacGyver', N'Susanna.Kulas18@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739175' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'cff612ea-6522-4614-8b8f-d313fbc3c5cd', N'$2b$04$44qd2RYKDLTrIZ0kUyjBaekjSauNvHPGWC.tNCS5P7o39kMUAFIiO', N'Robyn65', N'Eryn.Weimann78@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738734' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'd1004529-5785-4357-aefc-2dc8620eb117', N'$2b$04$060iRshM8HbNuTJ.u8OIFOk6TcRKj8F8yS9r3sqEP3i2L3vBWJsci', N'Stacey.Boyer', N'Cayla_Kling@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738903' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'd173f583-5c58-4c01-8abe-814f3e469f8b', N'$2b$04$CEPoVXrxD4MqjIRO2/Ka4ep/Q.RdUaPcjbmEWoYMtd0eeuzdOGVte', N'Darby.Beahan83', N'Zechariah_Ortiz@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739022' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'd1cbeb04-45bf-4a06-a7af-fdde7a22eb6b', N'$2b$04$hjzhA5v9wmUtm/m.qi6V7.xf7o4YLTLnNo6Deeu9dHloCYkpT7tsG', N'Freida.Daniel', N'Arne.McLaughlin16@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739255' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'd31e921c-fdec-4de7-a7d0-9ab86700416e', N'$2b$04$WiBU5UXDfxTvBUYRBWXRnuzHuBWzycEd8aFDv5h6xVyfZoNiEXegu', N'Burdette24', N'Tracy31@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739168' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'da2c67a1-2963-4736-b93c-98c43953b32d', N'$2b$04$pB3WDnZE.UyRWnL4qowpWOlPIpmOtVcS29XpLisLDrKd0tDkTwYV6', N'Darrick.Huel', N'Cecile_Nader71@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739127' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'dada2ed4-f692-434e-953e-3184d241f5d2', N'$2b$04$45WANtkOq7BL18vnefCReOgz9PIQrUsNzNtVnM3XwQHid6UdxGU4q', N'Adaline.Flatley', N'Joan_Goyette12@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738474' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'db5a6ce1-9a59-4a45-a13b-afb862369784', N'$2b$04$jQxbofQA2YEHjB1IrdY1UuKJU/eEjRdcP4mWyD8UxS.HcpY.sORpq', N'Alfonzo_Hettinger81', N'Larissa87@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739340' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'dd96be65-e71a-4537-ab07-0f5ed6ac667e', N'$2b$04$i7YZq.0MO6Nwb0E0BXPjQ.Q1hH/QLZPzCLggd9b.yoFGqWZEYxHa6', N'Pamela_Kub72', N'Charlotte25@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739161' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'e19cc307-4e54-49c5-a43c-7a4489e475c0', N'$2b$04$hDvdhjy3E1DIJGNwC4cnFu.HvLV4JGtWhPebxlvlYQ8rci.wjC/ri', N'Newell.Weimann87', N'Lonny.Wisoky72@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739276' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'e2532790-0bef-45d7-bd16-81709f211432', N'$2b$04$mTj.qm79ZEq4b40s9CBPjeX8KExc7okc3NM0uP1s.mHjDKrXgWIUC', N'Violette_Sipes', N'Esperanza_Hagenes78@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738955' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'e2f0e6b6-70d8-410b-b42d-deb2d32e00ae', N'$2b$04$UoqKMO.2Gtl.ZEW1CZfUHulzKkk8Z22wRRM60pC5ThE7LLFeXHYKG', N'Jolie_Gutmann', N'Nicole12@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739318' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'e595025e-707b-461a-9182-f7d465d2f91f', N'$2b$04$mrm/QwkUctQQ9Te7.vMNSeYd/eS81jUI/TGquk2BFTj0CYhNuUCrC', N'Elissa.Maggio', N'Krista58@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739333' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'e59bcd84-c04a-45cf-98e8-3580f6750984', N'$2b$04$y7frlPY3Oa0pq4A/n4X4Jupngmt1GFGSlVrQAdB/LgXf4kzbke8Oq', N'Dorothea_Deckow57', N'Alaina_Bradtke5@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738978' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'e5f9c68a-18c1-4907-ae44-c85861dfb739', N'$2b$04$CsSPKmmhtZlIuB0MM3ml8edKg2ajSrV9ti/Fu0gLypa4UCAvhsfS6', N'Quentin91', N'Elvie56@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738759' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'ea538c2f-7230-4d87-bbda-29db9fed309b', N'$2b$04$qmRM/q3AjltcSXZopL1AiOeGOKQfZlbmZoMxSS03tVQcm4AF60T7i', N'Clotilde4', N'Jackson_Streich@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738808' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'ee30ba09-6787-4cbe-b7d5-4136d7aa91a6', N'$2b$04$5GNqdfw23nfdhVDDT/6iAOmsofaSllacXfIFLF0UbTwSV28djgVH6', N'Taryn_Durgan', N'Adela86@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739423' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'ef87dbf8-a3ad-40e0-87e4-3c4633366b28', N'$2b$04$.LjTLKO3r5JMHHm0HrXNHeioJXuuhBVuw.kUNAc21XONf9dhobpb6', N'Brooklyn_Dickinson54', N'Maymie.Beer93@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739218' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'efd2d829-2500-4c66-bd27-586989316647', N'$2b$04$o260bGRP25WKOep5c4/lXOkrJtv.baT5VHUTRqHwpvkgbCH/RpXqm', N'Albertha.Osinski1', N'Blair18@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738521' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'f0bdc108-9efe-4ba4-a0ef-29bd040a7363', N'$2b$04$gf3iFdEdIiOuSPqdPZr60.mlT4pYNag1hVL/YwPzA/ZtMjnMjsOC2', N'Dustin56', N'Hilda66@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4738513' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'f19efa75-22a8-4287-9bd0-f088ed41f30b', N'$2b$04$N.UkP582m2i2SU2sMnWpqup4S9zRDKqhIIq/Y0Xolk1L0mMLRKGZK', N'Rey56', N'Destin50@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739325' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'f5ca7f60-0d49-4c12-bd33-87fbfdec7edd', N'$2b$04$iOrZk6jt3eRlJuXazW.6ZuaV8sosTuj9fjstcaZn5zb.Mdwg7gYE6', N'Madelyn_Pouros38', N'Ariane12@hotmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739106' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'f8a9e103-3c02-4dd2-b574-c79957887e5c', N'$2b$04$76oK9z4olfQiowoZLgYn/.Ua1zBoy75y3t.pYfXptAvznuQoZA2cK', N'Samara_Von', N'Ray17@gmail.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739120' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'fd20fdfb-7166-44ea-b258-9e3ee0f26e8d', N'$2b$04$ALSh2ZpJCE2Rs5gwz/sgpuWbr7qlqPp64eViCB1Y8gri24U8YTZkm', N'Randal.Doyle', N'Benny63@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739050' AS DateTime2))
INSERT [dbo].[users] ([uuid], [password_digest], [name], [email], [created_at], [updated_at]) VALUES (N'feee53b3-e691-488e-b3eb-2c0a4e2d0090', N'$2b$04$ysBNk4/skyps8aNWXYbV8uJfGoPt1GpCncGicpVTnQMb.tL1tCoyy', N'Kasey_OKeefe80', N'Claud.Abshire95@yahoo.com', CAST(N'2022-02-06T13:34:29.4730000' AS DateTime2), CAST(N'2022-02-06T13:34:29.4739187' AS DateTime2))
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ln
', 3, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'abl
', 4, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cum
', 4, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gre
', 4, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'iof
', 4, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lakę', 4, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'meg
', 4, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pwt
', 4, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rax
', 4, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sfm
', 4, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'atolu', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'capo
', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'coda
', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'coue
', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dowf
', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dukam', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'elmy
', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gonny', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gryzł', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'komżo', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'leno
', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'limo
', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mart
', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mobil', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'munt
', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ovis
', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'padłe', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'paws
', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'peck
', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pedli', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'roxy
', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rysik', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sążeń', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'star
', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tall
', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tiny
', 5, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ufitę', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zbiję', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zryję', 5, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'askoi
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'awide
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'biabo
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'birch
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'breed
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cobol
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cruds
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cumin
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cupel
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'domba
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ellan
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fired
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gezami', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gibli
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gledy
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'głowił', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'grene
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'grzywy', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'haika
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hasłom', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'jaskiń', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kasaka', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kelowi', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'knell
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'krężli', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'litre
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lucre
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mopuję', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'napaść', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nasty
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'osmoli', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'otomi
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pamhy
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'quare
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rąbków', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'raves
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'recpt
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rolado', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sabal
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sektów', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sheer
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'skift
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'skiwy
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'slopy
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spill
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'szreka', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'troch
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uczniu', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uparm
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'vidry
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'viewy
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'walców', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wefty
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'whump
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wiązem', 6, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'windy
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'write
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'yeses
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'yuruk
', 6, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'acylal
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'aiding
', 7, N'en')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ajentek', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ambury
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ampery
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'araise
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'arbute
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'atoxic
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'barker
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'blonds
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'boatel
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'borons
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bostal
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bouffe
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bouncy
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'brines
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'camoca
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'celebe
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cholee
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cieplak', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'coneen
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'conine
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cuecas
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cunyie
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cutely
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cyanol
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'czartów', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dacron
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'devels
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dicier
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dowołaj', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'edible
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'esencji', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'excels
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'faints
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fathom
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ferine
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fiderem', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'geests
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'girdle
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'giserzy', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'glebes
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'graeme
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hartly
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hexadd
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hoicks
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'homing
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hopsasa', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hunter
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'itylus
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'jaeger
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'junker
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'karettą', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'klamoty', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kubong
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kwakier', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'leghorn', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'liefer
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'liftuje', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lonżach', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lotong
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lovage
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mashed
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mazidłu', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'medius
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'melano
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'miting
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'muscle
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'naglisz', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'naplótł', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nickar
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieśnej', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nitril
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nowinie', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'obielmo', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'obsign
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'obunogi', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odcieki', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odmiano', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'okręceń', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'omyciem', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'oświnię', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pchając', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pędraka', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'płasklą', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pochlip', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podtyło', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'popłaca', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'porysuj', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prevue
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prolia
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'proode
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reeked
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'regalo
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'remulad', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reperk
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'repros
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rissel
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sercową', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sheila
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'siorbaj', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'siorpań', 7, N'pl')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'skarżąc', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'snatch
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'socjetę', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spinae
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'squirm
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'status
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sterczę', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'streen
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sunglo
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'teenty
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'telugu
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tenreku', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tenser
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'testor
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'theory
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tingly
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'toping
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'toposem', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'toquet
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tottum
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'trefnym', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'trojan
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'trzymam', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tyrałaś', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unline
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uparłeś', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'updrag
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'varnas
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'vatful
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'verver
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'viewly
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wciekną', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'whelms
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'whidah
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wikłały', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wooded
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'workach', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wrębiło', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wwlekła', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wybiela', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wzwodem', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zapacał', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zariba
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zawisać', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zęzowej', 7, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zombis
', 7, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'absydowe', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'airship
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'alecize
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'artemis
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'assumes
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'atamans
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'athbash
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'baronne
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'blagowań', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bredzeni', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bucefały', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'całostce', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cambers
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'catalin
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'catcher
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cedrówek', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chavish
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chiragro', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ciskacze', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'coeliac
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'conning
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'contrib
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'copular
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'counsel
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dapicho
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'debates
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'defiers
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'delfinów', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'deplete
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'diobely
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dognicia', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dorywczo', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'doszyłaś', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dropiaty', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'duchess
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'duplikat', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'duskily
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'egotysty', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ephelis
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'errable
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'exports
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'faconde
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fajdałaś', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fatally
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fiaschi
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'flanken
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'flotsen
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'foliums
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gajowcem', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'garners
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gefilte
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gercrow
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'girosol
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gluteal
', 8, N'en')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'goldbug
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gondite
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gorzenie', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'grapnel
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'harbour
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hoggers
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hubbite
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hyraxes
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'immerse
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'inflame
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'intrude
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'isocrat
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ivylike
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'izbeczką', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'izogamia', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'jazzers
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'jedziemy', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'jiveass
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'justers
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'justina
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kariokom', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kashira
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kierowcą', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'larixin
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'legowano', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'łukowscy', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'łuskajmy', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'marcowań', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mayhaps
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mensing
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'minimal
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mistook
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'moronic
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nabawimy', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nagadana', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nakroiły', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'namaśćże', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nawadnia', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'netbush
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niespory', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieżyzny', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'notably
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'oddalony', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odrapani', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'offices
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'okupanci', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'onstage
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'onychia
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'oppress
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'orarian
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'oratorze', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pantopon', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'partile
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pfennig
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'phonies
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pinkeye
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podkulał', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'popasani', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pożywiać', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'preloan
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pronaoi
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ptisans
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'puszkowe', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rajfurko', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reclose
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rewrote
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'roberts
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'roztrzęś', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rubbery
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rybojeże', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sabatowa', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sakeber
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'samisen
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'savarin
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'scopula
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'semikah
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sequani
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'serbdom
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'shilloo
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'shrines
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'skilful
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spasajże', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spattee
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spinner
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spitous
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'stalely
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'stogies
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'stosików', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'strokes
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'stupajom', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'surfman
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'szlamowi', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tallote
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tantawy
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'towages
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tuskish
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'twanger
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ubielono', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ucayale
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'udepnęły', 8, N'pl')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ukrócany', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uniters
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unsteek
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unthrid
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'upcoast
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'upcurls
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uwiercić', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'vicaire
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'vrilled
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'waggish
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wailing
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wearing
', 8, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'werndlem', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wrębywał', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wrogiego', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wwalcuje', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wymywane', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wypławię', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zagnoiły', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaślepić', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zbłąkane', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zsypujże', 8, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'acoelomi
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'actiones
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'adherant
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'advocaat
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'aegrotat
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'alsiferem', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'aranżerko', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'arculite
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'audition
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'avantlay
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'babiches
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'balaghat
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'banjoist
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'banksias
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'basilect
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'beefiest
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'benefact
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bistable
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bitbrace
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'blastide
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'boatlike
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bobowałem', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'boothage
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bruising
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bucharska', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bulimiac
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'burkińsku', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bushfire
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bydełkiem', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'caddises
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'calicoes
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cambiata
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'capiałaby', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'captance
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'caracoli
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'carpuspi
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'challies
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chamorro
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chapourn
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chazzans
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cirrhose
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'coachman
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cokneyfy
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'crevalle
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cromorna
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'crustate
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'curiatii
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'czareczko', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'decagons
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'deniably
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'descrial
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dieldrin
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dinamode
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'displume
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'diuretyno', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dochodzić', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dokopujmy', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dredging
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'driftway
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'duplikatu', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dustcart
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dzierżoną', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'edeology
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'elastorze', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'embolize
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'encysted
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'endemism
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'excretal
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'exorcism
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'exornate
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fermerami', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fireburn
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'flickers
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'foluszach', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'freshish
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'frettage
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'froggish
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'frygnięte', 9, N'pl')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gadkujmyż', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gandziach', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'geesowsku', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gelosine
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gęściutki', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gleesome
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'glyceric
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gnarlier
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'goshawks
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'greasing
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'groomlet
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'guanayes
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'harebell
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hogreeve
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'homopter
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'homotype
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hoofbeat
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hoosiers
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hospitia
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hurkoczmy', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'implores
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'infusing
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'inkstand
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'jaggeder
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'jędrniało', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'joginiach', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kaffiyeh
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kaflowymi', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kalekiemu', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kamarupa
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kimałabym', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kozłowały', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ładniutką', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'łataczami', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'liquored
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'litterer
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lobbowało', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'locativów', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'locksman
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'łowiskiem', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lustralna', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'łysiejemy', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'makijażom', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'maklerstw', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'małorolny', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mancando
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'manistic
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'marabucie', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'margaryno', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mealiest
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mealless
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mecenasce', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mezosomie', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'minitant
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'misspace
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mizoginem', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mucorine
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'muflarnia', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'murenger
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nachlacie', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'namęczyły', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'namłócili', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'naśladuję', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieopętań', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niesterań', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieulowym', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieżyjące', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'normistko', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'obleczmyż', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ochotona
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odpijałam', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odspoiłby', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ogławiali', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'okrwawiło', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'olivetan
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ośliniono', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overtrim
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pajacujmy', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pampered
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pandorea
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'paraphed
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'parasite
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pasquils
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'patologia', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'patronly
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pellicle
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'petitkiem', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'piłkowata', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pitiable
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'płoziłbym', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pobierało', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podłamuję', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podskubmy', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podsypało', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pojadajmy', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pojawiłby', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pojebania', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'poślizgom', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prebeset
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prebills
', 9, N'en')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'presound
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'próżniacy', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przedarły', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przywykał', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'psychoda
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'quaffers
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rdzennicy', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'realistom', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reballot
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rebuffet
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rechoose
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reclined
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'redlijcie', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'regauges
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rewinder
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozsianie', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rugującej', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ryjogłowi', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'shavings
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sheraton
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'simility
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'skulanymi', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'snugging
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sockeroo
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'śrutownie', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'starczych', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'strophic
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'subruler
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'suchness
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'szuwarową', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tchincou
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tesseral
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tłamsiłaś', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tonowanie', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'torfujemy', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'totalise
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'trakenami', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'trapunto
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'treasury
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'trimeric
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tummuler
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tyramine
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ubiczujmy', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'umierajmy', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uncoaxal
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'undarned
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'undrossy
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ungloved
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ungraced
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unjudged
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unlocker
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unringed
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unsensed
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unsocket
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'untamely
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'usidłałaś', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'utilises
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'validity
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'venomous
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'versatec
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wapiennik', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wazelinom', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wkreślony', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wmykaniom', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'woryszkom', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wydrwiono', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wygłaskań', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wygwizdów', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wykręciła', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyskubane', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wystawili', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyświetlę', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wzrośliby', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'yestreen
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaciosowa', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zakłuwany', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zasalutuj', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zatroskał', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zazbroimy', 9, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zoogloea
', 9, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'adiutancka', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'adsorbate
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'aerografom', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ammophila
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'analagous
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'andropauzy', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'anxiously
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'apennines
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'appendant
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'appliques
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'areolated
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'arracacia
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'astringed
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'autokomisu', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'azureness
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bacchides
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'balistytem', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bazującymi', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'befluster
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'benzoline
', 10, N'en')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'benzoxate
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'beworries
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bhutanese
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'billycock
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bioscopes
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'boczeniami', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bradburya
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'brevities
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'byordinar
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'caneology
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'catbriers
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cementoma
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chapnęłoby', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chargeant
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chenopods
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chorzałbym', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cocreator
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'coferment
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'coiffures
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'collegium
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'crepidoma
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cunningly
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cupressus
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dampishly
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'delumbate
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'demitrain
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'depravers
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'detroiter
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dokuczliwe', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dopożyczam', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dopożyczań', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dosychajmy', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'drubbings
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'duellists
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dungarees
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dworeczkom', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dyslectic
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dziczejemy', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dzięciołów', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'egzotyczni', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'eklektykom', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'emaliowali', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'emergents
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'engrafter
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ensampler
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'enunciate
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'existence
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'falszburto', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fedrowaniu', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fieldward
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fluxmeter
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'flycaster
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'forytowały', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'frondibola', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fryzowałam', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fulańskiej', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'garnishry
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gasometer
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'germanics
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gęstnącymi', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'globalistą', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'goldfinny
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'grassiest
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'grogshops
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'grounders
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gustatory
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hakowaniem', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'halsującej', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'homeopath
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'houndfish
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hymettian
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hyponymic
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'inactuate
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'injectors
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'insectine
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'iridaceae
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'izokefalij', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'jellified
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kancerujmy', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kanciatemu', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'karyomere
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kodycylowi', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'konflikcie', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lamellule
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'larghetto
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'liczmenowi', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lipomyoma
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lojalistce', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'makietować', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'malarioid
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'microfilm
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mierzwiącą', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'millerole
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'milliners
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'miniscule
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'moldavian
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mutilates
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'naparzonej', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'naważonemu', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nawinęłyby', 10, N'pl')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nawożącymi', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nawytykamy', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'neophytes
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nibynóżkom', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niełysawym', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieodrowym', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewarowny', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nuculacea
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'obkupiwszy', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'obrzynanie', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'obsrywałaś', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'obtulaliby', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odciągnęły', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odwirujesz', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odwlokłaby', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'osaczaniem', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'outpushed
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'outsinned
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overtimid
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'paguridae
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'papulated
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'parkociłem', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'paszowicki', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pathetism
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pawiackimi', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'peartness
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'penseroso
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'perviable
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pintadoes
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'płótnowano', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'plumiform
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pochwytany', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podobijamy', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podsufitek', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podzielamy', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pogadywali', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'poharatają', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'postnasal
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'posypywane', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'poustalasz', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'powięziłeś', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'powspinały', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pożarniczą', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'preferent
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przepocono', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przygańmyż', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przysłanym', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'publilian
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pucczankom', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pylangial
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rachowałem', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rawhiding
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'razorbill
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reanimate
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'recounter
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rejestrują', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reladling
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rentgenach', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'repursues
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'responded
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'retorting
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rhopalium
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozbarwisz', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozgranicz', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozpaszesz', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rubrycelom', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ruffianly
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rygorozach', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'schroniona', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'słoniskiem', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sourishly
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spamowałby', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'stinkaroo
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'strzelarki', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'stumpnose
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'stumpwise
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sulphuryl
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'swinehood
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'szepnęliby', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tantalous
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tchórzyłby', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'thickened
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'thwartman
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tidecoach
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tłoczonych', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'transmold
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tricresol
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tripodian
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uaktywniać', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uintymniło', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ujadaniach', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unbrittle
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'undeluded
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unditched
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'undulates
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unguicorn
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unlegible
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unloathly
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'urabiające', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'volkslied
', 10, N'en')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wainscots
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wartiness
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wartogłowy', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'witnesses
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wódczanych', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wonderful
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wrainbolt
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wtopionemu', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyczekałem', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wydziałową', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wydzwonili', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wykopowego', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wynkernel
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wysyczałam', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wytłuśćcie', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wzruszacie', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'xenagogue
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'yachtsmen
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zajezdniom', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zakrapiały', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zamykanego', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zapominane', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zarękawkom', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaśliniłem', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zatajałbym', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zawężałaby', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zbereźniki', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ziphiinae
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zirytowaną', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zjędrnieli', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zmokniętej', 10, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zygotaxis
', 10, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'afterstudy
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'akwirowania', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ammoniuret
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'amnestying
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'anadidymus
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'aspołecznym', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'asseverate
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'attenuated
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'azotenesis
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'barracking
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'berascaled
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'beshadowed
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bezrzęsnemu', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bobrkowatej', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'boneflower
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'branchiest
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'broadsheet
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bromthymol
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'buckboards
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cannelured
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'capillitia
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cattlefold
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'charmingly
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chironomus
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ciachnięciu', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cielaczkach', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cochleitis
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'contagions
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cudzoziemka', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dedukującym', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'detestably
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'diabantite
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dialektyzuj', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'disleafing
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dopadającej', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dosiadywane', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'drawieńskim', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'echinulate
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ewangelikom', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'exceptions
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'extipulate
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'extranidal
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'felineness
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'foeticidal
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fosforytową', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fostership
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'freemartin
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'garwoliński', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'glossohyal
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'handwaving
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'harfowanemu', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'harvestbug
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hempstring
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hexacyclic
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hexadecane
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'holystoned
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'iliodorsal
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ineligibly
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'integrowały', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'intendente
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'interferon
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'invitatory
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'jiggermast
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kleptomanie', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'korzystnego', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kosodrzewów', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'koziorożcom', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'krzniańskim', 11, N'pl')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'latecomers
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'leptandrin
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lethargize
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'limpnesses
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'liofobowych', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'literarily
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lithophyll
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lobbowaliby', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lokacyjnych', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'macroptery
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'magnezowego', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mcholubnymi', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'melografach', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mesogyrate
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'metrażowego', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mikroskopów', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'miligramowy', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'millesimal
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'miscreancy
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'modrzaczkom', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'muscleless
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nabajtlujmy', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'narbońskiej', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'narowiłyśmy', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nasarkałbyś', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'następowały', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'natarzaliby', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'natłumaczeń', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nawydziwiać', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'neomachizmy', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieczepiana', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niedonaszań', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niehasłowym', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niekolażowo', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niemasowana', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niemrugnięć', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nienaćkanie', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieodrybiań', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieotwockie', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieporowata', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieskracani', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nietoniczną', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieugadywań', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieulaniach', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewidywany', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonagenary
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'noneconomy
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonobvious
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nontypical
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'obstąpiłoby', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'obtapiałyby', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odwieziecie', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ophiomancy
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'optomeninx
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'oreotragus
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'orthoepies
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'otworzeniom', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'outdancing
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'palatality
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'panegirysty', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pastelistów', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'paszalikaty', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'patologiami', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pelargikon
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pelargonino', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'perishless
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'perspiring
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'picnickery
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'planetable
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'planorboid
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podgarniesz', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podiwanieni', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podoficerem', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pogrążyliby', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pomachiwały', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'popowlekany', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'porosities
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'porozrywani', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'porżnięciem', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'potanianego', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'potrząsłszy', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'potynkujemy', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'powoźnictwo', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'powycofujmy', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pozałatwiam', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'preimitate
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'proteinous
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prztyczkowi', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przybliżone', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przyczepami', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przytruwaną', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przytulicom', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'quinnipiac
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rabulistic
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'referencer
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reichsmark
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'restarting
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rostellate
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozdygocesz', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozjuszenia', 11, N'pl')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozkrajałam', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozpracujże', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ruszczących', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ryżobrodego', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'satanizmowi', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ściemniałam', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'semiyearly
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'serrasalmo
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'seybertite
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'shrineless
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'simpletons
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'simplistic
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'skepticize
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sklepiającą', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'slippiness
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'smithereen
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'snadniejszy', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spodlijcież', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'springlock
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spychałabyś', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'squirelike
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'śruborogimi', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sterculiad
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'stockinged
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'subcellars
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'suppliancy
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tariffless
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'telemeters
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'theologise
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'trajkotałby', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'transition
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'trematodes
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uhonorowuje', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unarodowiła', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unavoiding
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unbalanced
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unbemoaned
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unchoicely
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'undelaying
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unfineable
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uniflorous
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unsmutched
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unspecific
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'untunneled
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unwatchful
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'usuriously
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uszczypliwy', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uwyraźniasz', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'varicocele
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'vegeteness
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'verminlike
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'virginitis
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wabbliness
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'waterbloom
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wchodziłoby', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'whitehawse
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wibramycyna', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wszechwadze', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wsztukowane', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wygłaszajmy', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wymienienia', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyprężałbyś', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyszarpania', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyszturchaj', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wytrzeźwiam', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wywiadujące', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zagustowała', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaklaskajże', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zakrzątacie', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'załączonemu', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zamocowanie', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zamówionego', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zapacaniami', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zbłąkałabyś', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zeswatałoby', 11, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zigzagways
', 11, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'achałybyście', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'adsorbowałeś', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'aftergrowth
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'agrammatica
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ammotherapy
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'anachoretami', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'anagnoryzmom', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'anteopercle
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'apometaboly
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'assimilable
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'basketballom', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'beatificate
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'benignities
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bimbalibyśmy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'biomechaniką', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'blachowniach', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bromobenzenu', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'caudotibial
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cementowałaś', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'checkerspot
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chinchayote
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chlorhydric
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'connectedly
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'counterpace
', 12, N'en')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cummerbunds
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cysticarpic
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'czarterujące', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'decahydrate
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dekalkomanii', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'demaskowałem', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'demodulatory', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'denominated
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dewolutywnej', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dopuszczonym', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dosiadywałem', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'doubtlessly
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dozorującymi', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dracontites
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dundrearies
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'encouraging
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'evanescency
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ewokacyjnych', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'featherhead
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'filcowałabyś', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'formicicide
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fotokataliza', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fructuously
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'galloperdix
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gametophyll
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'geniculated
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'germinating
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'homunkulusom', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'horodelskiej', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hospitantach', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'imperforata
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kabaretujemy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kaledonidami', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kałożerstwom', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kapcanieniom', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kaszarstwach', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kinesiatric
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'komentatorkę', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'koncentracje', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kontestowano', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kościańskich', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kraniometryj', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'krochmaleniu', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kroksztynkom', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'łagodniejący', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'laparoscope
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'libracyjnymi', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'merchanteer
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'merostomous
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mesobenthos
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'mesyńczykach', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'microcosmus
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'misemployed
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'monosomatic
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'monstrances
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'naczesałabyś', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nadniemeński', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'naładowałoby', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'naopowiadaną', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'napsoceniami', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nefelometrom', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieasamblowa', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebotycznie', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieciernisty', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niedunitowej', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niegładzenia', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niehadziaccy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nielernejscy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niełysiejący', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nienałogowej', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nienapasioną', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieodmakaniu', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieoziębiana', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieparobkowa', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepodłapana', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieponatykań', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepsiknięta', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nierozpętaną', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niesądzących', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niespecjalny', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieszurnięte', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nietuczarski', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezasilanej', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezdołowaną', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezdwojonym', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezgubionej', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieznęcanego', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonneurotic
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonstorable
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odontotrypy
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odwróciłyśmy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ograbiałyśmy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'opiniowałbyś', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'orkiestronie', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overflatten
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overservice
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'parapitekach', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pedagoguish
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pedagogying
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'peevishness
', 12, N'en')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pericycloid
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'peroxidized
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'perruthenic
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'photochromy
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'poczciarkami', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podetiiform
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'poflotacyjni', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pograbiejesz', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pokształciła', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'półzwęglonym', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ponawadnianą', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'porozrzedzaj', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'posnobujecie', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'powyłupujcie', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pozagważdżać', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pozamalarska', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pozasiadajmy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pozbijałabym', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'preambulary
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'preclassify
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prederiving
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'preinclined
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'premidnight
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'premierowego', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'proamniotic
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prosecutive
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przedpisemne', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przeganianie', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przygłaszali', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przynależała', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'quinquangle
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'racjonowania', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'radiomovies
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'recontracts
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'recorporify
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reharmonize
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'relishingly
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'retrocaecal
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ripsnorting
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozkojarzone', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'różowiejcież', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozpanoszyła', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozpatrujmyż', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozścielanej', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'semazjologią', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sensigenous
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sensytywnych', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sideromancję', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'skrzydełkową', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'smorodinówek', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sojuszniczek', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'solaceproof
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sorkwickiemu', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'speronaroes
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sphaeridial
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'squirtingly
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sternohyoid
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'stężałybyśmy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'storpedujcie', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'styliolitach', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'superrefine
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'supracostal
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'syllabising
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'synanthrose
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'szminkowałam', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tabulowanego', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'telangiosis
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'topocentric
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'turpentinic
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'typicalness
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tyrannously
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'udeptałyście', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'umieralniami', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unaocznionej', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unasienniamy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'underbutler
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'undiffusive
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'undisputing
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unextracted
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uninsulated
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unscalloped
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'upieprzyliby', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wartowniczej', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wiosłowałaby', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wiśniewskiej', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wokalizowani', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wróżbiarkach', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wygładzanego', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wylawirowało', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wypiękniliby', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wypożyczyłby', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wzdrygnęliby', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'xenophanean
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'xerophagies
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zabłagałabyś', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zabukowaniem', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zadatkowaniu', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaminowujesz', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaplombujmyż', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zdmuchujecie', 12, N'pl')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zeskromnieli', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zeświecczcie', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zhasalibyśmy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zmotyczkować', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'znobilitujmy', 12, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zoografting
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zygophyceae
', 12, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'abbreviation
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'abbreviators
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'acetyliodide
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'amortyzacjach', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'amyloplastid
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'anisocytosis
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'apometabolic
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'asperuloside
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'astrographic
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ateizowałabym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'austronesian
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'benzoquinone
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'brzegoskłonów', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'budziszyńskim', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'buzerowałabym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cantankerous
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'charivariing
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cinchonamine
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'coenamorment
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'committeeman
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cryptoglioma
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'decapodiform
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'defenestracją', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dekretalistów', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'democratised
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'deskryptorową', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'destylacyjnym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'disregardant
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'doktoranturom', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dosiadywałbyś', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'elektrowózkom', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'endocarditic
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'enfranchises
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'entosternite
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'entrancement
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'eukariotyczni', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'faultfinding
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'flegmatyzmowi', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fototropizmie', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fraternation
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'galactosemic
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'gastrolobium
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hellenophile
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'helmintologię', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hipotermiczne', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'holosomatous
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hycnęłybyście', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'iconophilist
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ileocolotomy
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'izocyjanianów', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'jeffersonian
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'jeleśniańskim', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kąkolewnickie', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kalcynującemu', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kapitanowałam', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'karbolującemu', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'klerykałowską', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kobierczykowi', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'konfiguracjom', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'konwersacyjna', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'koprodukowani', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'marianowskimi', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'modyfikowałem', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'monologującym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'montserrackie', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nabuntowanymi', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nadpękniętemu', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nagolennikowi', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nakradzionymi', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nastopyrczymy', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'naszlochałoby', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'natłuściliśmy', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nephelometer
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebezsolnymi', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niedecyzyjnej', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niedorozwojku', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niedotruwanie', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niedowidzącym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niefantowania', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niefrunięciem', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niefurgocącej', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niegłogowskie', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niemieszakowe', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niemumiowatej', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieobczepioną', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieoceaniczną', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieogryzaniem', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieoksydowane', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieowinięciem', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieplotkujące', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepobudzanym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieposiewowej', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niesierpeckie', 13, N'pl')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niesucholubny', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieświdnickie', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niesylikatowa', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieszepcącego', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nietłoczniową', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieupływające', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieuznawanego', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewarzeniami', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewmieszaniu', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewydążeniem', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewygaszania', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewygładzani', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewyłataniom', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezabębniony', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezałatwianą', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezamontowań', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezapolickie', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezdychający', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezestarzały', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonabstainer
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonaffection
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'noncrushable
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonselection
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonsentience
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odmakałybyśmy', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odpolitycznić', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odpuszczający', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odstukniętymi', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odzipnięciach', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ogniochronnym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'opisthodetic
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'originatress
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'otologically
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overreliance
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'parafowaniach', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'participable
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'partycjonując', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pasibrzuchami', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'peregrynacjom', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'phentolamine
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'phylloideous
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pochodziłabym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podrąbywanych', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podśmiechujkę', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pojednywaniem', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'polemizującym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ponakreślałeś', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'poprzynoszona', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'postscutella
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'potruchlałbyś', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'powtórzeniami', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'powymądrzajże', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pozlizywałbym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'poznajdywałam', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pozwalibyście', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'precausation
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'preceptively
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'proborrowing
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przeganiałaby', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przemnożonymi', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przenosiłabym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przesączynowi', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przetrawiałeś', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przydawkowemu', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przygrywająca', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przyzakładową', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reinvitation
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'repatriating
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'retrenchable
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rhineurynter
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rocznicowości', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozczesaniami', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozdwojeniami', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozgotowujemy', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozkojarzyłeś', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozpląsałabyś', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozwarstwieni', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sankcjonowaną', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sauropsidian
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'scałowywaniem', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'semibachelor
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'semihumorous
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'skapowałyście', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'soliflukcjach', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spiderflower
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spiekalniczym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spolerowywano', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sporangiolum
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'stębnowaniami', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'strumousness
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'telepracownik', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'transverbate
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tropospheric
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uintensywniać', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ułagodziłyśmy', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unaccumulate
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unappealably
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unbrutalised
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uncarbonated
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'undreadfully
', 13, N'en')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unicuspidate
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unvigorously
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unwashedness
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unwassailing
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uprzytomniasz', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uspokajajcież', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'waggonwayman
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'warstwicowemu', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'współzależący', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wszędobylstwo', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wykarmiającej', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyodrębnianej', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wysokoudarowa', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wystrzeleniom', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wysuszających', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyzdrowiałymi', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wzbogacałyśmy', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'xalostockite
', 13, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zabalsamowaną', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaczadziałbyś', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zadekowałabym', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zakratowałbyś', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zapamiętywany', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaprzątniętej', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaśniedzonych', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zatłoczeniach', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zjednoliconej', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'znormalizujże', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zrejterujcież', 13, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'absolutyzujący', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'acceptability
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'actinomycetal
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'alleviatingly
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'antepenultima
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'antiresonance
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'brutification
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'butterfingers
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'celestialized
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chloramfenikol', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chloroplastic
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chojrakowałyby', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cobelligerent
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'conceptuality
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'confectioners
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'consonantized
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'continentaler
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'counterboring
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'debarkowałabym', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'decorticating
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dekoncentrowań', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'demagnetyzować', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'detectability
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'disconnective
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'doholowującego', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dokuczliwszych', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dopakowującymi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dostępowałabyś', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dyslokacyjnymi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dzwoniłybyście', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'excusableness
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'helmintologiem', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'heteroerotism
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'homodontyzmami', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hypercyanotic
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'immatriculate
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'imprejudicate
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'intercalative
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'interioryzację', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'interpelowałeś', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'interrogatrix
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'jednokomórkowi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kolposkopowego', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'konweniowałyby', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'legitymizowały', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'magnetometric
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'microsporidia
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'misclassified
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'monstrousness
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nabijalibyście', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nadskrzelowego', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'najrojniejszej', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'najtrwożniejsi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'najułomniejszy', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'napoprawiajcie', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'naprzykrzajcie', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nasosinusitis
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'neighbourlike
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieanoreksyjna', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niearkansaskim', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieasocjującym', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieaspiracyjna', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebezwiednymi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebiofizyczną', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niechlupotliwą', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niedodrukowane', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niedysfotyczni', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niedyspergowań', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieinhibicyjne', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niekationitowi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nienaczekaniem', 14, N'pl')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nienawdychanym', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nienoworocznej', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieośnieżanymi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieoziębianiom', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepłatniczego', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieplemnikowej', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepokrywające', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepoleganiach', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepozeszywane', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieprzebijaniu', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieprzyczynowi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieprzyjmująca', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieprzywędzany', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nierozdziałowy', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieskwarkowego', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niesprusaczeni', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieświerkowemu', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieszarpaniami', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieukradnięcia', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieulęgającymi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieuprawnienie', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieuwiązującej', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieworkowatego', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewszeptanemu', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewyfioczonej', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewyfrezowani', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewyłapywania', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezawróceniem', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezażydzonemu', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieżwanieckiej', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezwieszający', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonconvective
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odfiltrowujesz', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odgważdżajcież', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odpełźnięciami', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'odrzutowujecie', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ornithosauria
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'oskoumbryjskie', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ovipositional
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ówczesnościach', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'parakeratosis
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'plagiocephaly
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'plagiotropizmy', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pobledniałabyś', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'politicalized
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'półpogańskiemu', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'polydaemonist
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ponastrajaliby', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'poondulowanych', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'poprzestraszaj', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'porozpoczynane', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'posterishness
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'potrzebujących', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pourządzałabyś', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'powytrzebianiu', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'powyznaczanymi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pozachwycaliby', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'precautioning
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'preconquestal
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'preexposition
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prefiguracyjny', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przekraczanych', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przepróchnieje', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przyszykowałby', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przytaskałyśmy', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pyretogenetic
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'quadriternate
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'quarrellingly
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reinfiltrated
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'repersonalize
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'representably
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'reymontowskimi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rezerwowałabyś', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'roztasowywanej', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'scleroxanthin
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'seminarialnych', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'serwohamulcowi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sexualization
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sixpennyworth
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'slavonization
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sodioplatinic
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'strzeliłybyśmy', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'szafowałybyśmy', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tracheoskopową', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unabstentious
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unaudibleness
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'underbeveling
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unpuritanical
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'untransmitted
', 14, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uwidaczniającą', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wpieprzającymi', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wypatroszanych', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyrzygiwaniach', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaabsorbowania', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zacienilibyśmy', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zapluskwijcież', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaprzysiągłszy', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaszarżowałoby', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zdetonowaniach', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zeszlifowywały', 14, N'pl')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zmechanizujesz', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'żółtozielonemu', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zorganizowałeś', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zrekompensowań', 14, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'apodyktyczności', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'bizantyjskością', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cephalodiscida
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'corrosionproof
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'deflektometrami', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'disarticulated
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dodecasyllable
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dopieralibyście', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'dopowiedzianymi', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ekstraspekcjach', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'epexegetically
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'epidemiologist
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fizjognomicznym', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'galactopoietic
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'haemocytoblast
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'healthsomeness
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hyperdelicious
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ichthyophagous
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'inamissibility
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'intensywniejąca', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'intercessorial
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'interferencyjną', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'intermunicipal
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'karlistowskiego', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'kartografujecie', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'laryngotyphoid
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'lecithoprotein
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'masztalerstwach', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'multicarinated
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'neokapitalistkę', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niearchiwalnego', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niebiosterujące', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niedziurawienie', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niedźwiedzicami', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieesemesowaniu', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niegazyfikowany', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niegenologiczną', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niekażolowanymi', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieksięgowanego', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niekupelowanymi', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nienakłaniająca', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nienaszczypanie', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieobrabowanego', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieochajtaniami', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieochotniczych', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieodprzęgający', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieokupywaniach', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieostruganiami', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieoziębniętemu', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepastorałkowa', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepodkrajaniem', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepokrapiająca', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepomasowaniem', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepowykładanym', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepozawiązywań', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niepożyczającej', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieprzebaczalny', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieprzerzucaniu', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieprzymusowość', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieprzytulające', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieptolemejskim', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nierekwizycyjną', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nierozkwilonego', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nierozzłoconymi', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nietasiemkowymi', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieterminowości', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nietraktatowymi', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieudogodnienie', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieuljanowskimi', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nieuwyraźnianej', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewybranieckie', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niewytłomaczony', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezabrzęknięta', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezapatrującej', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezarecytowaną', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezarównywaniu', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezaślepiający', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezatoczkowaty', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'niezłagodzonemu', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonaesthetical
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'noncontractual
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonefficacious
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'obiektywizowane', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'petrarkowskiego', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'photographable
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'phytomastigoda
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'plumbogummitowi', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podagrycznikach', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podatkobiorcach', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'podkiełkowałbyś', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pooczyszczaniom', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pozużywalibyśmy', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'preliquidating
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prohibicjonistą', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'protopatrician
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przepustkowicze', 15, N'pl')
GO
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przesuwnikowych', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przydźwigaliśmy', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'przyrównywanemu', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'redimensioning
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozdzióbywanemu', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'roziskrzającemu', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozmazgajającym', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rozpracowaliśmy', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'roztłamszeniami', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'stereoblastula
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'subtransparent
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'supersweetness
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'szaroczerwonemu', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'temporocentral
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'thioantimonate
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'trappabilities
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'tumorigenicity
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'umożliwialiście', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unawakenedness
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uncollectively
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'undepreciatory
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'undiatonically
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uniemożliwiłyby', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unnitrogenised
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unobligingness
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unprecedential
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unresoluteness
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'untranquilized
', 15, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wychwaszczeniem', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'wyruchałybyście', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zafascynowałoby', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zagruntowaliśmy', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zamiauczałyście', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaprenumerowana', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zaśniedziałabyś', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zdramatyzowałem', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'ześrubowaliście', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'zeszkaradziłbyś', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'znieruchomiałaś', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'znokautowałabym', 15, N'pl')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'antispirochetic
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'chondroganoidei
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'enantiomorphism
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'fissidentaceous
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hyperdemocratic
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hyperexaltation
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'inexpungibility
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'interlinguistic
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'malpresentation
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'microanatomical
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'musicologically
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nontangibleness
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'oscillographies
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overaffirmation
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'paterfamiliases
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'patripassianism
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pauciarticulate
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'precontribution
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'prenecessitated
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'promiscuousness
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'rachioscoliosis
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'subcommissarial
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'theophrastaceae
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'trafficableness
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unmanageability
', 16, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'cytoarchitecture
', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'diversifications
', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'hypersentimental
', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'institutionalise
', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'noncleistogamous
', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonodoriferously
', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'palaeoentomology
', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'parallelinervous
', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'perigastrulation
', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'precorrespondent
', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'pseudomonastical
', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'selfpreservatory
', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uncontrovertably
', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'valetudinariness
', 17, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'crystallisability
', 18, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'electrochemically
', 18, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'laryngoscopically
', 18, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonconspiratorial
', 18, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'nonsubstitutional
', 18, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'protosiphonaceous
', 18, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'subadministration
', 18, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'trisacramentarian
', 18, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unblameworthiness
', 18, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'uncommendableness
', 18, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unconceivableness
', 18, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unconventionality
', 18, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'unprovocativeness
', 18, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'overimpressibility
', 19, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'spinosotuberculate
', 19, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'transubstantiating
', 19, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'vegetocarbonaceous
', 19, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'particularistically
', 20, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'underrepresentation
', 20, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'superincomprehensible
', 22, N'en')
INSERT [dbo].[words] ([word], [length], [language_code]) VALUES (N'sternocleidomastoideus
', 23, N'en')
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [challenge_types_name_key]    Script Date: 06.02.2022 14:38:13 ******/
ALTER TABLE [dbo].[challenge_types] ADD  CONSTRAINT [challenge_types_name_key] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [languages_name_key]    Script Date: 06.02.2022 14:38:13 ******/
ALTER TABLE [dbo].[languages] ADD  CONSTRAINT [languages_name_key] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [words_length_word_language_code_idx]    Script Date: 06.02.2022 14:38:13 ******/
CREATE NONCLUSTERED INDEX [words_length_word_language_code_idx] ON [dbo].[words]
(
	[length] ASC,
	[word] ASC,
	[language_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
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
ALTER TABLE [dbo].[words]  WITH CHECK ADD  CONSTRAINT [CK_words_length] CHECK  (([length]=len([word])))
GO
ALTER TABLE [dbo].[words] CHECK CONSTRAINT [CK_words_length]
GO
/****** Object:  StoredProcedure [dbo].[drop_challenge_duplicates]    Script Date: 06.02.2022 14:38:13 ******/
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
/****** Object:  StoredProcedure [dbo].[insert_word]    Script Date: 06.02.2022 14:38:13 ******/
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
/****** Object:  StoredProcedure [dbo].[start_game]    Script Date: 06.02.2022 14:38:13 ******/
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
