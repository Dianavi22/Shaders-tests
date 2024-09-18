#ifndef geometry
#define geometry

/// <summary>
/// Return 1 if the point pt is within the hexagon from center with halfwidth
/// </summary>
float Hexagon(float2 pt, float2 center, float halfWidth, float halfHeight) {
    float2 q2 = abs(float2(pt - center)); // Current point in local ref
    float2 p2 = float2(halfWidth, halfHeight); // Bottom right point of the hex
                
    float2 n = float2(-halfHeight, -halfWidth); // Normal vector from p2
    float2 m = q2 - p2; // vector from p2 to current point

    // Return one if in the hexagon, the other two steps are to check if it's in the box bounding the hexagon
    return (1 - step(halfWidth, q2.x)) * (1 - step(halfHeight * 2, q2.y)) * step(0, dot(n, m));
}

/// <summary>
/// Return 1 if inside the line of the emptied hexagon
/// </summary>
float EmptyHexagon(float2 pt, float2 center, float halfWidth, float lineWidth, float halfHeight) {
    return Hexagon(pt, center, halfWidth, halfHeight) * (1 - Hexagon(pt, center, halfWidth - lineWidth, halfHeight - lineWidth / 2));
}

float HexaGrid(float2 pt,  float lineWidth, float fracNumber) {
    // Square size within the (1, 1) space. We keep the 1 in y so it does not go beyond 1 (otherwise it'd be a (1, sqrt(3)) space but sqrt(3) > 1
    float2 squareSize = float2(1, sqrt(3)) / sqrt(3);

    // Center of centered hexagon within the current square
    float2 center = squareSize / 2;

    // Calculating halfwidth which equals the center
    float halfWidth = center.x;

    // Calculating halfwidth. 
    // Thanks to hexagon property, we know that half height equals half width devided by sqrt(3) (because we're working on the sqrt(3) based environment)
    float halfHeight = halfWidth / sqrt(3); 

    // frac point to have this pattern repeated. We're working on a smaller size that (1, 1) [see squareSize], so we have to add modulus + a small offset
    // No modulus on y because we know that we're working on a 1 width square
    float2 fr = frac(float2((pt.x * fracNumber) % (squareSize.x + .025), pt.y * fracNumber));
                
    // Set up to .05 because it'll be time two and we want a .1 offset
    float halfWidthCoef = 1.05; 

    // .1 to get the small offset
    float halfHeightCoef = 3.1; 

    // Return the centered hexagon + 4 hexagons parts on the coins
    return EmptyHexagon(fr, center, halfWidth, lineWidth, halfHeight)
        + EmptyHexagon(fr, center + float2(-halfWidthCoef * halfWidth, -halfHeightCoef * halfHeight), halfWidth, lineWidth, halfHeight) // 0, 0 
        + EmptyHexagon(fr, center + float2(halfWidthCoef * halfWidth, -halfHeightCoef * halfHeight), halfWidth, lineWidth, halfHeight) // 1, 0
        + EmptyHexagon(fr, center + float2(-halfWidthCoef * halfWidth, halfHeightCoef * halfHeight), halfWidth, lineWidth, halfHeight) // 0, 1
        + EmptyHexagon(fr, center + float2(halfWidthCoef * halfWidth, halfHeightCoef * halfHeight), halfWidth, lineWidth, halfHeight); // 1, 1
}

/// Draw a circle
float Circle(float2 center, float radius, float2 pt) {
    return step((pt.x - center.x) * (pt.x - center.x) + (pt.y - center.y) * (pt.y - center.y), radius * radius);
}

/// Draw an empty circle
float EmptyCircle(float2 center, float radius, float2 pt) {
    return Circle(center, radius, pt) * (1 - Circle(center, radius - (radius/10), pt));
}

// Return the point relative from [refPoint] and [refAngle] from a [globalPos] relative to (0, 0) (bottom left corner)
float2 GlobalToLocalPos(float2 refPos, float refAngle, float2 globalPos) {
    float2 globalVect = globalPos - refPos;
    float2 localI = float2(cos(refAngle), sin(refAngle));
    float2 localJ = float2(-localI.y, localI.x); 

    return float2(dot(globalVect, localI), dot(globalVect, localJ));
}

/// Draw a square
fixed Square(float2 halfSize, float2 pt) {
    return smoothstep(-halfSize.x, -halfSize.x, pt.x)
        * (1 - smoothstep(halfSize.x, halfSize.x, pt.x))
        * smoothstep(-halfSize.y, -halfSize.y, pt.y)
        * (1 - smoothstep(halfSize.y, halfSize.y, pt.y));
}

// Draw an empty square
fixed EmptySquare(float2 pt, float borderSize, float halfWidth){
    return Square(halfWidth, pt) * (1 - Square(halfWidth - borderSize, pt));
}


#endif