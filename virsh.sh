# sudo virsh net-destroy vagrant-libvirt
# sudo virsh net-undefine --network vagrant-libvirt
# sudo virsh net-define ./vagrant-libvirt.xml
# sudo virsh net-start --network vagrant-libvirt

UUID=$(sudo virsh net-info --network vagrant-libvirt | grep UUID | awk '{print $2}')
sed -i -e '/vagrant-libvirt/a\' -e "  <uuid>$UUID</uuid>" ./vagrant-libvirt.xml
sudo virsh net-define ./vagrant-libvirt.xml
sudo virsh net-destroy vagrant-libvirt
sudo virsh net-start --network vagrant-libvirt
