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
    Vertex: Array [0..2] of TPGLVertex;
  end;


  TPGLRasterizer = class(TPersistent)
    private
      fVertices: specialize TPGLVecArray<TPGLVertex>;
      fTriangles: specialize TPGLVecArray<TPGLTriangle>;
    public

  end;


implementation



end.

