install.packages('readxl')
library(readxl)


patients <- read_excel("C:/Users/user/master/ADBM/R and python/Пациенты.xlsx")

# --- №1 ---
str(patients[c("Возраст", "глюкоза")])
# type num 

# --- №2 ---
# преобразуем пол в фактор с уровнями м и ж и проверяем
patients$Пол <- factor(patients$Пол, levels = c("м", "ж"))
levels(patients$Пол)

# --- №3 ---
# создаем вектор с разделением на группы по возрасту
возраст_группа_2 <- ifelse(patients$Возраст <= 60, "Молодые", "Старшие")

# --- №4 ---
# фильтруем и выводим пациентов старше 75 лет
patients[patients$Возраст > 75, ]

# --- №5 ---
# смотрим первые строки и статистику для лейкоцитов и глюкозы
head(patients[c("лейкоциты", "глюкоза")])
summary(patients[c("лейкоциты", "глюкоза")])

# --- №6 ---
# считаем среднюю глюкозу по полу
aggregate(глюкоза ~ Пол, data = patients, mean)

# --- №7 ---
# добавляем группу в датафрейм и считаем средние лейкоциты по полу и возрасту
patients$возраст_группа_2 <- возраст_группа_2
aggregate(лейкоциты ~ Пол + возраст_группа_2, data = patients, mean)

# --- №8 ---
# выводим сразу среднее, отклонение и количество для глюкозы
aggregate(глюкоза ~ Пол,data = patients, FUN = function(x) c(mean = mean(x), sd = sd(x), n = length(x)))

# --- №9 ---
# дублирует задание 8

# --- №10 ---
# строим боксплоты глюкозы по полу с подписями
boxplot(глюкоза ~ Пол, data = patients, 
        main = "Распределение глюкозы по полу", 
        xlab = "Пол", 
        ylab = "Глюкоза")

# --- №11 ---
# проводим t-тест для лейкоцитов
t.test(лейкоциты ~ Пол, data = patients)
# Ho: средние уровни лейкоцитов у м и ж равны
# p-value > 0.05, значит нет оснований отвергнуть нулевую гипотезу, разницы нет

# --- №12 ---
# создаем копию и вносим NA, затем считаем их общее количество
patients_task <- patients
patients_task$глюкоза[c(3, 15, 45)] <- NA
sum(is.na(patients_task))

# --- №13 ---
# находим номера строк, где глюкоза равна NA
which(is.na(patients_task$глюкоза))

# --- №14 ---
# удаляем строки с NA и сравниваем размерности
patients_no_na <- na.omit(patients_task)
dim(patients_task)
dim(patients_no_na)

# --- №15 ---
# заменяем пропуски в глюкозе на медиану
med_val <- median(patients_task$глюкоза, na.rm = TRUE)
patients_task$глюкоза[is.na(patients_task$глюкоза)] <- med_val

# --- №16 ---
# считаем средние лейкоциты для обоих датафреймов
aggregate(лейкоциты ~ Пол, data = patients_task, mean)
aggregate(лейкоциты ~ Пол, data = patients_no_na, mean)
# результаты немного отличаюся из-за удаленных строк в patients_no_na

# --- №17 ---
# считаем статистику по гемоглобину и оформляем в таблицу
temp_agg <- aggregate(гемоглобин ~ возраст_группа_2, data = patients, 
                      FUN = function(x) c(mean = mean(x), sd = sd(x)))
final_result <- data.frame(
  Возрастная_группа = temp_agg$возраст_группа_2,
  Среднее_гемоглобин = temp_agg$гемоглобин[, "mean"],
  SD_гемоглобин = temp_agg$гемоглобин[, "sd"]
)
print(final_result)

# --- №18 ---
# сохраняем итоговую таблицу в csv файл
write.csv(final_result, "анализ_гемоглобина.csv", row.names = FALSE)