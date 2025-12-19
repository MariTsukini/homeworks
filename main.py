#!/usr/bin/env python
# coding: utf-8

# In[5]:


#!/usr/bin/env python3
"""
Алгоритма Нидлмана-Вунша.
"""

import time
import os


def clear_screen():
    """Очищает экран"""
    os.system('clear' if os.name == 'posix' else 'cls')


def print_matrix(seq1, seq2, dp, current_i=None, current_j=None, step_info=""):
    """
    Печатает матрицу с анимацией текущей ячейки
    """
    clear_screen()
    
    print("=" * 70)
    print("АЛГОРИТМ НИДЛМАНА-ВУНША - ПОШАГОВОЕ ЗАПОЛНЕНИЕ")
    print("=" * 70)
    print(f"Seq1: {seq1}")
    print(f"Seq2: {seq2}")
    if step_info:
        print(f"Шаг: {step_info}")
    print()
    
    # Заголовок
    print("     ", end="")
    for j in range(len(dp[0])):
        if j == 0:
            print("   ", end="")
        else:
            print(f"  {seq2[j-1]}", end="")
    print()
    
    # Строки матрицы
    for i in range(len(dp)):
        if i == 0:
            print("   ", end="")
        else:
            print(f" {seq1[i-1]} ", end="")
        
        for j in range(len(dp[0])):
            # Выделяем текущую ячейку
            if current_i == i and current_j == j:
                print(f"[{dp[i][j]:2}]", end="")
            else:
                print(f" {dp[i][j]:2} ", end="")
        print()
    
    print("=" * 70)


def needleman_wunsch(seq1, seq2, match=2, mismatch=-1, gap=-1):
    """
    Алгоритма Нидлмана-Вунша
    """
    n, m = len(seq1), len(seq2)
    

    dp = [[0] * (m+1) for _ in range(n+1)]
    
    for i in range(n+1):
        dp[i][0] = i * gap
    for j in range(m+1):
        dp[0][j] = j * gap
    
    print_matrix(seq1, seq2, dp, step_info="Инициализация")
    time.sleep(2)
    
    for i in range(1, n+1):
        for j in range(1, m+1):
            print_matrix(seq1, seq2, dp, current_i=i, current_j=j, 
                                step_info=f"Заполнение ячейки ({i},{j})")
            
            match_score = dp[i-1][j-1] + (match if seq1[i-1] == seq2[j-1] else mismatch)
            delete = dp[i-1][j] + gap
            insert = dp[i][j-1] + gap
            
            print(f"\nРасчет для {seq1[i-1]} vs {seq2[j-1]}:")
            print(f"↖ Совпадение: {dp[i-1][j-1]} + {match if seq1[i-1] == seq2[j-1] else '-1'} = {match_score}")
            print(f"↑ Удаление:   {dp[i-1][j]} + {gap} = {delete}")
            print(f"← Вставка:    {dp[i][j-1]} + {gap} = {insert}")
            
            dp[i][j] = max(match_score, delete, insert)
            
            print(f"Максимум: {dp[i][j]}")
            time.sleep(1.5)
    
    print_matrix(seq1, seq2, dp, step_info="Матрица заполнена")
    time.sleep(2)
    
    align1, align2 = "", ""
    i, j = n, m
    
    print("\nОБРАТНЫЙ ПРОХОД:")
    print("=" * 50)
    
    step = 1
    while i > 0 or j > 0:
        print(f"\nШаг {step}: Позиция ({i},{j})")
        
        if i > 0 and j > 0 and dp[i][j] == dp[i-1][j-1] + (match if seq1[i-1] == seq2[j-1] else mismatch):
            print(f"  ↖ Совпадение: {seq1[i-1]} = {seq2[j-1]}")
            align1 = seq1[i-1] + align1
            align2 = seq2[j-1] + align2
            i -= 1
            j -= 1
        elif i > 0 and dp[i][j] == dp[i-1][j] + gap:
            print(f"  ↑ Удаление: {seq1[i-1]} → -")
            align1 = seq1[i-1] + align1
            align2 = "-" + align2
            i -= 1
        else:
            print(f"  ← Вставка: - ← {seq2[j-1]}")
            align1 = "-" + align1
            align2 = seq2[j-1] + align2
            j -= 1
        
        print(f"  Выравнивание: {align1}")
        print(f"                {align2}")
        
        step += 1
        time.sleep(1)
    
    return align1, align2, dp


def main():
    """
    Демонстрация алгоритма
    """
    # Ваши последовательности
    seq1 = "ACTGAC"
    seq2 = "TCGTGC"
    
    print("АЛГОРИТМ НИДЛМАНА-ВУНША")
    print("=" * 70)
    print(f"Последовательность 1: {seq1}")
    print(f"Последовательность 2: {seq2}")
    print("Параметры: match=2, mismatch=0, gap=-2")
    print()
    
    result1, result2, matrix = needleman_wunsch(seq1, seq2)
    
    print("\n" + "=" * 70)
    print("ФИНАЛЬНЫЙ РЕЗУЛЬТАТ:")
    print("=" * 70)
    print(f"Выравнивание 1: {result1}")
    print(f"Выравнивание 2: {result2}")
    print(f"Общий score: {matrix[len(seq1)][len(seq2)]}")


if __name__ == "__main__":
    main()


# # Самостоятельная работа

# #  Часть 1

# In[2]:


# 1. Объясните, чему будет равно значение в ячейке (1, 2). Почему?

# Параметры: 
# Match = +2
# Mismatch = -1
# Gap = -1


# 
# 
# ![image.png](attachment:55f5e4df-7041-48b1-bdc9-d4b42f471c89.png)

# In[3]:


# 2. Объясните порядок движения при обратном проходе


# ![image.png](attachment:ffeaaa7b-c4fd-483d-bc8b-0bf204b065d5.png)

# In[16]:


# Создание матрицы: 

import numpy as np

# Создание матрицы 5x5 с числами от 1 до 25
matrix = np.arange(1, 26).reshape(5, 5)
print("Исходная матрица:")
print(matrix)


# In[35]:


# Задание 3: Элемент сверху для каждой ячейки

# Напишите код, который для каждой  ячейки матрицы выведет элемент,
# находящийся непосредственно над ней (сверху).
# Начинайте с элемента (1,1) и двигайтесь последовательно по строкам, пропуская элементы в нулевой строке и в нулевом столбце 

# Требования:

#     Для каждой ячейки выводите ее координаты

#     Выводите элемент сверху



# Пример вывода для первых нескольких ячеек:

# Ячейка (2,1) = 6 → Сверху: 1
# Ячейка (2,2) = 7 → Сверху: 2


# In[17]:


# Задание 2: Элемент по диагонали (левый верхний) для каждой ячейки

# Задача: Напишите код, который для каждой ячейки матрицы выведет элемент, находящийся по диагонали слева сверху.
# Начинайте с элемента (1,1)

# Требования:

#     Для каждой ячейки выводите ее координаты и значение

#     Выводите диагональный элемент, если он существует

#     Если диагонального элемента не существует (для первой строки или первого столбца), выводите соответствующее сообщение


# In[19]:


# Задание 3: Элемент слева для каждой ячейки

# Задача: Напишите код, который для каждой  ячейки матрицы выведет элемент, находящийся непосредственно слева.

# Начинайте с элемента (1,1)

# Требования:

#     Для каждой ячейки выводите ее координаты и значение

#     Выводите левый элемент


# # Часть 2

# In[34]:


# 1. NumPy: создайте матрицу от 1 до 9


# In[25]:


# 2. NumPy: создайте матрицу от 9 до 1


# In[29]:


# 3. NumPy: транспонируйте матрицу


# In[28]:


# 4. NumPy: создайте 2 матрицы и сложите их


# In[31]:


# 5. NumPy: создайте 2 матрицы и перемножьте их


# In[33]:


# 6. Используя NumPy создайте единичную матрицу (по главной диагонали единицы)

# [[1. 0. 0.]
#  [0. 1. 0.]
#  [0. 0. 1.]]


# # Домашнее задание

# In[23]:


# 1. Вам представлен код с реализацией алгоритма Нидлмана-Вунша. Функция needleman_wunsch принимает параметры: match=2, mismatch=-1, gap=-1
# поэксперементируйте с параметрами и посморите, как меняется выравнивание и score. Какие выводы можно сделать? 


# In[ ]:





# In[ ]:


# 2. Используя numpy создайте матрицу 7 на 7


# In[1]:


import numpy as np

matrix = np.arange(1, 50).reshape(7, 7)
print(matrix)


# In[32]:


# 3. NumPy: создайтие диагональную матрицу, где по главной диагонали идут числа от 1 до 5


# In[2]:


diag_values = np.arange(1, 6)
diag_matrix = np.diag(diag_values)

print(diag_matrix)


# In[ ]:


# 4. Напиши функцию, которая принимает матрицу и проверяет, является ли она единичной. В ответе возвращается True или False


# In[3]:


def is_identity(matrix):
    
    mat = np.array(matrix)
    if mat.shape[0] != mat.shape[1]:
        return False

    identity = np.eye(mat.shape[0])

    return np.array_equal(mat, identity)

mat1 = np.eye(3)
mat2 = np.array([[1, 0, 0],
                 [0, 2, 0],
                 [0, 0, 1]])

print(is_identity(mat1))  
print(is_identity(mat2))  


# In[ ]:




