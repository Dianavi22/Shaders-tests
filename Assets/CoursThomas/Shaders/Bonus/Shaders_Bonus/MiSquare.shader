Shader "Bonus Shaders/SquareConcentrics"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BorderSize ("Border Size", float) = 0.2
        _NbRep ("Nombre rep", int) = 1 
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
            int _NbRep;

            v2f vert (appdata v)
            {
               v2f o;
               o.vertex = UnityObjectToClipPos(v.vertex);
               o.uv = v.uv;
               UNITY_TRANSFER_FOG(o, o.vertex);
               return o;
            }

            float2 Rotatepoint(float angle, float2 uv){
                float2 pt = mul(float2x2(cos(angle), -sin(angle), sin(angle), cos(angle)), uv);
                return pt;
             }

            fixed Square(float2 halfSize, float2 pt) {
                return smoothstep(-halfSize.x, -halfSize.x, pt.x) * (1 - smoothstep(halfSize.x, halfSize.x, pt.x)) * smoothstep(-halfSize.y, -halfSize.y, pt.y) * (1 - smoothstep(halfSize.y, halfSize.y, pt.y));
            }

            fixed EmptySquare(float2 pt, float borderSize, float halfWidth){
                return Square(halfWidth, pt) * (1 - Square(halfWidth - borderSize, pt));
            }

            float2 GlobalToLocalPos(float2 refPos, float refAngle, float2 globalPos) {
                float2 globalVect = globalPos - refPos;
                float2 localI = float2(cos(refAngle), sin(refAngle));
                float2 localJ = float2(-localI.y, localI.x); 

                return float2(dot(globalVect, localI), dot(globalVect, localJ));
            }

            // Nouvelle fonction pour encapsuler le calcul de la couleur
            fixed4 CalculateColor(float2 uv, float borderSize, int nbRep)
            {
                float2 rotatedUV = Rotatepoint(radians(-45), uv);
                float2 repeatPt = frac(rotatedUV * nbRep);
                float2 center = float2(0.5, 0.5);
                float2 pt = GlobalToLocalPos(center, 0, repeatPt);

                float condition = EmptySquare(pt, borderSize / 2, 0.5) + 
                                  EmptySquare(repeatPt, borderSize, 0.7) + 
                                  EmptySquare(repeatPt, borderSize, 0.4);

                fixed4 col = lerp(fixed4(1, 1, 1, 1), fixed4(0, 0, 0, 1), condition);
                return col;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Utilisation de la nouvelle fonction CalculateColor
                fixed4 col = CalculateColor(i.uv, _BorderSize, _NbRep);

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }

            ENDCG
        }
    }
}
