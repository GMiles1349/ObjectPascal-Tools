unit pglfont;

{$ifdef FPC}
  {$mode OBJFPC}{$H+}
  {$modeswitch ADVANCEDRECORDS}
  {$modeswitch OUT}
  {$macro ON}
  {$DEFINE RELEASE_INLINE :=
	  {$IFOPT D+}  {$ELSE} inline; {$ENDIF}
	}
{$else}
  {$POINTERMATH ON}
{$endif}

interface

uses
  Classes, SysUtils, pglimage;

type

  TPGLFontAtlas = class;
  TPGLFont = class;


  PPGLCharacter = ^TPGLCharacter;
  TPGLCharacter = record
    private
      Index: UINT32;
      Symbol: Char;
      Width, Height, Advance: UINT32;
      PosX: UINT32;

  end;


  PPGLFontAtlas = ^TPGLFontAtlas;
  TPGLFontAtlas = class(TPersistent)
    private
      fTexture: TPGLImage;
      fWidth, fHeight: UINT32;
      fPointSize: UINT32;
      Character: Array [31..127] of TPGLCharacter;

  end;


  PPGLFont = ^TPGLFont;
  TPGLFont = class(TPersistent)
    private
      fSize: Array of UINT32;
      fAtlas: Array of TPGLFontAtlas;
    public

      constructor Create(aFontName: String; aPointSize: Array of UINT32);

  end;

implementation

constructor TPGLFont.Create(aFontName: String; aPointSize: Array of UINT32);
var
Directories: Array of String;
  begin

  end;

end.

