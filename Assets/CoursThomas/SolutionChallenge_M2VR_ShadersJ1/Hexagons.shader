Shader "Challenges/Hexagons"
{
    Properties
    {
        _GridSize("Grid Size", Float) = 10
        _ColorInside("Color Inside", Color) = (1,1,1,1)
        _ColorOutside("Color Outside", Color) = (1,1,1,1)
        _ColorBorderHex("Color Border Hex", Color) = (1,1,1,1)
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

            fixed _GridSize;
            fixed4 _ColorInside;
            fixed4 _ColorOutside;
            fixed4 _ColorBorderHex;

            //Explications complètes ici : https://www.youtube.com/watch?v=VmrIDyYiJBA
            float HexDist(float2 p) {
			    p = abs(p);

			    float c = dot(p, normalize(float2(1, 1.73f)));
			    c = max(c, p.x);

			    return c;
		    }

		    float4 HexCoords(float2 uv) {
			    float2 r = float2(1, 1.73f);
			    float2 h = r * .5f;

			    float2 a = (uv % r) - h;
			    float2 b = ((uv - h) % r) - h;

			    float2 gv = dot(a, a) < dot(b, b) ? a : b;

			    float x = atan2(gv.x, gv.y);
			    float y = .5f - HexDist(gv);
			    float2 id = uv - gv;
			    return float4(x, y, id.x, id.y);
		    } //x => pos as angle, y => dist from hex border, z => hex ID x, w => hex ID y

            fixed4 frag (v2f i) : SV_Target
            {
                //Offset pour les valeurs négatives, petit fix rapide mais pas propre
                float2 uv = 100 + i.uv * _GridSize;

                //On détermine, pour nos UVs, les infos hexagonales
                float4 hc = HexCoords(uv);
                
                //On détermine si on est dans l'hexagone ou pas suivant la distance au bord
			    float hex = smoothstep(.05, .08, hc.y);

                //Suivant notre seuil, on détermine si on dessine avec la couleur de l'extérieur ou celle de l'hexagone
                fixed4 col = lerp(_ColorOutside, _ColorInside, hex);

                //On refait un lerp, mais cette fois pour dessiner l'anneau blanc
                col = lerp(col, _ColorBorderHex, step(0.15, hc.y) * step(hc.y, 0.2));
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
