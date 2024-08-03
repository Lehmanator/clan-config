{ nuenv
, lib
, formats
}:
let
  boot-keybinds.oems = [
    { oem = "Acer";      boot = ["F12"];          bios = ["F2" "Del"]; }
    { oem = "Apple";     boot = ["Option / Alt"]; bios = [];           }
    { oem = "Asus";      boot = ["F2" "Alt"];     bios = ["F2" "Del"]; }
    { oem = "Dell";      boot = ["F12"];          bios = ["F2" "Del"]; } # TODO: Check Wyse
    { oem = "Framework"; boot = ["F12"];          bios = ["F2"];       }
    { oem = "HP";        boot = ["F9"];           bios = ["Esc"];      }
    { oem = "Lenovo";    boot = ["F12" "F2 + Fn"];  bios = ["F2+Novo-Button"]; }
    { oem = "MSI";       boot = ["F11"];          bios = ["Del"];            }
    { oem = "Sony";      boot = ["F11"];          bios = ["Assist Button"];  }
    { oem = "Toshiba";   boot = ["F12" "F2"];     bios = ["Esc -> F12"];     }
  ];
  json = (formats.json {}).generate "boot-keybinds.json" boot-keybinds;
in
nuenv.writeScriptBin {
  name = "clan-installer-instructions";
  script = ''
    print "\n"
    print "You may need to reboot into your machine's BIOS setup menu to set the boot order to attempt to boot from USB before the current OS.\n"
    print "Here are some startup keybinds for common OEMs: \n"
    let data = cat ${json} | from json | get oems;
    $data
    |  move boot --before bios 
    |  move oem  --before boot 
    |  rename OEM "Boot Menu" "BIOS Setup" 
    |  table --index false --expand --flatten --flatten-separator ' | '
  '';
}
