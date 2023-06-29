

/*
Tessellation阶段会将Mesh表面划分成许多小三角形,以产生更加平滑的效果。这个阶段包括:
1. Hull Shader: 控制每个大三角形被细分成几个小三角形。
2. Tessellator: 根据Hull Shader的指示实际将Mesh细分。
3. Domain Shader: 计算每个新生成小三角形顶点的属性,如位置、法线、UV等。
*/

Shader "Custom/SnowTrack"
{
    Properties
    {
        // mesh表面细分级别，控制地面细微平滑程度。 处于Hull Shader阶段
        _Tess("Tessellation", Range(1,128)) = 4

        // 车辙的深度和形变量,控制车辙效果的明显程度 处于Domain Shader 阶段
        _Displacement("Displacement", Range(0, 1.0)) = 0.3

        //轨迹贴图，红色的轨迹
        _Track("TrackMap", 2D) = "black" {}

        //雪花贴图 和颜色  
        _SnowTex ("Snow (RGB)", 2D) = "white" {}
        _SnowColor("Snow Color", Color) = (1,1,1,1)

         //地面贴图和颜色   基于_Track轨迹，颜色(0~1)实现 雪花和地面的mix
        _GroundTex("Ground (RGB)", 2D) = "white" {}
        _GroundColor("Ground Color", Color) = (1,1,1,1)

        // PBR 平滑度   越平滑则高光反射越强  
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        // 金属度  金属度越高 色调看起来越冷
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:disp tessellate:tessDistance

        #pragma target 4.6

        #include "Tessellation.cginc"
        struct appdata {
            float4 vertex : POSITION;
            float4 tangent : TANGENT;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD0;
        };

        float _Tess;
        
        // 根据Hull Shader的指示实际将Mesh细分
        float4 tessDistance(appdata v0, appdata v1, appdata v2) {
            float minDist = 100.0;
            float maxDist = 250.0;
            return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
        }

        sampler2D _Track;
        float _Displacement;
        
        // 计算每个新生成小三角形顶点的属性,如位置、法线、UV等
        // domin Shader  轨迹的深浅(r -> [0, 1])
        // 法线是朝上的，由于是轨迹，颜色越深则顶点应越靠近下面，因为雪花消融嘛，所以先减去法线的偏移
        void disp(inout appdata v)
        {
            float d = tex2Dlod(_Track, float4(v.texcoord.xy,0,0)).r * _Displacement;
            v.vertex.xyz -= v.normal * d;
            v.vertex.xyz += v.normal * _Displacement;
        }

        sampler2D _GroundTex;
        fixed4 _GroundColor;
        sampler2D _SnowTex;
        fixed4 _SnowColor;

        struct Input
        {
            float2 uv_GroundTex;
            float2 uv_SnowTex;
            float2 uv_Track;
        };

        half _Glossiness;
        half _Metallic;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color 拿到范围
            half amount = tex2Dlod(_Track, float4(IN.uv_Track, 0, 0)).r;
            // 基于 amount mix 贴图
            fixed4 c = lerp(tex2D(_SnowTex, IN.uv_SnowTex) * _SnowColor,
                tex2D(_GroundTex, IN.uv_GroundTex) * _GroundColor,
                amount);
            // PBR
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
