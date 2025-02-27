import express, { Request, Response } from "express";
import multer from "multer";
import cors from "cors";
import { exec } from "child_process";
import path from "path";
import fs from "fs";

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// File upload configuration
const storage = multer.diskStorage({
  destination: "uploads/",
  filename: (req, file, cb) => {
    cb(null, file.originalname);
  },
});
const upload = multer({ storage });

// Interface for received parameters
interface HeatmapParams {
  fileHasHeader: boolean;
  firstColumnIsLabel: boolean;
  columnSeparator: string;
  decimalSeparator: string;
  quoteChar: string;
  col: { color: string; value: number }[];
  name: string;
}

// POST route to generate the heatmap
app.post(
  "/generate-heatmap",
  upload.single("data"),
  async (req: Request, res: Response): Promise<void> => {
    try {
      const params: HeatmapParams = req.body;
      const filePath = req.file?.path;

      if (!filePath) {
        res.status(400).json({ error: "CSV file is required." });
        return;
      }

      const colJson = JSON.stringify(params.col).replace(/"/g, '\\"');
      const rScript = path.join(__dirname, "generate_heatmap.R");

      const command = `Rscript ${rScript} "${filePath}" "${params.fileHasHeader}" "${params.firstColumnIsLabel}" "${params.columnSeparator}" "${params.decimalSeparator}" "${params.quoteChar}" "${colJson}" "${params.name}"`;

      exec(command, (error, stdout, stderr) => {
        if (error) {
          console.error(`Error executing R: ${stderr}`);
          res.status(500).json({ error: "Error generating the heatmap." });
          return;
        }

        const imagePath = path.join(__dirname, "..", "heatmap.png");

        if (!fs.existsSync(imagePath)) {
          res.status(500).json({ error: "Image not generated." });
          return;
        }

        res.sendFile(imagePath);
      });
    } catch (err) {
      console.error("Unexpected error:", err);
      res.status(500).json({ error: "Internal server error." });
    }
  }
);

// Starting the server
app.listen(port, () => {
  console.log(`API running at http://localhost:${port}`);
});
