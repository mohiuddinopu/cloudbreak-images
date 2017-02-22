{% if grains['os_family'] == 'RedHat' %}
create_ambari_repo:
  pkgrepo.managed:
    - name: ambari
    - humanname: "AMBARI.{{ pillar['AMBARI_VERSION'] }}"
    - baseurl: "{{ pillar['AMBARI_BASEURL'] }}"
    - gpgcheck: 1
    - gpgkey: "{{ pillar['AMBARI_GPGKEY'] }}"
    - priority: 1
{% elif grains['os_family'] == 'Debian' %}
create_ambari_repo:
  pkgrepo.managed:
    - humanname: "AMBARI.{{ pillar['AMBARI_VERSION'] }}"
    - name: "deb {{ pillar['AMBARI_BASEURL'] }} Ambari main"
    - file: /etc/apt/sources.list.d/ambari.list
    - keyid: "{{ pillar['AMBARI_GPGKEY'] }}"
    - keyserver: keyserver.ubuntu.com
    - priority: 1
{% endif %}

install_ambari_pgks:
  pkg.installed:
    - pkgs:
      - ambari-server
      - ambari-agent
    - require:
      - pkgrepo: create_ambari_repo

disable_ambari_server:
  cmd.run:
    - name: chkconfig ambari-server off
    - onlyif: /sbin/chkconfig --list ambari-server | grep on

disable_ambari_agent:
  cmd.run:
    - name: chkconfig ambari-agent off
    - onlyif: /sbin/chkconfig --list ambari-agent | grep on

{% if grains['init'] == 'systemd' %}
/usr/lib/tmpfiles.d:
  file.recurse:
    - source: salt://{{ slspath }}/usr/lib/tmpfiles.d/
    - include_empty: True
{% endif %}
