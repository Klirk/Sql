CREATE DATABASE AnimeList
GO
use AnimeList
GO
CREATE TABLE [dbo].[Type] (
    [id_type]   INT           IDENTITY (1, 1) NOT NULL,
    [name_type] NVARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([id_type] ASC)
);
GO
CREATE TABLE [dbo].[Rating] (
    [id_rating]   INT           IDENTITY (1, 1) NOT NULL,
    [name_rating] NVARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([id_rating] ASC)
);
GO
CREATE TABLE [dbo].[Status] (
    [id_status]   INT           IDENTITY (1, 1) NOT NULL,
    [name_status] NVARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([id_status] ASC)
);
GO
CREATE TABLE [dbo].[Season] (
    [id_season]   INT           IDENTITY (1, 1) NOT NULL,
    [name_season] NVARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([id_season] ASC)
);
GO
CREATE TABLE [dbo].[Anime] (
    [id_anime]   INT           IDENTITY (1, 1) NOT NULL,
    [name_anime] NVARCHAR (50) NOT NULL,
    [rated]      FLOAT (53)    DEFAULT ((0.0)) NULL,
    [episodes]   INT           NOT NULL,
    [date_start] DATE          NULL,
    [date_end]   DATE          NULL,
    [id_type]    INT           NOT NULL,
    [id_rating]  INT           NOT NULL,
    [id_status]  INT           NOT NULL,
    [id_season]  INT           DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([id_anime] ASC),
    FOREIGN KEY ([id_type]) REFERENCES [dbo].[Type] ([id_type]),
    FOREIGN KEY ([id_rating]) REFERENCES [dbo].[Rating] ([id_rating]),
    FOREIGN KEY ([id_status]) REFERENCES [dbo].[Status] ([id_status]),
    FOREIGN KEY ([id_season]) REFERENCES [dbo].[Season] ([id_season])
);
GO
CREATE TABLE [dbo].[Genres] (
    [id_genres]   INT           IDENTITY (1, 1) NOT NULL,
    [name_genre] NVARCHAR (50) NOT NULL,
    [genres_description] NVARCHAR (MAX)
    PRIMARY KEY CLUSTERED ([id_genres] ASC)
);
GO
CREATE TABLE [dbo].[AnimeGenres] (
  [id_anime] INT           NOT NULL,
  [id_genres] INT           NOT NULL,
  PRIMARY KEY CLUSTERED ([id_genres],[id_anime]),
    FOREIGN KEY ([id_anime]) REFERENCES [dbo].[Anime] ([id_anime]),
    FOREIGN KEY ([id_genres]) REFERENCES [dbo].[Genres] ([id_genres])
);
GO
CREATE TABLE [dbo].[Viewstatus] (
    [id_viewstatus]       INT           IDENTITY (1, 1) NOT NULL,
    [view_status] NVARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([id_viewstatus] ASC)
);
GO
CREATE TABLE [dbo].[Types] (
    [id_type]   INT           IDENTITY (1, 1) NOT NULL,
    [name_type] NVARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([id_type] ASC)
);
GO
CREATE TABLE [dbo].[Users] (
    [id_user]       INT           IDENTITY (1, 1) NOT NULL,
    [login_user]    NVARCHAR (50) NOT NULL,
    [password_user] NVARCHAR (50) NOT NULL,
    [id_type] INT NOT NULL,
    FOREIGN KEY ([id_type]) REFERENCES [dbo].[types] ([id_type]),
    PRIMARY KEY CLUSTERED ([id_user] ASC)
);
GO
CREATE TABLE [dbo].[ListAnime] (
    [id_user]      INT NOT NULL,
    [id_anime]     INT NOT NULL,
    [user_rated]   FLOAT NULL DEFAULT 0.0,
    [id_viewstatus]      INT NOT NULL,
	PRIMARY KEY CLUSTERED ([id_user],[id_anime]),
    FOREIGN KEY ([id_anime]) REFERENCES [dbo].[Anime] ([id_anime]),
    FOREIGN KEY ([id_user]) REFERENCES [dbo].[Users] ([id_user]),
    FOREIGN KEY ([id_viewstatus]) REFERENCES [dbo].[Viewstatus] ([id_viewstatus])
);
GO
CREATE TRIGGER [dbo].[SetAnimeSeason]
ON [dbo].[Anime]
FOR INSERT
AS
BEGIN
		UPDATE Anime
		SET id_season = CASE
		WHEN YEAR(date_start) < 1980 THEN 1
		WHEN YEAR(date_start) >= 1980 AND YEAR(date_start) < 1990 THEN 2
		WHEN YEAR(date_start) >= 1990 AND YEAR(date_start) < 2000 THEN 3
		WHEN YEAR(date_start) >= 2000 AND YEAR(date_start) <= 2013 THEN 4
		WHEN YEAR(date_start) >= 2014 AND YEAR(date_start) <= 2018 THEN 5
		WHEN YEAR(date_start) >= 2019 AND YEAR(date_start) <= 2020 THEN 6
		WHEN YEAR(date_start) = 2021 THEN 7
		WHEN YEAR(date_start) = 2022 THEN 8
		ELSE NULL END
		WHERE id_season is null
END
GO
CREATE TRIGGER TriggerLogin
ON Users
FOR INSERT
AS
BEGIN
	 IF EXISTS (SELECT *
               FROM Users u JOIN
                    inserted i
                    ON u.login_user = i.login_user
               GROUP BY u.login_user
               HAVING count(*) > 1
              )
    BEGIN
        ROLLBACK
    END
END
GO
CREATE PROC SignUp(@login_user NVARCHAR(50),@password_user NVARCHAR(50), @id_type INT)
AS
BEGIN
	INSERT INTO Users(login_user, password_user, id_type) 
	VALUES (@login_user,@password_user,@id_type)
END
GO
CREATE PROC SignIn(@login_user NVARCHAR(50),@password_user NVARCHAR(50))
AS
BEGIN
	SELECT * 
    FROM Users
    WHERE login_user=@login_user AND password_user=@password_user;
END
GO
CREATE VIEW AllAnime
AS
SELECT TOP(15000) a.id_anime, name_anime, rated, episodes,date_start,date_end, name_type, name_rating, name_status, name_season, STRING_AGG(Genres.name_genre,',') genere_list
FROM Anime a
LEFT JOIN Type ON a.id_type=Type.id_type
LEFT JOIN Rating ON a.id_rating=Rating.id_rating
LEFT JOIN Status ON a.id_status=Status.id_status
LEFT JOIN Season ON a.id_season=Season.id_season
JOIN AnimeGenres ON a.id_anime = AnimeGenres.id_anime
JOIN Genres On Genres.id_genres = AnimeGenres.id_genres
GROUP BY a.id_anime, name_anime, rated, episodes,date_start,date_end,name_type, name_rating, name_status, name_season
ORDER BY a.id_anime;
GO
INSERT INTO Types VALUES('Admin')
INSERT INTO Types VALUES('User')
GO
INSERT INTO Users VALUES('admin','admin',1)
INSERT INTO Users VALUES('Olga','Ol321ga',2)
GO
INSERT INTO Season VALUES('Older')
INSERT INTO Season VALUES('1980s')
INSERT INTO Season VALUES('1990s')
INSERT INTO Season VALUES('2000-2013')
INSERT INTO Season VALUES('2014-2018')
INSERT INTO Season VALUES('2019-2020')
INSERT INTO Season VALUES('2021 year')
INSERT INTO Season VALUES('2022 year')
GO
INSERT INTO Genres VALUES('Empty',N'Here none ganres')
INSERT INTO Genres VALUES('Shounen',N'Сёнен аниме и манга в основном рассчитаны на мальчиков или юношей от 12 до 18 лет. В центре повествования сильный и харизматичный персонаж, который упорно добивается поставленных целей (чаще всего труднодостижимых) в определенных сферах (например, спорт, музыка и т.д.). Герой сенена добрый, справедливый, удачливый парень, который противостоит силам зла.
Сюжет в таком аниме развивается стремительно: главному персонажу и его друзьям предстоит испытать множество интересных приключений, смешных происшествий, принять участие в трудных соревнованиях и т.д.')
INSERT INTO Genres VALUES('Shounen Ai',N'Сёнен-ай аниме и манга рассчитаны преимущественно на девушек и женщин, где главное внимание уделяется отношениям между мужчинами различных возрастов, начиная с пылкой и преданной дружбы и заканчивая любовью и страстью. Все мужские персонажи исключительно привлекательны. В сенен-ай отсутствуют сексуальные сцены, но возможны намёки на них и поцелуи. Как правило, таким аниме присуща атмосфера теплоты и романтики.
Сенен-ай как жанр отличается очень выразительной графикой.')
INSERT INTO Genres VALUES('Seinen',N'Сэйнэн аниме и манга рассчитаны на мужскую аудиторию от 18 лет. Здесь, в отличие от сёнена, затрагиваются более «взрослые» темы. Главным героем чаще всего является сильный, харизматичный и умный парень, решающий серьёзные жизненные проблемы, поэтому основное внимание уделяется раскрытию характеров персонажей и их мыслям, а не активным действиям. Часто сэйнэн содержит кровавые или эротические сцены. Основная идея сэйнэна состоит в том, что жизнь жестока и непредсказуема, в ней нет четкого разделения на чёрное и белое. А жизнь человека – это всего лишь результат его мировоззрения и «приложенных усилий в пропорции к усилиям, приложенным другими».')
INSERT INTO Genres VALUES('Shoujo',N'Сёдзё аниме и манга рассчитаны на девочек и девушек, где акцент делается на чувства и отношения между персонажами. Наибольшее внимание уделяется дружбе и любви, но могут затрагиваться и повседневные мелочи, нюансы конкретных взаимоотношений и переживания по поводу философских проблем. Все женские персонажи очень привлекательны, а в аниме нередко используется красивая графика.')
INSERT INTO Genres VALUES('Shoujo Ai',N'Жанр, где главное внимание уделяется отношениям между женщинами различных возрастов, начиная с пылкой и преданной дружбы и заканчивая любовью и страстью. Сексуальные сцены отсутствуют, но возможны намёки на них и поцелуи.')
INSERT INTO Genres VALUES('Josei',N'Дзёсей - жанр аниме и манги, рассчитанный на молодых женщин от 18 лет и старше. Обычно дзёсей описывает «взрослые» проблемы, уже не девушек, но ещё и не женщин. В центре сюжета находятся отношения, часто романтические и сексуальные. Часто присутствует эротика. Любовные отношения показаны в дзёсее более реалистичнее в отличие от сёдзе.')
INSERT INTO Genres VALUES('Comedy',N'Комедийные аниме и манга рассчитаны на широкую аудиторию. Основная цель комедии - развеселить и дать возможность отдохнуть, что вовсе не исключает поднятия философских вопросов или привнесение весьма жесткой сатиры. Здесь можно увидеть шутки, насмешки, забавные ситуации, весьма своеобразных персонажей, игру слов. Комедия бывает как самостоятельным жанром, так и "украшением" других.')
INSERT INTO Genres VALUES('Romance',N'В аниме и манге данного жанра акцент делается на близких взаимоотношениях между героями, а также трудностях и препятствиях на их пути.
Чувства могут быть как между девушкой и парнем, так и между девушкой и девушкой, парнем и парнем. На протяжении всего произведения зритель сопереживает злоключениям героев, радуется их успехам, ненавидит, когда, например, парень не выбрал понравившегося персонажа, а кого-то другого.
Романтической линии может отводиться и второстепенная роль, основной целью которой является лишь желание вызвать мечтания у зрителя о той или иной паре.')
INSERT INTO Genres VALUES('School',N'Поскольку жанр посвящен всему, что связано со школой, основной аудиторией являются подростки. Главный акцент делается на школьных проблемах, включая взаимоотношения со сверстниками, родителями и учителями, становление личности и самоопределение. Основное действие происходит в клубах, поездках, на фестивалях и т.д.')
INSERT INTO Genres VALUES('Action',N'Этому жанру свойственна динамичность и быстрое развитие событий. Сюжет построен на сильном эмоциональном напряжении, ему характерен накал страстей и резкие спады.')
INSERT INTO Genres VALUES('Adventure',N'')
INSERT INTO Genres VALUES('Cars',N'Главными действующими лицами произведений данного жанра выступают, фигурально выражаясь, колёса и моторы. Основные элементы сюжета — гонки или погони на автомобилях или мототранспорте. Красной нитью через повествование может проходить рассказ о судьбе гонщика, водителя, пилота болида. Как правило, представленные транспортные средства имеют какую-либо особенность, в чём-то уникальны или демонстрируются "культовые" модели автопрома. Акцент может быть сделан и на техническом усовершенствовании машин в целях достижения более высоких результатов.')
INSERT INTO Genres VALUES('Dementia',N'Жанр аниме безумие характеризуется либо алогичностью происходящего в сюжетной компоненте, либо кажущейся бессмысленностью в визуальном плане. В первом случае произведения нацелены на обратный эффект: казалось бы безумное действо имеет целью заставить зрителя задуматься, взглянуть с другого ракурса на привычное и устоявшееся. Этот художественный приём может применяться и для привнесения юмористического оттенка в произведение. Во втором случае не несущему сюжетной нагрузки визуальному ряду обычно сопутствует соответствующее музыкальное сопровождение для погружения зрителя в состояние, которого добивается автор: тревожное, умиротворённое, созерцательное и пр.')
INSERT INTO Genres VALUES('Demons',N'')
INSERT INTO Genres VALUES('Drama',N'В драматических аниме или манге основной акцент делается на игре сильных чувств, глубоких противоречиях и конфликтах, трудноразрешимых проблемах, которые нередко имеют непоправимые последствия. Драме свойственна трагичность, но может быть и счастливый конец.')
INSERT INTO Genres VALUES('Ecchi',N'Этти в основном рассчитан на мужскую аудиторию. Это один из подвидов хентая. В аниме и манге мужчины изображаются сильными и мускулистыми, а женщины одарены подчёркнуто соблазнительными формами. Основная цель жанра - намекнуть зрителю на недвусмысленные отношения героев.
В этти часто можно увидеть белье персонажей и некоторые оголенные части тела. Сексуальные сцены в таком аниме отсутствуют, но есть сцены с эротическим содержанием и романтические чувства по отношению к персонажам противоположного пола.
Главным отличием этти от хентая является отсутствие демонстрации половых отношений; в этти присутствует лишь намек на таковые.')
INSERT INTO Genres VALUES('Fantasy',N'В фэнтизийных аниме и манге часто встречаются элементы фольклора, чаще всего западноевропейского, но нередко используется и колорит Востока, и элементы японской и китайской мифологии. Основное действие происходит в вымышленном мире со сказочными существами. Непременный атрибут фэнтези - магия и волшебство.
Характерное отличие этого жанра состоит в том, что особенности этого мира и существование вымышленных существ не объясняются с научной точки зрения, а являются нормой.')
INSERT INTO Genres VALUES('Game',N'')
INSERT INTO Genres VALUES('Gourmet',N'')
INSERT INTO Genres VALUES('Harem',N'Аниме или манга этого жанра имеют черты комедийного и романтического характера и рассчитаны на широкую аудиторию. Обычно по сюжету главный герой вовлечен в любовные истории с более чем 3 представителями противоположного пола. Основное внимание чаще всего уделяется выяснению отношений между персонажами.')
INSERT INTO Genres VALUES('Historical',N'Этот жанр рассчитан на широкую аудиторию. Действия в аниме и манге связаны с определёнными историческими событиями. Чаще всего это эпизоды из истории Западной Европы, Японии или Китая. Описываемые действия могут соответствовать реальности или быть вымышленными.')
INSERT INTO Genres VALUES('Horror',N'')
INSERT INTO Genres VALUES('Kids',N'Аниме и манга этого жанра направлены в основном на детскую аудиторию. Произведения носят позитивный, жизнеутверждающий характер. Сцены насилия, жестокости отсутствуют или носят юмористический оттенок. Отрицательные персонажи порой выполнены так, чтобы и при одном визуальном восприятии резко контрастировали с положительными, и даже отсутствие реплик героев не оставляло сомнений в симпатиях маленького зрителя или читателя. Морально-нравственных вопросов требующих глубокого осмысления не поднимается, если они присутствуют, то их понимание лежит на поверхности.')
INSERT INTO Genres VALUES('Magic',N'')
INSERT INTO Genres VALUES('Martial Arts',N'Боевые искусства — системы единоборств и самозащиты различного происхождения. Основная аудитория - мальчики, юноши и просто любители единоборств. Центральная линия сюжета – изучение какого-то вида боевого искусства. Особое внимание уделяется развитию навыков и росту силы персонажей. С помощью своих выдающихся способностей герои расправляются с врагами, побеждают в соревнованиях.')
INSERT INTO Genres VALUES('Mecha',N'Это научно-фантастический жанр, отличительной чертой которого являются человекоподобные машины, чаще всего используемые в бою. Главными героями являются персонажи, управляющие этими роботами изнутри. Основной акцент делается на контакте и синхронизации людей и машин. Характерной чертой меха является детальное описание запуска такой машины и взаимодействие с ней.')
INSERT INTO Genres VALUES('Military',N'В произведениях данного жанра демонстрируется функционирование различных воинских формирований от исторически достоверных армий, до отряда наемников или группы пилотов боевых роботов. Как правило, присутствуют боевые столкновения от индивидуальных схваток, до широкомасштабных сражений армий большой численности. Так же основной акцент в произведении может быть сделан на демонстрации военной техники, оружия, различных тактических приемов или на гуманитарный аспект последствий войн.')
INSERT INTO Genres VALUES('Music',N'В аниме или манге рассказывается о музыке и музыкантах, трудностях достижения музыкальной мечты и музыкальной карьеры.')
INSERT INTO Genres VALUES('Mystery',N'Преимущественно литературный и кинематографический жанр, произведения которого описывают процесс исследования загадочного происшествия с целью выяснения его обстоятельств и раскрытия загадки.
Аниме и манга этого жанра композиционно состоят из: завязки - обычно загадочного происшествия той или иной направленности, от потери казалось бы безделушки до убийства; кульминации - как правило высшее напряжение умственных усилий в решении задачи или наибольшая угроза лицам ведущим расследование; развязки - объяснение случившегося, решение загадки, оглашение причастных и виновных. Каждая история может находить реализацию в отдельной художественной форме лаконичного или развернутого формата, либо истории могут быть объединены в цикл по какому-либо признаку, например главным действующим лицам.')
INSERT INTO Genres VALUES('Parody',N'В пародийных аниме или манге обычно высмеиваются другие жанры при помощи гротеска и сатиры. Характерные черты определенного жанра или жанров гиперболизируются и доводятся до абсурда.')
INSERT INTO Genres VALUES('Police',N'')
INSERT INTO Genres VALUES('Psychological',N'Основная цель такого аниме или манги - показать, как работает человеческая психология. Самый популярный сюжет - как сообразительный персонаж использует знание психологии, чтобы добиться собственных целей.')
INSERT INTO Genres VALUES('Samurai',N'Главными героями этого аниме или манги являются самураи. Большое внимание уделяется самурайскому кодексу чести – бусидо - и подвигам, и приключениям самураев. Действие обычно происходит на историческом фоне. Иногда основными действующими лицами являются ниндзя.')
INSERT INTO Genres VALUES('Sci-Fi',N'Жанр, характеризуемый использованием фантастического допущения, «элемента необычайного», нарушением границ реальности, принятых условностей. Фантастическое допущение, или фантастическая идея — основной элемент жанра фантастики. Он заключается во введении в произведение фактора, который не встречается или невозможен в реальном мире.')
INSERT INTO Genres VALUES('Slice of Life',N'Основная цель таких аниме или манги - художественно, и в то же время максимально достоверно, рассказать о повседневных проблемах. В центре повествования будничная жизнь нескольких человек определенного возраста, чаще всего это школьники.
Обычно аниме состоит из нескольких маленьких новелл, где описаны сцены или ситуации, в которые можно попасть в реальной жизни. В повседневности есть и место комедии – тогда главные герои постоянно оказываются в череде нелепых и комических ситуаций.
Повседневность считается самым трудным жанром, поэтому требует от мангак, режиссёров и сейю высшего пилотажа и профессионализма.')
INSERT INTO Genres VALUES('Space',N'')
INSERT INTO Genres VALUES('Sports',N'Этот жанр аниме или манги целиком посвящён достижениям персонажей в определённом виде спорта. Чаще всего сюжет вращается вокруг одной спортивной команды (чаще всего школьной), которая, благодаря высокой мотивации и труду, постепенно побеждает всех соперников.
Основная цель – показать, что если есть сильное желание и интерес, то человек непременно добьётся успеха независимо от таланта.')
INSERT INTO Genres VALUES('Super Power',N'В аниме и манге этого жанра герои наделены повышенными физическими возможностями. Природа супер силы может носить фантастический или мистический характер. Супер способности могут быть как врожденной чертой носителя - инопланетного пришельца, мистического существа и т.п., так и приобретенными обычными людьми в результате, например, воздействия какого-либо фактора, взаимодействия с каким-либо предметом или же увеличение силы физической достигается путем приложения силы духовной. Супер сила может быть постоянной характеристикой носителя или проявляться при необходимости.')
INSERT INTO Genres VALUES('Supernatural',N'Жанр, где основной акцент делается на сверхъестественных и необъяснимых явлениях. Непременные персонажи этого жанра - вампиры, призраки, духи, демоны. Наиболее популярен японский фольклор, отражающий буддийско-синтоистское представление о мире, в которое местами вкрапляются элементы христианства.')
INSERT INTO Genres VALUES('Vampire',N'Основные персонажи этого жанра - упыри, вурдалаки, стригои, ламии, веталы и т.д. Герои могут быть разными. Они вечно живут, боятся света, чеснока и креста, но при этом они сильные, безумные, не отражающиеся в зеркалах, трагичные, смешные, но все как один желающие одного - крови.')
INSERT INTO Genres VALUES('Work Life',N'')
INSERT INTO Genres VALUES('Thriller',N'Жанр, нацеленный вызвать у зрителя внезапный прилив эмоций, чувство тревоги, возбуждение. Жанр не имеет чётких границ, элементы триллера присутствуют во многих произведениях разных жанров.')
GO
INSERT INTO Rating VALUES('G')
INSERT INTO Rating VALUES('PG')
INSERT INTO Rating VALUES('PG-13')
INSERT INTO Rating VALUES('R-17')
INSERT INTO Rating VALUES('R+')
GO
INSERT INTO Status VALUES('Announced')
INSERT INTO Status VALUES('Airing')
INSERT INTO Status VALUES('Finished')
INSERT INTO Status VALUES('Aired Recently')
GO
INSERT INTO Type VALUES('TV Series')
INSERT INTO Type VALUES('Movie')
INSERT INTO Type VALUES('OVA')
INSERT INTO Type VALUES('ONA')
INSERT INTO Type VALUES('Special')
INSERT INTO Type VALUES('Music')
GO
INSERT INTO Viewstatus VALUES('Planned to Watch')
INSERT INTO Viewstatus VALUES('Watching')
INSERT INTO Viewstatus VALUES('Rewatching')
INSERT INTO Viewstatus VALUES('Completed')
INSERT INTO Viewstatus VALUES('On Hold')
INSERT INTO Viewstatus VALUES('Dropped')
GO
INSERT INTO Anime VALUES('Fullmetal Alchemist','8.13',51,'10/4/2003','10/2/2004',1,4,3,NULL)
INSERT INTO Anime VALUES('Steins Gate','9.09',24,'04/6/2011','09/14/2011',1,3,3,NULL)
INSERT INTO Anime VALUES('Kimi no Na wa.','8.89',1,'08/26/2016',NULL,2,3,3,NULL)
INSERT INTO Anime VALUES('Koe no Katachi','8.97',1,'09/17/2016',NULL,2,3,3,NULL)
INSERT INTO Anime VALUES('Kimetsu no Yaiba','8.56',26,'04/6/2019','09/28/2019',1,4,3,NULL)
INSERT INTO Anime VALUES('Vinland Saga','8.73',24,'07/8/2019','12/30/2019',1,4,3,NULL)
INSERT INTO Anime VALUES('Howl no Ugoku Shiro','8.66',1,'11/20/2004',NULL,2,1,3,NULL)
INSERT INTO Anime VALUES('Yakusoku no Neverland','8.56',12,'01/10/2019','03/29/2019',1,4,3,NULL)
INSERT INTO Anime VALUES('One Punch Man','8.52',12,'10/5/2015','12/21/2015',1,4,3,NULL)
INSERT INTO Anime VALUES('Death Note','8.63',37,'10/4/2006','06/27/2007',1,4,3,NULL)
GO
INSERT INTO AnimeGenres VALUES(1,2)
INSERT INTO AnimeGenres VALUES(1,11)
INSERT INTO AnimeGenres VALUES(1,12)
INSERT INTO AnimeGenres VALUES(1,8)
INSERT INTO AnimeGenres VALUES(1,16)
INSERT INTO AnimeGenres VALUES(1,18)
INSERT INTO AnimeGenres VALUES(1,28)
INSERT INTO AnimeGenres VALUES(2,16)
INSERT INTO AnimeGenres VALUES(2,35)
INSERT INTO AnimeGenres VALUES(2,43)
INSERT INTO AnimeGenres VALUES(2,33)
INSERT INTO AnimeGenres VALUES(3,16)
INSERT INTO AnimeGenres VALUES(3,9)
INSERT INTO AnimeGenres VALUES(3,40)
INSERT INTO AnimeGenres VALUES(3,10)
INSERT INTO AnimeGenres VALUES(4,2)
INSERT INTO AnimeGenres VALUES(4,16)
INSERT INTO AnimeGenres VALUES(4,10)
INSERT INTO AnimeGenres VALUES(5,2)
INSERT INTO AnimeGenres VALUES(5,11)
INSERT INTO AnimeGenres VALUES(5,40)
INSERT INTO AnimeGenres VALUES(5,15)
INSERT INTO AnimeGenres VALUES(5,22)
INSERT INTO AnimeGenres VALUES(6,4)
INSERT INTO AnimeGenres VALUES(6,11)
INSERT INTO AnimeGenres VALUES(6,12)
INSERT INTO AnimeGenres VALUES(6,16)
INSERT INTO AnimeGenres VALUES(6,22)
INSERT INTO AnimeGenres VALUES(7,12)
INSERT INTO AnimeGenres VALUES(7,16)
INSERT INTO AnimeGenres VALUES(7,18)
INSERT INTO AnimeGenres VALUES(7,9)
INSERT INTO AnimeGenres VALUES(8,2)
INSERT INTO AnimeGenres VALUES(8,23)
INSERT INTO AnimeGenres VALUES(8,30)
INSERT INTO AnimeGenres VALUES(8,35)
INSERT INTO AnimeGenres VALUES(8,43)
INSERT INTO AnimeGenres VALUES(8,33)
INSERT INTO AnimeGenres VALUES(9,11)
INSERT INTO AnimeGenres VALUES(9,8)
INSERT INTO AnimeGenres VALUES(9,35)
INSERT INTO AnimeGenres VALUES(9,40)
INSERT INTO AnimeGenres VALUES(9,31)
INSERT INTO AnimeGenres VALUES(9,39)
INSERT INTO AnimeGenres VALUES(10,2)
INSERT INTO AnimeGenres VALUES(10,30)
INSERT INTO AnimeGenres VALUES(10,40)
INSERT INTO AnimeGenres VALUES(10,43)
INSERT INTO AnimeGenres VALUES(10,32)
INSERT INTO AnimeGenres VALUES(10,33)
GO
INSERT INTO ListAnime VALUES(1,6,0.0,1)
INSERT INTO ListAnime VALUES(1,3,0.0,4)
INSERT INTO ListAnime VALUES(1,5,0.0,2)
INSERT INTO ListAnime VALUES(2,4,0.0,2)
INSERT INTO ListAnime VALUES(2,2,0.0,4)
INSERT INTO ListAnime VALUES(2,5,0.0,4)
INSERT INTO ListAnime VALUES(2,9,0.0,2)
INSERT INTO ListAnime VALUES(2,1,0.0,2)
INSERT INTO ListAnime VALUES(2,10,0.0,4)
INSERT INTO ListAnime VALUES(2,7,0.0,5)
INSERT INTO ListAnime VALUES(2,3,0.0,6)
GO
CREATE TRIGGER TriggerGenress
ON Anime
AFTER INSERT
AS
BEGIN
	declare @id int
	select @id = id_anime From inserted
	insert into AnimeGenres values(@id,1)
END
GO
CREATE PROC UserAnimeList (@id int)
AS
SELECT Anime.id_anime as 'id_anime', Anime.name_anime as 'name_anime',ListAnime.user_rated as 'rated' , Anime.episodes as 'episodes', Type.name_type as 'name_type', Status.name_status as 'name_status', ViewStatus.view_status as 'view_status'
FROM Anime
LEFT JOIN Type ON Anime.id_type=Type.id_type
LEFT JOIN Status ON Anime.id_status=Status.id_status
LEFT JOIN ListAnime ON Anime.id_anime=ListAnime.id_anime
LEFT JOIN Viewstatus ON ListAnime.id_viewstatus=Viewstatus.id_viewstatus
WHERE ListAnime.id_user=@id
GO
CREATE PROC GetId(@login_user NVARCHAR(50))
AS
BEGIN
	SELECT id_user 
    FROM Users
    WHERE login_user=@login_user
END
GO
CREATE PROC [dbo].[GetType](@login_user NVARCHAR(50))
AS
BEGIN
	SELECT id_type
    FROM Users
    WHERE login_user=@login_user
END
