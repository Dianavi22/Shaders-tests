Shader "Unlit/MiSquareWithDuplications"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BorderSize ("Border Size", FLOAT) = 0.2
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 sizeVec = fixed2(_BorderSize, _BorderSize);

                fixed2 bottomLeft = step(sizeVec, 1 - i.uv);
                fixed inSquare = bottomLeft.x * bottomLeft.y;

                // Plus petit motif 1
                fixed2 smallScale1 = sizeVec * 0.5;
                fixed2 smallBottomLeft1 = step(smallScale1, 1 - (i.uv * 2 - 0.5));
                fixed inSmallSquare1 = smallBottomLeft1.x * smallBottomLeft1.y;

                // Plus petit motif 2
                fixed2 smallScale2 = sizeVec * 0.25;
                fixed2 smallBottomLeft2 = step(smallScale2, 1 - (i.uv * 4 - 0.75));
                fixed inSmallSquare2 = smallBottomLeft2.x * smallBottomLeft2.y;

                fixed4 col = fixed4(inSquare + inSmallSquare1 + inSmallSquare2, inSquare + inSmallSquare1 + inSmallSquare2, inSquare + inSmallSquare1 + inSmallSquare2, 1);

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
