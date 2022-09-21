# streaming-chat-app

### Step 1: One-click deployment on Hasura Cloud

The fastest and easiest way to try Hasura out is via [Hasura Cloud](https://hasura.io/docs/latest/graphql/cloud/getting-started/index.html).

1. Click on the following button to deploy GraphQL engine on Hasura Cloud including Postgres add-on or using an existing Postgres database:

    [![Deploy to Hasura Cloud](https://graphql-engine-cdn.hasura.io/img/deploy_to_hasura.png)](https://cloud.hasura.io/signup)

2. Open the Hasura console

   Click on the button "Launch console" to open the Hasura console.

### Step 2: Apply migrations and metadata

Go to Run SQL in Console and execute the following:

```
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
```

Save the following in a file and then go to Import Metadata in Console:

```
{
  "metadata": {
    "version": 3,
    "sources": [
      {
        "name": "default",
        "kind": "postgres",
        "tables": [
          {
            "table": {
              "name": "channel_users",
              "schema": "public"
            }
          },
          {
            "table": {
              "name": "messages",
              "schema": "public"
            },
            "array_relationships": [
              {
                "name": "recipients",
                "using": {
                  "manual_configuration": {
                    "column_mapping": {
                      "channel_id": "channel_id"
                    },
                    "insertion_order": null,
                    "remote_table": {
                      "name": "channel_users",
                      "schema": "public"
                    }
                  }
                }
              }
            ],
            "select_permissions": [
              {
                "role": "user",
                "permission": {
                  "columns": [
                    "id",
                    "message",
                    "author_id",
                    "channel_id"
                  ],
                  "filter": {
                    "recipients": {
                      "user_id": {
                        "_eq": "X-Hasura-User-Id"
                      }
                    }
                  }
                }
              }
            ]
          }
        ],
        "configuration": {
          "connection_info": {
            "database_url": {
              "from_env": "PG_DATABASE_URL"
            },
            "isolation_level": "read-committed",
            "use_prepared_statements": false
          }
        }
      }
    ]
  }
}
```

### Step 3: Try streaming subscriptions

Insert a few rows in messages and channel_users, then try a streaming subscriptions:

```
subscription {
  messages_stream(cursor: {initial_value: {id: 0} }, batch_size: 5) {
    id
    message
    author_id
  }
}
```

