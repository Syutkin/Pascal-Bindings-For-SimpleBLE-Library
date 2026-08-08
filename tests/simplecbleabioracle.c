#include <stddef.h>
#include <stdio.h>

#include <simplecble/types.h>

int main(void) {
    printf("pointer=%zu\n", sizeof(void*));
    printf("err=%zu\n", sizeof(simpleble_err_t));
    printf("os=%zu\n", sizeof(simpleble_os_t));
    printf("address_type=%zu\n", sizeof(simpleble_address_type_t));
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
