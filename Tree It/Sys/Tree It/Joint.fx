
//--------------
// un-tweaks
//--------------
   matrix WorldVP:WorldViewProjection; 
   matrix OrthoProj;
   matrix World:World;  

//--------------
// Textures
//--------------
   texture BaseTX <string Name="";>;	
   sampler Base = sampler_state 
      {
 	texture = <BaseTX>;
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
 	float2 Tex0:TEXCOORD0;
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
 	OUT.Tex=IN.Tex0;
	return OUT;
     }
   OutPut VS_Ortho(InPut IN) 
     {
 	OutPut OUT;
	OUT.Pos=mul(mul(IN.Pos,World),OrthoProj);
 	OUT.Tex=IN.Tex0;
	return OUT;
     }
  
//--------------
// pixel shader
//--------------
    float4 PS(OutPut IN)  : COLOR
     {
	return tex2D(Base,IN.Tex);
     }

//--------------
// techniques   
//--------------
   technique Joint
      {
 	pass p0
      {		
	vertexShader = compile vs_2_0 VS(); 
 	pixelShader  = compile ps_2_0 PS(); 	
      }
      }
   technique JointOrtho
      {
 	pass p0
      {		
	vertexShader = compile vs_2_0 VS_Ortho(); 
 	pixelShader  = compile ps_2_0 PS(); 	
      }
      }

