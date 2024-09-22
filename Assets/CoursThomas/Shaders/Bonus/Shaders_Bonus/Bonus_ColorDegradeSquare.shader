Shader "Bonus Shaders/ColorSquareMosaik"
{
     Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BorderSize ("Border Size", FLOAT) = 0.2
        _NbCase ("Nb Case", FLOAT) = 0.2
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

            fixed Square(float2 halfSize, float2 pt) {
             return smoothstep(-halfSize.x, -halfSize.x, pt.x) * (1 - smoothstep(halfSize.x, halfSize.x, pt.x)) * smoothstep(-halfSize.y, -halfSize.y, pt.y) * (1 - smoothstep(halfSize.y, halfSize.y, pt.y));
             }

            fixed EmptySquare(float2 pt, float borderSize, float halfWidth){
            return Square(halfWidth, pt) * (1 - Square(halfWidth - borderSize, pt));
            }

            float2 GlobalToLocalPos(float2 refPos, float refAngle, float2 globalPos) {
            float2 globalVect = globalPos - refPos;
            float2 localI = float2(cos(refAngle), sin(refAngle));
            float2 localJ = float2(-localI.y, localI.x); 

            return float2(dot(globalVect, localI), dot(globalVect, localJ));
            }

       float roundTo(float x, float to){
           return round(x*(1/to))/(1/to);
           }

           fixed4 pyramid(float2 pt, fixed4 color, float halfwidth, float2 center){
                fixed4 black = fixed4(0,0,0,1);
             fixed lineWidth = halfwidth/_NbCase;
               fixed4 col = lerp(black, color*0.01, EmptySquare(GlobalToLocalPos(center,0,pt), lineWidth, halfwidth));
              col = col + lerp(black, color*0.1, EmptySquare(GlobalToLocalPos(center,0,pt), lineWidth, halfwidth - lineWidth));
              col = col + lerp(black, color*0.2, EmptySquare(GlobalToLocalPos(center,0,pt), lineWidth, halfwidth - lineWidth *2));
              col = col + lerp(black, color*0.3, EmptySquare(GlobalToLocalPos(center,0,pt), lineWidth, halfwidth - lineWidth *3));
              col = col + lerp(black, color*0.4, EmptySquare(GlobalToLocalPos(center,0,pt), lineWidth, halfwidth - lineWidth *4));
              col = col + lerp(black, color*0.5, EmptySquare(GlobalToLocalPos(center,0,pt), lineWidth, halfwidth - lineWidth *5));
              col = col + lerp(black, color*0.6, EmptySquare(GlobalToLocalPos(center,0,pt), lineWidth, halfwidth - lineWidth *6));
              col = col + lerp(black, color*0.7, EmptySquare(GlobalToLocalPos(center,0,pt), lineWidth, halfwidth - lineWidth *7));
              col = col + lerp(black, color*0.8, EmptySquare(GlobalToLocalPos(center,0,pt), lineWidth, halfwidth - lineWidth *8));
              col = col + lerp(black, color*0.9, EmptySquare(GlobalToLocalPos(center,0,pt), lineWidth, halfwidth - lineWidth *9));
              return col;
               }
           

            fixed4 frag (v2f i) : SV_Target
            {
                float2 pt = i.uv;
                float2 center= float2(0.5,0.5);
                float halfwidth = 0.5;
               fixed4 col = lerp(lerp(fixed4(0, 1, 0, 1), fixed4(1, 0, 1, 1), step(0.5, pt.y)), lerp(fixed4(1, 0, 0, 1), fixed4(0, 0, 1, 1), step(0.5, pt.y)), step(0.5, pt.x));
                float2 centre = lerp(lerp(float2(0.25, 0.25), float2(0.25, 0.75), step(0.5, pt.y)), lerp(float2(0.75, 0.25), float2(0.75, 0.75), step(0.5, pt.y)), step(0.5, pt.x));
              col = pyramid(pt, col, 0.25, centre);
             
                float2 fr = frac(pt*_NbCase*4);
            
              col = lerp(col, fixed4(0, 0, 0, 1), EmptySquare(GlobalToLocalPos(float2(0.5, 0.5), 0, fr), 0.02, halfwidth));
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
