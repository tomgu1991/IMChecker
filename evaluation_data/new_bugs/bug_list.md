>Author: ZG, JW, LC
>
>Note:
>
>open - open issue
>
>patched - create patch for the opened issue
>
>assessed - confirm by developer, low priority
>
>confirmed - confirmed by developer, but not fixed yet
>
>fixed - confirmed and fixed
>

## Summary

|    Project    | Bugs |
| :-----------: | ---: |
|    OpenSSL    |   17 |
|     Linux     |   30 |
|      dma      |    1 |
|     exim      |    2 |
|    hexchat    |    2 |
|    httping    |    1 |
|   ipmitool    |    1 |
| open-vm-tools |    2 |
|   keepalive   |    2 |
|     Total     |   58 |



## OpenSSL

1. fixed - [#6567: Missing error check of RAND_bytes() calls in apps/speed.c](https://github.com/openssl/openssl/issues/6567)

2. assessed - [#6568: Error check of ASN1_INTEGER_get() miss in crypto/asn1/tasn_utl.c](https://github.com/openssl/openssl/issues/6568)

3. fixed - [#6569: Shall we check the return value of ASN1_INTEGER_set() call in crypto/pkcs12/p12_init.c?](https://github.com/openssl/openssl/issues/6569)

4. assessed - [#6570 :Missing the check the result value of ASN1_object_size() in crypto/asn1/asn1_gen.c.](https://github.com/openssl/openssl/issues/6570)

5. fixed - [#6572: Shall we check the return value of BN_set_word() call in ssl/t1_lib.c](https://github.com/openssl/openssl/issues/6572)

6. assessed - [#6573: Potential bugs in apps/speed.c, which caused by missing error code checkings](https://github.com/openssl/openssl/issues/6573)

7. fixed - [#6574: Potential null pointer dereference bug in ssl/statem/statem_srvr.c, which caused by missing error code checkings of EVP_PKEY_get0_DH()](https://github.com/openssl/openssl/issues/6574)

8. assessed - [#6575: Missing error checks in EC_KEY generating of apps/speed.c](https://github.com/openssl/openssl/issues/6575)

9. fixed - [#6781: Potential memory leak when EC_KEY_set_group fails in crypto/ec/ec_ameth.c](https://github.com/openssl/openssl/issues/6781)

10. fixed - [#6789: Missing return value check of ASN1_INTEGER_set() in crypto/pkcs12/p12_init.c](https://github.com/openssl/openssl/issues/6789)

11. fixed - [#6820: Missing return value check of ASN1_INTEGER_to_BN() in crypto/ts/ts_lib.c](https://github.com/openssl/openssl/issues/6820)

12. fixed - [#6822: Missing return value check of BN_sub() in crypto/rsa/rsa_ossl.c](https://github.com/openssl/openssl/issues/6822)

13. fixed - [#6973: Unchecked EVP_MD_CTX_new() return value in OCSP_basic_sign()](https://github.com/openssl/openssl/issues/6973)

14. fixed - [#6977: Potential redundant code in crypto/pkcs7/pk7_lib.c](https://github.com/openssl/openssl/issues/6977)

15. fixed - [#6982: Unchecked OBJ_nid2obj() return value in crypto/asn1/asn_moid.c: do_create](https://github.com/openssl/openssl/issues/6982)

16. fixed - [#6983: Unchecked BN_sub() return value in crypto/bn/bn_x931p.c: BN_X931_generate_Xpq](https://github.com/openssl/openssl/issues/6983)

17. confirmed(no need fix) -  [#7235: Function DH_set0_key() definition is inconsistent with interface](https://github.com/openssl/openssl/issues/7235)

## Linux

1. patched - [200489](https://bugzilla.kernel.org/show_bug.cgi?id=200489)
2. fixed - [200505](https://bugzilla.kernel.org/show_bug.cgi?id=200505)
3. patched - [200511](https://bugzilla.kernel.org/show_bug.cgi?id=200511)
4. patched - [200519](https://bugzilla.kernel.org/show_bug.cgi?id=200519)
5. patched - [200521](https://bugzilla.kernel.org/show_bug.cgi?id=200521)
6. fixed - [200533](https://bugzilla.kernel.org/show_bug.cgi?id=200533)
7. fixed - [200535](https://bugzilla.kernel.org/show_bug.cgi?id=200535)
8. patched - [200537](https://bugzilla.kernel.org/show_bug.cgi?id=200537)
9. patched - [200539](https://bugzilla.kernel.org/show_bug.cgi?id=200539)
10. patched - [200541](https://bugzilla.kernel.org/show_bug.cgi?id=200541), [pull request](https://github.com/torvalds/linux/pull/579)
11. patched - [200543](https://bugzilla.kernel.org/show_bug.cgi?id=200543)
12. patched - [200545](https://bugzilla.kernel.org/show_bug.cgi?id=200545)
13. open - [200547](https://bugzilla.kernel.org/show_bug.cgi?id=200547)
14. patched - [200549](https://bugzilla.kernel.org/show_bug.cgi?id=200549)
15. fixed - [200551](https://bugzilla.kernel.org/show_bug.cgi?id=200551)
16. patched - [200555](https://bugzilla.kernel.org/show_bug.cgi?id=200555)
17. patched - [200557](https://bugzilla.kernel.org/show_bug.cgi?id=200557)
18. patched - [200559](https://bugzilla.kernel.org/show_bug.cgi?id=200559)
19. fixed - [200561](https://bugzilla.kernel.org/show_bug.cgi?id=200561)
20. patched - [200563](https://bugzilla.kernel.org/show_bug.cgi?id=200563)
21. patched - [200565](https://bugzilla.kernel.org/show_bug.cgi?id=200565)
22. patched - [200567](https://bugzilla.kernel.org/show_bug.cgi?id=200567)
23. open - [200569](https://bugzilla.kernel.org/show_bug.cgi?id=200569)
24. patched - [200571](https://bugzilla.kernel.org/show_bug.cgi?id=200571)
25. patched - [200573](https://bugzilla.kernel.org/show_bug.cgi?id=200573)
26. patched - [200575](https://bugzilla.kernel.org/show_bug.cgi?id=200575)
27. open - [200577](https://bugzilla.kernel.org/show_bug.cgi?id=200577)
28. open - [200579](https://bugzilla.kernel.org/show_bug.cgi?id=200579)
29. open - [200581](https://bugzilla.kernel.org/show_bug.cgi?id=200581)
30. patched - [200583](https://bugzilla.kernel.org/show_bug.cgi?id=200583)

## [dma](https://github.com/corecode/dma)
1. fixed - [59](https://github.com/corecode/dma/issues/59)

## [exim](https://github.com/Exim/exim)
1. confirmed - [2316](https://bugs.exim.org/show_bug.cgi?id=2316)

2. fixed - [2317](https://bugs.exim.org/show_bug.cgi?id=2317)

## [hexchat](https://github.com/hexchat/hexchat)

1. confirmed - [2244](https://github.com/hexchat/hexchat/issues/2244)
2. open - [2245](https://github.com/hexchat/hexchat/issues/2245)

## [httping](https://github.com/flok99/httping)

1. confirmed - [41](https://github.com/flok99/httping/issues/41)

## [ipmitool](https://github.com/ipmitool/ipmitool)

1. open - [37](https://github.com/ipmitool/ipmitool/issues/37)

## [open-vm-tools](https://github.com/vmware/open-vm-tools)

1. fixed - [291](https://github.com/vmware/open-vm-tools/issues/291)
2. fixed - [292](https://github.com/vmware/open-vm-tools/issues/292)

## [keepalive](https://github.com/acassen/keepalived)

1. fixed - [1003](https://github.com/acassen/keepalived/issues/1003)
2. fixed - [1004](https://github.com/acassen/keepalived/issues/1004)

