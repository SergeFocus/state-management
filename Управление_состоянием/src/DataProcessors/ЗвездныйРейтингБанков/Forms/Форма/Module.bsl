#Область УправлениеСостоянием

&НаСервере
Процедура УправлениеФормойНаСервере(ИзмененныеРеквизиты = Неопределено, СохраненноеСостояние = Неопределено)
	РаботаСФормойКлиентСервер.УправлениеФормой(ЭтотОбъект, ИзмененныеРеквизиты, СохраненноеСостояние);	
КонецПроцедуры

&НаКлиенте
Процедура УправлениеФормой(ИзмененныеРеквизиты = Неопределено)
	Перем СохраненноеСостояние;
	Если НЕ РаботаСФормойКлиентСервер.УправлениеФормой(ЭтотОбъект, ИзмененныеРеквизиты, СохраненноеСостояние) Тогда
		УправлениеФормойНаСервере(ИзмененныеРеквизиты, СохраненноеСостояние);
	КонецЕсли;
КонецПроцедуры

#Область ОбработчикиСобытийФормы

//@skip-warning
&НаКлиенте
Процедура ПриАктивизацииСтроки(Элемент)
	РаботаСФормойКлиентСервер.ПриАктивизацииСтроки(ЭтотОбъект, Элемент);
КонецПроцедуры

//@skip-warning
&НаКлиенте
Процедура НачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	РаботаСФормойКлиентСервер.НачалоВыбора(ЭтотОбъект, Элемент, СтандартнаяОбработка);
КонецПроцедуры

#Область ПриИзменении // При расчете может потребоваться изменить контекст, а сделать это можно только в модуле формы

//@skip-warning
//  Процедура продолжает расчет уже в контексте сервера. Такое разделение процедуры нужно для программного переключения контекста
&НаСервере
Процедура РассчитатьСостояниеНаСервере(ИзмененныеРеквизиты, СохраненноеСостояние, ПроверятьЗначение = Ложь)
	РаботаСМодельюКлиентСервер.РассчитатьСостояние(ЭтотОбъект, ИзмененныеРеквизиты, СохраненноеСостояние, ПроверятьЗначение);
	УправлениеФормойНаСервере(ИзмененныеРеквизиты);
КонецПроцедуры

//  Процедура выполняет расчет в контексте клиента
&НаКлиенте
Процедура РассчитатьСостояние(ИзмененныеРеквизиты, ПроверятьЗначение = Ложь)
	Перем СохраненноеСостояние;
	Если НЕ РаботаСМодельюКлиентСервер.РассчитатьСостояние(ЭтотОбъект, ИзмененныеРеквизиты, СохраненноеСостояние, ПроверятьЗначение) Тогда
		РассчитатьСостояниеНаСервере(ИзмененныеРеквизиты, СохраненноеСостояние, ПроверятьЗначение);
	Иначе
		УправлениеФормой(ИзмененныеРеквизиты);
	КонецЕсли;
КонецПроцедуры

//@skip-warning
&НаКлиенте
Процедура ПриИзменении(Элемент)
	Модель = РаботаСМодельюКлиентСервер.МодельОбъекта(ЭтотОбъект);
	Параметр = Модель.Параметры[Модель.ПараметрыЭлементов[Элемент.Имя]];
	Если Параметр = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПроверятьЗначение = ТипЗнч(Элемент) = Тип("ПолеФормы")
		И Элемент.Вид = ВидПоляФормы.ПолеВвода
		И Элемент.ИсторияВыбораПриВводе = ИсторияВыбораПриВводе.Авто;
	
	Если Параметр.ЭтоЭлементКоллекции Тогда
		ИзмененныеРеквизиты = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(РаботаСМодельюКлиентСервер.Реквизит(Параметр.Идентификатор, РаботаСМодельюКлиентСервер.ЗначениеПараметра(ЭтотОбъект, Модель, Модель.Параметры[Параметр.Коллекция + ".ИндексСтроки"])));
	Иначе
		ИзмененныеРеквизиты = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(РаботаСМодельюКлиентСервер.Реквизит(Параметр.Идентификатор));
	КонецЕсли;
	РассчитатьСостояние(ИзмененныеРеквизиты, ПроверятьЗначение);
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#КонецОбласти

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	//  Создание описания модели. Начало
	Модель = РаботаСМодельюКлиентСервер.Модель("МодельЗвездныйРейтинг", "Объект");
	//  Добавление параметра Средний рейтинг
	РаботаСМодельюКлиентСервер.Связь(ЭтотОбъект, Модель, "СреднийРейтинг", "Рейтинг");
//	Модель.Параметры["СреднийРейтинг"].Выражение = "0.5 * Параметры.Рейтинг";
	Модель.Параметры["СреднийРейтинг"].Выражение = "*";
	Модель.Параметры["СреднийРейтинг"].НаСервере = Истина;
	//  Описание самой формы
	РаботаСФормойКлиентСервер.Элемент(ЭтотОбъект, Модель,,, "Рейтинг, СреднийРейтинг");
	//  Закрашенные звезды
	РаботаСФормойКлиентСервер.Элемент(ЭтотОбъект, Модель, Элементы.ДекорацияЗвезда11,, "Рейтинг");
	РаботаСФормойКлиентСервер.Элемент(ЭтотОбъект, Модель, Элементы.ДекорацияЗвезда21,, "Рейтинг");
	РаботаСФормойКлиентСервер.Элемент(ЭтотОбъект, Модель, Элементы.ДекорацияЗвезда31,, "Рейтинг");
	РаботаСФормойКлиентСервер.Элемент(ЭтотОбъект, Модель, Элементы.ДекорацияЗвезда41,, "Рейтинг");
	РаботаСФормойКлиентСервер.Элемент(ЭтотОбъект, Модель, Элементы.ДекорацияЗвезда51,, "Рейтинг");
	//  Незакрашенные звезды
	РаботаСФормойКлиентСервер.Элемент(ЭтотОбъект, Модель, Элементы.ДекорацияЗвезда10,, "Рейтинг");
	РаботаСФормойКлиентСервер.Элемент(ЭтотОбъект, Модель, Элементы.ДекорацияЗвезда20,, "Рейтинг");
	РаботаСФормойКлиентСервер.Элемент(ЭтотОбъект, Модель, Элементы.ДекорацияЗвезда30,, "Рейтинг");
	РаботаСФормойКлиентСервер.Элемент(ЭтотОбъект, Модель, Элементы.ДекорацияЗвезда40,, "Рейтинг");
	РаботаСФормойКлиентСервер.Элемент(ЭтотОбъект, Модель, Элементы.ДекорацияЗвезда50,, "Рейтинг");
	//  Создание описания модели. Конец
	
	РаботаСМоделью.Инициализировать(ЭтотОбъект, Модель);
	
	//  Отображение состояния формы
	УправлениеФормойНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ДекорацияЗвездаНажатие(Элемент)
	Перем ИзмененныеРеквизиты;
	//  Определение состояния звезды
	СоставИмениЭлементаЗвезды = СтрЗаменить(Элемент.Имя, "ДекорацияЗвезда", "");
	СостояниеЗвезды = Прав(СоставИмениЭлементаЗвезды, 1);
	РейтингЗвезды = Лев(СоставИмениЭлементаЗвезды, 1);
	//  Установка нового значения рейтинга по формуле: РейтингЗвезды - СостояниеЗвезды
	РаботаСМодельюКлиентСервер.УстановитьЗначение(ЭтотОбъект, "Рейтинг",, РейтингЗвезды - СостояниеЗвезды, ИзмененныеРеквизиты);
	//  Вызов функции расчета состояния модели и обновления формы. В отличии от функции УправлениеФормой, здесь вначале 
	//  рассчитывается модель, а потом обновляется форма по измененным реквизитам. 
	РассчитатьСостояние(ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(РаботаСМодельюКлиентСервер.Реквизит("Рейтинг")));
	//  Возвращение фокуса на элемент звезды, которая была нажата
	ЭтотОбъект.ТекущийЭлемент = Элементы[СтрШаблон("ДекорацияЗвезда%1%2", РейтингЗвезды, ?(СостояниеЗвезды = "1", "0", "1"))];
КонецПроцедуры
