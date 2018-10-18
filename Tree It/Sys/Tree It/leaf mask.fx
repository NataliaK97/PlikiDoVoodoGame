
//--------------
// tweaks
//--------------
   float3 MaskColor={0,0,0};
   matrix Angle;
   float2 Scale={1,1};

//--------------
// Textures
//--------------
   texture RenderTexture <string Name = " ";>;
   sampler RenderSampler=sampler_state 
      {
	Texture=<RenderTexture>;
     	ADDRESSU=Clamp;
        ADDRESSV=Clamp;
        ADDRESSW=Clamp;
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
	OUT.Pos=float4(mul(IN.Pos.xy*Scale,Angle).xy,IN.Pos.zw); 
 	OUT.Tex=(float2(IN.Pos.x,-IN.Pos.y)+1.0)*0.5;
	return OUT;
    }

//--------------
// pixel shader
//--------------
  float4 PS(OutPut IN) : COLOR
     {
	float3 Color=tex2D(RenderSampler,IN.Tex);
	float3 Mask=0;
	if(Color.x>(MaskColor.x-0.222f) && Color.x<(MaskColor.x+0.222f)) Mask.x=1;
	if(Color.y>(MaskColor.y-0.222f) && Color.y<(MaskColor.y+0.222f)) Mask.y=1;
	if(Color.z>(MaskColor.z-0.222f) && Color.z<(MaskColor.z+0.222f)) Mask.z=1;
	clip(-(dot(Mask,0.333).x-0.85));
	return float4(Color,1);	
     }
  float4 PS2(OutPut IN) : COLOR
     {
	float3 Color=tex2D(RenderSampler,IN.Tex);
	float3 Mask=0;
	if(Color.x>(MaskColor.x-0.222f) && Color.x<(MaskColor.x+0.222f)) Mask.x=1;
	if(Color.y>(MaskColor.y-0.222f) && Color.y<(MaskColor.y+0.222f)) Mask.y=1;
	if(Color.z>(MaskColor.z-0.222f) && Color.z<(MaskColor.z+0.222f)) Mask.z=1;
	clip(-(dot(Mask,0.333).x-0.85));
	return float4(1,1,1,1);	
     }

//--------------
// techniques   
//--------------
    technique PSColor
      {
 	pass p1
      {	
 	VertexShader = compile vs_2_0 VS();
 	PixelShader  = compile ps_2_0 PS(); 
      }
      }
    technique PSAlpha
      {
 	pass p1
      {	
 	VertexShader = compile vs_2_0 VS();
 	PixelShader  = compile ps_2_0 PS2(); 
      }
      }