import { useMutation } from "@tanstack/react-query";

import { IHeatmapParams } from "../types/IHeatmapParams";

const useCreateHeatmap = () => {
  const { mutateAsync, data, isError, isPending } = useMutation<
    Blob,
    Error,
    IHeatmapParams
  >({
    mutationFn: async (params: IHeatmapParams) => {
      const response = await fetch("/generate-heatmap", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(params),
      });
      if (!response.ok) {
        throw new Error("Erro ao gerar o heatmap");
      }
      return response.blob();
    },
  });

  return { mutateAsync, data, isError, isPending };
};

export default useCreateHeatmap;
