Shader "Bonus Shaders/Hexagones"
{
     Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
       
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _BorderSize;
            fixed _NbCase;


            v2f vert (appdata v)
            {
               v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

                float Hexagon(float2 pt, float2 center, float halfWidth, float halfHeight) {
                float2 q2 = abs(float2(pt - center));
                float2 p2 = float2(halfWidth, halfHeight); 
                
                float2 n = float2(-halfHeight, -halfWidth);
                float2 m = q2 - p2;

                return (1 - step(halfWidth, q2.x)) * (1 - step(halfHeight * 2, q2.y)) * step(0, dot(n, m));
                }


                float EmptyHexagon(float2 pt, float2 center, float halfWidth, float lineWidth, float halfHeight) {
                return Hexagon(pt, center, halfWidth, halfHeight) * (1 - Hexagon(pt, center, halfWidth - lineWidth, halfHeight - lineWidth / 2));
                }

                float HexaGrid(float2 pt,  float lineWidth, float fracNumber) {
                float2 squareSize = float2(1, sqrt(3)) / sqrt(3);

                float2 center = squareSize / 2;

                float halfWidth = center.x;

                float halfHeight = halfWidth / sqrt(3); 

                float2 fr = frac(float2((pt.x * fracNumber) % (squareSize.x + .025), pt.y * fracNumber));
                
                float halfWidthCoef = 1.05; 

                float halfHeightCoef = 3.1; 

                return EmptyHexagon(fr, center, halfWidth, lineWidth, halfHeight)
                + EmptyHexagon(fr, center + float2(-halfWidthCoef * halfWidth, -halfHeightCoef * halfHeight), halfWidth, lineWidth, halfHeight) // 0, 0 
                + EmptyHexagon(fr, center + float2(halfWidthCoef * halfWidth, -halfHeightCoef * halfHeight), halfWidth, lineWidth, halfHeight) // 1, 0
                + EmptyHexagon(fr, center + float2(-halfWidthCoef * halfWidth, halfHeightCoef * halfHeight), halfWidth, lineWidth, halfHeight) // 0, 1
                + EmptyHexagon(fr, center + float2(halfWidthCoef * halfWidth, halfHeightCoef * halfHeight), halfWidth, lineWidth, halfHeight); // 1, 1
                }

      
            fixed4 frag (v2f i) : SV_Target
            {
                float2 pt = i.uv;
             fixed4 col = lerp(fixed4(1,0,1,0), fixed4(1,1,1,1), HexaGrid(pt,0.08,10));
             col*=lerp(col,fixed4(0,0,0.5,1), HexaGrid(pt, 0.03,10));

             float2 squareSize = float2(1, sqrt(3)) / sqrt(3);
             float2 center = squareSize/2;
             float halfWidth = center.x;
             float halfHeight = halfWidth/ sqrt(3);

             float fr = frac(float2((pt.x*10)%(squareSize.x+0.025), pt.y*10));
             col += lerp(col, fixed4(0,0,0.5,1), Hexagon(fr, center, halfWidth, halfWidth));
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
