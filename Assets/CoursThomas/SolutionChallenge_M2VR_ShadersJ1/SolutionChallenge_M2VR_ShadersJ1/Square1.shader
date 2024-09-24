Shader "Challenges/Square1"
{
    Properties
    {
        _BorderSize("Border Size", Float) = 0.1
        _Repetitions("Repetitions", Float) = 3
        _GridSize("Grid Size", Float) = 10
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

            fixed _BorderSize;
            fixed _Repetitions;
            fixed _GridSize;

            float2 Rotate(float2 input, float angle)
		    {
			    float c = cos(radians(angle));
			    float s = sin(radians(angle));
			    return float2(
				    input.x * c - input.y * s,
				    input.x * s + input.y * c);
		    }

            fixed4 frag (v2f i) : SV_Target
            {
                //On tourne les UV
                float2 rotatedUVs = Rotate(i.uv - fixed2(0.5, 0.5), -45);
                rotatedUVs += fixed2(0.5, 0.5);

                //Ici, on créé une grille simple
                float2 uv = frac(rotatedUVs * _GridSize);

                //Ici, on essaie de trouver un "identifiant" à notre carré, en prenant simplement le nombre entier max de nos coordonnées multipliées
                //Si on le soustrait aux UVs multipliées, et qu'on les empêche de desccendre sous 0, on obtient des UV qui se répetent sans former de grille
                //En fait, si je prends un point après multiplication : (1,5;1,5) celui-ci devient (0,5;0,5) (1,5 - 1; 1,5 - 1)
                //Mais si je prends un autre point après multiplication : (1,5; 0,5) celui-ci devient (0,5; 0)
                //Nos UV se répetent alors diagonalement !
                uv = uv * _Repetitions;
                float2 flooredUVs = floor(uv);
                float squareID = max(flooredUVs.x, flooredUVs.y);
                uv = max(0, uv - squareID);

                //On fait la bordure classique comme pour le carré simple
                fixed2 borderVector = fixed2(_BorderSize, _BorderSize);

                //La distance au bord
                fixed2 bigBorder = step(borderVector, 1 - uv);
                fixed isWhite = bigBorder.x * bigBorder.y;

                fixed4 col = float4(isWhite, isWhite, isWhite, 1);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
