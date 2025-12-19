import pandas as pd
import os
import sys

# Настройка логирования в stdout
def log_message(message):
    print(f"[INFO] {message}")
    sys.stdout.flush() # Гарантируем немедленный вывод

log_message("Начало операций объединения данных...")
output_dir = 'output' # Директория для вывода (относительно WORKDIR /app)
log_message(f"Директория для вывода '{output_dir}' будет использоваться.")

# Загружаем данные из директории 'input'
try:
    sample_metadata = pd.read_csv('input/sample_metadata.csv')
    mass_spec_results = pd.read_csv('input/mass_spec_results.csv')
    quality_metrics = pd.read_csv('input/quality_metrics.csv')
    log_message("Все входные CSV-файлы успешно загружены.")
except FileNotFoundError as e:
    log_message(f"Ошибка при загрузке файла: {e}. Убедитесь, что 'input' директория монтирована и файлы существуют.")
    sys.exit(1)


# --- Выполняем INNER JOIN ---
log_message("\nВыполнение INNER JOIN для 'sample_metadata' и 'mass_spec_results'...")
inner_join = pd.merge(sample_metadata, mass_spec_results, on='sample_id', how='inner')
inner_join_output_path = os.path.join(output_dir, 'inner_join_results.csv')
inner_join.to_csv(inner_join_output_path, index=False)
log_message(f"INNER JOIN завершен. Результат сохранен в '{inner_join_output_path}'.")
log_message(f"Информация по INNER JOIN: Исходно {len(sample_metadata)} записей метаданных + {len(mass_spec_results)} записей масс-спектрометрии -> Получено {len(inner_join)} объединенных записей.")
log_message(f"Первые 5 строк INNER JOIN:\n{inner_join.head()}")

# --- Выполняем LEFT JOIN ---
log_message("\nВыполнение LEFT JOIN для 'sample_metadata' (левая) и 'mass_spec_results' (правая)...")
left_join = pd.merge(sample_metadata, mass_spec_results, on='sample_id', how='left')
left_join_output_path = os.path.join(output_dir, 'left_join_results.csv')
left_join.to_csv(left_join_output_path, index=False)
log_message(f"LEFT JOIN завершен. Результат сохранен в '{left_join_output_path}'.")
log_message(f"Информация по LEFT JOIN: Исходно {len(sample_metadata)} записей метаданных (все сохранены) -> Получено {len(left_join)} объединенных записей.")
log_message(f"Первые 5 строк LEFT JOIN:\n{left_join.head()}")
missing_mass_spec = left_join[left_join['total_proteins'].isna()]
if not missing_mass_spec.empty:
    log_message(f"Записи без данных масс-спектрометрии после LEFT JOIN (из 'sample_metadata'):\n{missing_mass_spec[['sample_id', 'cell_type']].to_string(index=False)}")
else:
    log_message("Все записи из 'sample_metadata' нашли соответствующие данные масс-спектрометрии.")

# --- Выполняем RIGHT JOIN ---
log_message("\nВыполнение RIGHT JOIN для 'sample_metadata' (левая) и 'mass_spec_results' (правая)...")
right_join = pd.merge(sample_metadata, mass_spec_results, on='sample_id', how='right')
right_join_output_path = os.path.join(output_dir, 'right_join_results.csv')
right_join.to_csv(right_join_output_path, index=False)
log_message(f"RIGHT JOIN завершен. Результат сохранен в '{right_join_output_path}'.")
log_message(f"Информация по RIGHT JOIN: Исходно {len(mass_spec_results)} записей масс-спектрометрии (все сохранены) -> Получено {len(right_join)} объединенных записей.")
log_message(f"Первые 5 строк RIGHT JOIN:\n{right_join.head()}")
missing_metadata = right_join[right_join['cell_type'].isna()]
if not missing_metadata.empty:
    log_message(f"Записи без метаданных после RIGHT JOIN (из 'mass_spec_results'):\n{missing_metadata[['sample_id', 'total_proteins']].to_string(index=False)}")
else:
    log_message("Все записи из 'mass_spec_results' нашли соответствующие метаданные.")

# --- Выполняем OUTER JOIN ---
log_message("\nВыполнение OUTER JOIN для 'sample_metadata' и 'mass_spec_results'...")
outer_join = pd.merge(sample_metadata, mass_spec_results, on='sample_id', how='outer')
outer_join_output_path = os.path.join(output_dir, 'outer_join_results.csv')
outer_join.to_csv(outer_join_output_path, index=False)
log_message(f"OUTER JOIN завершен. Результат сохранен в '{outer_join_output_path}'.")
log_message(f"Информация по OUTER JOIN: Исходно {len(sample_metadata)} записей метаданных + {len(mass_spec_results)} записей масс-спектрометрии -> Получено {len(outer_join)} уникальных объединенных записей.")
log_message(f"Первые 5 строк OUTER JOIN:\n{outer_join.head()}")

log_message("\nВсе операции объединения данных завершены.")