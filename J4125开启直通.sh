#!/usr/bin/env bash


sed -i 's/quiet/quiet intel_iommu=on iommu=pt video=efifb:off/g' /etc/default/grub

echo vfio >> /etc/modules
echo vfio_iommu_type1 >> /etc/modules
echo vfio_pci >> /etc/modules
echo vfio_virqfd >> /etc/modules
echo kvmgt >> /etc/modules
update-initramfs -k all -u

cat >> /etc/modprobe.d/vfio.conf <<'EOF'
options vfio-pci ids=8086:3185
EOF

update-initramfs -u
update-grub
