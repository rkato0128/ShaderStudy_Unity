Shader "Custom/CandleFlame" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _FlameSpeed ("Flame Speed", Range(0.1, 10)) = 1
        _FlameHeight ("Flame Height", Range(0, 2)) = 1
        _FlameIntensity ("Flame Intensity", Range(0, 1)) = 1
        _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float _FlameSpeed;
            float _FlameHeight;
            float _FlameIntensity;

            v2f vert (appdata v) {
                v.vertex.y += _FlameHeight * (1 - (cos(_Time.y * _FlameSpeed) * 0.5 + 0.5));
                float2 offset = float2(
                    sin(v.vertex.y * 15 + _Time.y * 3),
                    sin(v.vertex.y * 22 + _Time.y * 4)
                ) * _FlameIntensity;
                v.vertex.xyz += float3(offset * v.vertex.w, 0);
                v.uv.y += (1 - (cos(_Time.y * _FlameSpeed) * 0.5 + 0.5));
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _Color;

            fixed4 frag (v2f i) : SV_Target {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}