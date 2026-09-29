#include <simplecble/simplecble.h>

#include <stdlib.h>
#include <string.h>

#ifndef SIMPLEBLE_FIXTURE_VERSION
#define SIMPLEBLE_FIXTURE_VERSION "1.2.0"
#endif

struct simpleble_error {
    simpleble_err_t code;
    const char* message;
};

static size_t service_releases;
static size_t manufacturer_releases;
static size_t buffer_releases;
static size_t error_releases;

static void set_error(simpleble_error_t** out_error) {
    if (out_error == NULL) return;
    simpleble_error_release(out_error);
    *out_error = malloc(sizeof(**out_error));
    if (*out_error != NULL) {
        (*out_error)->code = SIMPLEBLE_ERROR_OPERATION_FAILED;
        (*out_error)->message = "fixture failure";
    }
}

const char* simpleble_get_version(void) { return SIMPLEBLE_FIXTURE_VERSION; }

simpleble_err_t simpleble_error_code(const simpleble_error_t* error) {
    return error->code;
}

const char* simpleble_error_message(const simpleble_error_t* error) {
    return error->message;
}

void simpleble_error_release(simpleble_error_t** error) {
    if (error != NULL && *error != NULL) {
        free(*error);
        *error = NULL;
        ++error_releases;
    }
}

void simpleble_free(void* handle) {
    if (handle != NULL) {
        free(handle);
        ++buffer_releases;
    }
}

void simpleble_peripheral_services_get(simpleble_peripheral_t handle, size_t index,
                                      simpleble_service_t* out_service,
                                      simpleble_error_t** out_error) {
    (void)handle;
    memset(out_service, 0, sizeof(*out_service));
    if (out_error != NULL) *out_error = NULL;
    out_service->uuid.value[0] = 's';
    out_service->data_length = 2;
    out_service->data = malloc(2);
    out_service->data[0] = 0x42;
    out_service->data[1] = 0x43;
    out_service->characteristic_count = 1;
    out_service->characteristics = calloc(1, sizeof(simpleble_characteristic_t));
    out_service->characteristics[0].uuid.value[0] = 'c';
    out_service->characteristics[0].can_notify = true;
    out_service->characteristics[0].descriptor_count = 1;
    out_service->characteristics[0].descriptors = calloc(1, sizeof(simpleble_descriptor_t));
    out_service->characteristics[0].descriptors[0].uuid.value[0] = 'd';
    if (index == 1) set_error(out_error);
}

void simpleble_service_release(simpleble_service_t* service) {
    for (size_t i = 0; i < service->characteristic_count; ++i)
        free(service->characteristics[i].descriptors);
    free(service->characteristics);
    free(service->data);
    memset(service, 0, sizeof(*service));
    ++service_releases;
}

void simpleble_peripheral_manufacturer_data_get(simpleble_peripheral_t handle,
                                               size_t index,
                                               simpleble_manufacturer_data_t* out_data,
                                               simpleble_error_t** out_error) {
    (void)handle;
    (void)index;
    memset(out_data, 0, sizeof(*out_data));
    if (out_error != NULL) *out_error = NULL;
    out_data->manufacturer_id = 0x1234;
    out_data->data_length = 2;
    out_data->data = malloc(2);
    out_data->data[0] = 0x51;
    out_data->data[1] = 0x52;
}

void simpleble_manufacturer_data_release(simpleble_manufacturer_data_t* data) {
    free(data->data);
    memset(data, 0, sizeof(*data));
    ++manufacturer_releases;
}

uint8_t* simpleble_peripheral_read(simpleble_peripheral_t handle,
                                   simpleble_uuid_t service,
                                   simpleble_uuid_t characteristic,
                                   size_t* data_length,
                                   simpleble_error_t** out_error) {
    (void)handle;
    *data_length = 0;
    if (out_error != NULL) *out_error = NULL;
    if (service.value[0] != 's' || characteristic.value[0] != 'c') {
        set_error(out_error);
        return NULL;
    }
    /* An empty value may still have an allocated buffer. */
    return malloc(1);
}

size_t simpleble_fixture_release_count(unsigned kind) {
    switch (kind) {
        case 0: return service_releases;
        case 1: return manufacturer_releases;
        case 2: return buffer_releases;
        case 3: return error_releases;
        default: return 0;
    }
}

void simpleble_fixture_reset_counts(void) {
    service_releases = manufacturer_releases = buffer_releases = error_releases = 0;
}

typedef void (*scan_callback_t)(simpleble_adapter_t, simpleble_peripheral_t, void*);
typedef void (*notify_callback_t)(simpleble_peripheral_t, simpleble_uuid_t,
                                  simpleble_uuid_t, const uint8_t*, size_t, void*);
typedef const uint8_t* (*read_callback_t)(simpleble_local_characteristic_t,
                                          size_t*, void*);
typedef bool (*passkey_callback_t)(simpleble_peripheral_t, const char*, void*);

/* Calls the Pascal callbacks across the C ABI, including UUIDs passed by value. */
bool simpleble_fixture_invoke_callbacks(scan_callback_t scan,
                                        notify_callback_t notify,
                                        read_callback_t read_value,
                                        passkey_callback_t passkey,
                                        simpleble_log_callback_t log,
                                        void* userdata) {
    simpleble_uuid_t service = {{0}};
    simpleble_uuid_t characteristic = {{0}};
    const uint8_t bytes[] = {0x21, 0x22};
    size_t length = 0;
    service.value[0] = 's';
    characteristic.value[0] = 'c';
    scan((void*)0x12, (void*)0x34, userdata);
    notify((void*)0x34, service, characteristic, bytes, 2, userdata);
    const uint8_t* value = read_value((void*)0x56, &length, userdata);
    bool accepted = passkey((void*)0x34, "123456", userdata);
    log(SIMPLEBLE_LOG_LEVEL_INFO, "fixture", "fixture.c", 17, "invoke", "callback");
    return value != NULL && length == 2 && value[0] == 0x21 &&
           value[1] == 0x22 && accepted;
}
