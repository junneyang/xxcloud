#COMAKE2 edit-mode: -*- Makefile -*-
####################64Bit Mode####################
ifeq ($(shell uname -m),x86_64)
CC=gcc
CXX=g++
CXXFLAGS=-g \
  -pipe \
  -W \
  -Wall \
  -fPIC
CFLAGS=-g \
  -pipe \
  -W \
  -Wall \
  -fPIC
CPPFLAGS=-D_GNU_SOURCE \
  -D__STDC_LIMIT_MACROS \
  -DVERSION=\"1.0.0.0\"
INCPATH=-I. \
  -I./proto \
  -I./src \
  -I./com/rapidjson-master/include \
  -I./com/jsoncpp-src-0.5.0/include
DEP_INCPATH=-I../../../../../../com/idlcompiler \
  -I../../../../../../com/idlcompiler/include \
  -I../../../../../../com/idlcompiler/output \
  -I../../../../../../com/idlcompiler/output/include \
  -I../../../../../../inf/common/share \
  -I../../../../../../inf/common/share/include \
  -I../../../../../../inf/common/share/output \
  -I../../../../../../inf/common/share/output/include \
  -I../../../../../../lib2-64/bsl \
  -I../../../../../../lib2-64/bsl/include \
  -I../../../../../../lib2-64/bsl/output \
  -I../../../../../../lib2-64/bsl/output/include \
  -I../../../../../../lib2-64/dict \
  -I../../../../../../lib2-64/dict/include \
  -I../../../../../../lib2-64/dict/output \
  -I../../../../../../lib2-64/dict/output/include \
  -I../../../../../../lib2-64/ullib \
  -I../../../../../../lib2-64/ullib/include \
  -I../../../../../../lib2-64/ullib/output \
  -I../../../../../../lib2-64/ullib/output/include \
  -I../../../../../../op/oped/noah/webfoot/naming-lib \
  -I../../../../../../op/oped/noah/webfoot/naming-lib/include \
  -I../../../../../../op/oped/noah/webfoot/naming-lib/output \
  -I../../../../../../op/oped/noah/webfoot/naming-lib/output/include \
  -I../../../../../../public/bslext \
  -I../../../../../../public/bslext/include \
  -I../../../../../../public/bslext/output \
  -I../../../../../../public/bslext/output/include \
  -I../../../../../../public/comlog-plugin \
  -I../../../../../../public/comlog-plugin/include \
  -I../../../../../../public/comlog-plugin/output \
  -I../../../../../../public/comlog-plugin/output/include \
  -I../../../../../../public/configure \
  -I../../../../../../public/configure/include \
  -I../../../../../../public/configure/output \
  -I../../../../../../public/configure/output/include \
  -I../../../../../../public/connectpool \
  -I../../../../../../public/connectpool/include \
  -I../../../../../../public/connectpool/output \
  -I../../../../../../public/connectpool/output/include \
  -I../../../../../../public/hulu/pbrpc \
  -I../../../../../../public/hulu/pbrpc/include \
  -I../../../../../../public/hulu/pbrpc/output \
  -I../../../../../../public/hulu/pbrpc/output/include \
  -I../../../../../../public/hulu/saber \
  -I../../../../../../public/hulu/saber/include \
  -I../../../../../../public/hulu/saber/output \
  -I../../../../../../public/hulu/saber/output/include \
  -I../../../../../../public/idlcompiler \
  -I../../../../../../public/idlcompiler/include \
  -I../../../../../../public/idlcompiler/output \
  -I../../../../../../public/idlcompiler/output/include \
  -I../../../../../../public/mcpack \
  -I../../../../../../public/mcpack/include \
  -I../../../../../../public/mcpack/output \
  -I../../../../../../public/mcpack/output/include \
  -I../../../../../../public/nshead \
  -I../../../../../../public/nshead/include \
  -I../../../../../../public/nshead/output \
  -I../../../../../../public/nshead/output/include \
  -I../../../../../../public/odict \
  -I../../../../../../public/odict/include \
  -I../../../../../../public/odict/output \
  -I../../../../../../public/odict/output/include \
  -I../../../../../../public/pbrpc \
  -I../../../../../../public/pbrpc/include \
  -I../../../../../../public/pbrpc/output \
  -I../../../../../../public/pbrpc/output/include \
  -I../../../../../../public/protobuf-json \
  -I../../../../../../public/protobuf-json/include \
  -I../../../../../../public/protobuf-json/output \
  -I../../../../../../public/protobuf-json/output/include \
  -I../../../../../../public/sofa-pbrpc \
  -I../../../../../../public/sofa-pbrpc/include \
  -I../../../../../../public/sofa-pbrpc/output \
  -I../../../../../../public/sofa-pbrpc/output/include \
  -I../../../../../../public/spreg \
  -I../../../../../../public/spreg/include \
  -I../../../../../../public/spreg/output \
  -I../../../../../../public/spreg/output/include \
  -I../../../../../../public/ub \
  -I../../../../../../public/ub/include \
  -I../../../../../../public/ub/output \
  -I../../../../../../public/ub/output/include \
  -I../../../../../../public/uconv \
  -I../../../../../../public/uconv/include \
  -I../../../../../../public/uconv/output \
  -I../../../../../../public/uconv/output/include \
  -I../../../../../../third-64/pcre \
  -I../../../../../../third-64/pcre/include \
  -I../../../../../../third-64/pcre/output \
  -I../../../../../../third-64/pcre/output/include \
  -I../../../../../../third-64/protobuf \
  -I../../../../../../third-64/protobuf/include \
  -I../../../../../../third-64/protobuf/output \
  -I../../../../../../third-64/protobuf/output/include \
  -I../../../../../../third-64/snappy \
  -I../../../../../../third-64/snappy/include \
  -I../../../../../../third-64/snappy/output \
  -I../../../../../../third-64/snappy/output/include

#============ CCP vars ============
CCHECK=@ccheck.py
CCHECK_FLAGS=
PCLINT=@pclint
PCLINT_FLAGS=
CCP=@ccp.py
CCP_FLAGS=


#COMAKE UUID
COMAKE_MD5=1f13ccff1e5b9a9a44dec2ee74e32f4b  COMAKE


.PHONY:all
all:comake2_makefile_check pbrpcclient pbrpcbenchmark 
	@echo "[COMAKE:BUILD][Target:'all']"
	@echo "make all done"

.PHONY:comake2_makefile_check
comake2_makefile_check:
	@echo "[COMAKE:BUILD][Target:'comake2_makefile_check']"
	#in case of error, update 'Makefile' by 'comake2'
	@echo "$(COMAKE_MD5)">comake2.md5
	@md5sum -c --status comake2.md5
	@rm -f comake2.md5

.PHONY:ccpclean
ccpclean:
	@echo "[COMAKE:BUILD][Target:'ccpclean']"
	@echo "make ccpclean done"

.PHONY:clean
clean:ccpclean
	@echo "[COMAKE:BUILD][Target:'clean']"
	rm -rf pbrpcclient
	rm -rf pbrpcbenchmark
	rm -rf src/pbrpcclient_pbrpcclient.o
	rm -rf src/pbrpcclient_common.o
	rm -rf proto/pbrpcclient_common.pb.o
	rm -rf proto/pbrpcclient_echo.pb.o
	rm -rf proto/pbrpcclient_helloworld.pb.o
	rm -rf proto/pbrpcclient_ipc.pb.o
	rm -rf proto/pbrpcclient_pbrpc.pb.o
	rm -rf proto/pbrpcclient_pbrpc_service.pb.o
	rm -rf proto/pbrpcclient_regist_condition.pb.o
	rm -rf proto/pbrpcclient_transport.pb.o
	rm -rf com/jsoncpp-src-0.5.0/src/lib_json/pbrpcclient_json_reader.o
	rm -rf com/jsoncpp-src-0.5.0/src/lib_json/pbrpcclient_json_value.o
	rm -rf com/jsoncpp-src-0.5.0/src/lib_json/pbrpcclient_json_writer.o
	rm -rf src/pbrpcbenchmark_pbrpcbenchmark.o
	rm -rf src/pbrpcbenchmark_common.o
	rm -rf src/pbrpcbenchmark_requestthreadpool.o
	rm -rf proto/pbrpcbenchmark_common.pb.o
	rm -rf proto/pbrpcbenchmark_echo.pb.o
	rm -rf proto/pbrpcbenchmark_helloworld.pb.o
	rm -rf proto/pbrpcbenchmark_ipc.pb.o
	rm -rf proto/pbrpcbenchmark_pbrpc.pb.o
	rm -rf proto/pbrpcbenchmark_pbrpc_service.pb.o
	rm -rf proto/pbrpcbenchmark_regist_condition.pb.o
	rm -rf proto/pbrpcbenchmark_transport.pb.o
	rm -rf com/jsoncpp-src-0.5.0/src/lib_json/pbrpcbenchmark_json_reader.o
	rm -rf com/jsoncpp-src-0.5.0/src/lib_json/pbrpcbenchmark_json_value.o
	rm -rf com/jsoncpp-src-0.5.0/src/lib_json/pbrpcbenchmark_json_writer.o

.PHONY:dist
dist:
	@echo "[COMAKE:BUILD][Target:'dist']"
	tar czvf output.tar.gz output
	@echo "make dist done"

.PHONY:distclean
distclean:clean
	@echo "[COMAKE:BUILD][Target:'distclean']"
	rm -f output.tar.gz
	@echo "make distclean done"

.PHONY:love
love:
	@echo "[COMAKE:BUILD][Target:'love']"
	@echo "make love done"

pbrpcclient:src/pbrpcclient_pbrpcclient.o \
  src/pbrpcclient_common.o \
  proto/pbrpcclient_common.pb.o \
  proto/pbrpcclient_echo.pb.o \
  proto/pbrpcclient_helloworld.pb.o \
  proto/pbrpcclient_ipc.pb.o \
  proto/pbrpcclient_pbrpc.pb.o \
  proto/pbrpcclient_pbrpc_service.pb.o \
  proto/pbrpcclient_regist_condition.pb.o \
  proto/pbrpcclient_transport.pb.o \
  com/jsoncpp-src-0.5.0/src/lib_json/pbrpcclient_json_reader.o \
  com/jsoncpp-src-0.5.0/src/lib_json/pbrpcclient_json_value.o \
  com/jsoncpp-src-0.5.0/src/lib_json/pbrpcclient_json_writer.o
	@echo "[COMAKE:BUILD][Target:'pbrpcclient']"
	$(CXX) src/pbrpcclient_pbrpcclient.o \
  src/pbrpcclient_common.o \
  proto/pbrpcclient_common.pb.o \
  proto/pbrpcclient_echo.pb.o \
  proto/pbrpcclient_helloworld.pb.o \
  proto/pbrpcclient_ipc.pb.o \
  proto/pbrpcclient_pbrpc.pb.o \
  proto/pbrpcclient_pbrpc_service.pb.o \
  proto/pbrpcclient_regist_condition.pb.o \
  proto/pbrpcclient_transport.pb.o \
  com/jsoncpp-src-0.5.0/src/lib_json/pbrpcclient_json_reader.o \
  com/jsoncpp-src-0.5.0/src/lib_json/pbrpcclient_json_value.o \
  com/jsoncpp-src-0.5.0/src/lib_json/pbrpcclient_json_writer.o -Xlinker "-("  ../../../../../../com/idlcompiler/astyle/libastyle.a \
  ../../../../../../com/idlcompiler/cxx/libskeleton.a \
  ../../../../../../com/idlcompiler/java/libjava_skeleton.a \
  ../../../../../../com/idlcompiler/parser/libparser.a \
  ../../../../../../com/idlcompiler/php/libphp_skeleton.a \
  ../../../../../../inf/common/share/libshare.a \
  ../../../../../../lib2-64/bsl/lib/libbsl.a \
  ../../../../../../lib2-64/bsl/lib/libbsl_ResourcePool.a \
  ../../../../../../lib2-64/bsl/lib/libbsl_archive.a \
  ../../../../../../lib2-64/bsl/lib/libbsl_buffer.a \
  ../../../../../../lib2-64/bsl/lib/libbsl_check_cast.a \
  ../../../../../../lib2-64/bsl/lib/libbsl_exception.a \
  ../../../../../../lib2-64/bsl/lib/libbsl_pool.a \
  ../../../../../../lib2-64/bsl/lib/libbsl_utils.a \
  ../../../../../../lib2-64/bsl/lib/libbsl_var.a \
  ../../../../../../lib2-64/bsl/lib/libbsl_var_implement.a \
  ../../../../../../lib2-64/bsl/lib/libbsl_var_utils.a \
  ../../../../../../lib2-64/dict/lib/libuldict.a \
  ../../../../../../lib2-64/ullib/lib/libullib.a \
  ../../../../../../op/oped/noah/webfoot/naming-lib/output/lib/libwebfoot_naming.a \
  ../../../../../../public/bslext/output/lib/libbsl_bml.a \
  ../../../../../../public/bslext/output/lib/libbsl_containers_utils.a \
  ../../../../../../public/bslext/output/lib/libbsl_var_scripting.a \
  ../../../../../../public/bslext/output/lib/libbsl_var_serializer.a \
  ../../../../../../public/bslext/output/lib/libbsl_var_vscript.a \
  ../../../../../../public/bslext/output/lib/libbsl_vs.a \
  ../../../../../../public/bslext/output/lib/libbslext.a \
  ../../../../../../public/comlog-plugin/libcomlog.a \
  ../../../../../../public/comlog-plugin/output/lib/libdfsappender.a \
  ../../../../../../public/configure/libconfig.a \
  ../../../../../../public/connectpool/libconnectpool.a \
  ../../../../../../public/hulu/pbrpc/output/lib/libpbrpc.a \
  ../../../../../../public/hulu/saber/libsaber.a \
  ../../../../../../public/idlcompiler/output/lib/libmcpack_idl.a \
  ../../../../../../public/mcpack/libmcpack.a \
  ../../../../../../public/nshead/libnshead.a \
  ../../../../../../public/odict/libodict.a \
  ../../../../../../public/pbrpc/output/lib/libpbrpc-client.a \
  ../../../../../../public/pbrpc/output/lib/libpbrpc-server.a \
  ../../../../../../public/pbrpc/output/lib/libpbrpc-util.a \
  ../../../../../../public/pbrpc/output/lib/libpbrpc.a \
  ../../../../../../public/protobuf-json/output/lib/libjson-pb.a \
  ../../../../../../public/sofa-pbrpc/lib/libsofa_pbrpc.a \
  ../../../../../../public/spreg/libspreg.a \
  ../../../../../../public/ub/output/lib/libub.a \
  ../../../../../../public/ub/output/lib/libub_aserver.a \
  ../../../../../../public/ub/output/lib/libub_client.a \
  ../../../../../../public/ub/output/lib/libub_conf.a \
  ../../../../../../public/ub/output/lib/libub_galileo.a \
  ../../../../../../public/ub/output/lib/libub_log.a \
  ../../../../../../public/ub/output/lib/libub_misc.a \
  ../../../../../../public/ub/output/lib/libub_monitor.a \
  ../../../../../../public/ub/output/lib/libub_naming.a \
  ../../../../../../public/ub/output/lib/libub_server.a \
  ../../../../../../public/ub/output/lib/libubex.a \
  ../../../../../../public/ub/output/lib/libubfw.a \
  ../../../../../../public/uconv/libuconv.a \
  ../../../../../../third-64/pcre/lib/libpcre.a \
  ../../../../../../third-64/pcre/lib/libpcrecpp.a \
  ../../../../../../third-64/pcre/lib/libpcreposix.a \
  ../../../../../../third-64/protobuf/lib/libprotobuf-lite.a \
  ../../../../../../third-64/protobuf/lib/libprotobuf.a \
  ../../../../../../third-64/protobuf/lib/libprotoc.a \
  ../../../../../../third-64/snappy/lib/libsnappy.a -lpthread \
  -lcrypto \
  -lrt -Xlinker "-)" -o pbrpcclient

pbrpcbenchmark:src/pbrpcbenchmark_pbrpcbenchmark.o \
  src/pbrpcbenchmark_common.o \
  src/pbrpcbenchmark_requestthreadpool.o \
  proto/pbrpcbenchmark_common.pb.o \
  proto/pbrpcbenchmark_echo.pb.o \
  proto/pbrpcbenchmark_helloworld.pb.o \
  proto/pbrpcbenchmark_ipc.pb.o \
  proto/pbrpcbenchmark_pbrpc.pb.o \
  proto/pbrpcbenchmark_pbrpc_service.pb.o \
  proto/pbrpcbenchmark_regist_condition.pb.o \
  proto/pbrpcbenchmark_transport.pb.o \
  com/jsoncpp-src-0.5.0/src/lib_json/pbrpcbenchmark_json_reader.o \
  com/jsoncpp-src-0.5.0/src/lib_json/pbrpcbenchmark_json_value.o \
  com/jsoncpp-src-0.5.0/src/lib_json/pbrpcbenchmark_json_writer.o
	@echo "[COMAKE:BUILD][Target:'pbrpcbenchmark']"
	$(CXX) src/pbrpcbenchmark_pbrpcbenchmark.o \
  src/pbrpcbenchmark_common.o \
  src/pbrpcbenchmark_requestthreadpool.o \
  proto/pbrpcbenchmark_common.pb.o \
  proto/pbrpcbenchmark_echo.pb.o \
  proto/pbrpcbenchmark_helloworld.pb.o \
  proto/pbrpcbenchmark_ipc.pb.o \
  proto/pbrpcbenchmark_pbrpc.pb.o \
  proto/pbrpcbenchmark_pbrpc_service.pb.o \
  proto/pbrpcbenchmark_regist_condition.pb.o \
  proto/pbrpcbenchmark_transport.pb.o \
  com/jsoncpp-src-0.5.0/src/lib_json/pbrpcbenchmark_json_reader.o \
  com/jsoncpp-src-0.5.0/src/lib_json/pbrpcbenchmark_json_value.o \
  com/jsoncpp-src-0.5.0/src/lib_json/pbrpcbenchmark_json_writer.o -Xlinker "-("  ../../../../../../com/idlcompiler/astyle/libastyle.a \
  ../../../../../../com/idlcompiler/cxx/libskeleton.a \
  ../../../../../../com/idlcompiler/java/libjava_skeleton.a \
  ../../../../../../com/idlcompiler/parser/libparser.a \
  ../../../../../../com/idlcompiler/php/libphp_skeleton.a \
  ../../../../../../inf/common/share/libshare.a \
  ../../../../../../lib2-64/bsl/lib/libbsl.a \
  ../../../../../../lib2-64/bsl/lib/libbsl_ResourcePool.a \
  ../../../../../../lib2-64/bsl/lib/libbsl_archive.a \
  ../../../../../../lib2-64/bsl/lib/libbsl_buffer.a \
  ../../../../../../lib2-64/bsl/lib/libbsl_check_cast.a \
  ../../../../../../lib2-64/bsl/lib/libbsl_exception.a \
  ../../../../../../lib2-64/bsl/lib/libbsl_pool.a \
  ../../../../../../lib2-64/bsl/lib/libbsl_utils.a \
  ../../../../../../lib2-64/bsl/lib/libbsl_var.a \
  ../../../../../../lib2-64/bsl/lib/libbsl_var_implement.a \
  ../../../../../../lib2-64/bsl/lib/libbsl_var_utils.a \
  ../../../../../../lib2-64/dict/lib/libuldict.a \
  ../../../../../../lib2-64/ullib/lib/libullib.a \
  ../../../../../../op/oped/noah/webfoot/naming-lib/output/lib/libwebfoot_naming.a \
  ../../../../../../public/bslext/output/lib/libbsl_bml.a \
  ../../../../../../public/bslext/output/lib/libbsl_containers_utils.a \
  ../../../../../../public/bslext/output/lib/libbsl_var_scripting.a \
  ../../../../../../public/bslext/output/lib/libbsl_var_serializer.a \
  ../../../../../../public/bslext/output/lib/libbsl_var_vscript.a \
  ../../../../../../public/bslext/output/lib/libbsl_vs.a \
  ../../../../../../public/bslext/output/lib/libbslext.a \
  ../../../../../../public/comlog-plugin/libcomlog.a \
  ../../../../../../public/comlog-plugin/output/lib/libdfsappender.a \
  ../../../../../../public/configure/libconfig.a \
  ../../../../../../public/connectpool/libconnectpool.a \
  ../../../../../../public/hulu/pbrpc/output/lib/libpbrpc.a \
  ../../../../../../public/hulu/saber/libsaber.a \
  ../../../../../../public/idlcompiler/output/lib/libmcpack_idl.a \
  ../../../../../../public/mcpack/libmcpack.a \
  ../../../../../../public/nshead/libnshead.a \
  ../../../../../../public/odict/libodict.a \
  ../../../../../../public/pbrpc/output/lib/libpbrpc-client.a \
  ../../../../../../public/pbrpc/output/lib/libpbrpc-server.a \
  ../../../../../../public/pbrpc/output/lib/libpbrpc-util.a \
  ../../../../../../public/pbrpc/output/lib/libpbrpc.a \
  ../../../../../../public/protobuf-json/output/lib/libjson-pb.a \
  ../../../../../../public/sofa-pbrpc/lib/libsofa_pbrpc.a \
  ../../../../../../public/spreg/libspreg.a \
  ../../../../../../public/ub/output/lib/libub.a \
  ../../../../../../public/ub/output/lib/libub_aserver.a \
  ../../../../../../public/ub/output/lib/libub_client.a \
  ../../../../../../public/ub/output/lib/libub_conf.a \
  ../../../../../../public/ub/output/lib/libub_galileo.a \
  ../../../../../../public/ub/output/lib/libub_log.a \
  ../../../../../../public/ub/output/lib/libub_misc.a \
  ../../../../../../public/ub/output/lib/libub_monitor.a \
  ../../../../../../public/ub/output/lib/libub_naming.a \
  ../../../../../../public/ub/output/lib/libub_server.a \
  ../../../../../../public/ub/output/lib/libubex.a \
  ../../../../../../public/ub/output/lib/libubfw.a \
  ../../../../../../public/uconv/libuconv.a \
  ../../../../../../third-64/pcre/lib/libpcre.a \
  ../../../../../../third-64/pcre/lib/libpcrecpp.a \
  ../../../../../../third-64/pcre/lib/libpcreposix.a \
  ../../../../../../third-64/protobuf/lib/libprotobuf-lite.a \
  ../../../../../../third-64/protobuf/lib/libprotobuf.a \
  ../../../../../../third-64/protobuf/lib/libprotoc.a \
  ../../../../../../third-64/snappy/lib/libsnappy.a -lpthread \
  -lcrypto \
  -lrt -Xlinker "-)" -o pbrpcbenchmark

src/pbrpcclient_pbrpcclient.o:src/pbrpcclient.cpp \
  src/common.h \
  com/rapidjson-master/include/rapidjson/document.h \
  com/rapidjson-master/include/rapidjson/reader.h \
  com/rapidjson-master/include/rapidjson/rapidjson.h \
  com/rapidjson-master/include/rapidjson/allocators.h \
  com/rapidjson-master/include/rapidjson/encodings.h \
  com/rapidjson-master/include/rapidjson/internal/meta.h \
  com/rapidjson-master/include/rapidjson/internal/pow10.h \
  com/rapidjson-master/include/rapidjson/internal/stack.h \
  com/rapidjson-master/include/rapidjson/error/error.h \
  com/rapidjson-master/include/rapidjson/internal/strfunc.h \
  com/rapidjson-master/include/rapidjson/writer.h \
  com/rapidjson-master/include/rapidjson/internal/dtoa.h \
  com/rapidjson-master/include/rapidjson/internal/itoa.h \
  com/rapidjson-master/include/rapidjson/internal/itoa.h \
  com/rapidjson-master/include/rapidjson/stringbuffer.h \
  com/rapidjson-master/include/rapidjson/stringbuffer.h \
  proto/user_proto.h \
  proto/common.pb.h \
  proto/echo.pb.h \
  proto/helloworld.pb.h \
  proto/ipc.pb.h \
  proto/pbrpc.pb.h \
  proto/pbrpc_service.pb.h \
  proto/regist_condition.pb.h \
  proto/transport.pb.h \
  com/jsoncpp-src-0.5.0/include/json/json.h \
  com/jsoncpp-src-0.5.0/include/json/autolink.h \
  com/jsoncpp-src-0.5.0/include/json/config.h \
  com/jsoncpp-src-0.5.0/include/json/value.h \
  com/jsoncpp-src-0.5.0/include/json/forwards.h \
  com/jsoncpp-src-0.5.0/include/json/reader.h \
  com/jsoncpp-src-0.5.0/include/json/features.h \
  com/jsoncpp-src-0.5.0/include/json/writer.h
	@echo "[COMAKE:BUILD][Target:'src/pbrpcclient_pbrpcclient.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o src/pbrpcclient_pbrpcclient.o src/pbrpcclient.cpp

src/pbrpcclient_common.o:src/common.cpp \
  src/common.h \
  com/rapidjson-master/include/rapidjson/document.h \
  com/rapidjson-master/include/rapidjson/reader.h \
  com/rapidjson-master/include/rapidjson/rapidjson.h \
  com/rapidjson-master/include/rapidjson/allocators.h \
  com/rapidjson-master/include/rapidjson/encodings.h \
  com/rapidjson-master/include/rapidjson/internal/meta.h \
  com/rapidjson-master/include/rapidjson/internal/pow10.h \
  com/rapidjson-master/include/rapidjson/internal/stack.h \
  com/rapidjson-master/include/rapidjson/error/error.h \
  com/rapidjson-master/include/rapidjson/internal/strfunc.h \
  com/rapidjson-master/include/rapidjson/writer.h \
  com/rapidjson-master/include/rapidjson/internal/dtoa.h \
  com/rapidjson-master/include/rapidjson/internal/itoa.h \
  com/rapidjson-master/include/rapidjson/internal/itoa.h \
  com/rapidjson-master/include/rapidjson/stringbuffer.h \
  com/rapidjson-master/include/rapidjson/stringbuffer.h \
  proto/user_proto.h \
  proto/common.pb.h \
  proto/echo.pb.h \
  proto/helloworld.pb.h \
  proto/ipc.pb.h \
  proto/pbrpc.pb.h \
  proto/pbrpc_service.pb.h \
  proto/regist_condition.pb.h \
  proto/transport.pb.h \
  com/jsoncpp-src-0.5.0/include/json/json.h \
  com/jsoncpp-src-0.5.0/include/json/autolink.h \
  com/jsoncpp-src-0.5.0/include/json/config.h \
  com/jsoncpp-src-0.5.0/include/json/value.h \
  com/jsoncpp-src-0.5.0/include/json/forwards.h \
  com/jsoncpp-src-0.5.0/include/json/reader.h \
  com/jsoncpp-src-0.5.0/include/json/features.h \
  com/jsoncpp-src-0.5.0/include/json/writer.h
	@echo "[COMAKE:BUILD][Target:'src/pbrpcclient_common.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o src/pbrpcclient_common.o src/common.cpp

proto/pbrpcclient_common.pb.o:proto/common.pb.cc \
  proto/common.pb.h
	@echo "[COMAKE:BUILD][Target:'proto/pbrpcclient_common.pb.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o proto/pbrpcclient_common.pb.o proto/common.pb.cc

proto/pbrpcclient_echo.pb.o:proto/echo.pb.cc \
  proto/echo.pb.h
	@echo "[COMAKE:BUILD][Target:'proto/pbrpcclient_echo.pb.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o proto/pbrpcclient_echo.pb.o proto/echo.pb.cc

proto/pbrpcclient_helloworld.pb.o:proto/helloworld.pb.cc \
  proto/helloworld.pb.h \
  proto/common.pb.h
	@echo "[COMAKE:BUILD][Target:'proto/pbrpcclient_helloworld.pb.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o proto/pbrpcclient_helloworld.pb.o proto/helloworld.pb.cc

proto/pbrpcclient_ipc.pb.o:proto/ipc.pb.cc \
  proto/ipc.pb.h
	@echo "[COMAKE:BUILD][Target:'proto/pbrpcclient_ipc.pb.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o proto/pbrpcclient_ipc.pb.o proto/ipc.pb.cc

proto/pbrpcclient_pbrpc.pb.o:proto/pbrpc.pb.cc \
  proto/pbrpc.pb.h
	@echo "[COMAKE:BUILD][Target:'proto/pbrpcclient_pbrpc.pb.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o proto/pbrpcclient_pbrpc.pb.o proto/pbrpc.pb.cc

proto/pbrpcclient_pbrpc_service.pb.o:proto/pbrpc_service.pb.cc \
  proto/pbrpc_service.pb.h \
  proto/pbrpc.pb.h \
  proto/regist_condition.pb.h
	@echo "[COMAKE:BUILD][Target:'proto/pbrpcclient_pbrpc_service.pb.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o proto/pbrpcclient_pbrpc_service.pb.o proto/pbrpc_service.pb.cc

proto/pbrpcclient_regist_condition.pb.o:proto/regist_condition.pb.cc \
  proto/regist_condition.pb.h \
  proto/pbrpc.pb.h
	@echo "[COMAKE:BUILD][Target:'proto/pbrpcclient_regist_condition.pb.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o proto/pbrpcclient_regist_condition.pb.o proto/regist_condition.pb.cc

proto/pbrpcclient_transport.pb.o:proto/transport.pb.cc \
  proto/transport.pb.h \
  proto/pbrpc.pb.h
	@echo "[COMAKE:BUILD][Target:'proto/pbrpcclient_transport.pb.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o proto/pbrpcclient_transport.pb.o proto/transport.pb.cc

com/jsoncpp-src-0.5.0/src/lib_json/pbrpcclient_json_reader.o:com/jsoncpp-src-0.5.0/src/lib_json/json_reader.cpp \
  com/jsoncpp-src-0.5.0/include/json/reader.h \
  com/jsoncpp-src-0.5.0/include/json/features.h \
  com/jsoncpp-src-0.5.0/include/json/forwards.h \
  com/jsoncpp-src-0.5.0/include/json/config.h \
  com/jsoncpp-src-0.5.0/include/json/value.h \
  com/jsoncpp-src-0.5.0/include/json/value.h
	@echo "[COMAKE:BUILD][Target:'com/jsoncpp-src-0.5.0/src/lib_json/pbrpcclient_json_reader.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o com/jsoncpp-src-0.5.0/src/lib_json/pbrpcclient_json_reader.o com/jsoncpp-src-0.5.0/src/lib_json/json_reader.cpp

com/jsoncpp-src-0.5.0/src/lib_json/pbrpcclient_json_value.o:com/jsoncpp-src-0.5.0/src/lib_json/json_value.cpp \
  com/jsoncpp-src-0.5.0/include/json/value.h \
  com/jsoncpp-src-0.5.0/include/json/forwards.h \
  com/jsoncpp-src-0.5.0/include/json/config.h \
  com/jsoncpp-src-0.5.0/include/json/writer.h \
  com/jsoncpp-src-0.5.0/include/json/value.h \
  com/jsoncpp-src-0.5.0/src/lib_json/json_batchallocator.h \
  com/jsoncpp-src-0.5.0/src/lib_json/json_valueiterator.inl
	@echo "[COMAKE:BUILD][Target:'com/jsoncpp-src-0.5.0/src/lib_json/pbrpcclient_json_value.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o com/jsoncpp-src-0.5.0/src/lib_json/pbrpcclient_json_value.o com/jsoncpp-src-0.5.0/src/lib_json/json_value.cpp

com/jsoncpp-src-0.5.0/src/lib_json/pbrpcclient_json_writer.o:com/jsoncpp-src-0.5.0/src/lib_json/json_writer.cpp \
  com/jsoncpp-src-0.5.0/include/json/writer.h \
  com/jsoncpp-src-0.5.0/include/json/value.h \
  com/jsoncpp-src-0.5.0/include/json/forwards.h \
  com/jsoncpp-src-0.5.0/include/json/config.h
	@echo "[COMAKE:BUILD][Target:'com/jsoncpp-src-0.5.0/src/lib_json/pbrpcclient_json_writer.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o com/jsoncpp-src-0.5.0/src/lib_json/pbrpcclient_json_writer.o com/jsoncpp-src-0.5.0/src/lib_json/json_writer.cpp

src/pbrpcbenchmark_pbrpcbenchmark.o:src/pbrpcbenchmark.cpp \
  src/common.h \
  com/rapidjson-master/include/rapidjson/document.h \
  com/rapidjson-master/include/rapidjson/reader.h \
  com/rapidjson-master/include/rapidjson/rapidjson.h \
  com/rapidjson-master/include/rapidjson/allocators.h \
  com/rapidjson-master/include/rapidjson/encodings.h \
  com/rapidjson-master/include/rapidjson/internal/meta.h \
  com/rapidjson-master/include/rapidjson/internal/pow10.h \
  com/rapidjson-master/include/rapidjson/internal/stack.h \
  com/rapidjson-master/include/rapidjson/error/error.h \
  com/rapidjson-master/include/rapidjson/internal/strfunc.h \
  com/rapidjson-master/include/rapidjson/writer.h \
  com/rapidjson-master/include/rapidjson/internal/dtoa.h \
  com/rapidjson-master/include/rapidjson/internal/itoa.h \
  com/rapidjson-master/include/rapidjson/internal/itoa.h \
  com/rapidjson-master/include/rapidjson/stringbuffer.h \
  com/rapidjson-master/include/rapidjson/stringbuffer.h \
  proto/user_proto.h \
  proto/common.pb.h \
  proto/echo.pb.h \
  proto/helloworld.pb.h \
  proto/ipc.pb.h \
  proto/pbrpc.pb.h \
  proto/pbrpc_service.pb.h \
  proto/regist_condition.pb.h \
  proto/transport.pb.h \
  com/jsoncpp-src-0.5.0/include/json/json.h \
  com/jsoncpp-src-0.5.0/include/json/autolink.h \
  com/jsoncpp-src-0.5.0/include/json/config.h \
  com/jsoncpp-src-0.5.0/include/json/value.h \
  com/jsoncpp-src-0.5.0/include/json/forwards.h \
  com/jsoncpp-src-0.5.0/include/json/reader.h \
  com/jsoncpp-src-0.5.0/include/json/features.h \
  com/jsoncpp-src-0.5.0/include/json/writer.h \
  src/requestthreadpool.h
	@echo "[COMAKE:BUILD][Target:'src/pbrpcbenchmark_pbrpcbenchmark.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o src/pbrpcbenchmark_pbrpcbenchmark.o src/pbrpcbenchmark.cpp

src/pbrpcbenchmark_common.o:src/common.cpp \
  src/common.h \
  com/rapidjson-master/include/rapidjson/document.h \
  com/rapidjson-master/include/rapidjson/reader.h \
  com/rapidjson-master/include/rapidjson/rapidjson.h \
  com/rapidjson-master/include/rapidjson/allocators.h \
  com/rapidjson-master/include/rapidjson/encodings.h \
  com/rapidjson-master/include/rapidjson/internal/meta.h \
  com/rapidjson-master/include/rapidjson/internal/pow10.h \
  com/rapidjson-master/include/rapidjson/internal/stack.h \
  com/rapidjson-master/include/rapidjson/error/error.h \
  com/rapidjson-master/include/rapidjson/internal/strfunc.h \
  com/rapidjson-master/include/rapidjson/writer.h \
  com/rapidjson-master/include/rapidjson/internal/dtoa.h \
  com/rapidjson-master/include/rapidjson/internal/itoa.h \
  com/rapidjson-master/include/rapidjson/internal/itoa.h \
  com/rapidjson-master/include/rapidjson/stringbuffer.h \
  com/rapidjson-master/include/rapidjson/stringbuffer.h \
  proto/user_proto.h \
  proto/common.pb.h \
  proto/echo.pb.h \
  proto/helloworld.pb.h \
  proto/ipc.pb.h \
  proto/pbrpc.pb.h \
  proto/pbrpc_service.pb.h \
  proto/regist_condition.pb.h \
  proto/transport.pb.h \
  com/jsoncpp-src-0.5.0/include/json/json.h \
  com/jsoncpp-src-0.5.0/include/json/autolink.h \
  com/jsoncpp-src-0.5.0/include/json/config.h \
  com/jsoncpp-src-0.5.0/include/json/value.h \
  com/jsoncpp-src-0.5.0/include/json/forwards.h \
  com/jsoncpp-src-0.5.0/include/json/reader.h \
  com/jsoncpp-src-0.5.0/include/json/features.h \
  com/jsoncpp-src-0.5.0/include/json/writer.h
	@echo "[COMAKE:BUILD][Target:'src/pbrpcbenchmark_common.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o src/pbrpcbenchmark_common.o src/common.cpp

src/pbrpcbenchmark_requestthreadpool.o:src/requestthreadpool.cpp \
  src/requestthreadpool.h \
  src/common.h \
  com/rapidjson-master/include/rapidjson/document.h \
  com/rapidjson-master/include/rapidjson/reader.h \
  com/rapidjson-master/include/rapidjson/rapidjson.h \
  com/rapidjson-master/include/rapidjson/allocators.h \
  com/rapidjson-master/include/rapidjson/encodings.h \
  com/rapidjson-master/include/rapidjson/internal/meta.h \
  com/rapidjson-master/include/rapidjson/internal/pow10.h \
  com/rapidjson-master/include/rapidjson/internal/stack.h \
  com/rapidjson-master/include/rapidjson/error/error.h \
  com/rapidjson-master/include/rapidjson/internal/strfunc.h \
  com/rapidjson-master/include/rapidjson/writer.h \
  com/rapidjson-master/include/rapidjson/internal/dtoa.h \
  com/rapidjson-master/include/rapidjson/internal/itoa.h \
  com/rapidjson-master/include/rapidjson/internal/itoa.h \
  com/rapidjson-master/include/rapidjson/stringbuffer.h \
  com/rapidjson-master/include/rapidjson/stringbuffer.h \
  proto/user_proto.h \
  proto/common.pb.h \
  proto/echo.pb.h \
  proto/helloworld.pb.h \
  proto/ipc.pb.h \
  proto/pbrpc.pb.h \
  proto/pbrpc_service.pb.h \
  proto/regist_condition.pb.h \
  proto/transport.pb.h \
  com/jsoncpp-src-0.5.0/include/json/json.h \
  com/jsoncpp-src-0.5.0/include/json/autolink.h \
  com/jsoncpp-src-0.5.0/include/json/config.h \
  com/jsoncpp-src-0.5.0/include/json/value.h \
  com/jsoncpp-src-0.5.0/include/json/forwards.h \
  com/jsoncpp-src-0.5.0/include/json/reader.h \
  com/jsoncpp-src-0.5.0/include/json/features.h \
  com/jsoncpp-src-0.5.0/include/json/writer.h
	@echo "[COMAKE:BUILD][Target:'src/pbrpcbenchmark_requestthreadpool.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o src/pbrpcbenchmark_requestthreadpool.o src/requestthreadpool.cpp

proto/pbrpcbenchmark_common.pb.o:proto/common.pb.cc \
  proto/common.pb.h
	@echo "[COMAKE:BUILD][Target:'proto/pbrpcbenchmark_common.pb.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o proto/pbrpcbenchmark_common.pb.o proto/common.pb.cc

proto/pbrpcbenchmark_echo.pb.o:proto/echo.pb.cc \
  proto/echo.pb.h
	@echo "[COMAKE:BUILD][Target:'proto/pbrpcbenchmark_echo.pb.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o proto/pbrpcbenchmark_echo.pb.o proto/echo.pb.cc

proto/pbrpcbenchmark_helloworld.pb.o:proto/helloworld.pb.cc \
  proto/helloworld.pb.h \
  proto/common.pb.h
	@echo "[COMAKE:BUILD][Target:'proto/pbrpcbenchmark_helloworld.pb.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o proto/pbrpcbenchmark_helloworld.pb.o proto/helloworld.pb.cc

proto/pbrpcbenchmark_ipc.pb.o:proto/ipc.pb.cc \
  proto/ipc.pb.h
	@echo "[COMAKE:BUILD][Target:'proto/pbrpcbenchmark_ipc.pb.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o proto/pbrpcbenchmark_ipc.pb.o proto/ipc.pb.cc

proto/pbrpcbenchmark_pbrpc.pb.o:proto/pbrpc.pb.cc \
  proto/pbrpc.pb.h
	@echo "[COMAKE:BUILD][Target:'proto/pbrpcbenchmark_pbrpc.pb.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o proto/pbrpcbenchmark_pbrpc.pb.o proto/pbrpc.pb.cc

proto/pbrpcbenchmark_pbrpc_service.pb.o:proto/pbrpc_service.pb.cc \
  proto/pbrpc_service.pb.h \
  proto/pbrpc.pb.h \
  proto/regist_condition.pb.h
	@echo "[COMAKE:BUILD][Target:'proto/pbrpcbenchmark_pbrpc_service.pb.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o proto/pbrpcbenchmark_pbrpc_service.pb.o proto/pbrpc_service.pb.cc

proto/pbrpcbenchmark_regist_condition.pb.o:proto/regist_condition.pb.cc \
  proto/regist_condition.pb.h \
  proto/pbrpc.pb.h
	@echo "[COMAKE:BUILD][Target:'proto/pbrpcbenchmark_regist_condition.pb.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o proto/pbrpcbenchmark_regist_condition.pb.o proto/regist_condition.pb.cc

proto/pbrpcbenchmark_transport.pb.o:proto/transport.pb.cc \
  proto/transport.pb.h \
  proto/pbrpc.pb.h
	@echo "[COMAKE:BUILD][Target:'proto/pbrpcbenchmark_transport.pb.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o proto/pbrpcbenchmark_transport.pb.o proto/transport.pb.cc

com/jsoncpp-src-0.5.0/src/lib_json/pbrpcbenchmark_json_reader.o:com/jsoncpp-src-0.5.0/src/lib_json/json_reader.cpp \
  com/jsoncpp-src-0.5.0/include/json/reader.h \
  com/jsoncpp-src-0.5.0/include/json/features.h \
  com/jsoncpp-src-0.5.0/include/json/forwards.h \
  com/jsoncpp-src-0.5.0/include/json/config.h \
  com/jsoncpp-src-0.5.0/include/json/value.h \
  com/jsoncpp-src-0.5.0/include/json/value.h
	@echo "[COMAKE:BUILD][Target:'com/jsoncpp-src-0.5.0/src/lib_json/pbrpcbenchmark_json_reader.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o com/jsoncpp-src-0.5.0/src/lib_json/pbrpcbenchmark_json_reader.o com/jsoncpp-src-0.5.0/src/lib_json/json_reader.cpp

com/jsoncpp-src-0.5.0/src/lib_json/pbrpcbenchmark_json_value.o:com/jsoncpp-src-0.5.0/src/lib_json/json_value.cpp \
  com/jsoncpp-src-0.5.0/include/json/value.h \
  com/jsoncpp-src-0.5.0/include/json/forwards.h \
  com/jsoncpp-src-0.5.0/include/json/config.h \
  com/jsoncpp-src-0.5.0/include/json/writer.h \
  com/jsoncpp-src-0.5.0/include/json/value.h \
  com/jsoncpp-src-0.5.0/src/lib_json/json_batchallocator.h \
  com/jsoncpp-src-0.5.0/src/lib_json/json_valueiterator.inl
	@echo "[COMAKE:BUILD][Target:'com/jsoncpp-src-0.5.0/src/lib_json/pbrpcbenchmark_json_value.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o com/jsoncpp-src-0.5.0/src/lib_json/pbrpcbenchmark_json_value.o com/jsoncpp-src-0.5.0/src/lib_json/json_value.cpp

com/jsoncpp-src-0.5.0/src/lib_json/pbrpcbenchmark_json_writer.o:com/jsoncpp-src-0.5.0/src/lib_json/json_writer.cpp \
  com/jsoncpp-src-0.5.0/include/json/writer.h \
  com/jsoncpp-src-0.5.0/include/json/value.h \
  com/jsoncpp-src-0.5.0/include/json/forwards.h \
  com/jsoncpp-src-0.5.0/include/json/config.h
	@echo "[COMAKE:BUILD][Target:'com/jsoncpp-src-0.5.0/src/lib_json/pbrpcbenchmark_json_writer.o']"
	$(CXX) -c $(INCPATH) $(DEP_INCPATH) $(CPPFLAGS) $(CXXFLAGS)  -o com/jsoncpp-src-0.5.0/src/lib_json/pbrpcbenchmark_json_writer.o com/jsoncpp-src-0.5.0/src/lib_json/json_writer.cpp

endif #ifeq ($(shell uname -m),x86_64)


