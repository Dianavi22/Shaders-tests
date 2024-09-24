Shader "Challenges/Triangles"
{
    Properties
    {
        _GridSize("Grid Size", Float) = 10
        _TriangleSize("Triangle Size", Float) = 0.6
        _BorderSize("Border Size", Float) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed _GridSize;
            fixed _TriangleSize;
            fixed _BorderSize;


            fixed SameSide(float3 p1, float3 p2, float3 a, float3 b){
                float3 cp1 = cross(b - a, p1 - a);
                float3 cp2 = cross(b - a, p2 - a);
                return step(0, dot(cp1, cp2));
            }

            //See https://blackpawn.com/texts/pointinpoly/
            fixed PointInTriangle(float3 p, float3 a, float3 b, float3 c){
                return SameSide(p, a, b, c) * SameSide(p, b, a, c) * SameSide(p, c, a, b);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Faire un grille
                float2 uv = frac(i.uv * _GridSize);

                //Un curseur pour multiplier les valeurs de triangle size et border size suivant où on se trouve en Y dans les UVs
                fixed cursor = sin(i.uv.y * 3.1415);

                _BorderSize = lerp(0.05, _BorderSize, cursor);
                _TriangleSize = lerp(0, _TriangleSize, cursor);

                //Dessiner un triangle simplement avec la méthode au dessus;
                fixed isInTLeft = PointInTriangle(float3(uv, 0), float3(0, _BorderSize, 0), float3(0, _BorderSize + _TriangleSize, 0), float3(_TriangleSize * 0.5, _BorderSize, 0));
                fixed isInTCenter = PointInTriangle(float3(uv, 0), float3(0.5 - _TriangleSize * 0.5, 1 - _BorderSize, 0), float3(0.5, 1 - _BorderSize - _TriangleSize, 0), float3(0.5 + _TriangleSize * 0.5, 1 - _BorderSize, 0));
                fixed isInTRight = PointInTriangle(float3(uv, 0), float3(1 - _TriangleSize * 0.5, _BorderSize, 0), float3(1, _BorderSize + _TriangleSize, 0), float3(1, _BorderSize, 0));

                //Inversion simple pour rendre les triangles noirs et pas blanc
                fixed isWhite = 1 - saturate(isInTLeft + isInTCenter + isInTRight);

                fixed4 col = fixed4(isWhite,isWhite,isWhite,1);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
