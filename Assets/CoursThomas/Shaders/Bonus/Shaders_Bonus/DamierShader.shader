Shader "Bonus Shaders/DamierColor"
{
    Properties
    {
        _CheckerSize ("Checker Size", FLOAT) = 0.2
        _GridThickness ("Grid Thickness", FLOAT) = 0.02
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

            fixed _CheckerSize;
            fixed _GridThickness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 RandomColor(float2 uv)
            {
                float2 scaledUV = floor(uv / 4.0); 
                float r = frac(sin(dot(scaledUV, float2(12.9898, 78.233))) * 43758.5453);
                float g = frac(sin(dot(scaledUV, float2(93.9898, 67.345))) * 23421.6312);
                float b = frac(sin(dot(scaledUV, float2(45.123, 98.765))) * 12345.6789);
                return fixed4(r, g, b, 1.0);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float2 uvChecker = floor(uv / _CheckerSize);
                float isEven = fmod(uvChecker.x + uvChecker.y, 2.0);

                fixed4 color1 = fixed4(1, 1, 1, 1);
                fixed4 color2 = RandomColor(uvChecker);
                fixed4 color = lerp(color1, color2, isEven);

                float2 grid = abs(frac(uv / _CheckerSize) - 0.5) * 2.0;
                float gridLine = step(1.0 - _GridThickness / _CheckerSize, min(grid.x, grid.y));

                fixed4 gridColor = fixed4(0, 0, 0, 1);
                fixed4 finalColor = lerp(color, gridColor, gridLine);

                UNITY_APPLY_FOG(i.fogCoord, finalColor);
                return finalColor;
            }
            ENDCG
        }
    }
}
