Shader "CustomPP/Pixelate"
{
    HLSLINCLUDE

        #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
        int _PixelSize;

        float4 Frag(VaryingsDefault i) : SV_Target
        {
            float2 screenSize = float2(_ScreenParams.x, _ScreenParams.y);

            float2 pixelSize = screenSize / _PixelSize;

            float2 uv = floor(i.texcoord * pixelSize) / pixelSize;

            float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);

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
