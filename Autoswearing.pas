{$includenamespace ConsoleMethods.pas}
{$includenamespace WordShell.pas}
{$includenamespace Conjugation.pas}
{$includenamespace Time.pas}
{$includenamespace Person.pas}
{$includenamespace Declension.pas}
{$includenamespace Modifiers.pas}
{$includenamespace Gender.pas}
{$includenamespace Case.pas}

{$includenamespace Word.pas}
{$includenamespace Noun.pas}
{$includenamespace Verb.pas}

{$includenamespace Dictionary.pas}
{$includenamespace Swear.pas}
program Autoswearing;

uses System;
uses System.Linq;
uses System.Threading;
uses System.Text;

procedure WriteTitle;
begin
  ConsoleMethods.Write(
    ConsoleColor.Green,
    'Autoswearing', nil, ' - программа, вставляющая слова из словаря в шаблонные конструкции, используя определённые правила', NewLine,
    'Для того чтобы сгенерировать фразу нажмите Enter. Если хотите сгенерировать конкретное слово, напишите шаблон и шажмите Enter', NewLine,
    NewLine,
    'Шаблоны:     <', ConsoleColor.Blue, 'часть_речи', nil, ':', ConsoleColor.White, ' модификаторы', nil, '>', NewLine,
    ConsoleColor.Blue, ' Части речи', nil, ': ', NewLine,
    ConsoleColor.Blue, '   noun', nil, ' - ', 'существительное', NewLine,
    ConsoleColor.Blue, '   verb', nil, ' - ', 'глагол', NewLine,
    NewLine,
    ConsoleColor.White, ' Модификаторы', nil, ': ', NewLine,
    '   Модификаторы изменяют форму слова, либо сужают выборку в словаре через определённый критерий. Также есть модификаторы, которые только меняют внешнее представление слова', NewLine,
    '   Для ', ConsoleColor.Blue, 'noun', nil, ': ', NewLine,
      ConsoleColor.DarkYellow, '      Nominative', nil, ' - меняет падеж слова на ', ConsoleColor.White, 'именительный ', ConsoleColor.DarkYellow, 'падеж', NewLine,
      ConsoleColor.DarkYellow, '      Genitive', nil, ' - меняет падеж слова на ', ConsoleColor.White, 'родительный ', ConsoleColor.DarkYellow, 'падеж', NewLine,
      ConsoleColor.DarkYellow, '      Dative', nil, ' - меняет падеж слова на ', ConsoleColor.White, 'дательный ', ConsoleColor.DarkYellow, 'падеж', NewLine,
      ConsoleColor.DarkYellow, '      Accusative', nil, ' - меняет падеж слова на ', ConsoleColor.White, 'винительный ', ConsoleColor.DarkYellow, 'падеж', NewLine,
      ConsoleColor.DarkYellow, '      Ablative', nil, ' - меняет падеж слова на ', ConsoleColor.White, 'творительный ', ConsoleColor.DarkYellow, 'падеж', NewLine,
      ConsoleColor.DarkYellow, '      Prepositional', nil, ' - меняет падеж слова на ', ConsoleColor.White, 'предложный ', ConsoleColor.DarkYellow, 'падеж', NewLine, nil,
      NewLine,
      ConsoleColor.Magenta, '      Masculine', nil, ' - сужает выборку слов до слов имеющих только ', ConsoleColor.White, 'мужской ', ConsoleColor.Magenta, 'род', NewLine,
      ConsoleColor.Magenta, '      Feminine', nil, ' - сужает выборку слов до слов имеющих только ', ConsoleColor.White, 'женский ', ConsoleColor.Magenta, 'род', NewLine,
      ConsoleColor.Magenta, '      Neuter', nil, ' - сужает выборку слов до слов имеющих только ', ConsoleColor.White, 'средний ', ConsoleColor.Magenta, 'род', NewLine, nil,
      NewLine,
    '   Для ', ConsoleColor.Blue, 'verb', nil, ': ', NewLine,
      ConsoleColor.DarkYellow, '      FirstPerson', nil, ' - меняет лицо глагола на ', ConsoleColor.White, 'первое ', ConsoleColor.DarkYellow, 'лицо', NewLine,
      ConsoleColor.DarkYellow, '      SecondPerson', nil, ' - меняет лицо глагола на ', ConsoleColor.White, 'второе ', ConsoleColor.DarkYellow, 'лицо', NewLine,
      ConsoleColor.DarkYellow, '      ThirdPerson', nil, ' - меняет лицо глагола на ', ConsoleColor.White, 'третье ', ConsoleColor.DarkYellow, 'лицо', NewLine,
      NewLine,
      ConsoleColor.DarkRed, '      Past', nil, ' - изменяет время глагола на ', ConsoleColor.White, 'прошедшее ', ConsoleColor.DarkRed, 'время', NewLine,
      ConsoleColor.DarkRed, '      Present', nil, ' - изменяет время глагола на ', ConsoleColor.White, 'настоящее ', ConsoleColor.DarkRed, 'время', NewLine,
      ConsoleColor.DarkRed, '      Future', nil, ' - изменяет время глагола на ', ConsoleColor.White, 'будущее ', ConsoleColor.DarkRed, 'время', NewLine,
      NewLine,
      ConsoleColor.Magenta, '      Masculine', nil, ' - меняет род глагола на ', ConsoleColor.White, 'мужской ', ConsoleColor.Magenta, 'род', NewLine,
      ConsoleColor.Magenta, '      Feminine', nil, ' - меняет род глагола на ', ConsoleColor.White, 'женский ', ConsoleColor.Magenta, 'род', NewLine,
      ConsoleColor.Magenta, '      Neuter', nil, ' - меняет род глагола на ', ConsoleColor.White, 'средний ', ConsoleColor.Magenta, 'род', NewLine,
      NewLine,
      ConsoleColor.Red, '      imperative', nil, ' - меняет наклонение глагола на ', ConsoleColor.Red, 'повелительное', NewLine,
      ConsoleColor.Red, '      reflexive', nil, ' - превращает глагол в', ConsoleColor.Red, ' возвратный ', nil, 'залог', NewLine,
      ConsoleColor.Cyan, '      ensoulable', nil, ' - сужает выборку глаголов до тех, которые могут быть применены к', ConsoleColor.Cyan, ' одушевлённым', nil, ' сущностям', NewLine,
      ConsoleColor.DarkYellow, '      perfect', nil, ' - сужает выборку глаголов, оставляя только глаголы', ConsoleColor.DarkYellow, ' совершенного ', nil, 'вида', NewLine,
    
    nil, '   Общие: ', NewLine,
      ConsoleColor.Cyan, '      singular', nil, ' - меняет число слова на ', ConsoleColor.White, 'единственное ', ConsoleColor.Cyan, 'число', NewLine,
      ConsoleColor.Cyan, '      plural', nil, ' - меняет число слова на ', ConsoleColor.White, 'множественное ', ConsoleColor.Cyan, 'число', NewLine,
      ConsoleColor.White, '      upperfirst', nil, ' - делает первую букву слова ', ConsoleColor.White, 'прописной', NewLine,
      ConsoleColor.White, '      caps', nil, ' - делает все буквы слова ', ConsoleColor.White, 'прописными', NewLine,
      NewLine
  );
end;

begin
  System.Environment.CurrentDirectory := System.IO.Path.GetDirectoryName(GetEXEFileName);
  Console.Title := 'Autoswearing';
  Dictionary.Init();
  Swear.Init();
  WriteTitle();
  while true do
  begin
    var s := ReadlnString('-> '); Writeln();
    if string.IsNullOrEmpty(s) then Swear.Generate().PrintLines()
    else
    begin
      if (s.Contains('<') and s.Contains('>')) then (new Swear(s)).GetVerse().PrintLines()
      else if (s.Contains('/help')) then WriteTitle();
      Writeln();
    end;
  end;
end.