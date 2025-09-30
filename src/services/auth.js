import jwt from "jsonwebtoken";
import { client, gql } from "../hasura.js";

export async function loginUser(email, password) {

    console.log("---->>>> Start loginUser");

  // 1. Fetch user from Hasura
  const QUERY = gql`
    query ($email: String!) {
      users(where: { email: { _eq: $email } }) {
        uuid
        email
        password
        role
        registry {
          name
          phone
          surname
        }
      }
    }
  `;

  const { data } = await client.query({ query: QUERY, variables: { email } });
  const user = data?.users?.[0];

  if (!user) {
    throw new Error("User not found");
  }
  if (user.password !== password) {
    throw new Error("Invalid credentials");
  }

  // 2. Generate JWT with your namespace
  const token = jwt.sign(
    {
      sub: user.uuid,
      [process.env.HASURA_CLAIMS_NAMESPACE]: {
        "x-hasura-allowed-roles": [user.role],
        "x-hasura-default-role": user.role,
        "x-hasura-user-id": user.uuid,
        "name": user.registry.name,
        "phone": user.registry.phone,
        "surname": user.registry.surname,
        "email": user.email,
      },
    },
    process.env.JWT_PRIVATE_KEY,
    { algorithm: process.env.JWT_KEY_ALGO, expiresIn: process.env.JWT_LIFE_WEB || "1h" }
  );

    console.log("---->>>> End loginUser");
  return {
    token,
    user_id: user.uuid,
    role: user.role,
  };
}