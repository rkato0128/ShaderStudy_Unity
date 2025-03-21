Shader "Custom/Ronja's Tutorials/PolygonClippingShader"
{
    // 인스펙터에서 조작할 수 있는 값들이 보여집니다.
    Properties
    {
        _Color ("Color", Color) = (0, 0, 0, 1)
    }

    SubShader
    {
        // 메테리얼은 완전히 불투명하고, 다른 불투명 지오메트리와 같은 타이밍에 렌더됩니다.
        Tags{ "RenderType"="Opaque" "Queue"="Geometry"}

        Pass
        {
            CGPROGRAM

            // 유용한 셰이더 함수들을 포함해줍니다.
            #include "UnityCG.cginc"

            // 버텍스와 프래그먼트 셰이더 정의
            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Color;
            
            // 꼭짓점 처리를 위한 변수들
            uniform float2 _corners[1000];
            uniform uint _cornerCount;

            // 버텍스 셰이더에 전달되는 오브젝트 데이터
            struct appdata
            {
                float4 vertex : POSITION;
            };

            // 프래그먼트를 생성할 때 사용되며, 프래그먼트 셰이더에서 읽을 수 있는 데이터
            struct v2f
            {
                float4 position : SV_POSITION;
                float3 worldPos : TEXCOORD0;
            };

            // 버텍스 셰이더
            v2f vert (appdata v)
            {
                v2f o;
                // 렌더될 수 있도록 버텍스 좌표를 오브젝트 공간에서 클립 공간으로 변환
                o.position = UnityObjectToClipPos(v.vertex);
                // 월드 공간 상의 버텍스 좌표를 계산하고 할당
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldPos = worldPos.xyz;
                return o;
            }

            // 점이 선의 왼쪽에 위치한다면 1을, 아니라면 0을 반환합니다.
            float isLeftOfLine(float2 pos, float2 linePoint1, float2 linePoint2)
            {
                // 계산을 위해 필요한 변수들
                float2 lineDirection = linePoint2 - linePoint1;
                float2 lineNormal = float2(-lineDirection.y, lineDirection.x);
                float2 toPos = pos - linePoint1;

                // 테스트할 위치가 선의 어느 쪽에 있는지 계산
                float side = dot(toPos, lineNormal);
                side = step(0, side);

                return side;
            }

            // 프래그먼트 셰이더
            fixed4 frag (v2f i) : SV_Target
            {
                float outsideTriangle = 0;

                [loop]
                for(uint index; index < _cornerCount; index++)
                {
                    outsideTriangle += isLeftOfLine(i.worldPos.xy, _corners[index], _corners[(index+1) % _cornerCount]);
                }

                // 값이 0 미만이면 렌더되지 않음
                clip(-outsideTriangle);
                return _Color;
            }

            ENDCG
        }
    }
}
