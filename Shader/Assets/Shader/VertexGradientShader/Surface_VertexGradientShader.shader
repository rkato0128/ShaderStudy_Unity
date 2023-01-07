Shader "Custom/VertexGradient/Surface_VertexGradientShader"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        // 프로퍼티 추가
        [Space]
        [Header(Gradation Option)]
        [Space]
        _StartColor ("Gradation Start Color", Color) = (1,1,1,1)
        _EndColor ("Gradation End Color", Color) = (1,1,1,1)
        _StartPos ("Gradation Start Position", Range(-1,1)) = 0
        _EndPos ("Gradation End Position", Range(-1,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        // RenderType / RenderQueue / Blend 추가 및 변경

        CGPROGRAM
        #pragma surface surf Standard vertex:vert alpha:blend
        // 버텍스 셰이더 사용을 위해 vertex:vert 구문 추가
        // 알파값이 적용되도록 alpha:blend 구문 추가

        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float4 color : COLOR; // color 변수 추가
        };

        // Vertex Gradient Shader
        half _StartPos;
        half _EndPos;
        fixed4 _StartColor;
        fixed4 _EndColor;

        void vert (inout appdata_full v)
        {
            float interpolValue;
            float range = _EndPos - _StartPos;
            interpolValue = clamp((_EndPos - v.vertex.y) / range, 0, 1);

            v.color = lerp(_EndColor, _StartColor, interpolValue);
        }
        // Vertex Gradient Shader End

        half _Glossiness;
        half _Metallic;

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb * IN.color.rgb; // 버텍스 컬러의 rgb값 적용

            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;

            o.Alpha = c.a * IN.color.a; // 버텍스 컬러의 알파값 적용
        }
        ENDCG
    }
    FallBack "Diffuse"
}
