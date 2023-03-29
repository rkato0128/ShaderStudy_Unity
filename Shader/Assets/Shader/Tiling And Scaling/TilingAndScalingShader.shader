Shader "Custom/TilingAndScalingShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Tiling ("Tiling Value", Float) = 1
        _Scale ("Scaling Value", Float) = 1
        _OffsetX ("Offset X Value", Float) = 0
        _OffsetY ("Offset Y Value", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "PreviewType" = "Plane" }

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

            float _Tiling;
            float _Scale;
            float _OffsetX;
            float _OffsetY;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 offset = float2(_OffsetX, _OffsetY);
                float2 uv = saturate((frac((i.uv - 0.5) * _Tiling + 0.5 + offset) - 0.5) * _Scale + 0.5);
                // 중앙 기준으로 타일링 / 크기 조절되도록 수정 + Offset 값 추가
                
                fixed4 col = tex2D(_MainTex, uv);

                return col;
            }
            ENDCG
        }
    }
}
