Shader "Thomas/VerticalWavesShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LineWidth ("Line Width", FLOAT) = 0.05
        _WaveAmplitude ("Wave Amplitude", FLOAT) = 0.1
        _WaveFrequency ("Wave Frequency", FLOAT) = 5.0
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
            fixed _LineWidth;
            fixed _WaveAmplitude;
            fixed _WaveFrequency;

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
                float wave = sin(i.uv.y * _WaveFrequency) * _WaveAmplitude;

                float uvX = frac(i.uv.x * 5 + wave);

                fixed inLine = step(_LineWidth, uvX) * step(uvX, 1 - _LineWidth);


                fixed4 col = float4(uvX, uvX, uvX, 1)

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
