Shader "Unlit/Deform"
{
    Properties
    {
        _DeformAmount ("Deform Amount", Float) = 1.0
        _DeformRadius ("Deform Radius", Float) = 5.0
        _PulseSpeed("Pulse Speed", float) = 2.0
        _TargetPosition ("Target Position", Vector) = (0,0,0,0)
        _MainTex ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _DeformAmount;
            float _DeformRadius;
            float _PulseSpeed;

            float4 _TargetPosition;

            sampler2D _MainTex;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                // Transform vertex and normal to world space
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 normalDir = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));

                // Distance to target
                float dist = distance(worldPos, _TargetPosition.xyz);
                float pulse = sin(_Time.y * 1.7) + cos(_Time.y * 3.1) + sin(_Time.y * 5.3);
                pulse = pulse * 0.3;
                pulse = pulse * 0.5 + 0.5;
                float deformStrength = smoothstep(_DeformRadius, 0.0, dist) * pulse; 
                deformStrength = clamp(deformStrength, 0.0, 0.1);

                // Deform in world space
                float3 displacedWorld = worldPos + normalDir * deformStrength * _DeformAmount;

                // Transform back to clip space
                v2f o;
                o.pos = UnityObjectToClipPos(float4(displacedWorld, 1.0));
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}
