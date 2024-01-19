#Использовать logos
#Использовать v8find
#Использовать 1commands
#Использовать gitsync

Перем Лог;              //   Лог                 - объект протоколирования (logger)
Перем Обработчик;       //   Команда             - обработчик текущей команды gitsync
Перем КомандыПлагина;   //   Массив из Строка    - список команд к которым подключается текущий плагин
Перем ТекущаяКоманда;   //   Строка              - имя выполняемой команды gitsync

Перем РабочийКаталогIBCMD;   //   Строка    - путь к рабочему каталогу утилиты ibcmd
Перем ТипСУБД;               //   Строка    - тип сервера базы данных
Перем СерверБД;              //   Строка    - адрес сервера базы данных
Перем ИмяБД;                 //   Строка    - имя базы данных
Перем ПользовательБД;        //   Строка    - имя пользователя базы данных
Перем ПарольБД;              //   Строка    - пароль пользователя базы данных
Перем Инкрементально;        //   Булево    - Истина - будет выполнена инкрементальная выгрузка если возможно

Перем ИнкрементальнаяВыгрузкаВозможна;   //   Булево    - Истина - инкрементальная выгрузка возможна
Перем ПутьКФайлуДампаИзменений;          //   Строка    - путь к файлу ConfigDumpInfo.xml

#Область Интерфейс_плагина

// Возвращает версию плагина
//
//  Возвращаемое значение:
//   Строка - текущая версия плагина
//
Функция Версия() Экспорт
	Возврат "1.0.1";
КонецФункции

// Возвращает приоритет выполнения плагина
//
//  Возвращаемое значение:
//   Число - приоритет выполнения плагина
//
Функция Приоритет() Экспорт
	Возврат 0;
КонецФункции

// Возвращает описание плагина
//
//  Возвращаемое значение:
//   Строка - описание функциональности плагина
//
Функция Описание() Экспорт
	Возврат "Плагин включает использование утилиты ibcmd для выгрузки конфигурации в файлы";
КонецФункции

// Возвращает подробную справку к плагину 
//
//  Возвращаемое значение:
//   Строка - подробная справка для плагина
//
Функция Справка() Экспорт
	Возврат "Плагин включает использование утилиты ibcmd для выгрузки конфигурации в файлы
	        |Рекомендуется отключить плагин ""increment"", если он используется
	        |и использовать флаг --increment для инкрементальной выгрузки.";
КонецФункции

// Возвращает имя плагина
//
//  Возвращаемое значение:
//   Строка - имя плагина при подключении
//
Функция Имя() Экспорт
	Возврат "use-ibcmd";
КонецФункции 

// Возвращает имя лога плагина
//
//  Возвращаемое значение:
//   Строка - имя лога плагина
//
Функция ИмяЛога() Экспорт
	Возврат СтрШаблон("oscript.lib.gitsync.plugins.%1", Имя());
КонецФункции

#КонецОбласти

#Область Подписки_на_события

Процедура ПриАктивизации(СтандартныйОбработчик) Экспорт

	Обработчик = СтандартныйОбработчик;

	РабочийКаталогIBCMD = "";
	ТипСУБД             = "MSSQLServer";
	СерверБД            = "localhost";
	ИмяБД               = "";
	ПользовательБД      = "sa";
	ПарольБД            = "";
	Инкрементально      = Ложь;

	Если НЕ (ВРег(ТекущаяКоманда) = "ALL"
	 ИЛИ ВРег(ТекущаяКоманда) = "SYNC") Тогда
		Возврат;
	КонецЕсли;

	МенеджерПлагинов   = ПараметрыПриложения.МенеджерПлагинов();
	ИндексПлагинов     = МенеджерПлагинов.ПолучитьИндексПлагинов();
	ОтключаемыеПлагины = ОтключаемыеПлагины();

	Для Каждого ТекЭлемент Из ИндексПлагинов Цикл
		Если ОтключаемыеПлагины.Найти(ВРег(ТекЭлемент.Ключ)) = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		Если НЕ ТекЭлемент.Значение.Включен() Тогда
			Продолжить;
		КонецЕсли;

		Лог.Информация("Плагин ""%1"" не совместим с плагином ""%2"" и будет отключен на время выполнения синхронизации!",
		               ТекЭлемент.Ключ,
		               Имя());
		ТекЭлемент.Значение.Отключить();
		Если ВРег(ТекЭлемент.Ключ) = ИмяПлагинаИнкрементальнойВыгрузки() Тогда
			Лог.Информация("Плагин ""%1"" отключен, будет использован параметр ""--increment""!", ТекЭлемент.Ключ);
			Инкрементально = Истина;
		КонецЕсли;

	КонецЦикла;

КонецПроцедуры

Процедура ПриРегистрацииКомандыПриложения(ИмяКоманды, КлассРеализации) Экспорт

	ТекущаяКоманда = ИмяКоманды;

	Лог.Отладка("Ищу команду <%1> в списке поддерживаемых", ИмяКоманды);
	Если КомандыПлагина.Найти(ИмяКоманды) = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Лог.Отладка("Устанавливаю дополнительные параметры для команды %1", ИмяКоманды);

	КлассРеализации.Опция("d ibcmd-data", "", "[*use-ibcmd] рабочий каталог утилиты ibcmd")
	               .ТСтрока()
	               .ВОкружении("GITSYNC_IBCMD_DATA");

	КлассРеализации.Опция("t ibcmd-dbms", "MSSQLServer", "[*use-ibcmd] тип СУБД (при использовании ibcmd)")
	               .ТСтрока()
	               .ВОкружении("GITSYNC_IBCMD_DBMS");

	КлассРеализации.Опция("s ibcmd-db-server", "", "[*use-ibcmd] адрес сервера базы данных (при использовании ibcmd)")
	               .ТСтрока()
	               .ВОкружении("GITSYNC_IBCMD_DB_SERVER");

	КлассРеализации.Опция("n ibcmd-db-name", "", "[*use-ibcmd] имя базы данных (при использовании ibcmd)")
	               .ТСтрока()
	               .ВОкружении("GITSYNC_IBCMD_DB_NAME");

	КлассРеализации.Опция("U ibcmd-db-user", "", "[*use-ibcmd] имя пользователя базы данных (при использовании ibcmd)")
	               .ТСтрока()
	               .ВОкружении("GITSYNC_IBCMD_DB_USER");

	КлассРеализации.Опция("P ibcmd-db-pwd", "", "[*use-ibcmd] пароль пользователя базы данных (при использовании ibcmd)")
	               .ТСтрока()
	               .ВОкружении("GITSYNC_IBCMD_DB_PWD");
	КлассРеализации.Опция("i increment",
	                      Ложь,
	                      "[*use-ibcmd] флаг использования инкрементальной выгрузки конфигурации, если возможно")
	               .Флаговый()
	               .ВОкружении("GITSYNC_IBCMD_INCREMENT");

КонецПроцедуры

Процедура ПриПолученииПараметров(ПараметрыКоманды) Экспорт

	РабочийКаталогIBCMD = ПараметрыКоманды.Параметр("ibcmd-data"     , "");
	ТипСУБД             = ПараметрыКоманды.Параметр("ibcmd-dbms"     , "MSSQLServer");
	СерверБД            = ПараметрыКоманды.Параметр("ibcmd-db-server", "localhost");
	ИмяБД               = ПараметрыКоманды.Параметр("ibcmd-db-name"  , "");
	ПользовательБД      = ПараметрыКоманды.Параметр("ibcmd-db-user"  , "sa");
	ПарольБД            = ПараметрыКоманды.Параметр("ibcmd-db-pwd"   , "");
	Если НЕ Инкрементально Тогда
		Инкрементально      = ПараметрыКоманды.Параметр("increment", Ложь);
	КонецЕсли;

КонецПроцедуры

Процедура ПередВыгрузкойКонфигурациюВИсходники(Конфигуратор,
                                               КаталогРабочейКопии,
                                               КаталогВыгрузки,
                                               ПутьКХранилищу,
                                               НомерВерсии) Экспорт

	ФайлДампаИзменений = Новый Файл(ОбъединитьПути(КаталогРабочейКопии, ИмяФайлаДампаИзменений()));
	ПутьКФайлуДампаИзменений = ФайлДампаИзменений.ПолноеИмя;

	ИнкрементальнаяВыгрузкаВозможна = (Инкрементально
	                                 И ИнкрементальнаяВыгрузкаВозможна(Конфигуратор, ПутьКФайлуДампаИзменений));

КонецПроцедуры

Процедура ПриВыгрузкеКонфигурациюВИсходники(Конфигуратор, КаталогВыгрузки, СтандартнаяОбработка) Экспорт

	СтандартнаяОбработка = Ложь;

	Лог.Информация("Используем утилиту ibcmd для выгрузки конфигурации в файлы");

	Попытка
		ВыгрузитьКонфигурациюВФайлыIBCMD(Конфигуратор, КаталогВыгрузки);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		Лог.Ошибка("Невозможно выгрузить конфигурацию в файлы. Ошибка:%1%2", Символы.ПС, ТекстОшибки);
		ВызватьИсключение;
	КонецПопытки;

КонецПроцедуры

Процедура ПриОчисткеКаталогаРабочейКопии(КаталогРабочейКопии,
                                         СоответствиеИменФайловДляПропуска,
                                         СтандартнаяОбработка) Экспорт

	Если Инкрементально И ИнкрементальнаяВыгрузкаВозможна Тогда
		СтандартнаяОбработка = Ложь;
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область Вспомогательные_процедуры_и_функции

// Процедура - выполняет выгрузку конфигурации в файлы с использованием утилиты ibcmd
//
// Параметры:
//   Конфигуратор       - УправлениеКонфигуратором    - объект управления конфигуратором (v8runner)
//   КаталогВыгрузки    - Строка                      - каталог для выгрузки файлов конфигурации
//
Процедура ВыгрузитьКонфигурациюВФайлыIBCMD(Знач Конфигуратор, Знач КаталогВыгрузки)

	ИмяРасширения    = Обработчик.ПолучитьИмяРасширения();

	ПутьКIBCMD = Платформа1С.ПутьКIBCMD(Обработчик.ТекущаяВерсияПлатформы);

	КомандаIBCMD = Новый Команда;
	КомандаIBCMD.УстановитьКоманду(ПутьКIBCMD);
	КомандаIBCMD.ПоказыватьВыводНемедленно(Истина);
	КомандаIBCMD.УстановитьКодировкуВывода("UTF-8");
	КомандаIBCMD.ДобавитьПараметр("infobase config export");
	КомандаIBCMD.ДобавитьПараметр(СтрШаблон("--data=%1", РабочийКаталогIBCMD));

	ДобавитьПараметрыПодключенияКИБ(КомандаIBCMD, Конфигуратор);

	Если ИнкрементальнаяВыгрузкаВозможна Тогда
		КомандаIBCMD.ДобавитьПараметр(СтрШаблон("--base=%1", ПутьКФайлуДампаИзменений));
	КонецЕсли;
	Если ЗначениеЗаполнено(ИмяРасширения) Тогда
		КомандаIBCMD.ДобавитьПараметр(СтрШаблон("--extension=%1", ИмяРасширения));
	КонецЕсли;
	КомандаIBCMD.ДобавитьПараметр("--force");

	ФайлКонфигурации = Новый Файл(ОбъединитьПути(КаталогВыгрузки, "Configuration.xml"));
	Если ФайлКонфигурации.Существует() Тогда
		КомандаIBCMD.ДобавитьПараметр("--sync");
	КонецЕсли;

	КомандаIBCMD.ДобавитьПараметр(КаталогВыгрузки);

	КодВозврата = КомандаIBCMD.Исполнить();

	Если КодВозврата <> 0 Тогда
		ТекстОшибки = КомандаIBCMD.ПолучитьВывод();
		Лог.КритичнаяОшибка("Не удалось выгрузить конфигурацию в файлы с использованием IBCMD:%1%2",
		                    Символы.ПС,
		                    ТекстОшибки);
	КонецЕсли;

КонецПроцедуры // ВыгрузитьКонфигурациюВФайлыIBCMD()

// Функция проверяет возможность инкрементальной выгрузки конфигурации в файлы
//
// Параметры:
//   Конфигуратор                - УправлениеКонфигуратором    - объект управление конфигуратором (v8runner)
//   ПутьКФайлуДампаИзменений    - Строка                      - путь к файлу ConfigDumpInfo.xml
//
//  Возвращаемое значение:
//   Булево - Истина - возможна инкрементальная выгрузка
//
Функция ИнкрементальнаяВыгрузкаВозможна(Знач Конфигуратор, Знач ПутьКФайлуДампаИзменений)

	Лог.Информация("Определяю тип возможной выгрузки конфигурации в файлы");

	Результат = Ложь;

	ИмяРасширения    = Обработчик.ПолучитьИмяРасширения();

	ФайлДампаИзменений = Новый Файл(ПутьКФайлуДампаИзменений);

	ПутьКФайлуПроверки = ПолучитьИмяВременногоФайла("dmp");

	Лог.Отладка("Проверяю существование файла <%1> в каталоге <%2>, файл <%3>", 
	            ФайлДампаИзменений.Имя,
	            ФайлДампаИзменений.Путь,
	            ?(ФайлДампаИзменений.Существует(), "существует", "отсутствует"));

	Если НЕ ФайлДампаИзменений.Существует() Тогда
		Лог.Отладка("Инкрементальная выгрузка конфигурации - НЕВОЗМОЖНА");
		Лог.Информация("ИНФОРМАЦИЯ - Тип выгрузки конфигурации в файлы: ПОЛНАЯ ВЫГРУЗКА");
		Возврат Результат;
	КонецЕсли;

	Лог.Отладка("Проверяю возможность обновления выгрузки для файла <%1>", ПутьКФайлуДампаИзменений);

	ПутьКIBCMD = Платформа1С.ПутьКIBCMD(Обработчик.ТекущаяВерсияПлатформы);

	КомандаIBCMD = Новый Команда;
	КомандаIBCMD.УстановитьКоманду(ПутьКIBCMD);
	КомандаIBCMD.ПоказыватьВыводНемедленно(Ложь);
	КомандаIBCMD.УстановитьКодировкуВывода("UTF-8");
	КомандаIBCMD.ДобавитьПараметр("infobase config export status");
	КомандаIBCMD.ДобавитьПараметр(СтрШаблон("--data=%1", РабочийКаталогIBCMD));

	ДобавитьПараметрыПодключенияКИБ(КомандаIBCMD, Конфигуратор);

	КомандаIBCMD.ДобавитьПараметр(СтрШаблон("--base=%1", ПутьКФайлуДампаИзменений));
	КомандаIBCMD.ДобавитьПараметр(СтрШаблон("--out=%1", ПутьКФайлуПроверки));
	Если ЗначениеЗаполнено(ИмяРасширения) Тогда
		КомандаIBCMD.ДобавитьПараметр(СтрШаблон("--extension=%1", ИмяРасширения));
	КонецЕсли;

	КодВозврата = КомандаIBCMD.Исполнить();

	Если КодВозврата <> 0 Тогда
		ТекстОшибки = КомандаIBCMD.ПолучитьВывод();
		Лог.КритичнаяОшибка("Не удалось получить информацию об изменениях конфигурации:%1%2",
		                    Символы.ПС,
		                    ТекстОшибки);
	КонецЕсли;

	ФайлПроверки = Новый Файл(ПутьКФайлуПроверки);

	Если ФайлПроверки.Существует() Тогда
		СтрокаПолныйДамп = "modified: all";
		ЧтениеФайла = Новый ЧтениеТекста(ПутьКФайлуПроверки);
		СтрокаПроверки = Лев(ЧтениеФайла.ПрочитатьСтроку(), СтрДлина(СтрокаПолныйДамп));

		Если Не ПустаяСтрока(СокрЛП(СтрокаПроверки)) Тогда

			Лог.Отладка("Строка проверки на возможность выгрузки конфигурации: <%1> = <%2> ", СтрокаПолныйДамп, СтрокаПроверки);
			Результат = НЕ (ВРег(СтрокаПроверки) = ВРег(СтрокаПолныйДамп));

		КонецЕсли;
		ЧтениеФайла.Закрыть();
		УдалитьФайлы(ПутьКФайлуПроверки);
	КонецЕсли;

	Лог.Отладка("Инкрементальная выгрузка конфигурации - %1", ?(Результат, "ВОЗМОЖНА", "НЕВОЗМОЖНА"));

	СпособВыгрузки = ?(Результат, "ИНКРЕМЕНТАЛЬНАЯ ВЫГРУЗКА", "ПОЛНАЯ ВЫГРУЗКА");

	Лог.Информация("ИНФОРМАЦИЯ - Тип выгрузки конфигурации в файлы: %1%2", СпособВыгрузки, Символы.ПС);

	Возврат Результат;

КонецФункции // ИнкрементальнаяВыгрузкаВозможна()

// Процедура - добавляет параметры подключения к информационной базе для команды запуска утилиты ibcmd
//
// Параметры:
//   Команда         - Команда                     - объект - описание команды запуска (1commands) утилиты ibcmd
//   Конфигуратор    - УправлениеКонфигуратором    - объект управления конфигуратором (v8runner)
//
Процедура ДобавитьПараметрыПодключенияКИБ(Команда, Конфигуратор)

	КонтекстКонфигуратора = Конфигуратор.ПолучитьКонтекст();
	
	СтрокаСоединения = КонтекстКонфигуратора.КлючСоединенияСБазой;
	Пользователь     = КонтекстКонфигуратора.ИмяПользователя;
	Пароль           = КонтекстКонфигуратора.Пароль;

	СервернаяБаза = Ложь;
	ПутьКБД = "";

	Если Лев(СтрокаСоединения, 2) = "/F" Тогда
		ПутьКБД = СокрЛП(Сред(СтрокаСоединения, 3));
	ИначеЕсли Лев(СтрокаСоединения, 2) = "/S" Тогда
		СервернаяБаза = Истина;
		ЧастиПути = СтрРазделить(Сред(СтрокаСоединения, 3), "\", Ложь);
		Если НЕ ЗначениеЗаполнено(СерверБД) Тогда
			СерверБД = СокрЛП(ЧастиПути[0]);
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(ИмяБД) И ЧастиПути.Количество() > 1 Тогда
			ИмяБД = СокрЛП(ЧастиПути[1]);
		КонецЕсли;
	Иначе
		ПутьКБД = Конфигуратор.ПутьКВременнойБазе();
	КонецЕсли;

	Если СервернаяБаза Тогда
		Команда.ДобавитьПараметр(СтрШаблон("--dbms=%1", ТипСУБД));
		Команда.ДобавитьПараметр(СтрШаблон("--db-server=%1", СерверБД));
		Команда.ДобавитьПараметр(СтрШаблон("--db-name=%1", ИмяБД));
		Команда.ДобавитьПараметр(СтрШаблон("--db-user=%1", ПользовательБД));
		Команда.ДобавитьПараметр(СтрШаблон("--db-pwd=%1", ПарольБД));
	Иначе
		Команда.ДобавитьПараметр(СтрШаблон("--db-path=%1", ПутьКБД));
	КонецЕсли;
	Если ЗначениеЗаполнено(Пользователь) Тогда
		Команда.ДобавитьПараметр(СтрШаблон("--user=%1", Пользователь));
		Если ЗначениеЗаполнено(Пароль) Тогда
			Команда.ДобавитьПараметр(СтрШаблон("--pwd=%1", Пароль));
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры // ДобавитьПараметрыПодключенияКИБ()

// Функция возвращает имя файла дампа изменений
//
//  Возвращаемое значение:
//   Строка - "ConfigDumpInfo.xml" имя файла дампа изменений
//
Функция ИмяФайлаДампаИзменений()
	Возврат "ConfigDumpInfo.xml";
КонецФункции // ИмяФайлаДампаИзменений()

// Функция возвращает имя плагина инкрементальной выгрузки
//
//  Возвращаемое значение:
//   Строка - "INCREMENT" имя плагина инкрементальной выгрузки
//
Функция ИмяПлагинаИнкрементальнойВыгрузки()
	Возврат "INCREMENT";
КонецФункции // ИмяПлагинаИнкрементальнойВыгрузки()

// Функция возвращает имя плагина инкрементальной выгрузки
//
//  Возвращаемое значение:
//   ФиксированныйМассив из Строка - список отключаемых плагинов
//
Функция ОтключаемыеПлагины()

	ОтключаемыеПлагины = Новый Массив();
	ОтключаемыеПлагины.Добавить(ИмяПлагинаИнкрементальнойВыгрузки());

	Возврат Новый ФиксированныйМассив(ОтключаемыеПлагины);

КонецФункции // ОтключаемыеПлагины()

#КонецОбласти

Процедура Инициализация()

	Лог = Логирование.ПолучитьЛог(ИмяЛога());
	КомандыПлагина = Новый Массив;
	КомандыПлагина.Добавить("sync");

КонецПроцедуры

Инициализация();
