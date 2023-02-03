Shader "WaterShader"
{
    Properties
    {
        _Depth("_Depth", Float) = 0
        _Strength("_Strength", Float) = 0
        _DeepWaterColor("_DeepWaterColor", Color) = (0, 0.6241608, 0.8301887, 0.945098)
        _ShallowWaterColor("_ShallowWaterColor", Color) = (0.01214843, 0.6947601, 0.8584906, 0.7450981)
        [NoScaleOffset]_MainNormal("_MainNormal", 2D) = "white" {}
        [NoScaleOffset]_SecondNormal("_SecondNormal", 2D) = "white" {}
        _NormalStrength("_NormalStrength", Range(0, 1)) = 0
        _Smoothness("_Smoothness", Range(0, 1)) = 0.5
        _Displacement("_Displacement", Float) = 0
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue" = "Transparent"
            "ShaderGraphShader" = "true"
            "ShaderGraphTargetId" = "UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>

        // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float3 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float2 interp6 : INTERP6;
             float3 interp7 : INTERP7;
             float4 interp8 : INTERP8;
             float4 interp9 : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings(Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz = input.positionWS;
            output.interp1.xyz = input.normalWS;
            output.interp2.xyzw = input.tangentWS;
            output.interp3.xyzw = input.texCoord0;
            output.interp4.xyz = input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp6.xy = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp7.xyz = input.sh;
            #endif
            output.interp8.xyzw = input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp9.xyzw = input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings(PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp5.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp6.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp7.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp8.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp9.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Depth;
        float _Strength;
        float4 _DeepWaterColor;
        float4 _ShallowWaterColor;
        float4 _MainNormal_TexelSize;
        float4 _SecondNormal_TexelSize;
        float _NormalStrength;
        float _Smoothness;
        float _Displacement;
        CBUFFER_END

            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainNormal);
            SAMPLER(sampler_MainNormal);
            TEXTURE2D(_SecondNormal);
            SAMPLER(sampler_SecondNormal);

            // Graph Includes
            // GraphIncludes: <None>

            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif

            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif

            // Graph Functions

            void Unity_Divide_float(float A, float B, out float Out)
            {
                Out = A / B;
            }

            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
            {
                Out = UV * Tiling + Offset;
            }


            float2 Unity_GradientNoise_Dir_float(float2 p)
            {
                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                p = p % 289;
                // need full precision, otherwise half overflows when p > 1
                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                x = (34 * x + 1) * x % 289;
                x = frac(x / 41) * 2 - 1;
                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
            }

            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
            {
                float2 p = UV * Scale;
                float2 ip = floor(p);
                float2 fp = frac(p);
                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
            }

            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }

            void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
            {
                Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }

            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }

            void Unity_Subtract_float(float A, float B, out float Out)
            {
                Out = A - B;
            }

            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
            {
                Out = clamp(In, Min, Max);
            }

            void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
            {
                Out = lerp(A, B, T);
            }

            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A + B;
            }

            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }

            void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
            {
                Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                float _Split_5a46fb254a6548d9a32e712a81235ca4_R_1 = IN.ObjectSpacePosition[0];
                float _Split_5a46fb254a6548d9a32e712a81235ca4_G_2 = IN.ObjectSpacePosition[1];
                float _Split_5a46fb254a6548d9a32e712a81235ca4_B_3 = IN.ObjectSpacePosition[2];
                float _Split_5a46fb254a6548d9a32e712a81235ca4_A_4 = 0;
                float _Property_2aee0f2c381447299717226883b9dd5e_Out_0 = _Displacement;
                float _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2;
                Unity_Divide_float(IN.TimeParameters.x, 50, _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2);
                float2 _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3;
                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_0347d994cff649cca9eb90763a4ce74a_Out_2.xx), _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3);
                float _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3, 20, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2);
                float _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2;
                Unity_Multiply_float_float(_Property_2aee0f2c381447299717226883b9dd5e_Out_0, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2);
                float4 _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4;
                float3 _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                float2 _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6;
                Unity_Combine_float(_Split_5a46fb254a6548d9a32e712a81235ca4_R_1, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2, _Split_5a46fb254a6548d9a32e712a81235ca4_B_3, 0, _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4, _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5, _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6);
                description.Position = _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalTS;
                float3 Emission;
                float Metallic;
                float Smoothness;
                float Occlusion;
                float Alpha;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float4 _Property_f669795152fd4d83bfe0251a331b5e7e_Out_0 = _ShallowWaterColor;
                float4 _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0 = _DeepWaterColor;
                float _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1;
                Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1);
                float _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2;
                Unity_Multiply_float_float(_SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1, _ProjectionParams.z, _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2);
                float4 _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0 = IN.ScreenPosition;
                float _Split_fabee40938d249f58c6df289b29487e6_R_1 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[0];
                float _Split_fabee40938d249f58c6df289b29487e6_G_2 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[1];
                float _Split_fabee40938d249f58c6df289b29487e6_B_3 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[2];
                float _Split_fabee40938d249f58c6df289b29487e6_A_4 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[3];
                float _Property_b835ed47772e498ca3bfd0304467564a_Out_0 = _Depth;
                float _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2;
                Unity_Add_float(_Split_fabee40938d249f58c6df289b29487e6_A_4, _Property_b835ed47772e498ca3bfd0304467564a_Out_0, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2);
                float _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2;
                Unity_Subtract_float(_Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2, _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2);
                float _Property_d4102fc229a94768ae4a93daed7fd849_Out_0 = _Strength;
                float _Multiply_c032a0c444d84300a760598cbea78a62_Out_2;
                Unity_Multiply_float_float(_Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2, _Property_d4102fc229a94768ae4a93daed7fd849_Out_0, _Multiply_c032a0c444d84300a760598cbea78a62_Out_2);
                float _Clamp_e8c5093ba9604977add70348fe2134be_Out_3;
                Unity_Clamp_float(_Multiply_c032a0c444d84300a760598cbea78a62_Out_2, 0, 1, _Clamp_e8c5093ba9604977add70348fe2134be_Out_3);
                float4 _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3;
                Unity_Lerp_float4(_Property_f669795152fd4d83bfe0251a331b5e7e_Out_0, _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0, (_Clamp_e8c5093ba9604977add70348fe2134be_Out_3.xxxx), _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3);
                UnityTexture2D _Property_53020a2b9cbe4b6a83ad0a9fee0558e8_Out_0 = UnityBuildTexture2DStructNoScale(_MainNormal);
                float _Divide_ee7923a88d6f4b1a9e8dbe5bfbb29685_Out_2;
                Unity_Divide_float(IN.TimeParameters.x, 50, _Divide_ee7923a88d6f4b1a9e8dbe5bfbb29685_Out_2);
                float2 _TilingAndOffset_a535553689a34d399e1a65691ca9aa39_Out_3;
                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (10, 10), (_Divide_ee7923a88d6f4b1a9e8dbe5bfbb29685_Out_2.xx), _TilingAndOffset_a535553689a34d399e1a65691ca9aa39_Out_3);
                float4 _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0 = SAMPLE_TEXTURE2D(_Property_53020a2b9cbe4b6a83ad0a9fee0558e8_Out_0.tex, _Property_53020a2b9cbe4b6a83ad0a9fee0558e8_Out_0.samplerstate, _Property_53020a2b9cbe4b6a83ad0a9fee0558e8_Out_0.GetTransformedUV(_TilingAndOffset_a535553689a34d399e1a65691ca9aa39_Out_3));
                _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0);
                float _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_R_4 = _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.r;
                float _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_G_5 = _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.g;
                float _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_B_6 = _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.b;
                float _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_A_7 = _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.a;
                UnityTexture2D _Property_2c235836e5664098bdb6fb2809be4539_Out_0 = UnityBuildTexture2DStructNoScale(_SecondNormal);
                float _Divide_5d7c40eba84948c2b427b4bc6c71a9b0_Out_2;
                Unity_Divide_float(IN.TimeParameters.x, -10, _Divide_5d7c40eba84948c2b427b4bc6c71a9b0_Out_2);
                float2 _TilingAndOffset_cca530b5dccb4ec0a00dd9aff0e156e2_Out_3;
                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (10, 10), (_Divide_5d7c40eba84948c2b427b4bc6c71a9b0_Out_2.xx), _TilingAndOffset_cca530b5dccb4ec0a00dd9aff0e156e2_Out_3);
                float4 _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0 = SAMPLE_TEXTURE2D(_Property_2c235836e5664098bdb6fb2809be4539_Out_0.tex, _Property_2c235836e5664098bdb6fb2809be4539_Out_0.samplerstate, _Property_2c235836e5664098bdb6fb2809be4539_Out_0.GetTransformedUV(_TilingAndOffset_cca530b5dccb4ec0a00dd9aff0e156e2_Out_3));
                _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0);
                float _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_R_4 = _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.r;
                float _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_G_5 = _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.g;
                float _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_B_6 = _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.b;
                float _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_A_7 = _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.a;
                float4 _Add_9b2536bd6bce45d4916943d980d7fc3f_Out_2;
                Unity_Add_float4(_SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0, _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0, _Add_9b2536bd6bce45d4916943d980d7fc3f_Out_2);
                float _Property_a5190d1ea56040d29725d71fd10fc2ff_Out_0 = _NormalStrength;
                float _Lerp_1b3da68c18ce4ab6b9781c9955aaa9ee_Out_3;
                Unity_Lerp_float(0, _Property_a5190d1ea56040d29725d71fd10fc2ff_Out_0, _Clamp_e8c5093ba9604977add70348fe2134be_Out_3, _Lerp_1b3da68c18ce4ab6b9781c9955aaa9ee_Out_3);
                float3 _NormalStrength_36f00e1d555c491bb0ed1d778d4eef29_Out_2;
                Unity_NormalStrength_float((_Add_9b2536bd6bce45d4916943d980d7fc3f_Out_2.xyz), _Lerp_1b3da68c18ce4ab6b9781c9955aaa9ee_Out_3, _NormalStrength_36f00e1d555c491bb0ed1d778d4eef29_Out_2);
                float _Property_15666cb92fb2412da792f74efe747b9b_Out_0 = _Smoothness;
                float _Split_2b30a0ad4e8848e081a23cc709e367a2_R_1 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[0];
                float _Split_2b30a0ad4e8848e081a23cc709e367a2_G_2 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[1];
                float _Split_2b30a0ad4e8848e081a23cc709e367a2_B_3 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[2];
                float _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[3];
                surface.BaseColor = (_Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3.xyz);
                surface.NormalTS = _NormalStrength_36f00e1d555c491bb0ed1d778d4eef29_Out_2;
                surface.Emission = float3(0, 0, 0);
                surface.Metallic = 0;
                surface.Smoothness = _Property_15666cb92fb2412da792f74efe747b9b_Out_0;
                surface.Occlusion = 1;
                surface.Alpha = _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;
                output.uv0 = input.uv0;
                output.TimeParameters = _TimeParameters.xyz;

                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

            #endif





                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                output.WorldSpacePosition = input.positionWS;
                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                output.uv0 = input.texCoord0;
                output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                    return output;
            }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif

            ENDHLSL
            }
            Pass
            {
                Name "GBuffer"
                Tags
                {
                    "LightMode" = "UniversalGBuffer"
                }

                // Render State
                Cull Back
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off

                // Debug
                // <None>

                // --------------------------------------------------
                // Pass

                HLSLPROGRAM

                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma instancing_options renderinglayer
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag

                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>

                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                #pragma multi_compile_fragment _ _SHADOWS_SOFT
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
                #pragma multi_compile_fragment _ _LIGHT_LAYERS
                #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
                #pragma multi_compile_fragment _ DEBUG_DISPLAY
                // GraphKeywords: <None>

                // Defines

                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define VARYINGS_NEED_SHADOW_COORD
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_GBUFFER
                #define _FOG_FRAGMENT 1
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                // custom interpolator pre-include
                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                // --------------------------------------------------
                // Structs and Packing

                // custom interpolators pre packing
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float4 texCoord0;
                     float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh;
                    #endif
                     float4 fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                     float4 shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 TangentSpaceNormal;
                     float3 WorldSpacePosition;
                     float4 ScreenPosition;
                     float4 uv0;
                     float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float4 uv0;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                     float4 interp2 : INTERP2;
                     float4 interp3 : INTERP3;
                     float3 interp4 : INTERP4;
                     float2 interp5 : INTERP5;
                     float2 interp6 : INTERP6;
                     float3 interp7 : INTERP7;
                     float4 interp8 : INTERP8;
                     float4 interp9 : INTERP9;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };

                PackedVaryings PackVaryings(Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz = input.positionWS;
                    output.interp1.xyz = input.normalWS;
                    output.interp2.xyzw = input.tangentWS;
                    output.interp3.xyzw = input.texCoord0;
                    output.interp4.xyz = input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp5.xy = input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.interp6.xy = input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp7.xyz = input.sh;
                    #endif
                    output.interp8.xyzw = input.fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.interp9.xyzw = input.shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }

                Varyings UnpackVaryings(PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    output.viewDirectionWS = input.interp4.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.interp5.xy;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.interp6.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp7.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp8.xyzw;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.interp9.xyzw;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }


                // --------------------------------------------------
                // Graph

                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float _Depth;
                float _Strength;
                float4 _DeepWaterColor;
                float4 _ShallowWaterColor;
                float4 _MainNormal_TexelSize;
                float4 _SecondNormal_TexelSize;
                float _NormalStrength;
                float _Smoothness;
                float _Displacement;
                CBUFFER_END

                    // Object and Global properties
                    SAMPLER(SamplerState_Linear_Repeat);
                    TEXTURE2D(_MainNormal);
                    SAMPLER(sampler_MainNormal);
                    TEXTURE2D(_SecondNormal);
                    SAMPLER(sampler_SecondNormal);

                    // Graph Includes
                    // GraphIncludes: <None>

                    // -- Property used by ScenePickingPass
                    #ifdef SCENEPICKINGPASS
                    float4 _SelectionID;
                    #endif

                    // -- Properties used by SceneSelectionPass
                    #ifdef SCENESELECTIONPASS
                    int _ObjectId;
                    int _PassValue;
                    #endif

                    // Graph Functions

                    void Unity_Divide_float(float A, float B, out float Out)
                    {
                        Out = A / B;
                    }

                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                    {
                        Out = UV * Tiling + Offset;
                    }


                    float2 Unity_GradientNoise_Dir_float(float2 p)
                    {
                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                        p = p % 289;
                        // need full precision, otherwise half overflows when p > 1
                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                        x = (34 * x + 1) * x % 289;
                        x = frac(x / 41) * 2 - 1;
                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                    }

                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                    {
                        float2 p = UV * Scale;
                        float2 ip = floor(p);
                        float2 fp = frac(p);
                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                    }

                    void Unity_Multiply_float_float(float A, float B, out float Out)
                    {
                        Out = A * B;
                    }

                    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                    {
                        RGBA = float4(R, G, B, A);
                        RGB = float3(R, G, B);
                        RG = float2(R, G);
                    }

                    void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                    {
                        Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                    }

                    void Unity_Add_float(float A, float B, out float Out)
                    {
                        Out = A + B;
                    }

                    void Unity_Subtract_float(float A, float B, out float Out)
                    {
                        Out = A - B;
                    }

                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                    {
                        Out = clamp(In, Min, Max);
                    }

                    void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                    {
                        Out = lerp(A, B, T);
                    }

                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                    {
                        Out = A + B;
                    }

                    void Unity_Lerp_float(float A, float B, float T, out float Out)
                    {
                        Out = lerp(A, B, T);
                    }

                    void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
                    {
                        Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
                    }

                    // Custom interpolators pre vertex
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                    // Graph Vertex
                    struct VertexDescription
                    {
                        float3 Position;
                        float3 Normal;
                        float3 Tangent;
                    };

                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                    {
                        VertexDescription description = (VertexDescription)0;
                        float _Split_5a46fb254a6548d9a32e712a81235ca4_R_1 = IN.ObjectSpacePosition[0];
                        float _Split_5a46fb254a6548d9a32e712a81235ca4_G_2 = IN.ObjectSpacePosition[1];
                        float _Split_5a46fb254a6548d9a32e712a81235ca4_B_3 = IN.ObjectSpacePosition[2];
                        float _Split_5a46fb254a6548d9a32e712a81235ca4_A_4 = 0;
                        float _Property_2aee0f2c381447299717226883b9dd5e_Out_0 = _Displacement;
                        float _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2;
                        Unity_Divide_float(IN.TimeParameters.x, 50, _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2);
                        float2 _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3;
                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_0347d994cff649cca9eb90763a4ce74a_Out_2.xx), _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3);
                        float _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2;
                        Unity_GradientNoise_float(_TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3, 20, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2);
                        float _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2;
                        Unity_Multiply_float_float(_Property_2aee0f2c381447299717226883b9dd5e_Out_0, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2);
                        float4 _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4;
                        float3 _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                        float2 _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6;
                        Unity_Combine_float(_Split_5a46fb254a6548d9a32e712a81235ca4_R_1, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2, _Split_5a46fb254a6548d9a32e712a81235ca4_B_3, 0, _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4, _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5, _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6);
                        description.Position = _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                        description.Normal = IN.ObjectSpaceNormal;
                        description.Tangent = IN.ObjectSpaceTangent;
                        return description;
                    }

                    // Custom interpolators, pre surface
                    #ifdef FEATURES_GRAPH_VERTEX
                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                    {
                    return output;
                    }
                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                    #endif

                    // Graph Pixel
                    struct SurfaceDescription
                    {
                        float3 BaseColor;
                        float3 NormalTS;
                        float3 Emission;
                        float Metallic;
                        float Smoothness;
                        float Occlusion;
                        float Alpha;
                    };

                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        float4 _Property_f669795152fd4d83bfe0251a331b5e7e_Out_0 = _ShallowWaterColor;
                        float4 _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0 = _DeepWaterColor;
                        float _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1;
                        Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1);
                        float _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2;
                        Unity_Multiply_float_float(_SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1, _ProjectionParams.z, _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2);
                        float4 _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0 = IN.ScreenPosition;
                        float _Split_fabee40938d249f58c6df289b29487e6_R_1 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[0];
                        float _Split_fabee40938d249f58c6df289b29487e6_G_2 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[1];
                        float _Split_fabee40938d249f58c6df289b29487e6_B_3 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[2];
                        float _Split_fabee40938d249f58c6df289b29487e6_A_4 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[3];
                        float _Property_b835ed47772e498ca3bfd0304467564a_Out_0 = _Depth;
                        float _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2;
                        Unity_Add_float(_Split_fabee40938d249f58c6df289b29487e6_A_4, _Property_b835ed47772e498ca3bfd0304467564a_Out_0, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2);
                        float _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2;
                        Unity_Subtract_float(_Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2, _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2);
                        float _Property_d4102fc229a94768ae4a93daed7fd849_Out_0 = _Strength;
                        float _Multiply_c032a0c444d84300a760598cbea78a62_Out_2;
                        Unity_Multiply_float_float(_Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2, _Property_d4102fc229a94768ae4a93daed7fd849_Out_0, _Multiply_c032a0c444d84300a760598cbea78a62_Out_2);
                        float _Clamp_e8c5093ba9604977add70348fe2134be_Out_3;
                        Unity_Clamp_float(_Multiply_c032a0c444d84300a760598cbea78a62_Out_2, 0, 1, _Clamp_e8c5093ba9604977add70348fe2134be_Out_3);
                        float4 _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3;
                        Unity_Lerp_float4(_Property_f669795152fd4d83bfe0251a331b5e7e_Out_0, _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0, (_Clamp_e8c5093ba9604977add70348fe2134be_Out_3.xxxx), _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3);
                        UnityTexture2D _Property_53020a2b9cbe4b6a83ad0a9fee0558e8_Out_0 = UnityBuildTexture2DStructNoScale(_MainNormal);
                        float _Divide_ee7923a88d6f4b1a9e8dbe5bfbb29685_Out_2;
                        Unity_Divide_float(IN.TimeParameters.x, 50, _Divide_ee7923a88d6f4b1a9e8dbe5bfbb29685_Out_2);
                        float2 _TilingAndOffset_a535553689a34d399e1a65691ca9aa39_Out_3;
                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (10, 10), (_Divide_ee7923a88d6f4b1a9e8dbe5bfbb29685_Out_2.xx), _TilingAndOffset_a535553689a34d399e1a65691ca9aa39_Out_3);
                        float4 _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0 = SAMPLE_TEXTURE2D(_Property_53020a2b9cbe4b6a83ad0a9fee0558e8_Out_0.tex, _Property_53020a2b9cbe4b6a83ad0a9fee0558e8_Out_0.samplerstate, _Property_53020a2b9cbe4b6a83ad0a9fee0558e8_Out_0.GetTransformedUV(_TilingAndOffset_a535553689a34d399e1a65691ca9aa39_Out_3));
                        _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0);
                        float _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_R_4 = _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.r;
                        float _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_G_5 = _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.g;
                        float _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_B_6 = _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.b;
                        float _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_A_7 = _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.a;
                        UnityTexture2D _Property_2c235836e5664098bdb6fb2809be4539_Out_0 = UnityBuildTexture2DStructNoScale(_SecondNormal);
                        float _Divide_5d7c40eba84948c2b427b4bc6c71a9b0_Out_2;
                        Unity_Divide_float(IN.TimeParameters.x, -10, _Divide_5d7c40eba84948c2b427b4bc6c71a9b0_Out_2);
                        float2 _TilingAndOffset_cca530b5dccb4ec0a00dd9aff0e156e2_Out_3;
                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (10, 10), (_Divide_5d7c40eba84948c2b427b4bc6c71a9b0_Out_2.xx), _TilingAndOffset_cca530b5dccb4ec0a00dd9aff0e156e2_Out_3);
                        float4 _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0 = SAMPLE_TEXTURE2D(_Property_2c235836e5664098bdb6fb2809be4539_Out_0.tex, _Property_2c235836e5664098bdb6fb2809be4539_Out_0.samplerstate, _Property_2c235836e5664098bdb6fb2809be4539_Out_0.GetTransformedUV(_TilingAndOffset_cca530b5dccb4ec0a00dd9aff0e156e2_Out_3));
                        _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0);
                        float _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_R_4 = _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.r;
                        float _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_G_5 = _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.g;
                        float _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_B_6 = _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.b;
                        float _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_A_7 = _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.a;
                        float4 _Add_9b2536bd6bce45d4916943d980d7fc3f_Out_2;
                        Unity_Add_float4(_SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0, _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0, _Add_9b2536bd6bce45d4916943d980d7fc3f_Out_2);
                        float _Property_a5190d1ea56040d29725d71fd10fc2ff_Out_0 = _NormalStrength;
                        float _Lerp_1b3da68c18ce4ab6b9781c9955aaa9ee_Out_3;
                        Unity_Lerp_float(0, _Property_a5190d1ea56040d29725d71fd10fc2ff_Out_0, _Clamp_e8c5093ba9604977add70348fe2134be_Out_3, _Lerp_1b3da68c18ce4ab6b9781c9955aaa9ee_Out_3);
                        float3 _NormalStrength_36f00e1d555c491bb0ed1d778d4eef29_Out_2;
                        Unity_NormalStrength_float((_Add_9b2536bd6bce45d4916943d980d7fc3f_Out_2.xyz), _Lerp_1b3da68c18ce4ab6b9781c9955aaa9ee_Out_3, _NormalStrength_36f00e1d555c491bb0ed1d778d4eef29_Out_2);
                        float _Property_15666cb92fb2412da792f74efe747b9b_Out_0 = _Smoothness;
                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_R_1 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[0];
                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_G_2 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[1];
                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_B_3 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[2];
                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[3];
                        surface.BaseColor = (_Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3.xyz);
                        surface.NormalTS = _NormalStrength_36f00e1d555c491bb0ed1d778d4eef29_Out_2;
                        surface.Emission = float3(0, 0, 0);
                        surface.Metallic = 0;
                        surface.Smoothness = _Property_15666cb92fb2412da792f74efe747b9b_Out_0;
                        surface.Occlusion = 1;
                        surface.Alpha = _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4;
                        return surface;
                    }

                    // --------------------------------------------------
                    // Build Graph Inputs
                    #ifdef HAVE_VFX_MODIFICATION
                    #define VFX_SRP_ATTRIBUTES Attributes
                    #define VFX_SRP_VARYINGS Varyings
                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                    #endif
                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                    {
                        VertexDescriptionInputs output;
                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                        output.ObjectSpaceNormal = input.normalOS;
                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                        output.ObjectSpacePosition = input.positionOS;
                        output.uv0 = input.uv0;
                        output.TimeParameters = _TimeParameters.xyz;

                        return output;
                    }
                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                    {
                        SurfaceDescriptionInputs output;
                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                    #ifdef HAVE_VFX_MODIFICATION
                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                    #endif





                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                        output.WorldSpacePosition = input.positionWS;
                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                        output.uv0 = input.texCoord0;
                        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                    #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                    #endif
                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                            return output;
                    }

                    // --------------------------------------------------
                    // Main

                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

                    // --------------------------------------------------
                    // Visual Effect Vertex Invocations
                    #ifdef HAVE_VFX_MODIFICATION
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                    #endif

                    ENDHLSL
                    }
                    Pass
                    {
                        Name "ShadowCaster"
                        Tags
                        {
                            "LightMode" = "ShadowCaster"
                        }

                        // Render State
                        Cull Back
                        ZTest LEqual
                        ZWrite On
                        ColorMask 0

                        // Debug
                        // <None>

                        // --------------------------------------------------
                        // Pass

                        HLSLPROGRAM

                        // Pragmas
                        #pragma target 4.5
                        #pragma exclude_renderers gles gles3 glcore
                        #pragma multi_compile_instancing
                        #pragma multi_compile _ DOTS_INSTANCING_ON
                        #pragma vertex vert
                        #pragma fragment frag

                        // DotsInstancingOptions: <None>
                        // HybridV1InjectedBuiltinProperties: <None>

                        // Keywords
                        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                        // GraphKeywords: <None>

                        // Defines

                        #define _NORMALMAP 1
                        #define _NORMAL_DROPOFF_TS 1
                        #define ATTRIBUTES_NEED_NORMAL
                        #define ATTRIBUTES_NEED_TANGENT
                        #define ATTRIBUTES_NEED_TEXCOORD0
                        #define VARYINGS_NEED_POSITION_WS
                        #define VARYINGS_NEED_NORMAL_WS
                        #define FEATURES_GRAPH_VERTEX
                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                        #define SHADERPASS SHADERPASS_SHADOWCASTER
                        #define REQUIRE_DEPTH_TEXTURE
                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                        // custom interpolator pre-include
                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                        // Includes
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                        // --------------------------------------------------
                        // Structs and Packing

                        // custom interpolators pre packing
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                        struct Attributes
                        {
                             float3 positionOS : POSITION;
                             float3 normalOS : NORMAL;
                             float4 tangentOS : TANGENT;
                             float4 uv0 : TEXCOORD0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : INSTANCEID_SEMANTIC;
                            #endif
                        };
                        struct Varyings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 positionWS;
                             float3 normalWS;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };
                        struct SurfaceDescriptionInputs
                        {
                             float3 WorldSpacePosition;
                             float4 ScreenPosition;
                        };
                        struct VertexDescriptionInputs
                        {
                             float3 ObjectSpaceNormal;
                             float3 ObjectSpaceTangent;
                             float3 ObjectSpacePosition;
                             float4 uv0;
                             float3 TimeParameters;
                        };
                        struct PackedVaryings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 interp0 : INTERP0;
                             float3 interp1 : INTERP1;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };

                        PackedVaryings PackVaryings(Varyings input)
                        {
                            PackedVaryings output;
                            ZERO_INITIALIZE(PackedVaryings, output);
                            output.positionCS = input.positionCS;
                            output.interp0.xyz = input.positionWS;
                            output.interp1.xyz = input.normalWS;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }

                        Varyings UnpackVaryings(PackedVaryings input)
                        {
                            Varyings output;
                            output.positionCS = input.positionCS;
                            output.positionWS = input.interp0.xyz;
                            output.normalWS = input.interp1.xyz;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }


                        // --------------------------------------------------
                        // Graph

                        // Graph Properties
                        CBUFFER_START(UnityPerMaterial)
                        float _Depth;
                        float _Strength;
                        float4 _DeepWaterColor;
                        float4 _ShallowWaterColor;
                        float4 _MainNormal_TexelSize;
                        float4 _SecondNormal_TexelSize;
                        float _NormalStrength;
                        float _Smoothness;
                        float _Displacement;
                        CBUFFER_END

                            // Object and Global properties
                            SAMPLER(SamplerState_Linear_Repeat);
                            TEXTURE2D(_MainNormal);
                            SAMPLER(sampler_MainNormal);
                            TEXTURE2D(_SecondNormal);
                            SAMPLER(sampler_SecondNormal);

                            // Graph Includes
                            // GraphIncludes: <None>

                            // -- Property used by ScenePickingPass
                            #ifdef SCENEPICKINGPASS
                            float4 _SelectionID;
                            #endif

                            // -- Properties used by SceneSelectionPass
                            #ifdef SCENESELECTIONPASS
                            int _ObjectId;
                            int _PassValue;
                            #endif

                            // Graph Functions

                            void Unity_Divide_float(float A, float B, out float Out)
                            {
                                Out = A / B;
                            }

                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                            {
                                Out = UV * Tiling + Offset;
                            }


                            float2 Unity_GradientNoise_Dir_float(float2 p)
                            {
                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                p = p % 289;
                                // need full precision, otherwise half overflows when p > 1
                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                x = (34 * x + 1) * x % 289;
                                x = frac(x / 41) * 2 - 1;
                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                            }

                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                            {
                                float2 p = UV * Scale;
                                float2 ip = floor(p);
                                float2 fp = frac(p);
                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                            }

                            void Unity_Multiply_float_float(float A, float B, out float Out)
                            {
                                Out = A * B;
                            }

                            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                            {
                                RGBA = float4(R, G, B, A);
                                RGB = float3(R, G, B);
                                RG = float2(R, G);
                            }

                            void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                            {
                                Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                            }

                            void Unity_Add_float(float A, float B, out float Out)
                            {
                                Out = A + B;
                            }

                            void Unity_Subtract_float(float A, float B, out float Out)
                            {
                                Out = A - B;
                            }

                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                            {
                                Out = clamp(In, Min, Max);
                            }

                            void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                            {
                                Out = lerp(A, B, T);
                            }

                            // Custom interpolators pre vertex
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                            // Graph Vertex
                            struct VertexDescription
                            {
                                float3 Position;
                                float3 Normal;
                                float3 Tangent;
                            };

                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                            {
                                VertexDescription description = (VertexDescription)0;
                                float _Split_5a46fb254a6548d9a32e712a81235ca4_R_1 = IN.ObjectSpacePosition[0];
                                float _Split_5a46fb254a6548d9a32e712a81235ca4_G_2 = IN.ObjectSpacePosition[1];
                                float _Split_5a46fb254a6548d9a32e712a81235ca4_B_3 = IN.ObjectSpacePosition[2];
                                float _Split_5a46fb254a6548d9a32e712a81235ca4_A_4 = 0;
                                float _Property_2aee0f2c381447299717226883b9dd5e_Out_0 = _Displacement;
                                float _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2;
                                Unity_Divide_float(IN.TimeParameters.x, 50, _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2);
                                float2 _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3;
                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_0347d994cff649cca9eb90763a4ce74a_Out_2.xx), _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3);
                                float _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2;
                                Unity_GradientNoise_float(_TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3, 20, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2);
                                float _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2;
                                Unity_Multiply_float_float(_Property_2aee0f2c381447299717226883b9dd5e_Out_0, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2);
                                float4 _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4;
                                float3 _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                float2 _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6;
                                Unity_Combine_float(_Split_5a46fb254a6548d9a32e712a81235ca4_R_1, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2, _Split_5a46fb254a6548d9a32e712a81235ca4_B_3, 0, _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4, _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5, _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6);
                                description.Position = _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                description.Normal = IN.ObjectSpaceNormal;
                                description.Tangent = IN.ObjectSpaceTangent;
                                return description;
                            }

                            // Custom interpolators, pre surface
                            #ifdef FEATURES_GRAPH_VERTEX
                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                            {
                            return output;
                            }
                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                            #endif

                            // Graph Pixel
                            struct SurfaceDescription
                            {
                                float Alpha;
                            };

                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                            {
                                SurfaceDescription surface = (SurfaceDescription)0;
                                float4 _Property_f669795152fd4d83bfe0251a331b5e7e_Out_0 = _ShallowWaterColor;
                                float4 _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0 = _DeepWaterColor;
                                float _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1;
                                Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1);
                                float _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2;
                                Unity_Multiply_float_float(_SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1, _ProjectionParams.z, _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2);
                                float4 _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0 = IN.ScreenPosition;
                                float _Split_fabee40938d249f58c6df289b29487e6_R_1 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[0];
                                float _Split_fabee40938d249f58c6df289b29487e6_G_2 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[1];
                                float _Split_fabee40938d249f58c6df289b29487e6_B_3 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[2];
                                float _Split_fabee40938d249f58c6df289b29487e6_A_4 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[3];
                                float _Property_b835ed47772e498ca3bfd0304467564a_Out_0 = _Depth;
                                float _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2;
                                Unity_Add_float(_Split_fabee40938d249f58c6df289b29487e6_A_4, _Property_b835ed47772e498ca3bfd0304467564a_Out_0, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2);
                                float _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2;
                                Unity_Subtract_float(_Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2, _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2);
                                float _Property_d4102fc229a94768ae4a93daed7fd849_Out_0 = _Strength;
                                float _Multiply_c032a0c444d84300a760598cbea78a62_Out_2;
                                Unity_Multiply_float_float(_Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2, _Property_d4102fc229a94768ae4a93daed7fd849_Out_0, _Multiply_c032a0c444d84300a760598cbea78a62_Out_2);
                                float _Clamp_e8c5093ba9604977add70348fe2134be_Out_3;
                                Unity_Clamp_float(_Multiply_c032a0c444d84300a760598cbea78a62_Out_2, 0, 1, _Clamp_e8c5093ba9604977add70348fe2134be_Out_3);
                                float4 _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3;
                                Unity_Lerp_float4(_Property_f669795152fd4d83bfe0251a331b5e7e_Out_0, _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0, (_Clamp_e8c5093ba9604977add70348fe2134be_Out_3.xxxx), _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3);
                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_R_1 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[0];
                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_G_2 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[1];
                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_B_3 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[2];
                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[3];
                                surface.Alpha = _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4;
                                return surface;
                            }

                            // --------------------------------------------------
                            // Build Graph Inputs
                            #ifdef HAVE_VFX_MODIFICATION
                            #define VFX_SRP_ATTRIBUTES Attributes
                            #define VFX_SRP_VARYINGS Varyings
                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                            #endif
                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                            {
                                VertexDescriptionInputs output;
                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                output.ObjectSpaceNormal = input.normalOS;
                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                output.ObjectSpacePosition = input.positionOS;
                                output.uv0 = input.uv0;
                                output.TimeParameters = _TimeParameters.xyz;

                                return output;
                            }
                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                            {
                                SurfaceDescriptionInputs output;
                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                            #ifdef HAVE_VFX_MODIFICATION
                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                            #endif







                                output.WorldSpacePosition = input.positionWS;
                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                            #else
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                            #endif
                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                    return output;
                            }

                            // --------------------------------------------------
                            // Main

                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                            // --------------------------------------------------
                            // Visual Effect Vertex Invocations
                            #ifdef HAVE_VFX_MODIFICATION
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                            #endif

                            ENDHLSL
                            }
                            Pass
                            {
                                Name "DepthNormals"
                                Tags
                                {
                                    "LightMode" = "DepthNormals"
                                }

                                // Render State
                                Cull Back
                                ZTest LEqual
                                ZWrite On

                                // Debug
                                // <None>

                                // --------------------------------------------------
                                // Pass

                                HLSLPROGRAM

                                // Pragmas
                                #pragma target 4.5
                                #pragma exclude_renderers gles gles3 glcore
                                #pragma multi_compile_instancing
                                #pragma multi_compile _ DOTS_INSTANCING_ON
                                #pragma vertex vert
                                #pragma fragment frag

                                // DotsInstancingOptions: <None>
                                // HybridV1InjectedBuiltinProperties: <None>

                                // Keywords
                                // PassKeywords: <None>
                                // GraphKeywords: <None>

                                // Defines

                                #define _NORMALMAP 1
                                #define _NORMAL_DROPOFF_TS 1
                                #define ATTRIBUTES_NEED_NORMAL
                                #define ATTRIBUTES_NEED_TANGENT
                                #define ATTRIBUTES_NEED_TEXCOORD0
                                #define ATTRIBUTES_NEED_TEXCOORD1
                                #define VARYINGS_NEED_POSITION_WS
                                #define VARYINGS_NEED_NORMAL_WS
                                #define VARYINGS_NEED_TANGENT_WS
                                #define VARYINGS_NEED_TEXCOORD0
                                #define FEATURES_GRAPH_VERTEX
                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                #define SHADERPASS SHADERPASS_DEPTHNORMALS
                                #define REQUIRE_DEPTH_TEXTURE
                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                // custom interpolator pre-include
                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                // Includes
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                // --------------------------------------------------
                                // Structs and Packing

                                // custom interpolators pre packing
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                struct Attributes
                                {
                                     float3 positionOS : POSITION;
                                     float3 normalOS : NORMAL;
                                     float4 tangentOS : TANGENT;
                                     float4 uv0 : TEXCOORD0;
                                     float4 uv1 : TEXCOORD1;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : INSTANCEID_SEMANTIC;
                                    #endif
                                };
                                struct Varyings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float3 positionWS;
                                     float3 normalWS;
                                     float4 tangentWS;
                                     float4 texCoord0;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };
                                struct SurfaceDescriptionInputs
                                {
                                     float3 TangentSpaceNormal;
                                     float3 WorldSpacePosition;
                                     float4 ScreenPosition;
                                     float4 uv0;
                                     float3 TimeParameters;
                                };
                                struct VertexDescriptionInputs
                                {
                                     float3 ObjectSpaceNormal;
                                     float3 ObjectSpaceTangent;
                                     float3 ObjectSpacePosition;
                                     float4 uv0;
                                     float3 TimeParameters;
                                };
                                struct PackedVaryings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float3 interp0 : INTERP0;
                                     float3 interp1 : INTERP1;
                                     float4 interp2 : INTERP2;
                                     float4 interp3 : INTERP3;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };

                                PackedVaryings PackVaryings(Varyings input)
                                {
                                    PackedVaryings output;
                                    ZERO_INITIALIZE(PackedVaryings, output);
                                    output.positionCS = input.positionCS;
                                    output.interp0.xyz = input.positionWS;
                                    output.interp1.xyz = input.normalWS;
                                    output.interp2.xyzw = input.tangentWS;
                                    output.interp3.xyzw = input.texCoord0;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }

                                Varyings UnpackVaryings(PackedVaryings input)
                                {
                                    Varyings output;
                                    output.positionCS = input.positionCS;
                                    output.positionWS = input.interp0.xyz;
                                    output.normalWS = input.interp1.xyz;
                                    output.tangentWS = input.interp2.xyzw;
                                    output.texCoord0 = input.interp3.xyzw;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }


                                // --------------------------------------------------
                                // Graph

                                // Graph Properties
                                CBUFFER_START(UnityPerMaterial)
                                float _Depth;
                                float _Strength;
                                float4 _DeepWaterColor;
                                float4 _ShallowWaterColor;
                                float4 _MainNormal_TexelSize;
                                float4 _SecondNormal_TexelSize;
                                float _NormalStrength;
                                float _Smoothness;
                                float _Displacement;
                                CBUFFER_END

                                    // Object and Global properties
                                    SAMPLER(SamplerState_Linear_Repeat);
                                    TEXTURE2D(_MainNormal);
                                    SAMPLER(sampler_MainNormal);
                                    TEXTURE2D(_SecondNormal);
                                    SAMPLER(sampler_SecondNormal);

                                    // Graph Includes
                                    // GraphIncludes: <None>

                                    // -- Property used by ScenePickingPass
                                    #ifdef SCENEPICKINGPASS
                                    float4 _SelectionID;
                                    #endif

                                    // -- Properties used by SceneSelectionPass
                                    #ifdef SCENESELECTIONPASS
                                    int _ObjectId;
                                    int _PassValue;
                                    #endif

                                    // Graph Functions

                                    void Unity_Divide_float(float A, float B, out float Out)
                                    {
                                        Out = A / B;
                                    }

                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                    {
                                        Out = UV * Tiling + Offset;
                                    }


                                    float2 Unity_GradientNoise_Dir_float(float2 p)
                                    {
                                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                        p = p % 289;
                                        // need full precision, otherwise half overflows when p > 1
                                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                        x = (34 * x + 1) * x % 289;
                                        x = frac(x / 41) * 2 - 1;
                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                    }

                                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                    {
                                        float2 p = UV * Scale;
                                        float2 ip = floor(p);
                                        float2 fp = frac(p);
                                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                    }

                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                    {
                                        Out = A * B;
                                    }

                                    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                    {
                                        RGBA = float4(R, G, B, A);
                                        RGB = float3(R, G, B);
                                        RG = float2(R, G);
                                    }

                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                    {
                                        Out = A + B;
                                    }

                                    void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                                    {
                                        Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                    }

                                    void Unity_Add_float(float A, float B, out float Out)
                                    {
                                        Out = A + B;
                                    }

                                    void Unity_Subtract_float(float A, float B, out float Out)
                                    {
                                        Out = A - B;
                                    }

                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                    {
                                        Out = clamp(In, Min, Max);
                                    }

                                    void Unity_Lerp_float(float A, float B, float T, out float Out)
                                    {
                                        Out = lerp(A, B, T);
                                    }

                                    void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
                                    {
                                        Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
                                    }

                                    void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                    {
                                        Out = lerp(A, B, T);
                                    }

                                    // Custom interpolators pre vertex
                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                    // Graph Vertex
                                    struct VertexDescription
                                    {
                                        float3 Position;
                                        float3 Normal;
                                        float3 Tangent;
                                    };

                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                    {
                                        VertexDescription description = (VertexDescription)0;
                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_R_1 = IN.ObjectSpacePosition[0];
                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_G_2 = IN.ObjectSpacePosition[1];
                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_B_3 = IN.ObjectSpacePosition[2];
                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_A_4 = 0;
                                        float _Property_2aee0f2c381447299717226883b9dd5e_Out_0 = _Displacement;
                                        float _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2;
                                        Unity_Divide_float(IN.TimeParameters.x, 50, _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2);
                                        float2 _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3;
                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_0347d994cff649cca9eb90763a4ce74a_Out_2.xx), _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3);
                                        float _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2;
                                        Unity_GradientNoise_float(_TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3, 20, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2);
                                        float _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2;
                                        Unity_Multiply_float_float(_Property_2aee0f2c381447299717226883b9dd5e_Out_0, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2);
                                        float4 _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4;
                                        float3 _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                        float2 _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6;
                                        Unity_Combine_float(_Split_5a46fb254a6548d9a32e712a81235ca4_R_1, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2, _Split_5a46fb254a6548d9a32e712a81235ca4_B_3, 0, _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4, _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5, _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6);
                                        description.Position = _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                        description.Normal = IN.ObjectSpaceNormal;
                                        description.Tangent = IN.ObjectSpaceTangent;
                                        return description;
                                    }

                                    // Custom interpolators, pre surface
                                    #ifdef FEATURES_GRAPH_VERTEX
                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                    {
                                    return output;
                                    }
                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                    #endif

                                    // Graph Pixel
                                    struct SurfaceDescription
                                    {
                                        float3 NormalTS;
                                        float Alpha;
                                    };

                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                    {
                                        SurfaceDescription surface = (SurfaceDescription)0;
                                        UnityTexture2D _Property_53020a2b9cbe4b6a83ad0a9fee0558e8_Out_0 = UnityBuildTexture2DStructNoScale(_MainNormal);
                                        float _Divide_ee7923a88d6f4b1a9e8dbe5bfbb29685_Out_2;
                                        Unity_Divide_float(IN.TimeParameters.x, 50, _Divide_ee7923a88d6f4b1a9e8dbe5bfbb29685_Out_2);
                                        float2 _TilingAndOffset_a535553689a34d399e1a65691ca9aa39_Out_3;
                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (10, 10), (_Divide_ee7923a88d6f4b1a9e8dbe5bfbb29685_Out_2.xx), _TilingAndOffset_a535553689a34d399e1a65691ca9aa39_Out_3);
                                        float4 _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0 = SAMPLE_TEXTURE2D(_Property_53020a2b9cbe4b6a83ad0a9fee0558e8_Out_0.tex, _Property_53020a2b9cbe4b6a83ad0a9fee0558e8_Out_0.samplerstate, _Property_53020a2b9cbe4b6a83ad0a9fee0558e8_Out_0.GetTransformedUV(_TilingAndOffset_a535553689a34d399e1a65691ca9aa39_Out_3));
                                        _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0);
                                        float _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_R_4 = _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.r;
                                        float _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_G_5 = _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.g;
                                        float _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_B_6 = _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.b;
                                        float _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_A_7 = _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.a;
                                        UnityTexture2D _Property_2c235836e5664098bdb6fb2809be4539_Out_0 = UnityBuildTexture2DStructNoScale(_SecondNormal);
                                        float _Divide_5d7c40eba84948c2b427b4bc6c71a9b0_Out_2;
                                        Unity_Divide_float(IN.TimeParameters.x, -10, _Divide_5d7c40eba84948c2b427b4bc6c71a9b0_Out_2);
                                        float2 _TilingAndOffset_cca530b5dccb4ec0a00dd9aff0e156e2_Out_3;
                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (10, 10), (_Divide_5d7c40eba84948c2b427b4bc6c71a9b0_Out_2.xx), _TilingAndOffset_cca530b5dccb4ec0a00dd9aff0e156e2_Out_3);
                                        float4 _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0 = SAMPLE_TEXTURE2D(_Property_2c235836e5664098bdb6fb2809be4539_Out_0.tex, _Property_2c235836e5664098bdb6fb2809be4539_Out_0.samplerstate, _Property_2c235836e5664098bdb6fb2809be4539_Out_0.GetTransformedUV(_TilingAndOffset_cca530b5dccb4ec0a00dd9aff0e156e2_Out_3));
                                        _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0);
                                        float _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_R_4 = _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.r;
                                        float _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_G_5 = _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.g;
                                        float _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_B_6 = _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.b;
                                        float _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_A_7 = _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.a;
                                        float4 _Add_9b2536bd6bce45d4916943d980d7fc3f_Out_2;
                                        Unity_Add_float4(_SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0, _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0, _Add_9b2536bd6bce45d4916943d980d7fc3f_Out_2);
                                        float _Property_a5190d1ea56040d29725d71fd10fc2ff_Out_0 = _NormalStrength;
                                        float _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1;
                                        Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1);
                                        float _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2;
                                        Unity_Multiply_float_float(_SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1, _ProjectionParams.z, _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2);
                                        float4 _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0 = IN.ScreenPosition;
                                        float _Split_fabee40938d249f58c6df289b29487e6_R_1 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[0];
                                        float _Split_fabee40938d249f58c6df289b29487e6_G_2 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[1];
                                        float _Split_fabee40938d249f58c6df289b29487e6_B_3 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[2];
                                        float _Split_fabee40938d249f58c6df289b29487e6_A_4 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[3];
                                        float _Property_b835ed47772e498ca3bfd0304467564a_Out_0 = _Depth;
                                        float _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2;
                                        Unity_Add_float(_Split_fabee40938d249f58c6df289b29487e6_A_4, _Property_b835ed47772e498ca3bfd0304467564a_Out_0, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2);
                                        float _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2;
                                        Unity_Subtract_float(_Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2, _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2);
                                        float _Property_d4102fc229a94768ae4a93daed7fd849_Out_0 = _Strength;
                                        float _Multiply_c032a0c444d84300a760598cbea78a62_Out_2;
                                        Unity_Multiply_float_float(_Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2, _Property_d4102fc229a94768ae4a93daed7fd849_Out_0, _Multiply_c032a0c444d84300a760598cbea78a62_Out_2);
                                        float _Clamp_e8c5093ba9604977add70348fe2134be_Out_3;
                                        Unity_Clamp_float(_Multiply_c032a0c444d84300a760598cbea78a62_Out_2, 0, 1, _Clamp_e8c5093ba9604977add70348fe2134be_Out_3);
                                        float _Lerp_1b3da68c18ce4ab6b9781c9955aaa9ee_Out_3;
                                        Unity_Lerp_float(0, _Property_a5190d1ea56040d29725d71fd10fc2ff_Out_0, _Clamp_e8c5093ba9604977add70348fe2134be_Out_3, _Lerp_1b3da68c18ce4ab6b9781c9955aaa9ee_Out_3);
                                        float3 _NormalStrength_36f00e1d555c491bb0ed1d778d4eef29_Out_2;
                                        Unity_NormalStrength_float((_Add_9b2536bd6bce45d4916943d980d7fc3f_Out_2.xyz), _Lerp_1b3da68c18ce4ab6b9781c9955aaa9ee_Out_3, _NormalStrength_36f00e1d555c491bb0ed1d778d4eef29_Out_2);
                                        float4 _Property_f669795152fd4d83bfe0251a331b5e7e_Out_0 = _ShallowWaterColor;
                                        float4 _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0 = _DeepWaterColor;
                                        float4 _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3;
                                        Unity_Lerp_float4(_Property_f669795152fd4d83bfe0251a331b5e7e_Out_0, _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0, (_Clamp_e8c5093ba9604977add70348fe2134be_Out_3.xxxx), _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3);
                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_R_1 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[0];
                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_G_2 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[1];
                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_B_3 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[2];
                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[3];
                                        surface.NormalTS = _NormalStrength_36f00e1d555c491bb0ed1d778d4eef29_Out_2;
                                        surface.Alpha = _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4;
                                        return surface;
                                    }

                                    // --------------------------------------------------
                                    // Build Graph Inputs
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #define VFX_SRP_ATTRIBUTES Attributes
                                    #define VFX_SRP_VARYINGS Varyings
                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                    #endif
                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                    {
                                        VertexDescriptionInputs output;
                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                        output.ObjectSpaceNormal = input.normalOS;
                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                        output.ObjectSpacePosition = input.positionOS;
                                        output.uv0 = input.uv0;
                                        output.TimeParameters = _TimeParameters.xyz;

                                        return output;
                                    }
                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                    {
                                        SurfaceDescriptionInputs output;
                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                    #ifdef HAVE_VFX_MODIFICATION
                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                    #endif





                                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                        output.WorldSpacePosition = input.positionWS;
                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                        output.uv0 = input.texCoord0;
                                        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                    #else
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                    #endif
                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                            return output;
                                    }

                                    // --------------------------------------------------
                                    // Main

                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                    // --------------------------------------------------
                                    // Visual Effect Vertex Invocations
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                    #endif

                                    ENDHLSL
                                    }
                                    Pass
                                    {
                                        Name "Meta"
                                        Tags
                                        {
                                            "LightMode" = "Meta"
                                        }

                                        // Render State
                                        Cull Off

                                        // Debug
                                        // <None>

                                        // --------------------------------------------------
                                        // Pass

                                        HLSLPROGRAM

                                        // Pragmas
                                        #pragma target 4.5
                                        #pragma exclude_renderers gles gles3 glcore
                                        #pragma vertex vert
                                        #pragma fragment frag

                                        // DotsInstancingOptions: <None>
                                        // HybridV1InjectedBuiltinProperties: <None>

                                        // Keywords
                                        #pragma shader_feature _ EDITOR_VISUALIZATION
                                        // GraphKeywords: <None>

                                        // Defines

                                        #define _NORMALMAP 1
                                        #define _NORMAL_DROPOFF_TS 1
                                        #define ATTRIBUTES_NEED_NORMAL
                                        #define ATTRIBUTES_NEED_TANGENT
                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                        #define ATTRIBUTES_NEED_TEXCOORD2
                                        #define VARYINGS_NEED_POSITION_WS
                                        #define VARYINGS_NEED_TEXCOORD0
                                        #define VARYINGS_NEED_TEXCOORD1
                                        #define VARYINGS_NEED_TEXCOORD2
                                        #define FEATURES_GRAPH_VERTEX
                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                        #define SHADERPASS SHADERPASS_META
                                        #define _FOG_FRAGMENT 1
                                        #define REQUIRE_DEPTH_TEXTURE
                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                        // custom interpolator pre-include
                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                        // Includes
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                        // --------------------------------------------------
                                        // Structs and Packing

                                        // custom interpolators pre packing
                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                        struct Attributes
                                        {
                                             float3 positionOS : POSITION;
                                             float3 normalOS : NORMAL;
                                             float4 tangentOS : TANGENT;
                                             float4 uv0 : TEXCOORD0;
                                             float4 uv1 : TEXCOORD1;
                                             float4 uv2 : TEXCOORD2;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : INSTANCEID_SEMANTIC;
                                            #endif
                                        };
                                        struct Varyings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float3 positionWS;
                                             float4 texCoord0;
                                             float4 texCoord1;
                                             float4 texCoord2;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };
                                        struct SurfaceDescriptionInputs
                                        {
                                             float3 WorldSpacePosition;
                                             float4 ScreenPosition;
                                        };
                                        struct VertexDescriptionInputs
                                        {
                                             float3 ObjectSpaceNormal;
                                             float3 ObjectSpaceTangent;
                                             float3 ObjectSpacePosition;
                                             float4 uv0;
                                             float3 TimeParameters;
                                        };
                                        struct PackedVaryings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float3 interp0 : INTERP0;
                                             float4 interp1 : INTERP1;
                                             float4 interp2 : INTERP2;
                                             float4 interp3 : INTERP3;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };

                                        PackedVaryings PackVaryings(Varyings input)
                                        {
                                            PackedVaryings output;
                                            ZERO_INITIALIZE(PackedVaryings, output);
                                            output.positionCS = input.positionCS;
                                            output.interp0.xyz = input.positionWS;
                                            output.interp1.xyzw = input.texCoord0;
                                            output.interp2.xyzw = input.texCoord1;
                                            output.interp3.xyzw = input.texCoord2;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }

                                        Varyings UnpackVaryings(PackedVaryings input)
                                        {
                                            Varyings output;
                                            output.positionCS = input.positionCS;
                                            output.positionWS = input.interp0.xyz;
                                            output.texCoord0 = input.interp1.xyzw;
                                            output.texCoord1 = input.interp2.xyzw;
                                            output.texCoord2 = input.interp3.xyzw;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }


                                        // --------------------------------------------------
                                        // Graph

                                        // Graph Properties
                                        CBUFFER_START(UnityPerMaterial)
                                        float _Depth;
                                        float _Strength;
                                        float4 _DeepWaterColor;
                                        float4 _ShallowWaterColor;
                                        float4 _MainNormal_TexelSize;
                                        float4 _SecondNormal_TexelSize;
                                        float _NormalStrength;
                                        float _Smoothness;
                                        float _Displacement;
                                        CBUFFER_END

                                            // Object and Global properties
                                            SAMPLER(SamplerState_Linear_Repeat);
                                            TEXTURE2D(_MainNormal);
                                            SAMPLER(sampler_MainNormal);
                                            TEXTURE2D(_SecondNormal);
                                            SAMPLER(sampler_SecondNormal);

                                            // Graph Includes
                                            // GraphIncludes: <None>

                                            // -- Property used by ScenePickingPass
                                            #ifdef SCENEPICKINGPASS
                                            float4 _SelectionID;
                                            #endif

                                            // -- Properties used by SceneSelectionPass
                                            #ifdef SCENESELECTIONPASS
                                            int _ObjectId;
                                            int _PassValue;
                                            #endif

                                            // Graph Functions

                                            void Unity_Divide_float(float A, float B, out float Out)
                                            {
                                                Out = A / B;
                                            }

                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                            {
                                                Out = UV * Tiling + Offset;
                                            }


                                            float2 Unity_GradientNoise_Dir_float(float2 p)
                                            {
                                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                p = p % 289;
                                                // need full precision, otherwise half overflows when p > 1
                                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                x = (34 * x + 1) * x % 289;
                                                x = frac(x / 41) * 2 - 1;
                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                            }

                                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                            {
                                                float2 p = UV * Scale;
                                                float2 ip = floor(p);
                                                float2 fp = frac(p);
                                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                            }

                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                            {
                                                Out = A * B;
                                            }

                                            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                            {
                                                RGBA = float4(R, G, B, A);
                                                RGB = float3(R, G, B);
                                                RG = float2(R, G);
                                            }

                                            void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                                            {
                                                Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                            }

                                            void Unity_Add_float(float A, float B, out float Out)
                                            {
                                                Out = A + B;
                                            }

                                            void Unity_Subtract_float(float A, float B, out float Out)
                                            {
                                                Out = A - B;
                                            }

                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                            {
                                                Out = clamp(In, Min, Max);
                                            }

                                            void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                            {
                                                Out = lerp(A, B, T);
                                            }

                                            // Custom interpolators pre vertex
                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                            // Graph Vertex
                                            struct VertexDescription
                                            {
                                                float3 Position;
                                                float3 Normal;
                                                float3 Tangent;
                                            };

                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                            {
                                                VertexDescription description = (VertexDescription)0;
                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_R_1 = IN.ObjectSpacePosition[0];
                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_G_2 = IN.ObjectSpacePosition[1];
                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_B_3 = IN.ObjectSpacePosition[2];
                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_A_4 = 0;
                                                float _Property_2aee0f2c381447299717226883b9dd5e_Out_0 = _Displacement;
                                                float _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2;
                                                Unity_Divide_float(IN.TimeParameters.x, 50, _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2);
                                                float2 _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3;
                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_0347d994cff649cca9eb90763a4ce74a_Out_2.xx), _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3);
                                                float _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2;
                                                Unity_GradientNoise_float(_TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3, 20, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2);
                                                float _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2;
                                                Unity_Multiply_float_float(_Property_2aee0f2c381447299717226883b9dd5e_Out_0, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2);
                                                float4 _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4;
                                                float3 _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                float2 _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6;
                                                Unity_Combine_float(_Split_5a46fb254a6548d9a32e712a81235ca4_R_1, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2, _Split_5a46fb254a6548d9a32e712a81235ca4_B_3, 0, _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4, _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5, _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6);
                                                description.Position = _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                description.Normal = IN.ObjectSpaceNormal;
                                                description.Tangent = IN.ObjectSpaceTangent;
                                                return description;
                                            }

                                            // Custom interpolators, pre surface
                                            #ifdef FEATURES_GRAPH_VERTEX
                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                            {
                                            return output;
                                            }
                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                            #endif

                                            // Graph Pixel
                                            struct SurfaceDescription
                                            {
                                                float3 BaseColor;
                                                float3 Emission;
                                                float Alpha;
                                            };

                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                            {
                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                float4 _Property_f669795152fd4d83bfe0251a331b5e7e_Out_0 = _ShallowWaterColor;
                                                float4 _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0 = _DeepWaterColor;
                                                float _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1;
                                                Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1);
                                                float _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2;
                                                Unity_Multiply_float_float(_SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1, _ProjectionParams.z, _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2);
                                                float4 _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0 = IN.ScreenPosition;
                                                float _Split_fabee40938d249f58c6df289b29487e6_R_1 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[0];
                                                float _Split_fabee40938d249f58c6df289b29487e6_G_2 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[1];
                                                float _Split_fabee40938d249f58c6df289b29487e6_B_3 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[2];
                                                float _Split_fabee40938d249f58c6df289b29487e6_A_4 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[3];
                                                float _Property_b835ed47772e498ca3bfd0304467564a_Out_0 = _Depth;
                                                float _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2;
                                                Unity_Add_float(_Split_fabee40938d249f58c6df289b29487e6_A_4, _Property_b835ed47772e498ca3bfd0304467564a_Out_0, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2);
                                                float _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2;
                                                Unity_Subtract_float(_Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2, _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2);
                                                float _Property_d4102fc229a94768ae4a93daed7fd849_Out_0 = _Strength;
                                                float _Multiply_c032a0c444d84300a760598cbea78a62_Out_2;
                                                Unity_Multiply_float_float(_Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2, _Property_d4102fc229a94768ae4a93daed7fd849_Out_0, _Multiply_c032a0c444d84300a760598cbea78a62_Out_2);
                                                float _Clamp_e8c5093ba9604977add70348fe2134be_Out_3;
                                                Unity_Clamp_float(_Multiply_c032a0c444d84300a760598cbea78a62_Out_2, 0, 1, _Clamp_e8c5093ba9604977add70348fe2134be_Out_3);
                                                float4 _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3;
                                                Unity_Lerp_float4(_Property_f669795152fd4d83bfe0251a331b5e7e_Out_0, _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0, (_Clamp_e8c5093ba9604977add70348fe2134be_Out_3.xxxx), _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3);
                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_R_1 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[0];
                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_G_2 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[1];
                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_B_3 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[2];
                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[3];
                                                surface.BaseColor = (_Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3.xyz);
                                                surface.Emission = float3(0, 0, 0);
                                                surface.Alpha = _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4;
                                                return surface;
                                            }

                                            // --------------------------------------------------
                                            // Build Graph Inputs
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #define VFX_SRP_ATTRIBUTES Attributes
                                            #define VFX_SRP_VARYINGS Varyings
                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                            #endif
                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                            {
                                                VertexDescriptionInputs output;
                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                output.ObjectSpaceNormal = input.normalOS;
                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                output.ObjectSpacePosition = input.positionOS;
                                                output.uv0 = input.uv0;
                                                output.TimeParameters = _TimeParameters.xyz;

                                                return output;
                                            }
                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                            {
                                                SurfaceDescriptionInputs output;
                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                            #ifdef HAVE_VFX_MODIFICATION
                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                            #endif







                                                output.WorldSpacePosition = input.positionWS;
                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                            #else
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                            #endif
                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                    return output;
                                            }

                                            // --------------------------------------------------
                                            // Main

                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                            // --------------------------------------------------
                                            // Visual Effect Vertex Invocations
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                            #endif

                                            ENDHLSL
                                            }
                                            Pass
                                            {
                                                Name "SceneSelectionPass"
                                                Tags
                                                {
                                                    "LightMode" = "SceneSelectionPass"
                                                }

                                                // Render State
                                                Cull Off

                                                // Debug
                                                // <None>

                                                // --------------------------------------------------
                                                // Pass

                                                HLSLPROGRAM

                                                // Pragmas
                                                #pragma target 4.5
                                                #pragma exclude_renderers gles gles3 glcore
                                                #pragma vertex vert
                                                #pragma fragment frag

                                                // DotsInstancingOptions: <None>
                                                // HybridV1InjectedBuiltinProperties: <None>

                                                // Keywords
                                                // PassKeywords: <None>
                                                // GraphKeywords: <None>

                                                // Defines

                                                #define _NORMALMAP 1
                                                #define _NORMAL_DROPOFF_TS 1
                                                #define ATTRIBUTES_NEED_NORMAL
                                                #define ATTRIBUTES_NEED_TANGENT
                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                #define VARYINGS_NEED_POSITION_WS
                                                #define FEATURES_GRAPH_VERTEX
                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                #define SCENESELECTIONPASS 1
                                                #define ALPHA_CLIP_THRESHOLD 1
                                                #define REQUIRE_DEPTH_TEXTURE
                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                // custom interpolator pre-include
                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                // Includes
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                // --------------------------------------------------
                                                // Structs and Packing

                                                // custom interpolators pre packing
                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                struct Attributes
                                                {
                                                     float3 positionOS : POSITION;
                                                     float3 normalOS : NORMAL;
                                                     float4 tangentOS : TANGENT;
                                                     float4 uv0 : TEXCOORD0;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                    #endif
                                                };
                                                struct Varyings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float3 positionWS;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };
                                                struct SurfaceDescriptionInputs
                                                {
                                                     float3 WorldSpacePosition;
                                                     float4 ScreenPosition;
                                                };
                                                struct VertexDescriptionInputs
                                                {
                                                     float3 ObjectSpaceNormal;
                                                     float3 ObjectSpaceTangent;
                                                     float3 ObjectSpacePosition;
                                                     float4 uv0;
                                                     float3 TimeParameters;
                                                };
                                                struct PackedVaryings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float3 interp0 : INTERP0;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };

                                                PackedVaryings PackVaryings(Varyings input)
                                                {
                                                    PackedVaryings output;
                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                    output.positionCS = input.positionCS;
                                                    output.interp0.xyz = input.positionWS;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }

                                                Varyings UnpackVaryings(PackedVaryings input)
                                                {
                                                    Varyings output;
                                                    output.positionCS = input.positionCS;
                                                    output.positionWS = input.interp0.xyz;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }


                                                // --------------------------------------------------
                                                // Graph

                                                // Graph Properties
                                                CBUFFER_START(UnityPerMaterial)
                                                float _Depth;
                                                float _Strength;
                                                float4 _DeepWaterColor;
                                                float4 _ShallowWaterColor;
                                                float4 _MainNormal_TexelSize;
                                                float4 _SecondNormal_TexelSize;
                                                float _NormalStrength;
                                                float _Smoothness;
                                                float _Displacement;
                                                CBUFFER_END

                                                    // Object and Global properties
                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                    TEXTURE2D(_MainNormal);
                                                    SAMPLER(sampler_MainNormal);
                                                    TEXTURE2D(_SecondNormal);
                                                    SAMPLER(sampler_SecondNormal);

                                                    // Graph Includes
                                                    // GraphIncludes: <None>

                                                    // -- Property used by ScenePickingPass
                                                    #ifdef SCENEPICKINGPASS
                                                    float4 _SelectionID;
                                                    #endif

                                                    // -- Properties used by SceneSelectionPass
                                                    #ifdef SCENESELECTIONPASS
                                                    int _ObjectId;
                                                    int _PassValue;
                                                    #endif

                                                    // Graph Functions

                                                    void Unity_Divide_float(float A, float B, out float Out)
                                                    {
                                                        Out = A / B;
                                                    }

                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                    {
                                                        Out = UV * Tiling + Offset;
                                                    }


                                                    float2 Unity_GradientNoise_Dir_float(float2 p)
                                                    {
                                                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                        p = p % 289;
                                                        // need full precision, otherwise half overflows when p > 1
                                                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                        x = (34 * x + 1) * x % 289;
                                                        x = frac(x / 41) * 2 - 1;
                                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                    }

                                                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                    {
                                                        float2 p = UV * Scale;
                                                        float2 ip = floor(p);
                                                        float2 fp = frac(p);
                                                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                    }

                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                                    {
                                                        RGBA = float4(R, G, B, A);
                                                        RGB = float3(R, G, B);
                                                        RG = float2(R, G);
                                                    }

                                                    void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                                                    {
                                                        Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                                    }

                                                    void Unity_Add_float(float A, float B, out float Out)
                                                    {
                                                        Out = A + B;
                                                    }

                                                    void Unity_Subtract_float(float A, float B, out float Out)
                                                    {
                                                        Out = A - B;
                                                    }

                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                    {
                                                        Out = clamp(In, Min, Max);
                                                    }

                                                    void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                                    {
                                                        Out = lerp(A, B, T);
                                                    }

                                                    // Custom interpolators pre vertex
                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                    // Graph Vertex
                                                    struct VertexDescription
                                                    {
                                                        float3 Position;
                                                        float3 Normal;
                                                        float3 Tangent;
                                                    };

                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                    {
                                                        VertexDescription description = (VertexDescription)0;
                                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_R_1 = IN.ObjectSpacePosition[0];
                                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_G_2 = IN.ObjectSpacePosition[1];
                                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_B_3 = IN.ObjectSpacePosition[2];
                                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_A_4 = 0;
                                                        float _Property_2aee0f2c381447299717226883b9dd5e_Out_0 = _Displacement;
                                                        float _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2;
                                                        Unity_Divide_float(IN.TimeParameters.x, 50, _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2);
                                                        float2 _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3;
                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_0347d994cff649cca9eb90763a4ce74a_Out_2.xx), _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3);
                                                        float _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2;
                                                        Unity_GradientNoise_float(_TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3, 20, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2);
                                                        float _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2;
                                                        Unity_Multiply_float_float(_Property_2aee0f2c381447299717226883b9dd5e_Out_0, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2);
                                                        float4 _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4;
                                                        float3 _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                        float2 _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6;
                                                        Unity_Combine_float(_Split_5a46fb254a6548d9a32e712a81235ca4_R_1, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2, _Split_5a46fb254a6548d9a32e712a81235ca4_B_3, 0, _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4, _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5, _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6);
                                                        description.Position = _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                        description.Normal = IN.ObjectSpaceNormal;
                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                        return description;
                                                    }

                                                    // Custom interpolators, pre surface
                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                    {
                                                    return output;
                                                    }
                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                    #endif

                                                    // Graph Pixel
                                                    struct SurfaceDescription
                                                    {
                                                        float Alpha;
                                                    };

                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                    {
                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                        float4 _Property_f669795152fd4d83bfe0251a331b5e7e_Out_0 = _ShallowWaterColor;
                                                        float4 _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0 = _DeepWaterColor;
                                                        float _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1;
                                                        Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1);
                                                        float _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2;
                                                        Unity_Multiply_float_float(_SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1, _ProjectionParams.z, _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2);
                                                        float4 _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0 = IN.ScreenPosition;
                                                        float _Split_fabee40938d249f58c6df289b29487e6_R_1 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[0];
                                                        float _Split_fabee40938d249f58c6df289b29487e6_G_2 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[1];
                                                        float _Split_fabee40938d249f58c6df289b29487e6_B_3 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[2];
                                                        float _Split_fabee40938d249f58c6df289b29487e6_A_4 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[3];
                                                        float _Property_b835ed47772e498ca3bfd0304467564a_Out_0 = _Depth;
                                                        float _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2;
                                                        Unity_Add_float(_Split_fabee40938d249f58c6df289b29487e6_A_4, _Property_b835ed47772e498ca3bfd0304467564a_Out_0, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2);
                                                        float _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2;
                                                        Unity_Subtract_float(_Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2, _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2);
                                                        float _Property_d4102fc229a94768ae4a93daed7fd849_Out_0 = _Strength;
                                                        float _Multiply_c032a0c444d84300a760598cbea78a62_Out_2;
                                                        Unity_Multiply_float_float(_Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2, _Property_d4102fc229a94768ae4a93daed7fd849_Out_0, _Multiply_c032a0c444d84300a760598cbea78a62_Out_2);
                                                        float _Clamp_e8c5093ba9604977add70348fe2134be_Out_3;
                                                        Unity_Clamp_float(_Multiply_c032a0c444d84300a760598cbea78a62_Out_2, 0, 1, _Clamp_e8c5093ba9604977add70348fe2134be_Out_3);
                                                        float4 _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3;
                                                        Unity_Lerp_float4(_Property_f669795152fd4d83bfe0251a331b5e7e_Out_0, _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0, (_Clamp_e8c5093ba9604977add70348fe2134be_Out_3.xxxx), _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3);
                                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_R_1 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[0];
                                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_G_2 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[1];
                                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_B_3 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[2];
                                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[3];
                                                        surface.Alpha = _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4;
                                                        return surface;
                                                    }

                                                    // --------------------------------------------------
                                                    // Build Graph Inputs
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                    #define VFX_SRP_VARYINGS Varyings
                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                    #endif
                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                    {
                                                        VertexDescriptionInputs output;
                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                        output.ObjectSpaceNormal = input.normalOS;
                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                        output.ObjectSpacePosition = input.positionOS;
                                                        output.uv0 = input.uv0;
                                                        output.TimeParameters = _TimeParameters.xyz;

                                                        return output;
                                                    }
                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                    {
                                                        SurfaceDescriptionInputs output;
                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                    #ifdef HAVE_VFX_MODIFICATION
                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                    #endif







                                                        output.WorldSpacePosition = input.positionWS;
                                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                    #else
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                    #endif
                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                            return output;
                                                    }

                                                    // --------------------------------------------------
                                                    // Main

                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                    // --------------------------------------------------
                                                    // Visual Effect Vertex Invocations
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                    #endif

                                                    ENDHLSL
                                                    }
                                                    Pass
                                                    {
                                                        Name "ScenePickingPass"
                                                        Tags
                                                        {
                                                            "LightMode" = "Picking"
                                                        }

                                                        // Render State
                                                        Cull Back

                                                        // Debug
                                                        // <None>

                                                        // --------------------------------------------------
                                                        // Pass

                                                        HLSLPROGRAM

                                                        // Pragmas
                                                        #pragma target 4.5
                                                        #pragma exclude_renderers gles gles3 glcore
                                                        #pragma vertex vert
                                                        #pragma fragment frag

                                                        // DotsInstancingOptions: <None>
                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                        // Keywords
                                                        // PassKeywords: <None>
                                                        // GraphKeywords: <None>

                                                        // Defines

                                                        #define _NORMALMAP 1
                                                        #define _NORMAL_DROPOFF_TS 1
                                                        #define ATTRIBUTES_NEED_NORMAL
                                                        #define ATTRIBUTES_NEED_TANGENT
                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                        #define VARYINGS_NEED_POSITION_WS
                                                        #define FEATURES_GRAPH_VERTEX
                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                        #define SHADERPASS SHADERPASS_DEPTHONLY
                                                        #define SCENEPICKINGPASS 1
                                                        #define ALPHA_CLIP_THRESHOLD 1
                                                        #define REQUIRE_DEPTH_TEXTURE
                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                        // custom interpolator pre-include
                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                        // Includes
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                        // --------------------------------------------------
                                                        // Structs and Packing

                                                        // custom interpolators pre packing
                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                        struct Attributes
                                                        {
                                                             float3 positionOS : POSITION;
                                                             float3 normalOS : NORMAL;
                                                             float4 tangentOS : TANGENT;
                                                             float4 uv0 : TEXCOORD0;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct Varyings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                             float3 positionWS;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct SurfaceDescriptionInputs
                                                        {
                                                             float3 WorldSpacePosition;
                                                             float4 ScreenPosition;
                                                        };
                                                        struct VertexDescriptionInputs
                                                        {
                                                             float3 ObjectSpaceNormal;
                                                             float3 ObjectSpaceTangent;
                                                             float3 ObjectSpacePosition;
                                                             float4 uv0;
                                                             float3 TimeParameters;
                                                        };
                                                        struct PackedVaryings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                             float3 interp0 : INTERP0;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };

                                                        PackedVaryings PackVaryings(Varyings input)
                                                        {
                                                            PackedVaryings output;
                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                            output.positionCS = input.positionCS;
                                                            output.interp0.xyz = input.positionWS;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }

                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                        {
                                                            Varyings output;
                                                            output.positionCS = input.positionCS;
                                                            output.positionWS = input.interp0.xyz;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }


                                                        // --------------------------------------------------
                                                        // Graph

                                                        // Graph Properties
                                                        CBUFFER_START(UnityPerMaterial)
                                                        float _Depth;
                                                        float _Strength;
                                                        float4 _DeepWaterColor;
                                                        float4 _ShallowWaterColor;
                                                        float4 _MainNormal_TexelSize;
                                                        float4 _SecondNormal_TexelSize;
                                                        float _NormalStrength;
                                                        float _Smoothness;
                                                        float _Displacement;
                                                        CBUFFER_END

                                                            // Object and Global properties
                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                            TEXTURE2D(_MainNormal);
                                                            SAMPLER(sampler_MainNormal);
                                                            TEXTURE2D(_SecondNormal);
                                                            SAMPLER(sampler_SecondNormal);

                                                            // Graph Includes
                                                            // GraphIncludes: <None>

                                                            // -- Property used by ScenePickingPass
                                                            #ifdef SCENEPICKINGPASS
                                                            float4 _SelectionID;
                                                            #endif

                                                            // -- Properties used by SceneSelectionPass
                                                            #ifdef SCENESELECTIONPASS
                                                            int _ObjectId;
                                                            int _PassValue;
                                                            #endif

                                                            // Graph Functions

                                                            void Unity_Divide_float(float A, float B, out float Out)
                                                            {
                                                                Out = A / B;
                                                            }

                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                            {
                                                                Out = UV * Tiling + Offset;
                                                            }


                                                            float2 Unity_GradientNoise_Dir_float(float2 p)
                                                            {
                                                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                p = p % 289;
                                                                // need full precision, otherwise half overflows when p > 1
                                                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                x = (34 * x + 1) * x % 289;
                                                                x = frac(x / 41) * 2 - 1;
                                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                            }

                                                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                            {
                                                                float2 p = UV * Scale;
                                                                float2 ip = floor(p);
                                                                float2 fp = frac(p);
                                                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                            }

                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                            {
                                                                Out = A * B;
                                                            }

                                                            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                                            {
                                                                RGBA = float4(R, G, B, A);
                                                                RGB = float3(R, G, B);
                                                                RG = float2(R, G);
                                                            }

                                                            void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                                                            {
                                                                Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                                            }

                                                            void Unity_Add_float(float A, float B, out float Out)
                                                            {
                                                                Out = A + B;
                                                            }

                                                            void Unity_Subtract_float(float A, float B, out float Out)
                                                            {
                                                                Out = A - B;
                                                            }

                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                            {
                                                                Out = clamp(In, Min, Max);
                                                            }

                                                            void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                                            {
                                                                Out = lerp(A, B, T);
                                                            }

                                                            // Custom interpolators pre vertex
                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                            // Graph Vertex
                                                            struct VertexDescription
                                                            {
                                                                float3 Position;
                                                                float3 Normal;
                                                                float3 Tangent;
                                                            };

                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                            {
                                                                VertexDescription description = (VertexDescription)0;
                                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_R_1 = IN.ObjectSpacePosition[0];
                                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_G_2 = IN.ObjectSpacePosition[1];
                                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_B_3 = IN.ObjectSpacePosition[2];
                                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_A_4 = 0;
                                                                float _Property_2aee0f2c381447299717226883b9dd5e_Out_0 = _Displacement;
                                                                float _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2;
                                                                Unity_Divide_float(IN.TimeParameters.x, 50, _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2);
                                                                float2 _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3;
                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_0347d994cff649cca9eb90763a4ce74a_Out_2.xx), _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3);
                                                                float _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2;
                                                                Unity_GradientNoise_float(_TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3, 20, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2);
                                                                float _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2;
                                                                Unity_Multiply_float_float(_Property_2aee0f2c381447299717226883b9dd5e_Out_0, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2);
                                                                float4 _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4;
                                                                float3 _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                                float2 _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6;
                                                                Unity_Combine_float(_Split_5a46fb254a6548d9a32e712a81235ca4_R_1, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2, _Split_5a46fb254a6548d9a32e712a81235ca4_B_3, 0, _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4, _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5, _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6);
                                                                description.Position = _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                return description;
                                                            }

                                                            // Custom interpolators, pre surface
                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                            {
                                                            return output;
                                                            }
                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                            #endif

                                                            // Graph Pixel
                                                            struct SurfaceDescription
                                                            {
                                                                float Alpha;
                                                            };

                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                            {
                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                float4 _Property_f669795152fd4d83bfe0251a331b5e7e_Out_0 = _ShallowWaterColor;
                                                                float4 _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0 = _DeepWaterColor;
                                                                float _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1;
                                                                Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1);
                                                                float _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2;
                                                                Unity_Multiply_float_float(_SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1, _ProjectionParams.z, _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2);
                                                                float4 _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0 = IN.ScreenPosition;
                                                                float _Split_fabee40938d249f58c6df289b29487e6_R_1 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[0];
                                                                float _Split_fabee40938d249f58c6df289b29487e6_G_2 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[1];
                                                                float _Split_fabee40938d249f58c6df289b29487e6_B_3 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[2];
                                                                float _Split_fabee40938d249f58c6df289b29487e6_A_4 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[3];
                                                                float _Property_b835ed47772e498ca3bfd0304467564a_Out_0 = _Depth;
                                                                float _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2;
                                                                Unity_Add_float(_Split_fabee40938d249f58c6df289b29487e6_A_4, _Property_b835ed47772e498ca3bfd0304467564a_Out_0, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2);
                                                                float _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2;
                                                                Unity_Subtract_float(_Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2, _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2);
                                                                float _Property_d4102fc229a94768ae4a93daed7fd849_Out_0 = _Strength;
                                                                float _Multiply_c032a0c444d84300a760598cbea78a62_Out_2;
                                                                Unity_Multiply_float_float(_Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2, _Property_d4102fc229a94768ae4a93daed7fd849_Out_0, _Multiply_c032a0c444d84300a760598cbea78a62_Out_2);
                                                                float _Clamp_e8c5093ba9604977add70348fe2134be_Out_3;
                                                                Unity_Clamp_float(_Multiply_c032a0c444d84300a760598cbea78a62_Out_2, 0, 1, _Clamp_e8c5093ba9604977add70348fe2134be_Out_3);
                                                                float4 _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3;
                                                                Unity_Lerp_float4(_Property_f669795152fd4d83bfe0251a331b5e7e_Out_0, _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0, (_Clamp_e8c5093ba9604977add70348fe2134be_Out_3.xxxx), _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3);
                                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_R_1 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[0];
                                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_G_2 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[1];
                                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_B_3 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[2];
                                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[3];
                                                                surface.Alpha = _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4;
                                                                return surface;
                                                            }

                                                            // --------------------------------------------------
                                                            // Build Graph Inputs
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                            #define VFX_SRP_VARYINGS Varyings
                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                            #endif
                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                            {
                                                                VertexDescriptionInputs output;
                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                output.ObjectSpacePosition = input.positionOS;
                                                                output.uv0 = input.uv0;
                                                                output.TimeParameters = _TimeParameters.xyz;

                                                                return output;
                                                            }
                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                            {
                                                                SurfaceDescriptionInputs output;
                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                            #endif







                                                                output.WorldSpacePosition = input.positionWS;
                                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                            #else
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                            #endif
                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                    return output;
                                                            }

                                                            // --------------------------------------------------
                                                            // Main

                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                            // --------------------------------------------------
                                                            // Visual Effect Vertex Invocations
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                            #endif

                                                            ENDHLSL
                                                            }
                                                            Pass
                                                            {
                                                                // Name: <None>
                                                                Tags
                                                                {
                                                                    "LightMode" = "Universal2D"
                                                                }

                                                                // Render State
                                                                Cull Back
                                                                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                                                ZTest LEqual
                                                                ZWrite Off

                                                                // Debug
                                                                // <None>

                                                                // --------------------------------------------------
                                                                // Pass

                                                                HLSLPROGRAM

                                                                // Pragmas
                                                                #pragma target 4.5
                                                                #pragma exclude_renderers gles gles3 glcore
                                                                #pragma vertex vert
                                                                #pragma fragment frag

                                                                // DotsInstancingOptions: <None>
                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                // Keywords
                                                                // PassKeywords: <None>
                                                                // GraphKeywords: <None>

                                                                // Defines

                                                                #define _NORMALMAP 1
                                                                #define _NORMAL_DROPOFF_TS 1
                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                #define VARYINGS_NEED_POSITION_WS
                                                                #define FEATURES_GRAPH_VERTEX
                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                #define SHADERPASS SHADERPASS_2D
                                                                #define REQUIRE_DEPTH_TEXTURE
                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                // custom interpolator pre-include
                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                // Includes
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                // --------------------------------------------------
                                                                // Structs and Packing

                                                                // custom interpolators pre packing
                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                struct Attributes
                                                                {
                                                                     float3 positionOS : POSITION;
                                                                     float3 normalOS : NORMAL;
                                                                     float4 tangentOS : TANGENT;
                                                                     float4 uv0 : TEXCOORD0;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct Varyings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                     float3 positionWS;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct SurfaceDescriptionInputs
                                                                {
                                                                     float3 WorldSpacePosition;
                                                                     float4 ScreenPosition;
                                                                };
                                                                struct VertexDescriptionInputs
                                                                {
                                                                     float3 ObjectSpaceNormal;
                                                                     float3 ObjectSpaceTangent;
                                                                     float3 ObjectSpacePosition;
                                                                     float4 uv0;
                                                                     float3 TimeParameters;
                                                                };
                                                                struct PackedVaryings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                     float3 interp0 : INTERP0;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };

                                                                PackedVaryings PackVaryings(Varyings input)
                                                                {
                                                                    PackedVaryings output;
                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                    output.positionCS = input.positionCS;
                                                                    output.interp0.xyz = input.positionWS;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }

                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                {
                                                                    Varyings output;
                                                                    output.positionCS = input.positionCS;
                                                                    output.positionWS = input.interp0.xyz;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }


                                                                // --------------------------------------------------
                                                                // Graph

                                                                // Graph Properties
                                                                CBUFFER_START(UnityPerMaterial)
                                                                float _Depth;
                                                                float _Strength;
                                                                float4 _DeepWaterColor;
                                                                float4 _ShallowWaterColor;
                                                                float4 _MainNormal_TexelSize;
                                                                float4 _SecondNormal_TexelSize;
                                                                float _NormalStrength;
                                                                float _Smoothness;
                                                                float _Displacement;
                                                                CBUFFER_END

                                                                    // Object and Global properties
                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                    TEXTURE2D(_MainNormal);
                                                                    SAMPLER(sampler_MainNormal);
                                                                    TEXTURE2D(_SecondNormal);
                                                                    SAMPLER(sampler_SecondNormal);

                                                                    // Graph Includes
                                                                    // GraphIncludes: <None>

                                                                    // -- Property used by ScenePickingPass
                                                                    #ifdef SCENEPICKINGPASS
                                                                    float4 _SelectionID;
                                                                    #endif

                                                                    // -- Properties used by SceneSelectionPass
                                                                    #ifdef SCENESELECTIONPASS
                                                                    int _ObjectId;
                                                                    int _PassValue;
                                                                    #endif

                                                                    // Graph Functions

                                                                    void Unity_Divide_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A / B;
                                                                    }

                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                    {
                                                                        Out = UV * Tiling + Offset;
                                                                    }


                                                                    float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                    {
                                                                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                        p = p % 289;
                                                                        // need full precision, otherwise half overflows when p > 1
                                                                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                        x = (34 * x + 1) * x % 289;
                                                                        x = frac(x / 41) * 2 - 1;
                                                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                    }

                                                                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                    {
                                                                        float2 p = UV * Scale;
                                                                        float2 ip = floor(p);
                                                                        float2 fp = frac(p);
                                                                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                    }

                                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A * B;
                                                                    }

                                                                    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                                                    {
                                                                        RGBA = float4(R, G, B, A);
                                                                        RGB = float3(R, G, B);
                                                                        RG = float2(R, G);
                                                                    }

                                                                    void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                                                                    {
                                                                        Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                                                    }

                                                                    void Unity_Add_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A + B;
                                                                    }

                                                                    void Unity_Subtract_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A - B;
                                                                    }

                                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                    {
                                                                        Out = clamp(In, Min, Max);
                                                                    }

                                                                    void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                                                    {
                                                                        Out = lerp(A, B, T);
                                                                    }

                                                                    // Custom interpolators pre vertex
                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                    // Graph Vertex
                                                                    struct VertexDescription
                                                                    {
                                                                        float3 Position;
                                                                        float3 Normal;
                                                                        float3 Tangent;
                                                                    };

                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                    {
                                                                        VertexDescription description = (VertexDescription)0;
                                                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_R_1 = IN.ObjectSpacePosition[0];
                                                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_G_2 = IN.ObjectSpacePosition[1];
                                                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_B_3 = IN.ObjectSpacePosition[2];
                                                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_A_4 = 0;
                                                                        float _Property_2aee0f2c381447299717226883b9dd5e_Out_0 = _Displacement;
                                                                        float _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2;
                                                                        Unity_Divide_float(IN.TimeParameters.x, 50, _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2);
                                                                        float2 _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3;
                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_0347d994cff649cca9eb90763a4ce74a_Out_2.xx), _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3);
                                                                        float _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2;
                                                                        Unity_GradientNoise_float(_TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3, 20, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2);
                                                                        float _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2;
                                                                        Unity_Multiply_float_float(_Property_2aee0f2c381447299717226883b9dd5e_Out_0, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2);
                                                                        float4 _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4;
                                                                        float3 _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                                        float2 _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6;
                                                                        Unity_Combine_float(_Split_5a46fb254a6548d9a32e712a81235ca4_R_1, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2, _Split_5a46fb254a6548d9a32e712a81235ca4_B_3, 0, _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4, _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5, _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6);
                                                                        description.Position = _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                        return description;
                                                                    }

                                                                    // Custom interpolators, pre surface
                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                    {
                                                                    return output;
                                                                    }
                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                    #endif

                                                                    // Graph Pixel
                                                                    struct SurfaceDescription
                                                                    {
                                                                        float3 BaseColor;
                                                                        float Alpha;
                                                                    };

                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                    {
                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                        float4 _Property_f669795152fd4d83bfe0251a331b5e7e_Out_0 = _ShallowWaterColor;
                                                                        float4 _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0 = _DeepWaterColor;
                                                                        float _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1;
                                                                        Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1);
                                                                        float _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2;
                                                                        Unity_Multiply_float_float(_SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1, _ProjectionParams.z, _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2);
                                                                        float4 _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0 = IN.ScreenPosition;
                                                                        float _Split_fabee40938d249f58c6df289b29487e6_R_1 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[0];
                                                                        float _Split_fabee40938d249f58c6df289b29487e6_G_2 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[1];
                                                                        float _Split_fabee40938d249f58c6df289b29487e6_B_3 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[2];
                                                                        float _Split_fabee40938d249f58c6df289b29487e6_A_4 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[3];
                                                                        float _Property_b835ed47772e498ca3bfd0304467564a_Out_0 = _Depth;
                                                                        float _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2;
                                                                        Unity_Add_float(_Split_fabee40938d249f58c6df289b29487e6_A_4, _Property_b835ed47772e498ca3bfd0304467564a_Out_0, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2);
                                                                        float _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2;
                                                                        Unity_Subtract_float(_Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2, _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2);
                                                                        float _Property_d4102fc229a94768ae4a93daed7fd849_Out_0 = _Strength;
                                                                        float _Multiply_c032a0c444d84300a760598cbea78a62_Out_2;
                                                                        Unity_Multiply_float_float(_Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2, _Property_d4102fc229a94768ae4a93daed7fd849_Out_0, _Multiply_c032a0c444d84300a760598cbea78a62_Out_2);
                                                                        float _Clamp_e8c5093ba9604977add70348fe2134be_Out_3;
                                                                        Unity_Clamp_float(_Multiply_c032a0c444d84300a760598cbea78a62_Out_2, 0, 1, _Clamp_e8c5093ba9604977add70348fe2134be_Out_3);
                                                                        float4 _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3;
                                                                        Unity_Lerp_float4(_Property_f669795152fd4d83bfe0251a331b5e7e_Out_0, _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0, (_Clamp_e8c5093ba9604977add70348fe2134be_Out_3.xxxx), _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3);
                                                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_R_1 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[0];
                                                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_G_2 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[1];
                                                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_B_3 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[2];
                                                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[3];
                                                                        surface.BaseColor = (_Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3.xyz);
                                                                        surface.Alpha = _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4;
                                                                        return surface;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Build Graph Inputs
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                    #endif
                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                    {
                                                                        VertexDescriptionInputs output;
                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                        output.ObjectSpacePosition = input.positionOS;
                                                                        output.uv0 = input.uv0;
                                                                        output.TimeParameters = _TimeParameters.xyz;

                                                                        return output;
                                                                    }
                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                    {
                                                                        SurfaceDescriptionInputs output;
                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                    #endif







                                                                        output.WorldSpacePosition = input.positionWS;
                                                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                    #else
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                    #endif
                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                            return output;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Main

                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                                    // --------------------------------------------------
                                                                    // Visual Effect Vertex Invocations
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                    #endif

                                                                    ENDHLSL
                                                                    }
    }
        SubShader
                                                                    {
                                                                        Tags
                                                                        {
                                                                            "RenderPipeline" = "UniversalPipeline"
                                                                            "RenderType" = "Transparent"
                                                                            "UniversalMaterialType" = "Lit"
                                                                            "Queue" = "Transparent"
                                                                            "ShaderGraphShader" = "true"
                                                                            "ShaderGraphTargetId" = "UniversalLitSubTarget"
                                                                        }
                                                                        Pass
                                                                        {
                                                                            Name "Universal Forward"
                                                                            Tags
                                                                            {
                                                                                "LightMode" = "UniversalForward"
                                                                            }

                                                                        // Render State
                                                                        Cull Back
                                                                        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                                                        ZTest LEqual
                                                                        ZWrite Off

                                                                        // Debug
                                                                        // <None>

                                                                        // --------------------------------------------------
                                                                        // Pass

                                                                        HLSLPROGRAM

                                                                        // Pragmas
                                                                        #pragma target 2.0
                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                        #pragma multi_compile_instancing
                                                                        #pragma multi_compile_fog
                                                                        #pragma instancing_options renderinglayer
                                                                        #pragma vertex vert
                                                                        #pragma fragment frag

                                                                        // DotsInstancingOptions: <None>
                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                        // Keywords
                                                                        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
                                                                        #pragma multi_compile _ LIGHTMAP_ON
                                                                        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                                                                        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                                                                        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                                                                        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
                                                                        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
                                                                        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                                                                        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                                                                        #pragma multi_compile_fragment _ _SHADOWS_SOFT
                                                                        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                                                                        #pragma multi_compile _ SHADOWS_SHADOWMASK
                                                                        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                                                                        #pragma multi_compile_fragment _ _LIGHT_LAYERS
                                                                        #pragma multi_compile_fragment _ DEBUG_DISPLAY
                                                                        #pragma multi_compile_fragment _ _LIGHT_COOKIES
                                                                        #pragma multi_compile _ _CLUSTERED_RENDERING
                                                                        // GraphKeywords: <None>

                                                                        // Defines

                                                                        #define _NORMALMAP 1
                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                                                        #define ATTRIBUTES_NEED_TEXCOORD2
                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                        #define VARYINGS_NEED_TANGENT_WS
                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                        #define VARYINGS_NEED_VIEWDIRECTION_WS
                                                                        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                        #define VARYINGS_NEED_SHADOW_COORD
                                                                        #define FEATURES_GRAPH_VERTEX
                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                        #define SHADERPASS SHADERPASS_FORWARD
                                                                        #define _FOG_FRAGMENT 1
                                                                        #define _SURFACE_TYPE_TRANSPARENT 1
                                                                        #define REQUIRE_DEPTH_TEXTURE
                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                        // custom interpolator pre-include
                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                        // Includes
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                        // --------------------------------------------------
                                                                        // Structs and Packing

                                                                        // custom interpolators pre packing
                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                        struct Attributes
                                                                        {
                                                                             float3 positionOS : POSITION;
                                                                             float3 normalOS : NORMAL;
                                                                             float4 tangentOS : TANGENT;
                                                                             float4 uv0 : TEXCOORD0;
                                                                             float4 uv1 : TEXCOORD1;
                                                                             float4 uv2 : TEXCOORD2;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct Varyings
                                                                        {
                                                                             float4 positionCS : SV_POSITION;
                                                                             float3 positionWS;
                                                                             float3 normalWS;
                                                                             float4 tangentWS;
                                                                             float4 texCoord0;
                                                                             float3 viewDirectionWS;
                                                                            #if defined(LIGHTMAP_ON)
                                                                             float2 staticLightmapUV;
                                                                            #endif
                                                                            #if defined(DYNAMICLIGHTMAP_ON)
                                                                             float2 dynamicLightmapUV;
                                                                            #endif
                                                                            #if !defined(LIGHTMAP_ON)
                                                                             float3 sh;
                                                                            #endif
                                                                             float4 fogFactorAndVertexLight;
                                                                            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                             float4 shadowCoord;
                                                                            #endif
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct SurfaceDescriptionInputs
                                                                        {
                                                                             float3 TangentSpaceNormal;
                                                                             float3 WorldSpacePosition;
                                                                             float4 ScreenPosition;
                                                                             float4 uv0;
                                                                             float3 TimeParameters;
                                                                        };
                                                                        struct VertexDescriptionInputs
                                                                        {
                                                                             float3 ObjectSpaceNormal;
                                                                             float3 ObjectSpaceTangent;
                                                                             float3 ObjectSpacePosition;
                                                                             float4 uv0;
                                                                             float3 TimeParameters;
                                                                        };
                                                                        struct PackedVaryings
                                                                        {
                                                                             float4 positionCS : SV_POSITION;
                                                                             float3 interp0 : INTERP0;
                                                                             float3 interp1 : INTERP1;
                                                                             float4 interp2 : INTERP2;
                                                                             float4 interp3 : INTERP3;
                                                                             float3 interp4 : INTERP4;
                                                                             float2 interp5 : INTERP5;
                                                                             float2 interp6 : INTERP6;
                                                                             float3 interp7 : INTERP7;
                                                                             float4 interp8 : INTERP8;
                                                                             float4 interp9 : INTERP9;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };

                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                        {
                                                                            PackedVaryings output;
                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                            output.positionCS = input.positionCS;
                                                                            output.interp0.xyz = input.positionWS;
                                                                            output.interp1.xyz = input.normalWS;
                                                                            output.interp2.xyzw = input.tangentWS;
                                                                            output.interp3.xyzw = input.texCoord0;
                                                                            output.interp4.xyz = input.viewDirectionWS;
                                                                            #if defined(LIGHTMAP_ON)
                                                                            output.interp5.xy = input.staticLightmapUV;
                                                                            #endif
                                                                            #if defined(DYNAMICLIGHTMAP_ON)
                                                                            output.interp6.xy = input.dynamicLightmapUV;
                                                                            #endif
                                                                            #if !defined(LIGHTMAP_ON)
                                                                            output.interp7.xyz = input.sh;
                                                                            #endif
                                                                            output.interp8.xyzw = input.fogFactorAndVertexLight;
                                                                            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                            output.interp9.xyzw = input.shadowCoord;
                                                                            #endif
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }

                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                        {
                                                                            Varyings output;
                                                                            output.positionCS = input.positionCS;
                                                                            output.positionWS = input.interp0.xyz;
                                                                            output.normalWS = input.interp1.xyz;
                                                                            output.tangentWS = input.interp2.xyzw;
                                                                            output.texCoord0 = input.interp3.xyzw;
                                                                            output.viewDirectionWS = input.interp4.xyz;
                                                                            #if defined(LIGHTMAP_ON)
                                                                            output.staticLightmapUV = input.interp5.xy;
                                                                            #endif
                                                                            #if defined(DYNAMICLIGHTMAP_ON)
                                                                            output.dynamicLightmapUV = input.interp6.xy;
                                                                            #endif
                                                                            #if !defined(LIGHTMAP_ON)
                                                                            output.sh = input.interp7.xyz;
                                                                            #endif
                                                                            output.fogFactorAndVertexLight = input.interp8.xyzw;
                                                                            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                                                                            output.shadowCoord = input.interp9.xyzw;
                                                                            #endif
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }


                                                                        // --------------------------------------------------
                                                                        // Graph

                                                                        // Graph Properties
                                                                        CBUFFER_START(UnityPerMaterial)
                                                                        float _Depth;
                                                                        float _Strength;
                                                                        float4 _DeepWaterColor;
                                                                        float4 _ShallowWaterColor;
                                                                        float4 _MainNormal_TexelSize;
                                                                        float4 _SecondNormal_TexelSize;
                                                                        float _NormalStrength;
                                                                        float _Smoothness;
                                                                        float _Displacement;
                                                                        CBUFFER_END

                                                                            // Object and Global properties
                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                            TEXTURE2D(_MainNormal);
                                                                            SAMPLER(sampler_MainNormal);
                                                                            TEXTURE2D(_SecondNormal);
                                                                            SAMPLER(sampler_SecondNormal);

                                                                            // Graph Includes
                                                                            // GraphIncludes: <None>

                                                                            // -- Property used by ScenePickingPass
                                                                            #ifdef SCENEPICKINGPASS
                                                                            float4 _SelectionID;
                                                                            #endif

                                                                            // -- Properties used by SceneSelectionPass
                                                                            #ifdef SCENESELECTIONPASS
                                                                            int _ObjectId;
                                                                            int _PassValue;
                                                                            #endif

                                                                            // Graph Functions

                                                                            void Unity_Divide_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A / B;
                                                                            }

                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                            {
                                                                                Out = UV * Tiling + Offset;
                                                                            }


                                                                            float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                            {
                                                                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                                p = p % 289;
                                                                                // need full precision, otherwise half overflows when p > 1
                                                                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                                x = (34 * x + 1) * x % 289;
                                                                                x = frac(x / 41) * 2 - 1;
                                                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                            }

                                                                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                            {
                                                                                float2 p = UV * Scale;
                                                                                float2 ip = floor(p);
                                                                                float2 fp = frac(p);
                                                                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                            }

                                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                                                            {
                                                                                RGBA = float4(R, G, B, A);
                                                                                RGB = float3(R, G, B);
                                                                                RG = float2(R, G);
                                                                            }

                                                                            void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                                                                            {
                                                                                Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                                                            }

                                                                            void Unity_Add_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A + B;
                                                                            }

                                                                            void Unity_Subtract_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A - B;
                                                                            }

                                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                            {
                                                                                Out = clamp(In, Min, Max);
                                                                            }

                                                                            void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                                                            {
                                                                                Out = lerp(A, B, T);
                                                                            }

                                                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                            {
                                                                                Out = A + B;
                                                                            }

                                                                            void Unity_Lerp_float(float A, float B, float T, out float Out)
                                                                            {
                                                                                Out = lerp(A, B, T);
                                                                            }

                                                                            void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
                                                                            {
                                                                                Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
                                                                            }

                                                                            // Custom interpolators pre vertex
                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                            // Graph Vertex
                                                                            struct VertexDescription
                                                                            {
                                                                                float3 Position;
                                                                                float3 Normal;
                                                                                float3 Tangent;
                                                                            };

                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                            {
                                                                                VertexDescription description = (VertexDescription)0;
                                                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_R_1 = IN.ObjectSpacePosition[0];
                                                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_G_2 = IN.ObjectSpacePosition[1];
                                                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_B_3 = IN.ObjectSpacePosition[2];
                                                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_A_4 = 0;
                                                                                float _Property_2aee0f2c381447299717226883b9dd5e_Out_0 = _Displacement;
                                                                                float _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2;
                                                                                Unity_Divide_float(IN.TimeParameters.x, 50, _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2);
                                                                                float2 _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3;
                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_0347d994cff649cca9eb90763a4ce74a_Out_2.xx), _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3);
                                                                                float _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2;
                                                                                Unity_GradientNoise_float(_TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3, 20, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2);
                                                                                float _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2;
                                                                                Unity_Multiply_float_float(_Property_2aee0f2c381447299717226883b9dd5e_Out_0, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2);
                                                                                float4 _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4;
                                                                                float3 _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                                                float2 _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6;
                                                                                Unity_Combine_float(_Split_5a46fb254a6548d9a32e712a81235ca4_R_1, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2, _Split_5a46fb254a6548d9a32e712a81235ca4_B_3, 0, _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4, _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5, _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6);
                                                                                description.Position = _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                return description;
                                                                            }

                                                                            // Custom interpolators, pre surface
                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                            {
                                                                            return output;
                                                                            }
                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                            #endif

                                                                            // Graph Pixel
                                                                            struct SurfaceDescription
                                                                            {
                                                                                float3 BaseColor;
                                                                                float3 NormalTS;
                                                                                float3 Emission;
                                                                                float Metallic;
                                                                                float Smoothness;
                                                                                float Occlusion;
                                                                                float Alpha;
                                                                            };

                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                            {
                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                float4 _Property_f669795152fd4d83bfe0251a331b5e7e_Out_0 = _ShallowWaterColor;
                                                                                float4 _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0 = _DeepWaterColor;
                                                                                float _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1;
                                                                                Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1);
                                                                                float _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2;
                                                                                Unity_Multiply_float_float(_SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1, _ProjectionParams.z, _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2);
                                                                                float4 _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0 = IN.ScreenPosition;
                                                                                float _Split_fabee40938d249f58c6df289b29487e6_R_1 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[0];
                                                                                float _Split_fabee40938d249f58c6df289b29487e6_G_2 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[1];
                                                                                float _Split_fabee40938d249f58c6df289b29487e6_B_3 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[2];
                                                                                float _Split_fabee40938d249f58c6df289b29487e6_A_4 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[3];
                                                                                float _Property_b835ed47772e498ca3bfd0304467564a_Out_0 = _Depth;
                                                                                float _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2;
                                                                                Unity_Add_float(_Split_fabee40938d249f58c6df289b29487e6_A_4, _Property_b835ed47772e498ca3bfd0304467564a_Out_0, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2);
                                                                                float _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2;
                                                                                Unity_Subtract_float(_Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2, _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2);
                                                                                float _Property_d4102fc229a94768ae4a93daed7fd849_Out_0 = _Strength;
                                                                                float _Multiply_c032a0c444d84300a760598cbea78a62_Out_2;
                                                                                Unity_Multiply_float_float(_Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2, _Property_d4102fc229a94768ae4a93daed7fd849_Out_0, _Multiply_c032a0c444d84300a760598cbea78a62_Out_2);
                                                                                float _Clamp_e8c5093ba9604977add70348fe2134be_Out_3;
                                                                                Unity_Clamp_float(_Multiply_c032a0c444d84300a760598cbea78a62_Out_2, 0, 1, _Clamp_e8c5093ba9604977add70348fe2134be_Out_3);
                                                                                float4 _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3;
                                                                                Unity_Lerp_float4(_Property_f669795152fd4d83bfe0251a331b5e7e_Out_0, _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0, (_Clamp_e8c5093ba9604977add70348fe2134be_Out_3.xxxx), _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3);
                                                                                UnityTexture2D _Property_53020a2b9cbe4b6a83ad0a9fee0558e8_Out_0 = UnityBuildTexture2DStructNoScale(_MainNormal);
                                                                                float _Divide_ee7923a88d6f4b1a9e8dbe5bfbb29685_Out_2;
                                                                                Unity_Divide_float(IN.TimeParameters.x, 50, _Divide_ee7923a88d6f4b1a9e8dbe5bfbb29685_Out_2);
                                                                                float2 _TilingAndOffset_a535553689a34d399e1a65691ca9aa39_Out_3;
                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (10, 10), (_Divide_ee7923a88d6f4b1a9e8dbe5bfbb29685_Out_2.xx), _TilingAndOffset_a535553689a34d399e1a65691ca9aa39_Out_3);
                                                                                float4 _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0 = SAMPLE_TEXTURE2D(_Property_53020a2b9cbe4b6a83ad0a9fee0558e8_Out_0.tex, _Property_53020a2b9cbe4b6a83ad0a9fee0558e8_Out_0.samplerstate, _Property_53020a2b9cbe4b6a83ad0a9fee0558e8_Out_0.GetTransformedUV(_TilingAndOffset_a535553689a34d399e1a65691ca9aa39_Out_3));
                                                                                _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0);
                                                                                float _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_R_4 = _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.r;
                                                                                float _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_G_5 = _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.g;
                                                                                float _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_B_6 = _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.b;
                                                                                float _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_A_7 = _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.a;
                                                                                UnityTexture2D _Property_2c235836e5664098bdb6fb2809be4539_Out_0 = UnityBuildTexture2DStructNoScale(_SecondNormal);
                                                                                float _Divide_5d7c40eba84948c2b427b4bc6c71a9b0_Out_2;
                                                                                Unity_Divide_float(IN.TimeParameters.x, -10, _Divide_5d7c40eba84948c2b427b4bc6c71a9b0_Out_2);
                                                                                float2 _TilingAndOffset_cca530b5dccb4ec0a00dd9aff0e156e2_Out_3;
                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (10, 10), (_Divide_5d7c40eba84948c2b427b4bc6c71a9b0_Out_2.xx), _TilingAndOffset_cca530b5dccb4ec0a00dd9aff0e156e2_Out_3);
                                                                                float4 _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0 = SAMPLE_TEXTURE2D(_Property_2c235836e5664098bdb6fb2809be4539_Out_0.tex, _Property_2c235836e5664098bdb6fb2809be4539_Out_0.samplerstate, _Property_2c235836e5664098bdb6fb2809be4539_Out_0.GetTransformedUV(_TilingAndOffset_cca530b5dccb4ec0a00dd9aff0e156e2_Out_3));
                                                                                _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0);
                                                                                float _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_R_4 = _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.r;
                                                                                float _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_G_5 = _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.g;
                                                                                float _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_B_6 = _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.b;
                                                                                float _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_A_7 = _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.a;
                                                                                float4 _Add_9b2536bd6bce45d4916943d980d7fc3f_Out_2;
                                                                                Unity_Add_float4(_SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0, _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0, _Add_9b2536bd6bce45d4916943d980d7fc3f_Out_2);
                                                                                float _Property_a5190d1ea56040d29725d71fd10fc2ff_Out_0 = _NormalStrength;
                                                                                float _Lerp_1b3da68c18ce4ab6b9781c9955aaa9ee_Out_3;
                                                                                Unity_Lerp_float(0, _Property_a5190d1ea56040d29725d71fd10fc2ff_Out_0, _Clamp_e8c5093ba9604977add70348fe2134be_Out_3, _Lerp_1b3da68c18ce4ab6b9781c9955aaa9ee_Out_3);
                                                                                float3 _NormalStrength_36f00e1d555c491bb0ed1d778d4eef29_Out_2;
                                                                                Unity_NormalStrength_float((_Add_9b2536bd6bce45d4916943d980d7fc3f_Out_2.xyz), _Lerp_1b3da68c18ce4ab6b9781c9955aaa9ee_Out_3, _NormalStrength_36f00e1d555c491bb0ed1d778d4eef29_Out_2);
                                                                                float _Property_15666cb92fb2412da792f74efe747b9b_Out_0 = _Smoothness;
                                                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_R_1 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[0];
                                                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_G_2 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[1];
                                                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_B_3 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[2];
                                                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[3];
                                                                                surface.BaseColor = (_Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3.xyz);
                                                                                surface.NormalTS = _NormalStrength_36f00e1d555c491bb0ed1d778d4eef29_Out_2;
                                                                                surface.Emission = float3(0, 0, 0);
                                                                                surface.Metallic = 0;
                                                                                surface.Smoothness = _Property_15666cb92fb2412da792f74efe747b9b_Out_0;
                                                                                surface.Occlusion = 1;
                                                                                surface.Alpha = _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4;
                                                                                return surface;
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Build Graph Inputs
                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                            #endif
                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                            {
                                                                                VertexDescriptionInputs output;
                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                output.ObjectSpacePosition = input.positionOS;
                                                                                output.uv0 = input.uv0;
                                                                                output.TimeParameters = _TimeParameters.xyz;

                                                                                return output;
                                                                            }
                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                            {
                                                                                SurfaceDescriptionInputs output;
                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                            #endif





                                                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                                                output.WorldSpacePosition = input.positionWS;
                                                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                output.uv0 = input.texCoord0;
                                                                                output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                            #else
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                            #endif
                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                    return output;
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Main

                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

                                                                            // --------------------------------------------------
                                                                            // Visual Effect Vertex Invocations
                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                            #endif

                                                                            ENDHLSL
                                                                            }
                                                                            Pass
                                                                            {
                                                                                Name "ShadowCaster"
                                                                                Tags
                                                                                {
                                                                                    "LightMode" = "ShadowCaster"
                                                                                }

                                                                                // Render State
                                                                                Cull Back
                                                                                ZTest LEqual
                                                                                ZWrite On
                                                                                ColorMask 0

                                                                                // Debug
                                                                                // <None>

                                                                                // --------------------------------------------------
                                                                                // Pass

                                                                                HLSLPROGRAM

                                                                                // Pragmas
                                                                                #pragma target 2.0
                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                #pragma multi_compile_instancing
                                                                                #pragma vertex vert
                                                                                #pragma fragment frag

                                                                                // DotsInstancingOptions: <None>
                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                // Keywords
                                                                                #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                                                                                // GraphKeywords: <None>

                                                                                // Defines

                                                                                #define _NORMALMAP 1
                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                #define VARYINGS_NEED_POSITION_WS
                                                                                #define VARYINGS_NEED_NORMAL_WS
                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                #define SHADERPASS SHADERPASS_SHADOWCASTER
                                                                                #define REQUIRE_DEPTH_TEXTURE
                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                // custom interpolator pre-include
                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                // Includes
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                // --------------------------------------------------
                                                                                // Structs and Packing

                                                                                // custom interpolators pre packing
                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                struct Attributes
                                                                                {
                                                                                     float3 positionOS : POSITION;
                                                                                     float3 normalOS : NORMAL;
                                                                                     float4 tangentOS : TANGENT;
                                                                                     float4 uv0 : TEXCOORD0;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                    #endif
                                                                                };
                                                                                struct Varyings
                                                                                {
                                                                                     float4 positionCS : SV_POSITION;
                                                                                     float3 positionWS;
                                                                                     float3 normalWS;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                    #endif
                                                                                };
                                                                                struct SurfaceDescriptionInputs
                                                                                {
                                                                                     float3 WorldSpacePosition;
                                                                                     float4 ScreenPosition;
                                                                                };
                                                                                struct VertexDescriptionInputs
                                                                                {
                                                                                     float3 ObjectSpaceNormal;
                                                                                     float3 ObjectSpaceTangent;
                                                                                     float3 ObjectSpacePosition;
                                                                                     float4 uv0;
                                                                                     float3 TimeParameters;
                                                                                };
                                                                                struct PackedVaryings
                                                                                {
                                                                                     float4 positionCS : SV_POSITION;
                                                                                     float3 interp0 : INTERP0;
                                                                                     float3 interp1 : INTERP1;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                    #endif
                                                                                };

                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                {
                                                                                    PackedVaryings output;
                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                    output.positionCS = input.positionCS;
                                                                                    output.interp0.xyz = input.positionWS;
                                                                                    output.interp1.xyz = input.normalWS;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    output.instanceID = input.instanceID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    output.cullFace = input.cullFace;
                                                                                    #endif
                                                                                    return output;
                                                                                }

                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                {
                                                                                    Varyings output;
                                                                                    output.positionCS = input.positionCS;
                                                                                    output.positionWS = input.interp0.xyz;
                                                                                    output.normalWS = input.interp1.xyz;
                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                    output.instanceID = input.instanceID;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                    #endif
                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                    #endif
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    output.cullFace = input.cullFace;
                                                                                    #endif
                                                                                    return output;
                                                                                }


                                                                                // --------------------------------------------------
                                                                                // Graph

                                                                                // Graph Properties
                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                float _Depth;
                                                                                float _Strength;
                                                                                float4 _DeepWaterColor;
                                                                                float4 _ShallowWaterColor;
                                                                                float4 _MainNormal_TexelSize;
                                                                                float4 _SecondNormal_TexelSize;
                                                                                float _NormalStrength;
                                                                                float _Smoothness;
                                                                                float _Displacement;
                                                                                CBUFFER_END

                                                                                    // Object and Global properties
                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                    TEXTURE2D(_MainNormal);
                                                                                    SAMPLER(sampler_MainNormal);
                                                                                    TEXTURE2D(_SecondNormal);
                                                                                    SAMPLER(sampler_SecondNormal);

                                                                                    // Graph Includes
                                                                                    // GraphIncludes: <None>

                                                                                    // -- Property used by ScenePickingPass
                                                                                    #ifdef SCENEPICKINGPASS
                                                                                    float4 _SelectionID;
                                                                                    #endif

                                                                                    // -- Properties used by SceneSelectionPass
                                                                                    #ifdef SCENESELECTIONPASS
                                                                                    int _ObjectId;
                                                                                    int _PassValue;
                                                                                    #endif

                                                                                    // Graph Functions

                                                                                    void Unity_Divide_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A / B;
                                                                                    }

                                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                    {
                                                                                        Out = UV * Tiling + Offset;
                                                                                    }


                                                                                    float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                                    {
                                                                                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                                        p = p % 289;
                                                                                        // need full precision, otherwise half overflows when p > 1
                                                                                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                                        x = (34 * x + 1) * x % 289;
                                                                                        x = frac(x / 41) * 2 - 1;
                                                                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                                    }

                                                                                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                                    {
                                                                                        float2 p = UV * Scale;
                                                                                        float2 ip = floor(p);
                                                                                        float2 fp = frac(p);
                                                                                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                                    }

                                                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A * B;
                                                                                    }

                                                                                    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                                                                    {
                                                                                        RGBA = float4(R, G, B, A);
                                                                                        RGB = float3(R, G, B);
                                                                                        RG = float2(R, G);
                                                                                    }

                                                                                    void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                                                                                    {
                                                                                        Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                                                                    }

                                                                                    void Unity_Add_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A + B;
                                                                                    }

                                                                                    void Unity_Subtract_float(float A, float B, out float Out)
                                                                                    {
                                                                                        Out = A - B;
                                                                                    }

                                                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                    {
                                                                                        Out = clamp(In, Min, Max);
                                                                                    }

                                                                                    void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                                                                    {
                                                                                        Out = lerp(A, B, T);
                                                                                    }

                                                                                    // Custom interpolators pre vertex
                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                    // Graph Vertex
                                                                                    struct VertexDescription
                                                                                    {
                                                                                        float3 Position;
                                                                                        float3 Normal;
                                                                                        float3 Tangent;
                                                                                    };

                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                    {
                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_R_1 = IN.ObjectSpacePosition[0];
                                                                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_G_2 = IN.ObjectSpacePosition[1];
                                                                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_B_3 = IN.ObjectSpacePosition[2];
                                                                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_A_4 = 0;
                                                                                        float _Property_2aee0f2c381447299717226883b9dd5e_Out_0 = _Displacement;
                                                                                        float _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2;
                                                                                        Unity_Divide_float(IN.TimeParameters.x, 50, _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2);
                                                                                        float2 _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3;
                                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_0347d994cff649cca9eb90763a4ce74a_Out_2.xx), _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3);
                                                                                        float _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2;
                                                                                        Unity_GradientNoise_float(_TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3, 20, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2);
                                                                                        float _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2;
                                                                                        Unity_Multiply_float_float(_Property_2aee0f2c381447299717226883b9dd5e_Out_0, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2);
                                                                                        float4 _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4;
                                                                                        float3 _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                                                        float2 _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6;
                                                                                        Unity_Combine_float(_Split_5a46fb254a6548d9a32e712a81235ca4_R_1, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2, _Split_5a46fb254a6548d9a32e712a81235ca4_B_3, 0, _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4, _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5, _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6);
                                                                                        description.Position = _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                        return description;
                                                                                    }

                                                                                    // Custom interpolators, pre surface
                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                    {
                                                                                    return output;
                                                                                    }
                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                    #endif

                                                                                    // Graph Pixel
                                                                                    struct SurfaceDescription
                                                                                    {
                                                                                        float Alpha;
                                                                                    };

                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                    {
                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                        float4 _Property_f669795152fd4d83bfe0251a331b5e7e_Out_0 = _ShallowWaterColor;
                                                                                        float4 _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0 = _DeepWaterColor;
                                                                                        float _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1;
                                                                                        Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1);
                                                                                        float _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2;
                                                                                        Unity_Multiply_float_float(_SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1, _ProjectionParams.z, _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2);
                                                                                        float4 _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0 = IN.ScreenPosition;
                                                                                        float _Split_fabee40938d249f58c6df289b29487e6_R_1 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[0];
                                                                                        float _Split_fabee40938d249f58c6df289b29487e6_G_2 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[1];
                                                                                        float _Split_fabee40938d249f58c6df289b29487e6_B_3 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[2];
                                                                                        float _Split_fabee40938d249f58c6df289b29487e6_A_4 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[3];
                                                                                        float _Property_b835ed47772e498ca3bfd0304467564a_Out_0 = _Depth;
                                                                                        float _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2;
                                                                                        Unity_Add_float(_Split_fabee40938d249f58c6df289b29487e6_A_4, _Property_b835ed47772e498ca3bfd0304467564a_Out_0, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2);
                                                                                        float _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2;
                                                                                        Unity_Subtract_float(_Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2, _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2);
                                                                                        float _Property_d4102fc229a94768ae4a93daed7fd849_Out_0 = _Strength;
                                                                                        float _Multiply_c032a0c444d84300a760598cbea78a62_Out_2;
                                                                                        Unity_Multiply_float_float(_Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2, _Property_d4102fc229a94768ae4a93daed7fd849_Out_0, _Multiply_c032a0c444d84300a760598cbea78a62_Out_2);
                                                                                        float _Clamp_e8c5093ba9604977add70348fe2134be_Out_3;
                                                                                        Unity_Clamp_float(_Multiply_c032a0c444d84300a760598cbea78a62_Out_2, 0, 1, _Clamp_e8c5093ba9604977add70348fe2134be_Out_3);
                                                                                        float4 _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3;
                                                                                        Unity_Lerp_float4(_Property_f669795152fd4d83bfe0251a331b5e7e_Out_0, _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0, (_Clamp_e8c5093ba9604977add70348fe2134be_Out_3.xxxx), _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3);
                                                                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_R_1 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[0];
                                                                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_G_2 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[1];
                                                                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_B_3 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[2];
                                                                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[3];
                                                                                        surface.Alpha = _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4;
                                                                                        return surface;
                                                                                    }

                                                                                    // --------------------------------------------------
                                                                                    // Build Graph Inputs
                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                    #endif
                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                    {
                                                                                        VertexDescriptionInputs output;
                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                        output.ObjectSpacePosition = input.positionOS;
                                                                                        output.uv0 = input.uv0;
                                                                                        output.TimeParameters = _TimeParameters.xyz;

                                                                                        return output;
                                                                                    }
                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                    {
                                                                                        SurfaceDescriptionInputs output;
                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                    #endif







                                                                                        output.WorldSpacePosition = input.positionWS;
                                                                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                    #else
                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                    #endif
                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                            return output;
                                                                                    }

                                                                                    // --------------------------------------------------
                                                                                    // Main

                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                                                                                    // --------------------------------------------------
                                                                                    // Visual Effect Vertex Invocations
                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                    #endif

                                                                                    ENDHLSL
                                                                                    }
                                                                                    Pass
                                                                                    {
                                                                                        Name "DepthNormals"
                                                                                        Tags
                                                                                        {
                                                                                            "LightMode" = "DepthNormals"
                                                                                        }

                                                                                        // Render State
                                                                                        Cull Back
                                                                                        ZTest LEqual
                                                                                        ZWrite On

                                                                                        // Debug
                                                                                        // <None>

                                                                                        // --------------------------------------------------
                                                                                        // Pass

                                                                                        HLSLPROGRAM

                                                                                        // Pragmas
                                                                                        #pragma target 2.0
                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                        #pragma multi_compile_instancing
                                                                                        #pragma vertex vert
                                                                                        #pragma fragment frag

                                                                                        // DotsInstancingOptions: <None>
                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                        // Keywords
                                                                                        // PassKeywords: <None>
                                                                                        // GraphKeywords: <None>

                                                                                        // Defines

                                                                                        #define _NORMALMAP 1
                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                                        #define VARYINGS_NEED_TANGENT_WS
                                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                        #define SHADERPASS SHADERPASS_DEPTHNORMALS
                                                                                        #define REQUIRE_DEPTH_TEXTURE
                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                        // custom interpolator pre-include
                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                        // Includes
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                        // --------------------------------------------------
                                                                                        // Structs and Packing

                                                                                        // custom interpolators pre packing
                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                        struct Attributes
                                                                                        {
                                                                                             float3 positionOS : POSITION;
                                                                                             float3 normalOS : NORMAL;
                                                                                             float4 tangentOS : TANGENT;
                                                                                             float4 uv0 : TEXCOORD0;
                                                                                             float4 uv1 : TEXCOORD1;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                            #endif
                                                                                        };
                                                                                        struct Varyings
                                                                                        {
                                                                                             float4 positionCS : SV_POSITION;
                                                                                             float3 positionWS;
                                                                                             float3 normalWS;
                                                                                             float4 tangentWS;
                                                                                             float4 texCoord0;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                            #endif
                                                                                        };
                                                                                        struct SurfaceDescriptionInputs
                                                                                        {
                                                                                             float3 TangentSpaceNormal;
                                                                                             float3 WorldSpacePosition;
                                                                                             float4 ScreenPosition;
                                                                                             float4 uv0;
                                                                                             float3 TimeParameters;
                                                                                        };
                                                                                        struct VertexDescriptionInputs
                                                                                        {
                                                                                             float3 ObjectSpaceNormal;
                                                                                             float3 ObjectSpaceTangent;
                                                                                             float3 ObjectSpacePosition;
                                                                                             float4 uv0;
                                                                                             float3 TimeParameters;
                                                                                        };
                                                                                        struct PackedVaryings
                                                                                        {
                                                                                             float4 positionCS : SV_POSITION;
                                                                                             float3 interp0 : INTERP0;
                                                                                             float3 interp1 : INTERP1;
                                                                                             float4 interp2 : INTERP2;
                                                                                             float4 interp3 : INTERP3;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                            #endif
                                                                                        };

                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                        {
                                                                                            PackedVaryings output;
                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                            output.positionCS = input.positionCS;
                                                                                            output.interp0.xyz = input.positionWS;
                                                                                            output.interp1.xyz = input.normalWS;
                                                                                            output.interp2.xyzw = input.tangentWS;
                                                                                            output.interp3.xyzw = input.texCoord0;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            output.instanceID = input.instanceID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            output.cullFace = input.cullFace;
                                                                                            #endif
                                                                                            return output;
                                                                                        }

                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                        {
                                                                                            Varyings output;
                                                                                            output.positionCS = input.positionCS;
                                                                                            output.positionWS = input.interp0.xyz;
                                                                                            output.normalWS = input.interp1.xyz;
                                                                                            output.tangentWS = input.interp2.xyzw;
                                                                                            output.texCoord0 = input.interp3.xyzw;
                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                            output.instanceID = input.instanceID;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                            #endif
                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                            #endif
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            output.cullFace = input.cullFace;
                                                                                            #endif
                                                                                            return output;
                                                                                        }


                                                                                        // --------------------------------------------------
                                                                                        // Graph

                                                                                        // Graph Properties
                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                        float _Depth;
                                                                                        float _Strength;
                                                                                        float4 _DeepWaterColor;
                                                                                        float4 _ShallowWaterColor;
                                                                                        float4 _MainNormal_TexelSize;
                                                                                        float4 _SecondNormal_TexelSize;
                                                                                        float _NormalStrength;
                                                                                        float _Smoothness;
                                                                                        float _Displacement;
                                                                                        CBUFFER_END

                                                                                            // Object and Global properties
                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                            TEXTURE2D(_MainNormal);
                                                                                            SAMPLER(sampler_MainNormal);
                                                                                            TEXTURE2D(_SecondNormal);
                                                                                            SAMPLER(sampler_SecondNormal);

                                                                                            // Graph Includes
                                                                                            // GraphIncludes: <None>

                                                                                            // -- Property used by ScenePickingPass
                                                                                            #ifdef SCENEPICKINGPASS
                                                                                            float4 _SelectionID;
                                                                                            #endif

                                                                                            // -- Properties used by SceneSelectionPass
                                                                                            #ifdef SCENESELECTIONPASS
                                                                                            int _ObjectId;
                                                                                            int _PassValue;
                                                                                            #endif

                                                                                            // Graph Functions

                                                                                            void Unity_Divide_float(float A, float B, out float Out)
                                                                                            {
                                                                                                Out = A / B;
                                                                                            }

                                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                            {
                                                                                                Out = UV * Tiling + Offset;
                                                                                            }


                                                                                            float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                                            {
                                                                                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                                                p = p % 289;
                                                                                                // need full precision, otherwise half overflows when p > 1
                                                                                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                                                x = (34 * x + 1) * x % 289;
                                                                                                x = frac(x / 41) * 2 - 1;
                                                                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                                            }

                                                                                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                                            {
                                                                                                float2 p = UV * Scale;
                                                                                                float2 ip = floor(p);
                                                                                                float2 fp = frac(p);
                                                                                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                                            }

                                                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                            {
                                                                                                Out = A * B;
                                                                                            }

                                                                                            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                                                                            {
                                                                                                RGBA = float4(R, G, B, A);
                                                                                                RGB = float3(R, G, B);
                                                                                                RG = float2(R, G);
                                                                                            }

                                                                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                                            {
                                                                                                Out = A + B;
                                                                                            }

                                                                                            void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                                                                                            {
                                                                                                Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                                                                            }

                                                                                            void Unity_Add_float(float A, float B, out float Out)
                                                                                            {
                                                                                                Out = A + B;
                                                                                            }

                                                                                            void Unity_Subtract_float(float A, float B, out float Out)
                                                                                            {
                                                                                                Out = A - B;
                                                                                            }

                                                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                            {
                                                                                                Out = clamp(In, Min, Max);
                                                                                            }

                                                                                            void Unity_Lerp_float(float A, float B, float T, out float Out)
                                                                                            {
                                                                                                Out = lerp(A, B, T);
                                                                                            }

                                                                                            void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
                                                                                            {
                                                                                                Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
                                                                                            }

                                                                                            void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                                                                            {
                                                                                                Out = lerp(A, B, T);
                                                                                            }

                                                                                            // Custom interpolators pre vertex
                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                            // Graph Vertex
                                                                                            struct VertexDescription
                                                                                            {
                                                                                                float3 Position;
                                                                                                float3 Normal;
                                                                                                float3 Tangent;
                                                                                            };

                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                            {
                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_R_1 = IN.ObjectSpacePosition[0];
                                                                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_G_2 = IN.ObjectSpacePosition[1];
                                                                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_B_3 = IN.ObjectSpacePosition[2];
                                                                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_A_4 = 0;
                                                                                                float _Property_2aee0f2c381447299717226883b9dd5e_Out_0 = _Displacement;
                                                                                                float _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2;
                                                                                                Unity_Divide_float(IN.TimeParameters.x, 50, _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2);
                                                                                                float2 _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3;
                                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_0347d994cff649cca9eb90763a4ce74a_Out_2.xx), _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3);
                                                                                                float _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2;
                                                                                                Unity_GradientNoise_float(_TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3, 20, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2);
                                                                                                float _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2;
                                                                                                Unity_Multiply_float_float(_Property_2aee0f2c381447299717226883b9dd5e_Out_0, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2);
                                                                                                float4 _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4;
                                                                                                float3 _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                                                                float2 _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6;
                                                                                                Unity_Combine_float(_Split_5a46fb254a6548d9a32e712a81235ca4_R_1, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2, _Split_5a46fb254a6548d9a32e712a81235ca4_B_3, 0, _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4, _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5, _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6);
                                                                                                description.Position = _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                return description;
                                                                                            }

                                                                                            // Custom interpolators, pre surface
                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                            {
                                                                                            return output;
                                                                                            }
                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                            #endif

                                                                                            // Graph Pixel
                                                                                            struct SurfaceDescription
                                                                                            {
                                                                                                float3 NormalTS;
                                                                                                float Alpha;
                                                                                            };

                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                            {
                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                UnityTexture2D _Property_53020a2b9cbe4b6a83ad0a9fee0558e8_Out_0 = UnityBuildTexture2DStructNoScale(_MainNormal);
                                                                                                float _Divide_ee7923a88d6f4b1a9e8dbe5bfbb29685_Out_2;
                                                                                                Unity_Divide_float(IN.TimeParameters.x, 50, _Divide_ee7923a88d6f4b1a9e8dbe5bfbb29685_Out_2);
                                                                                                float2 _TilingAndOffset_a535553689a34d399e1a65691ca9aa39_Out_3;
                                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (10, 10), (_Divide_ee7923a88d6f4b1a9e8dbe5bfbb29685_Out_2.xx), _TilingAndOffset_a535553689a34d399e1a65691ca9aa39_Out_3);
                                                                                                float4 _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0 = SAMPLE_TEXTURE2D(_Property_53020a2b9cbe4b6a83ad0a9fee0558e8_Out_0.tex, _Property_53020a2b9cbe4b6a83ad0a9fee0558e8_Out_0.samplerstate, _Property_53020a2b9cbe4b6a83ad0a9fee0558e8_Out_0.GetTransformedUV(_TilingAndOffset_a535553689a34d399e1a65691ca9aa39_Out_3));
                                                                                                _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0);
                                                                                                float _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_R_4 = _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.r;
                                                                                                float _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_G_5 = _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.g;
                                                                                                float _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_B_6 = _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.b;
                                                                                                float _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_A_7 = _SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0.a;
                                                                                                UnityTexture2D _Property_2c235836e5664098bdb6fb2809be4539_Out_0 = UnityBuildTexture2DStructNoScale(_SecondNormal);
                                                                                                float _Divide_5d7c40eba84948c2b427b4bc6c71a9b0_Out_2;
                                                                                                Unity_Divide_float(IN.TimeParameters.x, -10, _Divide_5d7c40eba84948c2b427b4bc6c71a9b0_Out_2);
                                                                                                float2 _TilingAndOffset_cca530b5dccb4ec0a00dd9aff0e156e2_Out_3;
                                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (10, 10), (_Divide_5d7c40eba84948c2b427b4bc6c71a9b0_Out_2.xx), _TilingAndOffset_cca530b5dccb4ec0a00dd9aff0e156e2_Out_3);
                                                                                                float4 _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0 = SAMPLE_TEXTURE2D(_Property_2c235836e5664098bdb6fb2809be4539_Out_0.tex, _Property_2c235836e5664098bdb6fb2809be4539_Out_0.samplerstate, _Property_2c235836e5664098bdb6fb2809be4539_Out_0.GetTransformedUV(_TilingAndOffset_cca530b5dccb4ec0a00dd9aff0e156e2_Out_3));
                                                                                                _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0);
                                                                                                float _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_R_4 = _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.r;
                                                                                                float _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_G_5 = _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.g;
                                                                                                float _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_B_6 = _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.b;
                                                                                                float _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_A_7 = _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0.a;
                                                                                                float4 _Add_9b2536bd6bce45d4916943d980d7fc3f_Out_2;
                                                                                                Unity_Add_float4(_SampleTexture2D_9d81139352aa41b6b63f406974b0bc77_RGBA_0, _SampleTexture2D_cd0761362c134a8083bd5d2310e78609_RGBA_0, _Add_9b2536bd6bce45d4916943d980d7fc3f_Out_2);
                                                                                                float _Property_a5190d1ea56040d29725d71fd10fc2ff_Out_0 = _NormalStrength;
                                                                                                float _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1;
                                                                                                Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1);
                                                                                                float _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2;
                                                                                                Unity_Multiply_float_float(_SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1, _ProjectionParams.z, _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2);
                                                                                                float4 _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0 = IN.ScreenPosition;
                                                                                                float _Split_fabee40938d249f58c6df289b29487e6_R_1 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[0];
                                                                                                float _Split_fabee40938d249f58c6df289b29487e6_G_2 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[1];
                                                                                                float _Split_fabee40938d249f58c6df289b29487e6_B_3 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[2];
                                                                                                float _Split_fabee40938d249f58c6df289b29487e6_A_4 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[3];
                                                                                                float _Property_b835ed47772e498ca3bfd0304467564a_Out_0 = _Depth;
                                                                                                float _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2;
                                                                                                Unity_Add_float(_Split_fabee40938d249f58c6df289b29487e6_A_4, _Property_b835ed47772e498ca3bfd0304467564a_Out_0, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2);
                                                                                                float _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2;
                                                                                                Unity_Subtract_float(_Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2, _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2);
                                                                                                float _Property_d4102fc229a94768ae4a93daed7fd849_Out_0 = _Strength;
                                                                                                float _Multiply_c032a0c444d84300a760598cbea78a62_Out_2;
                                                                                                Unity_Multiply_float_float(_Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2, _Property_d4102fc229a94768ae4a93daed7fd849_Out_0, _Multiply_c032a0c444d84300a760598cbea78a62_Out_2);
                                                                                                float _Clamp_e8c5093ba9604977add70348fe2134be_Out_3;
                                                                                                Unity_Clamp_float(_Multiply_c032a0c444d84300a760598cbea78a62_Out_2, 0, 1, _Clamp_e8c5093ba9604977add70348fe2134be_Out_3);
                                                                                                float _Lerp_1b3da68c18ce4ab6b9781c9955aaa9ee_Out_3;
                                                                                                Unity_Lerp_float(0, _Property_a5190d1ea56040d29725d71fd10fc2ff_Out_0, _Clamp_e8c5093ba9604977add70348fe2134be_Out_3, _Lerp_1b3da68c18ce4ab6b9781c9955aaa9ee_Out_3);
                                                                                                float3 _NormalStrength_36f00e1d555c491bb0ed1d778d4eef29_Out_2;
                                                                                                Unity_NormalStrength_float((_Add_9b2536bd6bce45d4916943d980d7fc3f_Out_2.xyz), _Lerp_1b3da68c18ce4ab6b9781c9955aaa9ee_Out_3, _NormalStrength_36f00e1d555c491bb0ed1d778d4eef29_Out_2);
                                                                                                float4 _Property_f669795152fd4d83bfe0251a331b5e7e_Out_0 = _ShallowWaterColor;
                                                                                                float4 _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0 = _DeepWaterColor;
                                                                                                float4 _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3;
                                                                                                Unity_Lerp_float4(_Property_f669795152fd4d83bfe0251a331b5e7e_Out_0, _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0, (_Clamp_e8c5093ba9604977add70348fe2134be_Out_3.xxxx), _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3);
                                                                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_R_1 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[0];
                                                                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_G_2 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[1];
                                                                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_B_3 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[2];
                                                                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[3];
                                                                                                surface.NormalTS = _NormalStrength_36f00e1d555c491bb0ed1d778d4eef29_Out_2;
                                                                                                surface.Alpha = _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4;
                                                                                                return surface;
                                                                                            }

                                                                                            // --------------------------------------------------
                                                                                            // Build Graph Inputs
                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                            #endif
                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                            {
                                                                                                VertexDescriptionInputs output;
                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                output.ObjectSpacePosition = input.positionOS;
                                                                                                output.uv0 = input.uv0;
                                                                                                output.TimeParameters = _TimeParameters.xyz;

                                                                                                return output;
                                                                                            }
                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                            {
                                                                                                SurfaceDescriptionInputs output;
                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                            #endif





                                                                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                                                                output.WorldSpacePosition = input.positionWS;
                                                                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                                output.uv0 = input.texCoord0;
                                                                                                output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                            #else
                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                            #endif
                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                    return output;
                                                                                            }

                                                                                            // --------------------------------------------------
                                                                                            // Main

                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                                                                            // --------------------------------------------------
                                                                                            // Visual Effect Vertex Invocations
                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                            #endif

                                                                                            ENDHLSL
                                                                                            }
                                                                                            Pass
                                                                                            {
                                                                                                Name "Meta"
                                                                                                Tags
                                                                                                {
                                                                                                    "LightMode" = "Meta"
                                                                                                }

                                                                                                // Render State
                                                                                                Cull Off

                                                                                                // Debug
                                                                                                // <None>

                                                                                                // --------------------------------------------------
                                                                                                // Pass

                                                                                                HLSLPROGRAM

                                                                                                // Pragmas
                                                                                                #pragma target 2.0
                                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                                #pragma vertex vert
                                                                                                #pragma fragment frag

                                                                                                // DotsInstancingOptions: <None>
                                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                                // Keywords
                                                                                                #pragma shader_feature _ EDITOR_VISUALIZATION
                                                                                                // GraphKeywords: <None>

                                                                                                // Defines

                                                                                                #define _NORMALMAP 1
                                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                                                                #define ATTRIBUTES_NEED_TEXCOORD2
                                                                                                #define VARYINGS_NEED_POSITION_WS
                                                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                                                #define VARYINGS_NEED_TEXCOORD1
                                                                                                #define VARYINGS_NEED_TEXCOORD2
                                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                #define SHADERPASS SHADERPASS_META
                                                                                                #define _FOG_FRAGMENT 1
                                                                                                #define REQUIRE_DEPTH_TEXTURE
                                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                // custom interpolator pre-include
                                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                // Includes
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                // --------------------------------------------------
                                                                                                // Structs and Packing

                                                                                                // custom interpolators pre packing
                                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                struct Attributes
                                                                                                {
                                                                                                     float3 positionOS : POSITION;
                                                                                                     float3 normalOS : NORMAL;
                                                                                                     float4 tangentOS : TANGENT;
                                                                                                     float4 uv0 : TEXCOORD0;
                                                                                                     float4 uv1 : TEXCOORD1;
                                                                                                     float4 uv2 : TEXCOORD2;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                    #endif
                                                                                                };
                                                                                                struct Varyings
                                                                                                {
                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                     float3 positionWS;
                                                                                                     float4 texCoord0;
                                                                                                     float4 texCoord1;
                                                                                                     float4 texCoord2;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                    #endif
                                                                                                };
                                                                                                struct SurfaceDescriptionInputs
                                                                                                {
                                                                                                     float3 WorldSpacePosition;
                                                                                                     float4 ScreenPosition;
                                                                                                };
                                                                                                struct VertexDescriptionInputs
                                                                                                {
                                                                                                     float3 ObjectSpaceNormal;
                                                                                                     float3 ObjectSpaceTangent;
                                                                                                     float3 ObjectSpacePosition;
                                                                                                     float4 uv0;
                                                                                                     float3 TimeParameters;
                                                                                                };
                                                                                                struct PackedVaryings
                                                                                                {
                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                     float3 interp0 : INTERP0;
                                                                                                     float4 interp1 : INTERP1;
                                                                                                     float4 interp2 : INTERP2;
                                                                                                     float4 interp3 : INTERP3;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                    #endif
                                                                                                };

                                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                                {
                                                                                                    PackedVaryings output;
                                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                    output.positionCS = input.positionCS;
                                                                                                    output.interp0.xyz = input.positionWS;
                                                                                                    output.interp1.xyzw = input.texCoord0;
                                                                                                    output.interp2.xyzw = input.texCoord1;
                                                                                                    output.interp3.xyzw = input.texCoord2;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    output.instanceID = input.instanceID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    output.cullFace = input.cullFace;
                                                                                                    #endif
                                                                                                    return output;
                                                                                                }

                                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                                {
                                                                                                    Varyings output;
                                                                                                    output.positionCS = input.positionCS;
                                                                                                    output.positionWS = input.interp0.xyz;
                                                                                                    output.texCoord0 = input.interp1.xyzw;
                                                                                                    output.texCoord1 = input.interp2.xyzw;
                                                                                                    output.texCoord2 = input.interp3.xyzw;
                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                    output.instanceID = input.instanceID;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                    #endif
                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                    #endif
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    output.cullFace = input.cullFace;
                                                                                                    #endif
                                                                                                    return output;
                                                                                                }


                                                                                                // --------------------------------------------------
                                                                                                // Graph

                                                                                                // Graph Properties
                                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                                float _Depth;
                                                                                                float _Strength;
                                                                                                float4 _DeepWaterColor;
                                                                                                float4 _ShallowWaterColor;
                                                                                                float4 _MainNormal_TexelSize;
                                                                                                float4 _SecondNormal_TexelSize;
                                                                                                float _NormalStrength;
                                                                                                float _Smoothness;
                                                                                                float _Displacement;
                                                                                                CBUFFER_END

                                                                                                    // Object and Global properties
                                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                                    TEXTURE2D(_MainNormal);
                                                                                                    SAMPLER(sampler_MainNormal);
                                                                                                    TEXTURE2D(_SecondNormal);
                                                                                                    SAMPLER(sampler_SecondNormal);

                                                                                                    // Graph Includes
                                                                                                    // GraphIncludes: <None>

                                                                                                    // -- Property used by ScenePickingPass
                                                                                                    #ifdef SCENEPICKINGPASS
                                                                                                    float4 _SelectionID;
                                                                                                    #endif

                                                                                                    // -- Properties used by SceneSelectionPass
                                                                                                    #ifdef SCENESELECTIONPASS
                                                                                                    int _ObjectId;
                                                                                                    int _PassValue;
                                                                                                    #endif

                                                                                                    // Graph Functions

                                                                                                    void Unity_Divide_float(float A, float B, out float Out)
                                                                                                    {
                                                                                                        Out = A / B;
                                                                                                    }

                                                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                                    {
                                                                                                        Out = UV * Tiling + Offset;
                                                                                                    }


                                                                                                    float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                                                    {
                                                                                                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                                                        p = p % 289;
                                                                                                        // need full precision, otherwise half overflows when p > 1
                                                                                                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                                                        x = (34 * x + 1) * x % 289;
                                                                                                        x = frac(x / 41) * 2 - 1;
                                                                                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                                                    }

                                                                                                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                                                    {
                                                                                                        float2 p = UV * Scale;
                                                                                                        float2 ip = floor(p);
                                                                                                        float2 fp = frac(p);
                                                                                                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                                                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                                                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                                                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                                                    }

                                                                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                                    {
                                                                                                        Out = A * B;
                                                                                                    }

                                                                                                    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                                                                                    {
                                                                                                        RGBA = float4(R, G, B, A);
                                                                                                        RGB = float3(R, G, B);
                                                                                                        RG = float2(R, G);
                                                                                                    }

                                                                                                    void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                                                                                                    {
                                                                                                        Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                                                                                    }

                                                                                                    void Unity_Add_float(float A, float B, out float Out)
                                                                                                    {
                                                                                                        Out = A + B;
                                                                                                    }

                                                                                                    void Unity_Subtract_float(float A, float B, out float Out)
                                                                                                    {
                                                                                                        Out = A - B;
                                                                                                    }

                                                                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                                    {
                                                                                                        Out = clamp(In, Min, Max);
                                                                                                    }

                                                                                                    void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                                                                                    {
                                                                                                        Out = lerp(A, B, T);
                                                                                                    }

                                                                                                    // Custom interpolators pre vertex
                                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                    // Graph Vertex
                                                                                                    struct VertexDescription
                                                                                                    {
                                                                                                        float3 Position;
                                                                                                        float3 Normal;
                                                                                                        float3 Tangent;
                                                                                                    };

                                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                    {
                                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_R_1 = IN.ObjectSpacePosition[0];
                                                                                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_G_2 = IN.ObjectSpacePosition[1];
                                                                                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_B_3 = IN.ObjectSpacePosition[2];
                                                                                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_A_4 = 0;
                                                                                                        float _Property_2aee0f2c381447299717226883b9dd5e_Out_0 = _Displacement;
                                                                                                        float _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2;
                                                                                                        Unity_Divide_float(IN.TimeParameters.x, 50, _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2);
                                                                                                        float2 _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3;
                                                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_0347d994cff649cca9eb90763a4ce74a_Out_2.xx), _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3);
                                                                                                        float _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2;
                                                                                                        Unity_GradientNoise_float(_TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3, 20, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2);
                                                                                                        float _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2;
                                                                                                        Unity_Multiply_float_float(_Property_2aee0f2c381447299717226883b9dd5e_Out_0, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2);
                                                                                                        float4 _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4;
                                                                                                        float3 _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                                                                        float2 _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6;
                                                                                                        Unity_Combine_float(_Split_5a46fb254a6548d9a32e712a81235ca4_R_1, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2, _Split_5a46fb254a6548d9a32e712a81235ca4_B_3, 0, _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4, _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5, _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6);
                                                                                                        description.Position = _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                                        return description;
                                                                                                    }

                                                                                                    // Custom interpolators, pre surface
                                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                    {
                                                                                                    return output;
                                                                                                    }
                                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                    #endif

                                                                                                    // Graph Pixel
                                                                                                    struct SurfaceDescription
                                                                                                    {
                                                                                                        float3 BaseColor;
                                                                                                        float3 Emission;
                                                                                                        float Alpha;
                                                                                                    };

                                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                    {
                                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                        float4 _Property_f669795152fd4d83bfe0251a331b5e7e_Out_0 = _ShallowWaterColor;
                                                                                                        float4 _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0 = _DeepWaterColor;
                                                                                                        float _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1;
                                                                                                        Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1);
                                                                                                        float _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2;
                                                                                                        Unity_Multiply_float_float(_SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1, _ProjectionParams.z, _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2);
                                                                                                        float4 _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0 = IN.ScreenPosition;
                                                                                                        float _Split_fabee40938d249f58c6df289b29487e6_R_1 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[0];
                                                                                                        float _Split_fabee40938d249f58c6df289b29487e6_G_2 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[1];
                                                                                                        float _Split_fabee40938d249f58c6df289b29487e6_B_3 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[2];
                                                                                                        float _Split_fabee40938d249f58c6df289b29487e6_A_4 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[3];
                                                                                                        float _Property_b835ed47772e498ca3bfd0304467564a_Out_0 = _Depth;
                                                                                                        float _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2;
                                                                                                        Unity_Add_float(_Split_fabee40938d249f58c6df289b29487e6_A_4, _Property_b835ed47772e498ca3bfd0304467564a_Out_0, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2);
                                                                                                        float _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2;
                                                                                                        Unity_Subtract_float(_Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2, _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2);
                                                                                                        float _Property_d4102fc229a94768ae4a93daed7fd849_Out_0 = _Strength;
                                                                                                        float _Multiply_c032a0c444d84300a760598cbea78a62_Out_2;
                                                                                                        Unity_Multiply_float_float(_Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2, _Property_d4102fc229a94768ae4a93daed7fd849_Out_0, _Multiply_c032a0c444d84300a760598cbea78a62_Out_2);
                                                                                                        float _Clamp_e8c5093ba9604977add70348fe2134be_Out_3;
                                                                                                        Unity_Clamp_float(_Multiply_c032a0c444d84300a760598cbea78a62_Out_2, 0, 1, _Clamp_e8c5093ba9604977add70348fe2134be_Out_3);
                                                                                                        float4 _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3;
                                                                                                        Unity_Lerp_float4(_Property_f669795152fd4d83bfe0251a331b5e7e_Out_0, _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0, (_Clamp_e8c5093ba9604977add70348fe2134be_Out_3.xxxx), _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3);
                                                                                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_R_1 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[0];
                                                                                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_G_2 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[1];
                                                                                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_B_3 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[2];
                                                                                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[3];
                                                                                                        surface.BaseColor = (_Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3.xyz);
                                                                                                        surface.Emission = float3(0, 0, 0);
                                                                                                        surface.Alpha = _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4;
                                                                                                        return surface;
                                                                                                    }

                                                                                                    // --------------------------------------------------
                                                                                                    // Build Graph Inputs
                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                    #endif
                                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                    {
                                                                                                        VertexDescriptionInputs output;
                                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                        output.ObjectSpacePosition = input.positionOS;
                                                                                                        output.uv0 = input.uv0;
                                                                                                        output.TimeParameters = _TimeParameters.xyz;

                                                                                                        return output;
                                                                                                    }
                                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                    {
                                                                                                        SurfaceDescriptionInputs output;
                                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                    #endif







                                                                                                        output.WorldSpacePosition = input.positionWS;
                                                                                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                    #else
                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                    #endif
                                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                            return output;
                                                                                                    }

                                                                                                    // --------------------------------------------------
                                                                                                    // Main

                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                                                                                    // --------------------------------------------------
                                                                                                    // Visual Effect Vertex Invocations
                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                    #endif

                                                                                                    ENDHLSL
                                                                                                    }
                                                                                                    Pass
                                                                                                    {
                                                                                                        Name "SceneSelectionPass"
                                                                                                        Tags
                                                                                                        {
                                                                                                            "LightMode" = "SceneSelectionPass"
                                                                                                        }

                                                                                                        // Render State
                                                                                                        Cull Off

                                                                                                        // Debug
                                                                                                        // <None>

                                                                                                        // --------------------------------------------------
                                                                                                        // Pass

                                                                                                        HLSLPROGRAM

                                                                                                        // Pragmas
                                                                                                        #pragma target 2.0
                                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                                        #pragma multi_compile_instancing
                                                                                                        #pragma vertex vert
                                                                                                        #pragma fragment frag

                                                                                                        // DotsInstancingOptions: <None>
                                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                                        // Keywords
                                                                                                        // PassKeywords: <None>
                                                                                                        // GraphKeywords: <None>

                                                                                                        // Defines

                                                                                                        #define _NORMALMAP 1
                                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                        #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                                                        #define SCENESELECTIONPASS 1
                                                                                                        #define ALPHA_CLIP_THRESHOLD 1
                                                                                                        #define REQUIRE_DEPTH_TEXTURE
                                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                        // custom interpolator pre-include
                                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                        // Includes
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                        // --------------------------------------------------
                                                                                                        // Structs and Packing

                                                                                                        // custom interpolators pre packing
                                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                        struct Attributes
                                                                                                        {
                                                                                                             float3 positionOS : POSITION;
                                                                                                             float3 normalOS : NORMAL;
                                                                                                             float4 tangentOS : TANGENT;
                                                                                                             float4 uv0 : TEXCOORD0;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                            #endif
                                                                                                        };
                                                                                                        struct Varyings
                                                                                                        {
                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                             float3 positionWS;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                            #endif
                                                                                                        };
                                                                                                        struct SurfaceDescriptionInputs
                                                                                                        {
                                                                                                             float3 WorldSpacePosition;
                                                                                                             float4 ScreenPosition;
                                                                                                        };
                                                                                                        struct VertexDescriptionInputs
                                                                                                        {
                                                                                                             float3 ObjectSpaceNormal;
                                                                                                             float3 ObjectSpaceTangent;
                                                                                                             float3 ObjectSpacePosition;
                                                                                                             float4 uv0;
                                                                                                             float3 TimeParameters;
                                                                                                        };
                                                                                                        struct PackedVaryings
                                                                                                        {
                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                             float3 interp0 : INTERP0;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                            #endif
                                                                                                        };

                                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                                        {
                                                                                                            PackedVaryings output;
                                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                            output.positionCS = input.positionCS;
                                                                                                            output.interp0.xyz = input.positionWS;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            output.instanceID = input.instanceID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            output.cullFace = input.cullFace;
                                                                                                            #endif
                                                                                                            return output;
                                                                                                        }

                                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                                        {
                                                                                                            Varyings output;
                                                                                                            output.positionCS = input.positionCS;
                                                                                                            output.positionWS = input.interp0.xyz;
                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                            output.instanceID = input.instanceID;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                            #endif
                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                            #endif
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            output.cullFace = input.cullFace;
                                                                                                            #endif
                                                                                                            return output;
                                                                                                        }


                                                                                                        // --------------------------------------------------
                                                                                                        // Graph

                                                                                                        // Graph Properties
                                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                                        float _Depth;
                                                                                                        float _Strength;
                                                                                                        float4 _DeepWaterColor;
                                                                                                        float4 _ShallowWaterColor;
                                                                                                        float4 _MainNormal_TexelSize;
                                                                                                        float4 _SecondNormal_TexelSize;
                                                                                                        float _NormalStrength;
                                                                                                        float _Smoothness;
                                                                                                        float _Displacement;
                                                                                                        CBUFFER_END

                                                                                                            // Object and Global properties
                                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                                            TEXTURE2D(_MainNormal);
                                                                                                            SAMPLER(sampler_MainNormal);
                                                                                                            TEXTURE2D(_SecondNormal);
                                                                                                            SAMPLER(sampler_SecondNormal);

                                                                                                            // Graph Includes
                                                                                                            // GraphIncludes: <None>

                                                                                                            // -- Property used by ScenePickingPass
                                                                                                            #ifdef SCENEPICKINGPASS
                                                                                                            float4 _SelectionID;
                                                                                                            #endif

                                                                                                            // -- Properties used by SceneSelectionPass
                                                                                                            #ifdef SCENESELECTIONPASS
                                                                                                            int _ObjectId;
                                                                                                            int _PassValue;
                                                                                                            #endif

                                                                                                            // Graph Functions

                                                                                                            void Unity_Divide_float(float A, float B, out float Out)
                                                                                                            {
                                                                                                                Out = A / B;
                                                                                                            }

                                                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                                            {
                                                                                                                Out = UV * Tiling + Offset;
                                                                                                            }


                                                                                                            float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                                                            {
                                                                                                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                                                                p = p % 289;
                                                                                                                // need full precision, otherwise half overflows when p > 1
                                                                                                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                                                                x = (34 * x + 1) * x % 289;
                                                                                                                x = frac(x / 41) * 2 - 1;
                                                                                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                                                            }

                                                                                                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                                                            {
                                                                                                                float2 p = UV * Scale;
                                                                                                                float2 ip = floor(p);
                                                                                                                float2 fp = frac(p);
                                                                                                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                                                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                                                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                                                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                                                            }

                                                                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                                            {
                                                                                                                Out = A * B;
                                                                                                            }

                                                                                                            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                                                                                            {
                                                                                                                RGBA = float4(R, G, B, A);
                                                                                                                RGB = float3(R, G, B);
                                                                                                                RG = float2(R, G);
                                                                                                            }

                                                                                                            void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                                                                                                            {
                                                                                                                Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                                                                                            }

                                                                                                            void Unity_Add_float(float A, float B, out float Out)
                                                                                                            {
                                                                                                                Out = A + B;
                                                                                                            }

                                                                                                            void Unity_Subtract_float(float A, float B, out float Out)
                                                                                                            {
                                                                                                                Out = A - B;
                                                                                                            }

                                                                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                                            {
                                                                                                                Out = clamp(In, Min, Max);
                                                                                                            }

                                                                                                            void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                                                                                            {
                                                                                                                Out = lerp(A, B, T);
                                                                                                            }

                                                                                                            // Custom interpolators pre vertex
                                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                            // Graph Vertex
                                                                                                            struct VertexDescription
                                                                                                            {
                                                                                                                float3 Position;
                                                                                                                float3 Normal;
                                                                                                                float3 Tangent;
                                                                                                            };

                                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                            {
                                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_R_1 = IN.ObjectSpacePosition[0];
                                                                                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_G_2 = IN.ObjectSpacePosition[1];
                                                                                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_B_3 = IN.ObjectSpacePosition[2];
                                                                                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_A_4 = 0;
                                                                                                                float _Property_2aee0f2c381447299717226883b9dd5e_Out_0 = _Displacement;
                                                                                                                float _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2;
                                                                                                                Unity_Divide_float(IN.TimeParameters.x, 50, _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2);
                                                                                                                float2 _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3;
                                                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_0347d994cff649cca9eb90763a4ce74a_Out_2.xx), _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3);
                                                                                                                float _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2;
                                                                                                                Unity_GradientNoise_float(_TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3, 20, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2);
                                                                                                                float _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2;
                                                                                                                Unity_Multiply_float_float(_Property_2aee0f2c381447299717226883b9dd5e_Out_0, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2);
                                                                                                                float4 _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4;
                                                                                                                float3 _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                                                                                float2 _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6;
                                                                                                                Unity_Combine_float(_Split_5a46fb254a6548d9a32e712a81235ca4_R_1, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2, _Split_5a46fb254a6548d9a32e712a81235ca4_B_3, 0, _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4, _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5, _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6);
                                                                                                                description.Position = _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                return description;
                                                                                                            }

                                                                                                            // Custom interpolators, pre surface
                                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                            {
                                                                                                            return output;
                                                                                                            }
                                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                            #endif

                                                                                                            // Graph Pixel
                                                                                                            struct SurfaceDescription
                                                                                                            {
                                                                                                                float Alpha;
                                                                                                            };

                                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                            {
                                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                float4 _Property_f669795152fd4d83bfe0251a331b5e7e_Out_0 = _ShallowWaterColor;
                                                                                                                float4 _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0 = _DeepWaterColor;
                                                                                                                float _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1;
                                                                                                                Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1);
                                                                                                                float _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2;
                                                                                                                Unity_Multiply_float_float(_SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1, _ProjectionParams.z, _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2);
                                                                                                                float4 _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0 = IN.ScreenPosition;
                                                                                                                float _Split_fabee40938d249f58c6df289b29487e6_R_1 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[0];
                                                                                                                float _Split_fabee40938d249f58c6df289b29487e6_G_2 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[1];
                                                                                                                float _Split_fabee40938d249f58c6df289b29487e6_B_3 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[2];
                                                                                                                float _Split_fabee40938d249f58c6df289b29487e6_A_4 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[3];
                                                                                                                float _Property_b835ed47772e498ca3bfd0304467564a_Out_0 = _Depth;
                                                                                                                float _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2;
                                                                                                                Unity_Add_float(_Split_fabee40938d249f58c6df289b29487e6_A_4, _Property_b835ed47772e498ca3bfd0304467564a_Out_0, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2);
                                                                                                                float _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2;
                                                                                                                Unity_Subtract_float(_Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2, _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2);
                                                                                                                float _Property_d4102fc229a94768ae4a93daed7fd849_Out_0 = _Strength;
                                                                                                                float _Multiply_c032a0c444d84300a760598cbea78a62_Out_2;
                                                                                                                Unity_Multiply_float_float(_Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2, _Property_d4102fc229a94768ae4a93daed7fd849_Out_0, _Multiply_c032a0c444d84300a760598cbea78a62_Out_2);
                                                                                                                float _Clamp_e8c5093ba9604977add70348fe2134be_Out_3;
                                                                                                                Unity_Clamp_float(_Multiply_c032a0c444d84300a760598cbea78a62_Out_2, 0, 1, _Clamp_e8c5093ba9604977add70348fe2134be_Out_3);
                                                                                                                float4 _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3;
                                                                                                                Unity_Lerp_float4(_Property_f669795152fd4d83bfe0251a331b5e7e_Out_0, _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0, (_Clamp_e8c5093ba9604977add70348fe2134be_Out_3.xxxx), _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3);
                                                                                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_R_1 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[0];
                                                                                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_G_2 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[1];
                                                                                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_B_3 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[2];
                                                                                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[3];
                                                                                                                surface.Alpha = _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4;
                                                                                                                return surface;
                                                                                                            }

                                                                                                            // --------------------------------------------------
                                                                                                            // Build Graph Inputs
                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                            #endif
                                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                            {
                                                                                                                VertexDescriptionInputs output;
                                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                output.ObjectSpacePosition = input.positionOS;
                                                                                                                output.uv0 = input.uv0;
                                                                                                                output.TimeParameters = _TimeParameters.xyz;

                                                                                                                return output;
                                                                                                            }
                                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                            {
                                                                                                                SurfaceDescriptionInputs output;
                                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                            #endif







                                                                                                                output.WorldSpacePosition = input.positionWS;
                                                                                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                            #else
                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                            #endif
                                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                    return output;
                                                                                                            }

                                                                                                            // --------------------------------------------------
                                                                                                            // Main

                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                                                                            // --------------------------------------------------
                                                                                                            // Visual Effect Vertex Invocations
                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                            #endif

                                                                                                            ENDHLSL
                                                                                                            }
                                                                                                            Pass
                                                                                                            {
                                                                                                                Name "ScenePickingPass"
                                                                                                                Tags
                                                                                                                {
                                                                                                                    "LightMode" = "Picking"
                                                                                                                }

                                                                                                                // Render State
                                                                                                                Cull Back

                                                                                                                // Debug
                                                                                                                // <None>

                                                                                                                // --------------------------------------------------
                                                                                                                // Pass

                                                                                                                HLSLPROGRAM

                                                                                                                // Pragmas
                                                                                                                #pragma target 2.0
                                                                                                                #pragma only_renderers gles gles3 glcore d3d11
                                                                                                                #pragma multi_compile_instancing
                                                                                                                #pragma vertex vert
                                                                                                                #pragma fragment frag

                                                                                                                // DotsInstancingOptions: <None>
                                                                                                                // HybridV1InjectedBuiltinProperties: <None>

                                                                                                                // Keywords
                                                                                                                // PassKeywords: <None>
                                                                                                                // GraphKeywords: <None>

                                                                                                                // Defines

                                                                                                                #define _NORMALMAP 1
                                                                                                                #define _NORMAL_DROPOFF_TS 1
                                                                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                                #define VARYINGS_NEED_POSITION_WS
                                                                                                                #define FEATURES_GRAPH_VERTEX
                                                                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                                                                #define SCENEPICKINGPASS 1
                                                                                                                #define ALPHA_CLIP_THRESHOLD 1
                                                                                                                #define REQUIRE_DEPTH_TEXTURE
                                                                                                                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                                // custom interpolator pre-include
                                                                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                                // Includes
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                                // --------------------------------------------------
                                                                                                                // Structs and Packing

                                                                                                                // custom interpolators pre packing
                                                                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                                struct Attributes
                                                                                                                {
                                                                                                                     float3 positionOS : POSITION;
                                                                                                                     float3 normalOS : NORMAL;
                                                                                                                     float4 tangentOS : TANGENT;
                                                                                                                     float4 uv0 : TEXCOORD0;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };
                                                                                                                struct Varyings
                                                                                                                {
                                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                                     float3 positionWS;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };
                                                                                                                struct SurfaceDescriptionInputs
                                                                                                                {
                                                                                                                     float3 WorldSpacePosition;
                                                                                                                     float4 ScreenPosition;
                                                                                                                };
                                                                                                                struct VertexDescriptionInputs
                                                                                                                {
                                                                                                                     float3 ObjectSpaceNormal;
                                                                                                                     float3 ObjectSpaceTangent;
                                                                                                                     float3 ObjectSpacePosition;
                                                                                                                     float4 uv0;
                                                                                                                     float3 TimeParameters;
                                                                                                                };
                                                                                                                struct PackedVaryings
                                                                                                                {
                                                                                                                     float4 positionCS : SV_POSITION;
                                                                                                                     float3 interp0 : INTERP0;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                    #endif
                                                                                                                };

                                                                                                                PackedVaryings PackVaryings(Varyings input)
                                                                                                                {
                                                                                                                    PackedVaryings output;
                                                                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                                    output.positionCS = input.positionCS;
                                                                                                                    output.interp0.xyz = input.positionWS;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                    output.instanceID = input.instanceID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    output.cullFace = input.cullFace;
                                                                                                                    #endif
                                                                                                                    return output;
                                                                                                                }

                                                                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                                                                {
                                                                                                                    Varyings output;
                                                                                                                    output.positionCS = input.positionCS;
                                                                                                                    output.positionWS = input.interp0.xyz;
                                                                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                    output.instanceID = input.instanceID;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                    #endif
                                                                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                    #endif
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    output.cullFace = input.cullFace;
                                                                                                                    #endif
                                                                                                                    return output;
                                                                                                                }


                                                                                                                // --------------------------------------------------
                                                                                                                // Graph

                                                                                                                // Graph Properties
                                                                                                                CBUFFER_START(UnityPerMaterial)
                                                                                                                float _Depth = 0.1f;
                                                                                                                float _Strength = 0.5f;
                                                                                                                float4 _DeepWaterColor;
                                                                                                                float4 _ShallowWaterColor;
                                                                                                                float4 _MainNormal_TexelSize;
                                                                                                                float4 _SecondNormal_TexelSize;
                                                                                                                float _NormalStrength = 0.45f;
                                                                                                                float _Smoothness = 0.78f;
                                                                                                                float _Displacement = 0.3f;
                                                                                                                CBUFFER_END

                                                                                                                    // Object and Global properties
                                                                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                                                                    TEXTURE2D(_MainNormal);
                                                                                                                    SAMPLER(sampler_MainNormal);
                                                                                                                    TEXTURE2D(_SecondNormal);
                                                                                                                    SAMPLER(sampler_SecondNormal);

                                                                                                                    // Graph Includes
                                                                                                                    // GraphIncludes: <None>

                                                                                                                    // -- Property used by ScenePickingPass
                                                                                                                    #ifdef SCENEPICKINGPASS
                                                                                                                    float4 _SelectionID;
                                                                                                                    #endif

                                                                                                                    // -- Properties used by SceneSelectionPass
                                                                                                                    #ifdef SCENESELECTIONPASS
                                                                                                                    int _ObjectId;
                                                                                                                    int _PassValue;
                                                                                                                    #endif

                                                                                                                    // Graph Functions

                                                                                                                    void Unity_Divide_float(float A, float B, out float Out)
                                                                                                                    {
                                                                                                                        Out = A / B;
                                                                                                                    }

                                                                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                                                    {
                                                                                                                        Out = UV * Tiling + Offset;
                                                                                                                    }


                                                                                                                    float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                                                                    {
                                                                                                                        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                                                                        p = p % 289;
                                                                                                                        // need full precision, otherwise half overflows when p > 1
                                                                                                                        float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                                                                        x = (34 * x + 1) * x % 289;
                                                                                                                        x = frac(x / 41) * 2 - 1;
                                                                                                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                                                                    }

                                                                                                                    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                                                                    {
                                                                                                                        float2 p = UV * Scale;
                                                                                                                        float2 ip = floor(p);
                                                                                                                        float2 fp = frac(p);
                                                                                                                        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                                                                        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                                                                        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                                                                        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                                                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                                                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                                                                    }

                                                                                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                                                    {
                                                                                                                        Out = A * B;
                                                                                                                    }

                                                                                                                    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                                                                                                    {
                                                                                                                        RGBA = float4(R, G, B, A);
                                                                                                                        RGB = float3(R, G, B);
                                                                                                                        RG = float2(R, G);
                                                                                                                    }

                                                                                                                    void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                                                                                                                    {
                                                                                                                        Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                                                                                                    }

                                                                                                                    void Unity_Add_float(float A, float B, out float Out)
                                                                                                                    {
                                                                                                                        Out = A + B;
                                                                                                                    }

                                                                                                                    void Unity_Subtract_float(float A, float B, out float Out)
                                                                                                                    {
                                                                                                                        Out = A - B;
                                                                                                                    }

                                                                                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                                                    {
                                                                                                                        Out = clamp(In, Min, Max);
                                                                                                                    }

                                                                                                                    void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                                                                                                    {
                                                                                                                        Out = lerp(A, B, T);
                                                                                                                    }

                                                                                                                    // Custom interpolators pre vertex
                                                                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                                    // Graph Vertex
                                                                                                                    struct VertexDescription
                                                                                                                    {
                                                                                                                        float3 Position;
                                                                                                                        float3 Normal;
                                                                                                                        float3 Tangent;
                                                                                                                    };

                                                                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                                    {
                                                                                                                        VertexDescription description = (VertexDescription)0;
                                                                                                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_R_1 = IN.ObjectSpacePosition[0];
                                                                                                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_G_2 = IN.ObjectSpacePosition[1];
                                                                                                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_B_3 = IN.ObjectSpacePosition[2];
                                                                                                                        float _Split_5a46fb254a6548d9a32e712a81235ca4_A_4 = 0;
                                                                                                                        float _Property_2aee0f2c381447299717226883b9dd5e_Out_0 = _Displacement;
                                                                                                                        float _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2;
                                                                                                                        Unity_Divide_float(IN.TimeParameters.x, 50, _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2);
                                                                                                                        float2 _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3;
                                                                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_0347d994cff649cca9eb90763a4ce74a_Out_2.xx), _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3);
                                                                                                                        float _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2;
                                                                                                                        Unity_GradientNoise_float(_TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3, 20, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2);
                                                                                                                        float _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2;
                                                                                                                        Unity_Multiply_float_float(_Property_2aee0f2c381447299717226883b9dd5e_Out_0, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2);
                                                                                                                        float4 _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4;
                                                                                                                        float3 _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                                                                                        float2 _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6;
                                                                                                                        Unity_Combine_float(_Split_5a46fb254a6548d9a32e712a81235ca4_R_1, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2, _Split_5a46fb254a6548d9a32e712a81235ca4_B_3, 0, _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4, _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5, _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6);
                                                                                                                        description.Position = _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                        return description;
                                                                                                                    }

                                                                                                                    // Custom interpolators, pre surface
                                                                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                                    {
                                                                                                                    return output;
                                                                                                                    }
                                                                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                                    #endif

                                                                                                                    // Graph Pixel
                                                                                                                    struct SurfaceDescription
                                                                                                                    {
                                                                                                                        float Alpha;
                                                                                                                    };

                                                                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                                    {
                                                                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                        float4 _Property_f669795152fd4d83bfe0251a331b5e7e_Out_0 = _ShallowWaterColor;
                                                                                                                        float4 _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0 = _DeepWaterColor;
                                                                                                                        float _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1;
                                                                                                                        Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1);
                                                                                                                        float _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2;
                                                                                                                        Unity_Multiply_float_float(_SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1, _ProjectionParams.z, _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2);
                                                                                                                        float4 _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0 = IN.ScreenPosition;
                                                                                                                        float _Split_fabee40938d249f58c6df289b29487e6_R_1 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[0];
                                                                                                                        float _Split_fabee40938d249f58c6df289b29487e6_G_2 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[1];
                                                                                                                        float _Split_fabee40938d249f58c6df289b29487e6_B_3 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[2];
                                                                                                                        float _Split_fabee40938d249f58c6df289b29487e6_A_4 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[3];
                                                                                                                        float _Property_b835ed47772e498ca3bfd0304467564a_Out_0 = _Depth;
                                                                                                                        float _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2;
                                                                                                                        Unity_Add_float(_Split_fabee40938d249f58c6df289b29487e6_A_4, _Property_b835ed47772e498ca3bfd0304467564a_Out_0, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2);
                                                                                                                        float _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2;
                                                                                                                        Unity_Subtract_float(_Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2, _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2);
                                                                                                                        float _Property_d4102fc229a94768ae4a93daed7fd849_Out_0 = _Strength;
                                                                                                                        float _Multiply_c032a0c444d84300a760598cbea78a62_Out_2;
                                                                                                                        Unity_Multiply_float_float(_Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2, _Property_d4102fc229a94768ae4a93daed7fd849_Out_0, _Multiply_c032a0c444d84300a760598cbea78a62_Out_2);
                                                                                                                        float _Clamp_e8c5093ba9604977add70348fe2134be_Out_3;
                                                                                                                        Unity_Clamp_float(_Multiply_c032a0c444d84300a760598cbea78a62_Out_2, 0, 1, _Clamp_e8c5093ba9604977add70348fe2134be_Out_3);
                                                                                                                        float4 _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3;
                                                                                                                        Unity_Lerp_float4(_Property_f669795152fd4d83bfe0251a331b5e7e_Out_0, _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0, (_Clamp_e8c5093ba9604977add70348fe2134be_Out_3.xxxx), _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3);
                                                                                                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_R_1 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[0];
                                                                                                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_G_2 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[1];
                                                                                                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_B_3 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[2];
                                                                                                                        float _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[3];
                                                                                                                        surface.Alpha = _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4;
                                                                                                                        return surface;
                                                                                                                    }

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Build Graph Inputs
                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                                    #endif
                                                                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                                    {
                                                                                                                        VertexDescriptionInputs output;
                                                                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                        output.ObjectSpacePosition = input.positionOS;
                                                                                                                        output.uv0 = input.uv0;
                                                                                                                        output.TimeParameters = _TimeParameters.xyz;

                                                                                                                        return output;
                                                                                                                    }
                                                                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                                    {
                                                                                                                        SurfaceDescriptionInputs output;
                                                                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                        // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                                    #endif







                                                                                                                        output.WorldSpacePosition = input.positionWS;
                                                                                                                        output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                                    #else
                                                                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                                    #endif
                                                                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                            return output;
                                                                                                                    }

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Main

                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                                                                                    // --------------------------------------------------
                                                                                                                    // Visual Effect Vertex Invocations
                                                                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                                    #endif

                                                                                                                    ENDHLSL
                                                                                                                    }
                                                                                                                    Pass
                                                                                                                    {
                                                                                                                        // Name: <None>
                                                                                                                        Tags
                                                                                                                        {
                                                                                                                            "LightMode" = "Universal2D"
                                                                                                                        }

                                                                                                                        // Render State
                                                                                                                        Cull Back
                                                                                                                        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                                                                                                        ZTest LEqual
                                                                                                                        ZWrite Off

                                                                                                                        // Debug
                                                                                                                        // <None>

                                                                                                                        // --------------------------------------------------
                                                                                                                        // Pass

                                                                                                                        HLSLPROGRAM

                                                                                                                        // Pragmas
                                                                                                                        #pragma target 2.0
                                                                                                                        #pragma only_renderers gles gles3 glcore d3d11
                                                                                                                        #pragma multi_compile_instancing
                                                                                                                        #pragma vertex vert
                                                                                                                        #pragma fragment frag

                                                                                                                        // DotsInstancingOptions: <None>
                                                                                                                        // HybridV1InjectedBuiltinProperties: <None>

                                                                                                                        // Keywords
                                                                                                                        // PassKeywords: <None>
                                                                                                                        // GraphKeywords: <None>

                                                                                                                        // Defines

                                                                                                                        #define _NORMALMAP 1
                                                                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                                                                        #define FEATURES_GRAPH_VERTEX
                                                                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                                                                        #define SHADERPASS SHADERPASS_2D
                                                                                                                        #define REQUIRE_DEPTH_TEXTURE
                                                                                                                        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


                                                                                                                        // custom interpolator pre-include
                                                                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                                                                        // Includes
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                                                                        // --------------------------------------------------
                                                                                                                        // Structs and Packing

                                                                                                                        // custom interpolators pre packing
                                                                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                                                                        struct Attributes
                                                                                                                        {
                                                                                                                             float3 positionOS : POSITION;
                                                                                                                             float3 normalOS : NORMAL;
                                                                                                                             float4 tangentOS : TANGENT;
                                                                                                                             float4 uv0 : TEXCOORD0;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };
                                                                                                                        struct Varyings
                                                                                                                        {
                                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                                             float3 positionWS;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };
                                                                                                                        struct SurfaceDescriptionInputs
                                                                                                                        {
                                                                                                                             float3 WorldSpacePosition;
                                                                                                                             float4 ScreenPosition;
                                                                                                                        };
                                                                                                                        struct VertexDescriptionInputs
                                                                                                                        {
                                                                                                                             float3 ObjectSpaceNormal;
                                                                                                                             float3 ObjectSpaceTangent;
                                                                                                                             float3 ObjectSpacePosition;
                                                                                                                             float4 uv0;
                                                                                                                             float3 TimeParameters;
                                                                                                                        };
                                                                                                                        struct PackedVaryings
                                                                                                                        {
                                                                                                                             float4 positionCS : SV_POSITION;
                                                                                                                             float3 interp0 : INTERP0;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                                                                            #endif
                                                                                                                        };

                                                                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                                                                        {
                                                                                                                            PackedVaryings output;
                                                                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                                                                            output.positionCS = input.positionCS;
                                                                                                                            output.interp0.xyz = input.positionWS;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                            output.instanceID = input.instanceID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            output.cullFace = input.cullFace;
                                                                                                                            #endif
                                                                                                                            return output;
                                                                                                                        }

                                                                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                                                                        {
                                                                                                                            Varyings output;
                                                                                                                            output.positionCS = input.positionCS;
                                                                                                                            output.positionWS = input.interp0.xyz;
                                                                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                                                                            output.instanceID = input.instanceID;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                                                                            #endif
                                                                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                                                                            #endif
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            output.cullFace = input.cullFace;
                                                                                                                            #endif
                                                                                                                            return output;
                                                                                                                        }


                                                                                                                        // --------------------------------------------------
                                                                                                                        // Graph

                                                                                                                        // Graph Properties
                                                                                                                        CBUFFER_START(UnityPerMaterial)
                                                                                                                        float _Depth;
                                                                                                                        float _Strength;
                                                                                                                        float4 _DeepWaterColor;
                                                                                                                        float4 _ShallowWaterColor;
                                                                                                                        float4 _MainNormal_TexelSize;
                                                                                                                        float4 _SecondNormal_TexelSize;
                                                                                                                        float _NormalStrength;
                                                                                                                        float _Smoothness;
                                                                                                                        float _Displacement;
                                                                                                                        CBUFFER_END

                                                                                                                            // Object and Global properties
                                                                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                                                                            TEXTURE2D(_MainNormal);
                                                                                                                            SAMPLER(sampler_MainNormal);
                                                                                                                            TEXTURE2D(_SecondNormal);
                                                                                                                            SAMPLER(sampler_SecondNormal);

                                                                                                                            // Graph Includes
                                                                                                                            // GraphIncludes: <None>

                                                                                                                            // -- Property used by ScenePickingPass
                                                                                                                            #ifdef SCENEPICKINGPASS
                                                                                                                            float4 _SelectionID;
                                                                                                                            #endif

                                                                                                                            // -- Properties used by SceneSelectionPass
                                                                                                                            #ifdef SCENESELECTIONPASS
                                                                                                                            int _ObjectId;
                                                                                                                            int _PassValue;
                                                                                                                            #endif

                                                                                                                            // Graph Functions

                                                                                                                            void Unity_Divide_float(float A, float B, out float Out)
                                                                                                                            {
                                                                                                                                Out = A / B;
                                                                                                                            }

                                                                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                                                                            {
                                                                                                                                Out = UV * Tiling + Offset;
                                                                                                                            }


                                                                                                                            float2 Unity_GradientNoise_Dir_float(float2 p)
                                                                                                                            {
                                                                                                                                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                                                                                                                                p = p % 289;
                                                                                                                                // need full precision, otherwise half overflows when p > 1
                                                                                                                                float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                                                                                                                                x = (34 * x + 1) * x % 289;
                                                                                                                                x = frac(x / 41) * 2 - 1;
                                                                                                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                                                                            }

                                                                                                                            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                                                                                                                            {
                                                                                                                                float2 p = UV * Scale;
                                                                                                                                float2 ip = floor(p);
                                                                                                                                float2 fp = frac(p);
                                                                                                                                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                                                                                                                                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                                                                                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                                                                                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                                                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                                                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                                                                            }

                                                                                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                                                                            {
                                                                                                                                Out = A * B;
                                                                                                                            }

                                                                                                                            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
                                                                                                                            {
                                                                                                                                RGBA = float4(R, G, B, A);
                                                                                                                                RGB = float3(R, G, B);
                                                                                                                                RG = float2(R, G);
                                                                                                                            }

                                                                                                                            void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                                                                                                                            {
                                                                                                                                Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                                                                                                                            }

                                                                                                                            void Unity_Add_float(float A, float B, out float Out)
                                                                                                                            {
                                                                                                                                Out = A + B;
                                                                                                                            }

                                                                                                                            void Unity_Subtract_float(float A, float B, out float Out)
                                                                                                                            {
                                                                                                                                Out = A - B;
                                                                                                                            }

                                                                                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                                                                            {
                                                                                                                                Out = clamp(In, Min, Max);
                                                                                                                            }

                                                                                                                            void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                                                                                                                            {
                                                                                                                                Out = lerp(A, B, T);
                                                                                                                            }

                                                                                                                            // Custom interpolators pre vertex
                                                                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                                                                            // Graph Vertex
                                                                                                                            struct VertexDescription
                                                                                                                            {
                                                                                                                                float3 Position;
                                                                                                                                float3 Normal;
                                                                                                                                float3 Tangent;
                                                                                                                            };

                                                                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                                                                            {
                                                                                                                                VertexDescription description = (VertexDescription)0;
                                                                                                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_R_1 = IN.ObjectSpacePosition[0];
                                                                                                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_G_2 = IN.ObjectSpacePosition[1];
                                                                                                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_B_3 = IN.ObjectSpacePosition[2];
                                                                                                                                float _Split_5a46fb254a6548d9a32e712a81235ca4_A_4 = 0;
                                                                                                                                float _Property_2aee0f2c381447299717226883b9dd5e_Out_0 = _Displacement;
                                                                                                                                float _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2;
                                                                                                                                Unity_Divide_float(IN.TimeParameters.x, 50, _Divide_0347d994cff649cca9eb90763a4ce74a_Out_2);
                                                                                                                                float2 _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3;
                                                                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_0347d994cff649cca9eb90763a4ce74a_Out_2.xx), _TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3);
                                                                                                                                float _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2;
                                                                                                                                Unity_GradientNoise_float(_TilingAndOffset_69a2ebc39aa44ae8a5e25ae8c28da45c_Out_3, 20, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2);
                                                                                                                                float _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2;
                                                                                                                                Unity_Multiply_float_float(_Property_2aee0f2c381447299717226883b9dd5e_Out_0, _GradientNoise_8ba081332b24411ca8402e8e953944bf_Out_2, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2);
                                                                                                                                float4 _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4;
                                                                                                                                float3 _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                                                                                                float2 _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6;
                                                                                                                                Unity_Combine_float(_Split_5a46fb254a6548d9a32e712a81235ca4_R_1, _Multiply_022b5053707942bea410bb5a27f15fdc_Out_2, _Split_5a46fb254a6548d9a32e712a81235ca4_B_3, 0, _Combine_cc2427d0d6aa439483bb82069e64a880_RGBA_4, _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5, _Combine_cc2427d0d6aa439483bb82069e64a880_RG_6);
                                                                                                                                description.Position = _Combine_cc2427d0d6aa439483bb82069e64a880_RGB_5;
                                                                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                                                                return description;
                                                                                                                            }

                                                                                                                            // Custom interpolators, pre surface
                                                                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                                                                            {
                                                                                                                            return output;
                                                                                                                            }
                                                                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                                                                            #endif

                                                                                                                            // Graph Pixel
                                                                                                                            struct SurfaceDescription
                                                                                                                            {
                                                                                                                                float3 BaseColor;
                                                                                                                                float Alpha;
                                                                                                                            };

                                                                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                                                                            {
                                                                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                                                                float4 _Property_f669795152fd4d83bfe0251a331b5e7e_Out_0 = _ShallowWaterColor;
                                                                                                                                float4 _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0 = _DeepWaterColor;
                                                                                                                                float _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1;
                                                                                                                                Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1);
                                                                                                                                float _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2;
                                                                                                                                Unity_Multiply_float_float(_SceneDepth_49c87219507a4aad9ad317ace3deb14d_Out_1, _ProjectionParams.z, _Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2);
                                                                                                                                float4 _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0 = IN.ScreenPosition;
                                                                                                                                float _Split_fabee40938d249f58c6df289b29487e6_R_1 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[0];
                                                                                                                                float _Split_fabee40938d249f58c6df289b29487e6_G_2 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[1];
                                                                                                                                float _Split_fabee40938d249f58c6df289b29487e6_B_3 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[2];
                                                                                                                                float _Split_fabee40938d249f58c6df289b29487e6_A_4 = _ScreenPosition_6b058d9edbbb42db800727927655692f_Out_0[3];
                                                                                                                                float _Property_b835ed47772e498ca3bfd0304467564a_Out_0 = _Depth;
                                                                                                                                float _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2;
                                                                                                                                Unity_Add_float(_Split_fabee40938d249f58c6df289b29487e6_A_4, _Property_b835ed47772e498ca3bfd0304467564a_Out_0, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2);
                                                                                                                                float _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2;
                                                                                                                                Unity_Subtract_float(_Multiply_02af91209ab440bca32a56ecfdbd8cde_Out_2, _Add_0073d0af8a87416f82bb8df4aa49b9c0_Out_2, _Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2);
                                                                                                                                float _Property_d4102fc229a94768ae4a93daed7fd849_Out_0 = _Strength;
                                                                                                                                float _Multiply_c032a0c444d84300a760598cbea78a62_Out_2;
                                                                                                                                Unity_Multiply_float_float(_Subtract_769bf8cd8e8341a581cb10d40173db2a_Out_2, _Property_d4102fc229a94768ae4a93daed7fd849_Out_0, _Multiply_c032a0c444d84300a760598cbea78a62_Out_2);
                                                                                                                                float _Clamp_e8c5093ba9604977add70348fe2134be_Out_3;
                                                                                                                                Unity_Clamp_float(_Multiply_c032a0c444d84300a760598cbea78a62_Out_2, 0, 1, _Clamp_e8c5093ba9604977add70348fe2134be_Out_3);
                                                                                                                                float4 _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3;
                                                                                                                                Unity_Lerp_float4(_Property_f669795152fd4d83bfe0251a331b5e7e_Out_0, _Property_41bdbb844d1a43e1ba4198d6218b3d69_Out_0, (_Clamp_e8c5093ba9604977add70348fe2134be_Out_3.xxxx), _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3);
                                                                                                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_R_1 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[0];
                                                                                                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_G_2 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[1];
                                                                                                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_B_3 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[2];
                                                                                                                                float _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4 = _Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3[3];
                                                                                                                                surface.BaseColor = (_Lerp_dd2766d9c5ca4dce9950fcfebe174b25_Out_3.xyz);
                                                                                                                                surface.Alpha = _Split_2b30a0ad4e8848e081a23cc709e367a2_A_4;
                                                                                                                                return surface;
                                                                                                                            }

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Build Graph Inputs
                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                                                                            #endif
                                                                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                                                                            {
                                                                                                                                VertexDescriptionInputs output;
                                                                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                                                                output.ObjectSpacePosition = input.positionOS;
                                                                                                                                output.uv0 = input.uv0;
                                                                                                                                output.TimeParameters = _TimeParameters.xyz;

                                                                                                                                return output;
                                                                                                                            }
                                                                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                                                                            {
                                                                                                                                SurfaceDescriptionInputs output;
                                                                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                                                                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                                                                            #endif







                                                                                                                                output.WorldSpacePosition = input.positionWS;
                                                                                                                                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                                                                            #else
                                                                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                                                                            #endif
                                                                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                                                                    return output;
                                                                                                                            }

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Main

                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                                                                                            // --------------------------------------------------
                                                                                                                            // Visual Effect Vertex Invocations
                                                                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                                                                            #endif

                                                                                                                            ENDHLSL
                                                                                                                            }
                                                                    }
                                                                        CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
                                                                                                                                CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
                                                                                                                                FallBack "Hidden/Shader Graph/FallbackError"
}

