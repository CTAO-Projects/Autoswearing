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

begin
  System.Environment.CurrentDirectory := System.IO.Path.GetDirectoryName(GetEXEFileName);
  Dictionary.Init();
  Swear.Init();
  while true do
  begin
    Swear.Generate.PrintLines;
    Readln;
  end;
end.