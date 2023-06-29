Shader "Hidden/SnowFall"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            float rand(float3 co)
            {
                return frac(sin(dot(co.xyz, float3(12.9898, 78.233, 45.5432))) * 43758.5453);
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _FlakeAmount, _FlakeOpacity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            // _MainTex是前面DrawTrack生成的红色轨迹贴图，col越红则产生的雪痕迹越明显，为了实现雪痕迹逐渐消失的效果，需要红色颜色逐渐变淡至消失(为0)
            // 而雪迹消融也不能完全以时间的长度来判断，比如时间越长消散的越快，效果也会假，故不能直接使用color减去 time*threshode。
            // 最理想的是时间慢一点的也会提前随机消散，稀疏的雪花点效果的算法如下
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float rValue = ceil(rand(float3(i.uv.x, i.uv.y, 0) * _Time.x) - (1 - _FlakeAmount));
                return saturate(col - (rValue * _FlakeOpacity));
            }
            ENDCG
        }
    }
}
