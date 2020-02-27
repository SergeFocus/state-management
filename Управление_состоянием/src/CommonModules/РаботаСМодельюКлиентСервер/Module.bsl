#Область Определение

Функция Модель(Модуль = "Контекст", ПутьКДанным = "") Экспорт
	Модель = Новый Структура;
	Модель.Вставить("ПутьКДанным", ПутьКДанным);
	Модель.Вставить("Модуль", Модуль);

	Модель.Вставить("Параметры", Новый Соответствие);
	Модель.Вставить("Связи", Новый Соответствие);
	Модель.Вставить("ЗависимыеСвязи", Новый Соответствие);// [Параметр]    -> Массив(Связи)

	Модель.Вставить("ПараметрыЭлементов", Новый Соответствие);       // [ИмяЭлемента] -> Параметр
	Модель.Вставить("ЗависимыеЭлементы", Новый Соответствие);        // [Параметр]    -> Массив(Элементы)
	Модель.Вставить("Элементы", Новый Соответствие);// [ЭлементФормы] = {Имя, Параметры, НаСервере}
	Возврат Модель;
КонецФункции

// Параметры:
//  Контекст
//  Идентификатор
//  ПутьКДанным
//  
// Возвращаемое значение:
//  Структура
//   * Идентификатор - Строка - Имя параметра по имени реквизита объекта или формы или переменной контекста объекта
//   * ПутьКДанным
//
Функция Параметр(Контекст, Модель, Идентификатор, ПутьКДанным = "", ОбработчикПриИзменении = "", Выражение = "", ПроверкаЗаполнения = Истина, НаСервере = Неопределено) Экспорт
	Перем Объект;
	ЭтоКоллекция = Ложь;
	ЭтоЭлементКоллекции = Ложь;
	Коллекция = "";
	СохраняемыеДанные = Ложь;
	СтруктураПараметра = Модель.Параметры[Идентификатор];
	Если СтруктураПараметра <> Неопределено Тогда
		Возврат СтруктураПараметра;
	КонецЕсли;
	Если ЗначениеЗаполнено(Модель.ПутьКДанным) Тогда
		Объект = Вычислить("Контекст." + Модель.ПутьКДанным);
	Иначе
		Объект = Контекст;
	КонецЕсли;
	ЭтоСсылка = Истина;
	Если ЗначениеЗаполнено(ПутьКДанным) Тогда
		СоставПути = СтрРазделить(ПутьКДанным, ".");
		Если СоставПути.ВГраница() = 1 Тогда
			СтруктураБазовогоПараметра = Параметр(Контекст, Модель, СоставПути[0]);
			Коллекция = СтруктураБазовогоПараметра.Идентификатор;
			ЭтоЭлементКоллекции = СоставПути[1] <> "ИндексСтроки";
			СохраняемыеДанные = СтруктураБазовогоПараметра.СохраняемыеДанные;
			//Параметр(Контекст, Модель, Коллекция + ".ИндексСтроки");
		Иначе
			Если ОбщегоНазначенияКлиентСервер.ЕстьРеквизитИлиСвойствоОбъекта(Объект, ПутьКДанным) Тогда
				СохраняемыеДанные = Истина;
			КонецЕсли;
		КонецЕсли;
	ИначеЕсли НЕ ЗначениеЗаполнено(ПутьКДанным) Тогда
		СоставПути = СтрРазделить(Идентификатор, ".");
		Если СоставПути.ВГраница() = 1 Тогда
			СтруктураБазовогоПараметра = Параметр(Контекст, Модель, СоставПути[0]);
			Если СтруктураБазовогоПараметра.ЭтоКоллекция И СоставПути[1] <> "ИндексСтроки" Тогда
				Коллекция = СтруктураБазовогоПараметра.Идентификатор;
				ЭтоЭлементКоллекции = Истина;
				ПутьКДанным = Идентификатор;
				СохраняемыеДанные = СтруктураБазовогоПараметра.СохраняемыеДанные;
				//Параметр(Контекст, Модель, Коллекция + ".ИндексСтроки");
			КонецЕсли;
		Иначе
			Если ОбщегоНазначенияКлиентСервер.ЕстьРеквизитИлиСвойствоОбъекта(Объект, Идентификатор) Тогда
				ПутьКДанным = Идентификатор;
				СохраняемыеДанные = Истина;
			ИначеЕсли ОбщегоНазначенияКлиентСервер.ЕстьРеквизитИлиСвойствоОбъекта(Контекст, Идентификатор) Тогда
				ПутьКДанным = Идентификатор;
				СохраняемыеДанные = Ложь;		
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Если ЗначениеЗаполнено(ПутьКДанным) И НЕ СтрНайти(ПутьКДанным, ".") Тогда
		ЗначениеПараметра = ОбщегоНазначенияКлиентСервер.ПолучитьРеквизитФормыПоПути(?(СохраняемыеДанные, Объект, Контекст), ПутьКДанным);
		Если ТипЗнч(ЗначениеПараметра) = Тип("ДанныеФормыКоллекция")
			ИЛИ ТипЗнч(ЗначениеПараметра) = Тип("ТаблицаЗначений")
			ИЛИ ТипЗнч(Контекст) <> Тип("ФормаКлиентскогоПриложения") 
				И Объект.Метаданные().ТабличныеЧасти.Найти(ПутьКДанным) <> Неопределено Тогда
			ЭтоКоллекция = Истина;
			//Параметр(Контекст, Модель, Идентификатор + ".ИндексСтроки");
		КонецЕсли;
		ТипЗначения = ТипЗнч(ЗначениеПараметра);
		Если ТипЗначения = Тип("Число") ИЛИ ТипЗначения = Тип("Строка") ИЛИ ТипЗначения = Тип("Булево") Тогда
			ЭтоСсылка = Ложь;
		КонецЕсли;
	Иначе
		ЭтоСсылка = Ложь;
	КонецЕсли;
	Если ЭтоКоллекция Тогда
		ЭтоСсылка = Ложь;
	КонецЕсли;
	Если НаСервере = Неопределено Тогда
		Если ЭтоСсылка Тогда
			НаСервере = Истина;
		Иначе
			НаСервере = Ложь;
		КонецЕсли;
	КонецЕсли;
	Параметр = Новый Структура;
	Параметр.Вставить("Идентификатор", Идентификатор);
	Параметр.Вставить("ПутьКДанным", ПутьКДанным);
	Параметр.Вставить("ПриИзменении", ОбработчикПриИзменении);
	Параметр.Вставить("Выражение", Выражение);
	Параметр.Вставить("НаСервере", НаСервере);
	//  Вычисляемые поля
	Параметр.Вставить("ЭтоСсылка", ЭтоСсылка);
	Параметр.Вставить("ЭтоКоллекция", ЭтоКоллекция);
	Параметр.Вставить("ЭтоЭлементКоллекции", ЭтоЭлементКоллекции);
	Параметр.Вставить("Коллекция", Коллекция);
	Параметр.Вставить("Ключ", Неопределено);// определяет ключ для параметра коллекции
	Параметр.Вставить("ПроверкаЗаполнения", ПроверкаЗаполнения);
	Параметр.Вставить("Использование", Истина);
	Параметр.Вставить("СохраняемыеДанные", СохраняемыеДанные);
	Параметр.Вставить("Порядок", Неопределено);
	//  Свойства коллекции
	Параметр.Вставить("ОтборСтрок", Неопределено);
	Параметр.Вставить("ИндексСтроки", Неопределено);
	//
	Параметр.Вставить("ВходящиеСвязи", Новый Массив);
	Параметр.Вставить("ИсходящиеСвязи", Новый Массив);
	Параметр.Вставить("ЗависимыеСвязи", Новый Массив);
	//
	Параметр.Вставить("Свойства", Новый Структура);
	Модель.Параметры[Идентификатор] = Параметр;
//	Если ЭтоЭлементКоллекции Тогда
//		Связь(Контекст, Идентификатор, Коллекция, ОбщийКлиентСервер.ОкончаниеСтрокиПослеРазделителя(ПутьКДанным, "."))
//	КонецЕсли;
	Возврат Параметр;
КонецФункции

//  ВидСвязи - Число - 0- топологическая, 1- сильная, 2- слабая, 3- ПараметрыСвойств
Функция Связь(Контекст, Модель, Приемник, Источник = "", ПутьКДанным = "", Значение = NULL, ПараметрыСвойств = Неопределено, Слабая = Ложь) Экспорт
	Идентификатор = СтрШаблон("%1-%2", Приемник, ?(ЗначениеЗаполнено(Источник), Источник, ПутьКДанным));
	//  Моделирование связей по свойствам источника
	СоставИсточника = СтрРазделить(Источник, ".");
	Если СоставИсточника.ВГраница() = 1 И Модель.Параметры[Источник] = Неопределено Тогда
		//  Входящий параметр является составным
		БазовыйПараметр = Параметр(Контекст, Модель, СоставИсточника[0]);
		Если НЕ БазовыйПараметр.ЭтоКоллекция Тогда
			//  Это реквизит параметра ссылочного типа
			//  Добавление доп.связей: БазовыйПараметр.*<-БазовыйПараметр, Источник<-БазовыйПараметр.*
			ПараметрРеквизитов = Параметр(Контекст, Модель, БазовыйПараметр.Идентификатор + ".*");
			ПараметрРеквизитов.Выражение = СтрШаблон("РаботаСМоделью.ЗначенияРеквизитов(Модель, ""%1"", ""*"")", БазовыйПараметр.Идентификатор);
			ПараметрРеквизитов.НаСервере = Истина;
			ВходящийПараметр = Параметр(Контекст, Модель, Источник);
			ВходящийПараметр.Выражение = СтрШаблон("РаботаСМоделью.ЗначенияРеквизитов(Модель, ""%1"", ""%2"")", ПараметрРеквизитов.Идентификатор, СоставИсточника[1]);
			ВходящийПараметр.НаСервере = Ложь;
			Связь(Контекст, Модель, БазовыйПараметр.Идентификатор + ".*", БазовыйПараметр.Идентификатор, "Ссылка");// БазовыйПараметр.*<-БазовыйПараметр
			Возврат Связь(Контекст, Модель, Приемник, БазовыйПараметр.Идентификатор + ".*", СоставИсточника[1]);// Источник<-БазовыйПараметр.*
		КонецЕсли;					
	КонецЕсли;
	//  Формирование структуры связи
	Связь = Новый Структура;
	Связь.Вставить("Приемник", Приемник);
	Связь.Вставить("Источник", Источник);
	Связь.Вставить("ПутьКДанным", ПутьКДанным);
	Связь.Вставить("Значение", Значение);
	Связь.Вставить("Слабая", Слабая);
	Связь.Вставить("Идентификатор", Идентификатор);
	Связь.Вставить("Использование", Истина);
	Связь.Вставить("Свойства", Новый Структура);
	Если ПараметрыСвойств <> Неопределено Тогда
		Для Каждого ЭлементСтруктуры Из ПараметрыСвойств Цикл
			Связь.Свойства.Вставить(ЭлементСтруктуры.Ключ, ЭлементСтруктуры.Значение);
			ЗависимыеСвязи = Модель.ЗависимыеСвязи[ЭлементСтруктуры.Значение];
			Если ЗависимыеСвязи = Неопределено Тогда
				ЗависимыеСвязи = Новый Массив;
				Модель.ЗависимыеСвязи[ЭлементСтруктуры.Значение] = ЗависимыеСвязи;
			КонецЕсли;
			ЗависимыеСвязи.Добавить(Идентификатор);
		КонецЦикла;
	КонецЕсли;
	//  Добавление к модели
	Модель.Связи[Идентификатор] = Связь;
	//  Добавление ссылки в параметры
	Параметр(Контекст, Модель, Приемник).ВходящиеСвязи.Добавить(Идентификатор);
	Если ЗначениеЗаполнено(Источник) Тогда
		Параметр(Контекст, Модель, Источник).ИсходящиеСвязи.Добавить(Идентификатор);
	КонецЕсли;
	Возврат Связь;
КонецФункции

Функция Реквизит(ИДПараметра, ИндексСтроки = Неопределено) Экспорт
	Возврат Новый Структура("Идентификатор, Параметр, ИндексСтроки", ИдентификаторРеквизита(ИДПараметра, ИндексСтроки), ИДПараметра, ИндексСтроки);
КонецФункции

#КонецОбласти

#Область Сервис

Процедура ОпределитьПорядокПараметра(Модель, ИДПараметра, Порядок, НайденныеПараметры)
	Параметр = Модель.Параметры[ИДПараметра];
	МассивСвязей = Параметр.ИсходящиеСвязи;
	ЗависимыеСвязи = Модель.ЗависимыеСвязи[Параметр.Идентификатор];
	Если ЗависимыеСвязи <> Неопределено Тогда
		ОбщегоНазначенияКлиентСервер.ДополнитьМассив(МассивСвязей, ЗависимыеСвязи, Истина);
	КонецЕсли;
	Для Каждого ИДСвязи Из МассивСвязей Цикл
		Связь = Модель.Связи[ИДСвязи];
		Если (НайденныеПараметры[Связь.Приемник] = Неопределено) Тогда
			ОпределитьПорядокПараметра(Модель, Связь.Приемник, Порядок, НайденныеПараметры);
		КонецЕсли;
	КонецЦикла;
	Порядок = Порядок + 1;
	Модель.Параметры[ИДПараметра].Порядок = Порядок;
	НайденныеПараметры[ИДПараметра] = Истина;
КонецПроцедуры

Процедура ОпределитьПорядок(Модель) Экспорт
	//  Топологическая сортировка
	НайденныеПараметры = Новый Соответствие;
	Уровень = 0;
	Пока Истина Цикл
		ИДПараметра = Неопределено;
		Для Каждого ЭлементПараметра Из Модель.Параметры Цикл
			Если НайденныеПараметры[ЭлементПараметра.Ключ] = Неопределено Тогда
				ИДПараметра = ЭлементПараметра.Ключ;
				Прервать;	
			КонецЕсли;
		КонецЦикла;
		Если ИДПараметра = Неопределено Тогда
			Прервать;
		КонецЕсли;
		ОпределитьПорядокПараметра(Модель, ИДПараметра, Уровень, НайденныеПараметры);
	КонецЦикла;
КонецПроцедуры

Функция ИдентификаторРеквизита(ИДПараметра, ИндексСтроки = Неопределено) Экспорт
	Если ИндексСтроки = Неопределено Тогда
		Возврат ИДПараметра;
	Иначе
		Состав = СтрРазделить(ИДПараметра, ".");
		Возврат СтрШаблон("%1[%2].%3", Состав[0], Формат(ИндексСтроки, "ЧН=0; ЧГ=;"), Состав[1]);
	КонецЕсли;
КонецФункции


Функция СвязьРеквизитов(РеквизитПриемник, РеквизитИсточник) Экспорт
	Возврат Новый Структура("Идентификатор, РеквизитПриемник, РеквизитИсточник", СтрШаблон("%1-%2", РеквизитПриемник.Идентификатор, РеквизитИсточник.Идентификатор), РеквизитПриемник.Идентификатор, РеквизитИсточник.Идентификатор);
КонецФункции

Функция СвойствоПараметра(Контекст, Модель, Параметр, ИндексСтроки = Неопределено, Свойство) Экспорт
	Перем ИДПараметраСвойства;
	Если Параметр.Свойства.Свойство(Свойство, ИДПараметраСвойства) Тогда
		Результат = ЗначениеПараметра(Контекст, Модель, Модель.Параметры[ИДПараметраСвойства], ИндексСтроки);
	Иначе
		Результат = Параметр[Свойство];
	КонецЕсли;
	Если Результат = Неопределено Тогда
		Возврат Ложь;
	Иначе
		Возврат Результат;
	КонецЕсли;
КонецФункции

Функция СвойствоСвязи(Контекст, Модель, Связь, ИндексСтроки = Неопределено, Свойство) Экспорт
	Перем ИДПараметраСвойства;
	Если Связь.Свойства.Свойство(Свойство, ИДПараметраСвойства) Тогда
		Результат = ЗначениеПараметра(Контекст, Модель, Модель.Параметры[ИДПараметраСвойства], ИндексСтроки);
	Иначе
		Результат = Связь[Свойство];
	КонецЕсли;
	Если Результат = Неопределено Тогда
		Возврат Ложь;
	Иначе
		Возврат Результат;
	КонецЕсли;
КонецФункции

Функция МодельОбъекта(Контекст) Экспорт
	Если ТипЗнч(Контекст) = Тип("ФормаКлиентскогоПриложения") Тогда	//@skip-warning
		Возврат Контекст["ХранилищеЗначений"][1].Значение;
	Иначе
		Возврат Контекст.ДополнительныеСвойства["ХранилищеЗначений"][1].Значение;
	КонецЕсли;
КонецФункции

Функция ОбъектПараметра(Контекст, Модель, Параметр, ИндексСтроки = Неопределено, ИмяРеквизита = "") Экспорт
	Если ЗначениеЗаполнено(Параметр.ПутьКДанным) Тогда
		Если Параметр.ЭтоЭлементКоллекции Тогда
			Возврат ПолучитьРеквизитФормыПоПути(Контекст, ПутьКДанным(Модель, Параметр), ИмяРеквизита)[ИндексСтроки];
		Иначе
			Возврат ПолучитьРеквизитФормыПоПути(Контекст, ПутьКДанным(Модель, Параметр), ИмяРеквизита);
		КонецЕсли;
	Иначе//  Это виртуальный параметр
		Если ТипЗнч(Контекст) = Тип("ФормаКлиентскогоПриложения") Тогда
			Объект = Контекст;
		Иначе
			Объект = Контекст.ДополнительныеСвойства;
		КонецЕсли;
		Если Параметр.ЭтоЭлементКоллекции Тогда
			//TODO: КА_ Сделать реализацию для коллекции
		Иначе //@skip-warning
			ХранилищеЗначений = Объект["ХранилищеЗначений"];
			Словарь = ХранилищеЗначений[0].Значение;
			ИндексСтрокиХранилища = Словарь[Параметр.Идентификатор];
			Если ИндексСтрокиХранилища = Неопределено Тогда
				НоваяСтрока = ХранилищеЗначений.Добавить();
				ИндексСтрокиХранилища = ХранилищеЗначений.Индекс(НоваяСтрока);
				Словарь[Параметр.Идентификатор] = ИндексСтрокиХранилища;
			КонецЕсли;
			ИмяРеквизита = "Значение";
			Возврат ХранилищеЗначений[ИндексСтрокиХранилища];
		КонецЕсли;	
	КонецЕсли;
КонецФункции

Функция ЗначениеПараметра(Контекст, Модель, Параметр, ИндексСтроки = Неопределено) Экспорт
	Перем ИмяРеквизита;// данная переменная определяется в функции ПолучитьРеквизитФормыПоПути
	Возврат ОбъектПараметра(Контекст, Модель, Параметр, ИндексСтроки, ИмяРеквизита)[ИмяРеквизита];
КонецФункции

Функция УстановитьЗначение(Контекст, ИДПараметра, ИндексСтроки = Неопределено, Значение, ИзмененныеРеквизиты = Неопределено) Экспорт
	Перем ИмяРеквизита;
	Если ТипЗнч(ИзмененныеРеквизиты) <> Тип("Массив") Тогда
		ИзмененныеРеквизиты = Новый Массив;
	КонецЕсли;
	Модель = МодельОбъекта(Контекст);
	Параметр = Модель.Параметры[ИДПараметра];
	Если ОбщийКлиентСервер.УстановитьЗначение(ОбъектПараметра(Контекст, Модель, Параметр, ИндексСтроки, ИмяРеквизита)[ИмяРеквизита], Значение) Тогда
		ИзмененныеРеквизиты.Добавить(Реквизит(ИДПараметра, ИндексСтроки));
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
КонецФункции

Функция ВыполнитьВыражениеЗначения(Выражение, Контекст, Объект, Модель, Параметры, СтандартнаяОбработка, Отказ)
	Возврат Вычислить(Выражение);// Формат вызова: ЗначениеПараметраХХХХХХХХ(ВходящиеПараметры, СтандартнаяОбработка)
КонецФункции

// Назначение функции в том, чтобы присвоить вычисленное значение реквизиту через ссылку, 
// т.к. иного способа присвоения нет или придется несколько раз обращаться к значению реквизита: для чтения и для записи
//
// Параметры:
//  Модель - Структура - может использоваться для выражения значения параметра или в обработчике ПриИзменении
//  СсылкаНаЗначение - Ссылка
//  СтруктураРеквизита - Структура - 
//  СтрукутраПараметра - Структура - 
//  ВходящиеПараметры - Структура -
//
Функция ЗаполнитьЗначение(Контекст, Объект, Модель, СсылкаНаЗначение, Параметр, ВходящиеПараметры, ДанныеСтроки = Неопределено) Экспорт
	ЕстьИзменение = Ложь;
	Значение = Неопределено;
	Выражение = Параметр.Выражение;
	Если ЗначениеЗаполнено(Выражение) Тогда
		Если Выражение = "*" Тогда
			Выражение = СтрШаблон("%1.Значение%2(Контекст, Объект, Модель, Параметры, СтандартнаяОбработка, Отказ)", Модель.Модуль, Параметр.Идентификатор);
		КонецЕсли;
		СтандартнаяОбработка = Ложь;
		Отказ = Ложь;
		Значение = ВыполнитьВыражениеЗначения(Выражение, Контекст, Объект, Модель, ВходящиеПараметры, СтандартнаяОбработка, Отказ);
		Если Отказ Тогда
			Возврат Ложь;
		КонецЕсли;
	Иначе
		СтандартнаяОбработка = Истина;
	КонецЕсли;
	Если СтандартнаяОбработка Тогда
		Если Параметр.ЭтоСсылка Тогда
			#Если Сервер Тогда
				Значение = РаботаСМоделью.НайтиЗначение(ТипЗнч(СсылкаНаЗначение), ВходящиеПараметры, СсылкаНаЗначение);
				ЕстьИзменение = ОбщийКлиентСервер.УстановитьЗначение(СсылкаНаЗначение, Значение);
			#Иначе
				ВызватьИсключение СтрШаблон("Для определения значение параметра ""%1"" необходим контекст сервера!", Параметр.Идентификатор);
			#КонецЕсли
		Иначе
			Возврат Ложь;
		КонецЕсли;
	Иначе
		ЕстьИзменение = ОбщийКлиентСервер.УстановитьЗначение(СсылкаНаЗначение, Значение);
	КонецЕсли;
	Возврат ЕстьИзменение;
КонецФункции

// Формирует структуру параметров выбора
//  
// Параметры:
//  Контекст
//  Параметр - Структура
//  ИндексСтроки - Число, Неопределено   
//
// Возвращаемое значение:
//  Структура
//   * Отбор - Структура
//
Функция ПараметрыСвязей(Контекст, Модель, Параметр, ИндексСтроки = Неопределено, Отказ = Ложь) Экспорт
	Параметры = Новый Структура;
	Для Каждого ИДСвязи Из Параметр.ВходящиеСвязи Цикл
		Связь = Модель.Связи[ИДСвязи];
		Если НЕ ЗначениеЗаполнено(Связь.ПутьКДанным) Тогда
			Продолжить;
		КонецЕсли;
		// Получение значения параметра связи
		ПараметрИсточника = Модель.Параметры[Связь.Источник];
		Значение = ЗначениеПараметра(Контекст, Модель, ПараметрИсточника, ИндексСтроки);
		Если НЕ СвойствоСвязи(Контекст, Модель, Связь, ИндексСтроки, "Использование")
			ИЛИ НЕ СвойствоПараметра(Контекст, Модель, ПараметрИсточника, ИндексСтроки, "Использование") Тогда
			Продолжить;
		ИначеЕсли (СвойствоПараметра(Контекст, Модель, ПараметрИсточника, ИндексСтроки, "ПроверкаЗаполнения")
				И НЕ ЗначениеЗаполнено(Значение)) Тогда
			Отказ = Истина;
			Прервать;
		КонецЕсли;
		// Добавление параметра в структуру
		СоставПути = СтрРазделить(Связь.ПутьКДанным, ".");
		Если СоставПути.ВГраница() = 1 Тогда
			ВложеннаяСтруктура = Неопределено;
			Если НЕ Параметры.Свойство(СоставПути[0], ВложеннаяСтруктура) Тогда
				ВложеннаяСтруктура = Новый Структура;
				Параметры.Вставить(СоставПути[0], ВложеннаяСтруктура);
			КонецЕсли;
			ВложеннаяСтруктура.Вставить(СоставПути[1], Значение);
		Иначе
			Параметры.Вставить(Связь.ПутьКДанным, Значение);
		КонецЕсли;
	КонецЦикла;
	Возврат Параметры;
КонецФункции

Функция ПутьКДанным(Модель, Параметр) Экспорт
	Если Параметр.СохраняемыеДанные Тогда
		Возврат ?(Модель.ПутьКДанным = "", "", Модель.ПутьКДанным + ".") + Параметр.ПутьКДанным;
	Иначе
		Возврат Параметр.ПутьКДанным;
	КонецЕсли;
КонецФункции

Функция ПолучитьРеквизитФормыПоПути(Контекст, ПутьКДанным, ИмяРеквизита = "")
	ПутьКДаннымОбъекта = Лев(ПутьКДанным, СтрНайти(ПутьКДанным, ".", НаправлениеПоиска.СКонца)-1);
	Если ЗначениеЗаполнено(ПутьКДаннымОбъекта) Тогда
		ИмяРеквизита = ОбщийКлиентСервер.ОкончаниеСтрокиПослеРазделителя(ПутьКДанным);
		Возврат ОбщегоНазначенияКлиентСервер.ПолучитьРеквизитФормыПоПути(Контекст, ПутьКДаннымОбъекта);
	Иначе
		ИмяРеквизита = ПутьКДанным;
		Возврат Контекст;
	КонецЕсли;
КонецФункции

Процедура ДобавитьЗависимыйРеквизит(Модель, Последовательность, ИспользованныеСвязи, ЗависимыйРеквизит, ВедущийРеквизит) Экспорт
	СвязьРеквизитов = СвязьРеквизитов(ЗависимыйРеквизит, ВедущийРеквизит);
	Если НЕ ИспользованныеСвязи[СвязьРеквизитов.Идентификатор] = Неопределено Тогда
		Возврат;
	КонецЕсли;
	Реквизит = Последовательность.Словарь[ЗависимыйРеквизит.Идентификатор];
	Если Реквизит = Неопределено Тогда
		Последовательность.Список.Добавить(Модель.Параметры[ЗависимыйРеквизит.Параметр].Порядок, ЗависимыйРеквизит.Идентификатор);
		Последовательность.Словарь[ЗависимыйРеквизит.Идентификатор] = ЗависимыйРеквизит;
		Реквизит = ЗависимыйРеквизит;
	КонецЕсли;
	ИспользованныеСвязи[СвязьРеквизитов.Идентификатор] = СвязьРеквизитов;
КонецПроцедуры

// Параметры:
//  Контекст - Любой объект - используется для получения данных коллекции
//  Последовательность - Структура - стек рассчитанных зависимостей
//  * Список - СписокЗначений - {Идентификатор, Порядок} - нужен для сортировки по порядку
//  * Словарь - Соответствие - {Идентификатор -> Структура} - нужен для поиска уже добавленных реквизитов. 
//                           Поиск в списке невозможен, т.к. тогда придется хранить структуру в списке 
//  ИспользованныеСвязи - Соответствие - {Идентификатор -> Структура{Идентификатор, РеквизитПриемник, РеквизитИсточник}}. Это словарь пройденных связей
//  ВедущийРеквизит - Структура - {Идентификатор, ИндексСтроки, СтароеЗначение, НовоеЗначение}
//
Функция ДобавитьЗависимыеРеквизиты(Контекст, Модель, ВедущийРеквизит, Последовательность, ИспользованныеСвязи)
	Параметр = Модель.Параметры[ВедущийРеквизит.Параметр];
	МассивСвязей = Параметр.ИсходящиеСвязи;
	ЗависимыеСвязи = Модель.ЗависимыеСвязи[Параметр.Идентификатор];
	Если ЗависимыеСвязи <> Неопределено Тогда
		ОбщегоНазначенияКлиентСервер.ДополнитьМассив(МассивСвязей, ЗависимыеСвязи, Истина);
	КонецЕсли;
	Для Каждого ИДСвязи Из МассивСвязей Цикл
		Связь = Модель.Связи[ИДСвязи];
		Если Связь.ПутьКДанным = "" Тогда
			Продолжить;//  это топологическая связь, которая необходима для топологического порядка расчета или связь, определяющая свойства
		КонецЕсли;
		ЗависимыйПараметр = Модель.Параметры[Связь.Приемник];
		Если НЕ ЗависимыйПараметр.ЭтоЭлементКоллекции 
			ИЛИ ЗависимыйПараметр.Коллекция = Параметр.Коллекция Тогда
			ЗависимыйРеквизит = Реквизит(Связь.Приемник, ВедущийРеквизит.ИндексСтроки);
			Если СвойствоСвязи(Контекст, Модель, Связь, ЗависимыйРеквизит.ИндексСтроки, "Использование")
				И СвойствоПараметра(Контекст, Модель, Модель.Параметры[ЗависимыйРеквизит.Параметр], ЗависимыйРеквизит.ИндексСтроки, "Использование") Тогда
				ДобавитьЗависимыйРеквизит(Модель, Последовательность, ИспользованныеСвязи, ЗависимыйРеквизит, ВедущийРеквизит);
			КонецЕсли; 
		Иначе // Это подчиненная коллекция
			ПараметрКоллекции = Модель.Параметры[ЗависимыйПараметр.Коллекция];
			Коллекция = ОбщегоНазначенияКлиентСервер.ПолучитьРеквизитФормыПоПути(Контекст, ПутьКДанным(Модель, ПараметрКоллекции));
			Для Каждого ЭлементКоллекции Из Коллекция Цикл
				ЗависимыйРеквизит = Реквизит(Связь.Приемник, Коллекция.Индекс(ЭлементКоллекции));
				Если СвойствоСвязи(Контекст, Модель, Связь, ЗависимыйРеквизит.ИндексСтроки, "Использование")
					И СвойствоПараметра(Контекст, Модель, Модель.Параметры[ЗависимыйРеквизит.Параметр], ЗависимыйРеквизит.ИндексСтроки, "Использование") Тогда
					ДобавитьЗависимыйРеквизит(Модель, Последовательность, ИспользованныеСвязи, ЗависимыйРеквизит, ВедущийРеквизит);
				КонецЕсли; 
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
	Возврат Параметр.ИсходящиеСвязи.ВГраница() <> -1;
КонецФункции

Процедура ВыполнитьОбработчикПриИзменении(ОбработчикПриИзменении, Контекст, Объект, ДанныеСтроки, Реквизит, ИзмененныеРеквизиты, РассчитанныеРеквизиты)
	Выполнить(ОбработчикПриИзменении);//  ПриИзменении(Контекст, Объект, Реквизит{Параметр, ИндексСтроки, Значение}, ДанныеСтроки)
КонецПроцедуры

//
// Процедура основного цикла расчета зависимостей от измененных реквизитов
//
// Параметры:
//  Контекст - Любой объект
//  ИзмененныеРеквизиты - Массив - массив реквизитов, от которых необходимо рассчитать зависимости
//  РассчитанныеРеквизиты - Соответствие - коллекция реквизитов с рассчитанными значениями. Измененные переходят в этот список.
//  Последовательность - Структура - содержит словарь и список реквизитов последовательности расчета
//   * Словарь - Соответствие - используется для получения структуры реквизита последовательности расчета
//   * Список - СписокЗначений - используется для сортировки по топологическому порядку параметров реквизитов, где значение - порядок, представление - идентификатор реквизита
//  ИспользованныеСвязи - Соответствие - связи, использованные при расчете зависимостей
//  НаСервере - Булево - признак необходимости вести расчет в контексте сервера
//
Функция РассчитатьСостояние(Контекст, ИзмененныеРеквизиты, Состояние = Неопределено) Экспорт
	Перем Последовательность, РассчитанныеРеквизиты, ИспользованныеСвязи, ИмяРеквизита;
	//  Инициализация/восстановление состояния расчета
	Если Состояние = Неопределено Тогда
		Последовательность = Новый Структура("Список, Словарь", Новый СписокЗначений, Новый Соответствие);
		РассчитанныеРеквизиты = Новый Соответствие;
		ИспользованныеСвязи = Новый Соответствие;
		Состояние = Новый Структура("Последовательность, РассчитанныеРеквизиты, ИспользованныеСвязи", Последовательность, РассчитанныеРеквизиты, ИспользованныеСвязи);
	Иначе
		Последовательность = Состояние.Последовательность;
		РассчитанныеРеквизиты = Состояние.РассчитанныеРеквизиты;
		ИспользованныеСвязи = Состояние.ИспользованныеСвязи;
	КонецЕсли;
	//  Иницализация контекста
	Модель = МодельОбъекта(Контекст);
	Если ЗначениеЗаполнено(Модель.ПутьКДанным) Тогда
		Объект = Контекст[Модель.ПутьКДанным];
	Иначе
		Объект = Контекст;
	КонецЕсли;
	Пока Истина Цикл
		//  Обработка списка измененных реквизитов: добавление в последовательность, поиск зависимых реквизитов, добавление в список обработанных
		Для Каждого Реквизит Из ИзмененныеРеквизиты Цикл
			Параметр = Модель.Параметры[Реквизит.Параметр];
			Если Параметр.ЭтоСсылка И СвойствоПараметра(Контекст, Модель, Параметр, Реквизит.ИндексСтроки, "ПроверкаЗаполнения") И НЕ ЗначениеЗаполнено(ЗначениеПараметра(Контекст, Модель, Параметр, Реквизит.ИндексСтроки)) Тогда
				Продолжить;
			КонецЕсли;
			Последовательность.Список.Добавить(Модель.Параметры[Реквизит.Параметр].Порядок, Реквизит.Идентификатор);
			Последовательность.Словарь[Реквизит.Идентификатор] = Реквизит;
			РассчитанныеРеквизиты[Реквизит.Идентификатор] = Реквизит;
			ДобавитьЗависимыеРеквизиты(Контекст, Модель, Реквизит, Последовательность, ИспользованныеСвязи);
			Последовательность.Список.СортироватьПоЗначению(НаправлениеСортировки.Убыв);
		КонецЦикла;

		ИзмененныеРеквизиты.Очистить();
		
		Если Последовательность.Список.Количество() = 0 Тогда
			Прервать;
		КонецЕсли;
		
		Реквизит = Последовательность.Словарь[Последовательность.Список[0].Представление];
		Параметр = Модель.Параметры[Реквизит.Параметр];

		#Если Клиент Тогда
			Если (Параметр.НаСервере) Тогда
				Возврат Ложь;
			КонецЕсли;
		#КонецЕсли
		
		Последовательность.Словарь.Удалить(Реквизит.Идентификатор);
		Последовательность.Список.Удалить(0);

//		#Если Сервер Тогда
//			ИмяКонтекста = "на сервере";
//		#Иначе
//			ИмяКонтекста = "";
//		#КонецЕсли

		ИндексСтроки = Реквизит.ИндексСтроки;
		
		ЕстьИзменение = Ложь;
		Если РассчитанныеРеквизиты[Реквизит.Идентификатор] = Неопределено Тогда
			РассчитанныеРеквизиты[Реквизит.Идентификатор] = Реквизит;
			//Сообщить("Заполнить значение " + ИмяКонтекста + ": " + Реквизит.Идентификатор);
			Отказ = Ложь;
			ВходящиеПараметры = ПараметрыСвязей(Контекст, Модель, Параметр, ИндексСтроки, Отказ);
			Если Отказ Тогда
				Продолжить;
			КонецЕсли;
			Если ЗначениеЗаполнено(Параметр.ПутьКДанным) Тогда
				//  Это реквизит объекта или контекста
				Если Параметр.ЭтоЭлементКоллекции Тогда
					ДанныеСтроки = ПолучитьРеквизитФормыПоПути(Контекст, ПутьКДанным(Модель, Параметр), ИмяРеквизита)[ИндексСтроки];
					ЕстьИзменение = ЗаполнитьЗначение(Контекст, Объект, Модель, 
						ДанныеСтроки[ИмяРеквизита], 
						Параметр,
						ВходящиеПараметры,
						ДанныеСтроки);
				Иначе
					ЕстьИзменение = ЗаполнитьЗначение(Контекст, Объект, Модель,
						ПолучитьРеквизитФормыПоПути(Контекст, ПутьКДанным(Модель, Параметр), ИмяРеквизита)[ИмяРеквизита],
						Параметр,
						ВходящиеПараметры);
				КонецЕсли;
			Иначе
				//  Это чистый параметр
				ЕстьИзменение = ЗаполнитьЗначение(Контекст, Объект, Модель, ОбъектПараметра(Контекст, Модель, Параметр,, ИмяРеквизита)[ИмяРеквизита], Параметр, ВходящиеПараметры);
			КонецЕсли;
			Если ЕстьИзменение Тогда
				//ИзмененныеРеквизиты.Добавить(РаботаСМодельюКлиентСервер.Реквизит(Параметр.Идентификатор, ИндексСтроки));
				ДобавитьЗависимыеРеквизиты(Контекст, Модель, Реквизит, Последовательность, ИспользованныеСвязи);
				Последовательность.Список.СортироватьПоЗначению(НаправлениеСортировки.Убыв);
			КонецЕсли;
		Иначе
			ЕстьИзменение = Истина;
		КонецЕсли;
		
		Если ЕстьИзменение Тогда
			//Сообщить("ПриИзменении " + ИмяКонтекста + ": " + Реквизит.Идентификатор);
			Параметр = Модель.Параметры[Реквизит.Параметр];
			ОбработчикПриИзменении = Параметр.ПриИзменении;
			Если ЗначениеЗаполнено(ОбработчикПриИзменении) Тогда
				Если ОбработчикПриИзменении = "*" Тогда
					ОбработчикПриИзменении = СтрШаблон("%1.ПриИзменении%2(Контекст, Объект, ДанныеСтроки, Реквизит, ИзмененныеРеквизиты, РассчитанныеРеквизиты)", Модель.Модуль, Параметр.Идентификатор);
				КонецЕсли;
				Если Реквизит.ИндексСтроки <> Неопределено Тогда
					ДанныеСтроки = ПолучитьРеквизитФормыПоПути(Контекст, ПутьКДанным(Модель, Реквизит.Параметр), ИмяРеквизита)[Реквизит.ИндексСтроки];
				Иначе
					ДанныеСтроки = Неопределено;
				КонецЕсли;
				ВыполнитьОбработчикПриИзменении(ОбработчикПриИзменении, Контекст, Объект, ДанныеСтроки, Реквизит, ИзмененныеРеквизиты, РассчитанныеРеквизиты);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	ИзмененныеРеквизиты = ОбщийКлиентСервер.СоответствиеВМассив(РассчитанныеРеквизиты);
	Возврат Истина;
КонецФункции


#КонецОбласти


