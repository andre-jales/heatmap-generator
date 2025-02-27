library(plumber)

# Função que vai processar os dados e retornar uma imagem
# Esta função é um exemplo simples que gera uma imagem baseada nos parâmetros recebidos
# E envia de volta uma imagem em formato PNG.

#* @post /processar
#* @param arquivo file - O arquivo enviado (garante o upload de arquivo)
#* @param parametro1 string - Um parâmetro de exemplo
#* @param parametro2 string - Outro parâmetro de exemplo
#* @response 200 - Imagem gerada
function(arquivo, parametro1, parametro2) {
  
  # Aqui você pode processar o arquivo e os parâmetros conforme necessário
  # Exemplo: Criar uma imagem simples com base nos parâmetros.
  
  # Ler o arquivo de imagem (como exemplo de processamento)
  img <- png::readPNG(arquivo$datapath)
  
  # Processar a imagem e os parâmetros
  # Neste exemplo, vamos criar uma imagem simples apenas com a manipulação do texto dos parâmetros
  # você pode colocar seu processamento aqui.
  
  # Gerar uma imagem simples
  png_file <- tempfile(fileext = ".png")
  png(png_file, width = 400, height = 400)
  plot(1:10, main = paste("Parâmetros:", parametro1, parametro2))
  dev.off()
  
  # Retorna a imagem gerada
  return(readBin(png_file, "raw", file.info(png_file)$size))
}

