#include <stddef.h>
#include <stdio.h>

#include <simplecble/types.h>
#include <simplecble/config.h>
#include <simplecble/logging.h>

int main(void) {
    printf("pointer=%zu\n", sizeof(void*));
    printf("err=%zu\n", sizeof(simpleble_err_t));
    printf("os=%zu\n", sizeof(simpleble_os_t));
    printf("address_type=%zu\n", sizeof(simpleble_address_type_t));
    printf("bool=%zu\n", sizeof(bool));
    printf("android_priority=%zu\n", sizeof(simpleble_config_android_connection_priority_t));
    printf("log_level=%zu\n", sizeof(simpleble_log_level_t));
    printf("error.first=%d\n", SIMPLEBLE_ERROR_INVALID_ARGUMENT);
    printf("error.last=%d\n", SIMPLEBLE_ERROR_UNCLASSIFIED_EXCEPTION);
    printf("local.read=%d\n", SIMPLEBLE_LOCAL_CHARACTERISTIC_READ);
    printf("local.indicate=%d\n", SIMPLEBLE_LOCAL_CHARACTERISTIC_INDICATE);
    printf("android_priority.disabled=%d\n", SIMPLEBLE_CONFIG_ANDROID_CONNECTION_PRIORITY_DISABLED);
    printf("android_priority.dck=%d\n", SIMPLEBLE_CONFIG_ANDROID_CONNECTION_PRIORITY_DCK);
    printf("log.verbose=%d\n", SIMPLEBLE_LOG_LEVEL_VERBOSE);
    printf("uuid=%zu\n", sizeof(simpleble_uuid_t));
    printf("descriptor=%zu\n", sizeof(simpleble_descriptor_t));
    printf("characteristic=%zu\n", sizeof(simpleble_characteristic_t));
    printf("characteristic.descriptor_count=%zu\n",
           offsetof(simpleble_characteristic_t, descriptor_count));
    printf("characteristic.descriptors=%zu\n",
           offsetof(simpleble_characteristic_t, descriptors));
    printf("service=%zu\n", sizeof(simpleble_service_t));
    printf("service.data_length=%zu\n", offsetof(simpleble_service_t, data_length));
    printf("service.data=%zu\n", offsetof(simpleble_service_t, data));
    printf("service.characteristic_count=%zu\n",
           offsetof(simpleble_service_t, characteristic_count));
    printf("service.characteristics=%zu\n",
           offsetof(simpleble_service_t, characteristics));
    printf("manufacturer_data=%zu\n", sizeof(simpleble_manufacturer_data_t));
    printf("manufacturer_data.data_length=%zu\n",
           offsetof(simpleble_manufacturer_data_t, data_length));
    printf("manufacturer_data.data=%zu\n",
           offsetof(simpleble_manufacturer_data_t, data));
    return 0;
}
