using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

namespace CustomPP.Rendering.PostProcessEffects
{
    [Serializable]
    [PostProcess(typeof(CustomColorRenderer), PostProcessEvent.AfterStack, "CustomPP/CustomColor")]
    public sealed class CustomColor : PostProcessEffectSettings
    {
        [Range(0f, 1f)]
        public FloatParameter blend = new FloatParameter { value = 0.0f };

        public ColorParameter minColor = new ColorParameter { value = Color.black };
        public ColorParameter maxColor = new ColorParameter { value = Color.white };

        public override bool IsEnabledAndSupported(PostProcessRenderContext context)
        {
            return enabled.value && blend.value > 0f;
        }
    }

    public sealed class CustomColorRenderer : PostProcessEffectRenderer<CustomColor>
    {
        public override void Render(PostProcessRenderContext context)
        {
            var sheet = context.propertySheets.Get(Shader.Find("CustomPP/CustomColor"));
            sheet.properties.SetFloat("_Blend", settings.blend);
            sheet.properties.SetColor("_MinColor", settings.minColor);
            sheet.properties.SetColor("_MaxColor", settings.maxColor);

            context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
        }
    }
}
