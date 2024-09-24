Shader "CustomPP/CustomColor"
{
    HLSLINCLUDE

        #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
        float _Blend;
        float4 _MinColor;
        float4 _MaxColor;

        float4 Frag(VaryingsDefault i) : SV_Target
        {
            float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
            
            float luminance = dot(color.rgb, float3(0.2126729, 0.7151522, 0.0721750));

            float4 customColor = lerp(_MinColor, _MaxColor, luminance);

            color.rgb = lerp(color.rgb, customColor.rgb, _Blend);

            return color;
        }

    ENDHLSL

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM

                #pragma vertex VertDefault
                #pragma fragment Frag

            ENDHLSL
        }
    }
}
