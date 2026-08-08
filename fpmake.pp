program fpmake;

{$mode ObjFPC}{$H+}

uses
  fpmkunit;

var
  Package: TPackage;
begin
  with Installer do
  begin
    Package := AddPackage('simpleblepascal');
    Package.Version := '1.0.0';
    Package.Author := 'Erik Lins, Andrey Syutkin';
    Package.License := 'MIT';
    Package.Description :=
      'Free Pascal bindings for the SimpleBLE/SimpleCBLE 1.0.0 C ABI';
    Package.SourcePath.Add('SimpleBleUnit');
    Package.Targets.AddUnit('simpleble.pas');
    Run;
  end;
end.
