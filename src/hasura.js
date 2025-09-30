import { ApolloClient, InMemoryCache, HttpLink, gql } from "@apollo/client/core";
import fetch from "cross-fetch";
import "dotenv/config";

import dotenv from "dotenv";
import dotenvExpand from "dotenv-expand";

const env = dotenv.config();
dotenvExpand.expand(env);

const HASURA_URL = process.env.HASURA_URL;
const HASURA_ADMIN_SECRET = process.env.HASURA_GRAPHQL_ADMIN_SECRET;

export const client = new ApolloClient({
  link: new HttpLink({
    uri: HASURA_URL,
    fetch,
    headers: {
      "x-hasura-admin-secret": HASURA_ADMIN_SECRET,
      "content-type": "application/json"
    },
  }),
  cache: new InMemoryCache(),
});

// Export gql so you can use it in routes
export { gql };