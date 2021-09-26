{ pkgs, ... }:
{
  hardware.fancontrol.enable = true;
  hardware.fancontrol.config = ''
    # Helios64 PWM Fan Control Configuration
    # Temp source : /dev/thermal-cpu
    INTERVAL=10
    FCTEMPS=/dev/fan-p6/pwm1=/dev/thermal-cpu/temp1_input /dev/fan-p7/pwm1=/dev/thermal-cpu/temp1_input
    MINTEMP=/dev/fan-p6/pwm1=40 /dev/fan-p7/pwm1=40
    MAXTEMP=/dev/fan-p6/pwm1=80 /dev/fan-p7/pwm1=80
    MINSTART=/dev/fan-p6/pwm1=60 /dev/fan-p7/pwm1=60
    MINSTOP=/dev/fan-p6/pwm1=29 /dev/fan-p7/pwm1=29
    MINPWM=20
  '';

  services.udev.packages = [
    # Fan control
    (pkgs.callPackage (
      { stdenv, lib, coreutils }:
      stdenv.mkDerivation {
        name = "helios64-udev-fancontrol";

        dontUnpack = true;
        dontBuild = true;

        installPhase = ''
          mkdir -p "$out/etc/udev/rules.d/";
          install -Dm644 "${../bsp/90-helios64-hwmon.rules}"        "$out/etc/udev/rules.d/90-helios64-hwmon.rules"
          substituteInPlace "$out/etc/udev/rules.d/90-helios64-hwmon.rules" \
            --replace '/bin/ln'  '${lib.getBin coreutils}/bin/ln'
        '';

        meta = with lib; {
          description = "udev fancontrol for Helios64";
          longDescription = ''
            To install udev rules, add `services.udev.packages = [ helios64-udev-fancontrol ]`
            into `nixos/configuration.nix`.
          '';
          platforms = platforms.linux;
          maintainers = with maintainers; [ angerman ];
        };
      }
    ) {})
  ];

  nixpkgs.overlays = [(final: super: {
    # https://github.com/NixOS/nixpkgs/pull/139577
    lm_sensors = super.lm_sensors.overrideAttrs({ buildInputs ? [], ... }: {
      buildInputs = buildInputs ++ [ final.bash ];
    });
  })];
}
