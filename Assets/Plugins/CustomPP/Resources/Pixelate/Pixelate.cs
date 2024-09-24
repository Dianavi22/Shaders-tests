using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

namespace CustomPP.Rendering.PostProcessEffects
{
    [Serializable]
    [PostProcess(typeof(PixelateRenderer), PostProcessEvent.AfterStack, "CustomPP/Pixelate")]
    public sealed class Pixelate : PostProcessEffectSettings
    {
        [Range(1, 100)]
        public IntParameter pixelSize = new IntParameter { value = 128 };

        public override bool IsEnabledAndSupported(PostProcessRenderContext context)
        {
            return enabled.value && pixelSize.value > 1;
        }
    }

    public sealed class PixelateRenderer : PostProcessEffectRenderer<Pixelate>
    {
        public override void Render(PostProcessRenderContext context)
        {
            var sheet = context.propertySheets.Get(Shader.Find("CustomPP/Pixelate"));
            sheet.properties.SetInt("_PixelSize", settings.pixelSize);

            context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
        }
    }
}
