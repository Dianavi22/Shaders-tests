Shader "Unlit/ColorDegradeWithGridOverlay"
{
    Properties
    {
        _BorderSize ("Border Size", FLOAT) = 0.05 
        _GradientWidth ("Gradient Width", FLOAT) = 0.2 
        _GridSize ("Grid Size", FLOAT) = 0.1  
        _GridThickness ("Grid Thickness", FLOAT) = 0.02  
        _GradientSteps ("Gradient Steps", FLOAT) = 5.0  
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

            fixed _BorderSize;
            fixed _GradientWidth;
            fixed _GridSize;
            fixed _GridThickness;
            fixed _GradientSteps;

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

                float isLeft = step(0.5, uv.x);  
                float isBottom = step(0.5, uv.y);   

                fixed4 color;
                if (isLeft == 0 && isBottom == 0) color = fixed4(1, 0, 0, 1);
                if (isLeft == 1 && isBottom == 0) color = fixed4(0, 1, 0, 1);  
                if (isLeft == 0 && isBottom == 1) color = fixed4(0, 0, 1, 1); 
                if (isLeft == 1 && isBottom == 1) color = fixed4(1, 1, 0, 1);  

                float2 quadrantCenter = float2(0.25 + 0.5 * isLeft, 0.25 + 0.5 * isBottom);
                float2 halfSize = float2(0.25 - _BorderSize, 0.25 - _BorderSize);  
                float2 offset = abs(uv - quadrantCenter);
                float2 borderDist = max(float2(0.0, 0.0), max(offset - halfSize, 0.0));

                float gradientDist = max(max(0.0, offset.x - (halfSize.x - _GradientWidth)), offset.y - (halfSize.y - _GradientWidth));
                float normalizedDist = gradientDist / _GradientWidth;
                float stepSize = 1.0 / _GradientSteps;
                float gradientValue = (1.0 - normalizedDist) * (1.0 - stepSize * floor(normalizedDist / stepSize));

                fixed4 borderColor = fixed4(0, 0, 0, 1); 
                fixed4 squareColor = lerp(color * gradientValue, borderColor, step(_BorderSize, borderDist.x) + step(_BorderSize, borderDist.y));

                float2 grid = abs(frac(uv / _GridSize) - 0.5) * 2.0;
                float gridLine = step(1.0 - _GridThickness, min(grid.x, grid.y));

                fixed4 gridColor = fixed4(0, 0, 0, 1);

                fixed4 gridBackgroundColor = fixed4(0, 0, 0, 0);

                fixed4 finalColor = lerp(gridBackgroundColor, gridColor, gridLine);
                finalColor = lerp(finalColor, squareColor, gridLine);

                UNITY_APPLY_FOG(i.fogCoord, finalColor);
                return finalColor;
            }
            ENDCG
        }
    }
}
