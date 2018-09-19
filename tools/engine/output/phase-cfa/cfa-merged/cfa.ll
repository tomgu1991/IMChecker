; ModuleID = 'output/phase-cfa/cfa-merged/cfa.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }

@.str = private unnamed_addr constant [2 x i8] c"r\00", align 1
@.str.1 = private unnamed_addr constant [16 x i8] c"Error open file\00", align 1
@.str.2 = private unnamed_addr constant [16 x i8] c"Error read file\00", align 1
@stdin = external global %struct._IO_FILE*, align 8
@.str.3 = private unnamed_addr constant [11 x i8] c"Error file\00", align 1
@.str.4 = private unnamed_addr constant [10 x i8] c"example.c\00", align 1

; Function Attrs: nounwind uwtable
define i32 @bad1(i8* %fileName) #0 !dbg !8 {
entry:
  %retval = alloca i32, align 4
  %fileName.addr = alloca i8*, align 8
  %buffer = alloca [100 x i8], align 16
  %pFile = alloca %struct._IO_FILE*, align 8
  store i8* %fileName, i8** %fileName.addr, align 8
  call void @llvm.dbg.declare(metadata i8** %fileName.addr, metadata !14, metadata !15), !dbg !16
  call void @llvm.dbg.declare(metadata [100 x i8]* %buffer, metadata !17, metadata !15), !dbg !21
  %0 = bitcast [100 x i8]* %buffer to i8*, !dbg !21
  call void @llvm.memset.p0i8.i64(i8* %0, i8 0, i64 100, i32 16, i1 false), !dbg !21
  call void @llvm.dbg.declare(metadata %struct._IO_FILE** %pFile, metadata !22, metadata !15), !dbg !82
  %1 = load i8*, i8** %fileName.addr, align 8, !dbg !83
  %call = call %struct._IO_FILE* @fopen(i8* %1, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str, i32 0, i32 0)), !dbg !84
  store %struct._IO_FILE* %call, %struct._IO_FILE** %pFile, align 8, !dbg !85
  %2 = load %struct._IO_FILE*, %struct._IO_FILE** %pFile, align 8, !dbg !86
  %cmp = icmp eq %struct._IO_FILE* %2, null, !dbg !88
  br i1 %cmp, label %if.then, label %if.end, !dbg !89

if.then:                                          ; preds = %entry
  call void @Log(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.1, i32 0, i32 0)), !dbg !90
  store i32 1, i32* %retval, align 4, !dbg !92
  br label %return, !dbg !92

if.end:                                           ; preds = %entry
  %arraydecay = getelementptr inbounds [100 x i8], [100 x i8]* %buffer, i32 0, i32 0, !dbg !93
  %3 = load %struct._IO_FILE*, %struct._IO_FILE** %pFile, align 8, !dbg !95
  %call1 = call i8* @fgets(i8* %arraydecay, i32 100, %struct._IO_FILE* %3), !dbg !96
  %cmp2 = icmp ult i8* %call1, null, !dbg !97
  br i1 %cmp2, label %if.then3, label %if.end4, !dbg !98

if.then3:                                         ; preds = %if.end
  call void @Log(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.2, i32 0, i32 0)), !dbg !99
  store i32 0, i32* %retval, align 4, !dbg !101
  br label %return, !dbg !101

if.end4:                                          ; preds = %if.end
  %4 = load %struct._IO_FILE*, %struct._IO_FILE** %pFile, align 8, !dbg !102
  %call5 = call i32 @fclose(%struct._IO_FILE* %4), !dbg !103
  store i32 1, i32* %retval, align 4, !dbg !104
  br label %return, !dbg !104

return:                                           ; preds = %if.end4, %if.then3, %if.then
  %5 = load i32, i32* %retval, align 4, !dbg !105
  ret i32 %5, !dbg !105
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i32, i1) #2

declare %struct._IO_FILE* @fopen(i8*, i8*) #3

declare void @Log(i8*) #3

declare i8* @fgets(i8*, i32, %struct._IO_FILE*) #3

declare i32 @fclose(%struct._IO_FILE*) #3

; Function Attrs: nounwind uwtable
define i32 @bad2() #0 !dbg !106 {
entry:
  %retval = alloca i32, align 4
  %buffer = alloca [100 x i8], align 16
  call void @llvm.dbg.declare(metadata [100 x i8]* %buffer, metadata !109, metadata !15), !dbg !110
  %0 = bitcast [100 x i8]* %buffer to i8*, !dbg !110
  call void @llvm.memset.p0i8.i64(i8* %0, i8 0, i64 100, i32 16, i1 false), !dbg !110
  %arraydecay = getelementptr inbounds [100 x i8], [100 x i8]* %buffer, i32 0, i32 0, !dbg !111
  %1 = load %struct._IO_FILE*, %struct._IO_FILE** @stdin, align 8, !dbg !113
  %call = call i8* @fgets(i8* %arraydecay, i32 100, %struct._IO_FILE* %1), !dbg !114
  %cmp = icmp ult i8* %call, null, !dbg !115
  br i1 %cmp, label %if.then, label %if.end, !dbg !116

if.then:                                          ; preds = %entry
  call void @Log(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.2, i32 0, i32 0)), !dbg !117
  store i32 0, i32* %retval, align 4, !dbg !119
  br label %return, !dbg !119

if.end:                                           ; preds = %entry
  store i32 1, i32* %retval, align 4, !dbg !120
  br label %return, !dbg !120

return:                                           ; preds = %if.end, %if.then
  %2 = load i32, i32* %retval, align 4, !dbg !121
  ret i32 %2, !dbg !121
}

; Function Attrs: nounwind uwtable
define i32 @good1(i8* %fileName) #0 !dbg !122 {
entry:
  %retval = alloca i32, align 4
  %fileName.addr = alloca i8*, align 8
  %buffer = alloca [100 x i8], align 16
  %pFile = alloca %struct._IO_FILE*, align 8
  store i8* %fileName, i8** %fileName.addr, align 8
  call void @llvm.dbg.declare(metadata i8** %fileName.addr, metadata !123, metadata !15), !dbg !124
  call void @llvm.dbg.declare(metadata [100 x i8]* %buffer, metadata !125, metadata !15), !dbg !126
  %0 = bitcast [100 x i8]* %buffer to i8*, !dbg !126
  call void @llvm.memset.p0i8.i64(i8* %0, i8 0, i64 100, i32 16, i1 false), !dbg !126
  call void @llvm.dbg.declare(metadata %struct._IO_FILE** %pFile, metadata !127, metadata !15), !dbg !128
  %1 = load i8*, i8** %fileName.addr, align 8, !dbg !129
  %cmp = icmp eq i8* %1, null, !dbg !131
  br i1 %cmp, label %if.then, label %if.end, !dbg !132

if.then:                                          ; preds = %entry
  call void @Log(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.3, i32 0, i32 0)), !dbg !133
  store i32 0, i32* %retval, align 4, !dbg !135
  br label %return, !dbg !135

if.end:                                           ; preds = %entry
  %2 = load i8*, i8** %fileName.addr, align 8, !dbg !136
  %call = call %struct._IO_FILE* @fopen(i8* %2, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str, i32 0, i32 0)), !dbg !137
  store %struct._IO_FILE* %call, %struct._IO_FILE** %pFile, align 8, !dbg !138
  %3 = load %struct._IO_FILE*, %struct._IO_FILE** %pFile, align 8, !dbg !139
  %cmp1 = icmp eq %struct._IO_FILE* %3, null, !dbg !141
  br i1 %cmp1, label %if.then2, label %if.end3, !dbg !142

if.then2:                                         ; preds = %if.end
  call void @Log(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.1, i32 0, i32 0)), !dbg !143
  store i32 0, i32* %retval, align 4, !dbg !145
  br label %return, !dbg !145

if.end3:                                          ; preds = %if.end
  %arraydecay = getelementptr inbounds [100 x i8], [100 x i8]* %buffer, i32 0, i32 0, !dbg !146
  %4 = load %struct._IO_FILE*, %struct._IO_FILE** %pFile, align 8, !dbg !148
  %call4 = call i8* @fgets(i8* %arraydecay, i32 100, %struct._IO_FILE* %4), !dbg !149
  %cmp5 = icmp eq i8* %call4, null, !dbg !150
  br i1 %cmp5, label %if.then6, label %if.end8, !dbg !151

if.then6:                                         ; preds = %if.end3
  call void @Log(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.2, i32 0, i32 0)), !dbg !152
  %5 = load %struct._IO_FILE*, %struct._IO_FILE** %pFile, align 8, !dbg !154
  %call7 = call i32 @fclose(%struct._IO_FILE* %5), !dbg !155
  store i32 0, i32* %retval, align 4, !dbg !156
  br label %return, !dbg !156

if.end8:                                          ; preds = %if.end3
  %6 = load %struct._IO_FILE*, %struct._IO_FILE** %pFile, align 8, !dbg !157
  %call9 = call i32 @fclose(%struct._IO_FILE* %6), !dbg !158
  store i32 1, i32* %retval, align 4, !dbg !159
  br label %return, !dbg !159

return:                                           ; preds = %if.end8, %if.then6, %if.then2, %if.then
  %7 = load i32, i32* %retval, align 4, !dbg !160
  ret i32 %7, !dbg !160
}

; Function Attrs: nounwind uwtable
define i32 @good2() #0 !dbg !161 {
entry:
  %retval = alloca i32, align 4
  %buffer = alloca [100 x i8], align 16
  call void @llvm.dbg.declare(metadata [100 x i8]* %buffer, metadata !162, metadata !15), !dbg !163
  %0 = bitcast [100 x i8]* %buffer to i8*, !dbg !163
  call void @llvm.memset.p0i8.i64(i8* %0, i8 0, i64 100, i32 16, i1 false), !dbg !163
  %arraydecay = getelementptr inbounds [100 x i8], [100 x i8]* %buffer, i32 0, i32 0, !dbg !164
  %1 = load %struct._IO_FILE*, %struct._IO_FILE** @stdin, align 8, !dbg !166
  %call = call i8* @fgets(i8* %arraydecay, i32 100, %struct._IO_FILE* %1), !dbg !167
  %cmp = icmp eq i8* %call, null, !dbg !168
  br i1 %cmp, label %if.then, label %if.end, !dbg !169

if.then:                                          ; preds = %entry
  call void @Log(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.2, i32 0, i32 0)), !dbg !170
  store i32 0, i32* %retval, align 4, !dbg !172
  br label %return, !dbg !172

if.end:                                           ; preds = %entry
  store i32 1, i32* %retval, align 4, !dbg !173
  br label %return, !dbg !173

return:                                           ; preds = %if.end, %if.then
  %2 = load i32, i32* %retval, align 4, !dbg !174
  ret i32 %2, !dbg !174
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 !dbg !175 {
entry:
  %fileName = alloca i8*, align 8
  call void @llvm.dbg.declare(metadata i8** %fileName, metadata !176, metadata !15), !dbg !177
  store i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.4, i32 0, i32 0), i8** %fileName, align 8, !dbg !177
  %0 = load i8*, i8** %fileName, align 8, !dbg !178
  %call = call i32 @bad1(i8* %0), !dbg !179
  %call1 = call i32 @bad2(), !dbg !180
  %1 = load i8*, i8** %fileName, align 8, !dbg !181
  %call2 = call i32 @good1(i8* %1), !dbg !182
  %call3 = call i32 @good2(), !dbg !183
  ret i32 0, !dbg !184
}

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { argmemonly nounwind }
attributes #3 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.ident = !{!5}
!llvm.module.flags = !{!6, !7}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 3.9.0 (tags/RELEASE_390/final)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !3)
!1 = !DIFile(filename: "/home/guzuxing/Documents/IMChecker/tools/example_code/example.c", directory: "/home/guzuxing/Documents/IMChecker/tools/engine")
!2 = !{}
!3 = !{!4}
!4 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64, align: 64)
!5 = !{!"clang version 3.9.0 (tags/RELEASE_390/final)"}
!6 = !{i32 2, !"Dwarf Version", i32 4}
!7 = !{i32 2, !"Debug Info Version", i32 3}
!8 = distinct !DISubprogram(name: "bad1", scope: !1, file: !1, line: 9, type: !9, isLocal: false, isDefinition: true, scopeLine: 9, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!9 = !DISubroutineType(types: !10)
!10 = !{!11, !12}
!11 = !DIBasicType(name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!12 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !13, size: 64, align: 64)
!13 = !DIBasicType(name: "char", size: 8, align: 8, encoding: DW_ATE_signed_char)
!14 = !DILocalVariable(name: "fileName", arg: 1, scope: !8, file: !1, line: 9, type: !12)
!15 = !DIExpression()
!16 = !DILocation(line: 9, column: 16, scope: !8)
!17 = !DILocalVariable(name: "buffer", scope: !8, file: !1, line: 10, type: !18)
!18 = !DICompositeType(tag: DW_TAG_array_type, baseType: !13, size: 800, align: 8, elements: !19)
!19 = !{!20}
!20 = !DISubrange(count: 100)
!21 = !DILocation(line: 10, column: 10, scope: !8)
!22 = !DILocalVariable(name: "pFile", scope: !8, file: !1, line: 11, type: !23)
!23 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !24, size: 64, align: 64)
!24 = !DIDerivedType(tag: DW_TAG_typedef, name: "FILE", file: !25, line: 48, baseType: !26)
!25 = !DIFile(filename: "/usr/include/stdio.h", directory: "/home/guzuxing/Documents/IMChecker/tools/engine")
!26 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_FILE", file: !27, line: 241, size: 1728, align: 64, elements: !28)
!27 = !DIFile(filename: "/usr/include/libio.h", directory: "/home/guzuxing/Documents/IMChecker/tools/engine")
!28 = !{!29, !30, !31, !32, !33, !34, !35, !36, !37, !38, !39, !40, !41, !49, !50, !51, !52, !56, !58, !60, !64, !67, !69, !70, !71, !72, !73, !77, !78}
!29 = !DIDerivedType(tag: DW_TAG_member, name: "_flags", scope: !26, file: !27, line: 242, baseType: !11, size: 32, align: 32)
!30 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_read_ptr", scope: !26, file: !27, line: 247, baseType: !12, size: 64, align: 64, offset: 64)
!31 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_read_end", scope: !26, file: !27, line: 248, baseType: !12, size: 64, align: 64, offset: 128)
!32 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_read_base", scope: !26, file: !27, line: 249, baseType: !12, size: 64, align: 64, offset: 192)
!33 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_write_base", scope: !26, file: !27, line: 250, baseType: !12, size: 64, align: 64, offset: 256)
!34 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_write_ptr", scope: !26, file: !27, line: 251, baseType: !12, size: 64, align: 64, offset: 320)
!35 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_write_end", scope: !26, file: !27, line: 252, baseType: !12, size: 64, align: 64, offset: 384)
!36 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_buf_base", scope: !26, file: !27, line: 253, baseType: !12, size: 64, align: 64, offset: 448)
!37 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_buf_end", scope: !26, file: !27, line: 254, baseType: !12, size: 64, align: 64, offset: 512)
!38 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_save_base", scope: !26, file: !27, line: 256, baseType: !12, size: 64, align: 64, offset: 576)
!39 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_backup_base", scope: !26, file: !27, line: 257, baseType: !12, size: 64, align: 64, offset: 640)
!40 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_save_end", scope: !26, file: !27, line: 258, baseType: !12, size: 64, align: 64, offset: 704)
!41 = !DIDerivedType(tag: DW_TAG_member, name: "_markers", scope: !26, file: !27, line: 260, baseType: !42, size: 64, align: 64, offset: 768)
!42 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !43, size: 64, align: 64)
!43 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_marker", file: !27, line: 156, size: 192, align: 64, elements: !44)
!44 = !{!45, !46, !48}
!45 = !DIDerivedType(tag: DW_TAG_member, name: "_next", scope: !43, file: !27, line: 157, baseType: !42, size: 64, align: 64)
!46 = !DIDerivedType(tag: DW_TAG_member, name: "_sbuf", scope: !43, file: !27, line: 158, baseType: !47, size: 64, align: 64, offset: 64)
!47 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !26, size: 64, align: 64)
!48 = !DIDerivedType(tag: DW_TAG_member, name: "_pos", scope: !43, file: !27, line: 162, baseType: !11, size: 32, align: 32, offset: 128)
!49 = !DIDerivedType(tag: DW_TAG_member, name: "_chain", scope: !26, file: !27, line: 262, baseType: !47, size: 64, align: 64, offset: 832)
!50 = !DIDerivedType(tag: DW_TAG_member, name: "_fileno", scope: !26, file: !27, line: 264, baseType: !11, size: 32, align: 32, offset: 896)
!51 = !DIDerivedType(tag: DW_TAG_member, name: "_flags2", scope: !26, file: !27, line: 268, baseType: !11, size: 32, align: 32, offset: 928)
!52 = !DIDerivedType(tag: DW_TAG_member, name: "_old_offset", scope: !26, file: !27, line: 270, baseType: !53, size: 64, align: 64, offset: 960)
!53 = !DIDerivedType(tag: DW_TAG_typedef, name: "__off_t", file: !54, line: 131, baseType: !55)
!54 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types.h", directory: "/home/guzuxing/Documents/IMChecker/tools/engine")
!55 = !DIBasicType(name: "long int", size: 64, align: 64, encoding: DW_ATE_signed)
!56 = !DIDerivedType(tag: DW_TAG_member, name: "_cur_column", scope: !26, file: !27, line: 274, baseType: !57, size: 16, align: 16, offset: 1024)
!57 = !DIBasicType(name: "unsigned short", size: 16, align: 16, encoding: DW_ATE_unsigned)
!58 = !DIDerivedType(tag: DW_TAG_member, name: "_vtable_offset", scope: !26, file: !27, line: 275, baseType: !59, size: 8, align: 8, offset: 1040)
!59 = !DIBasicType(name: "signed char", size: 8, align: 8, encoding: DW_ATE_signed_char)
!60 = !DIDerivedType(tag: DW_TAG_member, name: "_shortbuf", scope: !26, file: !27, line: 276, baseType: !61, size: 8, align: 8, offset: 1048)
!61 = !DICompositeType(tag: DW_TAG_array_type, baseType: !13, size: 8, align: 8, elements: !62)
!62 = !{!63}
!63 = !DISubrange(count: 1)
!64 = !DIDerivedType(tag: DW_TAG_member, name: "_lock", scope: !26, file: !27, line: 280, baseType: !65, size: 64, align: 64, offset: 1088)
!65 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !66, size: 64, align: 64)
!66 = !DIDerivedType(tag: DW_TAG_typedef, name: "_IO_lock_t", file: !27, line: 150, baseType: null)
!67 = !DIDerivedType(tag: DW_TAG_member, name: "_offset", scope: !26, file: !27, line: 289, baseType: !68, size: 64, align: 64, offset: 1152)
!68 = !DIDerivedType(tag: DW_TAG_typedef, name: "__off64_t", file: !54, line: 132, baseType: !55)
!69 = !DIDerivedType(tag: DW_TAG_member, name: "__pad1", scope: !26, file: !27, line: 297, baseType: !4, size: 64, align: 64, offset: 1216)
!70 = !DIDerivedType(tag: DW_TAG_member, name: "__pad2", scope: !26, file: !27, line: 298, baseType: !4, size: 64, align: 64, offset: 1280)
!71 = !DIDerivedType(tag: DW_TAG_member, name: "__pad3", scope: !26, file: !27, line: 299, baseType: !4, size: 64, align: 64, offset: 1344)
!72 = !DIDerivedType(tag: DW_TAG_member, name: "__pad4", scope: !26, file: !27, line: 300, baseType: !4, size: 64, align: 64, offset: 1408)
!73 = !DIDerivedType(tag: DW_TAG_member, name: "__pad5", scope: !26, file: !27, line: 302, baseType: !74, size: 64, align: 64, offset: 1472)
!74 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !75, line: 62, baseType: !76)
!75 = !DIFile(filename: "/usr/local/bin/../lib/clang/3.9.0/include/stddef.h", directory: "/home/guzuxing/Documents/IMChecker/tools/engine")
!76 = !DIBasicType(name: "long unsigned int", size: 64, align: 64, encoding: DW_ATE_unsigned)
!77 = !DIDerivedType(tag: DW_TAG_member, name: "_mode", scope: !26, file: !27, line: 303, baseType: !11, size: 32, align: 32, offset: 1536)
!78 = !DIDerivedType(tag: DW_TAG_member, name: "_unused2", scope: !26, file: !27, line: 305, baseType: !79, size: 160, align: 8, offset: 1568)
!79 = !DICompositeType(tag: DW_TAG_array_type, baseType: !13, size: 160, align: 8, elements: !80)
!80 = !{!81}
!81 = !DISubrange(count: 20)
!82 = !DILocation(line: 11, column: 11, scope: !8)
!83 = !DILocation(line: 14, column: 19, scope: !8)
!84 = !DILocation(line: 14, column: 13, scope: !8)
!85 = !DILocation(line: 14, column: 11, scope: !8)
!86 = !DILocation(line: 15, column: 9, scope: !87)
!87 = distinct !DILexicalBlock(scope: !8, file: !1, line: 15, column: 9)
!88 = !DILocation(line: 15, column: 15, scope: !87)
!89 = !DILocation(line: 15, column: 9, scope: !8)
!90 = !DILocation(line: 16, column: 9, scope: !91)
!91 = distinct !DILexicalBlock(scope: !87, file: !1, line: 15, column: 23)
!92 = !DILocation(line: 18, column: 9, scope: !91)
!93 = !DILocation(line: 22, column: 15, scope: !94)
!94 = distinct !DILexicalBlock(scope: !8, file: !1, line: 22, column: 9)
!95 = !DILocation(line: 22, column: 28, scope: !94)
!96 = !DILocation(line: 22, column: 9, scope: !94)
!97 = !DILocation(line: 22, column: 35, scope: !94)
!98 = !DILocation(line: 22, column: 9, scope: !8)
!99 = !DILocation(line: 23, column: 9, scope: !100)
!100 = distinct !DILexicalBlock(scope: !94, file: !1, line: 22, column: 39)
!101 = !DILocation(line: 25, column: 8, scope: !100)
!102 = !DILocation(line: 28, column: 12, scope: !8)
!103 = !DILocation(line: 28, column: 5, scope: !8)
!104 = !DILocation(line: 29, column: 5, scope: !8)
!105 = !DILocation(line: 30, column: 1, scope: !8)
!106 = distinct !DISubprogram(name: "bad2", scope: !1, file: !1, line: 32, type: !107, isLocal: false, isDefinition: true, scopeLine: 32, isOptimized: false, unit: !0, variables: !2)
!107 = !DISubroutineType(types: !108)
!108 = !{!11}
!109 = !DILocalVariable(name: "buffer", scope: !106, file: !1, line: 33, type: !18)
!110 = !DILocation(line: 33, column: 10, scope: !106)
!111 = !DILocation(line: 35, column: 15, scope: !112)
!112 = distinct !DILexicalBlock(scope: !106, file: !1, line: 35, column: 9)
!113 = !DILocation(line: 35, column: 28, scope: !112)
!114 = !DILocation(line: 35, column: 9, scope: !112)
!115 = !DILocation(line: 35, column: 35, scope: !112)
!116 = !DILocation(line: 35, column: 9, scope: !106)
!117 = !DILocation(line: 36, column: 9, scope: !118)
!118 = distinct !DILexicalBlock(scope: !112, file: !1, line: 35, column: 39)
!119 = !DILocation(line: 37, column: 9, scope: !118)
!120 = !DILocation(line: 40, column: 5, scope: !106)
!121 = !DILocation(line: 41, column: 1, scope: !106)
!122 = distinct !DISubprogram(name: "good1", scope: !1, file: !1, line: 43, type: !9, isLocal: false, isDefinition: true, scopeLine: 43, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!123 = !DILocalVariable(name: "fileName", arg: 1, scope: !122, file: !1, line: 43, type: !12)
!124 = !DILocation(line: 43, column: 17, scope: !122)
!125 = !DILocalVariable(name: "buffer", scope: !122, file: !1, line: 44, type: !18)
!126 = !DILocation(line: 44, column: 10, scope: !122)
!127 = !DILocalVariable(name: "pFile", scope: !122, file: !1, line: 45, type: !23)
!128 = !DILocation(line: 45, column: 11, scope: !122)
!129 = !DILocation(line: 48, column: 9, scope: !130)
!130 = distinct !DILexicalBlock(scope: !122, file: !1, line: 48, column: 9)
!131 = !DILocation(line: 48, column: 18, scope: !130)
!132 = !DILocation(line: 48, column: 9, scope: !122)
!133 = !DILocation(line: 49, column: 9, scope: !134)
!134 = distinct !DILexicalBlock(scope: !130, file: !1, line: 48, column: 26)
!135 = !DILocation(line: 50, column: 9, scope: !134)
!136 = !DILocation(line: 52, column: 19, scope: !122)
!137 = !DILocation(line: 52, column: 13, scope: !122)
!138 = !DILocation(line: 52, column: 11, scope: !122)
!139 = !DILocation(line: 54, column: 9, scope: !140)
!140 = distinct !DILexicalBlock(scope: !122, file: !1, line: 54, column: 9)
!141 = !DILocation(line: 54, column: 15, scope: !140)
!142 = !DILocation(line: 54, column: 9, scope: !122)
!143 = !DILocation(line: 55, column: 9, scope: !144)
!144 = distinct !DILexicalBlock(scope: !140, file: !1, line: 54, column: 23)
!145 = !DILocation(line: 56, column: 9, scope: !144)
!146 = !DILocation(line: 59, column: 15, scope: !147)
!147 = distinct !DILexicalBlock(scope: !122, file: !1, line: 59, column: 9)
!148 = !DILocation(line: 59, column: 28, scope: !147)
!149 = !DILocation(line: 59, column: 9, scope: !147)
!150 = !DILocation(line: 59, column: 35, scope: !147)
!151 = !DILocation(line: 59, column: 9, scope: !122)
!152 = !DILocation(line: 60, column: 9, scope: !153)
!153 = distinct !DILexicalBlock(scope: !147, file: !1, line: 59, column: 43)
!154 = !DILocation(line: 61, column: 16, scope: !153)
!155 = !DILocation(line: 61, column: 9, scope: !153)
!156 = !DILocation(line: 62, column: 9, scope: !153)
!157 = !DILocation(line: 65, column: 12, scope: !122)
!158 = !DILocation(line: 65, column: 5, scope: !122)
!159 = !DILocation(line: 66, column: 5, scope: !122)
!160 = !DILocation(line: 67, column: 1, scope: !122)
!161 = distinct !DISubprogram(name: "good2", scope: !1, file: !1, line: 69, type: !107, isLocal: false, isDefinition: true, scopeLine: 69, isOptimized: false, unit: !0, variables: !2)
!162 = !DILocalVariable(name: "buffer", scope: !161, file: !1, line: 70, type: !18)
!163 = !DILocation(line: 70, column: 10, scope: !161)
!164 = !DILocation(line: 71, column: 15, scope: !165)
!165 = distinct !DILexicalBlock(scope: !161, file: !1, line: 71, column: 9)
!166 = !DILocation(line: 71, column: 28, scope: !165)
!167 = !DILocation(line: 71, column: 9, scope: !165)
!168 = !DILocation(line: 71, column: 35, scope: !165)
!169 = !DILocation(line: 71, column: 9, scope: !161)
!170 = !DILocation(line: 72, column: 9, scope: !171)
!171 = distinct !DILexicalBlock(scope: !165, file: !1, line: 71, column: 43)
!172 = !DILocation(line: 73, column: 9, scope: !171)
!173 = !DILocation(line: 76, column: 5, scope: !161)
!174 = !DILocation(line: 77, column: 1, scope: !161)
!175 = distinct !DISubprogram(name: "main", scope: !1, file: !1, line: 79, type: !107, isLocal: false, isDefinition: true, scopeLine: 79, isOptimized: false, unit: !0, variables: !2)
!176 = !DILocalVariable(name: "fileName", scope: !175, file: !1, line: 80, type: !12)
!177 = !DILocation(line: 80, column: 11, scope: !175)
!178 = !DILocation(line: 81, column: 10, scope: !175)
!179 = !DILocation(line: 81, column: 5, scope: !175)
!180 = !DILocation(line: 82, column: 5, scope: !175)
!181 = !DILocation(line: 83, column: 11, scope: !175)
!182 = !DILocation(line: 83, column: 5, scope: !175)
!183 = !DILocation(line: 84, column: 5, scope: !175)
!184 = !DILocation(line: 85, column: 1, scope: !175)
