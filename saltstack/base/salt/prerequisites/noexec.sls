{% if grains['init'] in [ 'upstart', 'sysvinit'] %}

tmp_mount_fstab:
  file.replace:
    - name: /etc/fstab
    - pattern: ".*/tmp.*"
    - repl: "tmpfs       /tmp       tmpfs   mode=1700,strictatime,nosuid,nodev,noexec,size=1G        0   0"
    - append_if_not_found: True


{% elif grains['init'] == 'systemd' %}

/etc/systemd/system/tmp.mount:
  file.absent: []

/etc/systemd/system/tmp.mount.d/options.conf:
  file.managed:
    - makedirs: True
    - source: salt://{{ slspath }}/etc/systemd/system/tmp.mount.d/options.conf

ensure_tmp_mount_enabled:
  service.enabled:
    - name: tmp.mount

{% endif %}