Shader "CustomPP/ColorReduction"
{
    HLSLINCLUDE

        #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
        int _ColorLevels;

        float4 Frag(VaryingsDefault i) : SV_Target
        {
            float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);

            float levels = _ColorLevels;
            float invLevels = 1.0 / levels;

            color.r = floor(color.r * levels) * invLevels;
            color.g = floor(color.g * levels) * invLevels;
            color.b = floor(color.b * levels) * invLevels;

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
