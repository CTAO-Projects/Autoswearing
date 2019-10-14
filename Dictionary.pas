namespace Autoswearing;

type
  ///Словарь слов, ясно?
  Dictionary = static class
    private static dict: array of &Word;
    public static property This: array of &Word read dict write dict;
    
    public static procedure Init();
    const splitters: array of char = (' ', ',');
    begin
      var lst := new List<&Word>(256);
      var txt := System.IO.File.ReadAllLines('dictionary.dat');
      for var i := 0 to txt.Length - 1 do
      begin
        var s := txt[i].Trim();
        if not (string.IsNullOrWhiteSpace(s) or s.StartsWith('//')) then
        begin
          var ind1 := s.IndexOf('(');
          var ind2 := s.IndexOf(')');
          var value := s.Substring(0, ind1 - 1).Trim;
          var options := s.Substring(ind1 + 1, ind2 - ind1 - 1).ToWords(splitters).ConvertAll(x -> x.ToLower);
          var tp := options.First;
          case tp of
            'noun':
            begin
              var current := new Noun();
              current.Value := value;
              
              if options.Length > 1 then
              for var j := 1 to options.Length - 1 do
              case options[j] of
                'firstdeclension': current.Declension := Declension.FirstDeclension;
                'seconddeclension': current.Declension := Declension.SecondDeclension;
                'thirddeclension': current.Declension := Declension.ThirdDeclension;
                'overdeclension': current.Declension := Declension.Overdeclension;
                
                'masculine': current.Gender := Gender.Masculine;
                'feminine': current.Gender := Gender.Feminine;
                'neuter': current.Gender := Gender.Neuter;
              end;
              
              lst.Add(current);
            end;
            'verb':
            begin
              var current := new Verb();
              current.Infinitive := true;
              current.Value := value;
              
              if options.Length > 1 then
              for var j := 1 to options.Length - 1 do
              case options[j] of
                'firstconjugation': current.Conjugation := Conjugation.FirstConjugation;
                'secondconjugation': current.Conjugation := Conjugation.SecondConjugation;
                'overconjugation': current.Conjugation := Conjugation.OverConjugation;
                
                'perfect': current.PerfectForm := true;
              end;
              
              lst.Add(current);
            end;
            else raise new ArgumentException('Неподдерживаемая часть речи');
          end;
        end;
      end;
      dict := lst.ToArray();
    end;
  end;

end.