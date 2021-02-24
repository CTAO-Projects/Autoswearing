namespace Autoswearing;

uses System;
uses System.Linq;
uses System.Text;

type
  ///Существительное
  Noun = class(&Word, ICloneable)
    public auto property &Case: Autoswearing.Case := Autoswearing.Case.Nominative;
    public auto property &Gender: Autoswearing.Gender;
    public auto property Declension: Autoswearing.Declension;
    public auto property Plural: boolean;
    
    public function Clone() := MemberwiseClone();
    
    public function ConvertToPlural(): Noun;
    begin
      Result := Noun(Clone());
      if Result.Plural then exit;
      Result.Plural := true;
      case Declension of
        Autoswearing.Declension.FirstDeclension: Result.Value := self.Value.Left(self.Value.Length - 1) + 'ы';
        Autoswearing.Declension.SecondDeclension:
        begin
          var tp := 0; //нулевое окончание
          if Gender = Autoswearing.Gender.Masculine then
          begin
            if Value.EndsWith('ий') or (Value[Value.Length - 2] = 'к') or (Value[Value.Length - 2] = 'х') then tp := 4
            else if Value.EndsWith('ей') then tp := 2
            else if (Value.EndsWith('ко')) or (Value.EndsWith('ще')) or (Value.EndsWith('ки')) or (Value.EndsWith('ща')) then tp := 3
            else if (Value.EndsWith('ь')) or (Value.EndsWith('й')) then tp := 4;
          end else tp := 4;
          case tp of
            -1: Result.Value := self.Value.Left(self.Value.Length - 1) + 'а';
            0: Result.Value := self.Value.Left(self.Value.Length) + 'ы';
            1: Result.Value := self.Value + 'и';
            4: Result.Value := self.Value.Left(self.Value.Length - 1) + 'и';
            2: Result.Value := self.Value.Left(self.Value.Length - 2) + 'ьи';
            3: Result.Value := self.Value.Left(self.Value.Length - 2) + 'щи';
          end;
        end;
        Autoswearing.Declension.ThirdDeclension: Result.Value := self.Value.Left(self.Value.Length - 1) + 'и';
      end;
    end;
    
    public function ConvertPluralCase(newcase: Autoswearing.Case): Noun;
    begin
      Result := Noun(Clone());
      if newcase = Autoswearing.Case.Nominative then Result := Result.ConvertToPlural()
      else Result := Result.ConvertCase(newcase);
    end;
    
    public function ConvertCase(newcase: Autoswearing.Case): Noun;
    begin
      Result := Noun(Clone());
      if &Case <> Autoswearing.Case.nominative then raise new ArgumentException('Нельзя преобразовывать к падежам иные формы слова кроме базовых');
      if newcase <> Autoswearing.Case.nominative then Result.Case := newcase;
      case Declension of
        //Склонение первого склонения не зависит от рода слова.
        Autoswearing.Declension.FirstDeclension:
        begin
          case newcase of
            Autoswearing.Case.Nominative: exit;
            Autoswearing.Case.Genitive: Result.Value := 
              self.Value[self.Value.Length - 1] = 'к'
              ? (Plural ? self.Value.Left(self.Value.Length - 2) + 'ок' : (self.Value.Left(self.Value.Length - 1) + 'и'))
              : (Plural ? self.Value.Left(self.Value.Length - 1) : (self.Value.Left(self.Value.Length - 1) + 'ы'));
            Autoswearing.Case.Dative: Result.Value := Plural ? (self.Value.Left(self.Value.Length - 1) + 'ам') : (self.Value.Left(self.Value.Length - 1) + 'е');
            Autoswearing.Case.Accusative: Result.Value := Plural ? self.Value.Left(self.Value.Length - 1) : (self.Value.Left(self.Value.Length - 1) + 'у');
            Autoswearing.Case.Ablative: Result.Value := Plural ? (self.Value.Left(self.Value.Length - 1) + 'ами') : (self.Value.Left(self.Value.Length - 1) + 'ой');
            Autoswearing.Case.Prepositional: Result.Value := Plural ? (self.Value.Left(self.Value.Length - 1) + 'ах') : (self.Value.Left(self.Value.Length - 1) + 'е');
          end;
        end;
        //Разница между склонениями разных падежей во втором склонении почти незаметна. Пока игнорируем.
        Autoswearing.Declension.SecondDeclension:
        begin
          var tp := 0; //нулевое окончание
          if Gender = Autoswearing.Gender.Masculine then
          begin
            if Value.EndsWith('ий') then tp := 1
            else if Value.EndsWith('ей') then tp := 2
            else if (Value.EndsWith('ко')) or (Value.EndsWith('ще')) or (Value.EndsWith('ки')) or (Value.EndsWith('ща')) then tp := 3
            else if (Value.EndsWith('ь')) or (Value.EndsWith('й') or Value.EndsWith('ен')) then tp := 4;
          end else tp := -1;
          case newcase of
            Autoswearing.Case.Nominative: exit;
            Autoswearing.Case.Genitive:
            begin
              case tp of
                -1: Result.Value := Plural ? self.Value.Left(self.Value.Length - 1) : self.Value.Left(self.Value.Length - 1) + 'а';
                0: Result.Value := Plural ? self.Value + 'ов' : self.Value + 'а';
                1: Result.Value := Plural ? self.Value.Left(self.Value.Length - 1) + 'ев' : self.Value.Left(self.Value.Length - 1) + 'я';
                2: Result.Value := Plural ? self.Value.Left(self.Value.Length - 2) + 'ьёв' : self.Value.Left(self.Value.Length - 2) + 'ья';
                3: Result.Value := Plural ? self.Value.Left(self.Value.Length - 2) + 'щ' : self.Value.Left(self.Value.Length - 2) + 'ща';
                4: Result.Value := Plural ? self.Value.Left(self.Value.Length - 1) + 'ей' : self.Value.Left(self.Value.Length - 1) + 'я';
              end;
              exit;
            end;
            Autoswearing.Case.Dative:
            begin
              case tp of
                -1: Result.Value := Plural ? self.Value.Left(self.Value.Length - 1) + 'ам' : self.Value.Left(self.Value.Length - 1) + 'у';
                0: Result.Value := Plural ? self.Value + 'ам' : self.Value + 'у';
                1, 4: Result.Value := Plural ? self.Value.Left(self.Value.Length - 1) + 'ям' : self.Value.Left(self.Value.Length - 1) + 'ю';
                2: Result.Value := Plural ? self.Value.Left(self.Value.Length - 2) + 'щам' : self.Value.Left(self.Value.Length - 2) + 'щу';
                3: Result.Value := Plural ? self.Value.Left(self.Value.Length - 2) + 'ам' : self.Value.Left(self.Value.Length - 2) + 'ку';
              end;
              exit;
            end;
            Autoswearing.Case.Accusative:
            begin
              case tp of
                -1: Result.Value := Plural ? self.Value.Left(self.Value.Length - 1) + 'а' : self.Value.Left(self.Value.Length - 1) + 'о';
                0: Result.Value := Plural ? self.Value + 'ов' : self.Value + 'а';
                1: Result.Value := Plural ? self.Value.Left(self.Value.Length - 1) + 'ев' : self.Value.Left(self.Value.Length - 1) + 'я';
                2: Result.Value := Plural ? self.Value.Left(self.Value.Length - 2) + 'ьёв' : self.Value.Left(self.Value.Length - 2) + 'ья';
                3: Result.Value := Plural ? self.Value.Left(self.Value.Length - 2) + 'щ' : self.Value.Left(self.Value.Length - 2) + 'ще';
                4: Result.Value :=
                Plural
                ? (self.Value.EndsWith('й') or self.Value.EndsWith('ен') ? self.Value.Left(self.Value.Length - 1) + 'и' : self.Value.Left(self.Value.Length - 1) + 'ей')
                : (self.Value.EndsWith('й') or self.Value.EndsWith('ен') ? self.Value : self.Value.Left(self.Value.Length - 1) + 'я');
              end;
              exit;
            end;
            Autoswearing.Case.Ablative:
            begin
              case tp of
                -1: Result.Value := Plural ? self.Value.Left(self.Value.Length - 1) + 'ами' : self.Value.Left(self.Value.Length - 1) + 'ом';
                0: Result.Value := Plural ? self.Value + 'ами' : self.Value + 'ом';
                1: Result.Value := Plural ? self.Value.Left(self.Value.Length - 1) + 'ями' : self.Value.Left(self.Value.Length - 1) + 'ем';
                2: Result.Value := Plural ? self.Value.Left(self.Value.Length - 2) + 'ьями' : self.Value.Left(self.Value.Length - 2) + 'ьём';
                3: Result.Value := Plural ? self.Value.Left(self.Value.Length - 2) + 'щами' : self.Value.Left(self.Value.Length - 2) + 'щем';
                4: Result.Value := Plural ? self.Value.Left(self.Value.Length - 1) + 'ями' : self.Value.Left(self.Value.Length - 1) + 'ём';
              end;
              exit;
            end;
            Autoswearing.Case.Prepositional:
            begin
              case tp of
                -1: Result.Value := Plural ? self.Value.Left(self.Value.Length - 1) + 'ах' : self.Value.Left(self.Value.Length - 1) + 'е';
                0: Result.Value := Plural ? self.Value + 'ах' : self.Value + 'е';
                1, 4: Result.Value := Plural ? self.Value.Left(self.Value.Length - 1) + 'ях' : self.Value.Left(self.Value.Length - 1) + 'е';
                2: Result.Value := Plural ? self.Value.Left(self.Value.Length - 2) + 'ьях' : self.Value.Left(self.Value.Length - 2) + 'ье';
                3: Result.Value := Plural ? self.Value.Left(self.Value.Length - 2) + 'щах' : self.Value.Left(self.Value.Length - 2) + 'ще';
              end;
              exit;
            end;
          end;
        end;
        
        Autoswearing.Declension.ThirdDeclension:
        begin
          var subsoft := Value.EndsWith('чь') or Value.EndsWith('щь'); //ча ща с буквой а, да
          case newcase of
            Autoswearing.Case.Nominative, Autoswearing.Case.Accusative: exit;
            Autoswearing.Case.Genitive: Result.Value := Plural ? self.Value.Left(self.Value.Length - 1) + 'ей' : (self.Value.Left(self.Value.Length - 1) + 'и');
            Autoswearing.Case.Dative: Result.Value := Plural ? (self.Value.Left(self.Value.Length - 1) + (subsoft ? 'ам' : 'ям')) : (self.Value.Left(self.Value.Length - 1) + 'и');
            Autoswearing.Case.Ablative: Result.Value := Plural ? (self.Value.Left(self.Value.Length - 1) + (subsoft ? 'ами' : 'ями')) : (self.Value.Left(self.Value.Length - 1) + 'ью');
            Autoswearing.Case.Prepositional: Result.Value := Plural ? (self.Value.Left(self.Value.Length - 1) + (subsoft ? 'ах' : 'ях')) : (self.Value.Left(self.Value.Length - 1) + 'и');
          end;
        end;
        
        else raise new Exception('Склонение разносклоняемых слов запрещено');
      end;
    end;
    
    public constructor(val: string; cs: Autoswearing.Case; gen: Autoswearing.Gender; dec: Autoswearing.Declension);
    begin
      Value := val;
      &Case := cs;
      Gender := gen;
      Declension := dec;
    end;
  end;

end.