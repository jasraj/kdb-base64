// Base64 Encoding and Decoding Interface
// Copyright (c) 2020 Jaskirat Rajasansir

.require.lib each `util`file;


/ The name of the shared object to find
.b64.cfg.soName:`libkdbbase64;

/ The environment variable to check for a path to the shared object location
.b64.cfg.soPathEnvVar:`KSL_SO_FOLDER;

/ Configuration to load the shared object functions into the kdb process
.b64.cfg.nativeFunctionMap:`kdbFunc xkey flip `kdbFunc`nativeFunc`args!"SSJ"$\:();
.b64.cfg.nativeFunctionMap[`.b64.encode]:(`base64encode; 1);
.b64.cfg.nativeFunctionMap[`.b64.decode]:(`base64decode; 1);


/ Once discovered, the full path to the shared object
.b64.soPath:`;


.b64.init:{
    .b64.soPath:.b64.cfg.soName;

    if[not "" ~ getenv .b64.cfg.soPathEnvVar;
        .b64.soPath:.b64.i.getCustomSoPath[];
    ];

    .b64.i.loadNativeFunctions[];
 };


/ Attempts to derive the custom location of the shared object based on the path set in the environment variable. If the
/ specified folder does not contain the shared object, the function will look for 'lib' and 'lib64' folders (based on the
/ current kdb process architecture)
/  @returns (FilePath) The full path to the shared object (without the .so suffix) for use with 2:
/  @see .b64.cfg.soPathEnvVar
/  @see .b64.cfg.soName
.b64.i.getCustomSoPath:{
    customSoPath:`$":",getenv .b64.cfg.soPathEnvVar;
    soFileName:` sv .b64.cfg.soName,`so;

    if[soFileName in .file.ls customSoPath;
        .log.if.info "Shared object found in root of custom folder path [ Path: ",string[customSoPath]," ]";
        :` sv customSoPath,.b64.cfg.soName;
    ];

    if[(`x86 = .util.getProcessArchitecture[]) & `lib in .file.ls customSoPath;
        .log.if.info "32-bit shared object found in 'lib' folder [ Path: ",string[customSoPath]," ]";
        :` sv customSoPath,`lib,.b64.cfg.soName;
    ];

    if[(`x86_64 = .util.getProcessArchitecture[]) & `lib64 in .file.ls customSoPath;
        .log.if.info "64-bit shared object found in 'lib64' folder [ Path: ",string[customSoPath]," ]";
        :` sv customSoPath,`lib64,.b64.cfg.soName;
    ];

    .log.if.error "Shared object could not be found within the custom folder path specified [ Path: ",string[customSoPath]," ]";
    '"MissingSharedObjectException";
 };

/ Loads and maps the native functions available in the shared object to kdb functions
/ @see .b64.cfg.nativeFunctionMap
.b64.i.loadNativeFunctions:{
    .log.if.info "Loading native functions [ Shared Object: ",string[.b64.soPath]," ] [ Native Functions: ",string[count .b64.cfg.nativeFunctionMap]," ]";

    {[kdbFunc]
        soFunc:.b64.cfg.nativeFunctionMap kdbFunc;

        .log.if.debug "Loading native function [ kdb: ",string[kdbFunc]," ] [ Native: ",.Q.s1[soFunc]," ]";

        set[kdbFunc; .b64.soPath 2: value soFunc];
    } each exec kdbFunc from .b64.cfg.nativeFunctionMap;
 };
