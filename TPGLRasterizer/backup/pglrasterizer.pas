unit pglrasterizer;

{$mode ObjFPC}{$H+}
{$modeswitch ADVANCEDRECORDS}
{$modeswitch AUTODEREF}
{$inline ON}
{$FPUTYPE SSE64}


interface

uses
  Classes, SysUtils, pgltypes, pglimage, UnitMath;

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


  PPGLEdge = ^TPGLEdge;
  TPGLEdge = record
    V1,V2: PPGLVertex;

    constructor Create(const aV1, aV2: PPGLVertex);
  end;


  PPGLTriangle = ^TPGLTriangle;
  TPGLTriangle = record
    Vertex: Array [0..2] of PPGLVertex;
    Edge: Array [0..2] of TPGLEdge;
    Top,Middle,Bottom: UINT32;
    MiddleDir: INT32;
    ISE: Array [0..2] of Single;

    P: Array [0..2] of PPGLVec3;

    procedure SetUp();
  end;


  TPGLRasterizer = class(TPersistent)
    private
      fTarget: TPGLImage;
      fVertex: Array of TPGLVertex;
      fTriangle: Array of TPGLTriangle;
      fVertexCount: UINT32;
      fTriangleCount: UINT32;
      fIndexBuffer: Array of UINT32;
      fIndexCount: UINT32;

      function CurrentVertex(const aPlus: UINT32 = 0): PPGLVertex; inline;
      procedure PushVertex(const aVertex: PPGLVertex); inline;
      procedure PushTriangle1v(const aVertexIndex: UINT32); inline;
      procedure PushTriangle3v(const aIndex1, aIndex2, aIndex3: UINT32); inline;

      procedure DrawBatch();

    public
      property Target: TPGLImage read fTarget;

      constructor Create();

      procedure SetTarget(aTarget: TPGLImage);
      procedure SubmitTriangle(const aVertices: PPGLVertex);
      procedure SubmitIndexedBuffer(const aIndexBuffer: PUINT32; const aIndexCount: UINT32; const aVertexBuffer: PPGLVertex; const aVertexCount: UINT32);
      procedure ClearBatch();
      procedure Flush();

  end;


var
  Epsilon: Double = 9406564584124654418e-324;


implementation


constructor TPGLEdge.Create(const aV1, aV2: PPGLVertex);
  begin
    if aV1^.Position.Y < aV2^.Position.Y then begin
      Self.V1 := aV1;
      Self.V2 := aV2;
    end else begin
      Self.V1 := aV2;
      Self.V2 := aV1;
    end;
  end;


procedure TPGLTriangle.SetUp();
  begin
    Self.Edge[0] := TPGLEdge.Create(Self.Vertex[0], Self.Vertex[1]);
    Self.Edge[1] := TPGLEdge.Create(Self.Vertex[1], Self.Vertex[2]);
    Self.Edge[2] := TPGLEdge.Create(Self.Vertex[2], Self.Vertex[0]);
    P[0] := @Self.Vertex[0].Position;
    P[1] := @Self.Vertex[1].Position;
    P[2] := @Self.Vertex[2].Position;

    if (P[0].Y < P[1].Y) then begin
			if (P[2].Y < P[0].Y) then begin
				Top := 2;
				Middle := 0;
				Bottom := 1;
				MiddleDir := 1;
			end else begin
				Top := 0;
				if (P[1].Y < P[2].Y) then begin
					Middle := 1;
					Bottom := 2;
					MiddleDir := 1;
			  end else begin
					Middle := 2;
					Bottom := 1;
					MiddleDir := 0;
        end;
      end;
		end else begin
			if (P[2].Y < P[1].Y) then begin
				Top := 2;
				Middle := 1;
				Bottom := 0;
				MiddleDir := 0;
			end else begin
				Top := 1;
				if (P[0].Y < P[2].Y) then begin
					Middle := 0;
					Bottom := 2;
					MiddleDir := 0;
				end else begin
					Middle := 2;
					Bottom := 0;
					MiddleDir := 1;
        end;
      end;
    end;

    Self.ISE[0] := Divide( (P[Bottom].X - P[Top].X) , (P[Bottom].Y - P[Top].Y) );
    Self.ISE[1] := Divide( (P[Middle].X - P[Top].X) , (P[Middle].Y - P[Top].Y) );
    Self.ISE[2] := Divide( (P[Bottom].X - P[Middle].X) , (P[Bottom].Y - P[Middle].Y) );

  end;

constructor TPGLRasterizer.Create();
  begin
    SetLength(Self.fVertex, 3000);
    SetLength(Self.fTriangle, 1000);
    Self.fVertexCount := 0;
    Self.fTriangleCount := 0;
  end;


procedure TPGLRasterizer.SetTarget(aTarget: TPGLImage);
  begin
    if Assigned(aTarget) then begin
      Self.fTarget := aTarget;
    end else begin
      Self.fTarget := nil;
    end;
  end;

function TPGLRasterizer.CurrentVertex(const aPlus: UINT32 = 0): PPGLVertex;
  begin
    Exit(@Self.fVertex[fVertexCount + aPlus]);
  end;


procedure TPGLRasterizer.PushVertex(const aVertex: PPGLVertex);
  begin
    if Self.fVertexCount = High(Self.fVertex) then begin
      SetLength(Self.fVertex, Length(Self.fVertex) + 300);
    end;

    Self.CurrentVertex()^ := aVertex^;
    Inc(Self.fVertexCount);
  end;


procedure TPGLRasterizer.PushTriangle1v(const aVertexIndex: UINT32);
  begin
    if Self.fTriangleCount = High(Self.fTriangle) then begin
      SetLength(Self.fTriangle, Length(Self.fTriangle) + 100);
    end;

    Self.fTriangle[fTriangleCount].Vertex[0] := @Self.fVertex[aVertexIndex + 0];
    Self.fTriangle[fTriangleCount].Vertex[1] := @Self.fVertex[aVertexIndex + 1];
    Self.fTriangle[fTriangleCount].Vertex[2] := @Self.fVertex[aVertexIndex + 2];
    Self.fTriangle[fTriangleCount].SetUp();

    Inc(Self.fTriangleCount);
  end;


procedure TPGLRasterizer.PushTriangle3v(const aIndex1, aIndex2, aIndex3: UINT32);
  begin
    if Self.fTriangleCount = High(Self.fTriangle) then begin
      SetLength(Self.fTriangle, Length(Self.fTriangle) + 100);
    end;

    Self.fTriangle[fTriangleCount].Vertex[0] := @Self.fVertex[aIndex1];
    Self.fTriangle[fTriangleCount].Vertex[1] := @Self.fVertex[aIndex2];
    Self.fTriangle[fTriangleCount].Vertex[2] := @Self.fVertex[aIndex3];

    Inc(Self.fVertexCount);
  end;


procedure TPGLRasterizer.SubmitTriangle(const aVertices: PPGLVertex);
var
StartIndex: UINT32;
  begin
    StartIndex := Self.fVertexCount;
    Self.PushVertex(@aVertices[0]);
    Self.PushVertex(@aVertices[1]);
    Self.PushVertex(@aVertices[2]);
    Self.PushTriangle1v(StartIndex);
  end;


procedure TPGLRasterizer.SubmitIndexedBuffer(const aIndexBuffer: PUINT32; const aIndexCount: UINT32; const aVertexBuffer: PPGLVertex; const aVertexCount: UINT32);
  begin
    if Length(Self.fIndexBuffer) < aIndexCount then begin
      SetLength(fIndexBuffer,aIndexCount);
    end;

    Self.fIndexCount := aIndexCount;
    Move(aIndexBuffer[0], fIndexBuffer[0], aIndexCount * 4);
  end;


procedure TPGLRasterizer.ClearBatch();
  begin
    if Self.fVertexCount <> 0 then begin
      FillByte(Self.fVertex[0], SizeOf(TPGLVertex) * fVertexCount, 0);
      Self.fVertexCount := 0;
    end;

    if Self.fIndexCount <> 0 then begin
      FillByte(Self.fIndexBuffer[0], SizeOf(UINT32) * Self.fIndexCount, 0);
      Self.fIndexCount := 0;
    end;

    if Self.fTriangleCount <> 0 then begin
      FillByte(Self.fTriangle[0], SizeOf(TPGLTriangle) * Self.fTriangleCount, 0);
      Self.fTriangleCount := 0;
    end;
  end;


procedure TPGLRasterizer.Flush();
  begin
    Self.DrawBatch();
    Self.ClearBatch();
  end;


procedure TPGLRasterizer.DrawBatch();
var
T,X,Y: UINT32;
CurTri: PPGlTriangle;
MinVals, MaxVals: TPGLVec3;
MinX, MinY, MaxX, MaxY: INT32;
Area, Edge1, Edge2, Edge3: Single;
OutColor: TPGLColorI;
Color1, Color2, Color3: TPGLColorf;
XStep, YStep: Single;
Tile: Array of Array of TPGLRectI;
TilesX, TilesY: UINT32;
TileWidth: UINT32;
MaxWidth, MaxHeight: UINT32;
RemX, RemY: UINT32;
CurX, CurY: INT32;
SW, SH: INT32;
  begin

    if Self.fTriangleCount = 0 then Exit;

    for T := 0 to Self.fTriangleCount - 1 do begin
        CurTri := @Self.fTriangle[T];
        MinVals := Mins(CurTri.P[0]^, CurTri.P[1]^, CurTri.P[2]^);
        MaxVals := Maxes(CurTri.P[0]^, CurTri.P[1]^, CurTri.P[2]^);
        MinX := trunc(MinVals.X);
        MinY := trunc(MinVals.Y);
        MaxX := trunc(MaxVals.X);
        MaxY := trunc(MaxVals.Y);

        Area := EdgeTest(CurTri.P[0]^, CurTri.P[1]^, CurTri.P[2]^);

        Color1 := CurTri.Vertex[0].Color;
        Color2 := CurTri.Vertex[1].Color;
        Color3 := CurTri.Vertex[2].Color;

        TileWidth := 8;

        MaxWidth := MaxX - Minx;
        MaxHeight := MaxY - MinY;

        TilesX := trunc(MaxWidth / TileWidth);
        TilesY := trunc(MaxHeight / TileWidth);
        RemX := MaxWidth mod TileWidth;
        RemY := MaxHeight mod TileWidth;

        if RemX <> 0 then TilesX := TilesX + 1;
        if Remy <> 0 then TilesY := TilesY + 1;

        initialize(Tile);
        SetLength(Tile, TilesX, TilesY);

        CurX := MinX;
        CurY := MinY;

        for Y := 0 to TilesY - 1 do begin
          curX := MinX;
          for X := 0 to TilesX - 1 do begin

            SW := TileWidth;
            SH := TileWidth;

            if X = TilesX - 1 then begin
              SW := RemX;
            end;

            if Y = TilesY - 1 then begin
              SH := RemY;
            end;

            Tile[X,Y] := RectIWH(CurX, CurY, SW, SH);

            CurX := CurX + TileWidth;

          end;

          CurY := CurY + TileWidth;
        end;


        for Y := 0 to TilesY - 1 do begin
          for X := 0 to TilesX - 1 do begin

            if InTriangle(CurTri.P[0]^, CurTri.P[1]^, CurTri.P[2]^, Tile[X,Y].TopLeft) = False then Continue;
            if InTriangle(CurTri.P[0]^, CurTri.P[1]^, CurTri.P[2]^, Tile[X,Y].TopRight) = False then Continue;
            if InTriangle(CurTri.P[0]^, CurTri.P[1]^, CurTri.P[2]^, Tile[X,Y].BottomLeft) = False then Continue;
            if InTriangle(CurTri.P[0]^, CurTri.P[1]^, CurTri.P[2]^, Tile[X,Y].BottomRight) = False then Continue;

            Self.fTarget.Pixle[Tile[X,Y].X, Tile[X,Y].Y] := pgl_red;
          end;
        end;

    end;


  end;



end.

