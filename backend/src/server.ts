import express from "express";
import cors from "cors";
import heatmapRoutes from "./routes/heatmap.routes";

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());
app.use("/api", heatmapRoutes);

app.listen(port, () => {
  console.log(`API running at http://localhost:${port}`);
});
