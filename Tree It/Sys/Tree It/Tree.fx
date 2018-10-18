
//--------------
// un-tweaks
//--------------
   matrix ViewProj:ViewProjection;
   matrix ViewInv:ViewInverse;  
   matrix OrthoProj;
   matrix World:World;  
   matrix ProjMat={0.5,0,0,0.5,0,-0.5,0,0.5,0,0,0.5,0.5,0,0,0,1};

//--------------
// tweaks
//--------------
   float3 LightDir={0.5f,-0.5f,-0.5f};
   float3 LightColor={1.0f,1.0f,1.0f};
   float3 Ambient={0.3f,0.5f,0.3f};
   matrix ShadowProj;
   float3 ShadowCamPos;
   float ShadowRadius;  
   float4 TreeWindTimer;
   float4 TreeWindSize={500,250,75,1};
   float3 TreeWindPower={2,0.25f,0.25f};
   float WireframeMode;
   float WindColorsMode;
   float NormalColorsMode;
   float SpecularColorsMode;
   float SubsurfaceColorsMode;
   float3 WindColors={1,1,1};
   float4 ShadowOffset={-0.00146484375,-0.00146484375,0.00048828125,0.00048828125};
   float3 DirX;
   float3 DirY;

//--------------
// Textures
//--------------
   texture BaseTX <string Name="";>;	
   sampler Base = sampler_state 
      {
 	texture = <BaseTX>;
  	MagFilter=anisotropic;
	MinFilter=anisotropic;
	MipFilter=anisotropic;
        MaxAnisotropy=8;
      };
   texture NormalTX <string Name="";>;	
   sampler Normal=sampler_state 
      {
 	texture=<NormalTX>;
      };
   texture SpecularTX <string Name="";>;	
   sampler Specular =sampler_state 
      {
 	texture=<SpecularTX>;
      };
   texture BlendBaseTX <string Name="";>;	
   sampler BlendBase = sampler_state 
      {
 	texture = <BlendBaseTX>;
  	MagFilter=anisotropic;
	MinFilter=anisotropic;
	MipFilter=anisotropic;
        MaxAnisotropy=8;
      };
   texture BlendNormalTX <string Name="";>;	
   sampler BlendNormal=sampler_state 
      {
 	texture=<BlendNormalTX>;
      };
   texture BlendSpecularTX <string Name="";>;	
   sampler BlendSpecular =sampler_state 
      {
 	texture=<BlendSpecularTX>;
      };
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
   struct In_Diffuse
     {
 	float4 Pos:POSITION;
 	float2 UV:TEXCOORD0;
 	float2 Tex1:TEXCOORD1;
 	float2 Tex2:TEXCOORD2;
	float3 Normal:NORMAL;
  	float3 Color:COLOR0;
     };
   struct Out_Diffuse
     {
	float4 Pos:POSITION; 
 	float2 Tex:TEXCOORD0;
	float3 WPos:TEXCOORD1;
 	float3 Normal:TEXCOORD2;
	float3 Depth:TEXCOORD3;
	float4 VertexColor:COLOR0;
     };
   struct In_Normal
     {
 	float4 Pos:POSITION;
 	float2 UV:TEXCOORD0;
 	float2 Tex1:TEXCOORD1;
 	float2 Tex2:TEXCOORD2;
	float3 Normal:NORMAL;
  	float3 Color:COLOR0;
     };
   struct Out_Normal
     {
	float4 Pos:POSITION;
 	float2 Tex:TEXCOORD0;
	float3 WPos:TEXCOORD1;
 	float3 Normal:TEXCOORD2;
	float3 Depth:TEXCOORD3;
 	float3 LightVec:TEXCOORD4;
	float3 ViewVec:TEXCOORD5;
	float4 VertexColor:COLOR0;
     };
   struct In_Shadow
     {
 	float4 Pos:POSITION;
  	float3 Color:COLOR0;
     };
   struct Out_Shadow
     {
 	float4 Pos:POSITION; 
     };
   struct In_ShadowDepth
     {
 	float4 Pos:POSITION;
  	float3 Color:COLOR0;
     };
   struct Out_ShadowDepth
     {
 	float4 Pos:POSITION;
	float3 Depth:TEXCOORD0;
     };
   struct In_Scatter
     {
 	float4 Pos:POSITION;
  	float3 Color:COLOR0;
     };
   struct Out_Scatter
     {
 	float4 Pos:POSITION; 
     };

//--------------
// vertex shader
//--------------
   Out_Diffuse VS_Diffuse(In_Diffuse IN) 
     {
 	Out_Diffuse OUT;
	float3 TreeGlobalWind=(mul(IN.Pos,World).xyz/TreeWindSize.x)+TreeWindTimer.x;
	TreeGlobalWind.x=1+abs(dot(cos(TreeGlobalWind),sin(TreeGlobalWind)));
   	float3 TreeWindForce=normalize(IN.Pos.xyz)+TreeWindTimer.y;
  	TreeWindForce.x=sin(TreeWindForce.x);
	TreeWindForce.y=0;
  	TreeWindForce.z=cos(TreeWindForce.z);
	float3 WindAnimate=(TreeWindForce*TreeWindPower.x)*(IN.Pos.y/TreeWindSize.y);
	float3 TreeWindVariant=normalize(float3(IN.Pos.x,IN.Pos.y/TreeWindSize.z,IN.Pos.z))+TreeWindTimer.z+(IN.Color.y*10);
	WindAnimate +=(cos(TreeWindVariant)*TreeWindPower.y)*pow(IN.Color.z,2);
	float4 NewPos=mul(float4(IN.Pos.xyz+WindAnimate*TreeGlobalWind.x,1),World);
	OUT.Pos=mul(NewPos,ViewProj); 
 	OUT.Tex=IN.UV;
	OUT.WPos=NewPos.xyz;
	OUT.Normal=mul(IN.Normal,World);
        OUT.Depth=OUT.WPos-ShadowCamPos;
	OUT.VertexColor=float4(IN.Color,IN.Tex2.y);
	OUT.VertexColor.x=abs(OUT.VertexColor.x*2-1);
	OUT.VertexColor.xyz *=WindColors;
	return OUT;
     }
   Out_Diffuse VS_DiffuseOrtho(In_Diffuse IN) 
     {
 	Out_Diffuse OUT;
	OUT.Pos=mul(mul(IN.Pos,World),OrthoProj); 
 	OUT.Tex=IN.UV;
	OUT.WPos=mul(IN.Pos,World);
	OUT.Normal=mul(IN.Normal,World);
        OUT.Depth=0;
	OUT.VertexColor=float4(IN.Color,IN.Tex2.y);
	OUT.VertexColor.x=abs(OUT.VertexColor.x*2-1);
	OUT.VertexColor.xyz *=WindColors;
	return OUT;
     }
   Out_Normal VS_Normal(In_Normal IN) 
     {
 	Out_Normal OUT;
	float3 TreeGlobalWind=(mul(IN.Pos,World).xyz/TreeWindSize.x)+TreeWindTimer.x;
	TreeGlobalWind.x=1+abs(dot(cos(TreeGlobalWind),sin(TreeGlobalWind)));
   	float3 TreeWindForce=normalize(IN.Pos.xyz)+TreeWindTimer.y;
  	TreeWindForce.x=sin(TreeWindForce.x);
	TreeWindForce.y=0;
  	TreeWindForce.z=cos(TreeWindForce.z);
	float3 WindAnimate=(TreeWindForce*TreeWindPower.x)*(IN.Pos.y/TreeWindSize.y);
	float3 TreeWindVariant=normalize(float3(IN.Pos.x,IN.Pos.y/TreeWindSize.z,IN.Pos.z))+TreeWindTimer.z+(IN.Color.y*10);
	WindAnimate +=(cos(TreeWindVariant)*TreeWindPower.y)*pow(IN.Color.z,2);
	float4 NewPos=mul(float4(IN.Pos.xyz+WindAnimate*TreeGlobalWind.x,1),World);
	OUT.Pos=mul(NewPos,ViewProj);
	OUT.Tex=IN.UV;
	OUT.WPos=NewPos.xyz;
	OUT.Normal=mul(IN.Normal,World);
        OUT.Depth=OUT.WPos-ShadowCamPos;
 	float3 Tangent=float3(IN.Tex1.xy,IN.Tex2.x);
	float3x3 TBN={Tangent,cross(IN.Normal,Tangent),IN.Normal};
	TBN=transpose(mul(TBN,World));
	OUT.LightVec=mul((-LightDir*32000)-NewPos,TBN);
 	OUT.ViewVec=mul(ViewInv[3].xyz-NewPos,TBN);
	OUT.VertexColor=float4(IN.Color,IN.Tex2.y);
	OUT.VertexColor.x=abs(OUT.VertexColor.x*2-1);
	OUT.VertexColor.xyz *=WindColors;
	return OUT;
     }
   Out_Normal VS_NormalOrtho(In_Normal IN) 
     {
 	Out_Normal OUT;
	OUT.Pos=mul(mul(IN.Pos,World),OrthoProj); 
 	OUT.Tex=IN.UV;
	OUT.WPos=mul(IN.Pos,World);
	OUT.Normal=mul(IN.Normal,World);
        OUT.Depth=0;
 	float3 Tangent=float3(IN.Tex1.xy,IN.Tex2.x);
	float3x3 TBN={Tangent,cross(IN.Normal,Tangent),IN.Normal};
	TBN=transpose(mul(TBN,World));
	OUT.LightVec=mul((-LightDir*32000)-IN.Pos.xyz,TBN);
 	OUT.ViewVec=mul(ViewInv[3].xyz-IN.Pos.xyz,TBN);
	OUT.VertexColor=float4(IN.Color,IN.Tex2.y);
	OUT.VertexColor.x=abs(OUT.VertexColor.x*2-1);
	OUT.VertexColor.xyz *=WindColors;
	return OUT;
     }
   Out_Shadow VS_Shadow(In_Shadow IN) 
     {
 	Out_Shadow OUT;
	OUT.Pos=mul(mul(IN.Pos,World),ShadowProj); 
	return OUT;
     }
   Out_ShadowDepth VS_ShadowDepth(In_ShadowDepth IN) 
     {
 	Out_ShadowDepth OUT;
	float3 TreeGlobalWind=(mul(IN.Pos,World).xyz/TreeWindSize.x)+TreeWindTimer.x;
	TreeGlobalWind.x=1+abs(dot(cos(TreeGlobalWind),sin(TreeGlobalWind)));
   	float3 TreeWindForce=normalize(IN.Pos.xyz)+TreeWindTimer.y;
  	TreeWindForce.x=sin(TreeWindForce.x);
	TreeWindForce.y=0;
  	TreeWindForce.z=cos(TreeWindForce.z);
	float3 WindAnimate=(TreeWindForce*TreeWindPower.x)*(IN.Pos.y/TreeWindSize.y);
	float3 TreeWindVariant=normalize(float3(IN.Pos.x,IN.Pos.y/TreeWindSize.z,IN.Pos.z))+TreeWindTimer.z+(IN.Color.y*10);
	WindAnimate +=(cos(TreeWindVariant)*TreeWindPower.y)*pow(IN.Color.z,2);
	float4 NewPos=mul(float4(IN.Pos.xyz+WindAnimate*TreeGlobalWind.x,1),World);
	OUT.Pos=mul(NewPos,ShadowProj);
        OUT.Depth=NewPos.xyz-ShadowCamPos;
	return OUT;
     }
   Out_Scatter VS_Scatter(In_Scatter IN) 
     {
 	Out_Scatter OUT;
	float3 TreeGlobalWind=(mul(IN.Pos,World).xyz/TreeWindSize.x)+TreeWindTimer.x;
	TreeGlobalWind.x=1+abs(dot(cos(TreeGlobalWind),sin(TreeGlobalWind)));
   	float3 TreeWindForce=normalize(IN.Pos.xyz)+TreeWindTimer.y;
  	TreeWindForce.x=sin(TreeWindForce.x);
	TreeWindForce.y=0;
  	TreeWindForce.z=cos(TreeWindForce.z);
	float3 WindAnimate=(TreeWindForce*TreeWindPower.x)*(IN.Pos.y/TreeWindSize.y);
	float3 TreeWindVariant=normalize(float3(IN.Pos.x,IN.Pos.y/TreeWindSize.z,IN.Pos.z))+TreeWindTimer.z+(IN.Color.y*10);
	WindAnimate +=(cos(TreeWindVariant)*TreeWindPower.y)*pow(IN.Color.z,2);
	float4 NewPos=mul(float4(IN.Pos.xyz+WindAnimate*TreeGlobalWind.x,1),World);
	OUT.Pos=mul(NewPos,ViewProj);
	return OUT;
     }
   Out_Diffuse VS_RTT(In_Diffuse IN) 
     {
 	Out_Diffuse OUT;
	float3 TreeGlobalWind=(mul(IN.Pos,World).xyz/TreeWindSize.x)+TreeWindTimer.x;
	TreeGlobalWind.x=1+abs(dot(cos(TreeGlobalWind),sin(TreeGlobalWind)));
   	float3 TreeWindForce=normalize(IN.Pos.xyz)+TreeWindTimer.y;
  	TreeWindForce.x=sin(TreeWindForce.x);
	TreeWindForce.y=0;
  	TreeWindForce.z=cos(TreeWindForce.z);
	float3 WindAnimate=(TreeWindForce*TreeWindPower.x)*(IN.Pos.y/TreeWindSize.y);
	float3 TreeWindVariant=normalize(float3(IN.Pos.x,IN.Pos.y/TreeWindSize.z,IN.Pos.z))+TreeWindTimer.z+(IN.Color.y*10);
	WindAnimate +=(cos(TreeWindVariant)*TreeWindPower.y)*pow(IN.Color.z,2);
	float4 NewPos=mul(float4(IN.Pos.xyz+WindAnimate*TreeGlobalWind.x,1),World);
	OUT.Pos=mul(NewPos,ViewProj); 
 	OUT.Tex=IN.UV;
	OUT.WPos=0;
	OUT.Normal=mul(IN.Normal,World);
        OUT.Depth=0;
	OUT.VertexColor=float4(IN.Color,IN.Tex2.y);
	OUT.VertexColor.x=abs(OUT.VertexColor.x*2-1);
	OUT.VertexColor.xyz *=WindColors;
	return OUT;
     }
   Out_Diffuse VS_RTTOrtho(In_Diffuse IN) 
     {
 	Out_Diffuse OUT;
	OUT.Pos=mul(mul(IN.Pos,World),OrthoProj); 
 	OUT.Tex=IN.UV;
	OUT.WPos=mul(IN.Pos,World);
	OUT.Normal=mul(IN.Normal,World);
        OUT.Depth=0;
	OUT.VertexColor=float4(IN.Color,IN.Tex2.y);
	OUT.VertexColor.x=abs(OUT.VertexColor.x*2-1);
	OUT.VertexColor.xyz *=WindColors;
	return OUT;
     }

//--------------
// pixel shader
//--------------
    float4 PS_Diffuse(Out_Diffuse IN)  : COLOR
     {
	float3 Texture=tex2D(Base,IN.Tex);
	float3 Worldnorm;
	Worldnorm.x=dot(IN.Normal,-normalize(IN.WPos-DirX));
	Worldnorm.y=dot(IN.Normal,-normalize(IN.WPos-DirY));
	Worldnorm.z=1-(abs(Worldnorm.x)*abs(Worldnorm.y));
	Worldnorm.xy=0.5f+Worldnorm.xy*0.5f;
	IN.VertexColor.xyz=lerp(IN.VertexColor.xyz,Worldnorm,NormalColorsMode);
	Worldnorm.x=dot(Texture.xyz,0.333);
	IN.VertexColor.xyz=lerp(IN.VertexColor.xyz,float3(Worldnorm.x*0.25f,Worldnorm.x*0.25f,0),SpecularColorsMode);
	IN.VertexColor.xyz=lerp(IN.VertexColor.xyz,float3(0,0,0),SubsurfaceColorsMode);
	return float4(lerp(Texture,IN.VertexColor.xyz,WindColorsMode),1);

     }
    float4 PS_Light(Out_Diffuse IN)  : COLOR
     {
	float3 Texture=tex2D(Base,IN.Tex);
	float Light=saturate(dot(-LightDir,IN.Normal));
	float3 Worldnorm;
	Worldnorm.x=dot(IN.Normal,-normalize(IN.WPos-DirX));
	Worldnorm.y=dot(IN.Normal,-normalize(IN.WPos-DirY));
	Worldnorm.z=1-(abs(Worldnorm.x)*abs(Worldnorm.y));
	Worldnorm.xy=0.5f+Worldnorm.xy*0.5f;
	IN.VertexColor.xyz=lerp(IN.VertexColor.xyz,Worldnorm,NormalColorsMode);
	Worldnorm.x=dot(Texture.xyz,0.333);
	IN.VertexColor.xyz=lerp(IN.VertexColor.xyz,float3(Worldnorm.x*0.25f,Worldnorm.x*0.25f,0),SpecularColorsMode);
	IN.VertexColor.xyz=lerp(IN.VertexColor.xyz,float3(0,0,0),SubsurfaceColorsMode);
	return float4(lerp(Texture,IN.VertexColor.xyz,WindColorsMode)*((saturate(Light)*LightColor)+Ambient),1);
     }
    float4 PS_DiffuseShadow(Out_Diffuse IN)  : COLOR
     {
	float3 Texture=tex2D(Base,IN.Tex);
	float Light=saturate(dot(-LightDir,IN.Normal));
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
	float3 Worldnorm;
	Worldnorm.x=dot(IN.Normal,-normalize(IN.WPos-DirX));
	Worldnorm.y=dot(IN.Normal,-normalize(IN.WPos-DirY));
	Worldnorm.z=1-(abs(Worldnorm.x)*abs(Worldnorm.y));
	Worldnorm.xy=0.5f+Worldnorm.xy*0.5f;
	IN.VertexColor.xyz=lerp(IN.VertexColor.xyz,Worldnorm,NormalColorsMode);
	Worldnorm.x=dot(Texture.xyz,0.333);
	IN.VertexColor.xyz=lerp(IN.VertexColor.xyz,float3(Worldnorm.x*0.25f,Worldnorm.x*0.25f,0),SpecularColorsMode);
	IN.VertexColor.xyz=lerp(IN.VertexColor.xyz,float3(0,0,0),SubsurfaceColorsMode);
	return float4(lerp(Texture,IN.VertexColor.xyz,WindColorsMode)*((saturate(Light)*ShadowMap*LightColor)+Ambient),1);
     }
    float4 PS_Normal(Out_Normal IN)  : COLOR
     {
	float3 Texture=tex2D(Base,IN.Tex);
	float3 Normalmap=tex2D(Normal,IN.Tex)*2-1;
	float3 Specularmap=tex2D(Specular,IN.Tex);
	float3 LightV=normalize(IN.LightVec);
	float Light=saturate(dot(Normalmap,LightV));
	float3 View=normalize(IN.ViewVec);
	Light=Light+pow(saturate(dot(reflect(-View,Normalmap),LightV)),Specularmap.x*32)*Specularmap.y*2;
	float3 Worldnorm;
	Worldnorm.x=dot(IN.Normal,-normalize(IN.WPos-DirX));
	Worldnorm.y=dot(IN.Normal,-normalize(IN.WPos-DirY));
	Worldnorm.z=1-(abs(Worldnorm.x)*abs(Worldnorm.y));
	Worldnorm.xy=0.5f+Worldnorm.xy*0.5f;
	IN.VertexColor.xyz=lerp(IN.VertexColor.xyz,Worldnorm,NormalColorsMode);
	Worldnorm.x=dot(Texture.xyz,0.333);
	IN.VertexColor.xyz=lerp(IN.VertexColor.xyz,float3(Worldnorm.x*0.25f,Worldnorm.x*0.25f,0),SpecularColorsMode);
	IN.VertexColor.xyz=lerp(IN.VertexColor.xyz,float3(0,0,0),SubsurfaceColorsMode);
	return float4(lerp(Texture,IN.VertexColor.xyz,WindColorsMode)*((saturate(Light)*LightColor)+Ambient),1);
     }
    float4 PS_NormalShadow(Out_Normal IN)  : COLOR
     {
	float3 Texture=tex2D(Base,IN.Tex);
	float3 Normalmap=tex2D(Normal,IN.Tex)*2-1;
	float3 Specularmap=tex2D(Specular,IN.Tex);
	float3 LightV=normalize(IN.LightVec);
	float Light=saturate(dot(Normalmap,LightV));
	float3 View=normalize(IN.ViewVec);
	Light=Light+pow(saturate(dot(reflect(-View,Normalmap),LightV)),Specularmap.x*32)*Specularmap.y*2;
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
	float3 Worldnorm;
	Worldnorm.x=dot(IN.Normal,-normalize(IN.WPos-DirX));
	Worldnorm.y=dot(IN.Normal,-normalize(IN.WPos-DirY));
	Worldnorm.z=1-(abs(Worldnorm.x)*abs(Worldnorm.y));
	Worldnorm.xy=0.5f+Worldnorm.xy*0.5f;
	IN.VertexColor.xyz=lerp(IN.VertexColor.xyz,Worldnorm,NormalColorsMode);
	Worldnorm.x=dot(Texture.xyz,0.333);
	IN.VertexColor.xyz=lerp(IN.VertexColor.xyz,float3(Worldnorm.x*0.25f,Worldnorm.x*0.25f,0),SpecularColorsMode);
	IN.VertexColor.xyz=lerp(IN.VertexColor.xyz,float3(0,0,0),SubsurfaceColorsMode);
	return float4(lerp(Texture,IN.VertexColor.xyz,WindColorsMode)*((saturate(Light)*ShadowMap*LightColor)+Ambient),1);
     }
    float4 PS_Shadow(Out_Shadow IN)  : COLOR
     {
	return float4(1,1,1,1);
     }
    float4 PS_ShadowDepth(Out_ShadowDepth IN)  : COLOR
     {
        return (dot(IN.Depth.xyz,LightDir)/ShadowRadius)+0.005f;
     }
    float4 PS_Scatter(Out_Scatter IN)  : COLOR
     {
	return float4(0,0,0,1);
     }
    float4 PS_RTTAlpha(Out_Diffuse IN)  : COLOR
     {
	float Alpha=1;
	Alpha=lerp(Alpha,0,SpecularColorsMode);
	Alpha=lerp(Alpha,0,SubsurfaceColorsMode);
	return float4(Alpha.xxx,1);
     }
    float4 PS_RTTAlpha2(Out_Diffuse IN)  : COLOR
     {
	return float4(1,1,1,1);
     }
    float4 PS_WireFrame()  : COLOR
     {
	clip(WireframeMode-0.1);
	return float4(1,1,1,1);
     }

//--------------
// techniques   
//--------------
   technique Diffuse
      {
 	pass p0
      {		
	vertexShader = compile vs_3_0 VS_Diffuse(); 
 	pixelShader  = compile ps_3_0 PS_Diffuse(); 	
      }
 	pass p1
      {
 	pixelShader  = compile ps_3_0 PS_WireFrame();
	CullMode=0;
	FillMode=wireframe;
      }
      }
   technique Light
      {
 	pass p0
      {		
	vertexShader = compile vs_3_0 VS_Diffuse(); 
 	pixelShader  = compile ps_3_0 PS_Light(); 	
      }
 	pass p1
      {
 	pixelShader  = compile ps_3_0 PS_WireFrame();
	CullMode=0;
	FillMode=wireframe;
      }
      }
   technique DiffuseShadow
      {
 	pass p0
      {		
	vertexShader = compile vs_3_0 VS_Diffuse(); 
 	pixelShader  = compile ps_3_0 PS_DiffuseShadow(); 	
      }
 	pass p1
      {
 	pixelShader  = compile ps_3_0 PS_WireFrame();
	CullMode=0;
	FillMode=wireframe;
      }
      }
   technique DiffuseOrtho
      {
 	pass p0
      {		
	vertexShader = compile vs_3_0 VS_DiffuseOrtho(); 
 	pixelShader  = compile ps_3_0 PS_Diffuse(); 	
      }
 	pass p1
      {
 	pixelShader  = compile ps_3_0 PS_WireFrame();
	CullMode=0;
	FillMode=wireframe;
      }
      }
   technique DiffuseOrthoLight
      {
 	pass p0
      {		
	vertexShader = compile vs_3_0 VS_DiffuseOrtho(); 
 	pixelShader  = compile ps_3_0 PS_Light(); 	
      }
 	pass p1
      {
 	pixelShader  = compile ps_3_0 PS_WireFrame();
	CullMode=0;
	FillMode=wireframe;
      }
      }
   technique Normal
      {
 	pass p0
      {		
	vertexShader = compile vs_3_0 VS_Normal(); 
 	pixelShader  = compile ps_3_0 PS_Normal(); 	
      }
 	pass p1
      {
 	pixelShader  = compile ps_3_0 PS_WireFrame();
	CullMode=0;
	FillMode=wireframe;
      }
      }
   technique NormalShadow
      {
 	pass p0
      {		
	vertexShader = compile vs_3_0 VS_Normal(); 
 	pixelShader  = compile ps_3_0 PS_NormalShadow(); 	
      }
 	pass p1
      {
 	pixelShader  = compile ps_3_0 PS_WireFrame();
	CullMode=0;
	FillMode=wireframe;
      }
      }
   technique NormalOrtho
      {
 	pass p0
      {		
	vertexShader = compile vs_3_0 VS_NormalOrtho(); 
 	pixelShader  = compile ps_3_0 PS_Normal(); 	
      }
 	pass p1
      {
 	pixelShader  = compile ps_3_0 PS_WireFrame();
	CullMode=0;
	FillMode=wireframe;
      }
      }
   technique Shadow
      {
 	pass p0
      {		
	vertexShader = compile vs_3_0 VS_Shadow(); 
 	pixelShader  = compile ps_3_0 PS_Shadow(); 	
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
   technique Scatter
      {
 	pass p0
      {		
	vertexShader = compile vs_3_0 VS_Scatter(); 
 	pixelShader  = compile ps_3_0 PS_Scatter(); 	
      }
      }
   technique RTTAlpha
      {
 	pass p0
      {		
	vertexShader = compile vs_3_0 VS_RTT(); 
 	pixelShader  = compile ps_3_0 PS_RTTAlpha(); 	
      }
      }
   technique RTTAlphaOrtho
      {
 	pass p0
      {		
	vertexShader = compile vs_3_0 VS_RTTOrtho(); 
 	pixelShader  = compile ps_3_0 PS_RTTAlpha(); 	
      }
      }
   technique RTTAlpha2
      {
 	pass p0
      {		
	vertexShader = compile vs_3_0 VS_RTT(); 
 	pixelShader  = compile ps_3_0 PS_RTTAlpha2(); 	
      }
      }
   technique RTTAlphaOrtho2
      {
 	pass p0
      {		
	vertexShader = compile vs_3_0 VS_RTTOrtho(); 
 	pixelShader  = compile ps_3_0 PS_RTTAlpha2(); 	
      }
      }