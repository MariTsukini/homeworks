# main.R

# --- 1. Инициализация окружения ---
cat("=== Запуск скрипта анализа данных ===\n")

# чекаем пакет dplyr
if (!requireNamespace("dplyr", quietly = TRUE)) {
  message("Пакет dplyr не найден. Запускаем установку...")
  install.packages("dplyr", repos = "http://cran.rstudio.com/")
} else {
  message("Библиотека dplyr обнаружена.")
}

library(dplyr)

# Вывод версии
pkg_ver <- packageVersion("dplyr")
cat(sprintf("Текущая версия dplyr: %s\n\n", pkg_ver))

# Проверка/создание директории для вывода
output_dir <- "./data"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
  cat("Директория 'data' была создана.\n")
}

# --- 2. Генерация исходных данных ---
cat("--- Генерация таблиц ---\n")

# Метаданные (DataFrame 1)
meta_df <- data.frame(
  sample_id = paste0("Sample_", 1:6),
  cell_type = c("HEK293", "HeLa", "HEK293", "U2OS", "HeLa", "Primary"),
  treatment = c("Control", "Drug_A", "Drug_B", "Control", "Drug_A", "Drug_C"),
  replicate = c(1, 1, 1, 2, 2, 1),
  concentration_uM = c(0, 10, 50, 0, 10, 100)
)

# Данные масс-спектрометрии (DataFrame 2)
ms_df <- data.frame(
  sample_id = paste0("Sample_", c(1, 2, 3, 4, 7)),
  total_proteins = c(2450, 2310, 2540, 2480, 2600),
  unique_peptides = c(15200, 14800, 15600, 15400, 16200),
  contamination_level = c(0.02, 0.05, 0.03, 0.01, 0.04)
)

# Сохраняем сырые данные, чтобы они были в контейнере
write.csv(meta_df, file.path(output_dir, "sample_metadata.csv"), row.names = FALSE)
write.csv(ms_df, file.path(output_dir, "mass_spec_results.csv"), row.names = FALSE)
cat("Исходные файлы записаны в папку data/.\n\n")

# --- 3. Выполнение Join операций ---
cat("--- Обработка данных (Anti-Joins) ---\n")

# A) Anti Left: Есть в метаданных, но нет результатов MS
res_left <- anti_join(meta_df, ms_df, by = "sample_id")
cat(sprintf("1. Anti-Left Join: найдено %d записей (отсутствуют в MS).\n", nrow(res_left)))
write.csv(res_left, file.path(output_dir, "anti_left_result.csv"), row.names = FALSE)

# B) Anti Right: Есть результаты MS, но нет метаданных
res_right <- anti_join(ms_df, meta_df, by = "sample_id")
cat(sprintf("2. Anti-Right Join: найдено %d записей (нет описания в метаданных).\n", nrow(res_right)))
write.csv(res_right, file.path(output_dir, "anti_right_result.csv"), row.names = FALSE)

# C) Anti Outer: Симметричная разность (уникальные для каждой таблицы)
# Объединяем результаты left и right, добавляя метку происхождения
res_outer <- bind_rows(
  res_left %>% mutate(origin = "metadata_only"),
  res_right %>% mutate(origin = "ms_data_only")
)
cat(sprintf("3. Anti-Outer Join: всего %d уникальных непересекающихся записей.\n", nrow(res_outer)))
write.csv(res_outer, file.path(output_dir, "anti_outer_result.csv"), row.names = FALSE)

# --- 4. Финальный отчет ---
cat("\n--- Итоговая сводка ---\n")
common_count <- nrow(inner_join(meta_df, ms_df, by = "sample_id"))

cat(paste0(
  "Всего образцов в Metadata: ", nrow(meta_df), "\n",
  "Всего образцов в MS Data:  ", nrow(ms_df), "\n",
  "Пересекающихся образцов:   ", common_count, "\n",
  "---------------------------\n",
  "Уникальных для Metadata:   ", nrow(res_left), "\n",
  "Уникальных для MS Data:    ", nrow(res_right), "\n"
))

cat("\nСкрипт успешно завершил работу.\n")