
find_package(CUDA 10.0 EXACT REQUIRED cudart cublas curand)
list(APPEND GPU_ARCHS 62)

# Generate SASS for each architecture
foreach(arch ${GPU_ARCHS})
  set(GENCODES "${GENCODES} -gencode arch=compute_${arch},code=sm_${arch}")
endforeach()

# Generate PTX for the last architecture
list(GET GPU_ARCHS -1 LATEST_GPU_ARCH)
set(GENCODES "${GENCODES} -gencode arch=compute_${LATEST_GPU_ARCH},code=compute_${LATEST_GPU_ARCH}")


# Find TensorRT
find_path(TRT_INCLUDE_DIR NvInfer.h HINTS ${TRT_SDK_ROOT} PATH_SUFFIXES include)
if(${TRT_INCLUDE_DIR} MATCHES "TRT_INCLUDE_DIR-NOTFOUND")
  MESSAGE(FATAL_ERROR "-- Unable to find TensorRT headers. Please set path using -DTRT_SDK_ROOT")
else()
  MESSAGE(STATUS "Found TensorRT headers at ${TRT_INCLUDE_DIR}")
endif()

find_library(TRT_LIBRARY_INFER nvinfer HINTS ${TRT_SDK_ROOT} PATH_SUFFIXES lib lib64 lib/x64)
find_library(TRT_LIBRARY_INFER_PLUGIN nvinfer_plugin HINTS ${TRT_SDK_ROOT} PATH_SUFFIXES lib lib64 lib/x64)
find_library(TRT_LIBRARY_INFER_PARSERS nvparsers HINTS ${TRT_SDK_ROOT} PATH_SUFFIXES lib lib64 lib/x64)
find_library(TRT_LIBRARY_INFER_ONNX nvonnxparser HINTS ${TRT_SDK_ROOT} PATH_SUFFIXES lib lib64 lib/x64)
find_library(TRT_LIBRARY_INFER_CAFFE nvcaffe_parser HINTS ${TRT_SDK_ROOT} PATH_SUFFIXES lib lib64 lib/x64)


if((${TRT_LIBRARY_INFER} MATCHES "TRT_LIBRARY_INFER-NOTFOUND") OR (${TRT_LIBRARY_INFER_PLUGIN} MATCHES "TRT_LIBRARY_INFER_PLUGIN-NOTFOUND"))
  MESSAGE(FATAL_ERROR "-- Unable to find TensorRT libs. Please set path using -DTRT_SDK_ROOT")
else()
  set(TRT_LIBRARY ${TRT_LIBRARY_INFER} ${TRT_LIBRARY_INFER_PLUGIN} ${TRT_LIBRARY_INFER_ONNX} ${TRT_LIBRARY_INFER_CAFFE} ${TRT_LIBRARY_INFER_PARSERS})
  MESSAGE(STATUS "Found TensorRT libs at ${TRT_LIBRARY}")
endif()
