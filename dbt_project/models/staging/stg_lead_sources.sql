WITH deduplicated_lead_sources AS (
    SELECT DISTINCT
        lead_source_code,
        lead_source_code_description,
        response_channel,
        response_channel_category
    FROM {{ source('model_landing', 'lead_sources') }}
)
SELECT *
FROM deduplicated_lead_sources
