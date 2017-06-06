Shader "Nature/Tree Soft Occlusion Leaves 2" {
	Properties{
		_TopColor("Top Color", Color) = (1, 1, 1, 1)
		_BottomColor("Bottom Color in Top", Color) = (1, 1, 1, 1)
		_StartTopGradient("Top Gradient's Start", Range(0, 1)) = 0.5

		_TopMidColor("Top Color in Mid", Color) = (1, 1, 1, 1)
		_BottomMidColor("Bottom Color in Mid", Color) = (1, 1, 1, 1)

		_EndBottomGradient("End Of the Bottom Gradient", Range(0, 1)) = 0.4

		_TopBottomColor("Top Color from Below", Color) = (1, 1, 1, 1)
		_GroundBottomColor("Very Bottom Color", Color) = (1, 1, 1, 1)

		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "white" {  }
	_Cutoff("Alpha cutoff", Range(0.25,0.9)) = 0.5
		_BaseLight("Base Light", Range(0, 1)) = 0.35
		_AO("Amb. Occlusion", Range(0, 10)) = 2.4
		_Occlusion("Dir Occlusion", Range(0, 20)) = 7.5

		// These are here only to provide default values
		[HideInInspector] _TreeInstanceColor("TreeInstanceColor", Vector) = (1,1,1,1)
		[HideInInspector] _TreeInstanceScale("TreeInstanceScale", Vector) = (1,1,1,1)
		[HideInInspector] _SquashAmount("Squash", Float) = 1
	}

		SubShader{
		Tags{
		"Queue" = "AlphaTest"
		"IgnoreProjector" = "True"
		"RenderType" = "TreeTransparentCutout"
		"DisableBatching" = "True"
	}
		Cull Off
		ColorMask RGB

		Pass{
		Lighting On

		CGPROGRAM
#pragma vertex leaves
#pragma fragment frag
#pragma multi_compile_fog
#include "UnityBuiltin2xTreeLibrary.cginc"

		sampler2D _MainTex;
	fixed _Cutoff;

	fixed4 _TopColor;
	fixed4 _BottomColor;

	fixed4 _TopMidColor;
	fixed4 _BottomMidColor;

	fixed4 _TopBottomColor;
	fixed4 _GroundBottomColor;

	float _StartTopGradient;
	float _EndBottomGradient;


	/*
	*
	The gradients created for the Gradient 3 was adapted for this shader.
	*
	*/


	//returns the color of the pixel in a discrete section that is treated as a whole such as if
	//it started by 0 and ended by 1.
	fixed4 colorInThisSection_Gradient(float yCordinate, fixed4 bottomColor, fixed4 topColor,
		float startOfSection, float endOfSection) {
		//El equivalente a cuántos pixeles del todo avanza cada siguiente pixel de esta fracción del todo.
		float pixelAdvanceBy = 1 / (endOfSection - startOfSection);

		float positionInThisSection = (yCordinate - startOfSection) * pixelAdvanceBy;

		//if the pixel is in a position beyond the top color or under the botom color, it's
		//established to the top color, if it is the first case, or bottom color, in the second case.
		fixed4 pixelColor = yCordinate > 1 ? topColor : (yCordinate < 0 ? bottomColor
			: lerp(bottomColor, topColor, positionInThisSection));
		return pixelColor;
	}


	fixed4 frag(v2f input) : SV_Target
	{

		fixed4 colorOfThisPixel = tex2D(_MainTex, input.uv.xy);
		v2f inputCopy = input;

		float yCordinate = (float)inputCopy.uv.y;

		//Render Bottom gradient
		if (yCordinate < _EndBottomGradient) {
			//Por cuántos pixeles respecto al todo avanza cada siguiente pixel de esta fracción del todo.
			colorOfThisPixel = colorInThisSection_Gradient(yCordinate, _GroundBottomColor, _TopBottomColor,
				0, _EndBottomGradient);
		}else
		//Render central Gradient
		if (yCordinate >= _EndBottomGradient &&
			yCordinate <= _StartTopGradient) {
			//Por cuántos pixeles respecto al todo avanza cada siguiente pixel de esta fracción del todo.
			colorOfThisPixel = colorInThisSection_Gradient(yCordinate, _BottomMidColor, _TopMidColor,
				_EndBottomGradient, _StartTopGradient);
		}else
		//Render top gradient.
		if (yCordinate >= _StartTopGradient) {
			colorOfThisPixel = colorInThisSection_Gradient(yCordinate, _BottomColor, _TopColor,
				_EndBottomGradient, 1);
		}

		fixed4 c = tex2D(_MainTex, input.uv.xy);
		c.rgb *= input.color.rgb;
		c.rgb *= colorOfThisPixel.rgb;

		UNITY_APPLY_FOG(input.fogCoord, c);
		clip(c.a - _Cutoff);
		return c;
	}
		ENDCG
	}

		Pass{
		Name "ShadowCaster"
		Tags{ "LightMode" = "ShadowCaster" }

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_shadowcaster
#include "UnityCG.cginc"
#include "TerrainEngine.cginc"

		struct v2f {
		V2F_SHADOW_CASTER;
		float2 uv : TEXCOORD1;
	};

	struct appdata {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		fixed4 color : COLOR;
		float4 texcoord : TEXCOORD0;
	};
	v2f vert(appdata v)
	{
		v2f o;
		TerrainAnimateTree(v.vertex, v.color.w);
		TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
			o.uv = v.texcoord;
		return o;
	}

	sampler2D _MainTex;
	fixed _Cutoff;

	float4 frag(v2f i) : SV_Target
	{
		fixed4 texcol = tex2D(_MainTex, i.uv);
	clip(texcol.a - _Cutoff);
	SHADOW_CASTER_FRAGMENT(i)
	}
		ENDCG
	}
	}

		// This subshader is never actually used, but is only kept so
		// that the tree mesh still assumes that normals are needed
		// at build time (due to Lighting On in the pass). The subshader
		// above does not actually use normals, so they are stripped out.
		// We want to keep normals for backwards compatibility with Unity 4.2
		// and earlier.
		SubShader{
		Tags{
		"Queue" = "AlphaTest"
		"IgnoreProjector" = "True"
		"RenderType" = "TransparentCutout"
	}
		Cull Off
		ColorMask RGB
		Pass{
		Tags{ "LightMode" = "Vertex" }
		AlphaTest GEqual[_Cutoff]
		Lighting On
		Material{
		Diffuse[_Color]
		Ambient[_Color]
	}
		SetTexture[_MainTex]{ combine primary * texture DOUBLE, texture }
	}
	}

		Dependency "BillboardShader" = "Hidden/Nature/Tree Soft Occlusion Leaves Rendertex"
		Fallback Off
}
