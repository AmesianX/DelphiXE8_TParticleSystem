unit uMainLt1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics,
  FMX.MaterialSources, FMX.Ani,

  uSpritekit ;

type
  TfmMain = class(TForm)
    TextureMaterialPlayer: TTextureMaterialSource;
    TextureMaterialDragon: TTextureMaterialSource;
    TextureMaterialParticle: TTextureMaterialSource;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure FormResize(Sender: TObject);
  private
    FParticleSystem:  TParticleSystem;
    FPlayer,
    FDragon,
    FPartPoint:     TSprite;
    FAniPartPoint:  TRectAnimation;
    FAniDragon:     TRectAnimation;
    procedure DoIdle(Sender: TObject; var Done: Boolean);
  public
    { public êÈåæ }
  end;

var
  fmMain: TfmMain;

implementation

{$R *.fmx}

procedure TfmMain.DoIdle(Sender: TObject; var Done: Boolean);
begin
  Invalidate();

end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  Application.OnIdle := DoIdle;
  FParticleSystem := TParticleSystem.Create(Self, 1000, TextureMaterialParticle.Texture);

  FPlayer := TSprite.Create(Self);
  FPlayer.Parent  := Self;
  TextureMaterialPlayer.Parent  := FPlayer;
  FPlayer.Texture := TextureMaterialPlayer.Texture;


  FDragon := TSprite.Create(Self);
  FDragon.Parent  := Self;
  FDragon.Texture := TextureMaterialDragon.Texture;

  FPartPoint  := TSprite.Create(Self);
  FPartPoint.Parent := Self;

  FAniPartPoint := TRectAnimation.Create(Self);
  FAniPartPoint.Parent  := FPartPoint;
  FAniPartPoint.Loop  := True;
  FAniPartPoint.AutoReverse := True;
  FAniPartPoint.Duration  := 1;
  FAniPartPoint.PropertyName  := 'Size';
  FAniPartPoint.StartValue.Rect  := RectF(0, 0, 0, 0);
  FAniPartPoint.StopValue.Rect   := RectF(0, 0, Self.Width, 0);
  FAniPartPoint.AnimationType := TAnimationType.InOut;
  FAniPartPoint.Interpolation := TInterpolationType.Cubic;

  FAniDragon  := TRectAnimation.Create(Self);
  FAniDragon.Parent := FDragon;
  FAniDragon.Loop  := True;
  FAniDragon.AutoReverse := True;
  FAniDragon.Duration  := 1;
  FAniDragon.PropertyName  := 'Size';
  FAniDragon.StartValue.Rect  := RectF(Self.Width - FDragon.Texture.Width-100, 0, Self.Width-100, FDragon.Texture.Height);
  FAniDragon.StopValue.Rect   := RectF(Self.Width - FDragon.Texture.Width-100, Self.Height - FDragon.Texture.Height-30, Self.Width-100, Self.Height-30);
  FAniDragon.AnimationType := TAnimationType.Out;
  FAniDragon.Interpolation := TInterpolationType.Cubic;

  FAniPartPoint.Enabled     := True;
  FAniDragon.Enabled        := True;

{$IFDEF ANDROID}
  Self.FullScreen := True;
{$ENDIF}
{$IFDEF IOS}
  Self.FullScreen := True;
{$ENDIF}


end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin

  FAniPartPoint.Free;
  FPartPoint.Free;

  FDragon.Free;
  FPlayer.Free;
  FParticleSystem.Free;
end;

procedure TfmMain.FormPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
var
  P: TPointF;
begin
  P := ScreenToClient(Screen.MousePos);
  Canvas.BeginScene();
  Canvas.Clear($00000000);
  Canvas.Fill.Color := $FFFF0000;

  FParticleSystem.DrawBitmap(Canvas);
  Canvas.DrawBitmap(FDragon.Texture,
    RectF(0,0, FDragon.Texture.Width, FDragon.Texture.Height),
    FDragon.Size.Rect
    ,1,True
    );
  Canvas.DrawBitmap(FPlayer.Texture,
    RectF(0,0, FPlayer.Texture.Width, FPlayer.Texture.Height),
    RectF(P.X+10,
          P.Y-20,
          P.X+10 + FPlayer.Texture.Width,
          P.Y-20 + FPlayer.Texture.Height),1,True
    );
  Canvas.EndScene;
  FParticleSystem.SetEmmitter(FPartPoint.Size.Rect.Right, 5);
end;

procedure TfmMain.FormResize(Sender: TObject);
begin
  FAniDragon.StartValue.Rect  := RectF(Self.Width - FDragon.Texture.Width-100, 0, Self.Width-100, FDragon.Texture.Height);
  FAniDragon.StopValue.Rect   := RectF(Self.Width - FDragon.Texture.Width-100, Self.Height - FDragon.Texture.Height-30, Self.Width-100, Self.Height-30);

end;

end.
