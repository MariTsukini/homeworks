# --- №1 ---
motifs2 <- matrix(c(
  "a", "C", "g", "G", "T", "A", "A", "t", "t", "C", "a", "G",
  "t", "G", "G", "G", "C", "A", "A", "T", "t", "C", "C", "a",
  "A", "C", "G", "t", "t", "A", "A", "t", "t", "C", "G", "G",
  "T", "G", "C", "G", "G", "G", "A", "t", "t", "C", "C", "C",
  "t", "C", "G", "a", "A", "A", "A", "t", "t", "C", "a", "G",
  "A", "C", "G", "G", "C", "G", "A", "a", "t", "T", "C", "C",
  "T", "C", "G", "t", "G", "A", "A", "t", "t", "a", "C", "G",
  "t", "C", "G", "G", "G", "A", "A", "t", "t", "C", "a", "C",
  "A", "G", "G", "G", "T", "A", "A", "t", "t", "C", "C", "G",
  "t", "C", "G", "G", "A", "A", "A", "a", "t", "C", "a", "C"
), nrow = 10, byrow = TRUE)


# --- №2 ---
motifs2 <- toupper(motifs2)
print(motifs2)


# --- №3 ---
count_matrix <- apply(motifs2, 2, function(x) {table(factor(x, levels = c("A", "C", "G", "T")))})
print(count_matrix)

profile_matrix <- count_matrix / nrow(motifs2)
print(profile_matrix)


# --- №4 ---
scoreMotifs <- function(mtx) {
  cm <- apply(mtx, 2, function(x) table(factor(x, levels = c("A", "C", "G", "T"))))
  max_counts <- apply(cm, 2, max)
  return(sum(max_counts))
}
current_score <- scoreMotifs(motifs2)
cat("Score для motifs2:", current_score, "\n")


# --- №5 ---
getConsensus <- function(mtx) {
  # cтроим count matrix
  count_matrix <- apply(mtx, 2, function(x) table(factor(x, levels = c("A", "C", "G", "T"))))
  # Находим индекс max элемента в каждом столбце
  # which.max возвращает первый индекс, если есть равенство
  max_indices <- apply(count_matrix, 2, which.max)
  # извлекаем имена нк по индексам
  consensus_bases <- rownames(count_matrix)[max_indices]
  # склеиваем вектор букв в одну строку
  return(paste(consensus_bases, collapse = ""))
}

consensus_seq <- getConsensus(motifs2)
cat("Консенсусная последовательность:", consensus_seq, "\n")


# --- Задание №6 ---
barplot(
  count_matrix[, 1],
  col = "skyblue",
  main = "Частоты нуклеотидов в 1-м столбце",
  ylab = "Количество",
  xlab = "Нуклеотид"
)