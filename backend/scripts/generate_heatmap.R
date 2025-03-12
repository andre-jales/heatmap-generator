# Recebe os parâmetros da linha de comando
args <- commandArgs(trailingOnly = TRUE)

# Atribui os parâmetros a variáveis
file <- args[1]
file_has_header <- as.logical(args[2])
first_column_is_label <- as.logical(args[3])
column_separator <- args[4]
decimal_separator <- args[5]
quote_char <- args[6]
color_json <- gsub("^'|'$", "", args[7])
name <- args[8]

# Carrega o pacote ComplexHeatmap e outros necessários
suppressPackageStartupMessages(library(ComplexHeatmap))
suppressPackageStartupMessages(library(circlize))
suppressPackageStartupMessages(library(jsonlite))

# Verifica se a primeira coluna é um label
row_names <- NULL
if (first_column_is_label) {
  row_names <- 1
} else {
  row_names <- 0
}

# Lê o arquivo com o delimitador passado
table <- read.table(file,
                    row.names = row_names,
                    header = file_has_header,
                    sep = column_separator,
                    dec = decimal_separator,
                    quote = quote_char,
                    check.names = FALSE)

matrix <- data.matrix(table)

# A criação da função de cores com base nos valores passados
color_object <- fromJSON(color_json, simplifyVector = FALSE)
color_values <- sapply(color_object, function(x) x$value)
color_names <- sapply(color_object, function(x) x$color)
color_fun <- colorRamp2(color_values, color_names)

# Cria o heatmap
ht <- Heatmap(matrix,
              name = name,
              col = color_fun,
              column_title = "",
              row_title = "",
              show_row_names = TRUE,
              show_column_names = TRUE)

# Salva a imagem do heatmap
output_dir <- file.path(getwd(), "public")
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

output_path <- file.path(output_dir, "heatmap.png")
cat("Salvando imagem em:", output_path, "\n")
png(output_path, width = 800, height = 800)
draw(ht)
dev.off()

# Exibe mensagem de sucesso
cat("Heatmap gerado com sucesso!\n")
