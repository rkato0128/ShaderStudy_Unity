Shader "Custom/Ronja's Tutorials/PlanarMappingShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
                //float2 uv : TEXCOORD0;
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
                // 오브젝트를 렌더하기 위해 클립 공간에서 좌표값 계산

                // #1 로컬 좌표계 기반 Planar Mapping
                o.uv = TRANSFORM_TEX(v.vertex.xz, _MainTex);
                // UV로 vertex의 x와 z를 사용해, 위에서 누른 듯 보여짐
                // TRANSFORM_TEX() 로 Offset 및 Tiling 적용

                // #2 월드 좌표계 기반 Planar Mapping
                float4 wordlPos = mul(unity_ObjectToWorld, v.vertex);
                // 월드 좌표계의 버텍스 위치 계산
                o.uv = TRANSFORM_TEX(wordlPos.xz,_MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                
                return col;
            }
            ENDCG
        }
    }
}
