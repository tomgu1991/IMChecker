; ModuleID = 'example.i'
source_filename = "example.i"
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
  call void @llvm.dbg.declare(metadata i8** %fileName.addr, metadata !15, metadata !16), !dbg !17
  call void @llvm.dbg.declare(metadata [100 x i8]* %buffer, metadata !18, metadata !16), !dbg !22
  %0 = bitcast [100 x i8]* %buffer to i8*, !dbg !22
  call void @llvm.memset.p0i8.i64(i8* %0, i8 0, i64 100, i32 16, i1 false), !dbg !22
  call void @llvm.dbg.declare(metadata %struct._IO_FILE** %pFile, metadata !23, metadata !16), !dbg !83
  %1 = load i8*, i8** %fileName.addr, align 8, !dbg !84
  %call = call %struct._IO_FILE* @fopen(i8* %1, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str, i32 0, i32 0)), !dbg !85
  store %struct._IO_FILE* %call, %struct._IO_FILE** %pFile, align 8, !dbg !86
  %2 = load %struct._IO_FILE*, %struct._IO_FILE** %pFile, align 8, !dbg !87
  %cmp = icmp eq %struct._IO_FILE* %2, null, !dbg !89
  br i1 %cmp, label %if.then, label %if.end, !dbg !90

if.then:                                          ; preds = %entry
  call void @Log(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.1, i32 0, i32 0)), !dbg !91
  store i32 1, i32* %retval, align 4, !dbg !93
  br label %return, !dbg !93

if.end:                                           ; preds = %entry
  %arraydecay = getelementptr inbounds [100 x i8], [100 x i8]* %buffer, i32 0, i32 0, !dbg !94
  %3 = load %struct._IO_FILE*, %struct._IO_FILE** %pFile, align 8, !dbg !96
  %call1 = call i8* @fgets(i8* %arraydecay, i32 100, %struct._IO_FILE* %3), !dbg !97
  %cmp2 = icmp ult i8* %call1, null, !dbg !98
  br i1 %cmp2, label %if.then3, label %if.end4, !dbg !99

if.then3:                                         ; preds = %if.end
  call void @Log(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.2, i32 0, i32 0)), !dbg !100
  store i32 0, i32* %retval, align 4, !dbg !102
  br label %return, !dbg !102

if.end4:                                          ; preds = %if.end
  %4 = load %struct._IO_FILE*, %struct._IO_FILE** %pFile, align 8, !dbg !103
  %call5 = call i32 @fclose(%struct._IO_FILE* %4), !dbg !104
  store i32 1, i32* %retval, align 4, !dbg !105
  br label %return, !dbg !105

return:                                           ; preds = %if.end4, %if.then3, %if.then
  %5 = load i32, i32* %retval, align 4, !dbg !106
  ret i32 %5, !dbg !106
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
define i32 @bad2() #0 !dbg !107 {
entry:
  %retval = alloca i32, align 4
  %buffer = alloca [100 x i8], align 16
  call void @llvm.dbg.declare(metadata [100 x i8]* %buffer, metadata !110, metadata !16), !dbg !111
  %0 = bitcast [100 x i8]* %buffer to i8*, !dbg !111
  call void @llvm.memset.p0i8.i64(i8* %0, i8 0, i64 100, i32 16, i1 false), !dbg !111
  %arraydecay = getelementptr inbounds [100 x i8], [100 x i8]* %buffer, i32 0, i32 0, !dbg !112
  %1 = load %struct._IO_FILE*, %struct._IO_FILE** @stdin, align 8, !dbg !114
  %call = call i8* @fgets(i8* %arraydecay, i32 100, %struct._IO_FILE* %1), !dbg !115
  %cmp = icmp ult i8* %call, null, !dbg !116
  br i1 %cmp, label %if.then, label %if.end, !dbg !117

if.then:                                          ; preds = %entry
  call void @Log(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.2, i32 0, i32 0)), !dbg !118
  store i32 0, i32* %retval, align 4, !dbg !120
  br label %return, !dbg !120

if.end:                                           ; preds = %entry
  store i32 1, i32* %retval, align 4, !dbg !121
  br label %return, !dbg !121

return:                                           ; preds = %if.end, %if.then
  %2 = load i32, i32* %retval, align 4, !dbg !122
  ret i32 %2, !dbg !122
}

; Function Attrs: nounwind uwtable
define i32 @good1(i8* %fileName) #0 !dbg !123 {
entry:
  %retval = alloca i32, align 4
  %fileName.addr = alloca i8*, align 8
  %buffer = alloca [100 x i8], align 16
  %pFile = alloca %struct._IO_FILE*, align 8
  store i8* %fileName, i8** %fileName.addr, align 8
  call void @llvm.dbg.declare(metadata i8** %fileName.addr, metadata !124, metadata !16), !dbg !125
  call void @llvm.dbg.declare(metadata [100 x i8]* %buffer, metadata !126, metadata !16), !dbg !127
  %0 = bitcast [100 x i8]* %buffer to i8*, !dbg !127
  call void @llvm.memset.p0i8.i64(i8* %0, i8 0, i64 100, i32 16, i1 false), !dbg !127
  call void @llvm.dbg.declare(metadata %struct._IO_FILE** %pFile, metadata !128, metadata !16), !dbg !129
  %1 = load i8*, i8** %fileName.addr, align 8, !dbg !130
  %cmp = icmp eq i8* %1, null, !dbg !132
  br i1 %cmp, label %if.then, label %if.end, !dbg !133

if.then:                                          ; preds = %entry
  call void @Log(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.3, i32 0, i32 0)), !dbg !134
  store i32 0, i32* %retval, align 4, !dbg !136
  br label %return, !dbg !136

if.end:                                           ; preds = %entry
  %2 = load i8*, i8** %fileName.addr, align 8, !dbg !137
  %call = call %struct._IO_FILE* @fopen(i8* %2, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str, i32 0, i32 0)), !dbg !138
  store %struct._IO_FILE* %call, %struct._IO_FILE** %pFile, align 8, !dbg !139
  %3 = load %struct._IO_FILE*, %struct._IO_FILE** %pFile, align 8, !dbg !140
  %cmp1 = icmp eq %struct._IO_FILE* %3, null, !dbg !142
  br i1 %cmp1, label %if.then2, label %if.end3, !dbg !143

if.then2:                                         ; preds = %if.end
  call void @Log(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.1, i32 0, i32 0)), !dbg !144
  store i32 0, i32* %retval, align 4, !dbg !146
  br label %return, !dbg !146

if.end3:                                          ; preds = %if.end
  %arraydecay = getelementptr inbounds [100 x i8], [100 x i8]* %buffer, i32 0, i32 0, !dbg !147
  %4 = load %struct._IO_FILE*, %struct._IO_FILE** %pFile, align 8, !dbg !149
  %call4 = call i8* @fgets(i8* %arraydecay, i32 100, %struct._IO_FILE* %4), !dbg !150
  %cmp5 = icmp eq i8* %call4, null, !dbg !151
  br i1 %cmp5, label %if.then6, label %if.end8, !dbg !152

if.then6:                                         ; preds = %if.end3
  call void @Log(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.2, i32 0, i32 0)), !dbg !153
  %5 = load %struct._IO_FILE*, %struct._IO_FILE** %pFile, align 8, !dbg !155
  %call7 = call i32 @fclose(%struct._IO_FILE* %5), !dbg !156
  store i32 0, i32* %retval, align 4, !dbg !157
  br label %return, !dbg !157

if.end8:                                          ; preds = %if.end3
  %6 = load %struct._IO_FILE*, %struct._IO_FILE** %pFile, align 8, !dbg !158
  %call9 = call i32 @fclose(%struct._IO_FILE* %6), !dbg !159
  store i32 1, i32* %retval, align 4, !dbg !160
  br label %return, !dbg !160

return:                                           ; preds = %if.end8, %if.then6, %if.then2, %if.then
  %7 = load i32, i32* %retval, align 4, !dbg !161
  ret i32 %7, !dbg !161
}

; Function Attrs: nounwind uwtable
define i32 @good2() #0 !dbg !162 {
entry:
  %retval = alloca i32, align 4
  %buffer = alloca [100 x i8], align 16
  call void @llvm.dbg.declare(metadata [100 x i8]* %buffer, metadata !163, metadata !16), !dbg !164
  %0 = bitcast [100 x i8]* %buffer to i8*, !dbg !164
  call void @llvm.memset.p0i8.i64(i8* %0, i8 0, i64 100, i32 16, i1 false), !dbg !164
  %arraydecay = getelementptr inbounds [100 x i8], [100 x i8]* %buffer, i32 0, i32 0, !dbg !165
  %1 = load %struct._IO_FILE*, %struct._IO_FILE** @stdin, align 8, !dbg !167
  %call = call i8* @fgets(i8* %arraydecay, i32 100, %struct._IO_FILE* %1), !dbg !168
  %cmp = icmp eq i8* %call, null, !dbg !169
  br i1 %cmp, label %if.then, label %if.end, !dbg !170

if.then:                                          ; preds = %entry
  call void @Log(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.2, i32 0, i32 0)), !dbg !171
  store i32 0, i32* %retval, align 4, !dbg !173
  br label %return, !dbg !173

if.end:                                           ; preds = %entry
  store i32 1, i32* %retval, align 4, !dbg !174
  br label %return, !dbg !174

return:                                           ; preds = %if.end, %if.then
  %2 = load i32, i32* %retval, align 4, !dbg !175
  ret i32 %2, !dbg !175
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 !dbg !176 {
entry:
  %fileName = alloca i8*, align 8
  call void @llvm.dbg.declare(metadata i8** %fileName, metadata !177, metadata !16), !dbg !178
  store i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.4, i32 0, i32 0), i8** %fileName, align 8, !dbg !178
  %0 = load i8*, i8** %fileName, align 8, !dbg !179
  %call = call i32 @bad1(i8* %0), !dbg !180
  %call1 = call i32 @bad2(), !dbg !181
  %1 = load i8*, i8** %fileName, align 8, !dbg !182
  %call2 = call i32 @good1(i8* %1), !dbg !183
  %call3 = call i32 @good2(), !dbg !184
  ret i32 0, !dbg !185
}

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { argmemonly nounwind }
attributes #3 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!5, !6}
!llvm.ident = !{!7}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 3.9.0 (tags/RELEASE_390/final)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !3)
!1 = !DIFile(filename: "example.i", directory: "/home/guzuxing/Documents/IMChecker/tools/example_code")
!2 = !{}
!3 = !{!4}
!4 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64, align: 64)
!5 = !{i32 2, !"Dwarf Version", i32 4}
!6 = !{i32 2, !"Debug Info Version", i32 3}
!7 = !{!"clang version 3.9.0 (tags/RELEASE_390/final)"}
!8 = distinct !DISubprogram(name: "bad1", scope: !9, file: !9, line: 9, type: !10, isLocal: false, isDefinition: true, scopeLine: 9, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!9 = !DIFile(filename: "example.c", directory: "/home/guzuxing/Documents/IMChecker/tools/example_code")
!10 = !DISubroutineType(types: !11)
!11 = !{!12, !13}
!12 = !DIBasicType(name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!13 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !14, size: 64, align: 64)
!14 = !DIBasicType(name: "char", size: 8, align: 8, encoding: DW_ATE_signed_char)
!15 = !DILocalVariable(name: "fileName", arg: 1, scope: !8, file: !9, line: 9, type: !13)
!16 = !DIExpression()
!17 = !DILocation(line: 9, column: 16, scope: !8)
!18 = !DILocalVariable(name: "buffer", scope: !8, file: !9, line: 10, type: !19)
!19 = !DICompositeType(tag: DW_TAG_array_type, baseType: !14, size: 800, align: 8, elements: !20)
!20 = !{!21}
!21 = !DISubrange(count: 100)
!22 = !DILocation(line: 10, column: 10, scope: !8)
!23 = !DILocalVariable(name: "pFile", scope: !8, file: !9, line: 11, type: !24)
!24 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !25, size: 64, align: 64)
!25 = !DIDerivedType(tag: DW_TAG_typedef, name: "FILE", file: !26, line: 48, baseType: !27)
!26 = !DIFile(filename: "/usr/include/stdio.h", directory: "/home/guzuxing/Documents/IMChecker/tools/example_code")
!27 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_FILE", file: !28, line: 241, size: 1728, align: 64, elements: !29)
!28 = !DIFile(filename: "/usr/include/libio.h", directory: "/home/guzuxing/Documents/IMChecker/tools/example_code")
!29 = !{!30, !31, !32, !33, !34, !35, !36, !37, !38, !39, !40, !41, !42, !50, !51, !52, !53, !57, !59, !61, !65, !68, !70, !71, !72, !73, !74, !78, !79}
!30 = !DIDerivedType(tag: DW_TAG_member, name: "_flags", scope: !27, file: !28, line: 242, baseType: !12, size: 32, align: 32)
!31 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_read_ptr", scope: !27, file: !28, line: 247, baseType: !13, size: 64, align: 64, offset: 64)
!32 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_read_end", scope: !27, file: !28, line: 248, baseType: !13, size: 64, align: 64, offset: 128)
!33 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_read_base", scope: !27, file: !28, line: 249, baseType: !13, size: 64, align: 64, offset: 192)
!34 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_write_base", scope: !27, file: !28, line: 250, baseType: !13, size: 64, align: 64, offset: 256)
!35 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_write_ptr", scope: !27, file: !28, line: 251, baseType: !13, size: 64, align: 64, offset: 320)
!36 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_write_end", scope: !27, file: !28, line: 252, baseType: !13, size: 64, align: 64, offset: 384)
!37 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_buf_base", scope: !27, file: !28, line: 253, baseType: !13, size: 64, align: 64, offset: 448)
!38 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_buf_end", scope: !27, file: !28, line: 254, baseType: !13, size: 64, align: 64, offset: 512)
!39 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_save_base", scope: !27, file: !28, line: 256, baseType: !13, size: 64, align: 64, offset: 576)
!40 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_backup_base", scope: !27, file: !28, line: 257, baseType: !13, size: 64, align: 64, offset: 640)
!41 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_save_end", scope: !27, file: !28, line: 258, baseType: !13, size: 64, align: 64, offset: 704)
!42 = !DIDerivedType(tag: DW_TAG_member, name: "_markers", scope: !27, file: !28, line: 260, baseType: !43, size: 64, align: 64, offset: 768)
!43 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !44, size: 64, align: 64)
!44 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_marker", file: !28, line: 156, size: 192, align: 64, elements: !45)
!45 = !{!46, !47, !49}
!46 = !DIDerivedType(tag: DW_TAG_member, name: "_next", scope: !44, file: !28, line: 157, baseType: !43, size: 64, align: 64)
!47 = !DIDerivedType(tag: DW_TAG_member, name: "_sbuf", scope: !44, file: !28, line: 158, baseType: !48, size: 64, align: 64, offset: 64)
!48 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !27, size: 64, align: 64)
!49 = !DIDerivedType(tag: DW_TAG_member, name: "_pos", scope: !44, file: !28, line: 162, baseType: !12, size: 32, align: 32, offset: 128)
!50 = !DIDerivedType(tag: DW_TAG_member, name: "_chain", scope: !27, file: !28, line: 262, baseType: !48, size: 64, align: 64, offset: 832)
!51 = !DIDerivedType(tag: DW_TAG_member, name: "_fileno", scope: !27, file: !28, line: 264, baseType: !12, size: 32, align: 32, offset: 896)
!52 = !DIDerivedType(tag: DW_TAG_member, name: "_flags2", scope: !27, file: !28, line: 268, baseType: !12, size: 32, align: 32, offset: 928)
!53 = !DIDerivedType(tag: DW_TAG_member, name: "_old_offset", scope: !27, file: !28, line: 270, baseType: !54, size: 64, align: 64, offset: 960)
!54 = !DIDerivedType(tag: DW_TAG_typedef, name: "__off_t", file: !55, line: 131, baseType: !56)
!55 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types.h", directory: "/home/guzuxing/Documents/IMChecker/tools/example_code")
!56 = !DIBasicType(name: "long int", size: 64, align: 64, encoding: DW_ATE_signed)
!57 = !DIDerivedType(tag: DW_TAG_member, name: "_cur_column", scope: !27, file: !28, line: 274, baseType: !58, size: 16, align: 16, offset: 1024)
!58 = !DIBasicType(name: "unsigned short", size: 16, align: 16, encoding: DW_ATE_unsigned)
!59 = !DIDerivedType(tag: DW_TAG_member, name: "_vtable_offset", scope: !27, file: !28, line: 275, baseType: !60, size: 8, align: 8, offset: 1040)
!60 = !DIBasicType(name: "signed char", size: 8, align: 8, encoding: DW_ATE_signed_char)
!61 = !DIDerivedType(tag: DW_TAG_member, name: "_shortbuf", scope: !27, file: !28, line: 276, baseType: !62, size: 8, align: 8, offset: 1048)
!62 = !DICompositeType(tag: DW_TAG_array_type, baseType: !14, size: 8, align: 8, elements: !63)
!63 = !{!64}
!64 = !DISubrange(count: 1)
!65 = !DIDerivedType(tag: DW_TAG_member, name: "_lock", scope: !27, file: !28, line: 280, baseType: !66, size: 64, align: 64, offset: 1088)
!66 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !67, size: 64, align: 64)
!67 = !DIDerivedType(tag: DW_TAG_typedef, name: "_IO_lock_t", file: !28, line: 150, baseType: null)
!68 = !DIDerivedType(tag: DW_TAG_member, name: "_offset", scope: !27, file: !28, line: 289, baseType: !69, size: 64, align: 64, offset: 1152)
!69 = !DIDerivedType(tag: DW_TAG_typedef, name: "__off64_t", file: !55, line: 132, baseType: !56)
!70 = !DIDerivedType(tag: DW_TAG_member, name: "__pad1", scope: !27, file: !28, line: 297, baseType: !4, size: 64, align: 64, offset: 1216)
!71 = !DIDerivedType(tag: DW_TAG_member, name: "__pad2", scope: !27, file: !28, line: 298, baseType: !4, size: 64, align: 64, offset: 1280)
!72 = !DIDerivedType(tag: DW_TAG_member, name: "__pad3", scope: !27, file: !28, line: 299, baseType: !4, size: 64, align: 64, offset: 1344)
!73 = !DIDerivedType(tag: DW_TAG_member, name: "__pad4", scope: !27, file: !28, line: 300, baseType: !4, size: 64, align: 64, offset: 1408)
!74 = !DIDerivedType(tag: DW_TAG_member, name: "__pad5", scope: !27, file: !28, line: 302, baseType: !75, size: 64, align: 64, offset: 1472)
!75 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !76, line: 216, baseType: !77)
!76 = !DIFile(filename: "/usr/lib/gcc/x86_64-linux-gnu/5/include/stddef.h", directory: "/home/guzuxing/Documents/IMChecker/tools/example_code")
!77 = !DIBasicType(name: "long unsigned int", size: 64, align: 64, encoding: DW_ATE_unsigned)
!78 = !DIDerivedType(tag: DW_TAG_member, name: "_mode", scope: !27, file: !28, line: 303, baseType: !12, size: 32, align: 32, offset: 1536)
!79 = !DIDerivedType(tag: DW_TAG_member, name: "_unused2", scope: !27, file: !28, line: 305, baseType: !80, size: 160, align: 8, offset: 1568)
!80 = !DICompositeType(tag: DW_TAG_array_type, baseType: !14, size: 160, align: 8, elements: !81)
!81 = !{!82}
!82 = !DISubrange(count: 20)
!83 = !DILocation(line: 11, column: 11, scope: !8)
!84 = !DILocation(line: 14, column: 19, scope: !8)
!85 = !DILocation(line: 14, column: 13, scope: !8)
!86 = !DILocation(line: 14, column: 11, scope: !8)
!87 = !DILocation(line: 15, column: 9, scope: !88)
!88 = distinct !DILexicalBlock(scope: !8, file: !9, line: 15, column: 9)
!89 = !DILocation(line: 15, column: 15, scope: !88)
!90 = !DILocation(line: 15, column: 9, scope: !8)
!91 = !DILocation(line: 16, column: 9, scope: !92)
!92 = distinct !DILexicalBlock(scope: !88, file: !9, line: 15, column: 22)
!93 = !DILocation(line: 18, column: 9, scope: !92)
!94 = !DILocation(line: 22, column: 15, scope: !95)
!95 = distinct !DILexicalBlock(scope: !8, file: !9, line: 22, column: 9)
!96 = !DILocation(line: 22, column: 28, scope: !95)
!97 = !DILocation(line: 22, column: 9, scope: !95)
!98 = !DILocation(line: 22, column: 35, scope: !95)
!99 = !DILocation(line: 22, column: 9, scope: !8)
!100 = !DILocation(line: 23, column: 9, scope: !101)
!101 = distinct !DILexicalBlock(scope: !95, file: !9, line: 22, column: 39)
!102 = !DILocation(line: 25, column: 8, scope: !101)
!103 = !DILocation(line: 28, column: 12, scope: !8)
!104 = !DILocation(line: 28, column: 5, scope: !8)
!105 = !DILocation(line: 29, column: 5, scope: !8)
!106 = !DILocation(line: 30, column: 1, scope: !8)
!107 = distinct !DISubprogram(name: "bad2", scope: !9, file: !9, line: 32, type: !108, isLocal: false, isDefinition: true, scopeLine: 32, isOptimized: false, unit: !0, variables: !2)
!108 = !DISubroutineType(types: !109)
!109 = !{!12}
!110 = !DILocalVariable(name: "buffer", scope: !107, file: !9, line: 33, type: !19)
!111 = !DILocation(line: 33, column: 10, scope: !107)
!112 = !DILocation(line: 35, column: 15, scope: !113)
!113 = distinct !DILexicalBlock(scope: !107, file: !9, line: 35, column: 9)
!114 = !DILocation(line: 35, column: 27, scope: !113)
!115 = !DILocation(line: 35, column: 9, scope: !113)
!116 = !DILocation(line: 35, column: 34, scope: !113)
!117 = !DILocation(line: 35, column: 9, scope: !107)
!118 = !DILocation(line: 36, column: 9, scope: !119)
!119 = distinct !DILexicalBlock(scope: !113, file: !9, line: 35, column: 38)
!120 = !DILocation(line: 37, column: 9, scope: !119)
!121 = !DILocation(line: 40, column: 5, scope: !107)
!122 = !DILocation(line: 41, column: 1, scope: !107)
!123 = distinct !DISubprogram(name: "good1", scope: !9, file: !9, line: 43, type: !10, isLocal: false, isDefinition: true, scopeLine: 43, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!124 = !DILocalVariable(name: "fileName", arg: 1, scope: !123, file: !9, line: 43, type: !13)
!125 = !DILocation(line: 43, column: 17, scope: !123)
!126 = !DILocalVariable(name: "buffer", scope: !123, file: !9, line: 44, type: !19)
!127 = !DILocation(line: 44, column: 10, scope: !123)
!128 = !DILocalVariable(name: "pFile", scope: !123, file: !9, line: 45, type: !24)
!129 = !DILocation(line: 45, column: 11, scope: !123)
!130 = !DILocation(line: 48, column: 9, scope: !131)
!131 = distinct !DILexicalBlock(scope: !123, file: !9, line: 48, column: 9)
!132 = !DILocation(line: 48, column: 18, scope: !131)
!133 = !DILocation(line: 48, column: 9, scope: !123)
!134 = !DILocation(line: 49, column: 9, scope: !135)
!135 = distinct !DILexicalBlock(scope: !131, file: !9, line: 48, column: 25)
!136 = !DILocation(line: 50, column: 9, scope: !135)
!137 = !DILocation(line: 52, column: 19, scope: !123)
!138 = !DILocation(line: 52, column: 13, scope: !123)
!139 = !DILocation(line: 52, column: 11, scope: !123)
!140 = !DILocation(line: 54, column: 9, scope: !141)
!141 = distinct !DILexicalBlock(scope: !123, file: !9, line: 54, column: 9)
!142 = !DILocation(line: 54, column: 15, scope: !141)
!143 = !DILocation(line: 54, column: 9, scope: !123)
!144 = !DILocation(line: 55, column: 9, scope: !145)
!145 = distinct !DILexicalBlock(scope: !141, file: !9, line: 54, column: 22)
!146 = !DILocation(line: 56, column: 9, scope: !145)
!147 = !DILocation(line: 59, column: 15, scope: !148)
!148 = distinct !DILexicalBlock(scope: !123, file: !9, line: 59, column: 9)
!149 = !DILocation(line: 59, column: 28, scope: !148)
!150 = !DILocation(line: 59, column: 9, scope: !148)
!151 = !DILocation(line: 59, column: 35, scope: !148)
!152 = !DILocation(line: 59, column: 9, scope: !123)
!153 = !DILocation(line: 60, column: 9, scope: !154)
!154 = distinct !DILexicalBlock(scope: !148, file: !9, line: 59, column: 42)
!155 = !DILocation(line: 61, column: 16, scope: !154)
!156 = !DILocation(line: 61, column: 9, scope: !154)
!157 = !DILocation(line: 62, column: 9, scope: !154)
!158 = !DILocation(line: 65, column: 12, scope: !123)
!159 = !DILocation(line: 65, column: 5, scope: !123)
!160 = !DILocation(line: 66, column: 5, scope: !123)
!161 = !DILocation(line: 67, column: 1, scope: !123)
!162 = distinct !DISubprogram(name: "good2", scope: !9, file: !9, line: 69, type: !108, isLocal: false, isDefinition: true, scopeLine: 69, isOptimized: false, unit: !0, variables: !2)
!163 = !DILocalVariable(name: "buffer", scope: !162, file: !9, line: 70, type: !19)
!164 = !DILocation(line: 70, column: 10, scope: !162)
!165 = !DILocation(line: 71, column: 15, scope: !166)
!166 = distinct !DILexicalBlock(scope: !162, file: !9, line: 71, column: 9)
!167 = !DILocation(line: 71, column: 27, scope: !166)
!168 = !DILocation(line: 71, column: 9, scope: !166)
!169 = !DILocation(line: 71, column: 34, scope: !166)
!170 = !DILocation(line: 71, column: 9, scope: !162)
!171 = !DILocation(line: 72, column: 9, scope: !172)
!172 = distinct !DILexicalBlock(scope: !166, file: !9, line: 71, column: 42)
!173 = !DILocation(line: 73, column: 9, scope: !172)
!174 = !DILocation(line: 76, column: 5, scope: !162)
!175 = !DILocation(line: 77, column: 1, scope: !162)
!176 = distinct !DISubprogram(name: "main", scope: !9, file: !9, line: 79, type: !108, isLocal: false, isDefinition: true, scopeLine: 79, isOptimized: false, unit: !0, variables: !2)
!177 = !DILocalVariable(name: "fileName", scope: !176, file: !9, line: 80, type: !13)
!178 = !DILocation(line: 80, column: 11, scope: !176)
!179 = !DILocation(line: 81, column: 10, scope: !176)
!180 = !DILocation(line: 81, column: 5, scope: !176)
!181 = !DILocation(line: 82, column: 5, scope: !176)
!182 = !DILocation(line: 83, column: 11, scope: !176)
!183 = !DILocation(line: 83, column: 5, scope: !176)
!184 = !DILocation(line: 84, column: 5, scope: !176)
!185 = !DILocation(line: 85, column: 1, scope: !176)
