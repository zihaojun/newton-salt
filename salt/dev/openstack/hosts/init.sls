{% if salt['pillar.get']('common:HOSTS',{}) %}
{% for hostname,ip in salt['pillar.get']('common:HOSTS',{}).items() %}
{{hostname}}:
   host.present:
       - ip: {{ ip }}
{% endfor %}
{% endif %}

{% if salt['pillar.get']('nova:CONTROLLER:HOSTS',{}) %}
{% for hostname,ip in salt['pillar.get']('nova:CONTROLLER:HOSTS',{}).items() %}
{{hostname}}:
   host.present:
       - ip: {{ ip }}
{% endfor %}
{% endif %}

{% if salt['pillar.get']('nova:COMPUTE:HOSTS',{}) %}
{% for hostname,ip in salt['pillar.get']('nova:COMPUTE:HOSTS',{}).items() %}
{{hostname}}:
   host.present:
       - ip: {{ ip }}
{% endfor %}
{% endif %}

add-vip-hosts:
    host.present:
       - name: {{ salt['pillar.get']('pacemaker:VIP_HOSTNAME') }}
       - ip: {{ salt['pillar.get']('pacemaker:VIP') }}


