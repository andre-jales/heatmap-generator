interface IHeatmapParams {
  filePath: string;
  fileHasHeader: boolean;
  firstColumnIsLabel: boolean;
  columnSeparator: string;
  decimalSeparator: string;
  quoteChar: string;
  col: { color: string; value: number }[];
  name: string;
}

export default IHeatmapParams;
