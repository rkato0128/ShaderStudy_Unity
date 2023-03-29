Shader "Custom/HoundToothPattern" {
    Properties {
        _Sharpness ("Sharpness", Range(1, 100)) = 100
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            uniform float _Sharpness;

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                //float2 uv = frac(i.uv / _ScreenParams.y * 8); // Chat GPT가 작성한 코드
                float2 uv = frac(i.uv * 8);
                // Tiling 해주는 부분인데 왜 ScreenParams 를 추가로 곱했는지 모르겠음.
                // 원본 코드가 i.uv 대신 화면 해상도를 사용하는데,
                // 해당 부분을 동일한 역할인 _ScreenParams 로 변환해준듯함.

                float2 mask = clamp((uv - 0.5) * _Sharpness, 0, 1);

                //float color = clamp((abs((fract(abs(uv.x - uv.y) * 2.0 + 0.25) - 0.5) * 2.0) - 0.5) * _Sharpness / 5.0, 0, 1); // Chat GPT가 작성한 코드
                float color = clamp((abs((frac(abs(uv.x - uv.y) * 2.0 + 0.25) - 0.5) * 2.0) - 0.5) * _Sharpness / 5.0, 0, 1);
                // clamp(abs()) 부분 괄호 내 fract 는 GLSL 에서 HLSL로 변환하지 못함.

                color = max(color, min(mask.x, mask.y)) * max(mask.x, mask.y);

                return fixed4(color, color, color, 1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}