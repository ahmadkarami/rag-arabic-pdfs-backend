import express from "express";
import { loginUser } from "./services/auth.js";
import { generateAnswer , createConversation, fetchFileUrl, createDocument, fetchChatSummary, getHistory, updateConvChatSummary, saveMessage} from "./services/ragService.js";


const router = express.Router();


// ---------------- LOGIN ----------------
router.post("/login", async (req, res) => {
  try {
    console.log("---->>>> Start Login");
        const headerSecret = req.headers["x-auth-secret"];
        if (headerSecret !== process.env.HEADER_AUTH_SECRET) {
          return res.status(403).json({ error: "Forbidden: invalid header secret" });
        }
        const { email, password } = req.body.input || req.body;

        if (!email || !password) {
          return res.status(400).json({ error: "Missing email or password" });
        }

        const result = await loginUser(email, password);
        res.json(result);

    console.log("---->>>> End Login");
  } catch (err) {
        console.error("❌ Login error:", err.message);
        res.status(400).json({ error: err.message });
  }
});

// ---------------- RAG ANSWER ----------------
router.post("/generate-answer", async (req, res) => {
  try {
    console.log("---->>>> Start generate answer");

      // ------------------- HEADER
      const headerSecret = req.headers["x-auth-secret"];
      if (headerSecret !== process.env.HEADER_AUTH_SECRET) {
        return res.status(403).json({ error: "Forbidden: invalid header secret" });
      }
      // ------------------- HEADER

      const sessionVars = req.body.session_variables || {};
      const userId = sessionVars["x-hasura-user-id"];
      const role = sessionVars["x-hasura-role"];
      var chatSummary = {};
      var history = [];

      if (!userId) {
        return res.status(401).json({ error: "Missing x-hasura-user-id" });
      }

      let { question , conversation_id, file_url} = req.body.input || req.body;

      if (!question && !conversation_id) {
        // ERRROR
        return res.status(400).json({ error: "Missing data" });
      }

      if (!question && conversation_id) {
        file_url = await fetchFileUrl(conversation_id);
        
        if(!file_url){
          return res.status(400).json({ error: "Missing fileUrl" });
        }

        chatSummary = await fetchChatSummary(conversation_id); //chatSummary
        history = await getHistory(conversation_id, userId, 6); //history
      }

      if (question && !conversation_id) {
        conversation_id = await createConversation();
        if(file_url){
          await createDocument("Tilte", file_url, userId, conversation_id);
        }
      }

      if (question && conversation_id) {
        file_url = await fetchFileUrl(conversation_id);
        chatSummary = await fetchChatSummary(conversation_id); //chatSummary
        history = await getHistory(conversation_id, userId, 6); //history
      }

    const result = await generateAnswer({ question, "fileUrl": file_url, chatSummary, history });
    await updateConvChatSummary(result.chatSummary, conversation_id);
    await saveMessage(question, "user", userId, conversation_id);
    await saveMessage(result.answer, "system", userId, conversation_id);
    res.json({"answer": result.answer, "conversation_id": conversation_id});

    console.log("---->>>> End generate answer");
  } catch (err) {
    console.error("❌ RAG error:", err.message);
    res.status(500).json({ error: err.message });
  }
});


export default router;