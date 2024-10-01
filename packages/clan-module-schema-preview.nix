{
  bat
, jq
, lib
, module-schema
, writeShellScript
}:
writeShellScript "clan-module-schema-preview" ''
  ${lib.getExe jq} '.' ${module-schema} --color-output | ${lib.getExe bat} --plain
''
