# Base64 Encoding and Decoding Interface for kdb

This repository provides a kdb library for Base64 encoding and decoding. 

NOTE: This library requires the shared object `libkdbbase64.so` provided by the [kdb-base64-lib](https://github.com/jasraj/kdb-base64-lib) repository. Please ensure that this object is available in your target environment.

This library has been written for use with the [kdb-common](https://github.com/BuaBook/kdb-common) set of libraries.

## Building `libkdbbase64.so`

See [kdb-base64-lib](https://github.com/jasraj/kdb-base64-lib) for build instructions

## Using the Library

The 2 functions provided by this library are:

* `.b64.encode`: Base64 encoder
    * Behaves the same as `.Q.btoa`
* `.b64.decode`: Base64 decoder

Both functions expect a string (`10h`) argument and will return a string.

## Encoder Performance Comparison

There is a slight performance improvement with `.b64.encode` vs the built-in `.Q.btoa`:

```q
/ Intel(R) Core(TM) i7-1065G7 CPU @ 1.30GHz

q) encStr:500?.Q.an

q) \ts do[10000; .Q.btoa encStr]
39 1408

q) \ts do[10000; .b64.encode encStr]
34 1376
```
