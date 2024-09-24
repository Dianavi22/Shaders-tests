Shader "Challenges/Square2"
{
    Properties
    {
        _GridSize("Grid Size", Float) = 10
        _ColorLookupSize("ColorLookup Size", Float) = 4
        _ColorLookup ("ColorLookup", 2D) = "white" {}
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
            // make fog work
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            sampler2D _ColorLookup;
            fixed _GridSize;
            fixed _ColorLookupSize;

            fixed4 frag (v2f i) : SV_Target
            {
                //On "aggrandit" les UV, ça va nous servir ensuite
                float2 uv = i.uv * _GridSize;
                
                //On déplace les UV en X de 1 si les UV en Y sont impairs
                uv.x += step(1, uv.y % 2);

                //On colore en blanc si les UV en X sont impairs
                float isWhite = step(1, uv.x % 2);

                //On calcule des coordonnées "pixelisées" par rapport à notre texture colorante
                float2 colorUV = floor(i.uv * _ColorLookupSize) / _ColorLookupSize;
                
                //On lit sur une texture suivant nos UV "pixelisés"
                fixed4 color = tex2D(_ColorLookup, colorUV);

                fixed4 col = lerp(fixed4(1,1,1,1), color * isWhite, isWhite);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
