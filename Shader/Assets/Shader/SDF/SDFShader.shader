Shader "Custom/SDFShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Threshold ("SDF Alpha Threshold", Range(0, 1)) = 0.5
        _EdgeSoftness ("Edge Softness", Range(0, 0.5)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

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
            float _Threshold;
            float _EdgeSoftness;
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                // Alpha Test
                //col.a = col.r > _Threshold;

                // Anti-aliasing
                float threshold = clamp(_Threshold, _EdgeSoftness, 1 - _EdgeSoftness); // threshold 값이 EdgeSoftness 값이 차지하는 범위만큼만 늘어나게 제한
                col.a = smoothstep(threshold - _EdgeSoftness, threshold + _EdgeSoftness, col.r);

                col.rgb = _Color.rgb;
                col.a *= _Color.a;

                return col;
            }
            ENDCG
        }
    }
}
