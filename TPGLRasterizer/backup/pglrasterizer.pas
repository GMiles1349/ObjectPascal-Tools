unit pglrasterizer;

{$mode ObjFPC}{$H+}
{$modeswitch ADVANCEDRECORDS}
{$inline ON}

interface

uses
  Classes, SysUtils, pgltypes, pglvecarray;

type

  TPGLRasterizer = class;

  {$ALIGN 4}

  PPGLSampler = ^TPGLSampler;
  TPGLSampler = record
    ImageData: PByte;
    Width: UINT32;
    Height: UINT32;
  end;


  PPGLVertex = ^TPGLVertex;
  TPGLVertex = record
    Position: TPGLVec4;
    Color: TPGLColorF;
    TexCoord: TPGLVec4;
    Sampler: TPGLSampler;
  end;


  PPGLTriangle = ^TPGLTriangle;
  TPGLTriangle = record
    Vertex: Array [0..2] of PPGLVertex;
  end;


  TPGLRasterizer = class(TPersistent)
    private
      fVertex: Array of TPGLVertex;
      fTriangle: Array of TPGLTriangle;
      fVertexCount: UINT32;
      fTriangleCount: UINT32;
      fIndexBuffer: Array of UINT32;
      fIndexCount: UINT32;

      function CurrentVertex(const aPlus: UINT32 = 0): PPGLVertex; inline;
      procedure PushVertex(constref aVertex: PPGLVertex); inline;
      procedure PushTriangle1v(constref aVertexIndex: UINT32); inline;
      procedure PushTriangle3v(constref aIndex1, aIndex2, aIndex3: UINT32); inline;

    public

      constructor Create();

      procedure SubmitTriangle(constref aVertices: PPGLVertex); inline;
      procedure SubmitIndexedBuffer(constref aIndexBuffer: PUINT32; constref aIndexCount: UINT32; constref aVertexBuffer: PPGLVertex; constref aVertexCount: UINT32); inline;

  end;


implementation


constructor TPGLRasterizer.Create();
  begin
    SetLength(Self.fVertex, 3000);
    SetLength(Self.fTriangle, 1000);
    Self.fVertexCount := 0;
    Self.fTriangleCount := 0;
  end;


function TPGLRasterizer.CurrentVertex(const aPlus: UINT32 = 0): PPGLVertex;
  begin
    Exit(@Self.fVertex[fVertexCount + aPlus]);
  end;


procedure TPGLRasterizer.PushVertex(constref aVertex: PPGLVertex);
  begin
    if Self.fVertexCount = High(Self.fVertex) then begin
      SetLength(Self.fVertex, Length(Self.fVertex) + 300);
    end;

    Self.CurrentVertex()^ := aVertex^;
    Inc(Self.fVertexCount);
  end;


procedure TPGLRasterizer.PushTriangle1v(constref aVertexIndex: UINT32);
  begin
    if Self.fTriangleCount = High(Self.fTriangle) then begin
      SetLength(Self.fTriangle, Length(Self.fTriangle) + 100);
    end;

    Self.fTriangle[fTriangleCount].Vertex[0] := @Self.fVertex[aVertexIndex + 0];
    Self.fTriangle[fTriangleCount].Vertex[1] := @Self.fVertex[aVertexIndex + 1];
    Self.fTriangle[fTriangleCount].Vertex[2] := @Self.fVertex[aVertexIndex + 2];

    Inc(Self.fTriangleCount);
  end;


procedure TPGLRasterizer.PushTriangle3v(constref aIndex1, aIndex2, aIndex3: UINT32);
  begin
    if Self.fTriangleCount = High(Self.fTriangle) then begin
      SetLength(Self.fTriangle, Length(Self.fTriangle) + 100);
    end;

    Self.fTriangle[fTriangleCount].Vertex[0] := @Self.fVertex[aIndex1];
    Self.fTriangle[fTriangleCount].Vertex[1] := @Self.fVertex[aIndex2];
    Self.fTriangle[fTriangleCount].Vertex[2] := @Self.fVertex[aIndex3];

    Inc(Self.fVertexCount);
  end;


procedure TPGLRasterizer.SubmitTriangle(constref aVertices: PPGLVertex);
var
StartIndex: UINT32;
  begin
    StartIndex := Self.fVertexCount;
    Self.PushVertex(@aVertices[0]);
    Self.PushVertex(@aVertices[1]);
    Self.PushVertex(@aVertices[2]);
    Self.PushTriangle1v(StartIndex);
  end;


procedure TPGLRasterizer.SubmitIndexedBuffer(constref aIndexBuffer: PUINT32; constref aIndexCount: UINT32; constref aVertexBuffer: PPGLVertex; constref aVertexCount: UINT32);
  begin
    if Length(Self.fIndexBuffer) < aCount then begin
      SetLength(fIndexBuffer,aCount);
    end;

    Self.fIndexCount := aCount;
    Move(aBuffer[0], fIndexBuffer[0], aCount * 4);
  end;

end.

