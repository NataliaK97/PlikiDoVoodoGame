//--------------
// un-tweaks
//--------------
   matrix WorldVP:WorldViewProjection;

//--------------
// Textures
//--------------
   texture Stage0 <string Name="";>;
   sampler BaseSampler=sampler_state 
      {
 	texture=<Stage0>;
  	MagFilter=None;
	MinFilter=None;
	MipFilter=None;
      };
   texture Stage1 <string Name="";>;
   sampler Base2Sampler=sampler_state 
      {
 	texture=<Stage1>;
  	MagFilter=None;
	MinFilter=None;
	MipFilter=None;
      };

//--------------
// structs 
//--------------
   struct InPut
     {
 	float4 Pos:POSITION;
 	float2 Tex:TEXCOORD0;
     };
   struct OutPut
     {
	float4 Pos:POSITION; 
   	float2 Tex:TEXCOORD0; 
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.Pos=mul(IN.Pos,WorldVP);
 	OUT.Tex=IN.Tex;
	return OUT;
     }

//--------------
// pixel shader
//--------------
   float4 PS(OutPut IN) : COLOR
     {
   	float4 Base=tex2D(BaseSampler,IN.Tex);
 	clip(Base.w-0.2f);
	return float4(Base.xyz,1);
     }
   float4 PSA(OutPut IN) : COLOR
     {
   	float4 Base=tex2D(BaseSampler,IN.Tex);
 	clip((Base.w*255)-0.2f);
	return float4(Base.www,1);
     }
   float4 PSA2(OutPut IN) : COLOR
     {
   	float4 Base=tex2D(BaseSampler,IN.Tex);
 	clip(Base.w-0.2f);
	return float4(1,1,1,1);
     }
   float4 xPS(OutPut IN) : COLOR
     {
   	float4 Base=tex2D(BaseSampler,IN.Tex);
 	clip(Base.w-0.2f);
   	Base=tex2D(Base2Sampler,IN.Tex);
	return float4(Base.xyz,1);
     }
   float4 xPSA(OutPut IN) : COLOR
     {
   	float4 Base=tex2D(BaseSampler,IN.Tex);
 	clip((Base.w*255)-0.2f);
   	Base=tex2D(Base2Sampler,IN.Tex);
	return float4(Base.www,1);
     }
   float4 xPSA2(OutPut IN) : COLOR
     {
   	float4 Base=tex2D(BaseSampler,IN.Tex);
 	clip(Base.w-0.2f);
   	Base=tex2D(Base2Sampler,IN.Tex);
	return float4(1,1,1,1);
     }

//--------------
// techniques   
//--------------
   technique Texture
      {
 	pass p1
      {		
 	vertexShader = compile vs_3_0 VS();
 	pixelShader  = compile ps_3_0 PS();
      }
      }
   technique Alpha
      {
 	pass p1
      {		
 	vertexShader = compile vs_3_0 VS();
 	pixelShader  = compile ps_3_0 PSA();
      }
      }
   technique Alpha2
      {
 	pass p1
      {		
 	vertexShader = compile vs_3_0 VS();
 	pixelShader  = compile ps_3_0 PSA2();
      }
      }
   technique xTexture
      {
 	pass p1
      {		
 	vertexShader = compile vs_3_0 VS();
 	pixelShader  = compile ps_3_0 xPS();
      }
      }
   technique xAlpha
      {
 	pass p1
      {		
 	vertexShader = compile vs_3_0 VS();
 	pixelShader  = compile ps_3_0 xPSA();
      }
      }
   technique xAlpha2
      {
 	pass p1
      {		
 	vertexShader = compile vs_3_0 VS();
 	pixelShader  = compile ps_3_0 xPSA2();
      }
      }