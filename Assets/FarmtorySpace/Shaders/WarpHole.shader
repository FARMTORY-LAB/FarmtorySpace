Shader "Farmtory/WarpHole"
{
	Properties
	{
		_MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
		_FresnelColor("Fresnel Color", Color) = (1,1,1,1)
		_FresnelBias("Fresnel Bias", Float) = 0
		_FresnelScale("Fresnel Scale", Float) = 1
		_FresnelPower("Fresnel Power", Float) = 1
			/*
		_DistortionStrength("Distortion Strength", Range(0, 10)) = 3.020896
		_HoleSize("Hole Size", Range(0, 1)) = 0.7030833
		_HoleEdgeSmoothness("Hole Edge Smoothness", Range(0.001, 0.05)) = 0.007289694
			*/
	}

		SubShader
		{
			Tags
			{
				"Queue" = "Transparent"
				"IgnoreProjector" = "True"
				"RenderType" = "Transparent"
			}
			//Cull Off //Two sides

			GrabPass{ }
			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0

				#include "UnityCG.cginc"

				struct appdata_t
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
					float3 normal : NORMAL;
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					half2 uv : TEXCOORD0;
					float4 posWorld : TEXCOORD1;
					float3 normalDir : TEXCOORD2;
					float4 projPos : TEXCOORD3;
					float fresnel : TEXCOORD4;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed4 _Color;
				fixed4 _FresnelColor;
				fixed _FresnelBias;
				fixed _FresnelScale;
				fixed _FresnelPower;
				uniform sampler2D _GrabTexture;

				v2f vert(appdata_t v)
				{
					v2f o;
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					o.normalDir = UnityObjectToWorldNormal(-v.normal);
					o.posWorld = mul(unity_ObjectToWorld, v.vertex);
					o.pos = UnityObjectToClipPos(v.vertex);
					o.projPos = ComputeScreenPos(o.pos);
					COMPUTE_EYEDEPTH(o.projPos.z);

					float3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
					o.fresnel = _FresnelBias + _FresnelScale * pow(1 + dot(viewDir, v.normal), _FresnelPower);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					/*
					float3 viewDir = normalize(ObjSpaceViewDir(i.pos));
					float2 xy = i.normalDir.xy * i.fresnel;
					float2 sceneUVs = (i.projPos.xy / i.projPos.w);
					float4 sceneColor = tex2D(_GrabTexture, sceneUVs.rg + xy);

					return sceneColor;
					*/



					i.normalDir = normalize(i.normalDir);
					float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
					float3 normalDirection = i.normalDir;
					float2 sceneUVs = (i.projPos.xy / i.projPos.w);
					float4 sceneColor = tex2D(_GrabTexture, sceneUVs);
					////// Lighting:
					////// Emissive:

					float _HoleSize = 0.7030833;
					float _HoleEdgeSmoothness = 0.5;
					float _DistortionStrength = 3.020896;
					float node_9892 = (_HoleSize * -1.0 + 1.0);
					float node_1841 = smoothstep((node_9892 + _HoleEdgeSmoothness), (node_9892 - _HoleEdgeSmoothness), (1.0 - pow(1.0 - max(0,dot(normalDirection, viewDirection)),0.15))); // Create the hole mask
					float node_3969 = (1.0 - pow(1.0 - max(0,dot(normalDirection, viewDirection)),_DistortionStrength));
					float3 emissive = (node_1841 * tex2D(_GrabTexture, ((pow(node_3969,6.0) * (sceneUVs.rg * -2.0 + 1.0)) + sceneUVs.rg)).rgb);
					float3 finalColor = emissive;
					return fixed4(finalColor,1);
				}
				ENDCG
			}
		}
}