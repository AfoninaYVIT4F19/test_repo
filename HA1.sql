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
 
 -- Комментарий:
 -- Копирование данных из файлов нужно прописывать кодом.   
 
 -- Исправление после комментария.
 -- Команда позволяет скопировать данные из файла ratings_task.csv (предваритено перевести файл из формата xlsx в cvs) в созданную таблицу ratings_tasks.
 \copy ratings_tasks FROM 'D:/IT/rating_tasks.csv' DELIMITER ',' CSV HEADER;
 
 -- Команда позволяет скопировать данные из файла credit_events_task.csv (предваритено перевести файл из формата xls в cvs) в созданную таблицу credit_events_task.
  \copy credit_events_task FROM 'D:/IT/credit_events_task.csv' DELIMITER ',' CSV HEADER;
  
 -- Команда позволяет скопировать данные из файла scale_EXP_task.csv в созданную таблицу scale_EXP_task.
   \copy scale_EXP_task FROM 'D:/IT/scale_EXP_task.csv' DELIMITER ',' CSV HEADER;
   
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

-- Комментарий:
-- Следует также установить связи с таблицами credit_events_task и scale_EXP_task.

 -- Исправление после комментария.
 -- Команда добавляет в исходную таблицу ratings_task поле с кодами-ссылками на таблицу scale_EXP_task.
ALTER TABLE ratings_task add column "grade_id" bigint;

-- Команда заполняет поле grade_id в исходной таблице ratings_task с кодами-ссылками на таблицу scale_EXP_task
UPDATE ratings_task
SET grade_id=scale_EXP_task.grade_id
FROM scale_EXP_task
WHERE ratings_task."grade"=scale_EXP_task."grade";

-- Команда присваивает полю grade_id ограничение внешнего ключа
ALTER TABLE public.ratings_task 
ADD CONSTRAINT fr_key_2 FOREIGN KEY (grade_id) REFERENCES public.scale_EXP_task (grade_id);

-- Комментарий:
-- Не самое лучше по смыслу решение.

-- Команда добавляет в исходную таблицу credit_events_task поле с кодами-ссылками на таблицу ent_info
ALTER TABLE credit_events_task add column "ent_id" bigint;

-- Команда заполняет поле ent_id в исходной таблице credit_events_task с кодами-ссылками на таблицу ent_info
UPDATE credit_events_task
SET ent_id=ent_info.ent_id
FROM ent_info
WHERE credit_events_task."inn"=ent_info."inn";

-- Команда присваивает полю grade_id ограничение внешнего ключа
ALTER TABLE public.credit_events_task
ADD CONSTRAINT fr_key_3 FOREIGN KEY (ent_id) REFERENCES public.ent_ifo (ent_id);
 
# Пункт 4.
-- Команда не получилась 

-- Комментарий:
-- Попробуйте еще раз.

-- Исправление после комментария.
-- Команда выводит актуальные рейтинги для вида рейнга "27" на дату 26.03.2014 путем создания двух промежуточных таблиц firdt_table и second_table.
SELECT ent_id, assign_date, public.ratings_task."grade", public.ent_info."ent_name" 
FROM (SELECT ent_name, max("date") as assign_date
FROM public.ent_info INNER JOIN
	(SELECT *
	FROM public.ratings_task INNER JOIN public.ratings_data
	ON public.ratings_task.NO=public.ratings_data.NO
	WHERE "rat_id=27" AND "date" <= '26.03.2014' AND change NOT IN ('снят', 'приостановлен') as first_table
	ON public.ent_info.ent_id=first_table.ent_id
GROUP BY ent_name) as second_table
INNER JOIN public.ent_info ON second_name.ent_name=public.ent_info.ent_name;

-- Комментарий:
-- Неверно. Для компаний с отозванными рейтингами запрос вернет значения рейтингов, предшествовавшие отзывам.
