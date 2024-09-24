Shader "Challenges/Vasarely1"
{
    Properties
    {
        _GridSize("Grid Size", Float) = 10
        _Radius("Radius", Float) = 0.5
        _ColorS1("Color Square 1", Color) = (1,1,1,1)
        _ColorS2("Color Square 2", Color) = (1,1,1,1)
        _ColorC1("Color Circle 1", Color) = (1,1,1,1)
        _ColorC2("Color Circle 2", Color) = (1,1,1,1)
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

            fixed _Radius;
            fixed _GridSize;
            fixed4 _ColorS1;
            fixed4 _ColorS2;
            fixed4 _ColorC1;
            fixed4 _ColorC2;

            float random(float2 uv){
                return frac(sin(dot(uv, fixed2(14.9752, 78.233))) * 51729.513527);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //on prépare juste une grille
                float2 uv = i.uv * _GridSize;

                //on calcule l'identifiant du carré
                fixed2 squareID = floor(uv) / _GridSize;

                //On termine la grille
                uv = frac(uv);

                //Dessiner un cercle
                fixed2 center = fixed2(0.5, 0.5);
                fixed dist = distance(uv, center);
                fixed inCircle = 1 - step(_Radius, dist);

                //on determine un nombre aléatoire suivant notre identifiant de carré
                fixed randSquare = random(squareID);
                fixed randCircle = random(squareID * randSquare); //Un deuxième random différent pour éviter de trop lier une couleur de carré à une couleur de cercle
                
                //on colore notre case en carré et en cercle
                fixed4 colorSquare = lerp(_ColorS1, _ColorS2, randCircle);
                fixed4 colorCircle = lerp(_ColorC1, _ColorC2, randCircle);

                //On choisit parmi les deux couleur suivant si on est dans le cercle ou non
                fixed4 col = lerp(colorSquare, colorCircle, inCircle);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
