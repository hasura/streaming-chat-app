SET check_function_bodies = false;
CREATE TABLE public.channel_users (
    channel_id integer NOT NULL,
    user_id integer NOT NULL
);
CREATE TABLE public.messages (
    id integer NOT NULL,
    message text NOT NULL,
    author_id integer NOT NULL,
    channel_id integer NOT NULL
);
ALTER TABLE ONLY public.channel_users
    ADD CONSTRAINT channel_users_pkey PRIMARY KEY (channel_id, user_id);
ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);
