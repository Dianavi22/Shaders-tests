Shader "Introduction/TextureSample2"
{
    Properties
    {
        _MainTexture("Main Texture", 2D) = "white" {}
        _Color("Color", color) = (1,1,1,1)

        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcFactor("Src Factor", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstFactor("Dst Factor", Float) = 10
        [Enum(UnityEngine.Rendering.BlendOp)]
        _Opp("Operation", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Blend [_SrcFactor] [_DstFactor] 
        BlendOp [_Opp]

        //blend Formula 
        // Source = whatever this shader outputs 
        // destination = whatever is in the background

        // source * fsource + destination * fdestination
        // white * 0.7 + backgroundColor * (1-0.7)
        // we see &)% white and 30% of the background

        //Additive 
        // source * fsource + destination * fdestination
        // source * 1 + destination * 1

        // Grass + BG
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

           
             struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };



            sampler2D _MainTexture;
            float4 _MainTexture_ST;

            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTexture);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uvs = i.uv;
                fixed4 textureColor = tex2D(_MainTexture, uvs);
                return textureColor  ;
            }
            ENDCG
        }
    }
}
