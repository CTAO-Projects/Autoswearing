namespace Autoswearing;

type
  ConsoleMethods = static class
  
    public static procedure Write(params objs: array of object);
    begin
      for var i := 0 to objs.Length - 1 do
      begin
        if objs[i] = nil then Console.ForegroundColor := ConsoleColor.Gray
        else if objs[i] is ConsoleColor then Console.ForegroundColor := ConsoleColor(objs[i])
        else PABCSystem.Write(objs[i]);
      end;
    end;
  
  end;

end.