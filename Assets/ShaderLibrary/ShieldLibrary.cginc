#ifndef shield
#define shield


            fixed4 CalculateColor(float2 uv, float borderSize, int nbRep)
            {
                float2 rotatedUV = Rotatepoint(radians(-45), uv);
                float2 repeatPt = frac(rotatedUV * nbRep);
                float2 center = float2(0.5, 0.5);
                float2 pt = GlobalToLocalPos(center, 0, repeatPt);

                float condition = EmptySquare(pt, borderSize / 2, 0.5) + 
                                  EmptySquare(repeatPt, borderSize, 0.7) + 
                                  EmptySquare(repeatPt, borderSize, 0.4);

                fixed4 col = lerp(fixed4(1, 1, 1, 1), fixed4(0, 0, 0, 1), condition);
                return col;
            }

             float2 Rotatepoint(float angle, float2 uv){
                float2 pt = mul(float2x2(cos(angle), -sin(angle), sin(angle), cos(angle)), uv);
                return pt;
             }

            fixed Square(float2 halfSize, float2 pt) {
                return smoothstep(-halfSize.x, -halfSize.x, pt.x) * (1 - smoothstep(halfSize.x, halfSize.x, pt.x)) * smoothstep(-halfSize.y, -halfSize.y, pt.y) * (1 - smoothstep(halfSize.y, halfSize.y, pt.y));
            }

            fixed EmptySquare(float2 pt, float borderSize, float halfWidth){
                return Square(halfWidth, pt) * (1 - Square(halfWidth - borderSize, pt));
            }

            float2 GlobalToLocalPos(float2 refPos, float refAngle, float2 globalPos) {
                float2 globalVect = globalPos - refPos;
                float2 localI = float2(cos(refAngle), sin(refAngle));
                float2 localJ = float2(-localI.y, localI.x); 

                return float2(dot(globalVect, localI), dot(globalVect, localJ));
            }

           


#endif