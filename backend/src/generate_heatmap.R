# Recebe os parâmetros da linha de comando
args <- commandArgs(trailingOnly = TRUE)

# Atribui os parâmetros a variáveis
arquivo <- args[1]
file_has_header <- as.logical(args[2])
first_column_is_label <- as.logical(args[3])
column_separator <- args[4]
decimal_separator <- args[5]
quote_char <- args[6]
col_json <- args[7]
name <- args[8]

# Carrega o pacote ComplexHeatmap e outros necessários
suppressPackageStartupMessages(library(ComplexHeatmap))
suppressPackageStartupMessages(library(circlize))
suppressPackageStartupMessages(library(jsonlite))

# Converte o JSON de colunas para um formato utilizável em R
# col <- fromJSON(col_json)
col_fun <- colorRamp2(c(-1, 0, 1), c("green", "yellow", "red"))

# Lê o arquivo com o delimitador passado
x <- read.delim(arquivo, row.names = 1, check.names = FALSE)

# Caso o arquivo tenha header, a primeira linha será tratada como nomes das colunas
if (file_has_header) {
  colnames(x) <- colnames(x)
}

# Caso a primeira coluna seja rótulo
if (first_column_is_label) {
  rownames(x) <- x[, 1]
  x <- x[, -1]
}

x <- data.matrix(x)

# A criação da função de cores com base nos valores passados
# Assumindo que col seja uma lista de objetos com a propriedade "color" e "value"
#color_values <- sapply(col, function(x) x$value)
#color_names <- sapply(col, function(x) x$color)

# Definindo a função de cores para o heatmap
#col_fun <- colorRamp2(color_values, color_names)

# Cria o heatmap
ht <- Heatmap(x, 
              name = name,
              col = col_fun, 
              column_title = "Heatmap", 
              row_title = "Rows",
              show_row_names = TRUE, 
              show_column_names = TRUE)

# Salva a imagem do heatmap
output_path <- file.path(getwd(), "heatmap.png")
png(output_path, width = 800, height = 800)
draw(ht)
dev.off()

# Exibe mensagem de sucesso
cat("Heatmap gerado com sucesso!\n")
