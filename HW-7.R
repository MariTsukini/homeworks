library(httr)
library(jsonlite)

ebi_url <- "https://www.ebi.ac.uk/proteins/api"
ncbi_url <- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils"


# --- №1 ---
# получаем функции (features) для белка P04637 (p53)
# отправляем get запрос на endpoint /features
resp <- GET(paste0(ebi_url, "/features?accession=P04637"), accept("application/json"))
stop_for_status(resp) # проверяем ошибки
data_p53 <- fromJSON(content(resp, "text", encoding = "UTF-8"))
# выводим типы функций
unique(data_p53$features[[1]]$type)


# --- №2 ---
# -- 1. data APP (P05067) --
url_app <- "https://www.ebi.ac.uk/proteins/api/proteins/P05067"
data_app <- fromJSON(content(GET(url_app), "text", encoding = "UTF-8"))

# Считаем длину всех вариантов последовательностей и берем max
len_app <- max(nchar(data_app$sequence)) 


# -- 2. data Tau (P10636) --
url_tau <- "https://www.ebi.ac.uk/proteins/api/proteins/P10636"
data_tau <- fromJSON(content(GET(url_tau), "text", encoding = "UTF-8"))

# Тоже берем максимальную
len_tau <- max(nchar(data_tau$sequence))


# -- 3. Сравнение --
print(paste("Длина APP (max):", len_app))
print(paste("Длина Tau (max):", len_tau))

if (len_app > len_tau) {
  diff <- len_app - len_tau
  print(paste("APP длиннее на", diff))
} else {
  diff <- len_tau - len_app
  print(paste("Tau длиннее на", diff))
}

# --- №3 ---
# Список ID
ids <- c("P78509", "P09874", "P26358", "Q96EB6", "Q05066")

# lapply проходит по всем id и возвращает список табличек
# склеивает этот список в одну большую таблицу
df_proteins <- do.call(rbind, lapply(ids, function(id) {
  
  url <- paste0("https://www.ebi.ac.uk/proteins/api/proteins/", id)
  data <- fromJSON(content(GET(url), "text", encoding = "UTF-8"), flatten = TRUE)
  
  # Возвращаем строку для текущего белка
  data.frame(
    Accession = id,
    Name = data$id[1],                  # Берем поле id
    Length = max(nchar(data$sequence))  # Считаем длину
  )
}))

print(df_proteins)


# --- №4 ---
# 1. получаем список ID
url_search <- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi"
resp_search <- GET(url_search, query = list(db="pubmed", term="COVID-19 variants", sort="date", retmax=10, retmode="json"))
ids <- fromJSON(content(resp_search, "text"))$esearchresult$idlist

# 2. Получаем детали для ID
url_sum <- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi"
resp_sum <- GET(url_sum, query = list(db="pubmed", id=paste(ids, collapse=","), retmode="json"))
data_sum <- fromJSON(content(resp_sum, "text"))$result

for (id in ids) {
  # Берем заголовок по ID
  title <- data_sum[[id]]$title
  cat("ID:", id, "\nTitle:", title, "\n\n")
}


# -- №7 --
for (id in ids) {
  # Берем таблицу авторов внутри каждой статьи
  authors_data <- data_sum[[id]]$authors
  
  if (!is.null(authors_data)) {
    # Склеиваем имена
    authors_str <- paste(authors_data$name, collapse = ", ")
    cat("ID:", id, "\nAuthors:", authors_str, "\n\n")
  } else {
    cat("ID:", id, "\nAuthors: Не указаны\n\n")
  }
}


# -- №9 --
#белок Q8WZ42 (Titin): последовательность разбить по 80 символов
r_titin <- GET(paste0(ebi_url, "/proteins/Q8WZ42"), accept("application/json"))
d_titin <- fromJSON(content(r_titin, "text", encoding = "UTF-8"))
seq_titin <- d_titin$sequence$sequence 

# разбиваем строку.регулярка вставляет \n каждые 80 символов
formatted_seq <- gsub("(.{80})", "\\1\n", seq_titin)
# сохраняем в файл, так как вывод огромный
cat(formatted_seq, file = "titin_seq.txt")
readLines("titin_seq.txt", n = 2)


# --- №10 ---
# barplot длин 10 белков
protein_ids_10 <- c("P05067", "P10636", "P04637", "Q9BYF1", "P38398","P78509", "P09874", "P26358", "Q96EB6", "Q05066")

# 1. Создаем таблицу
protein_10 <- do.call(rbind, lapply(protein_ids_10, function(id) {
  
  url <- paste0("https://www.ebi.ac.uk/proteins/api/proteins/", id)
  # Скачиваем и сразу превращаем в удобную структуру
  data <- fromJSON(content(GET(url), "text", encoding = "UTF-8"), flatten = TRUE)
  
  # Формируем строку таблицы
  data.frame(
    Accession = id,
    Name = sub("_HUMAN", "", data$id[1]), 
    Length = max(nchar(data$sequence)) 
  )
}))

print(protein_10)

# 2. Строим столбчатую диаграмму (barplot)
barplot(
  protein_10$Length,
  names.arg = protein_10$Name,    
  col = "skyblue",             
  main = "Длины белков",       
  ylab = "Аминокислоты",       
  las = 2)                    



# --- №11 ---
# Делаем запрос: ищем белки гена APOE у человека
url <- "https://www.ebi.ac.uk/proteins/api/proteins"
resp <- GET(url, query = list(gene = "APOE", taxid = "9606", offset = 0, size = 100))

# Получаем таблицу
data_gene <- fromJSON(content(resp, "text", encoding = "UTF-8"), flatten = TRUE)

# Создаем итоговую таблицу
df_apoe <- data.frame(
  ID = data_gene$accession,
  Name = data_gene$id,
  Link = paste0("https://www.uniprot.org/uniprot/", data_gene$accession)
  )

# Сохраняем и выводим
rite.csv(df_apoe, "apoe_proteins.csv", row.names = FALSE)
print(df_apoe)


# --- №13 ---
# (R) запрос fasta и сохранение
# возьмем p53
r_sry_fasta <- GET(paste0(ebi_url, "/proteins/Q05066"), accept("text/x-fasta"))
writeBin(content(r_sry_fasta, "raw"), "sry.fasta")


# --- №15 ---
gene <- "SRY"

# Получаем белок, берем первый
resp_prot <- GET(paste0(ebi_url, "/proteins"), query = list(gene=gene, taxid="9606", size=1))
data_prot <- fromJSON(content(resp_prot, "text", encoding = "UTF-8"), flatten = TRUE)
print(paste("Белок:", data_prot$accession[1]))

#Ищем статьи в PubMed по названию гена
resp_search <- GET(paste0(ncbi_url, "/esearch.fcgi"), query = list(db="pubmed", term=gene, retmode="json", retmax=10))
ids <- fromJSON(content(resp_search, "text"))$esearchresult$idlist

cat("ID статей:", ids, "\n")


# --- №17 ---
# все мои гениальные идеи сложные, ничего не работает.за часов 5.
#а чятпгт еще больше усложняет и ничего не работает.