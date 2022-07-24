#include <alloca.h>
#include <stdlib.h>
#include <string.h>

#include <postgres.h>
#include <utils/array.h>
#include <utils/geo_decls.h>

#include <fmgr.h>

PG_MODULE_MAGIC;

int compareDouble(const void *arg1, const void *arg2);
int compareDouble(const void *arg1, const void *arg2) {
  double d1 = *((double *)arg1);
  double d2 = *((double *)arg2);
  return (d1 < d2) - (d2 < d1);
}

PG_FUNCTION_INFO_V1(nocode_median);

Datum nocode_median(PG_FUNCTION_ARGS) {
  ArrayType *arg0 = PG_GETARG_ARRAYTYPE_P(0);
  // array size in bytes including the header
  int arrSize = ARR_SIZE(arg0);
  // distance from start of array header to data
  int offset = (ARR_DATA_PTR(arg0) - (char *)arg0);
  // amount of raw data in raw bytes
  int rawSize = arrSize - offset;
  if (rawSize <= 0) {
    PG_RETURN_FLOAT8(0.0 / 0.0);
  }
  // fprintf(stderr, "data length: %d\n", rawSize);
  int N = rawSize / 8;
  // already does not contain null values, no need to check for null then;
  float8 *data = alloca(rawSize); // float8 data[N];
  memcpy(data, ARR_DATA_PTR(arg0), rawSize);

  for (int i = 0; i < N; i++) {
    if (data[i] != data[i]) { // is nan?
      // nan in the arguments means forward nan
      PG_RETURN_FLOAT8(0.0 / 0.0);
    }
  }

  qsort(data, N, sizeof(float8), compareDouble);
  double result = 0;
  if (N & 1) {
    result = data[N >> 1];
  } else {
    result = data[N >> 1] * 0.5 + data[(N >> 1) - 1] * 0.5;
  }
  PG_RETURN_FLOAT8(result);
}

PG_FUNCTION_INFO_V1(nocode_average);

Datum nocode_average(PG_FUNCTION_ARGS) {
  ArrayType *arg0 = PG_GETARG_ARRAYTYPE_P(0);
  // array size in bytes including the header
  int arrSize = ARR_SIZE(arg0);
  // distance from start of array header to data
  int offset = (ARR_DATA_PTR(arg0) - (char *)arg0);
  // amount of raw data in raw bytes
  int rawSize = arrSize - offset;
  if (rawSize <= 0) {
    PG_RETURN_FLOAT8(0.0 / 0.0);
  }
  // fprintf(stderr, "data length: %d\n", rawSize);
  int N = rawSize / 8;
  // already does not contain null values, no need to check for null then;
  float8 *data = alloca(rawSize); // float8 data[N];
  memcpy(data, ARR_DATA_PTR(arg0), rawSize);

  float8 sum = 0;
  for (int i = 0; i < N; i++) {
    if (data[i] != data[i]) { // is nan?
      PG_RETURN_FLOAT8(0.0 / 0.0);
    }
    sum += data[i];
  }
  PG_RETURN_FLOAT8(sum / N);
}

PG_FUNCTION_INFO_V1(nocode_ieee_div);

Datum nocode_ieee_div(PG_FUNCTION_ARGS) {
  if (PG_ARGISNULL(0) || PG_ARGISNULL(1)) {
    PG_RETURN_NULL();
  } else {
    float8 arg1 = PG_GETARG_FLOAT8(0);
    float8 arg2 = PG_GETARG_FLOAT8(1);
    PG_RETURN_FLOAT8(arg1 / arg2);
  }
}
