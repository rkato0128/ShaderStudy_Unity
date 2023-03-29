Shader "Custom/BlinkingLight"
{
    Properties
    {
        _Color ("Light Color", Color) = (1, 1, 1, 1)
        _Intensity ("Light Intensity", Range(0, 1)) = 1
        _BlinkSpeed ("Blink Speed", Range(0, 10)) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            uniform float4 _Color;
            uniform float _Intensity;
            uniform float _BlinkSpeed;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float t = _Time.y * _BlinkSpeed;
                float c = sin(t) * 0.5 + 0.5;
                fixed4 col = _Color * _Intensity * c;
                
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}