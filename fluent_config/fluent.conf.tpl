@INCLUDE /ecs/service.conf
@INCLUDE /ecs/input-forward.conf
@INCLUDE /ecs/ecs-metadata.conf

[OUTPUT]
    Name s3
    Match logs.FRONTOFFICE_API_LOG_EVENT
    bucket ${FRONTOFFICE_API_LOG_BUCKET_NAME}
    region ${AWS_REGION}
    total_file_size ${FRONTOFFICE_API_LOG_FILE_SIZE}
    json_date_key timestamp
    upload_timeout 5m
    use_put_object Off
    compression gzip
    s3_key_format /logs/api/year=%Y/month=%m/day=%d/frontoffice-api-logs-%Y-%m-%d-%H-%M-$UUID.gz
    static_file_path On

[OUTPUT]
    Name cloudwatch_logs
    Match *-firelens-*
    region ${AWS_REGION}
    log_group_name ${LOG_GROUP_NAME}
    log_stream_prefix ecs/
    auto_create_group On

