library(plumber)
library(ComplexHeatmap)
library(circlize)
library(jsonlite)

#* @apiTitle Heatmap API
#* @apiDescription API to generate heatmaps from provided data

#* Generates a heatmap from a matrix
#* @param file File to be uploaded, can be either CSV or TXT format.
#* @param file_has_header Boolean indicating if the CSV file has a header. Default is TRUE.
#* @param first_column_is_label Boolean indicating if the first column of the CSV is used as row labels. Default is TRUE.
#* @param column_separator Character string indicating the separator for columns. Default is ','.
#* @param decimal_separator Character string for the decimal separator. Default is ','.
#* @param quote_char Character string indicating the quote character used in the CSV. Can be either '"' or "'". Default is '"'.
#* @param color_scale Array of objects with 'color' and 'value' properties.
#* @param name Optional name for the heatmap.
#* @serializer png
#* @post /heatmap
function (file_has_header = TRUE, first_column_is_label = TRUE, 
          file, column_separator = ",", decimal_separator = ",", 
          quote_char = "\"", color_scale, name = NULL) {
  
  # Se color_scale for string, converter para lista
  if (is.character(color_scale)) {
    color_scale <- fromJSON(color_scale, simplifyVector = FALSE)
  }
  
  # Se color_scale for um data.frame, converter para lista de listas
  if (is.data.frame(color_scale)) {
    color_scale <- split(color_scale, seq(nrow(color_scale)))
  }
  
  # Verificação de estrutura de color_scale
  if (length(color_scale) < 1) {
    stop("color_scale must have at least one element.")
  }
  
  if (!all(c("color", "value") %in% names(color_scale[[1]]))) {
    stop("Each element of color_scale must have 'color' and 'value' properties.")
  }
  
  # Garantir que column_separator não seja NULL ou vazio
  if (is.null(column_separator) || column_separator == "") {
    stop("column_separator cannot be NULL or empty.")
  }

  # Ajustando separadores (permitindo "\t" e "\\t")
  if (column_separator %in% c("\t", "\\t")) {
    sep <- "\t"
  } else {
    sep <- column_separator
  }
  
  # Garantir que decimal_separator seja válido
  dec <- switch(decimal_separator, "." = ".", "," = ",", stop("Invalid decimal separator"))
  
  # Verificar se o arquivo foi enviado corretamente
  if (is.null(file) || !is.list(file) || !all(c("tempfile", "filename") %in% names(file))) {
    stop("Invalid file upload. Please provide a valid file.")
  }

  file_path <- file$tempfile  # Acessando corretamente o arquivo enviado
  file_ext <- tools::file_ext(file$filename)  # Pegando a extensão do arquivo
  
  if (!(file_ext %in% c("csv", "txt"))) {
    stop("The file must be either a CSV or TXT file.")
  }

  # Carregar os dados do arquivo
  data <- tryCatch({
    if (file_ext == "csv") {
      read.csv(file_path, sep = sep, dec = dec, 
               quote = quote_char, header = file_has_header, 
               row.names = ifelse(first_column_is_label, 1, NULL), 
               check.names = FALSE)
    } else {
      read.table(file_path, sep = sep, dec = dec, 
                 quote = quote_char, header = file_has_header, 
                 row.names = ifelse(first_column_is_label, 1, NULL), 
                 check.names = FALSE)
    }
  }, error = function(e) stop("Error reading file: ", e$message))

  # Converter para matriz
  matrix <- as.matrix(data)
  
  # Criar função de escala de cores
  values <- sapply(color_scale, function(x) x$value)
  colors <- sapply(color_scale, function(x) x$color)
  
  if (length(values) != length(colors)) {
    stop("The 'values' and 'colors' in 'color_scale' must have the same length.")
  }
  
  col_fun <- colorRamp2(values, colors)

  # Criar o heatmap e salvar como PNG
  png_file <- tempfile(fileext = ".png")
  png(png_file)
  heatmap <- Heatmap(matrix, col = col_fun, name = name)
  draw(heatmap)
  dev.off()

  # Retornar o arquivo PNG gerado
  readBin(png_file, "raw", file.info(png_file)$size)
}
