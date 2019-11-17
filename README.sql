-- # test_repo
-- My first attempt

-- Hello, world!

-- Мои приветствия!

-- МК

-- Домашняя работа №1. Вариант 1. Кредитные рейтинги
-- Пункт 1.
-- Создание таблицы ratings_tasks. Команда создает пустую таблицу с необходимыми столбцами и их форматами. В созданную таблицу необходимо дальнейшее импортирование данных из csv файла rating_task. Перед загрузкой в файле с данными необходимо изменить формат столбца с датами из числового в формат даты.
DROP TABLE IF EXISTS public.ratings_task;

CREATE TABLE public.ratings_task
(
	"rat_id" integer NOT NULL,
	"grade" text COLLATE pg_catalog."default" NOT NULL,
	"outlook" text COLLATE pg_catalog."default",
	"change" text COLLATE pg_catalog."default" NOT NULL,
	"data" date,
	"ent_name" text COLLATE pg_catalog."default" NOT NULL,
	"okpo" bigint NOT NULL,
	"ogrn" bigint,
	"inn" bigint,
	"finst" integer,
	"agency_id" text COLLATE pg_catalog."default",
	"rat_industry" text COLLATE pg_catalog."default",
	"rat_type" text COLLATE pg_catalog."default" NOT NULL,
	"horizon" text COLLATE pg_catalog."default",
	"scale_typer" text COLLATE pg_catalog."default",
	"currency" text COLLATE pg_catalog."default",
	"backed_flag" text COLLATE pg_catalog."default"
)

TABLESPACE pg_default;

ALTER TABLE public.ratings_task
    OWNER to postgres;

-- Создание таблицы credit_events_tasks. Команда создает пустую таблицу с необходимыми столбцами и их форматами. В созданную таблицу необходимо дальнейшее импортирование данных из csv файла credit_events_task. Ни один из столбцов не может выступать в качестве первичного ключа, поскольку имеют повторяющиеся, либо пустые значения.
DROP TABLE IF EXISTS public.credit_events_task;

CREATE TABLE public.credit_events_task
(
	"inn" bigint NOT NULL,
	"date" date NOT NULL,
	"event" text COLLATE pg_catalog."default" NOT NULL
)

TABLESPACE pg_default;

ALTER TABLE public.credit_events_task
    OWNER to postgres;  

-- Создание таблицы scale_EXP_task. Команда создает пустую таблицу с необходимыми столбцами и их форматами. В созданную таблицу необходимо дальнейшее импортирование данных из csv файла scale_EXP_task. В качестве первичного ключа выбран столбец grade_id, поскольку он не имеет повторяющихся и пустых значений.
DROP TABLE IF EXISTS public.scale_EXP_task;

CREATE TABLE public.scale_EXP_task
(
	"grade" text COLLATE pg_catalog."default" NOT NULL,
	"grade_id" integer NOT NULL,
	CONSTRAINT scale_EXP_task_pkey PRIMARY KEY ("grade_id")
)
)
WITH (
    OIDS = FALSE    
TABLESPACE pg_default;

ALTER TABLE public.scale_EXP_task
    OWNER to postgres; 
    
    
-- Пункт 2 и 3.
-- Создание новой таблицы ratings_data для выноса информации о рейтингах из таблицы ratings_task. Команда создает пустую таблицу с необходимыми столбцами и их форматами.
CREATE TABLE public.ratings_data
(
  "NO" bigint NOT NULL,
  "rat_industry" text COLLATE pg_catalog."default",
  "rat_type" text COLLATE pg_catalog."default" NOT NULL,
  "horizon" text COLLATE pg_catalog."default",
  "scale_typer" text COLLATE pg_catalog."default",
  "currency" text COLLATE pg_catalog."default",
  "backed_flag" text COLLATE pg_catalog."default",
  CONSTRAINT ratings_data_pkey PRIMARY KEY ("no_")
)
WITH (
OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.ratings_data
OWNER to postgres;

-- Команда исполняет запрос и копирование информации из исходной таблицы ratings_task в новую ratings_data
INSERT INTO ratings_data SELECT count(*) over (order by "agency_id", "rat_industry", "rat_type", "horizon", "scale_typer", "currency", "backed_flag") as NO, 
"agency_id", "rat_industry", "rat_type", "horizon", "scale_typer", "currency", "backed_flag"
FROM  (select distinct "agency_id", "rat_industry", "rat_type", "horizon", "scale_typer", "currency", "backed_flag"
FROM ratings_task)
as my_select;

-- Команда добавляет в исходную таблицу ratings_task поле с кодами-ссылками на новую таблицу ratings_data
ALTER TABLE ratings_task add column "NO" bigint;

-- Команда заполняет поле NO в исходной таблице ratings_task с кодами-ссылками на новую таблицу ratings_data
UPDATE ratings_task
SET NO=ratings_data.NO
FROM ratings_data
WHERE ratings_task."agency_id"=ratings_data."agency_id";

-- Команда присваивает полю NO ограничение внешнего ключа
ALTER TABLE public.ratings_task 
ADD CONSTRAINT fr_key_1 FOREIGN KEY (NO) REFERENCES public.ratings_data (NO);

-- Команда удаляет вынесенную информацию из исходной таблицы ratings_task
ALTER TABLE public.ratings_task
DROP COLUMN IF EXISTS "rat_industry",
DROP COLUMN IF EXISTS "rat_type",
DROP COLUMN IF EXISTS "horizon",
DROP COLUMN IF EXISTS "scale_typer",
DROP COLUMN IF EXISTS "currency",
DROP COLUMN IF EXISTS "backed_flag";

-- Создание новой таблицы ent_info для выноса информации о рейтингуемом лице из таблицы ratings_task. Команда создает пустую таблицу с необходимыми столбцами и их форматами.
CREATE TABLE public.ent_info
(
  "ent_id" bigint NOT NULL,
  "ent_name" text COLLATE pg_catalog."default" NOT NULL,
  "okpo" bigint NOT NULL,
  "ogrn" bigint,
  "inn" bigint,
  "finst" integer,
  CONSTRAINT ent_info_pkey PRIMARY KEY ("ent_id")
)
WITH (
OIDS = FALSE
)
TABLESPACE pg_default;
ALTER TABLE public.ent_info
OWNER to postgres;

-- Команда исполняет запрос и копирование информации из исходной таблицы ratings_task в новую ent_info
INSERT INTO ent_info SELECT count(*) ooer (order by "ent_name", "okpo", "ogrn", "inn", "finst") as ent_id,
"ent_name", "okpo", "ogrn", "inn", "finst"
FROM (select distinct "ent_name", "okpo", "ogrn", "inn", "finst"
FROM ratings_task)
as my_second_select;

-- Команда добавляет в исходную таблицу ratings_task поле с кодами-ссылками на новую таблицу ent_info
ALTER TABLE ratings_task add column "ent_id" bigint;

-- Команда заполняет поле ent_id в исходной таблице ratings_task с кодами-ссылками на новую таблицу ent_info
UPDATE ratings_task
SET ent_id=ent_info.ent_id
FROM ent_info
WHERE ratings_task."ent_name"=ent_info."ent_name";

-- Команда присваивает полю ent_id ограничение внешнего ключа
ALTER TABLE public.ratings_task 
ADD CONSTRAINT fr_key_1 FOREIGN KEY (ent_id) REFERENCES public.ent_info (ent_id);

-- Команда удаляет вынесенную информацию из исходной таблицы ratings_task
ALTER TABLE public.ratings_task
DROP COLUMN IF EXISTS "ent_name",
DROP COLUMN IF EXISTS "okpo",
DROP COLUMN IF EXISTS "ogrn",
DROP COLUMN IF EXISTS "inn",
DROP COLUMN IF EXISTS "finst";

# Пункт 4.
-- Команда не получилась 
