//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// un-tweaks
//--------------
   matrix WorldVP:WorldViewProjection; 
   matrix World:World;   
   matrix ViewInv:ViewInverse; 

//--------------
// tweaks
//--------------
   float3 SkyColor;
   float3 GroundColor;

//--------------
// structs 
//--------------
   struct Input
     {
 	float4 Pos:POSITION;
     };
   struct output
     {
 	float4 Pos:POSITION;
 	float Shade:TEXCOORD0; 
     };

//--------------
// vertex shader
//--------------
   output VS(Input IN) 
    {
 	output OUT;
	OUT.Pos=mul(IN.Pos,WorldVP); 
	OUT.Shade=IN.Pos.y+50; 
	return OUT;
    }

//--------------
// pixel shader
//--------------
    float4 PS(output IN)  : COLOR
     {	
	return float4(((1-(IN.Shade/100).xxx)*GroundColor)+((IN.Shade/100).xxx*SkyColor),1);
     }
    float4 PS_Scatter(output IN)  : COLOR
     {		
	return float4(0.111f+pow(IN.Shade/100,100).xxx*float3(0.8f,0.7f,0.5f),1);
     }

//--------------
// techniques   
//--------------
    technique Sky
      {
 	pass p1
      {		
 	vertexShader = compile vs_2_0 VS(); 
 	pixelShader  = compile ps_2_0 PS();	
      }
      }
    technique Scatter
      {
 	pass p1
      {		
 	vertexShader = compile vs_2_0 VS(); 
 	pixelShader  = compile ps_2_0 PS_Scatter();	
      }
      }