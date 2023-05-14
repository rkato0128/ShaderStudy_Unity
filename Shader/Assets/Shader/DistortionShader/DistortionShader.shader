Shader "Custom/Distortion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [Space]
        [Header(Distortion Option)]
        [Space]
        [KeywordEnum(DISTANCE, TEXTURE)] _METHOD ("Animation Starting Point", Float) = 0
        _DistortionTex ("Distortion Texture", 2D) = "white" {}
        _DisTexTiling ("Distortion Texture Tiling Value", Float) = 1
        [Space]
        [Toggle] _REVERSE ("Reverse Distortion", Float) = 0
        _Power ("Distortion Power", Float) = 1
        _Value ("Distortion Value", Float) = 0
        _Tiling ("Tiling Value", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _METHOD_DISTANCE _METHOD_TEXTURE
            #pragma shader_feature _REVERSE_ON

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

            sampler2D _DistortionTex;
            float _DisTexTiling;
            float _Power;
            float _Value;
            float _Tiling;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col;
                fixed reverse = 0;

            #if _REVERSE_ON // 왜곡 적용 방향 반전
                reverse = 1;
            #endif

            // 1) distance() 사용해 왜곡 적용
            #if _METHOD_DISTANCE
                float2 uv1 = (i.uv - 0.5) * _Tiling;
                float dis = distance(float2(0, 0), uv1);
                // 텍스처 중앙점(원래값 0.5, 0.5)에서 거리 계산
                dis = abs(reverse - dis / _Tiling) * _Tiling;
                // reverse가 1일 경우 반전 적용

                float2 distortedUV = uv1 * pow(dis, _Power);
                // pow 적용해 왜곡 강도 조정
                uv1 += 0.5;
                distortedUV += 0.5;
                // UV 이동

                float2 finalUV = lerp(uv1, distortedUV, _Value);

                col = tex2D(_MainTex, finalUV);
            #endif

            // 2) 텍스처를 사용해 왜곡 적용
            #if _METHOD_TEXTURE
                float2 uv2 = (i.uv - 0.5) * _Tiling;

                fixed4 distortionTex = tex2D(_DistortionTex, (i.uv - 0.5) * _DisTexTiling + 0.5); // 왜곡용 텍스처
                fixed disTex = abs(reverse - distortionTex.r);
                // reverse가 1일 경우 반전 적용

                float2 disTexUV = uv2 * pow(disTex, _Power) + 0.5;
                uv2 += 0.5;
                // pow 적용해 왜곡 강도 조정, UV 이동

                float2 finalTexUV = lerp(uv2, disTexUV, _Value);

                col = tex2D(_MainTex, finalTexUV);
            #endif

                return col;
            }
            ENDCG
        }
    }
}
