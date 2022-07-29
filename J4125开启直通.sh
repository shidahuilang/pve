#!/usr/bin/env bash

grep "iommu" /etc/default/grub >/dev/null
if [ $? -eq 1 ]; then
sed -i 's/quiet/quiet intel_iommu=on iommu=pt video=efifb:off/g' /etc/default/grub
fi


grep "vfio" /etc/modules >/dev/null
if [ $? -eq 1 ]; then
echo vfio >> /etc/modules
echo vfio_iommu_type1 >> /etc/modules
echo vfio_pci >> /etc/modules
echo vfio_virqfd >> /etc/modules
echo kvmgt >> /etc/modules
fi

grep "blacklist" /etc/modprobe.d/blacklist.conf >/dev/null
if [ $? -eq 1 ]; then
echo "blacklist snd_hda_intel" >> /etc/modprobe.d/blacklist.conf 
echo "blacklist snd_hda_codec_hdmi" >> /etc/modprobe.d/blacklist.conf 
echo "blacklist i915" >> /etc/modprobe.d/blacklist.conf 
fi

grep "vfio" /etc/modprobe.d/vfio.conf >/dev/null
if [ $? -eq 1 ]; then
echo "options vfio-pci ids=8086:3185" >> /etc/modprobe.d/vfio.conf
fi
update-initramfs -u
update-grub

