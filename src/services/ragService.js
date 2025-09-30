import fetch from "node-fetch";
import AbortController from "abort-controller";
import { client, gql } from "../hasura.js";

export async function generateAnswer(payload) {
  try {

    console.log("---->>>> Start generateAnswer");
    
     const controller = new AbortController();
     const timeout = setTimeout(() => controller.abort(), 60000);

    const response = await fetch(process.env.RAG_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
      signal: controller.signal,
    });

     clearTimeout(timeout);

    if (!response.ok) {
      throw new Error(`RAG service error: ${response.statusText}`);
    }
    const result = await response.json();


    console.log("---->>>> End generateAnswer");
    return result;
  } catch (err) {
    console.error("❌ RAG service call failed:", err);
    throw err;
  }
}

export async function createConversation() {
  try {

    console.log("---->>>> Start createConversation");
    const MUTATION = gql`
      mutation CreateConversation($chat_summary: String!, $title: String!) {
        insert_conversations_one(object: { chat_summary: $chat_summary, title: $title }) {
          uuid
        }
      }
    `;

    const { data } = await client.mutate({
      mutation: MUTATION,
      variables: {
        chat_summary: "{}",
        title: "New Chat",
      },
    });

    const conv = data?.insert_conversations_one?.uuid;

    if (!conv) {
      throw new Error("Conversation not created");
    }


    console.log("---->>>> End createConversation");
    return conv;

  } catch (err) {
    console.error("❌ createConversation error:", err);
    throw err;
  }
}

export async function fetchFileUrl(conversation_id){

    console.log("---->>>> Start fetchFileUrl");

    const QUERY = gql`
    query getFileUrl($conversation_id: uuid!) {
        documents(where: {conversations: {conversation_id: {_eq: $conversation_id}}}) {
            file_url
        }
    }
    `;

    const { data } = await client.query({
      query: QUERY,
      variables: {
        conversation_id: conversation_id,
      },
    });

    const file_url = data?.documents[0]?.file_url;

    console.log("---->>>> End fetchFileUrl");
    return file_url;
}

export async function createDocument(title, file_url, user_id, conversation_id) {
  try {

    console.log("---->>>> Start createDocument");
    const MUTATION = gql`
      mutation InsertDocumentAndConversation(
        $file_url: String!
        $title: String!
        $user_id: uuid!
        $conversation_id: uuid!
        ) {
        insert_documents_one(
            object: {
            file_url: $file_url
            title: $title
            user_id: $user_id
            conversations: {
                data: {
                conversation_id: $conversation_id
                    }
                }
            }
        ) {
            uuid
        }
        }
    `;

    const { data } = await client.mutate({
      mutation: MUTATION,
      variables: {
        file_url: file_url,
        title: title,
        user_id: user_id,
        conversation_id: conversation_id
      },
    });

    const doc = data?.insert_documents_one?.uuid;

    if (!doc) {
      throw new Error("Conversation not created");
    }


    console.log("---->>>> End createDocument");
    return doc;

  } catch (err) {
    console.error("❌ createConversation error:", err);
    throw err;
  }
}

export async function fetchChatSummary(conversation_id){

    console.log("---->>>> Start fetchChatSummary");
    const QUERY = gql`
    query getChatSummary($conversation_id: uuid!) {
        conversations(where: {uuid: {_eq: $conversation_id}}) {
            chat_summary
        }
      }
    `;

    const { data } = await client.query({
      query: QUERY,
      variables: {
        conversation_id: conversation_id,
      },
    });

    //const chat_summary = data?.conversations[0]?.chat_summary;
    //return chat_summary;

    const rawSummary = data?.conversations[0]?.chat_summary;

    let chat_summary;
    try {
        chat_summary = rawSummary ? JSON.parse(rawSummary) : null;
    } catch (err) {
        console.error("Invalid JSON in chat_summary:", rawSummary);
        chat_summary = null;
    }

    console.log("---->>>> End fetchChatSummary");
    return chat_summary;
}

export async function getHistory(conversation_id, user_id, limit){

    console.log("---->>>> Start getHistory");
    const QUERY = gql`
        query getHistory($user_id: uuid!, $conversation_id: uuid!, $limit: Int!) {
        messages(where: {_and: {user_id: {_eq: $user_id}, conversation_id: {_eq: $conversation_id}}}, order_by: {created_at: asc}, limit: $limit) {
            author
            content
        }
      }
    `;

    const { data } = await client.query({
      query: QUERY,
      variables: {
        conversation_id: conversation_id,
        user_id: user_id,
        limit: limit
      },
    });

    const history = data?.messages;

    const messages = [];
    for (let i = 0; i < history.length; i++) {
        if (history[i].author === "user") {
            const question = history[i].content;
            const answer = history[i + 1]?.author === "system" ? history[i + 1].content : null;
            messages.push({ qu: question, an: answer });
        }
    }

    console.log("---->>>> End getHistory");
    return messages;
}

export async function updateConvChatSummary(chat_summary, conversation_id) {
  try {

    console.log("---->>>> Start updateConvChatSummary");
    const MUTATION = gql`
      mutation updateChatSummary($conversation_id: uuid!, $chat_summary: String!) {
        update_conversations_by_pk(pk_columns: {uuid: $conversation_id}, _set: {chat_summary: $chat_summary}) {
            uuid
        }
       }
    `;

    const { data } = await client.mutate({
      mutation: MUTATION,
      variables: {
        chat_summary: JSON.stringify(chat_summary),
        conversation_id: conversation_id
      },
    });

    const conv = data?.update_conversations_by_pk?.uuid;

    if (!conv) {
      throw new Error("Conversation not created");
    }

    console.log("---->>>> End updateConvChatSummary");
    return conv;

  } catch (err) {
    console.error("❌ updateConvChatSummary error:", err);
    throw err;
  }
}

export async function saveMessage(content, author, user_id, conversation_id) {
  try {

    console.log("---->>>> Start saveMessage");
    const MUTATION = gql`
      mutation MyMutation($author: String!, $content: String!, $conversation_id: uuid!, $user_id: uuid!) {
        insert_messages_one(object: {author: $author, content: $content, conversation_id: $conversation_id, user_id: $user_id}) {
            uuid
        }
      }
    `;

    const { data } = await client.mutate({
      mutation: MUTATION,
      variables: {
        author: author,
        content: content,
        user_id: user_id,
        conversation_id: conversation_id
      },
    });

    const msg = data?.insert_messages_one?.uuid;

    if (!msg) {
      throw new Error("Conversation not created");
    }

    console.log("---->>>> End saveMessage");
    return msg;

  } catch (err) {
    console.error("❌ createConversation error:", err);
    throw err;
  }
}