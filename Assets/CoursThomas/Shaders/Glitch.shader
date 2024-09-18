Shader "Thomas/RandomGlitch"
{
    Properties
    {
        _Threshold("Threshold", Float) = 0.85
        _Size("Size", Float) = 10
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

            fixed _Threshold;
            fixed _Size;

            //Une fonction al�atoire qui se r�sume en fait � une fonction tellement incompr�hensible qu'on pourrait croire � de l'al�atoire
            //Avantage : rapide � calculer
            //D�savantage (qui est un avantage si on s'en sert bien !) : c'est d�terministe -> m�me r�sultat � chaque fois pour les m�mes valeurs d'entr�e
            float random(float2 uv){
                return frac(sin(dot(uv, fixed2(14.9752, 78.233))) * 51729.513527);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //On transforme nos UV en une grille pixelis�e
                float2 uv = floor(i.uv * _Size);

                //On d�cale les UV par rappot au temps
                uv += frac(_Time.y);

                //On lit la valeur random, on s'en sert pour savoir si le pixel est noir ou blanc suivant un seuil
                float rand = step(_Threshold, random(uv));

                fixed4 col = fixed4(rand, rand, rand, 1.0);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
