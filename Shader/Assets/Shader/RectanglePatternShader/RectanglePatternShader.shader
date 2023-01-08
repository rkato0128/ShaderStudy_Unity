Shader "Custom/RectanglePattern"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)

        [Space]
        [Header(Rectangle Option)]
        [Space]
        _QuadSize ("Rectangle Size", Range(0, 50)) = 1 // 짝수만 입력
        _Rotation ("Pattern Rotation", Range(0, 360)) = 45
        [KeywordEnum(CENTER, CORNER)] _STARTPOINT ("Animation Starting Point", Float) = 0

        [Space]
        [Header(Test Option)]
        [Space]
        _Threshold ("Threshold", Range(-2, 2)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "PreviewType" = "Plane" }
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _STARTPOINT_CENTER _STARTPOINT_CORNER

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            float4 _Color;

            // Rectangle
            float _QuadSize;
            float _Rotation;

            float _Threshold; // For Test

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                float2 uv = i.uv;
                uv -= 0.5; // UV 기준점(0,0)을 중앙으로 옮기기

                // ----- UV 회전 - 회전 행렬을 사용
                float rotation = radians(_Rotation);
                // 사각형의 각도, 라디안값으로 변환 (숫자 45를 각도 45도로)

                float2x2 m = float2x2(cos(rotation), -sin(rotation), sin(rotation), cos(rotation));
                uv = mul(m, uv);
                // 벡터 uv와 행렬 m을 곱연산
                // ----- UV 회전 끝

                float2 pos = (_QuadSize * uv) + 0.5;
                // UV 타일링 이후 UV의 중앙점(0.5, 0.5)을 메시의 중앙점으로 이동

                float2 rep = frac(pos);
                // frac() : pos의 소숫점을 반환함
                // uv.x 의 값이 1.0 ~ 1.9 인 구간이 있다면 0.0~0.9 반환, 2.0~2.9도 동일하게 0.0~0.9 반환

                float2 adjust = float2(min(rep.x, 1.0 - rep.x), min(rep.y, 1.0 - rep.y));
                // min(a, b) : 두 값 중 작은 값을 반환
                // 현재 uv를 가져와 만든 float2(x,y)를 사용하고 있는데, 두가지 중 작은 값을 반환
                
                float dist = min(adjust.x, adjust.y) * 2.0; // adjust 의 x와 y 값 중 작은 값을 리턴하는 것으로 마름모꼴의 그라데이션이 생김
                // 최종 값에 2를 곱하는 이유 - 연산되는 값의 최대치가 0.5이기 때문에 2를 곱해서 최대치를 1로 만들어줌

                //float dist = (adjust.x * 2) * (adjust.y * 2); // adjust 의 x와 y를 서로 곱해주면 십자 별 느낌의 그라데이션이 됨
                // 십자 별 느낌의 그라데이션은 floor() 를 적용하지 않아야 부드럽게 전환됨
                // float threshold = (pos.x + 0.5 * _QuadSize) / _QuadSize;
                // col.rgb = dist > threshold + sin(_Time.y);

                //col.rgb = dist > sin(_Time.y);

                
            #if _STARTPOINT_CENTER // 1) 중앙에서 퍼져나가게 하기
                float thresholdX = floor(pos.x + 0.5 * _QuadSize) / _QuadSize;
                thresholdX -= 0.5;

                //col.rgb = abs(thresholdX);

                float thresholdY = floor(pos.y + 0.5 * _QuadSize) / _QuadSize;
                thresholdY -= 0.5;
    
                //col.rgb = min(1 - abs(thresholdX), 1 - abs(thresholdY));

                float threshold = min(1 - abs(thresholdX), 1 - abs(thresholdY));

                col.a = dist > threshold + sin(_Time.y);

            #elif _STARTPOINT_CORNER // 2) 모서리에서 퍼져나가게 하기
                float threshold = floor(pos.x + 0.5 * _QuadSize) / _QuadSize;
                col.a = dist > threshold + sin(_Time.y);
            #endif

                col *= _Color;
                return col;
            }
            ENDCG
        }
    }
}