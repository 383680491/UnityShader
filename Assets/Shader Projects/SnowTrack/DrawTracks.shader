  // 基于传入的uv坐标在绘制轨迹，一般基于RenderTexture拿到轨迹贴图
  Shader "Unlit/DrawTracks"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Coordinate("Coordinate", Vector) = (0, 0, 0, 0)
        _Color("Draw Color", Color) = (1, 0, 0, 0)
        //绘制范围
        _Size("Size", Range(1, 500)) = 200
        //绘制强度
        _Strength("Strength", Range(0, 1)) = 0.1
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Coordinate, _Color;
            half _Size, _Strength;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // 纹理本身有过平铺和偏移，则输入的模型UV坐标变换到与纹理的平铺和偏移匹配的空间以获取正确的纹理颜色
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // 这段代码的功能是划线，离传入的坐标uv越近，则线段的颜色就越深
                float draw = pow(saturate(1 - distance(i.uv, _Coordinate.xy)), 500 / _Size);
                fixed4 drawCol = _Color * (draw * _Strength);
                return saturate(col + drawCol);
            }
            ENDCG
        }
    }
}
