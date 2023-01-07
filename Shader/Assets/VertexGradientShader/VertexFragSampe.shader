Shader "Custom/Sample_VertFrag"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //_ChangePoint ("Point for vertex color", Range(-1,1)) = 0 // 버텍스 컬러를 설정해주는 기준점

        _StartColor ("Gradient Start Color", Color) = (1,1,1,1)
        _EndColor ("Gradient End Color", Color) = (1,1,1,1)

        _StartPos ("Gradient Start Position", Range (-2, 2)) = 0
        _EndPos ("Gradient End Position", Range (-2, 2)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                fixed4 color : COLOR; // Color 추가
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR; // Color 추가
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _StartColor;
            fixed4 _EndColor;

            float _StartPos;
            float _EndPos;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                float interpolValue;
                float range = _EndPos - _StartPos;
                interpolValue = clamp((_EndPos - v.vertex.y) / range, 0, 1);
                // 버텍스가 그라디언트 상에서 어디에 위치하고 있는지를 구하고,
                // clamp 로 값이 0과 1을 벗어나지 않도록 고정

                o.color = lerp(_EndColor, _StartColor, interpolValue);
                // 버텍스 컬러에 그라디언트 상의 위치에 맞게 색상을 적용

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col = i.color; // 최종 색상값을 버텍스 컬러로 대체

                return col;
            }
            ENDCG
        }
    }
}
