namespace Autoswearing;

type
  ///Базовый класс всех слов
  &Word = class(ICloneable)
    public auto property Value: string;
    
    public constructor(val: string) := Value := val;
    
    public function Clone(): object; virtual := MemberwiseClone();
    
    public function ToString(): string; override := Value;
  end;

end.