Shader "Custom/StripesShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BorderSize ("Border Size", float) = 0.2
        _NbRep ("Nombre rep", int) = 1 
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
            #include "Assets/ShaderLibrary/Geometry.cginc"

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
            int _NbRep;

            v2f vert (appdata v)
            {
               v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float2 Rotatepoint(float angle, float2 uv){
                float2 pt = mul(float2x2(cos(angle), -sin(angle), sin(angle), cos(angle)), uv);
                return pt;
             }

            fixed4 frag (v2f i) : SV_Target
            {
               float2 rotatedUV = Rotatepoint(radians(-45), i.uv);
               float2 repeatPt = frac(rotatedUV * _NbRep);
               float center = float2(0.5, 0.5);
               float2 pt = GlobalToLocalPos(center, 0, repeatPt);
               float condition = EmptySquare(pt, _BorderSize / 2, 0.5) + EmptySquare(repeatPt, _BorderSize, 0.7) + EmptySquare(repeatPt, _BorderSize, 0.4);
               fixed4 col = lerp(fixed4(1, 1, 1, 1), fixed4(0, 0, 0, 1), condition);

               UNITY_APPLY_FOG(i.fogCoord, col);
               return col;
            }
            ENDCG
        }
    }
}
