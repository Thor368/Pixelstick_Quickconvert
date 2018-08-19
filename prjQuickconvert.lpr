program prjQuickconvert;

uses
  sysutils, crt, BGRABitmap, BGRABitmapTypes, BGRATransform;

var
  i: integer;
  k: single;
  source, target: string;
  image_in: TBGRABitmap;
  image_out: TBGRACustomBitmap;
  transform: TBGRAAffineBitmapTransform;

  flip: boolean;
  mirror_horzontal: boolean;
  mirror_vertical: boolean;
  gamma2, gamma3: boolean;
  pix: PBGRAPixel;

procedure decodeParams(raw: string);
var
  param: string;
begin
  param:= RightStr(raw, Length(raw)-1);

  case param of
    'r':
      flip:= true;
    'h':
      mirror_horzontal:= true;
    'v':
      mirror_vertical:= true;
    'g2':
      gamma2:= true;
    'g3':
      gamma3:= true;
  end;
end;

procedure displayParams();
begin
  for i:= 0 to ParamCount do
    WriteLn('#' + IntToStr(i) + ' = ' + ParamStr(i));
end;

procedure displayUsage();
begin
  WriteLn('Error: Not enought parameters!');
  WriteLn('Give me an image as parameter and enjoy^^');
  WriteLn('Usage: [Options] image');
  WriteLn('There are paramteres:');
  WriteLn('-r        rotate image CW instead of CCW(default)');
  WriteLn('-h        flip image horizontally befor rotation');
  WriteLn('-v        flip image vertically befor rotation');
  WriteLn('-g2       do gamma = 2 correction');
  WriteLn('-g3       do gamma = 3 correction');
end;

begin
  WriteLn('Welcome to Quickconvert v0.2!');
  WriteLn('The easy tool to convert images to Pixelstick format!' + #10);

  flip:= false;
  mirror_horzontal:= false;
  mirror_vertical:= false;
  gamma2:= false;
  gamma3:= false;
  source:= '';
  target:= '';


  if ParamCount <= 0 then
  begin
    displayUsage;
//    displayParams;
    ReadKey;
    exit;
  end;

  for i:= 1 to ParamCount do
  begin
    if ParamStr(i).Chars[0] = '-' then
      decodeParams(ParamStr(i))
    else
    begin
      source:= ParamStr(i);
      target:= ExtractFilePath(source) + '_pixelstick.bmp';
    end;
  end;

  Write('Reading image... ');
  if source <> '' then
  begin
    try
      image_in:= TBGRABitmap.Create(source);
    except
      on E: Exception do
      begin
        WriteLn('Error!');
        WriteLn('Unknown filetype!');
        ReadKey;
        exit;
      end;
    end;
    WriteLn('done.');

    transform:= TBGRAAffineBitmapTransform.Create(image_in, true);
    k:= 288/image_in.Height;
    image_out:= TBGRABitmap.Create(288, round(image_in.Width*k));

    Write('Scaling image... ');
    transform.Scale(k);
    WriteLn('done.');

    if mirror_horzontal then
    begin
      Write('Mirroring image horizontally... ');
      image_in.HorizontalFlip;
      WriteLn('done.');
    end;

    if mirror_vertical then
    begin
      Write('Mirroring image horizontally... ');
      image_in.VerticalFlip;
      WriteLn('done.');
    end;

    if flip then
    begin
      Write('Rotating image right... ');
      transform.RotateDeg(90);
      WriteLn('done.');
    end
    else
    begin
      Write('Rotating image left... ');
      transform.RotateDeg(-90);
      WriteLn('done.');
    end;

    image_out.Fill(transform);

    if gamma2 then
    begin
      Write('Doing gamma = 2... ');
      pix:= image_out.Data;

      for i:= image_out.NbPixels-1 downto 0 do
      begin
        pix^.red:= pix^.red*pix^.red div 255;
        pix^.green:= pix^.green*pix^.green div 255;
        pix^.blue:= pix^.blue*pix^.blue div 255;
        inc(pix);
      end;
      image_out.InvalidateBitmap;

      WriteLn('done.');
    end
    else if gamma3 then
    begin
      Write('Doing gamma = 3... ');
      pix:= image_out.Data;

      for i:= image_out.NbPixels-1 downto 0 do
      begin
        pix^.red:= pix^.red*pix^.red*pix^.red div 65025;
        pix^.green:= pix^.green*pix^.green*pix^.green div 65025;
        pix^.blue:= pix^.blue*pix^.blue*pix^.blue div 65025;
        inc(pix);
      end;
      image_out.InvalidateBitmap;

      WriteLn('done.');
    end;

    image_out.SaveToFile(target);
    transform.Destroy;
    image_in.Destroy;
  end
  else
  begin
    WriteLn('Error!');
    WriteLn('No input file specified!');
    displayUsage;
//    displayParams;
    ReadKey;
    Exit;
  end;
end.

