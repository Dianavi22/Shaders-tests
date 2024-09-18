Shader "Unlit/SquareShaderCad"
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
                float2 uvGrid = frac(i.uv *5);
                fixed2 sizeVec = fixed2(_BorderSize,_BorderSize);

                fixed2 bottumLeft = step(sizeVec, uvGrid);
                fixed inSquare = bottumLeft.x * bottumLeft.y;

                fixed2 topRight = step(sizeVec,1 - uvGrid);
                inSquare *= topRight.x * topRight.y;

                fixed4 col = fixed4(inSquare,inSquare,inSquare,1);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
