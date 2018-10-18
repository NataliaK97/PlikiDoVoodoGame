//--------------
// un-tweaks
//--------------
   matrix ViewProj:ViewProjection; 
   matrix OrthoProj;
   matrix World:World;  

//--------------
// tweaks
//--------------
   float3 GridColor={0.5f,0.5f,0.5f};

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
     };
 
//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.Pos=mul(mul(IN.Pos,World),ViewProj);
	return OUT;
     }
   OutPut VS_Ortho(InPut IN) 
     {
 	OutPut OUT;
	OUT.Pos=mul(mul(IN.Pos,World),OrthoProj);
	return OUT;
     }
  
//--------------
// pixel shader
//--------------
    float4 PS(OutPut IN)  : COLOR
     {
	return float4(GridColor,1);
     }

//--------------
// techniques   
//--------------
   technique Grid
      {
 	pass p0
      {		
	vertexShader = compile vs_2_0 VS(); 
 	pixelShader  = compile ps_2_0 PS(); 	
      }
      }
   technique GridOrtho
      {
 	pass p0
      {		
	vertexShader = compile vs_2_0 VS_Ortho(); 
 	pixelShader  = compile ps_2_0 PS(); 	
      }
      }