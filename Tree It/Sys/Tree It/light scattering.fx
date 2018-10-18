//====================================================
// Light Scattering
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// un-tweaks
//--------------
   matrix ViewProjection:ViewProjection;
   matrix View:View;
   matrix ProjMat={0.5,0,0,0.5,0,-0.5,0,0.5,0,0,0.5,0.5,0,0,0,1}; 

//--------------
// tweaks
//--------------
   float3 LightDir;
   int SampleNum=60;
   float Density=0.75f;
   float Decay=0.99f;

//--------------
// Textures
//--------------
   texture BlackTextureTX <string Name=" ";>;
   sampler BlackTexture=sampler_state 
      {
	Texture=<BlackTextureTX>;
   	ADDRESSU=CLAMP;
   	ADDRESSV=CLAMP;
   	ADDRESSW=CLAMP;
      };

//--------------
// structs 
//--------------
   struct InPut
     {
 	float4 Pos:POSITION;
     };
   struct OutPut
     {
	float4 OPos:POSITION; 
 	float2 Tex:TEXCOORD0;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.OPos=IN.Pos; 
 	OUT.Tex=(float2(IN.Pos.x,-IN.Pos.y)+1.0)*0.5;
	return OUT;
    }

//--------------
// pixel shader
//--------------
   float4 PS(OutPut IN) : COLOR
     {
	float4 ScreenToLight=mul(ProjMat,mul(-LightDir,ViewProjection));
	float2 DeltaTex=((ScreenToLight.xy/ScreenToLight.z)-IN.Tex)*sign(ScreenToLight.z);
	DeltaTex *=Density;
	float2 NewUv=IN.Tex;
	float3 Scatter=0;
	float FallOff=1.0;
	DeltaTex /=SampleNum;
	for (int i=0; i < SampleNum; i++)
	 {		
	  NewUv +=DeltaTex;
	  Scatter +=tex2D(BlackTexture,NewUv)*FallOff;
	  FallOff=FallOff*Decay;
	 }
	Scatter /=SampleNum;	
	return float4(Scatter*dot(mul(LightDir,View),float3(0.0f,0.0f,-1.f)),1);
     }

//--------------
// techniques   
//--------------
    technique Scatter
      {
 	pass p1
      {		
 	VertexShader = compile vs_3_0 VS(); 
 	PixelShader  = compile ps_3_0 PS();
	AlphaBlendEnable=true;
	SrcBlend=SRCALPHA;
 	DestBlend=one;
	zwriteenable=false;
	zenable=false;
      }
      }