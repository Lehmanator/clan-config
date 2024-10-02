{ clan-cli
, nuenv
, lib
, root, super, self
, ...
}:
  nuenv.writeScriptBin {
    name = "clan-flash";
    script = let
      clan = lib.getExe clan-cli;
    in ''

      # Get list of devices
      let diskinfo = (
        lsblk --json --output PATH,HOTPLUG,SIZE,TYPE,VENDOR,MODEL,LABEL,STATE,MOUNTPOINT --nodeps
        | from json
        | get blockdevices
        | where hotplug == true
        | where type == "disk"
      );

      # Display table of devices to user.
      $diskinfo
      | reject hotplug type
      | table -i false

      # Ask user to select disk from list
      let disk = ($diskinfo
      | input list --fuzzy --display path "Select the device to flash:\n"
      | get path
      );
  
      # Ask user for SSH public key to add to installer
      let key = (
        ls ~/.ssh/*.pub
        | where type == file
        | input list --fuzzy --display name "Select the SSH public key to access the new system with:\n"
        | get name
      ) 

      # Ask user which machine to flash
      # TODO: Split description.
      let machine = (
        ${clan} machines list
         | lines
         | append (${clan} machines list --flake ${root} | lines)
         | input list --fuzzy "Select the clan machine to flash:\n"
      )

      # Flash the disk with installer
      # TODO: Ask user to select flake
      (${clan} flash
        --flake git+https://git.clan.lol/clan/clan-core
        --ssh-pubkey $key
        --keymap en
        --language en
        --disk main $disk
        $machine
        # --ssh-pubkey $HOME/.ssh/id_ed25519.pub
        #flash-installer
      )
    '';
}
