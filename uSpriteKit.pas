unit uSpritekit;

interface
uses
  System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, FMX.Types, FMX.Graphics;

type
  TSprite = class(TFmxObject)
  strict private
    FSize:    TBounds;
    FTexture: TBitmap;
  private
    function  getSize: TBounds;
    procedure setSize(const Value: TBounds);
    procedure SetTexture(const Value: TBitmap);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property  Size: TBounds read getSize  write setSize;
    property Texture: TBitmap read FTexture write SetTexture;
  end;


  TParticle = class(TObject)
  private
    FpntMove:   TPointF;
    FpntVel:    TPointF;
    FiOpacity:  Integer;

    Fbmp: TBitmap;
    FPartSize: Integer;
    FPosition: TPointF;
  public
    constructor Create(bmp: TBitmap);
    destructor Destroy(); override;
    procedure Rebirth(X, Y: Single);
    function  IsOpacity(): Boolean;
    procedure DrawBitmap(Canvas: TCanvas);
  end;

  TParticleSystem = class(TFmxObject)
  private
    Fbmp: array[0..3] of TBitmap;
    FParticleList: TObjectList<TParticle>;
  public
    constructor Create(AOwner: TComponent; Count: Integer; bmp: TBitmap); virtual;
    destructor Destroy; override;
    procedure DrawBitmap(Canvas: TCanvas);
    procedure SetEmmitter(X, Y: Single);
  end;

implementation


{ TSprite }

constructor TSprite.Create(AOwner: TComponent);
begin
  inherited;
  FSize := TBounds.Create(TRectF.Empty);
  FTexture  := TBitmap.Create;
end;

destructor TSprite.Destroy;
begin
  FTexture.Free;
  FSize.Free;
  inherited;
end;

function TSprite.getSize: TBounds;
begin
  Result  := FSize;
end;

procedure TSprite.setSize(const Value: TBounds);
begin
  FSize.Assign(Value);
end;

procedure TSprite.SetTexture(const Value: TBitmap);
begin
  FTexture.Assign(Value);
end;


{ TParticle }

constructor TParticle.Create(bmp: TBitmap);
begin
//  inherited Create;

  FpntMove := TPointF.Create(0, 0.2); //重さ
  FPartSize := Random(50) + 10;
  Fbmp := bmp;
  Rebirth(0, 0);
  FiOpacity := Random(255);
end;

destructor TParticle.Destroy;
begin

  inherited;
end;

function TParticle.IsOpacity: Boolean;
begin
  Result := (FiOpacity <= 0);
end;

procedure TParticle.Rebirth(X, Y: Single);
var
  iParabora,
  iSpeed: Single;
begin
  iParabora := Random() * 5 * Pi;
  iSpeed    := Random() * 10 + 0.5;
  FpntVel := TPointF.Create(Cos(iParabora), Tangent(iParabora));
  FpntVel := FpntVel * iSpeed;
  FiOpacity := Random(100) + 155;
  FPosition := TPointF.Create(X, Y);
end;

procedure TParticle.DrawBitmap(Canvas: TCanvas);
begin
  Inc(FiOpacity, -1);
  FpntVel.Offset(FpntMove);//重さをタス
  FPosition := FPosition + FpntVel;
  Canvas.DrawBitmap( Fbmp,
    RectF(0, 0, Fbmp.Width, Fbmp.Height),
    RectF(FPosition.X, FPosition.Y,
      FPosition.X + FPartSize, FPosition.Y + FPartSize),
    FiOpacity, True);
end;

{ TParticleSystem }

constructor TParticleSystem.Create(AOwner: TComponent; Count: Integer; bmp: TBitmap);
var
  color:  TAlphaColor;
  clTrance: TAlphaColor;
  i,i1,i2: Integer;
  b:  TBitmapData;
  iTemp:  Integer;
begin
  Randomize;
  inherited Create(AOwner);

  FParticleList := TObjectList<TParticle>.Create(True);
  try
    for i := 0 to Length(Fbmp)-1 do
    begin
      Fbmp[i] := TBitmap.Create;
      Fbmp[i].Assign(bmp);
      case i of
      1:  clTrance := $FF00FFFF;
      2:  clTrance := $FF00FF00;
      3:  clTrance := $FF0000FF;
      else
        clTrance := $FFFFFFFF;
      end;
      Fbmp[i].Map(TMapAccess.ReadWrite, b);
      if i > 0 then
      begin
        for i1 := 0 to b.Width-1 do
          for i2 := 0 to b.Height-1 do
          begin
            color := b.GetPixel(i1, i2);
            if color > 0 then
            begin
              color   := color and clTrance;
              b.SetPixel(i1, i2, color);
            end;
          end;
        Fbmp[i].Unmap(b);
      end;
    end;
    for i := 0 to Count - 1 do
    begin
      iTemp := i mod 4;
      if iTemp >= 4 then
        iTemp := 0;
      FParticleList.Add(TParticle.Create(Fbmp[iTemp]));
    end;
  finally
  end;
end;

procedure TParticleSystem.DrawBitmap(Canvas: TCanvas);
var
  particle: TParticle;
begin
  for particle in FParticleList do
  begin
    particle.DrawBitmap(Canvas);
  end;
end;

destructor TParticleSystem.Destroy;
var
  i:  Integer;
begin
  for i := 0 to Length(Fbmp)-1 do
  begin
    Fbmp[i].Free;
  end;
  inherited;
end;

procedure TParticleSystem.SetEmmitter(X, Y: Single);
var
  particle: TParticle;
begin
  for particle in FParticleList do
    if particle.IsOpacity then
    begin
      particle.Rebirth(X, Y);
    end;
end;


end.
