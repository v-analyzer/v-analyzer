module project

import project.flavors
import os

// get_modules_location возвращает папку в которой V ищет и сохраняет модули.
// По умолчанию это ~/.vmodules, однако его можно переопределить
// с помощью переменной окружения VMODULES
pub fn get_modules_location() string {
	return os.vmodules_dir()
}

// get_toolchain_candidates ищет возможные места где был установлен компилятор V.
// Функция возвращает массив кандидатов, где первый элемент - самый приоритетный.
// Если ни один кандидат не найден, то возвращается пустой массив.
//
// Приоритет:
// 1. VROOT или VEXE переменные окружения
// 2. Символическая ссылка /usr/local/bin/v -> v (кроме Windows)
// 3. Путь из переменной окружения PATH
// 4. Другие дополнительные варианты поиска
pub fn get_toolchain_candidates() []string {
	return flavors.get_toolchain_candidates()
}
