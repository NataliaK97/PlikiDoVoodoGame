
//--------------
// un-tweaks
//--------------
   matrix WorldVP:WorldViewProjection; 
   matrix VP:ViewProjection; 
   matrix World:World;  
   matrix ViewInv:ViewInverse; 
   float time:Time;
   matrix ProjMat={0.5,0,0,0.5,0,-0.5,0,0.5,0,0,0.5,0.5,0,0,0,1};

//--------------
// tweaks
//--------------
   float3 LightDir;
   float3 Ambient={0.3f,0.3f,0.3f};
   matrix ShadowProj;
   float3 ShadowCamPos;
   float ShadowRadius;  
   float4 ShadowOffset={-0.00146484375,-0.00146484375,0.00048828125,0.00048828125};

//--------------
// Textures
//--------------
   texture DepthMapTX <string Name="";>;
   sampler DepthMap=sampler_state 
      {
     	texture=<DepthMapTX>;
	AddressU=Clamp;
	AddressV=Clamp;
	AddressW=Clamp;
	MagFilter = Point;
	MinFilter = Point;
	MipFilter = Point;
      };

//--------------
// structs 
//--------------
   struct In_shadow
     {
 	float4 Pos:POSITION; 
	float3 Normal:NORMAL;
     };
   struct out_shadow
     {
	float4 Pos:POSITION; 
	float3 WPos:TEXCOORD0;
	float3 Normal:TEXCOORD1;
	float3 Depth:TEXCOORD2;
	float2 Shadowproj:TEXCOORD3;
     };
   struct In_ShadowDepth
     {
 	float4 Pos:POSITION;
     };
   struct Out_ShadowDepth
     {
 	float4 Pos:POSITION; 
	float3 Depth:TEXCOORD0;
     };

//--------------
// vertex shader
//--------------
   out_shadow VS_Shadow(In_shadow IN) 
     {
 	out_shadow OUT;
	OUT.Pos=mul(IN.Pos,WorldVP);
	OUT.WPos=mul(IN.Pos,World);
	OUT.Normal=normalize(mul(IN.Normal,World))*2;
        OUT.Depth=OUT.WPos-ShadowCamPos;
 	OUT.Shadowproj=mul(ProjMat,mul(OUT.WPos,ShadowProj)).xy;
	return OUT;
     }
   Out_ShadowDepth VS_ShadowDepth(In_ShadowDepth IN) 
     {
 	Out_ShadowDepth OUT;
	OUT.Pos=mul(mul(IN.Pos,World),ShadowProj); 
        OUT.Depth=mul(IN.Pos,World).xyz-ShadowCamPos;
	return OUT;
     }

//--------------
// pixel shader
//--------------
    float4 PS_Shadow(out_shadow IN)  : COLOR
     {
	float Depth=dot(IN.Depth.xyz,LightDir)/ShadowRadius;
    	float4 Proj=mul(float4(IN.WPos+IN.Normal,1),ShadowProj);
	float2 ShadowProj=(Proj.xy/Proj.w)*float2(0.5f,-0.5f)+0.5f;
	float4 Shadow1=step(Depth,tex2D(DepthMap,ShadowProj+ShadowOffset.xy));
	float4 Shadow2=step(Depth,tex2D(DepthMap,ShadowProj+ShadowOffset.zy));
	float4 Shadow3=step(Depth,tex2D(DepthMap,ShadowProj+ShadowOffset.xw));
	float4 Shadow4=step(Depth,tex2D(DepthMap,ShadowProj+ShadowOffset.zw));
	float2 PCF=frac(1024*ShadowProj-0.5);
	float3 PCFx=lerp(float3(Shadow1.z+Shadow3.x,Shadow1.x,Shadow3.z),float3(Shadow2.w+Shadow4.y,Shadow2.y,Shadow4.w),PCF.x);
	float2 PCFy=lerp(float2(Shadow1.y+Shadow2.x,PCFx.y),float2(Shadow3.w+Shadow4.z,PCFx.z),PCF.y);
  	float ShadowMap=(PCFx.x+PCFy.x+PCFy.y+Shadow1.w+Shadow2.z+Shadow3.y+Shadow4.x)*0.111f;
	return float4(Ambient,1-(ShadowMap+dot(Ambient,0.333f)));
     }
    float4 PS_Shadow2(out_shadow IN)  : COLOR
     {
        float shadowmap=tex2D(DepthMap,IN.Shadowproj).x;
	return float4(Ambient,shadowmap);
     }
    float4 PS_ShadowDepth(Out_ShadowDepth IN)  : COLOR
     {
        return (dot(IN.Depth.xyz,LightDir)/ShadowRadius)+0.005f;
     }

//--------------
// techniques   
//--------------
   technique Shadow
      {
 	pass p0
      {		
	vertexShader = compile vs_3_0 VS_Shadow(); 
 	pixelShader  = compile ps_3_0 PS_Shadow(); 
	AlphaBlendEnable=TRUE;	
	SrcBlend=SRCALPHA;
	DestBlend=INVSRCALPHA;
	zwriteenable=false;	
      }
      }
   technique Shadow2
      {
 	pass p0
      {		
	vertexShader = compile vs_3_0 VS_Shadow(); 
 	pixelShader  = compile ps_3_0 PS_Shadow2(); 
	AlphaBlendEnable=TRUE;	
	SrcBlend=SRCALPHA;
	DestBlend=INVSRCALPHA;
	zwriteenable=false;	
      }
      }
   technique ShadowDepth
      {
 	pass p0
      {		
	vertexShader = compile vs_3_0 VS_ShadowDepth(); 
 	pixelShader  = compile ps_3_0 PS_ShadowDepth(); 	
      }
      }