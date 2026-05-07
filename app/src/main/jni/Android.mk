# JNI Native Exploit Code
# CVE-2026-21385 + CVE-2026-31431 Android Root Exploit

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := exploit
LOCAL_SRC_FILES := exploit.c
LOCAL_C_INCLUDES := $(LOCAL_PATH)
LOCAL_LDFLAGS := -llog -landroid
LOCAL_ARM_MODE := arm
include $(BUILD_SHARED_LIBRARY)
