Shader "Custom/DrawSquareShader"
{
    Properties
    {
        _SquareColor ("Square Color", Color) = (1, 0, 0, 1) 
        _BackgroundColor ("Background Color", Color) = (0, 0, 0, 1)
        _SquareSize ("Square Size", Range(0, 1)) = 0.5 
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
            #include "UnityCG.cginc"

            fixed4 _SquareColor;
            fixed4 _BackgroundColor;
            float _SquareSize;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float halfSize = _SquareSize / 2.0;

                float2 center = float2(0.5, 0.5);
                float2 uv = i.uv;

                if (uv.x > center.x - halfSize && uv.x < center.x + halfSize &&
                    uv.y > center.y - halfSize && uv.y < center.y + halfSize)
                {
                    return _SquareColor;
                }
                else
                {
                    return _BackgroundColor;
                }
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
