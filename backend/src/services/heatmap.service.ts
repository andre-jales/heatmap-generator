import { exec } from "child_process";
import path from "path";

import IHeatmapParams from "../types/IHeatmapParams";
import { getHeatmapPath, fileExists } from "../utils/file.utils";

export const generateHeatmap = (params: IHeatmapParams): Promise<string> => {
  return new Promise((resolve, reject) => {
    const rScript = path.join(__dirname, "../../scripts/generate_heatmap.R");
    const jsonString = JSON.stringify(params.col);

    const command = `Rscript ${rScript} "${params.filePath}" "${params.fileHasHeader}" "${params.firstColumnIsLabel}" "${params.columnSeparator}" "${params.decimalSeparator}" "${params.quoteChar}" '${jsonString}' "${params.name}"`;

    exec(command, (error, stdout, stderr) => {
      stdout && console.log(`R output: ${stdout}`);
      if (error) {
        console.error(`Error executing R: ${stderr}`);
        reject(new Error("Error generating the heatmap."));
        return;
      }

      const imagePath = getHeatmapPath();

      if (!fileExists(imagePath)) {
        reject(new Error("Image not generated."));
        return;
      }

      resolve(imagePath);
    });
  });
};
