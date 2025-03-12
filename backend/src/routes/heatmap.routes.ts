import { Router } from "express";
import { generateHeatmapController } from "../controllers/heatmap.controller";
import { upload } from "../config/multer.config";

const router = Router();

router.post(
  "/generate-heatmap",
  upload.single("data"),
  generateHeatmapController
);

export default router;
