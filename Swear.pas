namespace Autoswearing;

type
  Swear = class
    private static _swears: array of Swear;
    
    public auto property Paste: array of object;
    
    public constructor(s: string);
    begin
      var isinternal := false;
      var lst := new List<object>();
      var str := new StringBuilder();
      var changes := false;
      for var i := 1 to s.Length do
      begin
        if s[i] = '<' then 
        begin
          changes := false;
          isinternal := true;
          continue;
        end;
        if s[i] = '>' then 
        begin
          isinternal := false;
          lst += object(new WordShell(str.ToString()));
          str.Clear();
          continue;
        end;
        if isinternal then
        begin
          if not changes then
          begin
            if str.Length > 0 then lst += object(str.ToString());
            str.Clear();
          end;
          changes := true;
          str += s[i];
        end
        else str += s[i];
      end;
      if str.Length > 0 then lst += object(str.ToString());
      Paste := lst.ToArray();
    end;
    
    public static procedure Init();
    begin
      var lst := new List<Swear>(256);
      var txt := System.IO.File.ReadAllLines('constructions.dat');
      var sb := new StringBuilder;
      var mode := 0;
      var current: Swear;
      for var i := 0 to txt.Length - 1 do
      begin
        var s := txt[i].Trim();
        if not (s.StartsWith('//') or string.IsNullOrEmpty(s)) or (mode = 1) then
        begin
          if mode = 0 then
          begin
            if s.ToLower = '#begin' then
            begin
              mode := 1;
              sb.Clear;
            end;
          end else if mode = 1 then
          begin
            if s.ToLower() = '#end' then
            begin
              mode := 0;
              current := new Swear(sb.ToString());
              lst += current;
            end
            else if not s.StartsWith('//') then sb.AppendLine(s);
          end;
        end;
      end;
      _swears := lst.ToArray;
    end;
    
    public function GetVerse: array of string;
    begin
      var sb := new StringBuilder();
      for var i := 0 to Paste.Length - 1 do
      begin
        match Paste[i] with
          string(var s): sb += s;
          WordShell(var ws): sb += ws.Find();
        end;
      end;
      Result := sb.ToString.Remove(#13).Split(#10);
    end;
    
    public static function Generate(): array of string;
    begin
      Result := _swears[PABCSystem.Random(_swears.Length)].GetVerse();
    end;
  end;

end.