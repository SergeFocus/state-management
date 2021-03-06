
#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура ФиксированныеНастройкиОтборВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	Если Поле = Элементы.ФиксированныеНастройкиОтборПравоеЗначение Тогда
		ПоказатьЗначение(, КомпоновщикНастроек.ФиксированныеНастройки.Отбор.ПолучитьОбъектПоИдентификатору(ВыбраннаяСтрока).ПравоеЗначение);
	КонецЕсли; 
КонецПроцедуры

//
&НаСервере
Процедура УстановитьЗаголовок(Заголовок, Количество) 
	Заголовок = Заголовок + ?(Количество = 0, "", "(" + Количество + ")");
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	КоличествоЭлементовКоллекции = КомпоновщикНастроек.ФиксированныеНастройки.Отбор.Элементы.Количество();
	УстановитьЗаголовок(Элементы.СтраницаФиксированныеНастройки.Заголовок, КоличествоЭлементовКоллекции);
	КоличествоЭлементовКоллекции = КомпоновщикНастроек.ФиксированныеНастройки.ПараметрыДанных.Элементы.Количество();
	УстановитьЗаголовок(Элементы.СтраницаПараметрыДанных.Заголовок, КоличествоЭлементовКоллекции);
	Для каждого ЭлементПараметра Из КомпоновщикНастроек.ФиксированныеНастройки.ПараметрыДанных.Элементы Цикл
		СтруктураПараметра = Новый Структура("Параметр,Значение,Использование");
		ЗаполнитьЗначенияСвойств(СтруктураПараметра, ЭлементПараметра);
		Если ТипЗнч(ЭлементПараметра.Значение) = Тип("Массив") Тогда
			СтруктураПараметра.Значение = СтрСоединить(ЭлементПараметра.Значение, ", ");
		КонецЕсли;
		ЗаполнитьЗначенияСвойств(ПараметрыДанных.Добавить(), СтруктураПараметра);
	КонецЦикла;
КонецПроцедуры

#КонецОбласти