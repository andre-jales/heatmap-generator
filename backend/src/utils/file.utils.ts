import fs from "fs";
import path from "path";

export const fileExists = (filePath: string): boolean =>
  fs.existsSync(filePath);

export const getHeatmapPath = (): string =>
  path.join(__dirname, "../../public/heatmap.png");
