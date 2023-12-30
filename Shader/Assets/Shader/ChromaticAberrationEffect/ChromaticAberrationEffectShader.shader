Shader "Custom/ChromaticAberrationEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Space]
        [Header (Chromatic Aberration Effect)]
        [Space]
        _Intensity ("Chromatic Aberration Intensity", Float) = 0
        [Space]
        _RChannelAngle ("Red Channel Rotation Angle", Range(0, 360)) = 290
        _GChannelAngle ("Green Channel Rotation Angle", Range(0, 360)) = 0
        _BChannelAngle ("Blue Channel Rotation Angle", Range(0, 360)) = 125
        [Space]
        _RChannelRange ("Red Channel Motion Range", Range(0, 1)) = 1
        _GChannelRange ("Green Channel Motion Range", Range(0, 1)) = 0
        _BChannelRange ("Blue Channel Motion Range", Range(0, 1)) = 1
        [Space]
        [Header (Distance Options)]
        [Space]
        _DistanceParam ("Distance Effect Parameter", Range(0, 1)) = 0
        [Header (Glitch Effect)]
        [Space]
        [MaterialToggle] _isGlitchOn("Glitch Effect Toggle", Float) = 0
        _GlitchSpeed ("Glitch Animation Speed", Float) = 15
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "RenderType"="Transparent"
            "PriviewTyoe"="Plane"
        }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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

            float _Intensity;

            float _RChannelAngle;
            float _GChannelAngle;
            float _BChannelAngle;

            float _RChannelRange;
            float _GChannelRange;
            float _BChannelRange;

            float _DistanceParam;

            float _isGlitchOn;
            float _GlitchSpeed;


            // Random 함수
            float random (in float2 st)
            {
                return frac(sin(dot(st.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }


            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                // Random 함수를 사용해 색수차 글리치 애니메이션 추가
                float rand = random(floor(i.uv + float2(floor(_Time.y * _GlitchSpeed), 0)));

                // Distance 함수를 사용해 화면 외곽부로 갈수록 효과 강해지게 하기
                float distanceValue = distance(float2(0.5, 0.5), i.uv) * _DistanceParam;

                // 색수차 효과의 적용 각도 라디안값으로 변환
                // 랜덤 값을 더해 각도를 불규칙적으로 변경해 글리치 효과 생성
                float rRadian = radians(_RChannelAngle + rand * 360 * _isGlitchOn);
                float gRadian = radians(_GChannelAngle + rand * 360 * _isGlitchOn);
                float bRadian = radians(_BChannelAngle + rand * 360 * _isGlitchOn);

                // 색수차 효과 벡터의 크기를 조정
                float rMotionValue = _RChannelRange * _Intensity * 0.001;
                float gMotionValue = _GChannelRange * _Intensity * 0.001;
                float bMotionValue = _BChannelRange * _Intensity * 0.001;

                // Distance 값 적용
                rMotionValue = lerp(rMotionValue, rMotionValue * distanceValue, _DistanceParam);
                gMotionValue = lerp(gMotionValue, gMotionValue * distanceValue, _DistanceParam);
                bMotionValue = lerp(bMotionValue, bMotionValue * distanceValue, _DistanceParam);

                // 각도에 맞게 색수차 효과를 내줄 벡터 회전
                float2 rMotion = float2(cos(rRadian), sin(rRadian)) * rMotionValue;
                float2 gMotion = float2(cos(gRadian), sin(gRadian)) * gMotionValue;
                float2 bMotion = float2(cos(bRadian), sin(bRadian)) * bMotionValue;

                // 채널별 UV에 색수차 효과 벡터를 더해 이미지를 채널별로 움직임
                col.r = tex2D(_MainTex, i.uv + rMotion).r;
                col.g = tex2D(_MainTex, i.uv + gMotion).g;
                col.b = tex2D(_MainTex, i.uv + bMotion).b;

                return col;
            }
            ENDCG
        }
    }
}
