#!/usr/bin/env bash

orig_iso="$HOME"/downloads/debian-13.2.0-amd64-netinst.iso
new_files="$HOME"/pers/setup/k8s/iso
new_iso="$HOME"/pers/bchk-baked-debian-13.2.0-amd64-netinst.iso
mbr_template=isohdpfx.bin

dd if="$orig_iso" bs=1 count=432 of="$mbr_template"

xorriso -as mkisofs \
   -r -V 'DEBIAN_13_2_0_AMD64' \
   -o "$new_iso" \
   -J -J -joliet-long -cache-inodes \
   -isohybrid-mbr "$mbr_template" \
   -b isolinux/isolinux.bin \
   -c isolinux/boot.cat \
   -boot-load-size 4 -boot-info-table -no-emul-boot \
   -eltorito-alt-boot \
   -e boot/grub/efi.img \
   -no-emul-boot -isohybrid-gpt-basdat -isohybrid-apm-hfsplus \
   "$new_files"
