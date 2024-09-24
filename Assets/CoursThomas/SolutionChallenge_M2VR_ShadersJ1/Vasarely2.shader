Shader "Challenges/Vasarely2"
{
    Properties
    {
        _GridSize("Grid Size", Float) = 10
        _BorderSize("Border Size", Float) = 0.1
        _Color1Inner("Color 1 Inner", Color) = (1,1,1,1)
        _Color1Outer("Color 1 Outer", Color) = (1,1,1,1)
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

            fixed _GridSize;
            fixed _BorderSize;
            fixed4 _Color1Inner;
            fixed4 _Color1Outer;
            sampler2D _ColorLookup;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 bigGridUV = frac(i.uv * 2);

                float2 uv = frac(bigGridUV * _GridSize);

                //Dessiner un carré
                fixed2 sizeVec = fixed2(_BorderSize, _BorderSize);
                //bottom left
                fixed2 bottomLeft = step(sizeVec, uv);
                fixed inSquare = bottomLeft.x * bottomLeft.y;
                //top right
                fixed2 topRight = step(sizeVec, 1 - uv);
                inSquare *= topRight.x * topRight.y;

                //Distance au centre
                float2 uvDist = floor(abs(bigGridUV - 0.5) * _GridSize) / _GridSize;
                fixed dist = max(uvDist.x, uvDist.y) * 2;
                
                //Trouver un identifiant de carré
                float2 bigSquareID = floor(i.uv * 2) / 2;
                
                //Trouver la couleur max
                fixed4 colorMax = tex2D(_ColorLookup, bigSquareID);

                //Trouver la couleur min
                fixed4 colorMin = colorMax * fixed4(0.05, 0.05, 0.05, 1);

                //Dessiner le carré dans chaque case
                fixed4 col = fixed4(inSquare, inSquare, inSquare, 1) * colorMax;

                //Colorer le carré
                col = lerp(col, colorMin, dist);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
