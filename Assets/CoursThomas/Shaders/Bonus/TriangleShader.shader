Shader "Unlit/Triangle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BorderSize ("Border Size", FLOAT) = 0.2
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _BorderSize;

            v2f vert (appdata v)
            {
               v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float sign (float2 p1, float2 p2, float2 p3) {
                return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
            }

            float PointInTriangle (float2 pt, float2 v1, float2 v2, float2 v3)
            {
                float d1 = sign(pt, v1, v2);
                float d2 = sign(pt, v2, v3);
                float d3 = sign(pt, v3, v1);

                float has_neg = (d1 < 0) + (d2 < 0) + (d3 < 0);
                float has_pos = (d1 > 0) + (d2 > 0) + (d3 > 0);

                return 1 - (has_neg * has_pos);
            }

            fixed4 blackWhiteLerp(float condition) {
                return lerp(fixed4(0, 0, 0, 1), fixed4(1, 1, 1, 1), condition);
            }

            float BottomTriangleCondition(float2 pt, float width) {
                float2 topLeft = float2(width, 1 - width / 2);
                float2 topRight = float2(1 - width, 1 - width / 2);
                float2 center = float2(0.5, width / 2);

                float2 topLeftBottom = float2(0, 1 - width / 2);
                float2 bottomLeft = float2(0, width / 2);
                float2 centerLeft = float2(0.5 - width, width / 2);

                float2 topRightBottom = float2(1, 1 - width / 2);
                float2 bottomRight = float2(1, width / 2);
                float2 centerRight = float2(0.5 + width, width / 2);

                return 1 - (PointInTriangle(pt, topLeft, center, topRight)
                    * PointInTriangle(pt, topLeftBottom, centerLeft, bottomLeft)
                    * PointInTriangle(pt, topRightBottom, bottomRight, centerRight));
            }

            float TopTriangleCondition(float2 pt, float width) {
                float2 topCenter = float2(0.5, 1 - width / 2);
                float2 centerBottomLeft = float2(width, width / 2);
                float2 centerBottomRight = float2(1 - width, width / 2);

                float2 topLeft = float2(0, 1 - width / 2);
                float2 bottomLeft = float2(0, width / 2);
                float2 topCenterLeft = float2(0.5 - width, 1 - width / 2);

                float2 topRight = float2(1, 1 - width / 2);
                float2 bottomRight = float2(1, width / 2);
                float2 topCenterRight = float2(0.5 + width, 1 - width / 2);

                return 1 - (PointInTriangle(pt, topCenter, centerBottomLeft, centerBottomRight)
                    * PointInTriangle(pt, topLeft, topCenterLeft, bottomLeft)
                    * PointInTriangle(pt, topRight, bottomRight, topCenterRight));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 multipliedUv = i.uv * 10;
            
                float width = lerp(0.1, 0.4, abs(0.5 - i.uv.y));
                float isOdd = step(1, multipliedUv.y % 2); // Checking if odd

                float2 pt = frac(multipliedUv);
                float condition = lerp(BottomTriangleCondition(pt, width), TopTriangleCondition(pt, width), isOdd);

                return blackWhiteLerp(condition);
            }
            ENDCG
        }
    }
}
