//====================================================
// Shadow Blur
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// tweaks
//--------------
   float2 BlurOffset={0.0009765625f,0.0009765625f};

//--------------
// Textures
//--------------
   texture DepthTexture <string Name = " ";>;
   sampler DepthSampler=sampler_state 
      {
	Texture=<DepthTexture>;
     	ADDRESSU=Clamp;
        ADDRESSV=Clamp;
        ADDRESSW=Clamp;
	MagFilter = Point;
	MinFilter = Point;
	MipFilter = Point;
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
	float4 Pos:POSITION; 
	float2 Tex1:TEXCOORD0;
	float2 Tex2:TEXCOORD1;
	float2 Tex3:TEXCOORD2;
	float2 Tex4:TEXCOORD3;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.Pos=IN.Pos; 
	OUT.Tex1=((float2(IN.Pos.x,-IN.Pos.y)+1.0f)*0.5f)+(BlurOffset*0.5f);
	OUT.Tex2=OUT.Tex1+float2(BlurOffset.x,0);
	OUT.Tex3=OUT.Tex1+float2(0,BlurOffset.y);
	OUT.Tex4=OUT.Tex1+BlurOffset;
	return OUT;
    }

//--------------
// pixel shader
//--------------
  float4 PS(OutPut IN) : COLOR
     {
	return float4(tex2D(DepthSampler,IN.Tex1).w,
		      tex2D(DepthSampler,IN.Tex2).w,
                      tex2D(DepthSampler,IN.Tex3).w,
                      tex2D(DepthSampler,IN.Tex4).w);
     }

//--------------
// techniques   
//--------------
    technique Evsm
      {
 	pass p1
      {	
 	VertexShader = compile vs_3_0 VS();
 	PixelShader  = compile ps_3_0 PS();
      }
      }