Shader "Farmtory/Master"
{
    Properties
    {
		_Color("Color", Color) = (1,1,1,1)
        _AlbedoGrayScaleLevel ("Albedo Gray Scale Level", Range(1, 10)) = 1.5
        _AlbedoGrayScaleOffset ("Albedo Gray Scale Offset", Range(0, 1)) = 0.5
        [NoScaleOffset] _Albedo("Albedo (RGB), Alpha (A)", 2D) = "white" {}
        //[NoScaleOffset] _Metallic("Metallic (R), Occlusion (G), Emission (B), Smoothness (A)", 2D) = "black" {}
        [NoScaleOffset] _Normal("Normal (RGB)", 2D) = "bump" {}
        [NoScaleOffset] _DispTex("Displacement Texture", 2D) = "white" {}
        _Displacement("Displacement Amount",  Range(0.000, 0.08)) = 0.005
        _Smoothness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        //_Emission("Emission", Range(0,1)) = 0.0
        //_Occulusion("Occulusion", Range(0,1)) = 0.0
    }

        SubShader
        {
            Tags
            {
                "Queue" = "Geometry"
                "RenderType" = "Opaque"
            }

            CGINCLUDE
            #define _GLOSSYENV 1
            ENDCG

            CGPROGRAM
            #pragma target 3.0
            #include "UnityPBSLighting.cginc"
            #pragma surface surf Standard vertex:vert
            #pragma exclude_renderers gles

            struct Input
            {
                float2 uv_Albedo;
            };

            sampler2D _Albedo;
            sampler2D _Normal;
            //sampler2D _Metallic;
            sampler2D _DispTex;

            fixed4 _Color;
            float _Displacement;
            float _AlbedoGrayScaleLevel;
            float _AlbedoGrayScaleOffset;
			half _Smoothness;
			half _Metallic;
			//half _Occulusion;
			//half _Emission;

            void vert(inout appdata_full v)
            {
                v.vertex.xyz += v.normal * tex2Dlod(_DispTex, float4(v.texcoord.xy, 0, 0)).r * _Displacement;
            }

            void surf(Input IN, inout SurfaceOutputStandard o)
            {
                fixed4 albedo = tex2D(_Albedo, IN.uv_Albedo);
				 //Makes gray scale
                fixed4 gray = dot(albedo.rgb, float3(0.3, 0.59, 0.11)).r * _AlbedoGrayScaleLevel + _AlbedoGrayScaleOffset;
                albedo = gray * _Color;

                fixed3 normal = UnpackScaleNormal(tex2D(_Normal, IN.uv_Albedo), 1);

                o.Albedo = albedo.rgb;
                o.Alpha = albedo.a;
                o.Normal = normal;

				o.Metallic = _Metallic;
				o.Smoothness = _Smoothness;
                //o.Occlusion = _Occulusion;
                //o.Emission = _Emission;
            }
            ENDCG
        }

            FallBack "Diffuse"
}