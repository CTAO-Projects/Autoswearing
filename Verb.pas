namespace Autoswearing;

type
  ///Глагол, представь себе
  Verb = class(&Word, ICloneable)
    public auto property Gender: Autoswearing.Gender;
    public auto property Person: Autoswearing.Person;
    public auto property Time: Autoswearing.Time;
    public auto property Conjugation: Autoswearing.Conjugation;
    public auto property Plural: boolean;
    public auto property Infinitive: boolean;
    public auto property PerfectForm: boolean;
    public auto property Imperative: boolean;
    
    private static vowels := new string[10]('а', 'о', 'у', 'ы', 'э', 'я', 'ё', 'ю', 'и', 'е');
    
    private static function Костыль1(s: string; v: array of string): boolean;
    begin
      Result := false;
      for var i := 0 to v.Length - 1 do
      begin
        if s.StartsWith(v[i]) then
        begin
          Result := true;
          exit;
        end;
      end;
    end;
    
    public static function MakeFuture(s: string; perfect: boolean): string;
    begin
      var needhard := Костыль1(s, vowels);
      if needhard then Result := 'съ' + s else Result := 'с' + s;
    end;
    
    public function GetVerb(plural: boolean; gender: Autoswearing.Gender; Person: Autoswearing.Person; time: Autoswearing.Time; reflexive: boolean): Verb;
    begin
      if not Infinitive then raise new ArgumentException('Нельзя образовывать глаголы из иных форм');
      if Conjugation = Autoswearing.Conjugation.OverConjugation then raise new ArgumentException('Нельзя образовывать формы глагола из разноспрягаемых глаголов');
      if reflexive and PerfectForm then raise new ArgumentException('В данной грамматике невозможно создание возвратных форм глаголов совершенного вида');
      Result := Verb(Clone());
      Result.Infinitive := false;
      Result.Gender := gender;
      Result.Person := person;
      Result.Time := time;
      case Conjugation of
        Autoswearing.Conjugation.FirstConjugation:
        begin
          case time of
            Autoswearing.Time.Past:
            begin
              if plural then Result.Value := self.Value.Left(self.Value.Length - 2) + 'ли'
              else
              case gender of
                Autoswearing.Gender.Masculine: Result.Value := self.Value.Left(self.Value.Length - 2) + 'л';
                Autoswearing.Gender.Feminine: Result.Value := self.Value.Left(self.Value.Length - 2) + 'ла';
                Autoswearing.Gender.Neuter: Result.Value := self.Value.Left(self.Value.Length - 2) + 'ло';
              end;
            end;
            Autoswearing.Time.Present:
            begin
              case person of
                Autoswearing.Person.FirstPerson: Result.Value := Plural ? self.Value.Left(self.Value.Length - 2) + 'ем' : self.Value.Left(self.Value.Length - 2) + 'ю';
                Autoswearing.Person.SecondPerson: Result.Value := Plural ? self.Value.Left(self.Value.Length - 2) + 'ете' : self.Value.Left(self.Value.Length - 2) + 'ешь';
                Autoswearing.Person.ThirdPerson: Result.Value := Plural ? self.Value.Left(self.Value.Length - 2) + 'ют' : self.Value.Left(self.Value.Length - 3) + 'ет';
              end;
            end;
            Autoswearing.Time.Future:
            begin
              case person of
                Autoswearing.Person.FirstPerson: Result.Value := MakeFuture(Plural ? self.Value.Left(self.Value.Length - 2) + 'ем' : self.Value.Left(self.Value.Length - 2) + 'ю', PerfectForm);
                Autoswearing.Person.SecondPerson: Result.Value := MakeFuture(Plural ? self.Value.Left(self.Value.Length - 2) + 'ете' : self.Value.Left(self.Value.Length - 2) + 'ешь', PerfectForm);
                Autoswearing.Person.ThirdPerson: Result.Value := MakeFuture(Plural ? self.Value.Left(self.Value.Length - 2) + 'ют' : self.Value.Left(self.Value.Length - 2) + 'ет', PerfectForm);
              end;
            end;
          end;
        end;
        Autoswearing.Conjugation.SecondConjugation:
        begin
          case time of
            Autoswearing.Time.Past:
            begin
              if plural then Result.Value := self.Value.Left(self.Value.Length - 2) + 'ли'
              else
              case gender of
                Autoswearing.Gender.Masculine: Result.Value := self.Value.Left(self.Value.Length - 2) + 'л';
                Autoswearing.Gender.Feminine: Result.Value := self.Value.Left(self.Value.Length - 2) + 'ла';
                Autoswearing.Gender.Neuter: Result.Value := self.Value.Left(self.Value.Length - 2) + 'ло';
              end;
            end;
            Autoswearing.Time.Present:
            begin
              case person of
                Autoswearing.Person.FirstPerson: Result.Value := Plural ? self.Value.Left(self.Value.Length - 2) + 'им' : self.Value.Left(self.Value.Length - 2) + 'ю';
                Autoswearing.Person.SecondPerson: Result.Value := Plural ? self.Value.Left(self.Value.Length - 2) + 'ите' : self.Value.Left(self.Value.Length - 2) + 'ишь';
                Autoswearing.Person.ThirdPerson: Result.Value := Plural ? self.Value.Left(self.Value.Length - 2) + 'ят' : self.Value.Left(self.Value.Length - 3) + 'ит';
              end;
            end;
            Autoswearing.Time.Future:
            begin
              case person of
                Autoswearing.Person.FirstPerson: Result.Value := MakeFuture(Plural ? self.Value.Left(self.Value.Length - 2) + 'им' : self.Value.Left(self.Value.Length - 2) + 'ю', PerfectForm);
                Autoswearing.Person.SecondPerson: Result.Value := MakeFuture(Plural ? self.Value.Left(self.Value.Length - 2) + 'ите' : self.Value.Left(self.Value.Length - 2) + 'ишь', PerfectForm);
                Autoswearing.Person.ThirdPerson: Result.Value := MakeFuture(Plural ? self.Value.Left(self.Value.Length - 2) + 'ят' : self.Value.Left(self.Value.Length - 2) + 'ит', PerfectForm);
              end;
            end;
          end;
        end;
      end;
      if reflexive then Result.Value := Result.Value + 'ся';
    end;
    
    public function GetImperative(reflexive: boolean; gender: Autoswearing.Gender; person: Autoswearing.Person): Verb;
    begin
      if reflexive and PerfectForm then raise new ArgumentException('В данной грамматике невозможно создание возвратных форм глаголов совершенного вида');
      Result := Verb(Clone());
      if Imperative then exit;
      case Conjugation of
        //Autoswearing.Conjugation.FirstConjugation:
      end;
      //todo make imperative verbs
    end;
    
    public function Clone() := MemberwiseClone();
  end;

end.