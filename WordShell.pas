namespace Autoswearing;

type
  WordShell = class
    public auto property WordType: string;
    public auto property Modifiers: array of string;
    
    public constructor(wt: string; params mods: array of string);
    begin
      WordType := wt;
      Modifiers := mods;
    end;
    
    private static splitters: array of char = (' ', ':');
    
    public constructor(s: string);
    begin
      var tw := s.ToWords(splitters);
      WordType := tw.First;
      Modifiers := new string[tw.Length - 1];
      for var i := 1 to Modifiers.Length do
        Modifiers[i - 1] := tw[i];
    end;
    
    private static casenames: array of string;
    private static timenames: array of string;
    private static personnames: array of string;
    private static gendernames: array of string;
    
    static constructor;
    begin
      casenames := Enum.GetNames(typeof(&Case));
      timenames := Enum.GetNames(typeof(Time));
      personnames := Enum.GetNames(typeof(Person));
      gendernames := Enum.GetNames(typeof(Gender));
    end;
    
    public function Find: string;
    begin
      case WordType.ToLower of
        'noun':
        begin
          var nouns := Dictionary.This.Where(x -> x is Noun).Select(x -> x as Noun).ToArray();
          var anyplural := Modifiers.Contains('plural');
          var anycase := Modifiers.Any(x -> casenames.Contains(x));
          if anyplural or anycase then
          begin
            var &case := Nominative;
            var plural := false;
            if anyplural then plural := true;
            if anycase then &case := Autoswearing.Case(Autoswearing.Case.Parse(typeof(Autoswearing.Case), Modifiers.First(x -> x in casenames)));
            Result := plural ? nouns[PABCSystem.Random(nouns.Length - 1)].ConvertPluralCase(&case).Value : nouns[PABCSystem.Random(nouns.Length - 1)].ConvertCase(&case).Value;
          end
          else
          begin
            Result := nouns[PABCSystem.Random(nouns.Length - 1)].Value;
          end;
        end;
        'verb':
        begin
          var verbs := Dictionary.This.Where(x -> x is Verb).Select(x -> x as Verb).ToArray();
          var anyplural := Modifiers.Contains('plural');
          var anyimperative := Modifiers.Contains('imperative');
          var anytime := Modifiers.Any(x -> timenames.Contains(x));
          var anyperson := Modifiers.Any(x -> personnames.Contains(x));
          var anygender := Modifiers.Any(x -> gendernames.Contains(x));
          var anyperfect := Modifiers.Contains('perfect');
          var anyreflexive := Modifiers.Contains('reflexive');
          if anyimperative then
          begin
            Result := verbs.Where(x -> not x.PerfectForm).ToArray()[PABCSystem.Random(verbs.Length - 1)].GetImperative(anyreflexive).Value;
          end
          else if anygender or anyperson or anytime or anyplural then
          begin
            var _time := Time(PABCSystem.Random(3));
            var _gender := Gender(PABCSystem.Random(3));
            var _person := Person(PABCSystem.Random(3));
            var _perfect := anyperfect;
            var plural := anyplural;
            if anytime then _time := Time(Enum.Parse(typeof(Time), Modifiers.First(x -> timenames.Contains(x))));
            if anygender then _gender := Gender(Enum.Parse(typeof(Gender), Modifiers.First(x -> gendernames.Contains(x))));
            if anyperson then _person := Person(Enum.Parse(typeof(Person), Modifiers.First(x -> personnames.Contains(x))));
            if _perfect then verbs := verbs.Where(x -> x.PerfectForm).ToArray();
            Result := verbs[verbs.Length - 1].GetVerb(plural, _gender, _person, _time, anyreflexive).Value;
          end
          else
          begin
            if anyperfect then verbs := verbs.Where(x -> x.PerfectForm).ToArray();
            Result := verbs[verbs.Length - 1].Value;
          end;
        end;
      end;
      if Modifiers.Contains('upperfirst') then Result := Result[1].ToUpper + Result.Right(Result.Length - 1);
      if Modifiers.Contains('caps') then Result := Result.ToUpper;
    end;
  end;

end.