# language: ru

Функционал: Работа плагина ограничений выгрузки
    Как Пользователь
    Я хочу выполнять автоматическую синхронизацию конфигурации из хранилища
    Чтобы автоматизировать свою работы с хранилищем с git

Контекст: Тестовый контекст limit
    Когда Я очищаю параметры команды "gitsync" в контексте
    И Я устанавливаю рабочей каталог во временный каталог
    И Я создаю новый объект ГитРепозиторий
    И Я устанавливаю путь выполнения команды "gitsync" к текущей библиотеке
    И Я устанавливаю текущие плагины
    И Я создаю временный каталог и сохраняю его в переменной "КаталогХранилища1С"
    И я скопировал каталог тестового хранилища конфигурации в каталог из переменной "КаталогХранилища1С"
    И Я создаю временный каталог и сохраняю его в переменной "ПутьКаталогаИсходников"
    И Я инициализирую репозиторий в каталоге из переменной "ПутьКаталогаИсходников"
    И Я создаю тестовой файл AUTHORS 
    И Я записываю "0" в файл VERSION
    И я включаю отладку лога с именем "oscript.app.gitsync"
    И Я создаю временный каталог и сохраняю его в переменной "ВременнаяДиректория"
    И Я добавляю параметр "--tempdir" для команды "gitsync" из переменной "ВременнаяДиректория"
    И Я добавляю параметр "-v" для команды "gitsync"
    И Я добавляю параметр "sync" для команды "gitsync"
    И Я выключаю все плагины
    И Я включаю плагин "limit"
    
Сценарий: Cинхронизация с использованием limit
    Допустим Я добавляю параметр "-l 1" для команды "gitsync"
    И Я добавляю позиционный параметр для команды "gitsync" из переменной "КаталогХранилища1С"
    И Я добавляю позиционный параметр для команды "gitsync" из переменной "ПутьКаталогаИсходников"
    Когда Я выполняю команду "gitsync"
    Тогда Вывод команды "gitsync" содержит "ИНФОРМАЦИЯ - Завершена синхронизации с git"
    И Вывод команды "gitsync" не содержит "Внешнее исключение"
    И Код возврата команды "gitsync" равен 0
    И Количество коммитов должно быть "1"

Сценарий: Cинхронизация c использованием maxversion
    Допустим Я добавляю параметр "--maxversion 2" для команды "gitsync"
    И Я добавляю позиционный параметр для команды "gitsync" из переменной "КаталогХранилища1С"
    И Я добавляю позиционный параметр для команды "gitsync" из переменной "ПутьКаталогаИсходников"
    Когда Я выполняю команду "gitsync"
    Тогда Вывод команды "gitsync" содержит "ИНФОРМАЦИЯ - Завершена синхронизации с git"
    И Вывод команды "gitsync" не содержит "Внешнее исключение"
    И Код возврата команды "gitsync" равен 0
    И Количество коммитов должно быть "2"

Сценарий: Cинхронизация c использованием minversion
    Допустим Я добавляю параметр "--minversion 5" для команды "gitsync"
    И Я добавляю позиционный параметр для команды "gitsync" из переменной "КаталогХранилища1С"
    И Я добавляю позиционный параметр для команды "gitsync" из переменной "ПутьКаталогаИсходников"
    Когда Я выполняю команду "gitsync"
    Тогда Вывод команды "gitsync" содержит "ИНФОРМАЦИЯ - Завершена синхронизации с git"
    И Вывод команды "gitsync" не содержит "Внешнее исключение"
    И Код возврата команды "gitsync" равен 0
    И Количество коммитов должно быть "6"

Сценарий: Cинхронизация хранилища все вместе
    Допустим Я добавляю параметр "--limit 3" для команды "gitsync"
    И Я добавляю параметр "--minversion 2" для команды "gitsync"
    И Я добавляю параметр "--maxversion 4" для команды "gitsync"
    И Я добавляю позиционный параметр для команды "gitsync" из переменной "КаталогХранилища1С"
    И Я добавляю позиционный параметр для команды "gitsync" из переменной "ПутьКаталогаИсходников"
    Когда Я выполняю команду "gitsync"
    Тогда Вывод команды "gitsync" содержит "ИНФОРМАЦИЯ - Завершена синхронизации с git"
    И Вывод команды "gitsync" не содержит "Внешнее исключение"
    И Код возврата команды "gitsync" равен 0
    И Количество коммитов должно быть "3"