Shader "Gradient/Gradient Unlit"{
	Properties{
		_TopColor("Top Color", Color) = (1, 1, 1, 1)
		_BottomColor("Bottom Color in Top", Color) = (1, 1, 1, 1)
		_StartTopGradient("Top Gradient's Start", Range(0, 1)) = 0.5 

		_TopMidColor("Top Color in Mid", Color) = (1, 1, 1, 1)
		_BottomMidColor("Bottom Color in Mid", Color) = (1, 1, 1, 1)

		_EndBottomGradient("End Of the Bottom Gradient", Range(0, 1)) = 0.4

		_TopBottomColor("Top Color from Below", Color) = (1, 1, 1, 1)
		_GroundBottomColor("Very Bottom Color", Color) = (1, 1, 1, 1)

		
	//	_MainTex("Main Texture", 2D) = "white" {}
	}

	SubShader{
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			

			struct appdata {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 texcoord: TEXCOORD0;
			};

			fixed4 _TopColor;
			fixed4 _BottomColor;

			fixed4 _TopMidColor;
			fixed4 _BottomMidColor;

			fixed4 _TopBottomColor;
			fixed4 _GroundBottomColor;

			float _StartTopGradient;
			float _EndBottomGradient;
			//sampler2D _MainTex;
			
			v2f vert(appdata IN) {
				v2f OUT;
				OUT.pos = mul(UNITY_MATRIX_MVP, IN.vertex);
				OUT.texcoord = IN.texcoord;
				return OUT;
			}

			//returns the color of the pixel in a discrete section that is treated as a whole such as if
			//it started by 0 and ended by 1.
			fixed4 colorInThisSection_Gradient(v2f IN, fixed4 bottomColor, fixed4 topColor,
				float startOfSection, float endOfSection) {
				//El equivalente a cuántos pixeles del todo avanza cada siguiente pixel de esta fracción del todo.
				float pixelAdvanceBy = 1 / (endOfSection - startOfSection);

				float positionInThisSection = (IN.texcoord.y - startOfSection) * pixelAdvanceBy;
				
				//if the pixel is in a position beyond the top color or under the botom color, it's
				//established to the top color, if it is the first case, or bottom color, in the second case.
				fixed4 pixelColor = IN.texcoord.y > 1 ? topColor : (IN.texcoord.y < 0 ? bottomColor
					: lerp(bottomColor, topColor, positionInThisSection));
				return pixelColor;


			}


			fixed4 frag(v2f IN) : COLOR {
				//fixed4 texColor = tex2D(_MainTex, IN.texcoord);
				fixed4 colorOfThisPixel = _TopColor;
				
				//Render Bottom gradient
				if ((float)IN.texcoord.y < _EndBottomGradient) {
					//Por cuántos pixeles respecto al todo avanza cada siguiente pixel de esta fracción del todo.
					colorOfThisPixel = colorInThisSection_Gradient(IN, _GroundBottomColor, _TopBottomColor,
						0, _EndBottomGradient);
				}

				//Render central Gradient
				if ((float)IN.texcoord.y >= _EndBottomGradient &&
					(float)IN.texcoord.y <= _StartTopGradient) {
					//Por cuántos pixeles respecto al todo avanza cada siguiente pixel de esta fracción del todo.
					colorOfThisPixel = colorInThisSection_Gradient(IN, _BottomMidColor, _TopMidColor,
						_EndBottomGradient, _StartTopGradient);
				}

				//Render top gradient.
				if ((float)IN.texcoord.y >= _StartTopGradient) {
					//Por cuántos pixeles respecto al todo avanza cada siguiente pixel de esta fracción del todo.
					colorOfThisPixel = colorInThisSection_Gradient(IN, _BottomColor, _TopColor,
						_StartTopGradient, 1);

					/*float pixelAdvanceBy = 1 / (1 - _StartTopGradient);

					float positionInWhatTheGradientCovers = (IN.texcoord.y - _StartTopGradient) * pixelAdvanceBy;
					colorOfThisPixel = lerp(_BottomColor, _TopColor, positionInWhatTheGradientCovers);*/
				}

				return colorOfThisPixel;
			}

			ENDCG
		}
	}
}