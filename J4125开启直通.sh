#!/usr/bin/env bash


sed -i 's/quiet/quiet intel_iommu=on iommu=pt video=efifb:off/g' /etc/default/grub

echo vfio >> /etc/modules
echo vfio_iommu_type1 >> /etc/modules
echo vfio_pci >> /etc/modules
echo vfio_virqfd >> /etc/modules
echo kvmgt >> /etc/modules


echo "options vfio-pci ids=8086:3185" >> /etc/modprobe.d/vfio.conf
echo "blacklist snd_hda_intel" >> /etc/modprobe.d/blacklist.conf 
echo "blacklist snd_hda_codec_hdmi" >> /etc/modprobe.d/blacklist.conf 
echo "blacklist i915" >> /etc/modprobe.d/blacklist.conf 

update-initramfs -u
update-grub
