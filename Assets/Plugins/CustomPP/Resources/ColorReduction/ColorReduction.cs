using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

namespace CustomPP.Rendering.PostProcessEffects
{
    [Serializable]
    [PostProcess(typeof(ColorReductionRenderer), PostProcessEvent.AfterStack, "CustomPP/ColorReduction")]
    public sealed class ColorReduction : PostProcessEffectSettings
    {
        [Range(2, 256)]
        public IntParameter colorLevels = new IntParameter { value = 8 };

        public override bool IsEnabledAndSupported(PostProcessRenderContext context)
        {
            return enabled.value && colorLevels.value > 1;
        }
    }

    public sealed class ColorReductionRenderer : PostProcessEffectRenderer<ColorReduction>
    {
        public override void Render(PostProcessRenderContext context)
        {
            var sheet = context.propertySheets.Get(Shader.Find("CustomPP/ColorReduction"));
            sheet.properties.SetInt("_ColorLevels", settings.colorLevels);

            context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
        }
    }
}
