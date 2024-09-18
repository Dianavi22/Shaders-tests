Shader "Unlit/Checkerboard"
{
    Properties
    {
        _CheckerSize ("Checker Size", FLOAT) = 0.2  // Taille des cases du damier
        _GridThickness ("Grid Thickness", FLOAT) = 0.02  // Épaisseur des lignes de la grille
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

            fixed _CheckerSize;
            fixed _GridThickness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;

                // Calculer les coordonnées du damier
                float2 uvChecker = floor(uv / _CheckerSize);
                float isEven = fmod(uvChecker.x + uvChecker.y, 2.0);

                // Définir les couleurs pour le damier
                fixed4 color1 = fixed4(1, 1, 1, 1); // Blanc
                fixed4 color2 = fixed4(0, 0, 0, 1); // Noir
                fixed4 color = lerp(color1, color2, isEven);

                // Calculer la grille
                float2 grid = abs(frac(uv / _CheckerSize) - 0.5) * 2.0;
                float gridLine = step(1.0 - _GridThickness / _CheckerSize, min(grid.x, grid.y));

                // Couleur de la grille
                fixed4 gridColor = fixed4(0, 0, 0, 1); // Noir

                // Combiner la couleur du damier et la couleur de la grille
                fixed4 finalColor = lerp(color, gridColor, gridLine);

                UNITY_APPLY_FOG(i.fogCoord, finalColor);
                return finalColor;
            }
            ENDCG
        }
    }
}
