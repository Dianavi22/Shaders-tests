Shader "Unlit/SquareShaderCad"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BorderSize ("Border Size", FLOAT) = 0.2
        _Radius ("Radius", FLOAT) = 0.2
        _RotationSpeed ("Rotation Speed", FLOAT) = 1.0
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
            fixed _Radius;
            fixed _RotationSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 center = float2(0.5, 0.5);

                float2 uv = i.uv - center;

                float angle = _RotationSpeed * _Time.y;

                float2x2 rotationMatrix = float2x2(cos(angle), -sin(angle),
                                                   sin(angle), cos(angle));

                uv = mul(rotationMatrix, uv);

                uv += center;

                float2 uvGrid = frac(uv * 5);
                fixed2 sizeVec = fixed2(_BorderSize, _BorderSize);

                fixed2 bottumLeft = step(sizeVec, uvGrid);
                fixed inSquare = bottumLeft.x * bottumLeft.y;

                fixed2 topRight = step(sizeVec, 1 - uvGrid);
                inSquare *= topRight.x * topRight.y;

                fixed iInCircle = 1 - step(_Radius, distance(center, uv)) + inSquare;

                fixed4 col = fixed4(inSquare, inSquare, inSquare, 1);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
