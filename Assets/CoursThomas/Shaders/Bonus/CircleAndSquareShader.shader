Shader "Unlit/ColoredRepeatedSquareAndCircle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BorderSize ("Border Size", FLOAT) = 0.05
        _Repetition ("Repetitions", FLOAT) = 4
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
            fixed _Repetition;

            fixed3 GetColor(float2 uv)
            {
                float n = frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
                return fixed3(n, frac(n + 0.33), frac(n + 0.66));
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = frac(i.uv * _Repetition);
                float2 cell = floor(i.uv * _Repetition);

                fixed2 sizeVec = fixed2(_BorderSize, _BorderSize);
                fixed2 bottumLeft = step(sizeVec, uv);
                fixed inSquare = bottumLeft.x * bottumLeft.y;
                fixed2 topRight = step(sizeVec, 1 - uv);
                inSquare *= topRight.x * topRight.y;

                fixed2 center = float2(0.5, 0.5);
                fixed radius = 0.5 - _BorderSize;
                fixed dist = distance(uv, center);
                fixed inCircle = step(dist, radius);

                fixed shape = inSquare * inCircle;

                fixed3 squareColor = GetColor(cell + 0.5);
                fixed3 circleColor = GetColor(cell);

                fixed3 finalColor = lerp(squareColor, circleColor, shape);

                fixed4 col = fixed4(finalColor, 1);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
