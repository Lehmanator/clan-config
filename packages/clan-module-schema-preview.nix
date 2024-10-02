{ bat
, jq
, lib
, module-schema
, writeShellScript
, root, self, super
, ...
}:
writeShellScript "clan-module-schema-preview" ''
  ${lib.getExe jq} '.' ${module-schema} --color-output | ${lib.getExe bat} --plain
''
