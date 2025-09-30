import express from "express";
import routes from "./routes.js";
import { swaggerUiMiddleware, swaggerSpec } from "./swagger.js";

const app = express();

app.use(express.json());
app.use("/api", routes);
app.use("/docs", swaggerUiMiddleware, (req, res) => res.json(swaggerSpec));

const port = process.env.NODE_PORT || 3000;
app.listen(port, () => console.log(`🚀 Server running at http://localhost:${port}`));