Shader "CustomPP/Glitch"
{
    HLSLINCLUDE

    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    float _GlitchInterval;
    float _DispProbability;
    float _DispIntensity;
    float _ColorProbability;
    float _ColorIntensity;
    float _DispStripSize;
    float _GlitchSize;  
    float _GlitchSpeed;  

    float rand(float x, float y) {
        return frac(sin(x * 12.9898 + y * 78.233) * 43758.5453);
    }

    float4 Frag(VaryingsDefault i) : SV_Target
    {
        float intervalTime = floor(_Time.y * _GlitchSpeed / _GlitchInterval) * _GlitchInterval;
        float intervalTime2 = intervalTime + 2.793;

        float timePositionVal = intervalTime;
        float timePositionVal2 = intervalTime2;

        float dispGlitchRandom = rand(timePositionVal, -timePositionVal);
        float colorGlitchRandom = rand(timePositionVal, timePositionVal);

        float rShiftRandom = (rand(-timePositionVal, timePositionVal) - 0.5) * _ColorIntensity;
        float gShiftRandom = (rand(-timePositionVal, -timePositionVal) - 0.5) * _ColorIntensity;
        float bShiftRandom = (rand(-timePositionVal2, -timePositionVal2) - 0.5) * _ColorIntensity;

        float shiftLineOffset = float((rand(timePositionVal2, timePositionVal2) - 0.5) / 50);

        if (dispGlitchRandom < _DispProbability) {
            i.texcoord.x += (rand(floor(i.texcoord.y / (_DispStripSize + shiftLineOffset)) - timePositionVal, floor(i.texcoord.y / (_DispStripSize + shiftLineOffset)) + timePositionVal) - _DispStripSize) * _DispIntensity * _GlitchSize;
            i.texcoord.x = saturate(i.texcoord.x);
        }

        float4 rShifted = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, float2(i.texcoord.x + rShiftRandom, i.texcoord.y + rShiftRandom));
        float4 gShifted = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, float2(i.texcoord.x + gShiftRandom, i.texcoord.y + gShiftRandom));
        float4 bShifted = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, float2(i.texcoord.x + bShiftRandom, i.texcoord.y + bShiftRandom));

        float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);

        if (colorGlitchRandom < _ColorProbability) {
            color.r = rShifted.r;
            color.g = gShifted.g;
            color.b = bShifted.b;
            color.a = (rShifted.a + gShifted.a + bShifted.a) / 3;
        }
        else {
            color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
        }

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
