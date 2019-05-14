-- CREATE A DATABASE CALLED RQDB WITH OWNER TEAM AND RUN THE FOLLOWING:
-- REPLACE D:\Documents\Wo\Business Intelligence\Project\Data\Raw data\ BY LOCAL RAW DATA FOLDER 

CREATE TABLE public.countries
(
    country_id serial NOT NULL,
    country_name character varying NOT NULL,
    PRIMARY KEY (country_id)
)
WITH (
    OIDS = FALSE
);

ALTER TABLE public.countries
    OWNER to team;

INSERT INTO public.countries(country_name)
	VALUES ('The Netherlands'), ('United Kingdom'), ('China'),('Brazil'), ('United States');


-- INSERT WORLD UNIVERSITY DAT PT2

CREATE TABLE temp_universities_WORLD2(
	world_rank integer,
	university character varying,
	det integer, 
	presence_rank integer,
	impact_rank integer,
	openness_rank integer,
	excellence_rank integer
);

COPY temp_universities_WORLD2(world_rank, university, det, presence_rank,impact_rank,openness_rank,excellence_rank) 
FROM 'D:\Documents\Wo\Business Intelligence\Project\Data\Raw data\Ranking-WORLD-pt2.csv' DELIMITER ';' CSV HEADER;

CREATE TABLE public.universities
(
    id serial NOT NULL,
    university_name character varying NOT NULL,
    world_rank integer,
    presence_rank integer,
    impact_rank integer,
    openness_rank integer,
    excellence_rank integer,
    country integer,
    country_rank integer,
    CONSTRAINT universities_pkey PRIMARY KEY (id),
    CONSTRAINT universities_university_name_country_key UNIQUE (university_name, country)
,
    CONSTRAINT countries_fk FOREIGN KEY (country)
        REFERENCES public.countries (country_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.universities
    OWNER to team;

INSERT INTO universities(world_rank, university_name, presence_rank,impact_rank,openness_rank,excellence_rank)
	(SELECT world_rank, university, presence_rank, impact_rank, openness_rank, excellence_rank FROM public.temp_universities_WORLD2
	 WHERE
	 NOT EXISTS (
        SELECT A.university_name FROM public.universities as A WHERE A.university_name = university
    ));
	
DROP TABLE temp_universities_WORLD2;


-- Table: public.researchers

CREATE TABLE public.researchers
(
    researcher_id serial NOT NULL ,
    university integer,
    researcher_name character varying COLLATE pg_catalog."default" NOT NULL UNIQUE,
    citations integer,
    h_index integer,
    ranking integer,
	PRIMARY KEY (researcher_id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.researchers
    OWNER to team;


CREATE TABLE temp_researchers(
	ranking	integer,
	_name character varying,
	university character varying,
	citations integer,
	h_index integer
);

COPY temp_researchers(ranking, _name, university, citations, h_index) 
FROM 'D:\Documents\Wo\Business Intelligence\Project\Data\Raw data\Top1000Researchers.csv' DELIMITER ';' CSV HEADER;

INSERT INTO public.researchers(researcher_name, citations, h_index, ranking, university)
	(SELECT _name, citations, h_index, ranking, A.id as university FROM public.temp_researchers as B
	 INNER JOIN public.universities as A ON A.university_name = B.university);

	
DROP TABLE temp_researchers;


--CREATE PAPERS TABLE

CREATE TABLE public.papers
(
	paper_id serial NOT NULL,
	paper_rank integer,
	sourceid character varying,
	title character varying,
	paper_type character varying,
	issn character varying,
	sjr DOUBLE PRECISION,
	sjr_best_quartile  character varying,
	h_index	integer,
	total_docs_2017	integer,
	total_docs_3yrs integer,
	total_refs integer,
	total_cites_3yrs integer,
	citable_docs_3yrs integer,
	cites_2yrs DOUBLE PRECISION,
	refs DOUBLE PRECISION,
	country integer,
	publisher character varying,
	PRIMARY KEY (paper_id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.papers
    OWNER to team;


CREATE TABLE temp_papers(
	_rank integer,
	sourceid character varying, title character varying, _type character varying, 
	issn character varying, sjr DOUBLE PRECISION ,srjBQ character varying, h_index integer,
	total_docs integer,	total_docs_3yrs integer, total_refs integer,
	total_cites_3yrs integer, citable_docs integer, cites DOUBLE PRECISION,
	refs DOUBLE PRECISION, country character varying, publisher character varying, categories character varying);

COPY temp_papers(_rank, sourceid, title, _type, issn, sjr,srjBQ, h_index,	total_docs,	total_docs_3yrs, total_refs, total_cites_3yrs, citable_docs, cites,	refs, country, publisher, categories) 
FROM 'D:\Documents\Wo\Business Intelligence\Project\Data\Raw data\scimagojr 2017 ALL.csv' DELIMITER ';' CSV HEADER;


-- INSERT ALL UNKNOWN COUNTRIES

INSERT INTO countries (country_name) 
	(SELECT DISTINCT country FROM temp_papers
	WHERE NOT EXISTS(SELECT country_name
                    FROM countries t2
                   WHERE t2.country_name = country ) AND country is not NULL) ;


--INSERT PAPERS

INSERT INTO public.papers(paper_rank, sourceid, title, paper_type, issn, sjr, 
						  sjr_best_quartile, h_index, total_docs_2017, total_docs_3yrs, 
						  total_refs, total_cites_3yrs, citable_docs_3yrs, cites_2yrs, 
						  refs, publisher, country)
	(SELECT _rank, sourceid, title, _type, issn, sjr, srjBQ, h_index,
	total_docs,	total_docs_3yrs, total_refs,
	total_cites_3yrs, citable_docs, cites, refs, publisher, c.country_id FROM temp_papers tp
	INNER JOIN countries as c ON c.country_name = tp.country);


CREATE TABLE research_areas(
	research_area_id serial NOT NULL,
	research_area_name character varying NOT NULL,
	PRIMARY KEY(research_area_id)
);	


ALTER TABLE research_areas
    OWNER to team;

--INSERT RESEARCH AREAS

INSERT INTO research_areas(research_area_name)
SELECT DISTINCT regexp_split_to_table(categories, E'; ')
FROM temp_papers 
WHERE NOT EXISTS (SELECT research_area_name FROM research_areas);


--CREATE COMBINATION TABLE (MANY-TO-MANY RELATION)

CREATE TABLE public.papers_research_areas
(
    paper_id integer NOT NULL,
    research_area_id integer NOT NULL,
    PRIMARY KEY (paper_id, research_area_id),
    CONSTRAINT research_area_id_fk FOREIGN KEY (research_area_id)
        REFERENCES public.research_areas (research_area_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT paper_id_fk FOREIGN KEY (paper_id)
        REFERENCES public.papers (paper_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
);

ALTER TABLE public.papers_research_areas
    OWNER to team;


--INSERT MANY-TO-MANY DATA research/papers

INSERT INTO papers_research_areas(paper_id, research_area_id)
	SELECT paper_id, research_area_id from temp_papers
	INNER JOIN research_areas ON (research_areas.research_area_name = ANY(regexp_split_to_array(categories, E'; ')))
	INNER JOIN papers ON papers.sourceid = temp_papers.sourceid ;


DROP TABLE temp_papers;


--TODO LOOK AT/DO DIFFERENTLY
--CREATE TABLE research_funding_countries(
-- country integer,
-- indicator_name character varying,
-- y1960 DOUBLE PRECISION,	
-- y1961 DOUBLE PRECISION,	
-- y1962 DOUBLE PRECISION,
-- y1963 DOUBLE PRECISION,
-- y1964 DOUBLE PRECISION,
-- y1965 DOUBLE PRECISION,
-- y1966 DOUBLE PRECISION,
-- y1967 DOUBLE PRECISION,
-- y1968 DOUBLE PRECISION,
-- y1969 DOUBLE PRECISION,
-- y1970 DOUBLE PRECISION,	
-- y1971 DOUBLE PRECISION,
-- y1972 DOUBLE PRECISION,
-- y1973 DOUBLE PRECISION,
-- y1974 DOUBLE PRECISION,	
-- y1975 DOUBLE PRECISION,	
-- y1976 DOUBLE PRECISION,
-- y1977 DOUBLE PRECISION,
-- y1978 DOUBLE PRECISION,	
-- y1979 DOUBLE PRECISION,	
-- y1980 DOUBLE PRECISION,
-- y1981 DOUBLE PRECISION,
-- y1982 DOUBLE PRECISION,
-- y1983 DOUBLE PRECISION,
-- y1984 DOUBLE PRECISION,
-- y1985 DOUBLE PRECISION,
-- y1986 DOUBLE PRECISION,
-- y1987 DOUBLE PRECISION,
-- y1988 DOUBLE PRECISION,
-- y1989 DOUBLE PRECISION,
-- y1990 DOUBLE PRECISION,	
-- y1991 DOUBLE PRECISION,
-- y1992 DOUBLE PRECISION,	
-- y1993 DOUBLE PRECISION,
-- y1994 DOUBLE PRECISION,
-- y1995 DOUBLE PRECISION,
-- y1996 DOUBLE PRECISION,
-- y1997 DOUBLE PRECISION,
-- y1998 DOUBLE PRECISION,
-- y1999 DOUBLE PRECISION,
-- y2000 DOUBLE PRECISION,	
-- y2001 DOUBLE PRECISION,
-- y2002 DOUBLE PRECISION,
-- y2003 DOUBLE PRECISION,
-- y2004 DOUBLE PRECISION,
-- y2005 DOUBLE PRECISION,
-- y2006 DOUBLE PRECISION,
-- y2007 DOUBLE PRECISION,	
-- y2008 DOUBLE PRECISION,
-- y2009 DOUBLE PRECISION,
-- y2010 DOUBLE PRECISION,
-- y2011 DOUBLE PRECISION,
-- y2012 DOUBLE PRECISION,	
-- y2013 DOUBLE PRECISION,
-- y2014 DOUBLE PRECISION,
-- y2015 DOUBLE PRECISION,	
-- y2016 DOUBLE PRECISION,
-- y2017 DOUBLE PRECISION,
-- y2018 DOUBLE PRECISION);

-- CREATE TABLE research_funding_countries_temp(
-- country character varying,
-- country_code character varying,
-- indicator_name character varying,
-- indicator_code character varying,
-- y1960 DOUBLE PRECISION,	
-- y1961 DOUBLE PRECISION,	
-- y1962 DOUBLE PRECISION,
-- y1963 DOUBLE PRECISION,
-- y1964 DOUBLE PRECISION,
-- y1965 DOUBLE PRECISION,
-- y1966 DOUBLE PRECISION,
-- y1967 DOUBLE PRECISION,
-- y1968 DOUBLE PRECISION,
-- y1969 DOUBLE PRECISION,
-- y1970 DOUBLE PRECISION,	
-- y1971 DOUBLE PRECISION,
-- y1972 DOUBLE PRECISION,
-- y1973 DOUBLE PRECISION,
-- y1974 DOUBLE PRECISION,	
-- y1975 DOUBLE PRECISION,	
-- y1976 DOUBLE PRECISION,
-- y1977 DOUBLE PRECISION,
-- y1978 DOUBLE PRECISION,	
-- y1979 DOUBLE PRECISION,	
-- y1980 DOUBLE PRECISION,
-- y1981 DOUBLE PRECISION,
-- y1982 DOUBLE PRECISION,
-- y1983 DOUBLE PRECISION,
-- y1984 DOUBLE PRECISION,
-- y1985 DOUBLE PRECISION,
-- y1986 DOUBLE PRECISION,
-- y1987 DOUBLE PRECISION,
-- y1988 DOUBLE PRECISION,
-- y1989 DOUBLE PRECISION,
-- y1990 DOUBLE PRECISION,	
-- y1991 DOUBLE PRECISION,
-- y1992 DOUBLE PRECISION,	
-- y1993 DOUBLE PRECISION,
-- y1994 DOUBLE PRECISION,
-- y1995 DOUBLE PRECISION,
-- y1996 DOUBLE PRECISION,
-- y1997 DOUBLE PRECISION,
-- y1998 DOUBLE PRECISION,
-- y1999 DOUBLE PRECISION,
-- y2000 DOUBLE PRECISION,	
-- y2001 DOUBLE PRECISION,
-- y2002 DOUBLE PRECISION,
-- y2003 DOUBLE PRECISION,
-- y2004 DOUBLE PRECISION,
-- y2005 DOUBLE PRECISION,
-- y2006 DOUBLE PRECISION,
-- y2007 DOUBLE PRECISION,	
-- y2008 DOUBLE PRECISION,
-- y2009 DOUBLE PRECISION,
-- y2010 DOUBLE PRECISION,
-- y2011 DOUBLE PRECISION,
-- y2012 DOUBLE PRECISION,	
-- y2013 DOUBLE PRECISION,
-- y2014 DOUBLE PRECISION,
-- y2015 DOUBLE PRECISION,	
-- y2016 DOUBLE PRECISION,
-- y2017 DOUBLE PRECISION,
-- y2018 DOUBLE PRECISION);


-- COPY research_funding_countries_temp(country, country_code, indicator_name,	indicator_code,	y1960,	y1961,	y1962,	y1963,	y1964,	y1965,	y1966,	y1967,	y1968,	y1969,	y1970,	y1971,	y1972,	y1973,	y1974,	y1975,	y1976,	y1977,	y1978,	y1979,	y1980,	y1981,	y1982,	y1983,	y1984,	y1985,	y1986,	y1987,	y1988,	y1989,	y1990,	y1991,	y1992,	y1993,	y1994,	y1995,	y1996,	y1997,	y1998,	y1999,	y2000,	y2001,	y2002,	y2003,	y2004,	y2005,	y2006,	y2007,	y2008,	y2009,	y2010,	y2011,	y2012,	y2013, y2014, y2015,	y2016,	y2017, y2018)
-- FROM 'D:\Documents\Wo\Business Intelligence\Project\Data\Raw data\research_funding_data.csv' DELIMITER ';' CSV HEADER;



