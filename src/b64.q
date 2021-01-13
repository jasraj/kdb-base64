// Base64 Encoding and Decoding Interface
// Copyright (c) 2020 - 2021 Jaskirat Rajasansir

.require.lib `so;


/ The name of the shared object to find
.b64.cfg.soName:`libkdbbase64.so;

/ Configuration to load the shared object functions into the kdb process
.b64.cfg.nativeFunctionMap:`kdbFunc xkey flip `kdbFunc`nativeFunc`args!"SSJ"$\:();
.b64.cfg.nativeFunctionMap[`.b64.encode]:(`base64encode; 1);
.b64.cfg.nativeFunctionMap[`.b64.decode]:(`base64decode; 1);


.b64.init:{
    .b64.i.loadNativeFunctions[];
 };


/ Loads and maps the native functions available in the shared object to kdb functions
/ @see .b64.cfg.nativeFunctionMap
.b64.i.loadNativeFunctions:{
    .log.if.info "Loading native functions [ Shared Object: ",string[.b64.cfg.soName]," ] [ Native Functions: ",string[count .b64.cfg.nativeFunctionMap]," ]";

    targetFuncs:exec kdbFunc from .b64.cfg.nativeFunctionMap;
    soFuncs:get each .so.loadFunction[.b64.cfg.soName;;] ./: flip (0!.b64.cfg.nativeFunctionMap)`nativeFunc`args;

    (set) ./: targetFuncs,'soFuncs;
 };
