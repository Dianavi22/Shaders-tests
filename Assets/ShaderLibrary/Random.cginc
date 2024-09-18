#ifndef random
#define random

/** Inigo Quilez **/
float hash(float2 p)
{
    p = 50.0 * frac(p * 0.3183099 + float2(0.71, 0.113));
    return -1.0 + 2.0 * frac(p.x * p.y * (p.x + p.y));
}

float perlin(float2 p)
{
    float2 i = floor(p);
    float2 f = frac(p);

    float2 u = f * f * (3.0 - 2.0 * f);

    return lerp(lerp(hash(i + float2(0.0, 0.0)), hash(i + float2(1.0, 0.0)), u.x), lerp(hash(i + float2(0.0, 1.0)), hash(i + float2(1.0, 1.0)), u.x), u.y);
}
/** End of IQ **/

/// <summary>
/// Book of Shaders' random functions
/// </summary>
float2 random2(float2 p) {
    return frac(sin(float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)))) * 43758.5453);
}

/// <summary>
/// Voronoi noise algorithm (from multiple online sources)
/// </summary>
float voronoi(float2 value) {
    float2 baseCell = floor(value);
    float minDistToCell = 8;

    // Voronoi noise base algorithm
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            float2 cell = baseCell + float2(x, y);
            float2 cellPosition = cell + random2(cell);
            float2 toCell = cellPosition - value;
            float distToCell = length(toCell);

            minDistToCell = min(distToCell, minDistToCell);
        }
    }

    return minDistToCell;
}

#endif