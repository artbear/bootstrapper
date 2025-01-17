#Использовать xml-parser

&Пластилин(Значение = "junit", Тип = "Массив")
Перем АдаптерыЮнитТестов;

&Пластилин 
Перем ТаблицаРезультатовТестов;

&Пластилин("ДетальнаяТаблицаРезультатовТестов")
&Табакерка 
Перем ФабрикаДетальныхЗаписей;

&Пластилин 
Перем РаботаСДЖСОН;

Перем ПроцессорХМЛ;

&Желудь
&Прозвище("ПарсерТестов")
Процедура ПриСозданииОбъекта()
	ПроцессорХМЛ = Новый СериализацияДанныхXML();
КонецПроцедуры

Функция ТабилцаРезультатов() Экспорт
	ОбновитьТаблицу();
	Возврат ТаблицаРезультатовТестов;
КонецФункции

Процедура ОбновитьТаблицу()
	Для каждого Адаптер Из АдаптерыЮнитТестов Цикл
		ДополнитьТаблицуПоАдаптеру(Адаптер);
	КонецЦикла;
КонецПроцедуры

Процедура ДополнитьТаблицуПоАдаптеру(Адаптер)
	Каталог = Адаптер.ПодкаталогОтчетов();
	Представление = Адаптер.Представление;

	ПодкаталогиОтчетов = НайтиФайлы(Каталог, "*");

	Для Каждого ПодкаталогОтчета Из ПодкаталогиОтчетов Цикл
		Если Не ПодкаталогОтчета.ЭтоКаталог() Тогда
			Продолжить;
		КонецЕсли;

		ПутьМетаданных = ОбъединитьПути(ПодкаталогОтчета.ПолноеИмя, Адаптер.ИмяФайлаМетаданных());
		Метаданные = РаботаСДЖСОН.ПрочитатьИзФайла(ПутьМетаданных);

		Если Метаданные = Неопределено Тогда
			ВызватьИсключение "Не удалось прочитать метаданные отчета из файла " + ПутьМетаданных;
		КонецЕсли;

		Если ЕстьЗаписьПоИдентификатору(Метаданные.Идентификатор) Тогда
			Продолжить;
		КонецЕсли;

		НоваяСтрокаРезультата = ТаблицаРезультатовТестов.Добавить();
		НоваяСтрокаРезультата.Парсер = ЭтотОбъект;
		НоваяСтрокаРезультата.ВидТестов = Метаданные.Тип;
		НоваяСтрокаРезультата.Дата = Метаданные.Дата;
		НоваяСтрокаРезультата.Идентификатор = Метаданные.Идентификатор;

		Результат = ПолучитьРезультаты(ПодкаталогОтчета.ПолноеИмя);

		НоваяСтрокаРезультата.Успешно = Результат.Успешно;
		НоваяСтрокаРезультата.Результаты = Результат.Детали;
		
	КонецЦикла;
КонецПроцедуры

Функция ПолучитьРезультаты(Каталог)
	Результат = Новый Структура("Успешно, Детали");

	Детали = ФабрикаДетальныхЗаписей.Достать();

	ФайлыРезультатов = НайтиФайлы(Каталог, "*.xml");

	Для каждого ФайлРезультата Из ФайлыРезультатов Цикл
		ЗаполнитьРезультатТетстаИзФайла(Детали.Добавить(), ФайлРезультата);
	КонецЦикла;

	Результат.Детали = Детали;

	Если Детали.Количество() = 0 Тогда
		Результат.Успешно = Истина;
	Иначе
		Результат.Успешно = Детали.Итог("Ошибка") + Детали.Итог("НеПройден")  = 0;
	КонецЕсли;

	Возврат Результат;
КонецФункции

Процедура ЗаполнитьРезультатТетстаИзФайла(Результат, Файл)
	
	СодержаниеФайла = ПроцессорХМЛ.ПрочитатьИзФайла(Файл.ПолноеИмя);

	Для каждого ТестовыйНабор Из СодержаниеФайла["testsuites"]._Элементы Цикл

		ИмяНабора = ТестовыйНабор.Значение._Атрибуты["name"];
		Для каждого ЭлементНабора Из ТестовыйНабор.Значение._Элементы Цикл
			Для каждого ТестКейс Из ЭлементНабора.Значение._Элементы Цикл
				ЗаполнитьРезультатПоТестКейсу(Результат, ТестКейс.Значение, ИмяНабора);		
			КонецЦикла;
		КонецЦикла;

	КонецЦикла;

КонецПроцедуры

Процедура ЗаполнитьРезультатПоТестКейсу(Результат, ТестКейс, ИмяНабора)
	Атрибуты = ТестКейс._Атрибуты;
	Результат.Набор = ИмяНабора;
	Результат.Тест = Атрибуты["classname"] + "/" + Атрибуты["name"];
	Результат.Статус = Атрибуты["status"];
	Результат.Ошибка = СтатусЭтоОшибка(Атрибуты["status"]);
	Результат.Пропущен = СтатусЭтоПропущен(Атрибуты["status"]);
	Результат.НеПройден = СтатусЭтоНеПройден(Атрибуты["status"]);
	Результат.Успешно = СтатусЭтоУспешно(Атрибуты["status"]);
	Результат.Время = Число(Атрибуты["time"]);

	Если ТестКейс.Свойство("_Элементы") Тогда
		Результат.Сообщение = ПрочитатьСообщенияИзТеста(ТестКейс._Элементы);
	КонецЕсли;

КонецПроцедуры

Функция ПрочитатьСообщенияИзТеста(ЭлементыТестКейса)
	Сообщения = Новый Массив();
	Для каждого Элемент Из ЭлементыТестКейса Цикл
		Если Элемент.Значение = Неопределено Тогда
			Продолжить;
		КонецЕсли;

		Сообщения.Добавить(Элемент.Значение._Атрибуты["message"]);
	КонецЦикла;

	Возврат СтрСоединить(Сообщения, Символы.ПС);
КонецФункции

Функция СтатусЭтоОшибка(Статус)
	Возврат ?(Статус = "error", 1, 0);
КонецФункции

Функция СтатусЭтоПропущен(Статус)
	Возврат ?(Статус = "skipped", 1, 0);
КонецФункции

Функция СтатусЭтоНеПройден(Статус)
	Возврат ?(Статус = "failure", 1, 0);
КонецФункции

Функция СтатусЭтоУспешно(Статус)
	Возврат ?(Статус = "passed", 1, 0);
КонецФункции

Функция ЕстьЗаписьПоИдентификатору(ИдДляПоиска)
	Возврат ТаблицаРезультатовТестов.Найти(ИдДляПоиска) <> Неопределено; 
КонецФункции