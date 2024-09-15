Shader "Introduction/FirstShader"
{
    Properties
    {

        _Color("Test Color", color) =  (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert // Run on every vert
            #pragma fragment frag // Run on every signle px

            #include "UnityCG.cginc"

            struct appdata // object data or mesh
            {
                float4 vertex : POSITION;
            };

            struct v2f // Vertex to frag
            {
                float4 vertex : SV_POSITION;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Model view projection
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = fixed4(0,0,1,0);
                return col;
            }
            ENDCG
        }
    }
}
