include:
  - {{ slspath }}.repository
  - {{ slspath }}.packages
  - {{ slspath }}.sudo
{% if pillar['subtype'] != 'Docker' %}
  - {{ slspath }}.sysctl
  - {{ slspath }}.disable_ipv6
  - {{ slspath }}.selinux
{% endif %}
  - {{ slspath }}.ssh
  - {{ slspath }}.pip
  - {{ slspath }}.cert-tool
  - {{ slspath }}.dnsmasq
  - {{ slspath }}.user
  - {{ slspath }}.firewall
  - {{ slspath }}.noexec

/usr/bin/:
  file.recurse:
    - source: salt://{{ slspath }}/usr/bin/
    - template: jinja
    - include_empty: True
    - file_mode: 755

/usr/lib/jvm:
  file.recurse:
    - source: salt://{{ slspath }}/usr/lib/jvm/
    - include_empty: True
