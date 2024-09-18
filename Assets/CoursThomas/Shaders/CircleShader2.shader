Shader "Unlit/CircleShader"
{
    Properties
    {
      //  _MainTex ("Texture", 2D) = "white" {}
      _Radius("Radius", FLOAT) = 0.2
       //_Color1 ("Top Color", Color) = (1, 1, 1, 0)
       // _Color2 ("Bottom Color", Color) = (1, 1, 1, 0)
       //  _Intensity ("Intensity Amplifier", Float) = 1.0
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                UNITY_FOG_COORDS(1)
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            //sampler2D _MainTex;
            //float4 _MainTex_ST;
            fixed _Radius;
            fixed _Color;

            fixed linearstep(fixed a, fixed b, fixed x){
                return max(0, min(1, (x-a)/(b-a)));
                }

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
                fixed2 center = fixed2(0.5, 0.5);
                fixed dist = distance(center, i.uv);
                fixed remappedDistance = linearstep(0.2, 0.4, dist);
                remappedDistance *=5;
                remappedDistance = floor(remappedDistance);
                remappedDistance /=5;
                fixed4 col = fixed4(remappedDistance, remappedDistance, remappedDistance,1);
               
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
