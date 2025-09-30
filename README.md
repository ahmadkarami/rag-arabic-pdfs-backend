# Backend (Node.js + Hasura + Postgres)

This backend integrates **Node.js**, **Hasura**, **Postgres** for managing conversations, documents, and messages with contextual AI-powered responses.

---

## Development Setup

### Start the RAG Service
The RAG service must be running **before anything else**.

---

### Start Postgres + Hasura

```bash
docker-compose -f docker-compose.dev.yml up -d
```

- **Postgres** → `localhost:5433`  
- **Hasura** → `http://localhost:8088/v1/graphql`

---

### Restore Database

From the project root, restore the latest backup into Postgres:

```bash
./restore.sh backup.sql
```

---

### Import Hasura Metadata

Go to http://localhost:8088/console and login with HASURA_GRAPHQL_ADMIN_SECRET in the .env and import metadata

---

### Install Node.js Dependencies

In the backend project root:

```bash
npm install
```

---

### Start Node Backend

```bash
npm run dev
```

Backend runs at:  
👉 `http://localhost:3000`

---

## Authentication

Before sending requests, login to get a JWT:

```graphql
mutation login {
  login(email: "YOUR_EMAIL", password: "YOUR_PASSWORD") {
    token
  }
}
```

Use the token in all subsequent requests:

```
Authorization: Bearer <jwt_token>
```

---

## Workflow – Conversations & RAG Service

### First Request (no conversation yet)

Creates a new conversation, saves the first message, and returns `conversation_id`:

```graphql
mutation MyMutation {
  rag_service(
    question: "what does this document talk about",
    file_url: "test/sample_text.pdf"
  ) {
    answer
    conversation_id
  }
}
```

### Subsequent Requests (with conversation)

Pass the existing `conversation_id` to append messages:

```graphql
mutation MyMutation {
  rag_service(
    question: "what does this document talk about",
    file_url: "test/sample_text.pdf",
    conversation_id: "727b011f-5c6a-485d-a17e-b431c0ab0059"
  ) {
    answer
    conversation_id
  }
}
```

---

## Database Schema

The system uses **8 tables**:

- `conversations`  
- `documents`  
- `documents_conversations`  
- `messages`  
- `registries`  
- `roles`  
- `states`  
- `users`  

**Flow:**
- First request → creates a `conversation` + first `message`.  
- Later requests → append messages to that conversation.  

---
