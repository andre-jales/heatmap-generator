import { Request, Response } from "express";
import { generateHeatmap } from "../services/heatmap.service";

export const generateHeatmapController = async (
  req: Request,
  res: Response
): Promise<void> => {
  try {
    const filePath = req.file?.path;
    if (!filePath) {
      res.status(400).json({ error: "CSV file is required." });
      return;
    }

    const params = { ...req.body, filePath };
    const imagePath = await generateHeatmap(params);

    res.sendFile(imagePath);
  } catch (err) {
    console.error("Unexpected error:", err);
    res.status(500).json({
      error: err instanceof Error ? err.message : "Internal server error.",
    });
  }
};
