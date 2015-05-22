program lt1;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMainLt1 in 'uMainLt1.pas' {fmMain},
  uSpriteKit in 'uSpriteKit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Landscape, TFormOrientation.InvertedLandscape];
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
