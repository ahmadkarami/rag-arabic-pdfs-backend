--
-- PostgreSQL database dump
--

\restrict EVtOnXp4dZYbuYuaxBaPL6rMQ6JTNeiiz3lPVlOONhMHceKd4bgPx5dvzguqsE9

-- Dumped from database version 15.14 (Debian 15.14-1.pgdg13+1)
-- Dumped by pg_dump version 15.14 (Debian 15.14-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: hdb_catalog; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA hdb_catalog;


ALTER SCHEMA hdb_catalog OWNER TO postgres;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: gen_hasura_uuid(); Type: FUNCTION; Schema: hdb_catalog; Owner: postgres
--

CREATE FUNCTION hdb_catalog.gen_hasura_uuid() RETURNS uuid
    LANGUAGE sql
    AS $$select gen_random_uuid()$$;


ALTER FUNCTION hdb_catalog.gen_hasura_uuid() OWNER TO postgres;

--
-- Name: set_current_timestamp_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$;


ALTER FUNCTION public.set_current_timestamp_updated_at() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: hdb_action_log; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_action_log (
    id uuid DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    action_name text,
    input_payload jsonb NOT NULL,
    request_headers jsonb NOT NULL,
    session_variables jsonb NOT NULL,
    response_payload jsonb,
    errors jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    response_received_at timestamp with time zone,
    status text NOT NULL,
    CONSTRAINT hdb_action_log_status_check CHECK ((status = ANY (ARRAY['created'::text, 'processing'::text, 'completed'::text, 'error'::text])))
);


ALTER TABLE hdb_catalog.hdb_action_log OWNER TO postgres;

--
-- Name: hdb_cron_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_cron_event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.hdb_cron_event_invocation_logs OWNER TO postgres;

--
-- Name: hdb_cron_events; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_cron_events (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    trigger_name text NOT NULL,
    scheduled_time timestamp with time zone NOT NULL,
    status text DEFAULT 'scheduled'::text NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    next_retry_at timestamp with time zone,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['scheduled'::text, 'locked'::text, 'delivered'::text, 'error'::text, 'dead'::text])))
);


ALTER TABLE hdb_catalog.hdb_cron_events OWNER TO postgres;

--
-- Name: hdb_metadata; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_metadata (
    id integer NOT NULL,
    metadata json NOT NULL,
    resource_version integer DEFAULT 1 NOT NULL
);


ALTER TABLE hdb_catalog.hdb_metadata OWNER TO postgres;

--
-- Name: hdb_scheduled_event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_scheduled_event_invocation_logs (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.hdb_scheduled_event_invocation_logs OWNER TO postgres;

--
-- Name: hdb_scheduled_events; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_scheduled_events (
    id text DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    webhook_conf json NOT NULL,
    scheduled_time timestamp with time zone NOT NULL,
    retry_conf json,
    payload json,
    header_conf json,
    status text DEFAULT 'scheduled'::text NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    next_retry_at timestamp with time zone,
    comment text,
    CONSTRAINT valid_status CHECK ((status = ANY (ARRAY['scheduled'::text, 'locked'::text, 'delivered'::text, 'error'::text, 'dead'::text])))
);


ALTER TABLE hdb_catalog.hdb_scheduled_events OWNER TO postgres;

--
-- Name: hdb_schema_notifications; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_schema_notifications (
    id integer NOT NULL,
    notification json NOT NULL,
    resource_version integer DEFAULT 1 NOT NULL,
    instance_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT hdb_schema_notifications_id_check CHECK ((id = 1))
);


ALTER TABLE hdb_catalog.hdb_schema_notifications OWNER TO postgres;

--
-- Name: hdb_version; Type: TABLE; Schema: hdb_catalog; Owner: postgres
--

CREATE TABLE hdb_catalog.hdb_version (
    hasura_uuid uuid DEFAULT hdb_catalog.gen_hasura_uuid() NOT NULL,
    version text NOT NULL,
    upgraded_on timestamp with time zone NOT NULL,
    cli_state jsonb DEFAULT '{}'::jsonb NOT NULL,
    console_state jsonb DEFAULT '{}'::jsonb NOT NULL,
    ee_client_id text,
    ee_client_secret text
);


ALTER TABLE hdb_catalog.hdb_version OWNER TO postgres;

--
-- Name: conversations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conversations (
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    title character varying NOT NULL,
    chat_summary character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.conversations OWNER TO postgres;

--
-- Name: documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.documents (
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    title character varying NOT NULL,
    file_url character varying NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.documents OWNER TO postgres;

--
-- Name: documents_conversations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.documents_conversations (
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    document_id uuid NOT NULL,
    conversation_id uuid NOT NULL
);


ALTER TABLE public.documents_conversations OWNER TO postgres;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    content character varying NOT NULL,
    author character varying NOT NULL,
    user_id uuid NOT NULL,
    conversation_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- Name: registries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.registries (
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    surname character varying NOT NULL,
    phone character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.registries OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id text NOT NULL,
    comment text NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: states; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.states (
    id text NOT NULL,
    comment text NOT NULL
);


ALTER TABLE public.states OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying NOT NULL,
    password character varying NOT NULL,
    state text NOT NULL,
    role text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    registry_id uuid NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: hdb_action_log; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_action_log (id, action_name, input_payload, request_headers, session_variables, response_payload, errors, created_at, response_received_at, status) FROM stdin;
\.


--
-- Data for Name: hdb_cron_event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_cron_event_invocation_logs (id, event_id, status, request, response, created_at) FROM stdin;
\.


--
-- Data for Name: hdb_cron_events; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_cron_events (id, trigger_name, scheduled_time, status, tries, created_at, next_retry_at) FROM stdin;
\.


--
-- Data for Name: hdb_metadata; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_metadata (id, metadata, resource_version) FROM stdin;
1	{"actions":[{"definition":{"arguments":[{"name":"email","type":"String!"},{"name":"password","type":"String!"}],"handler":"{{HASURA_ACTION_BASE_URL}}/api/login","headers":[{"name":"x-auth-secret","value_from_env":"HEADER_SECRET"}],"kind":"synchronous","output_type":"LoginResponse","type":"mutation"},"name":"login"},{"definition":{"arguments":[{"name":"question","type":"String"},{"name":"conversation_id","type":"String"},{"name":"file_url","type":"String"}],"handler":"{{HASURA_ACTION_BASE_URL}}/api/generate-answer","headers":[{"name":"x-auth-secret","value_from_env":"HEADER_SECRET"}],"kind":"synchronous","output_type":"ragResponse","type":"mutation"},"name":"rag_service","permissions":[{"role":"guest"}]}],"custom_types":{"objects":[{"fields":[{"name":"token","type":"String!"}],"name":"LoginResponse"},{"fields":[{"name":"answer","type":"String!"},{"name":"conversation_id","type":"String!"}],"name":"ragResponse"}]},"sources":[{"configuration":{"connection_info":{"database_url":{"from_env":"HASURA_GRAPHQL_DATABASE_URL"},"isolation_level":"read-committed","pool_settings":{"connection_lifetime":600,"idle_timeout":180,"max_connections":50,"retries":1},"use_prepared_statements":true}},"kind":"postgres","name":"default","tables":[{"array_relationships":[{"name":"documents","using":{"foreign_key_constraint_on":{"column":"conversation_id","table":{"name":"documents_conversations","schema":"public"}}}},{"name":"messages","using":{"foreign_key_constraint_on":{"column":"conversation_id","table":{"name":"messages","schema":"public"}}}}],"table":{"name":"conversations","schema":"public"}},{"array_relationships":[{"name":"conversations","using":{"foreign_key_constraint_on":{"column":"document_id","table":{"name":"documents_conversations","schema":"public"}}}}],"object_relationships":[{"name":"user","using":{"foreign_key_constraint_on":"user_id"}}],"table":{"name":"documents","schema":"public"}},{"object_relationships":[{"name":"conversation","using":{"foreign_key_constraint_on":"conversation_id"}},{"name":"document","using":{"foreign_key_constraint_on":"document_id"}}],"table":{"name":"documents_conversations","schema":"public"}},{"object_relationships":[{"name":"conversation","using":{"foreign_key_constraint_on":"conversation_id"}},{"name":"user","using":{"foreign_key_constraint_on":"user_id"}}],"table":{"name":"messages","schema":"public"}},{"array_relationships":[{"name":"users","using":{"foreign_key_constraint_on":{"column":"registry_id","table":{"name":"users","schema":"public"}}}}],"table":{"name":"registries","schema":"public"}},{"is_enum":true,"table":{"name":"roles","schema":"public"}},{"is_enum":true,"table":{"name":"states","schema":"public"}},{"array_relationships":[{"name":"documents","using":{"foreign_key_constraint_on":{"column":"user_id","table":{"name":"documents","schema":"public"}}}},{"name":"messages","using":{"foreign_key_constraint_on":{"column":"user_id","table":{"name":"messages","schema":"public"}}}}],"object_relationships":[{"name":"registry","using":{"foreign_key_constraint_on":"registry_id"}}],"table":{"name":"users","schema":"public"}}]}],"version":3}	55
\.


--
-- Data for Name: hdb_scheduled_event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_scheduled_event_invocation_logs (id, event_id, status, request, response, created_at) FROM stdin;
\.


--
-- Data for Name: hdb_scheduled_events; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_scheduled_events (id, webhook_conf, scheduled_time, retry_conf, payload, header_conf, status, tries, created_at, next_retry_at, comment) FROM stdin;
\.


--
-- Data for Name: hdb_schema_notifications; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_schema_notifications (id, notification, resource_version, instance_id, updated_at) FROM stdin;
1	{"metadata":false,"remote_schemas":[],"sources":[],"data_connectors":[]}	55	5c6d710b-e0db-4cff-9cfc-365368d44fcc	2025-09-29 16:50:45.75599+00
\.


--
-- Data for Name: hdb_version; Type: TABLE DATA; Schema: hdb_catalog; Owner: postgres
--

COPY hdb_catalog.hdb_version (hasura_uuid, version, upgraded_on, cli_state, console_state, ee_client_id, ee_client_secret) FROM stdin;
50911b71-cf3e-45fb-99b3-49bc61d551b0	48	2025-09-29 16:36:54.166107+00	{}	{"onboardingShown": true, "console_notifications": {"admin": {"date": null, "read": [], "showBadge": true}}}	\N	\N
\.


--
-- Data for Name: conversations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.conversations (uuid, title, chat_summary, created_at, updated_at) FROM stdin;
727b011f-5c6a-485d-a17e-b431c0ab0059	New Chat	{}	2025-09-30 15:35:23.585618+00	2025-09-30 15:36:47.480256+00
\.


--
-- Data for Name: documents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.documents (uuid, title, file_url, user_id, created_at, updated_at) FROM stdin;
6bcaf8bc-f791-474c-9fdc-2a814cb1a86f	Tilte	test/sample_text.pdf	5580470c-b104-44d8-ad64-cc90458f93a9	2025-09-30 15:35:23.605806+00	2025-09-30 15:35:23.605806+00
\.


--
-- Data for Name: documents_conversations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.documents_conversations (uuid, document_id, conversation_id) FROM stdin;
a8458447-d5c4-479a-a154-c5a69193c18d	6bcaf8bc-f791-474c-9fdc-2a814cb1a86f	727b011f-5c6a-485d-a17e-b431c0ab0059
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messages (uuid, content, author, user_id, conversation_id, created_at, updated_at) FROM stdin;
9bde2133-2722-46e0-b170-b2ba7a393493	what does this document talk about	user	5580470c-b104-44d8-ad64-cc90458f93a9	727b011f-5c6a-485d-a17e-b431c0ab0059	2025-09-30 15:35:33.722871+00	2025-09-30 15:35:33.722871+00
d1f1b4a5-b97b-4adb-b339-0f596cd7a13e	المستند يتحدث عن "مدونة سلوك للعاملين في مجال العمل الإنساني والتنمية والسلام لمنع حدوث الاستغلال والاعتداء الجنسيين والحماية منهما في لبنان". يحتوي المستند على التزامات وتعهدات للعاملين في المنظمات الإنسانية بشأن احترام أعلى معايير السلوك المهني والشخصي، ويشدد على حظر الاستغلال والاعتداء الجنسيين، التحرش، استغلال السلطة، والفساد، مع التأكيد على ضرورة الإبلاغ عن أي انتهاكات محتملة. كما يوضح المستند تبعات الإخلال بمدونة السلوك، ومنها اتخاذ إجراءات تأديبية قد تصل إلى الصرف والملاحقة القانونية. ويشمل المستند تعريفات للاستغلال والاعتداء الجنسيين، وآليات للبلاغ الداخلي والتحقيق المستقل، وكذلك أهمية حماية الناجين من هذه الأفعال. ويتطلب المستند توقيع العامل تأكيدًا على فهمه والتزامه بهذه المبادئ والإجراءات.	system	5580470c-b104-44d8-ad64-cc90458f93a9	727b011f-5c6a-485d-a17e-b431c0ab0059	2025-09-30 15:35:33.750983+00	2025-09-30 15:35:33.750983+00
d448657c-70b7-40fb-a1bb-ed3826916f0b	what does this document talk about	user	5580470c-b104-44d8-ad64-cc90458f93a9	727b011f-5c6a-485d-a17e-b431c0ab0059	2025-09-30 15:36:47.515406+00	2025-09-30 15:36:47.515406+00
49c80c53-37a6-47f9-97b8-24f3142dcdec	المستند يتحدث عن "مدونة سلوك للعاملين في مجال العمل الإنساني والتنمية والسلام لمنع حدوث الاستغلال والاعتداء الجنسيين والحماية منهما في لبنان". يوضح المستند التزامات العاملين في المنظمات الإنسانية للحفاظ على أعلى معايير السلوك المهني والشخصي، ويشدد على ضرورة الإبلاغ عن أي مخالفة تتعلق بالتحرش أو الاستغلال أو الاعتداء الجنسي. كما يحتوي على تعريفات للاستغلال والاعتداء الجنسيين، ويحدد السياسات والإجراءات المتبعة لمنع هذه الأفعال، ويتناول تبعات الإخلال بهذه المدونة مثل اتخاذ تدابير تأديبية أو قانونية. كما يشدد المستند على أهمية حماية الناجين من الاستغلال والاعتداء، وضرورة وجود آليات تحقيق مستقلة، مع تأكيد على عدم قبول أي شكل من أشكال الفساد أو التمييز أو العلاقات التي تنطوي على إساءة استغلال السلطة. في نهاية المستند، يطلب من العاملين التوقيع تأكيداً على فهمهم والتزامهم بهذه المدونة.	system	5580470c-b104-44d8-ad64-cc90458f93a9	727b011f-5c6a-485d-a17e-b431c0ab0059	2025-09-30 15:36:47.52837+00	2025-09-30 15:36:47.52837+00
\.


--
-- Data for Name: registries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.registries (uuid, name, surname, phone, created_at, updated_at) FROM stdin;
49028945-f970-466d-bdc3-8333ed03c2f3	ahmad	karami	\N	2025-09-29 16:59:13.432758+00	2025-09-29 16:59:13.432758+00
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, comment) FROM stdin;
administrator	administrator
\.


--
-- Data for Name: states; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.states (id, comment) FROM stdin;
active	active
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (uuid, email, password, state, role, created_at, updated_at, registry_id) FROM stdin;
5580470c-b104-44d8-ad64-cc90458f93a9	ahmadkarami73@gmail.com	12341234	active	admin	2025-09-29 16:59:49.014353+00	2025-09-29 16:59:49.014353+00	49028945-f970-466d-bdc3-8333ed03c2f3
\.


--
-- Name: hdb_action_log hdb_action_log_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_action_log
    ADD CONSTRAINT hdb_action_log_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_event_invocation_logs
    ADD CONSTRAINT hdb_cron_event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: hdb_cron_events hdb_cron_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_events
    ADD CONSTRAINT hdb_cron_events_pkey PRIMARY KEY (id);


--
-- Name: hdb_metadata hdb_metadata_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_metadata
    ADD CONSTRAINT hdb_metadata_pkey PRIMARY KEY (id);


--
-- Name: hdb_metadata hdb_metadata_resource_version_key; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_metadata
    ADD CONSTRAINT hdb_metadata_resource_version_key UNIQUE (resource_version);


--
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_event_invocation_logs
    ADD CONSTRAINT hdb_scheduled_event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: hdb_scheduled_events hdb_scheduled_events_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_events
    ADD CONSTRAINT hdb_scheduled_events_pkey PRIMARY KEY (id);


--
-- Name: hdb_schema_notifications hdb_schema_notifications_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_schema_notifications
    ADD CONSTRAINT hdb_schema_notifications_pkey PRIMARY KEY (id);


--
-- Name: hdb_version hdb_version_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_version
    ADD CONSTRAINT hdb_version_pkey PRIMARY KEY (hasura_uuid);


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (uuid);


--
-- Name: documents_conversations documents_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents_conversations
    ADD CONSTRAINT documents_conversations_pkey PRIMARY KEY (uuid);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (uuid);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (uuid);


--
-- Name: registries registries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registries
    ADD CONSTRAINT registries_pkey PRIMARY KEY (uuid);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: states states_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (uuid);


--
-- Name: hdb_cron_event_invocation_event_id; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE INDEX hdb_cron_event_invocation_event_id ON hdb_catalog.hdb_cron_event_invocation_logs USING btree (event_id);


--
-- Name: hdb_cron_event_status; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE INDEX hdb_cron_event_status ON hdb_catalog.hdb_cron_events USING btree (status);


--
-- Name: hdb_cron_events_unique_scheduled; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE UNIQUE INDEX hdb_cron_events_unique_scheduled ON hdb_catalog.hdb_cron_events USING btree (trigger_name, scheduled_time) WHERE (status = 'scheduled'::text);


--
-- Name: hdb_scheduled_event_status; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE INDEX hdb_scheduled_event_status ON hdb_catalog.hdb_scheduled_events USING btree (status);


--
-- Name: hdb_version_one_row; Type: INDEX; Schema: hdb_catalog; Owner: postgres
--

CREATE UNIQUE INDEX hdb_version_one_row ON hdb_catalog.hdb_version USING btree (((version IS NOT NULL)));


--
-- Name: conversations set_public_conversations_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_public_conversations_updated_at BEFORE UPDATE ON public.conversations FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_conversations_updated_at ON conversations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TRIGGER set_public_conversations_updated_at ON public.conversations IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: documents set_public_documents_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_public_documents_updated_at BEFORE UPDATE ON public.documents FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_documents_updated_at ON documents; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TRIGGER set_public_documents_updated_at ON public.documents IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: messages set_public_messages_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_public_messages_updated_at BEFORE UPDATE ON public.messages FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_messages_updated_at ON messages; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TRIGGER set_public_messages_updated_at ON public.messages IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: registries set_public_registries_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_public_registries_updated_at BEFORE UPDATE ON public.registries FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_registries_updated_at ON registries; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TRIGGER set_public_registries_updated_at ON public.registries IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: users set_public_users_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_public_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_users_updated_at ON users; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TRIGGER set_public_users_updated_at ON public.users IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: hdb_cron_event_invocation_logs hdb_cron_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_cron_event_invocation_logs
    ADD CONSTRAINT hdb_cron_event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.hdb_cron_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hdb_scheduled_event_invocation_logs hdb_scheduled_event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: postgres
--

ALTER TABLE ONLY hdb_catalog.hdb_scheduled_event_invocation_logs
    ADD CONSTRAINT hdb_scheduled_event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.hdb_scheduled_events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documents_conversations documents_conversations_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents_conversations
    ADD CONSTRAINT documents_conversations_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(uuid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documents_conversations documents_conversations_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents_conversations
    ADD CONSTRAINT documents_conversations_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(uuid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documents documents_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(uuid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: messages messages_conversationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT "messages_conversationId_fkey" FOREIGN KEY (conversation_id) REFERENCES public.conversations(uuid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: messages messages_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT "messages_userId_fkey" FOREIGN KEY (user_id) REFERENCES public.users(uuid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users users_registry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_registry_id_fkey FOREIGN KEY (registry_id) REFERENCES public.registries(uuid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict EVtOnXp4dZYbuYuaxBaPL6rMQ6JTNeiiz3lPVlOONhMHceKd4bgPx5dvzguqsE9

