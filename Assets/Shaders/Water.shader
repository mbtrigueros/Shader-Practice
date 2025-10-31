Shader "Custom/Water"
{
    Properties
    {
        _WaveSpeed ("Wave Speed", Float) = 1.0
        _WaveFrequency ("Wave Frequency", Float) = 1.0
        _WaveHeight ("Wave Height", Float) = 1.0
        _Glossiness ("Smoothness", Range(0,1)) = 0.8
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Color("Color", Color) = (0.2, 0.5, 0.8, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

        sampler2D _MainTex;
        float _WaveSpeed;
        float _WaveFrequency;
        float _WaveHeight;

        fixed4 _Color;

        half _Metallic;
        half _Glossiness;

        struct Input
        {
            float3 worldPos;
        };

        void vert(inout appdata_full v) {
            float time = _Time.y * _WaveSpeed;

            float waveX = sin(v.vertex.x * _WaveFrequency + time);
            float waveZ = cos(v.vertex.z * _WaveFrequency + time);

            float displacement = (waveX + waveZ) * 0.5 * _WaveHeight;
            v.vertex.y += displacement;

            v.normal = normalize(v.normal + float3(0, displacement * 5.0, 0));
        }


        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            
            float2 pos = IN.worldPos.xz * _WaveFrequency;
            float pattern = sin(pos.x + _Time.y * _WaveSpeed) * cos(pos.y + _Time.y * _WaveSpeed);

            pattern = saturate(pattern * 0.5 + 0.5);

            fixed3 finalColor = lerp(_Color.rgb * 0.6, _Color.rgb * 1.2, pattern);

            o.Albedo = finalColor;
            
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = 1.0;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
