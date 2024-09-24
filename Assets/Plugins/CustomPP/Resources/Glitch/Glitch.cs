using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

namespace CustomPP.Rendering.PostProcessEffects
{
    [Serializable]
    [PostProcess(typeof(GlitchRenderer), PostProcessEvent.AfterStack, "CustomPP/Glitch")]
    public sealed class Glitch : PostProcessEffectSettings
    {
        public FloatParameter m_GlitchInterval = new FloatParameter { value = 0.5f };
        public FloatParameter m_DispProbability = new FloatParameter { value = 0.0f };
        public FloatParameter m_DispIntensity = new FloatParameter { value = 0.0f };
        public FloatParameter m_ColorProbability = new FloatParameter { value = 0.0f };
        public FloatParameter m_ColorIntensity = new FloatParameter { value = 0.0f };
        public FloatParameter m_DispStripSize = new FloatParameter { value = 0.2f };

        public FloatParameter m_GlitchSize = new FloatParameter { value = 1.0f };  
        public FloatParameter m_GlitchSpeed = new FloatParameter { value = 1.0f }; 

        public override bool IsEnabledAndSupported(PostProcessRenderContext context)
        {
            return enabled.value
                && (m_DispProbability.value > 0f
                || m_DispIntensity.value > 0f
                || m_ColorProbability > 0f
                || m_ColorIntensity > 0f);
        }
    }

    public sealed class GlitchRenderer : PostProcessEffectRenderer<Glitch>
    {
        public override void Render(PostProcessRenderContext context)
        {
            var sheet = context.propertySheets.Get(Shader.Find("CustomPP/Glitch"));
            sheet.properties.SetFloat("_GlitchInterval", settings.m_GlitchInterval);
            sheet.properties.SetFloat("_DispProbability", settings.m_DispProbability);
            sheet.properties.SetFloat("_DispIntensity", settings.m_DispIntensity);
            sheet.properties.SetFloat("_ColorProbability", settings.m_ColorProbability);
            sheet.properties.SetFloat("_ColorIntensity", settings.m_ColorIntensity);
            sheet.properties.SetFloat("_DispStripSize", settings.m_DispStripSize);

            sheet.properties.SetFloat("_GlitchSize", settings.m_GlitchSize);
            sheet.properties.SetFloat("_GlitchSpeed", settings.m_GlitchSpeed);

            context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
        }
    }
}
