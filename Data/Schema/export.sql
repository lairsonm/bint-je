--
-- PostgreSQL database dump
--

-- Dumped from database version 11.2
-- Dumped by pg_dump version 11.2

-- Started on 2019-04-25 18:38:32

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET default_with_oids = false;

--
-- TOC entry 196 (class 1259 OID 16396)
-- Name: TestTable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TestTable" (
    "Firstname" character varying(25),
    "Name" character varying(50),
    "Id" integer NOT NULL
);


--
-- TOC entry 197 (class 1259 OID 16399)
-- Name: TestTable_Id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."TestTable_Id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2825 (class 0 OID 0)
-- Dependencies: 197
-- Name: TestTable_Id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."TestTable_Id_seq" OWNED BY public."TestTable"."Id";


--
-- TOC entry 2694 (class 2604 OID 16401)
-- Name: TestTable Id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TestTable" ALTER COLUMN "Id" SET DEFAULT nextval('public."TestTable_Id_seq"'::regclass);


--
-- TOC entry 2818 (class 0 OID 16396)
-- Dependencies: 196
-- Data for Name: TestTable; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."TestTable" VALUES ('Business', 'Intelligence', 1);
INSERT INTO public."TestTable" VALUES ('Business', 'Intelligence', 2);
INSERT INTO public."TestTable" VALUES ('Business', 'Intelligence', 3);
INSERT INTO public."TestTable" VALUES ('Business', 'Intelligence', 4);
INSERT INTO public."TestTable" VALUES ('Data', 'Science', 5);
INSERT INTO public."TestTable" VALUES ('Organization', 'Information', 6);
INSERT INTO public."TestTable" VALUES ('Optimization', 'Problem', 7);
INSERT INTO public."TestTable" VALUES ('Operation', 'Research', 8);
INSERT INTO public."TestTable" VALUES ('Business', 'Intelligence', 9);
INSERT INTO public."TestTable" VALUES ('Business', 'Intelligence', 10);
INSERT INTO public."TestTable" VALUES ('Data', 'Science', 11);
INSERT INTO public."TestTable" VALUES ('Organization', 'Information', 12);
INSERT INTO public."TestTable" VALUES ('Optimization', 'Problem', 13);
INSERT INTO public."TestTable" VALUES ('Operation', 'Research', 14);
INSERT INTO public."TestTable" VALUES ('Business', 'Intelligence', 15);
INSERT INTO public."TestTable" VALUES ('Business', 'Intelligence', 16);
INSERT INTO public."TestTable" VALUES ('Data', 'Science', 17);
INSERT INTO public."TestTable" VALUES ('Organization', 'Information', 18);
INSERT INTO public."TestTable" VALUES ('Optimization', 'Problem', 19);
INSERT INTO public."TestTable" VALUES ('Operation', 'Research', 20);
INSERT INTO public."TestTable" VALUES ('Business', 'Intelligence', 21);
INSERT INTO public."TestTable" VALUES ('Business', 'Intelligence', 22);
INSERT INTO public."TestTable" VALUES ('Data', 'Science', 23);
INSERT INTO public."TestTable" VALUES ('Organization', 'Information', 24);
INSERT INTO public."TestTable" VALUES ('Optimization', 'Problem', 25);
INSERT INTO public."TestTable" VALUES ('Operation', 'Research', 26);


--
-- TOC entry 2826 (class 0 OID 0)
-- Dependencies: 197
-- Name: TestTable_Id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."TestTable_Id_seq"', 26, true);


--
-- TOC entry 2696 (class 2606 OID 16403)
-- Name: TestTable TestTable_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TestTable"
    ADD CONSTRAINT "TestTable_pkey" PRIMARY KEY ("Id");


-- Completed on 2019-04-25 18:38:32

--
-- PostgreSQL database dump complete
--

